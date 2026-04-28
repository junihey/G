# Peter Steinberger – You Can Just Do Things

> *The year is 2025.*

---

## General Rules

- NEVER delete or revert files unless explicitly requested in this session.
- Moving/renaming and restoring files is allowed.
- Do not run destructive git operations (e.g., reset --hard, rm, checkout/restore to an older commit) unless explicitly requested.
- Always double-check git status before any commit.
- No quick fixes – properly fix TypeScript errors and code issues.
- Use proper TypeScript types instead of `any`
  - AVOID TYPE ASSERTION ANTI-PATTERNS: Never use `as unknown as` or other unsafe type assertions
  - Instead create proper type transformers in `src/lib/validation/transformers.ts`
  - Use type guards and proper validation for type conversions
  - Example: Create `transformUserV2ToTwitterApiUser()` instead of `user as TwitterApiUser`
- Be critical of bad practices and challenge poor architectural decisions

---

## 🚨 CRITICAL ANTIPATTERN: "Handle Both Formats"

NEVER write code that handles multiple data formats like this:

```typescript
// ✗ ANTIPATTERN - "Handle both" creates technical debt
const date = data.createdAt instanceof Date ? data.createdAt : new Date(data.createdAt);
const authorId = data.authorId || data.author_id; // Both camelCase and snake_case
const isoString = userData.createdAt instanceof Date
  ? userData.createdAt.toISOString()
  : userData.createdAt; // NEVER DO THIS!
```

**Why this is wrong:**

- Violates single source of truth principle
- Creates maintenance burden across codebase
- Hides the real architectural issue
- Leads to inconsistent data handling
- THESE ARE HACKS, NOT SOLUTIONS

**The correct approach:**

- ALWAYS fix the root cause (boundary transformation, serialization, API response structure)
- Maintain clean data flow with single format
- Respect the established Zod boundary architecture
- Use proper validation/transformation at entry points
- **Never compromise on data type consistency**

---

## Code References Format

When referencing code locations, MUST use VS Code clickable format:

- `path/to/file.ts:123` (single line)
- `path/to/file.ts:123-456` (range)

---

## 📦 Package Manager - PNPM ONLY

THIS PROJECT USES PNPM EXCLUSIVELY - NEVER USE NPM OR YARN

---

## 🖥 Development Environment

```bash
pnpm env:dev      # Local development (isolated)
pnpm env:prod     # Production-like (BE CAREFUL - real data!)
pnpm env:status   # Check current environment
pnpm run dev      # Start dev server (ONLY when user requests)
```

⚠️ **CRITICAL:** The user usually has a dev server already running on localhost:3000

- NEVER start your own dev server unless explicitly asked
- NEVER kill or restart the existing server
- Always use the existing localhost:3000 for testing
- If you accidentally start a server, immediately kill it
- The user will get angry if you kill their running server!

**Local Mode:**

- `pnpm run dev` automatically starts Docker containers (PostgreSQL + CloudBeaver)
- IMPORTANT: Never manually start Docker containers – `pnpm run dev` handles this automatically
- PostgreSQL runs on localhost:5432
- CloudBeaver UI available at localhost:8080
- Completely isolated from production
- To reset the database: Stop dev server first, then run `pnpm run db:reset`

**Production Mode:** Connects to production Neon database

**Environment Files:**

- `.env` – Active configuration (Next.js reads this)
- `.env.prod-like` – Vercel Preview environment template
- `.env.dev.local` – Local development configuration
- `docker-compose.dev.yml` – Local services configuration
- `.env.backup` – Automatic backup when switching

---

## 🗄 Database Management

### Kysely with CamelCase

Kysely Docs: https://kysely.dev/llms-full.txt (comprehensive type-safe SQL query builder docs)

```typescript
// ✅ CORRECT - Use camelCase (plugin converts to snake_case)
db.selectFrom('timelineSnapshots').where('userId', '=', id)

// ✗ WRONG - Don't use snake_case
db.selectFrom('timeline_snapshots').where('user_id', '=', id)
```

**Field Naming:** Always use camelCase in TypeScript/JavaScript code. Database uses snake_case, Kysely's CamelCasePlugin handles conversion automatically.

**Relationship Tracking (follow graph):** We track follows using directional edges and snapshots:

- `follow_edges`: current, directional edges per tenant and observer (inbound/outbound) with `is_active`.
- `follow_snapshots` + `follow_snapshot_members`: normalized list snapshots (followers/following) used to diff edges.
- `follow_events`: append-only audit of started/ended edge transitions (idempotent per snapshot/run).
- `mutuals_current` (VIEW): live mutuals derived from active inbound+outbound edges; zero staleness.

Writes happen via snapshot writers: insert a snapshot, then call the diff helper to upsert ON edges and (for completed snapshots) inactivate OFF edges. Do not write per-row "relationship masks".

**Type Preference:** Use direct Kysely types instead of wrapper types for better clarity:

```typescript
// ✅ PREFERRED - Clear and explicit
tweets: Array<Omit<Insertable<DB['tweets']>, 'updatedAt'>>

// ✗ AVOID - Indirection through wrapper types
tweets: Array<NewTweet>
```

Wrapper types like `NewTweet` or `NewDBTweet` hide what table you're working with and add unnecessary abstraction.

**Query Preference:** Use Kysely's query builder for all database operations unless raw SQL provides significant performance benefits. Examples where raw SQL is appropriate:

- Bulk operations with UNNEST (PostgreSQL-specific)
- Complex window functions
- Geospatial operations with PostGIS (ST_\*, GIST/BRIN)
- Full-text search with ts_rank

---

## 🐦 Tweet Storage (Unified Helpers)

**Canonical helpers:**

- `batchUpsertTweets(rows, dbh?)`: Accepts `Insertable<DB['tweets']>[]` only. Conflict logic preserves existing values when a field is omitted and updates when provided; `updatedAt` bumps only when data actually changes (IS DISTINCT FROM guard).
- `upsertTweetsFromBoundary(tweets, includes?, dbh?)`: Accepts validated camelCase `TwitterApiTweet[]`. Transforms via `TransformTwitterApiTweetForDb(...)` and delegates to `batchUpsertTweets(...)`. If `includes.media` is provided (array or Map keyed by `media_key`), performs a single UNNEST update to set `media` and `mediaMetadata`.

**No legacy adapter:**

- All callers must parse unknown → boundary and use `upsertTweetsFromBoundary(...)`. This ensures a single write path and avoids format drift.

**Enforcement:**

- Do not write `insertInto('tweets')` or chain `.onConflict()` outside `src/lib/db/**` (AST-grep rules: `no-tweets-upsert-outside-db`, `no-tweets-onConflict-outside-db`).
- Avoid "handle both" patterns; always transform once at the boundary.

**Metrics:**

- `likeCount`, `retweetCount`, `replyCount`, `quoteCount`, `bookmarkCount`, `impressionCount` supported end-to-end. Conflict logic preserves DB values when inputs omit metrics.

**Media:**

- Prefer `includes.media` for enrichment. The boundary helper handles bulk UNNEST updates for performance.

### Persistence Do's and Don'ts

- Do not convert boundary tweets back to `TweetV2` for persistence. Keep V2 strictly for external API calls and tests. Persist via:
  - `upsertTweetsFromBoundary(boundaryTweets, { media }) → TransformTwitterApiTweetForDb → BatchUpsertTweets`
- Media enrichment is centralized:
  - Use `BuildMediaUpdateArrays(tweets: TwitterApiTweet[], mediaByKey: Map<...>)` for UNNEST arrays
  - Prefer boundary-first helper `buildTweetUpdateArraysFromBoundary(...)` over raw variants
- DB helper signature convention (apply across `src/lib/db/**`):
  - Last argument is always `dbh?: Kysely<DB> | Transaction<DB>` (accept either a pool or a transaction)

---

## ✏️ Testing

**Framework:** This project uses **Vitest** for all testing.

### Agent Policy: No Watch/Interactive Modes

- Automation must not use watch/interactive flags; they hang indefinitely.
- Use run-once commands only; prefer `pnpm -s test` for units.

**Forbidden (hangs):**

```bash
pnpm test -w
pnpm -s test -w
pnpm test --watch
pnpm vitest         # no args
pnpm vitest -w
pnpm vitest --watch
pnpm playwright test --ui
```

**Allowed (run once):**

```bash
pnpm -s test
pnpm vitest run
pnpm test:unit
pnpm test:integration
pnpm test:all
pnpm test:ci
```

For CI output tuning, use reporters, e.g. `pnpm vitest run --reporter=dot`.

---

## 🌿 AST-Grep (Structural Search & Codemods)

**What it is:**

Structural code search, lint, and codemods using tree-sitter AST. Complements Biome (format + curated JS/TS lint) with custom, pattern-driven rules and safe rewrites.

**Why we use it:**

- Enforce core policies: no `as unknown as`, no `as any`, no direct `process.env` outside the T3 env boundary, no direct `new TwitterApi(...)`.
- Fast, repo-wide AST queries and targeted refactors during migrations.

**Quick commands:**

```bash
# Search
sg run -p 'process.env.$NAME' -C 2 src

# Rewrite (preview)
sg run -p 'process.env.$NAME' -r 'env.$NAME' --interactive src

# Scan with rules
pnpm run lint:ast-grep          # all
pnpm run lint:ast-grep:strict   # low-noise
```

**How To Use (Concise Guide)**

- Preview first: `sg run -p '<pattern>' -C 1 src` (never write on first pass).
- Refactor safely: add a replacement and `--interactive` to confirm each hunk: `sg run -p '<pattern>' -r '<replacement>' --interactive src`.
- Scope precisely: add globs to include/exclude: `--globs 'src/lib/**' --globs '!src/env.ts'`.
- Constrain matches: use meta vars + constraints, e.g. `--constraint NAME '/_/'` for snake_case.
- Validate: run `pnpm run lint:ast-grep:strict` and `pnpm -s test` after changes.

### Common Recipes (copy/paste)

**Env boundary (process.env → env):**

```bash
# Preview
sg run -p 'process.env.$NAME' -C 1 src --globs '!src/env.ts'

# Rewrite
sg run -p 'process.env.$NAME' -r 'env.$NAME' --interactive src --globs '!src/env.ts'
```

**Block direct Twitter API (migrate to service):**

```bash
# Rewrite (guided)
sg run -p 'new TwitterApi($ARGS)' -r '/* use TwitterService.forCurrentUser()/forUser() */' --interactive src
```

**Kysely snake_case tables → camelCase:**

```bash
# Find
sg run -p 'db.$CALL($NAME$)' --constraint CALL '/^(selectFrom|insertInto|updateTable|deleteFrom)$/' --constraint NAME '/_/' -C 1 src
# Fix interactively (supply correct camelCase names per match).
```

**Kysely snake_case columns → camelCase:**

```bash
# Find
sg run -p 'db.$CALL($FIELD', $OP, $VAL)' --constraint CALL '/^(where|orWhere|orderBy|select)$/' --constraint FIELD '/_/' -C 1 src
```

**Anti-casting cleanup:**

- Action: replace by adding a transformer in `src/lib/validation/transformers.ts` and proper types/guards.

**Pre-commit integration:**

- Husky runs a strict subset on staged TS/TSX files only (fast).
- Rules: `no-double-cast-unknown`, `no-direct-twitterapi`, `no-process-env-outside-env`
- Excludes `src/env.ts` (boundary file may read `process.env`)

**Tips:**

- Use meta variables (`$EXPR`, `$NAME`, `$TYPE`) for flexible matching.
- Add constraints with `inside`, `has`, `precedes` in rule YAML for precision.
- Use `--selector` to narrow match to a node kind when needed.

---

## Profile Upserts (Single Source of Truth)

- Use `batchUpsertProfiles()` for all profiles writes (DB-shaped inputs). For follow edges, call `upsertProfilesWithRelationships()` (it delegates to `batchUpsertProfiles()` for the write).
- Never write ad-hoc `.insertInto('profiles')` or `.onConflict()` outside `src/lib/db/**` — AST-grep enforces this in pre-commit.
- Metrics: only update when provided; if omitted, existing DB values are preserved (via conflict guards). Do not default with `|| 0` in DB writes.

**Examples:**

- Boundary users → transform → `batchUpsertProfiles([row])`
- With relationship context → `upsertProfilesWithRelationships(userId, observerProfileId, twitterApiUsers)`

---

## Tweet Upserts (Single Source of Truth)

- Use `batchUpsertTweets()` for DB-shaped rows. If you have boundary tweets, use `upsertTweetsFromBoundary()` (transforms and delegates).
- Boundary-first flow: Twitter API → boundary (camelCase, Date types) → DB rows → `batchUpsertTweets()`.
- Do not convert back to `TweetV2` for DB writes; keep V2 only in read utilities if necessary.

**Examples:**

- Boundary tweets → `upsertTweetsFromBoundary(boundaryTweets, { media })`
- DB rows → `batchUpsertTweets(rows)`

Pattern references: see AST-grep "Common recipes" above for search and rewrite commands.

---

## ■ Command Behaviors

### /check Command

1. Auto-fix linting: `pnpm biome check --write .`
2. Type check: `pnpm type-check`
3. Run tests: `pnpm test`
4. Fix all issues and re-run until everything passes

### /commit Command

1. Run `git status` to see changes
2. Stage ONLY files YOU modified in this conversation
3. Create descriptive commit message
4. NEVER use `git add .` or `git add -A`

---

## 🛡 Critical Rules

### Code Organization & Contributions

- **Active Contributors:** We must maintain an active contributor ecosystem.
- **File Length:** We must keep all files under 800 lines of code (LOC). Files must be modular and single-purpose.
- **Reading Files:** Always read the file in full, do not be lazy. Before making any code changes, start by finding and reading ALL of the relevant files. Never make changes without reading the entire file.
- **EGO:** Do not make assumptions. Do not jump to conclusions. You are just a Large Language Model, you are very limited. Always consider multiple different approaches, just like a Senior Engineer would.

### Refactoring Philosophy

- **No backwards compatibility** – refactor aggressively
- **No version suffixes** – update files directly (`timeline.ts` not `timeline-v2.ts`)
- **No legacy files** – delete old implementations completely

### Git Workflow

🚨 **CRITICAL - NEVER USE `git add -A` or `git add .`**

- **ABSOLUTELY FORBIDDEN:** Never stage all files at once
- **ONLY** stage files YOU explicitly modified in this conversation
- **ALWAYS** use specific file paths: `git add path/to/specific/file.ts`
- **CHECK** with `git status` before staging anything
- Other developers may have uncommitted work – DO NOT touch their files

### Git Worktrees

```bash
# Create worktree with automatic environment setup
bun scripts/setup-worktrees.js feature-name
```

Creates worktree in `.work/<branch-name>` with env files copied

---

## Twitter API

- Always use `TwitterService.forCurrentUser()` or `TwitterService.forUser()`
- Never instantiate TwitterApi directly

**Twitter App IDs:**

- **Development:** Client ID 31299634 (base64: `ekx8NTdBRFUwOGM4clpZQk5hQVMAMTpjaQ`)
- **Production:** Client ID 18238588 (base64: `enT3MUlFNmNTdV9CcoUVzUldpQnE6MTpjaQ`)

---

## OpenAI

- Use GPT-5 only – GPT-4 and GPT-3.5 are deprecated
- Available models: gpt-5, gpt-5-mini, gpt-5-nano (released August 7, 2025)
- Use `openai.responses.create()` NOT `chat.completions.create()`
- **NOTE:** These GPT-5 models are fully implemented and available in the codebase. Use them as: `openai/gpt-5`, `openai/gpt-5-mini`, `openai/gpt-5-nano`

---

## 🌿 Environment Variables Management

**Type-Safe Environment Variables with T3 Env + Zod**

This project uses `@t3-oss/env-nextjs` for runtime validation and type-safe environment variable management.

### How It Works

All environment variables are defined and validated in `src/env.ts:6-147` with Zod schemas:

```typescript
import { env } from '@/env';

// ✅ Type-safe access with runtime validation
const dbUrl = env.DATABASE_URL;       // Server-side only
const appUrl = env.NEXT_PUBLIC_APP_URL; // Client-side accessible
```

### Adding New Environment Variables

1. Add to `.env` file:

```
NEW_API_KEY=your_value_here
```

2. Define in schema (`src/env.ts`):

```typescript
server: {
  NEW_API_KEY: noNewlines(z.string().min(1)),
}
```

3. Map to runtime (`src/env.ts`):

```typescript
runtimeEnv: {
  NEW_API_KEY: process.env.NEW_API_KEY,
}
```

**Key Benefits:**

- **Build-time validation:** Invalid/missing env vars fail the build
- **Type safety:** Full TypeScript support with autocomplete
- **No runtime errors:** Guaranteed valid configuration
- **Client/server separation:** Prevents accidental server var exposure
- **Custom validation:** Email formats, URL validation, string lengths, etc.

### Environment Switching

```bash
pnpm env:dev    # Switch to local development
pnpm env:prod   # Switch to production-like
pnpm env:status # Check current environment
```

Environment files are automatically managed – never manually edit `.env` directly.

This modern approach eliminates the common `process.env.VARIABLE_NAME` pattern and the associated runtime errors from undefined or malformed environment variables.

---

## 🔺 Zod Validation Architecture with Codecs

**Full documentation:** `docs/api-schema.md`

### Core Principle: Transform Once at the Boundary with Codecs

```
External APIs (snake_case, ISO strings) → | BOUNDARY CODEC | → App (camelCase, Date objects) → Kysely → DB (snake_case)
```

### Key Rules

1. **Codec Transformation:** All external data gets validated AND transformed using Zod codecs at entry
2. **Single Internal Format:** App uses `camelCase` + proper types (Date, number, etc.) – no unions or format checking
3. **Standard Codecs:** Use Zod's built-in codec patterns (`IsoDateTimeToDate`, `stringToNumber`, etc.)
4. **Kysely Handles DB:** CamelCasePlugin auto-converts `camelCase` ↔ `snake_case`

### Directory Structure

```
src/lib/validation/
├── codecs.ts      # Standard Zod codecs (Date, JSON, URL, etc.)
├── boundaries/    # External validators with codec transformations
├── core/          # Internal schemas (camelCase + proper types)
├── database/      # DB schemas (extends core)
└── api/           # Request/response schemas with codecs
```

### Correct Pattern with Codecs

```typescript
// ✅ Transform at boundary using codecs
const TweetResponseSchema = z.object({
  createdAt: IsoDateCodec,  // ISO string → Date object
  authorId: z.string(),
});
const tweet = TweetResponseSchema.decode(rawApiData); // Automatic transformation
await processTweet(tweet); // Uses Date objects

// ✗ Never do this
const authorId = tweet.author_id || tweet.authorId;  // No format checking!
const date = new Date(tweet.createdAt);               // No manual conversion!
```

### Migration Goal

- Eliminate all `as any` and `as unknown as` casts
- Remove all union schemas for format variations
- Single source of truth per data type

---

## 🔧 Tech Stack

- **Frontend:** Next.js 15 Canary, React 19 Canary, TypeScript 5, Tailwind CSS v4
- **Database:** Neon PostgreSQL with Kysely ORM
- **AI:** OpenAI GPT-5, text-embedding-3-small
- **Auth:** Better Auth with Twitter OAuth 2.0
- **Background:** Inngest for jobs

---

## 🔺 Next.js Canary Requirement

**CRITICAL:** This project uses Next.js canary for Partial Pre-Rendering (PPR) support.

### Why Canary?

- **PPR (Partial Pre-Rendering):** Experimental feature requiring latest canary builds
- **Performance:** Significant rendering optimizations for our analytics dashboard
- **React 19:** Full support for latest React features

**Rules:**

- NEVER downgrade Next.js from canary to stable
- NEVER disable PPR – upgrade Next.js instead
- ALWAYS use `pnpm add next@canary react@canary react-dom@canary` for updates
- Monitor breaking changes in canary releases

Note on versioning (keep us on canary):

- Set `"next": "canary"` in `package.json` to avoid semver drifting to stable (e.g. 15.5.x > 15.5.x-canary by semver).
- Pin React canary as well (`react`, `react-dom`) via direct deps or `pnpm.overrides` to keep versions aligned.

If PPR errors occur, the fix is **ALWAYS** to upgrade Next.js canary, not disable the feature.

---

## 🐞 Debugging

### Better Stack Logging

Use the bslog CLI for quick queries and tails:

```bash
bslog tail -n 50                               # Recent logs
bslog errors --since 1h                        # Recent errors
bslog search "module:timeline" --limit 50
```

Dashboard: https://logtail.com/ Requires: `NEXT_PUBLIC_LOGTAIL_SOURCE_TOKEN`

### bslog – Better Stack Log Query CLI

**Quick setup:**

```bash
# Environment variables are in ~/.zshrc
# If authentication fails, reload with: source ~/.zshrc

# Set default source
bslog config source sweetistics-dev

# Common queries
bslog tail -n 20
bslog errors --since 1h                          # Recent errors
bslog search "authentication" --limit 10         # Search logs
bslog query "{ logs(level: 'error') { dt, message } }"  # GraphQL-style
```

**Sources available:**

- `sweetistics-dev` – Development logs
- `sweetistics` – Vercel integration
- `sweetistics-neon` – Database logs
- `sweetistics-prod` – Production logs

---

## Important Notes

- Inngest for jobs: https://www.inngest.com/llms.txt
- X API Rate Limits: https://docs.x.com/x-api/fundamentals/rate-limits
- Vercel Pro: Functions can run up to 800 seconds (13 minutes)
- Test files in `src/__tests__/`
- Shadcn/ui components in `/src/components/ui/`
- Schema source of truth: `/db/schema.sql`

---

## JSONB Queries with Kysely

When querying JSONB fields with Kysely, use `sql.literal()` for proper escaping:

```typescript
// ✅ CORRECT - Use sql.literal() for JSONB containment
.where(sql`options::jsonb @> ${sql.literal(JSON.stringify({ timeRange }))}::jsonb`)

// ✗ WRONG - Direct template interpolation doesn't escape properly
.where(sql<boolean>`options @> ${JSON.stringify({ timeRange })}::jsonb`)

// ✅ BETTER - Use helper function from db-helpers.ts
import { jsonbContains } from '@/lib/db-helpers';
.where(jsonbContains('options', { timeRange: '4h' }))
```

### JSONB Storage with Kysely

**CRITICAL:** PostgreSQL JSONB columns automatically handle JSON serialization/deserialization.

```typescript
// ✅ CORRECT - Direct object assignment for JSONB columns
await db.updateTable('systemAiConfig').set({
  enabledModels: enabledModels as any,  // Pass array/object directly
  modelConfigs: modelConfigs || {},
}).execute()

// ✗ WRONG - Don't stringify when storing to JSONB
await db.updateTable('systemAiConfig').set({
  enabledModels: JSON.stringify(enabledModels),  // Double-stringified!
}).execute()
```

### Query Helpers

Use helper functions in `src/lib/db-helpers.ts` for common patterns (based on Kysely relations patterns)

---

## ■ Linear CLI Usage

### Essential Commands

```bash
# List issues (defaults to assigned to you only)
linear issue list --sort priority
linear issue list --all-assignees --sort priority   # Show all
linear issue list --unassigned --sort priority      # Unassigned only

# Create & manage issues
linear issue create --title "Title" --description "Description"
linear issue view SWT-123                           # Must specify issue ID
linear issue update SWT-123 --state started         # States: triage, backlog, unstarted, started, completed, canceled
linear issue update SWT-123 --assignee username

# Open in browser/app
linear issue list --web                             # Open in browser
linear issue view SWT-123 --app                     # Open in Linear app
```

**Tips:**

- Default list shows only YOUR assigned issues – use `--all-assignees` to see all
- Add `--no-pager` to disable pagination
- States: `triage`, `backlog`, `unstarted`, `started`, `completed`, `canceled`
- `linear issue view` requires an issue ID (e.g., SWT-123) – won't auto-detect from git branch

---

## API Testing

### X/Twitter API Testing with xl CLI

```bash
# Local CLI that uses app's auth to avoid token conflicts
./xl /2/users/me                                            # Get authenticated user
./xl /2/users/by/username/vercel\                           # Get user by username
./xl /2/tweets/search/recent -q "query-from:vercel\"        # Search tweets
./xl /2/users/me -c                                         # Generate curl command
./xl /2/users/me -t "token"                                 # Use specific token
```

The xl CLI automatically fetches tokens from the local database, avoiding OAuth conflicts when testing. See `scripts/xl-README.md` for details.

---

## Atlas Database Schema Management

Quick start: start the PostGIS planning DB with `pnpm atlas:dev-db` (runs on 127.0.0.1:5435), then apply schema with `pnpm -s schema:apply`. For prod, set `DIRECT_DATABASE_URL` (with `sslmode=require`) and run `pnpm -s schema:apply:prod`.

Note: the production DB URL lives in `.env.prod-like` as `DIRECT_DATABASE_URL`. Use `pnpm env:prod` to switch `.env` to that template before running prod applies.

Atlas is a language-independent tool for managing and migrating database schemas using modern DevOps principles.

### Quick Reference

```bash
# Common Atlas commands
atlas schema inspect --env <name> --url file://migrations
atlas migrate status --env <name>
atlas migrate diff --env <name>
atlas migrate lint --env <name> --latest 1
atlas migrate apply --env <name>
atlas whoami
```
