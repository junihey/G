# The "Loop Contract" in AI Jason's Loop Engineer Video — Verification & a Blueprint for Your Claude Code Skill

## TL;DR
- The video is by **Jason Zhou ("AI Jason")**, uploaded June 18, 2026; per his own companion write-up, a **Loop Contract is one README.md per loop that states five things: ==Goal, Workflow, Boundaries, (outstanding) Backlog, and a Timeline==** — the loop reads it before every run and then "takes the next best action."
- Your German notes are **mostly correct but partly mislabeled**: GOAL ✓, Workflow ✓, Timeline ✓ are verbatim; your "==Task for next loop iteration" is really the **Backlog** field; your "Rules" is closest to the source's **Boundaries** field==. The field you missed by its real name is **Boundaries**; you effectively renamed Backlog as "next task."
- For your skill, the highest-leverage additions beyond Jason's five fields are a **==machine-checkable Definition of Done (exit condition tied to a command exit code), explicit failure/stop conditions (iteration + budget caps, escalation), and a state/handoff block==** — these are what turn a loose "loop" into a *deterministic* one, and they map cleanly onto your Sandcastle + git-worktree + Obsidian-YAML pipeline.

## Key Findings

### What the video/source actually says (verified)
- **Author & context:** "wtf is Loop Engineer & how to setup for real" is by Jason Zhou (AI Jason), channel @AIJasonZ, published June 18, 2026. The video's alternate title is "Loop Engineer: Systemization and Artifacts." It ships a free GitHub template (`JayZeeDesign/loop-engineer-template`, mirror `AI-Builder-Club/loop-engineer-template`).
- **The four ingredients of a loop:** (1) Triggers, (2) File structure (artifacts, contracts, logs), (3) Tools & connectors, (4) An agent-ready codebase (legible / executable / verifiable).
- **The Loop Contract:** Jason's own AI Builder Club guide (which embeds this exact video) states: *"Contracts – one per loop, usually a README in the loop's folder. It states the goal, the workflow, the boundaries, the outstanding backlog, and a timeline. Every time the loop fires, it reads its contract first – goal, workflow, what happened last time – then takes the next best action."* The FAQ restates it: *"A contract is one README per loop stating its goal, workflow, backlog, and timeline; the loop reads it before every run."*
- **How the contract is created:** the ==template's `/new-loop` skill "scaffolds `domains/<loop>/README.md`, does one real test run, and logs it."== The recommended workflow is *"run the loop manually once as a test, calibrate the workflow with the agent, then ask it to write the contract and register the trigger. Test run first, loop second."*
- ==**`## Timeline` is a literal, append-only heading** used across files in the template ("every file with an append-only `## Timeline`").==
- **Hard rule from the video:** *"don't let an agent self-verify."* Jason's PR skill always spawns a **==separate read-only verifier sub-agent==** with the detailed spec; generator and verifier stay different agents.
- **Note on verbatim schema:** the exact markdown heading text inside the `new-loop` SKILL.md template could not be retrieved (GitHub raw file and API endpoints are blocked to automated fetch). Only `## Timeline` is confirmed as a literal heading. The five field *names* are confirmed from Jason's own prose, not from the raw template file — verify exact capitalization by opening the template yourself.

### Verifying your German notes against the source
| Your note (DE) | Verified field in source | Verdict |
|---|---|---|
| GOAL | Goal | ✅ Correct |
| Workflow | Workflow | ✅ Correct |
| Task for next loop iteration | (outstanding) Backlog | 🟡 Right idea, wrong name — it's a standing backlog; the loop derives the "next best action" from Goal + Workflow + Backlog + Timeline |
| Timeline | Timeline | ✅ Correct (literal `## Timeline`) |
| Rules | Boundaries | 🟡 Closest match is "Boundaries." "Rules" as a distinct field is not in the source; project-wide rules live in CLAUDE.md / custom lints, not the contract |
| — (missing) | **Boundaries** | ❌ You omitted the field by its real name |

So: 3 of your 5 are verbatim-correct; "Task for next loop iteration" is the Backlog; and the field genuinely named in the source that you didn't capture is **Boundaries** (scope limits — what the loop may and may not touch).

### The wider "Loop Engineering" landscape (context)
- The term went viral in June 2026. **Peter Steinberger (@steipete, OpenClaw creator)** posted on June 8, 2026: *"you shouldn't be prompting coding agents anymore. You should be designing loops that prompt your agents"* — a post that hit ~6.5 million views on X. **Boris Cherny (Claude Code creator, Anthropic)** said the same from the vendor side: *"I don't prompt Claude anymore. I have loops running that prompt Claude and figuring out what to do. My job is to write loops."* **Addy Osmani (Google)** codified it in his "Loop Engineering" essay (published ~June 7–8, 2026), giving the practice its anatomy: automations, worktrees, skills, connectors, sub-agents, and external state. **Andrew Ng**, in *The Batch* issue 359 (June 26, 2026), framed three nested loops: agentic coding (minutes), developer feedback (hours), external feedback (days).
- A widely shared five-layer model (Claude Skills Hub / Osmani's anatomy) frames a loop as: **==harness (environment) → loop contract (what "done" means) → state layer (files that survive restarts) → checker (automated verification) → human checkpoint==.** This is the most useful external frame for extending Jason's contract into a robust skill.
- ==Repeated== across every serious source: *"Every contract line must be checkable by a command with an exit code"*; *"'Improve the codebase' cannot halt"*; ==retries *"must carry the error plus the contract, and must be bounded with escalation"==*; and state ==must be *externalized to files* because *"the loop's memory lives in the transcript. First compaction, the loop forgets what it finished."==*

## Details

### A. What a Loop Contract contains — the verified core plus the practical superset
**==Verified core== (from AI Jason, the actual source):**
1. **Goal** — the outcome the loop pursues.
2. **Workflow** — the repeatable steps the loop runs each iteration.
3. **Boundaries** — scope limits / what it may not touch.
4. **Backlog** — the outstanding work queue it draws the next action from.
5. **Timeline** — append-only log of what happened each run (`## Timeline`).

**Recommended superset for a *deterministic* loop (best-practice synthesis, not in Jason's five-field list):** Jason's contract is optimized for open-ended, compounding *business* loops (support / SEO / product). Because you want reproducible, well-scoped *==coding* loops, add==:
6. **Definition of Done / Success criteria** — expressed as machine-checkable ==commands with exit codes (e.g., "`pnpm test` exits 0 AND `pnpm lint` exits 0 AND endpoint returns 200")==. This is the single most important field for determinism.
7. **Failure / Stop conditions** — hard iteration cap, token/time budget, and "same error twice → escalate, don't retry."
8. **Escalation / Handoff** — what to write and to whom when the loop stops or blocks.
9. **State / handoff pointer** — where durable state lives (your Obsidian note + YAML frontmatter), read at start and written at end.
10. **Allowed tools / permissions** — which commands, MCPs, paths, and worktree/branch the loop may use.
11. **Context / inputs** — the exact files, specs, and prior artifacts to load (keep this tight — it's the determinism lever).
12. **Contract version** — a version/hash so contract changes are trackable across iterations.

### B. What to watch out for when building the skill (Worauf muss geachtet werden)

**1. Determinism & reproducibility.** LLM loops are inherently non-deterministic; you cannot make the *model* deterministic, so ==make the *inputs and the exit test* deterministic==. Concretely: pin the model version in the contract; pin the exact context files (don't let the agent freely decide what to read — "the agent decides what to read is the line that quietly kills reproducibility"); express Done as a command that returns a pass/fail exit code; and run the verification in a **fresh context / separate sub-agent**, never self-verification.

**2. Tight scoping / anti-scope-creep.** One bounded unit of work per iteration ("fix the next failing test," not "improve the module"). Encode Boundaries as denylists and, where possible, as custom lints so violations fail mechanically rather than relying on the agent reading a doc. Keep primary context under ~100k tokens; use sub-agents for large reads.

**3. Definition of Done.** Every acceptance criterion must be observable by a command. ==If a criterion can only be judged by a human ("the code is clean"), it belongs at a human review gate==, not in the loop's automated exit logic. Pin the passes up front, before writing loop logic.

**4. Stop / exit conditions (five canonical exits).** ==goal achieved · max iterations reached · budget exhausted · no-progress detected · escalation to human==. A loop with no stop condition is "a billing incident." Treat hitting a cap as stop-and-escalate, not "try harder."

**5. State handoff between iterations.** Externalize state to disk (your Obsidian vault). A good ==handoff has layered content: raw facts (active/completed/blocked tasks, env), plus a narrative of "what I was thinking / why."== Use YAML frontmatter as the typed, greppable state header; the note body as the narrative; `## Timeline` as the append-only ledger. ==Start each iteration with fresh context that reads this note first==.

**6. Versioning / tracking contract changes.** Because the contract is a README.md in git, every edit is already diffable. ==Add a `contract_version` (or content hash) to the YAML frontmatter, and require the loop to append a `## Timeline` entry whenever the contract itself changes==, so you can correlate behavior shifts with contract edits.

### C. Integration with your specific pipeline
- **Claude Code CLI skill mechanics:** A skill is a folder with `SKILL.md` (YAML frontmatter `name` + `description`, then markdown body). The **description is the single most important line** — Claude only sees name+description at startup (progressive disclosure) and decides whether to fire the skill from it; use concrete trigger phrases ("set up a loop contract", "kick off a deterministic loop"). Keep the body under ~300–500 lines; ==move the contract *template* into a `templates/loop-contract.md` file (a file Claude **copies**, distinct from `references/` files it only reads)==. Use `disable-model-invocation: true` if you want the contract-generator to run only when you explicitly call it. ==Use `allowed-tools` to pre-authorize the git/worktree/write commands so it doesn't stall on permission prompts==.
- **Git worktrees:** each loop iteration/agent gets its own worktree + branch so parallel loops never collide (==Sandcastle's `branch` / `merge-to-head` strategies==). ==Put the branch name and worktree path in the contract's Allowed-tools/State block. Worktrees convert silent runtime file corruption into visible merge-time conflicts==.
- **Sandcastle (`@ai-hero/sandcastle`):** it already runs a bounded loop (`run({ maxIterations })`), does prompt expansion (`!` `` `command` `` and `{{KEY}}` substitution) *inside* the sandbox at each iteration, captures session JSONL for `--resume`, and supports `merge-to-head` for safe unattended runs. ==Your skill should generate the contract README *and* the matching `.sandcastle/prompt.md` that points the agent at the contract, so the two stay in sync.== Note the known macOS `resumeSession` path-encoding bug (issue #695) if you rely on cross-turn resume.
- **Obsidian + YAML ==frontmatter as state store==:** keep frontmatter minimal and typed (==status, current-iteration, next-task, contract_version, done-criteria, budget-remaining, blocked-reason==). Avoid nested YAML (Obsidian Properties don't support it well). ==Add a `description` field per note for progressive-disclosure discovery==. Remember flat markdown doesn't scale to huge state — ==keep the state note small and greppable; put bulk artifacts in separate files referenced by path.==
- **Merge queue for parallel agents:** keep the human/CI gate on merge; each finished loop opens a PR that a fresh verifier sub-agent (and CI) must pass before the ==queue merges==. ==Avoid dependency/lockfile changes in parallel loops== (they conflict at merge).

## Recommendations
**Stage 1 — Ship a minimal contract-generator skill.** Create `.claude/skills/new-loop-contract/` with a `SKILL.md` (sharp description + trigger phrases) and a `templates/loop-contract.md`. Have the skill interview you for name/goal, then write `domains/<loop>/README.md` with all 12 sections above, plus a YAML frontmatter state header. Mirror Jason's own flow: **do one real manual test run first, then let the skill write the contract.** Benchmark to advance: the generated contract's Done section is 100% commands-with-exit-codes (no prose-only criteria).

**Stage 2 — Wire determinism + verification.** Make the skill also emit the `.sandcastle/prompt.md` referencing the contract, pin the model + exact context files, and require a separate verifier sub-agent. Add iteration cap + token/time budget + no-progress detection to the contract. Benchmark to advance: a loop run twice on the same contract + same repo state converges to the same pass/fail verdict.

**Stage 3 — State, versioning, escalation, scale.** Add the Obsidian-YAML state handoff (read-at-start/write-at-end), `contract_version`, append-only `## Timeline`, and an escalation block. Only then enable parallel worktree loops behind your merge queue. Benchmark to advance: intervention rate (human touches per merged change) trends down over a week of runs.

**Thresholds that should change your plan:** if token spend per merged change rises without quality gains → tighten scope / lower iteration cap. If the same loop escalates repeatedly on the same class of problem → graduate that check into a versioned eval ("eval engineering"). If merge conflicts spike → reduce parallelism (most teams find 3–5 parallel agents the ceiling before the codebase can't absorb parallel changes).

## Caveats
- **The five-field contract list is sourced from AI Jason's own written companion guide (which embeds the video), not from a verbatim transcript or the raw template file.** The exact markdown heading text in the `new-loop` SKILL.md could not be retrieved (GitHub raw/API blocked); only `## Timeline` is confirmed as a literal heading. Treat "Goal / Workflow / Boundaries / Backlog / Timeline" as the authoritative field *names* but verify exact capitalization by opening the template yourself.
- **Jason's contract is designed for open-ended, compounding business loops** (support, SEO, product). Your goal — deterministic, reproducible coding loops — is the more constrained ("closed loop") case, so the superset fields (Done-as-command, stop conditions, state handoff) are essential additions, not optional.
- **"Loop engineering" is a hyped, ~3-week-old term** as of the video. Skeptics have real points: The Register (June 24, 2026, "Loop engineering, latest AI buzzword, still needs humans in the loop") argued the mechanics are an old control loop and that real runs still need human steering; Ed Zitron called the trend *"celebrating and evangelizing autonomous token consumption"* and noted (of Cherny) *"Pretty convenient for a guy who's allowed to burn upwards of $130,000 a month in tokens by Anthropic."* Cost evidence is concrete: per PostHog's roundup, Uber reportedly capped engineers at $1,500/month for agent tooling after burning through its annual AI budget in four months. The durable, non-hype core — a checkable Definition of Done, bounded retries, and a human gate before irreversible actions — is exactly what your skill should encode.
- Determinism here means **reproducible inputs and a deterministic exit test**, not a deterministic model. Byte-identical LLM output across runs is not achievable; convergent pass/fail verdicts are.

---

### Kurzfassung auf Deutsch (für die direkte Verwendung)
**Was das Video / die Quelle wirklich sagt:** Ein *Loop Contract* ist **eine README.md pro Loop** und enthält fünf Felder — **Goal, Workflow, Boundaries, (offener) Backlog und Timeline**. Der Loop liest den Contract vor *jedem* Durchlauf und wählt dann "die nächste beste Aktion". Ersteller: **Jason Zhou (AI Jason)**, Video vom 18.06.2026; Begleit-Template: `JayZeeDesign/loop-engineer-template`.

**Prüfung deiner Notizen:** GOAL ✓, Workflow ✓, Timeline ✓ (wörtlich korrekt). "Task for next loop iteration" = eigentlich das **Backlog**-Feld. "Rules" ≈ das Feld **Boundaries** (der tatsächliche Begriff der Quelle; feste Projektregeln gehören in CLAUDE.md / Lints, nicht in den Contract). **Fehlend:** das Feld **Boundaries** unter seinem echten Namen.

**Worauf beim Skill zu achten ist (deterministische Loops):** Ergänze über Jasons fünf Felder hinaus: **(6) Definition of Done als maschinen-prüfbares Kommando mit Exit-Code**, **(7) Stop-/Fehlerbedingungen** (Iterations-Cap, Token-/Zeit-Budget, "gleicher Fehler zweimal → eskalieren"), **(8) Eskalation/Handoff**, **(9) State-Pointer** (Obsidian-Notiz + YAML-Frontmatter, am Anfang lesen / am Ende schreiben), **(10) erlaubte Tools/Permissions**, **(11) fixierter Kontext/Inputs**, **(12) Contract-Version/Hash**. Kernregeln: Modellversion pinnen, Kontext-Dateien fixieren, **nie Selbst-Verifikation** (separater Verifier-Sub-Agent in frischem Kontext), enge Scope-Grenzen (ein abgegrenzter Arbeitsschritt pro Iteration), und immer eine der fünf Exit-Bedingungen (Ziel erreicht · max. Iterationen · Budget erschöpft · kein Fortschritt · Eskalation an Mensch).