# Ablaufplan: API-getriebenes Monorepo mit Docker-Sub-Agents und zentralem Orchestrator

Dieser Plan baut ein produktionsfähiges, aber minimales System: ein Orchestrator verwaltet Bug-Reports/Tasks, spawnt Sub-Agenten in isolierten Docker-Containern, kommuniziert ausschließlich über API (keine geteilten Dateisysteme), erzwingt Pull-Request-Flow mit Merge-Queue und nutzt intelligenten Sparse-Checkout statt vollständiger Repo-Klone.

---

## 0. Architekturüberblick

```
                         ┌─────────────────────┐
   GitHub Webhooks  ───► │                     │ ◄─── Discord/Slack (Status)
   (Issues, PR merged,   │      ORCHESTRATOR    │
    CI-Ergebnisse)       │  (zentraler Service) │
                         │                     │
                         │  - Task-Queue        │
                         │  - Agent-Registry    │
                         │  - Merge-Queue        │
                         │  - Checkout-Resolver  │
                         └─────────┬───────────┘
                                   │ REST/WebSocket API
                                   │ (spawnen, Status, Dateien)
              ┌────────────────────┼────────────────────┐
              ▼                    ▼                    ▼
      ┌───────────────┐   ┌───────────────┐    ┌───────────────┐
      │ Docker-Container│   │ Docker-Container│    │ Docker-Container│
      │  Sub-Agent #1   │   │  Sub-Agent #2   │    │  Sub-Agent #3   │
      │  (sparse repo)  │   │  (sparse repo)  │    │  (sparse repo)  │
      └───────────────┘   └───────────────┘    └───────────────┘
```

Kernprinzip: Der Orchestrator codet nicht selbst. Er nimmt Tasks an, entscheidet über Zuweisung, spawnt/überwacht Container, erzwingt den PR-Flow und räumt danach auf. Sub-Agenten sehen nur ihren zugewiesenen Ausschnitt des Repos und reden nur mit dem Orchestrator, nie direkt miteinander.

---

## Phase 1: Monorepo-Fundament

### 1.1 Workspace-Tooling

Voraussetzung für Dependency-Graph und Sparse-Checkout ist ein Monorepo-Tool, das Paketgrenzen kennt:

```bash
# pnpm Workspaces als Basis
pnpm init
cat > pnpm-workspace.yaml <<'EOF'
packages:
  - "packages/*"
  - "shared/*"
EOF

# Nx für Dependency-Graph (alternativ: Turborepo)
pnpm add -D nx @nx/js
npx nx init
```

`nx graph --file=graph.json` liefert danach eine maschinenlesbare Abhängigkeitsstruktur – das ist die Grundlage für Schritt 4.

### 1.2 CODEOWNERS anlegen

```
# .github/CODEOWNERS
packages/auth/**       @team-auth
packages/billing/**    @team-billing
shared/types/**        @team-platform
```

### 1.3 Dependency-Graph validieren

```bash
npx nx graph --file=tmp/graph.json
cat tmp/graph.json | jq '.graph.dependencies["auth"]'
```

Output zeigt z. B. `["shared-types"]` – genau diese Liste braucht der Checkout-Resolver später.

---

## Phase 2: Orchestrator – Grundgerüst

### 2.1 Tech-Stack (konkret)

- **Runtime:** Node.js + TypeScript
- **API:** Fastify (schnell, schema-validiert)
- **Docker-Steuerung:** `dockerode`
- **GitHub-Integration:** `octokit` (App-Auth, nicht PAT)
- **State:** SQLite via `better-sqlite3` (für MVP; austauschbar gegen Postgres)
- **Queue:** zunächst In-Memory + SQLite-Persistenz; bei Bedarf später BullMQ/Redis

```bash
mkdir orchestrator && cd orchestrator
pnpm init
pnpm add fastify dockerode octokit better-sqlite3 zod
pnpm add -D typescript @types/node tsx
npx tsc --init
```

### 2.2 Datenmodell

```sql
-- schema.sql
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  source TEXT NOT NULL,           -- 'github_issue' | 'manual'
  repo TEXT NOT NULL,
  issue_number INTEGER,
  title TEXT NOT NULL,
  status TEXT NOT NULL,           -- triage|claimed|running|pr_open|merging|done|needs_owner|failed
  required_paths TEXT,            -- JSON-Array, vom Checkout-Resolver befüllt
  assigned_container_id TEXT,
  branch TEXT,
  pr_number INTEGER,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE agent_reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id TEXT NOT NULL,
  kind TEXT NOT NULL,             -- 'status'|'test_result'|'log'|'review_request'
  payload TEXT NOT NULL,          -- JSON
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (task_id) REFERENCES tasks(id)
);

CREATE TABLE merge_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id TEXT NOT NULL,
  pr_number INTEGER NOT NULL,
  position INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'waiting',  -- waiting|rebasing|retesting|ready|merged
  FOREIGN KEY (task_id) REFERENCES tasks(id)
);
```

### 2.3 Projekt-Skeleton

```
orchestrator/
├── src/
│   ├── index.ts              # Fastify-Bootstrap
│   ├── db.ts                 # SQLite-Verbindung + Migrations
│   ├── github/
│   │   ├── webhooks.ts       # issues.opened, pull_request, check_suite
│   │   └── client.ts         # Octokit-App-Auth
│   ├── checkout/
│   │   └── resolver.ts       # Phase 4
│   ├── docker/
│   │   ├── spawn.ts          # Phase 5
│   │   └── lifecycle.ts      # Health/Timeout/Cleanup
│   ├── api/
│   │   ├── agent-routes.ts   # Endpunkte FÜR Sub-Agenten (Phase 6)
│   │   └── admin-routes.ts   # Status/Queue-Einsicht für dich
│   ├── mergequeue/
│   │   └── queue.ts          # Phase 8
│   └── permissions.ts        # Phase 10
└── docker-compose.yml
```

### 2.4 API-Endpunkte (Spezifikation)

| Methode | Pfad | Konsument | Zweck |
|---|---|---|---|
| `POST` | `/webhooks/github` | GitHub | Issue/PR/CI-Events empfangen |
| `POST` | `/agent/:taskId/claim` | Sub-Agent | Task als "in Bearbeitung" markieren |
| `GET`  | `/agent/:taskId/file?path=` | Sub-Agent | Lazy-Loading einer Datei (Phase 6) |
| `POST` | `/agent/:taskId/status` | Sub-Agent | Statusmeldung (z. B. `repro_test_red`) |
| `POST` | `/agent/:taskId/test-result` | Sub-Agent | Testergebnis melden |
| `POST` | `/agent/:taskId/open-pr` | Sub-Agent | PR erstellen (Orchestrator führt aus, Agent fragt nur an) |
| `GET`  | `/admin/queue` | Du | Merge-Queue-Status |
| `GET`  | `/admin/tasks` | Du | Alle Tasks + Status |

---

## Phase 3: GitHub-Integration

### 3.1 GitHub App registrieren

1. GitHub → Settings → Developer settings → GitHub Apps → New
2. Berechtigungen: `Issues: Read`, `Pull requests: Write`, `Contents: Read & Write`, `Checks: Read`
3. Webhook-URL auf deinen Orchestrator zeigen lassen, Events abonnieren: `issues`, `pull_request`, `check_suite`

```typescript
// src/github/client.ts
import { App } from "octokit";

export const githubApp = new App({
  appId: process.env.GITHUB_APP_ID!,
  privateKey: process.env.GITHUB_PRIVATE_KEY!,
  webhooks: { secret: process.env.GITHUB_WEBHOOK_SECRET! },
});
```

### 3.2 Webhook-Handler

```typescript
// src/github/webhooks.ts
import { githubApp } from "./client";
import { createTaskFromIssue } from "../checkout/resolver";
import { onPullRequestMerged } from "../mergequeue/queue";

githubApp.webhooks.on("issues.opened", async ({ payload }) => {
  await createTaskFromIssue({
    repo: payload.repository.full_name,
    issueNumber: payload.issue.number,
    title: payload.issue.title,
    body: payload.issue.body ?? "",
  });
});

githubApp.webhooks.on("pull_request.closed", async ({ payload }) => {
  if (payload.pull_request.merged) {
    await onPullRequestMerged(payload.pull_request.number);
  }
});

githubApp.webhooks.on("check_suite.completed", async ({ payload }) => {
  // an wartende Merge-Queue-Einträge weiterleiten, siehe Phase 8
});
```

### 3.3 Task aus Issue erzeugen

Triage-Logik (autonom lösbar vs. braucht Owner-Entscheidung) gehört hier hin – siehe Phase 10 für die konkrete Permission-Stufung.

---

## Phase 4: Intelligenter Checkout (Sparse-Checkout-Resolver)

### 4.1 Pfade aus CODEOWNERS/Dependency-Graph ableiten

```typescript
// src/checkout/resolver.ts
import { execSync } from "child_process";

export function resolveRequiredPaths(issueBody: string): string[] {
  // 1. Heuristik: welches Package ist betroffen? (z.B. aus Issue-Labels oder Pfad-Erwähnungen)
  const affectedPackage = detectPackageFromIssue(issueBody); // "auth"

  // 2. Dependency-Graph abfragen
  const graph = JSON.parse(execSync(`npx nx graph --file=-`).toString());
  const deps: string[] = graph.graph.dependencies[affectedPackage]?.map(
    (d: any) => d.target
  ) ?? [];

  // 3. Pfade zusammenstellen
  return [
    `packages/${affectedPackage}`,
    ...deps.map((d) => `shared/${d}`),
    "package.json",
    "pnpm-workspace.yaml",
  ];
}
```

### 4.2 Checkout-Skript (läuft im Container-Entrypoint)

```bash
#!/bin/bash
# checkout.sh – wird per ENV REQUIRED_PATHS an den Container übergeben
set -e
git clone --no-checkout --filter=blob:none "$REPO_URL" /workspace
cd /workspace
git sparse-checkout init --cone
git sparse-checkout set $REQUIRED_PATHS
git checkout main
git checkout -b "agent/task-$TASK_ID"
```

### 4.3 Caching-Strategie

Den `--filter=blob:none`-Klon (nur Metadaten, keine Blobs) auf einem gemeinsamen Docker-Volume zwischenspeichern, damit nicht jeder Container die komplette Commit-Historie neu herunterlädt:

```yaml
# docker-compose.yml Auszug
volumes:
  git-cache:
```

```bash
git clone --reference /git-cache/monorepo --no-checkout --filter=blob:none "$REPO_URL" /workspace
```

---

## Phase 5: Docker Sub-Agent Spawning

### 5.1 Sandbox-Image

```dockerfile
# sandbox/Dockerfile
FROM node:22-bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates curl jq python3 ripgrep \
    && rm -rf /var/lib/apt/lists/*
RUN useradd --create-home --shell /bin/bash agent
USER agent
WORKDIR /workspace
COPY --chown=agent checkout.sh /usr/local/bin/checkout.sh
ENTRYPOINT ["/usr/local/bin/checkout.sh"]
```

```bash
docker build -t agent-sandbox:latest sandbox/
```

### 5.2 Spawn-Logik im Orchestrator

```typescript
// src/docker/spawn.ts
import Docker from "dockerode";
const docker = new Docker();

export async function spawnAgentContainer(task: {
  id: string;
  repoUrl: string;
  requiredPaths: string[];
}) {
  const container = await docker.createContainer({
    Image: "agent-sandbox:latest",
    name: `agent-${task.id}`,
    Env: [
      `TASK_ID=${task.id}`,
      `REPO_URL=${task.repoUrl}`,
      `REQUIRED_PATHS=${task.requiredPaths.join(" ")}`,
      `ORCHESTRATOR_URL=http://orchestrator:3000`,
      `ORCHESTRATOR_TOKEN=${generateScopedToken(task.id)}`,
    ],
    HostConfig: {
      NetworkMode: "agent-net",     // kein Zugriff auf Host-Netz
      Memory: 2 * 1024 * 1024 * 1024,
      NanoCpus: 2_000_000_000,      // 2 CPUs
      AutoRemove: false,            // Cleanup macht lifecycle.ts kontrolliert
      Mounts: [
        { Type: "volume", Source: "git-cache", Target: "/git-cache", ReadOnly: true },
      ],
    },
  });
  await container.start();
  return container.id;
}
```

### 5.3 Resource Limits & Netzwerkpolicy

```bash
docker network create --internal agent-net
```
`--internal` verhindert ausgehenden Internetzugriff komplett. Falls der Agent `npm install` o. ä. braucht: separates Netz mit Egress-Proxy + Allowlist statt offenem Internet.

### 5.4 Health-Check & Timeout

```typescript
// src/docker/lifecycle.ts
const TASK_TIMEOUT_MS = 30 * 60 * 1000;

export function watchTask(taskId: string, containerId: string) {
  const timer = setTimeout(async () => {
    await markTaskFailed(taskId, "timeout");
    await docker.getContainer(containerId).stop();
  }, TASK_TIMEOUT_MS);

  return { clearTimer: () => clearTimeout(timer) };
}
```

---

## Phase 6: API-basierte Kontext-Injection (Lazy File Loading)

Statt eines Bind-Mounts kann der Agent auch komplett ohne lokalen Checkout laufen und Dateien per Tool-Call beim Orchestrator anfordern – nützlich, wenn der Agent über eine reine Chat-API (kein Dateisystem-Tool) angesteuert wird.

### 6.1 Endpunkt im Orchestrator

```typescript
// src/api/agent-routes.ts
app.get("/agent/:taskId/file", async (req, reply) => {
  const { taskId } = req.params as { taskId: string };
  const path = (req.query as any).path as string;

  if (!isPathAllowed(taskId, path)) {
    return reply.code(403).send({ error: "path not in scope for this task" });
  }

  const content = await fetchFromGitHubContentsAPI(path); // oder lokaler Cache
  await logFileAccess(taskId, path); // für Audit
  return reply.send({ path, content });
});
```

### 6.2 `isPathAllowed` nutzt exakt die `required_paths` aus Phase 4 – derselbe Mechanismus, nur als Laufzeit-Check statt als Sparse-Checkout-Filter.

### 6.3 Caching pro Task

```typescript
const fileCache = new Map<string, Map<string, string>>(); // taskId -> path -> content
```
Verhindert wiederholte GitHub-API-Calls für dieselbe Datei innerhalb eines Task-Laufs.

---

## Phase 7: Agentic-TDD-Loop im Container

### 7.1 Statemachine

```typescript
type TaskState =
  | "claimed"
  | "repro_test_written"
  | "repro_test_red"     // Pflicht-Checkpoint: Test MUSS fehlschlagen
  | "fix_applied"
  | "repro_test_green"
  | "regression_pass"
  | "pr_requested";

export async function transition(taskId: string, to: TaskState, evidence: unknown) {
  const current = await getTaskState(taskId);
  const allowed: Record<TaskState, TaskState[]> = {
    claimed: ["repro_test_written"],
    repro_test_written: ["repro_test_red"],
    repro_test_red: ["fix_applied"],          // grüner Test hier = zurück zu repro_test_written
    fix_applied: ["repro_test_green"],
    repro_test_green: ["regression_pass"],
    regression_pass: ["pr_requested"],
    pr_requested: [],
  };
  if (!allowed[current]?.includes(to)) {
    throw new Error(`invalid transition ${current} -> ${to}`);
  }
  await persistState(taskId, to, evidence);
}
```

### 7.2 Verifikation durch den Orchestrator, nicht durch Selbstauskunft

Entscheidend: Der Agent *behauptet* nicht nur "Test ist rot", er muss den tatsächlichen Exit-Code + stdout/stderr mitschicken, den der Orchestrator gegen das erwartete Muster prüft:

```typescript
app.post("/agent/:taskId/test-result", async (req, reply) => {
  const { taskId } = req.params as { taskId: string };
  const { phase, exitCode, stdout, stderr } = req.body as any;

  if (phase === "repro_test" && exitCode === 0) {
    // Test ist GRÜN, obwohl er rot sein sollte -> Bug nicht reproduziert
    return reply.code(409).send({
      error: "repro test must fail before fix; bug not isolated",
    });
  }
  if (phase === "repro_test" && exitCode !== 0) {
    await transition(taskId, "repro_test_red", { stdout, stderr });
  }
  if (phase === "regression" && exitCode !== 0) {
    await transition(taskId, "fix_applied", { stdout, stderr }); // zurück, Fix nicht fertig
  }
  if (phase === "regression" && exitCode === 0) {
    await transition(taskId, "regression_pass", {});
  }
  return reply.send({ ok: true });
});
```

### 7.3 Prompt-Vorgabe für den Agenten (im Container-Kontext, z. B. als `AGENTS.md`)

```markdown
1. Lies den Bug-Report über GET /agent/:taskId/context
2. Schreibe einen Test, der den Bug reproduziert
3. Führe ihn aus, melde Ergebnis an POST /agent/:taskId/test-result mit phase=repro_test
   -> Falls exitCode 0: Test reicht nicht, neu schreiben
4. Erst nach Bestätigung von repro_test_red: Code ändern
5. Führe vollständige Suite aus, melde mit phase=regression
6. Erst nach regression_pass: POST /agent/:taskId/open-pr
```

---

## Phase 8: PR-Flow & Merge-Queue

### 8.1 PR-Erstellung über Orchestrator (nie direkter Push durch den Agenten)

```typescript
app.post("/agent/:taskId/open-pr", async (req, reply) => {
  const task = await getTask((req.params as any).taskId);
  if (task.state !== "regression_pass") {
    return reply.code(409).send({ error: "regression must pass before PR" });
  }
  const octokit = await githubApp.getInstallationOctokit(installationId);
  const pr = await octokit.rest.pulls.create({
    owner, repo,
    title: `Fix: ${task.title}`,
    head: task.branch,
    base: "main",
  });
  await enqueueForMerge(task.id, pr.data.number);
  return reply.send({ prNumber: pr.data.number });
});
```

### 8.2 Merge-Queue

Zwei Optionen, beide valide:

**A) GitHub native Merge Queue** (einfacher, weniger Code):
```bash
gh api -X PUT repos/{owner}/{repo}/branches/main/protection \
  -f required_status_checks[strict]=true \
  -f merge_queue.enabled=true
```
GitHub übernimmt Rebase + Re-CI-Run automatisch vor jedem Merge.

**B) Eigene Queue** (volle Kontrolle, nötig wenn Container-interne Re-Tests getriggert werden müssen):

```typescript
// src/mergequeue/queue.ts
export async function onPullRequestMerged(mergedPrNumber: number) {
  const waiting = await getWaitingQueueEntries();
  for (const entry of waiting) {
    await rebaseAndRetest(entry.taskId);
  }
}

async function rebaseAndRetest(taskId: string) {
  const containerId = await spawnAgentContainer(await getTask(taskId)); // frischer Container
  // Container führt aus: git fetch origin main && git rebase origin/main
  // dann komplette Suite erneut -> Ergebnis kommt über /test-result zurück
}
```

### 8.3 CI-Status abwarten

```typescript
githubApp.webhooks.on("check_suite.completed", async ({ payload }) => {
  if (payload.check_suite.conclusion === "success") {
    await advanceQueue();
  } else {
    await markQueueEntryBlocked(payload.check_suite.pull_requests[0]?.number);
  }
});
```

---

## Phase 9: Domain-Isolation / Kommunikationsprotokoll

### 9.1 Strikte Regel: kein geteiltes Volume zwischen Agenten

Jeder Container bekommt sein eigenes, isoliertes Workspace-Volume. Kommunikation läuft **ausschließlich** über die Endpunkte aus Phase 2.4/6/7 – niemals über ein gemeinsames `/shared`-Verzeichnis. Das verhindert Race Conditions, wenn mehrere Agenten parallel laufen.

### 9.2 Notifications nach außen

```typescript
async function notifyDiscord(message: string) {
  await fetch(process.env.DISCORD_WEBHOOK_URL!, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ content: message }),
  });
}

// Aufruf bei jedem wichtigen State-Wechsel:
await notifyDiscord(`🔧 Task ${taskId}: ${newState}`);
```

---

## Phase 10: Guardrails, Permissions, Observability

### 10.1 Permission-Stufen pro Task

```typescript
type Permission = "triage_only" | "autonomous" | "needs_owner";

function classify(task: Task): Permission {
  if (task.touchesSecurityPath || task.isDestructive) return "needs_owner";
  if (task.hasReproducibleTest && task.boundedScope) return "autonomous";
  return "triage_only";
}
```

Nur bei `"autonomous"` darf der Orchestrator selbstständig bis zum PR durchlaufen; bei `"needs_owner"` stoppt die Statemachine vor Schritt 8 und meldet an Discord/Slack zur manuellen Freigabe.

### 10.2 Logging & Monitoring

```typescript
app.addHook("onResponse", async (req, reply) => {
  await logRequest({ path: req.url, status: reply.statusCode, taskId: (req.params as any)?.taskId });
});
```
Alle `agent_reports`-Einträge (Phase 2.2) bilden den Audit-Trail – jeder Statuswechsel, jedes Testergebnis ist nachvollziehbar in der DB.

### 10.3 Kill-Switch

```bash
# Sofortiger Stopp aller laufenden Agenten
docker ps --filter "name=agent-" -q | xargs -r docker stop
```
Als Admin-Endpunkt: `POST /admin/kill-all`.

---

## Phase 11: Build-Reihenfolge (Checkliste)

Empfohlene Reihenfolge, damit jede Phase testbar ist, bevor die nächste aufsetzt:

- [ ] **1.** Monorepo + CODEOWNERS + Dependency-Graph (Phase 1)
- [ ] **2.** Orchestrator-Skeleton mit SQLite läuft lokal, Admin-Endpunkte abrufbar (Phase 2)
- [ ] **3.** GitHub Webhooks kommen an, Task wird in DB angelegt (Phase 3)
- [ ] **4.** Sparse-Checkout-Resolver liefert korrekte Pfade für ein Test-Issue (Phase 4)
- [ ] **5.** Ein Container wird manuell gespawnt, checkt erfolgreich nur die nötigen Pfade aus (Phase 5)
- [ ] **6.** Lazy-File-Endpunkt funktioniert mit Pfad-Validierung (Phase 6)
- [ ] **7.** TDD-Statemachine erzwingt roten Test vor Fix – mit einem absichtlich kaputten Test gegenprüfen (Phase 7)
- [ ] **8.** Erster echter End-to-End-Lauf: Issue → Container → Test rot → Fix → Test grün → PR (Phase 8)
- [ ] **9.** Zweiter Agent parallel, Merge-Queue greift korrekt bei überlappenden PRs (Phase 8/9)
- [ ] **10.** Permission-Stufen + Kill-Switch + Discord-Notifications scharf schalten (Phase 10)

---

## Anhang: Minimaler `docker-compose.yml` für den Orchestrator selbst

```yaml
version: "3.9"
services:
  orchestrator:
    build: ./orchestrator
    ports:
      - "3000:3000"
    environment:
      - GITHUB_APP_ID=${GITHUB_APP_ID}
      - GITHUB_PRIVATE_KEY=${GITHUB_PRIVATE_KEY}
      - GITHUB_WEBHOOK_SECRET=${GITHUB_WEBHOOK_SECRET}
      - DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock   # Orchestrator spawnt Sibling-Container
      - orchestrator-data:/app/data
      - git-cache:/git-cache
    networks:
      - default
      - agent-net

networks:
  agent-net:
    internal: true

volumes:
  orchestrator-data:
  git-cache:
```

**Wichtig zum Docker-Socket-Mount:** Das gibt dem Orchestrator-Container vollen Zugriff auf den Docker-Daemon des Hosts (Docker-out-of-Docker). Für produktiven Einsatz: Zugriff über einen Proxy wie `tecnativa/docker-socket-proxy` einschränken, der nur `containers/create`, `containers/start`, `containers/stop` erlaubt statt des vollen Socket-Zugriffs.
