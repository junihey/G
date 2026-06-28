# Ablaufplan: API-getriebenes Monorepo mit Docker-Sub-Agents und zentralem Orchestrator (NestJS-Edition)

Dieser Plan baut ein produktionsfähiges, aber minimales System: ein NestJS-Orchestrator verwaltet Bug-Reports/Tasks, spawnt Sub-Agenten in isolierten Docker-Containern (jeweils mit eigener, ephemerer Datenbank), kommuniziert ausschließlich über API/Message-Broker (keine geteilten Dateisysteme, keine geteilte DB), erzwingt Pull-Request-Flow mit Merge-Queue und nutzt intelligenten Sparse-Checkout statt vollständiger Repo-Klone.

**Was sich gegenüber der ersten Fassung geändert hat:** Fastify wurde durch NestJS ersetzt (Begründung in Phase 2.1), Status-Updates laufen über Redis Pub/Sub statt reines HTTP-Polling, die Merge-Queue läuft über RabbitMQ statt Eigenbau-Logik, und jeder Sub-Agent bekommt eine eigene, ephemere Postgres-Instanz statt einer geteilten DB. Jede Änderung wird an ihrer Stelle ausführlich begründet, nicht nur gezeigt.

---

## 0. Architekturüberblick

```
                         ┌──────────────────────────────────────┐
   GitHub Webhooks  ───► │                                      │ ◄─── Discord/Slack (Status, via Redis-Konsument)
   (Issues, PR merged,   │      ORCHESTRATOR (NestJS-Prozess)     │
    CI-Ergebnisse)       │                                      │
                         │  Module:                              │
                         │  - GithubModule                       │
                         │  - TasksModule (Statemachine)         │
                         │  - CheckoutModule (Sparse-Checkout)    │
                         │  - DockerModule (Spawn inkl. DB/Task)  │
                         │  - EventsModule (Redis Pub/Sub)        │
                         │  - MergeQueueModule (RabbitMQ)         │
                         │  - PermissionsModule                  │
                         └───────────┬───────────────┬───────────┘
                                     │ HTTP (DTO-validiert)         │ intern: Redis + RabbitMQ
                      ┌──────────────┼──────────────┐               │ (Agenten haben KEINEN Zugriff hierauf,
                      ▼              ▼              ▼               │  siehe Phase 9 + Netzwerk-Policy)
              ┌───────────────┐┌───────────────┐┌───────────────┐    ▼
              │ Agent-Container ││ Agent-Container ││ Agent-Container │  ┌─────────┐  ┌──────────┐
              │   + eigene DB   ││   + eigene DB   ││   + eigene DB   │  │  Redis   │  │ RabbitMQ │
              │  (Task #1)      ││  (Task #2)      ││  (Task #3)      │  └─────────┘  └──────────┘
              └───────────────┘└───────────────┘└───────────────┘
```

Kernprinzip bleibt: Der Orchestrator codet nicht selbst. Neu hinzugekommen ist die explizite Trennung in zwei interne Netzwerke (`agent-net` für die Kommunikation mit Sub-Agenten, `backend-net` für Redis/RabbitMQ) – Agent-Container haben physisch keine Netzwerkroute zum Message-Broker. Das ist kein Versehen, sondern bewusste Policy: Agenten reden ausschließlich mit dem Orchestrator über HTTP, nie direkt mit Redis, RabbitMQ oder anderen Agenten.

---

## Phase 1: Monorepo-Fundament

### 1.1 Workspace-Tooling

```bash
pnpm init
cat > pnpm-workspace.yaml <<'EOF'
packages:
  - "packages/*"
  - "shared/*"
EOF

pnpm add -D nx @nx/js
npx nx init
```

`nx graph --file=graph.json` liefert eine maschinenlesbare Abhängigkeitsstruktur – Grundlage für Phase 4.

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

---

## Phase 2: Orchestrator – Grundgerüst (NestJS-Edition)

### 2.1 Tech-Stack-Entscheidung: warum NestJS statt rohem Fastify

Die ursprüngliche Fassung dieses Plans hat rohes Fastify vorgeschlagen, weil es schnell und minimal ist. Drei konkrete Anforderungen, die im Laufe der Planung dazukamen, sprechen aber für NestJS:

1. **DTOs als einzige Quelle für drei verschiedene Zwecke.** Wir brauchen (a) Laufzeit-Validierung der Agent-Requests, (b) menschenlesbare API-Doku, (c) maschinenlesbare Tool-Schemas für die KI-Agenten selbst (Phase 6). NestJS koppelt das über `class-validator`-Decorators auf denselben Klassen, aus denen `@nestjs/swagger` automatisch OpenAPI generiert – bei Fastify hätte man das händisch über separate Zod-Schemas plus manuell gepflegte OpenAPI-Doku nachbauen müssen, mit Drift-Risiko zwischen beiden.
2. **Eingebaute Microservice-Transporter.** `@nestjs/microservices` unterstützt RabbitMQ- und Redis-Transporter als Erstklassbürger (`ClientsModule`, `@EventPattern`-Decorator). Das spart uns in Phase 7/8 viel Boilerplate gegenüber rohen `amqplib`/`ioredis`-Aufrufen.
3. **Dependency Injection für Testbarkeit.** Der Orchestrator hat viele querschneidende Abhängigkeiten (Docker-Service, GitHub-Client, Checkout-Resolver, Token-Generator). Mit DI lassen sich diese in Unit-Tests einzeln mocken – bei reinem Fastify-Code müsste man das von Hand verdrahten.

**Tradeoff, den man kennen sollte:** NestJS ist opinionierter und etwas schwerer als rohes Fastify (mehr Boilerplate pro Endpunkt: Modul, Controller, DTO, Service statt einer einzelnen Route-Funktion). Für ein Wegwerf-Skript wäre das unnötiger Overhead – für ein System mit der hier geplanten Lebensdauer und Endpunkt-Anzahl überwiegt der Validierungs-/Doku-/Testbarkeits-Gewinn deutlich. **Kafka wurde bewusst nirgends in diesem Plan verwendet** – das ist für Event-Replay/Durability im Millionen-Events-Bereich gebaut; bei unserer Größenordnung (einige bis einige Dutzend parallele Agenten) wäre es reiner Infrastruktur-Ballast ohne Gegenwert.

```bash
npx @nestjs/cli new orchestrator
cd orchestrator
pnpm add @nestjs/swagger @nestjs/microservices class-validator class-transformer
pnpm add dockerode octokit better-sqlite3 ioredis amqplib amqp-connection-manager
pnpm add -D @types/node
```

### 2.2 Datenmodell

Unverändert gegenüber der ersten Fassung (SQLite für den MVP, austauschbar gegen Postgres):

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

### 2.3 Projekt-Skeleton (NestJS-Modulstruktur)

```
orchestrator/
├── src/
│   ├── main.ts                         # Bootstrap, ValidationPipe, Swagger
│   ├── app.module.ts                   # importiert alle Feature-Module
│   ├── github/
│   │   ├── github.module.ts
│   │   ├── github.service.ts           # Octokit-App-Auth, PR-Erstellung
│   │   └── github-webhook.controller.ts
│   ├── checkout/
│   │   ├── checkout.module.ts
│   │   └── checkout.service.ts         # Sparse-Checkout-Resolver, Lazy-File-Loading
│   ├── docker/
│   │   ├── docker.module.ts
│   │   ├── docker.service.ts           # spawnAgentStack/teardownAgentStack inkl. DB-pro-Task
│   │   └── lifecycle.service.ts        # Health/Timeout
│   ├── agent/
│   │   ├── agent.module.ts
│   │   ├── agent.controller.ts         # alle /agent/:taskId/* Endpunkte
│   │   └── dto/
│   │       ├── get-file-query.dto.ts
│   │       ├── test-result.dto.ts
│   │       ├── status.dto.ts
│   │       └── open-pr.dto.ts
│   ├── tasks/
│   │   ├── tasks.module.ts
│   │   ├── tasks.service.ts            # TDD-Statemachine aus Phase 7
│   │   └── task.entity.ts
│   ├── events/
│   │   ├── events.module.ts
│   │   └── redis-publisher.service.ts  # Phase 7
│   ├── mergequeue/
│   │   ├── mergequeue.module.ts
│   │   ├── mergequeue.producer.ts      # RabbitMQ Producer
│   │   └── mergequeue.consumer.ts      # RabbitMQ Consumer – LÄUFT IM SELBEN PROZESS
│   ├── permissions/
│   │   └── permissions.service.ts
│   └── admin/
│       └── admin.controller.ts
├── shared-contracts -> ../shared-contracts   # siehe Anhang 2, als Workspace-Dependency verlinkt
└── docker-compose.yml
```

### 2.4 Bootstrap mit globaler Validierung und Swagger

```typescript
// src/main.ts
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Globale Validierung: JEDE DTO-Verletzung wird automatisch mit 400 abgelehnt,
  // bevor der Controller-Code überhaupt erreicht wird. whitelist:true entfernt
  // unbekannte Felder, forbidNonWhitelisted:true lehnt sie hart ab statt sie
  // stillschweigend zu ignorieren. Das ist der erste Guardrail aus Phase 10 -
  // ein Agent, der fehlerhafte Daten schickt, kommt nicht einmal bis zur
  // Business-Logik durch.
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }));

  const config = new DocumentBuilder()
    .setTitle('Orchestrator API')
    .setDescription('Schnittstelle zwischen Orchestrator und Sub-Agenten')
    .setVersion('1.0')
    .build();
  const document = SwaggerModule.createDocument(app, config);
  // GET /docs       -> Swagger-UI zum manuellen Nachschauen
  // GET /docs-json  -> rohe OpenAPI-Spec, wird in Phase 6 zu Tool-Schemas konvertiert
  SwaggerModule.setup('docs', app, document);

  await app.listen(3000);
}
bootstrap();
```

### 2.5 DTOs als Single Source of Truth

Statt Validierung, Doku und Tool-Schema getrennt zu pflegen, definieren wir jeden Endpunkt-Vertrag genau einmal als DTO-Klasse:

```typescript
// src/agent/dto/test-result.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsInt, IsString } from 'class-validator';

export class TestResultDto {
  @ApiProperty({ enum: ['repro_test', 'regression'], description: 'Welche Phase des TDD-Loops dieses Ergebnis betrifft' })
  @IsIn(['repro_test', 'regression'])
  phase: 'repro_test' | 'regression';

  @ApiProperty({ description: 'Exit-Code des Testlaufs; 0 = grün, alles andere = rot' })
  @IsInt()
  exitCode: number;

  @ApiProperty()
  @IsString()
  stdout: string;

  @ApiProperty()
  @IsString()
  stderr: string;
}
```

```typescript
// src/agent/dto/get-file-query.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class GetFileQueryDto {
  @ApiProperty({ description: 'Repo-relativer Pfad; muss innerhalb der required_paths des Tasks liegen' })
  @IsString()
  path: string;
}
```

### 2.6 Controller

```typescript
// src/agent/agent.controller.ts
import { Controller, Get, Post, Param, Query, Body, ForbiddenException } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { TasksService } from '../tasks/tasks.service';
import { CheckoutService } from '../checkout/checkout.service';
import { GetFileQueryDto } from './dto/get-file-query.dto';
import { TestResultDto } from './dto/test-result.dto';

@ApiTags('agent')
@Controller('agent/:taskId')
export class AgentController {
  constructor(
    private readonly tasks: TasksService,
    private readonly checkout: CheckoutService,
  ) {}

  @Post('claim')
  @ApiOperation({ summary: 'Task als in Bearbeitung markieren' })
  claim(@Param('taskId') taskId: string) {
    return this.tasks.claim(taskId);
  }

  @Get('file')
  @ApiOperation({ summary: 'Lazy-Loading einer Datei aus dem Repo-Scope' })
  async getFile(@Param('taskId') taskId: string, @Query() query: GetFileQueryDto) {
    if (!this.checkout.isPathAllowed(taskId, query.path)) {
      throw new ForbiddenException('path not in scope for this task');
    }
    return this.checkout.fetchFile(taskId, query.path);
  }

  @Post('test-result')
  @ApiOperation({ summary: 'Testergebnis melden – Pflicht-Checkpoint des TDD-Loops' })
  testResult(@Param('taskId') taskId: string, @Body() body: TestResultDto) {
    return this.tasks.handleTestResult(taskId, body);
  }
}
```

### 2.7 API-Endpunkte (Übersicht)

| Methode | Pfad | Konsument | Zweck |
|---|---|---|---|
| `POST` | `/webhooks/github` | GitHub | Issue/PR/CI-Events empfangen |
| `POST` | `/agent/:taskId/claim` | Sub-Agent | Task als "in Bearbeitung" markieren |
| `GET`  | `/agent/:taskId/file?path=` | Sub-Agent | Lazy-Loading einer Datei (Phase 6) |
| `POST` | `/agent/:taskId/status` | Sub-Agent | Statusmeldung, wird auf Redis publiziert (Phase 7) |
| `POST` | `/agent/:taskId/test-result` | Sub-Agent | Testergebnis melden (Phase 7) |
| `POST` | `/agent/:taskId/open-pr` | Sub-Agent | PR erstellen, landet in RabbitMQ-Merge-Queue (Phase 8) |
| `GET`  | `/admin/queue` | Du | Merge-Queue-Status |
| `GET`  | `/admin/tasks` | Du | Alle Tasks + Status |
| `GET`  | `/docs-json` | Build-Skript | OpenAPI-Spec für Tool-Schema-Generierung |

---

## Phase 3: GitHub-Integration

Strukturell unverändert, jetzt als injizierbarer NestJS-Service statt freier Funktionen – das macht den GitHub-Client in Tests einfach durch ein Mock ersetzbar.

```typescript
// src/github/github.service.ts
import { Injectable } from '@nestjs/common';
import { App } from 'octokit';

@Injectable()
export class GithubService {
  private readonly app = new App({
    appId: process.env.GITHUB_APP_ID!,
    privateKey: process.env.GITHUB_PRIVATE_KEY!,
    webhooks: { secret: process.env.GITHUB_WEBHOOK_SECRET! },
  });

  constructor() {
    this.app.webhooks.on('issues.opened', (e) => this.onIssueOpened(e.payload));
    this.app.webhooks.on('pull_request.closed', (e) => this.onPullRequestClosed(e.payload));
  }

  private async onIssueOpened(payload: any) { /* delegiert an TasksService.createFromIssue */ }
  private async onPullRequestClosed(payload: any) { /* delegiert an MergeQueueProducer */ }
}
```

GitHub App registrieren: Settings → Developer settings → GitHub Apps → New, Berechtigungen `Issues: Read`, `Pull requests: Write`, `Contents: Read & Write`, `Checks: Read`, Events `issues`, `pull_request`, `check_suite` abonnieren.

---

## Phase 4: Intelligenter Checkout (Sparse-Checkout-Resolver)

Auch hier nur die Verpackung neu (NestJS-Service statt freier Funktion), die Logik bleibt:

```typescript
// src/checkout/checkout.service.ts
import { Injectable } from '@nestjs/common';
import { execSync } from 'child_process';

@Injectable()
export class CheckoutService {
  resolveRequiredPaths(issueBody: string): string[] {
    const affectedPackage = this.detectPackageFromIssue(issueBody);
    const graph = JSON.parse(execSync('npx nx graph --file=-').toString());
    const deps: string[] = graph.graph.dependencies[affectedPackage]?.map((d: any) => d.target) ?? [];
    return [`packages/${affectedPackage}`, ...deps.map((d) => `shared/${d}`), 'package.json', 'pnpm-workspace.yaml'];
  }

  isPathAllowed(taskId: string, path: string): boolean {
    const allowed = this.getRequiredPaths(taskId);
    return allowed.some((p) => path.startsWith(p));
  }
}
```

Checkout-Skript im Container-Entrypoint, unverändert:

```bash
#!/bin/bash
# checkout.sh
set -e
git clone --reference /git-cache/monorepo --no-checkout --filter=blob:none "$REPO_URL" /workspace
cd /workspace
git sparse-checkout init --cone
git sparse-checkout set $REQUIRED_PATHS
git checkout main
git checkout -b "agent/task-$TASK_ID"
```

---

## Phase 5: Docker Sub-Agent Spawning + ephemere Datenbank pro Task

### 5.1 Warum jeder Agent eine eigene DB braucht

Viele reale Bugs lassen sich nicht ohne echten Datenbank-Zustand reproduzieren – ein Constraint-Verstoß, ein fehlerhafter Migrations-Schritt, eine Race Condition zwischen zwei Schreibvorgängen. Eine **geteilte** Datenbank zwischen parallel laufenden Agenten wäre hier fatal:

1. Agent A schreibt Testdaten, Agent B liest dieselbe Tabelle für einen völlig anderen Bug → nicht reproduzierbare, flackernde Tests.
2. Zwei Agenten, die zufällig dieselbe Migration testen, überschreiben sich gegenseitig den Schema-Zustand.
3. Es widerspricht direkt der Domain-Isolation aus Phase 9 – wenn der Datenzustand geteilt ist, ist die Isolation nur auf Code-Ebene echt, nicht auf Laufzeit-Ebene.

Die Lösung: **jeder Task-Stack bekommt seine eigene, isolierte Postgres-Instanz**, deren Daten auf `tmpfs` (RAM) statt auf einem persistenten Volume liegen. Das ist eine Verschärfung des klassischen "fahr alles runter, lösch die Volumes, garantiert frischer State"-Patterns aus der lokalen Docker-Compose-Entwicklung: hier muss man nicht einmal aktiv aufräumen, weil mit dem Container-Stop automatisch auch der RAM-Inhalt weg ist.

### 5.2 Task-Compose-Template

```yaml
# sandbox/docker-compose.task-template.yml
services:
  agent:
    image: agent-sandbox:latest
    networks: [agent-net]                 # NUR agent-net, kein Zugriff auf backend-net (Redis/RabbitMQ)
    environment:
      - DATABASE_URL=postgres://agent:agent@db:5432/task_db
    depends_on: [db]
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: agent
      POSTGRES_PASSWORD: agent
      POSTGRES_DB: task_db
    # tmpfs statt Volume: die Daten existieren nur im Arbeitsspeicher des
    # Containers. Beim Stop ist der gesamte DB-Zustand automatisch und
    # vollständig weg - es gibt keine Möglichkeit, dass Daten zwischen
    # zwei Tasks "überleben".
    tmpfs: ["/var/lib/postgresql/data"]
    networks: [agent-net]

networks:
  agent-net:
    external: true    # wird vom Haupt-Stack (Anhang) bereitgestellt
```

### 5.3 DockerService: Spawn inklusive eigenem DB-Stack

```typescript
// src/docker/docker.service.ts
import { Injectable } from '@nestjs/common';
import { execSync } from 'child_process';
import { Task } from '../tasks/task.entity';

@Injectable()
export class DockerService {
  /**
   * Spawnt den kompletten Stack für einen Task: Agent-Container UND seine
   * eigene, isolierte Postgres-Instanz. docker compose -p (Projekt-Name)
   * sorgt dafür, dass jeder Task seinen eigenen, namentlich getrennten
   * Compose-Stack bekommt - keine Namenskollisionen zwischen Containern
   * verschiedener Tasks, auch bei vielen parallelen Läufen nicht.
   */
  async spawnAgentStack(task: Task): Promise<void> {
    execSync(`docker compose -p task-${task.id} -f sandbox/docker-compose.task-template.yml up -d`, {
      env: {
        ...process.env,
        TASK_ID: task.id,
        REPO_URL: task.repoUrl,
        REQUIRED_PATHS: task.requiredPaths.join(' '),
        ORCHESTRATOR_URL: 'http://orchestrator:3000',
        ORCHESTRATOR_TOKEN: this.generateScopedToken(task.id),
      },
    });
  }

  /**
   * down -v ist hier strenggenommen doppelte Absicherung: die Postgres-Daten
   * liegen ohnehin auf tmpfs und sind beim Stop schon weg. -v räumt
   * zusätzlich benannte Volumes ab, falls in einer späteren Erweiterung doch
   * mal eines hinzukommt (z.B. für einen Cache, der NICHT pro Task isoliert
   * sein muss).
   */
  async teardownAgentStack(taskId: string): Promise<void> {
    execSync(`docker compose -p task-${taskId} down -v`);
  }

  private generateScopedToken(taskId: string): string {
    // signiertes JWT, das NUR für /agent/:taskId/* gültig ist - verhindert,
    // dass ein Agent-Container mit dem Token eines anderen Tasks arbeitet,
    // selbst wenn er ihn irgendwie erraten würde.
    return ''; // Implementierung: jsonwebtoken, Claim { taskId }, kurze TTL
  }
}
```

### 5.4 Sandbox-Image und Netzwerk-Policy

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
docker network create --internal agent-net
docker network create --internal backend-net
```

`--internal` auf beiden Netzen bedeutet kein ausgehender Internetzugriff und keine Route zwischen den beiden Netzen, sofern ein Container nicht explizit an beide angeschlossen ist (das ist nur der Orchestrator selbst, siehe Anhang).

### 5.5 Health-Check & Timeout

```typescript
// src/docker/lifecycle.service.ts
const TASK_TIMEOUT_MS = 30 * 60 * 1000;

export function watchTask(taskId: string, onTimeout: () => Promise<void>) {
  const timer = setTimeout(onTimeout, TASK_TIMEOUT_MS);
  return { clearTimer: () => clearTimeout(timer) };
}
```

---

## Phase 6: API-basierte Kontext-Injection + OpenAPI-zu-Tool-Schema-Generierung

### 6.1 Lazy-File-Loading

Funktional unverändert: der Agent fordert Dateien per Tool-Call an, der Orchestrator validiert den Pfad gegen die `required_paths` des Tasks (Phase 4), bevor er ausliefert.

```typescript
// in checkout.service.ts ergänzt
async fetchFile(taskId: string, path: string) {
  const content = await this.fetchFromGitHubContentsApi(path);
  this.logFileAccess(taskId, path); // Audit-Trail für Phase 10
  return { path, content };
}
```

### 6.2 Warum OpenAPI als Quelle für Tool-Schemas

Das ist der eigentliche Mehrwert der NestJS/Swagger-Kombination: **dieselbe DTO-Klasse** validiert zur Laufzeit, dokumentiert sich selbst für Menschen via Swagger-UI, und liefert über die generierte OpenAPI-Spec auch das Function-Calling-Schema für die KI-Agenten. Eine Änderung an `TestResultDto` propagiert automatisch in alle drei Stellen – es gibt keine zweite Quelle, die aus dem Tritt geraten kann. Das ist exakt dasselbe "Transform once at the boundary"-Prinzip, das schon in der Twitter/X-Codebase aus deinem hochgeladenen Dokument für die Zod-Boundary-Codecs galt – hier nur auf die Agent-Tool-Definitionen übertragen.

```typescript
// scripts/generate-agent-tools.ts
// Läuft als Build-Step nach jedem Start des Orchestrators: liest die
// laufende OpenAPI-Spec und erzeugt daraus Function-Calling-Tool-
// Definitionen für den Agenten.
import fetch from 'node-fetch';
import { writeFileSync } from 'fs';

async function generateToolSchemas() {
  const spec = await fetch('http://localhost:3000/docs-json').then((r) => r.json());

  const tools = Object.entries(spec.paths)
    .filter(([path]) => path.startsWith('/agent/'))
    .map(([path, methods]: [string, any]) => {
      const [, def] = Object.entries(methods)[0] as [string, any];
      return {
        name: def.operationId,
        description: def.summary,
        input_schema: resolveRequestSchema(def, spec.components.schemas),
      };
    });

  writeFileSync('generated/agent-tools.json', JSON.stringify(tools, null, 2));
}
```

### 6.3 Caching pro Task

```typescript
const fileCache = new Map<string, Map<string, string>>(); // taskId -> path -> content
```

---

## Phase 7: Agentic-TDD-Loop mit Redis-Status-Events

### 7.1 Warum Redis hier und nicht RabbitMQ

Status-Updates (`claimed`, `repro_test_red`, `fix_applied`, …) sind **hochfrequent** und müssen einen Orchestrator-Neustart nicht überleben – verliert man eine Zwischenmeldung, ist das unkritisch, weil der aktuelle Zustand ohnehin in der SQLite-DB persistiert wird (Phase 2.2). Das unterscheidet sie fundamental von Merge-Queue-Einträgen in Phase 8, die zwingend durabel sein müssen (ein verlorener "PR wartet auf Merge"-Eintrag wäre ein echtes Problem). Redis Pub/Sub ist für den ersten Fall die leichtgewichtigere, passendere Wahl; RabbitMQ mit seinen Durability-/Ack-Garantien ist für den zweiten Fall richtig. Beide Broker für denselben Zweck einzusetzen wäre unnötige Redundanz.

### 7.2 Statemachine (unverändert in der Logik)

```typescript
// src/tasks/tasks.service.ts
type TaskState =
  | 'claimed' | 'repro_test_written' | 'repro_test_red'
  | 'fix_applied' | 'repro_test_green' | 'regression_pass' | 'pr_requested';

const ALLOWED: Record<TaskState, TaskState[]> = {
  claimed: ['repro_test_written'],
  repro_test_written: ['repro_test_red'],
  repro_test_red: ['fix_applied'],
  fix_applied: ['repro_test_green'],
  repro_test_green: ['regression_pass'],
  regression_pass: ['pr_requested'],
  pr_requested: [],
};
```

### 7.3 Verifikation durch den Orchestrator, jetzt mit Redis-Publish nach jedem Wechsel

```typescript
// src/tasks/tasks.service.ts (Ausschnitt)
@Injectable()
export class TasksService {
  constructor(private readonly redis: RedisPublisherService) {}

  async handleTestResult(taskId: string, result: TestResultDto) {
    const current = await this.getState(taskId);

    if (result.phase === 'repro_test' && result.exitCode === 0) {
      // Test ist GRÜN, obwohl er rot sein sollte -> Bug nicht reproduziert.
      // Wichtig: hier verlassen wir uns NICHT auf die Selbstauskunft des
      // Agenten ("ich habe den Bug reproduziert"), sondern auf den
      // tatsächlich gemeldeten Exit-Code.
      throw new ConflictException('repro test must fail before fix; bug not isolated');
    }

    const next = this.computeNextState(current, result);
    await this.transition(taskId, next, result);

    // Jeder Statuswechsel geht raus auf Redis - unabhängig davon, wer
    // gerade mithört (Discord-Notifier, Admin-Dashboard, Audit-Logger).
    // Die TasksService-Logik muss ihre Konsumenten nicht einzeln kennen.
    await this.redis.publishTaskEvent(taskId, { type: next, evidence: result });

    return { state: next };
  }
}
```

```typescript
// src/events/redis-publisher.service.ts
import { Injectable } from '@nestjs/common';
import Redis from 'ioredis';

@Injectable()
export class RedisPublisherService {
  private readonly client = new Redis(process.env.REDIS_URL);

  async publishTaskEvent(taskId: string, event: { type: string; evidence: unknown }) {
    await this.client.publish(`task.${taskId}.events`, JSON.stringify(event));
  }
}
```

```typescript
// Unabhängiger Konsument, z.B. Discord-Notifier - hört einfach mit,
// ohne dass TasksService davon weiß
@Injectable()
export class DiscordNotifierService implements OnModuleInit {
  private readonly sub = new Redis(process.env.REDIS_URL);

  onModuleInit() {
    this.sub.psubscribe('task.*.events');
    this.sub.on('pmessage', (_pattern, channel, message) => {
      const event = JSON.parse(message);
      this.notify(`🔧 ${channel}: ${event.type}`);
    });
  }

  private async notify(text: string) {
    await fetch(process.env.DISCORD_WEBHOOK_URL!, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ content: text }),
    });
  }
}
```

### 7.4 Prompt-Vorgabe für den Agenten (unverändert)

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

## Phase 8: PR-Flow & Merge-Queue mit RabbitMQ

### 8.1 Warum hier RabbitMQ statt Redis

Eine Merge-Queue ist im Kern eine Warteschlange mit harten Anforderungen: ein wartender PR-Eintrag **darf nicht verloren gehen**, auch wenn der Orchestrator währenddessen neu startet; ein fehlgeschlagener Rebase-Retest soll **nicht endlos retryen**, sondern nach einer definierten Anzahl Versuche in eine Dead-Letter-Queue zur menschlichen Prüfung wandern; und der Producer (PR wurde gemergt) darf nicht warten müssen, bis der Consumer (nächster wartender Agent wird rebased) fertig ist. Das sind klassische RabbitMQ-Stärken (`durable: true`, Ack/Nack, Dead-Letter-Exchange), die Redis Pub/Sub so nicht bietet – bei Redis ist eine verlorene Nachricht einfach weg, ohne Wiederholungsversuch oder Fehlerpfad.

### 8.2 Wichtig: der Orchestrator ist alleiniger Teilnehmer am Broker

```typescript
// src/mergequeue/mergequeue.module.ts
import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices';

@Module({
  imports: [
    ClientsModule.register([
      {
        name: 'MERGE_QUEUE_SERVICE',
        transport: Transport.RMQ,
        options: {
          urls: [process.env.RABBITMQ_URL],
          queue: 'merge_queue',
          queueOptions: {
            durable: true, // Einträge überleben einen Orchestrator-Neustart
            deadLetterExchange: 'merge_queue_dlx', // 3x fehlgeschlagener Rebase -> hierhin statt endlos retryen
          },
        },
      },
    ]),
  ],
  providers: [MergeQueueProducer, MergeQueueConsumer],
})
export class MergeQueueModule {}
```

**Entscheidend:** Producer und Consumer laufen im selben NestJS-Prozess. Das ist kein technisches Versehen, sondern exakt die Architekturentscheidung aus unserer letzten Besprechung: Agenten dürfen niemals direkt am Message-Broker teilnehmen, sonst hätten wir uns auf Event-Bus-Ebene dieselben Race-Conditions eingehandelt, die wir mit dem Verzicht auf geteilte Worktrees/Dateisysteme gerade vermieden haben. Kein Agent-Container bekommt `RABBITMQ_URL` in seine Umgebungsvariablen – das ist zusätzlich zur Code-Architektur auch eine Netzwerk-Policy (Phase 9).

```typescript
// src/mergequeue/mergequeue.producer.ts
@Injectable()
export class MergeQueueProducer {
  constructor(@Inject('MERGE_QUEUE_SERVICE') private readonly client: ClientProxy) {}

  async enqueue(taskId: string, prNumber: number) {
    // emit() statt send(): wir erwarten keine synchrone Antwort, nur
    // "fire and forget" mit RabbitMQ-Ack-Garantie im Hintergrund.
    this.client.emit('pr.merged.requeue', { taskId, prNumber });
  }
}
```

```typescript
// src/mergequeue/mergequeue.consumer.ts
@Controller()
export class MergeQueueConsumer {
  constructor(
    private readonly docker: DockerService,
    private readonly tasks: TasksService,
  ) {}

  @EventPattern('pr.merged.requeue')
  async handleRequeue(@Payload() data: { taskId: string; prNumber: number }) {
    // Der eigentliche Rebase-Retest-Schritt: ein FRISCHER Container wird
    // gespawnt (nicht der alte wiederverwendet), damit kein Zustand vom
    // letzten Lauf überlebt. Er rebased auf main und läuft die volle
    // Suite erneut - das Ergebnis kommt regulär über /test-result zurück
    // und durchläuft dieselbe Statemachine wie ein Erstlauf.
    const task = await this.tasks.get(data.taskId);
    await this.docker.spawnAgentStack(task);
  }
}
```

### 8.3 PR-Erstellung über den Orchestrator

```typescript
// src/agent/agent.controller.ts (Ergänzung)
@Post('open-pr')
@ApiOperation({ summary: 'PR erstellen - nur nach regression_pass erlaubt' })
async openPr(@Param('taskId') taskId: string) {
  const task = await this.tasks.get(taskId);
  if (task.state !== 'regression_pass') {
    throw new ConflictException('regression must pass before PR');
  }
  const pr = await this.github.createPullRequest(task);
  await this.mergeQueueProducer.enqueue(task.id, pr.number);
  return { prNumber: pr.number };
}
```

### 8.4 Alternative: GitHub native Merge Queue

Falls die eigene RabbitMQ-Logik mehr Kontrolle bietet als nötig: GitHub hat eine native Merge-Queue-Funktion, die Rebase + Re-CI-Run automatisch übernimmt:

```bash
gh api -X PUT repos/{owner}/{repo}/branches/main/protection \
  -f required_status_checks[strict]=true \
  -f merge_queue.enabled=true
```

Der Unterschied: bei der nativen Variante triggert GitHub den Re-Test über deine normale CI-Pipeline, nicht über einen frisch gespawnten Container mit eigener DB-Instanz. Wenn deine Regression-Tests den isolierten Per-Task-DB-Zustand aus Phase 5 brauchen, ist die selbstgebaute RabbitMQ-Variante die richtige Wahl; wenn eine normale CI-Pipeline reicht, ist die native Lösung deutlich weniger Code.

---

## Phase 9: Domain-Isolation / Kommunikationsprotokoll

### 9.1 Zwei getrennte interne Netzwerke

```
Agent A --HTTP--> [NestJS Orchestrator Prozess] <--HTTP-- Agent B
                          │
                          │  (ausschließlich intern, gleicher Prozess/Container)
                          ├── RedisPublisherService.publish()      ──► Redis      (backend-net)
                          └── MergeQueueProducer.emit()             ──► RabbitMQ  (backend-net)
```

Kein Agent-Container hat `REDIS_URL` oder `RABBITMQ_URL` in seinen Umgebungsvariablen, und selbst wenn doch: das Docker-Netzwerk `agent-net` hat schlicht keine Route zu `backend-net`. Agent-Container sind ausschließlich an `agent-net` angeschlossen (Phase 5.2), Redis und RabbitMQ ausschließlich an `backend-net` (Anhang). Nur der Orchestrator-Container selbst ist an beiden Netzen angeschlossen – er ist die einzige Brücke, und das auf Code-Ebene (Producer/Consumer im selben Prozess) wie auf Netzwerk-Ebene (einzige Doppelmitgliedschaft).

### 9.2 Strikte Regel: kein geteiltes Volume zwischen Agenten

Unverändert: jeder Container bekommt sein eigenes, isoliertes Workspace-Volume und jetzt zusätzlich seine eigene DB-Instanz (Phase 5). Kommunikation läuft ausschließlich über die HTTP-Endpunkte aus Phase 2.7.

---

## Phase 10: Guardrails, Permissions, Observability

### 10.1 Permission-Stufen pro Task

```typescript
type Permission = 'triage_only' | 'autonomous' | 'needs_owner';

function classify(task: Task): Permission {
  if (task.touchesSecurityPath || task.isDestructive) return 'needs_owner';
  if (task.hasReproducibleTest && task.boundedScope) return 'autonomous';
  return 'triage_only';
}
```

### 10.2 DTOs als zusätzlicher Guardrail

Der globale `ValidationPipe` aus 2.4 ist selbst schon ein Guardrail: ein Agent, der ein unerwartetes Feld mitschickt oder einen falschen Typ liefert, bekommt automatisch `400 Bad Request`, bevor irgendein Service-Code läuft. Das reduziert die Fläche für fehlerhafte Agent-Reports gegenüber der ursprünglichen, händisch geprüften Fastify-Variante.

### 10.3 Logging & Audit-Trail

Jeder `agent_reports`-Eintrag (Phase 2.2) plus jedes Redis-Event (Phase 7) bildet zusammen den vollständigen Audit-Trail – nachvollziehbar sowohl auf Datenbank- als auch auf Event-Ebene.

### 10.4 Kill-Switch

```bash
docker ps --filter "name=task-" -q | xargs -r docker stop
```
Als Admin-Endpunkt: `POST /admin/kill-all`. Wichtig: stoppt jetzt auch automatisch alle Per-Task-DB-Container mit, weil sie im selben Compose-Stack (`task-<id>`) laufen.

---

## Phase 11: Build-Reihenfolge (aktualisierte Checkliste)

- [ ] **1.** Monorepo + CODEOWNERS + Dependency-Graph (Phase 1)
- [ ] **2.** NestJS-Skeleton mit globalem `ValidationPipe` + Swagger unter `/docs` läuft lokal (Phase 2)
- [ ] **3.** GitHub Webhooks kommen an, Task wird in DB angelegt (Phase 3)
- [ ] **4.** Sparse-Checkout-Resolver liefert korrekte Pfade für ein Test-Issue (Phase 4)
- [ ] **5.** Ein Task-Stack (Agent + eigene Postgres-Instanz) wird gespawnt; nach Teardown ist die DB nachweislich komplett verschwunden (Phase 5)
- [ ] **6.** Lazy-File-Endpunkt funktioniert; `/docs-json` lässt sich erfolgreich in Tool-Schemas konvertieren (Phase 6)
- [ ] **7.** TDD-Statemachine erzwingt roten Test vor Fix; Redis-Events kommen bei mindestens zwei unabhängigen Konsumenten an (Discord + Audit-Log) (Phase 7)
- [ ] **8.** Erster End-to-End-Lauf: Issue → Container → Test rot → Fix → Test grün → PR → RabbitMQ-Merge-Queue (Phase 8)
- [ ] **9.** Netzwerk-Test: von einem Agent-Container aus ist Redis/RabbitMQ NICHT erreichbar (`curl` auf `backend-net`-Hosts muss fehlschlagen) (Phase 9)
- [ ] **10.** Zweiter Agent parallel, Merge-Queue verarbeitet überlappende PRs korrekt inkl. Rebase-Retest in frischem Container (Phase 8)
- [ ] **11.** Absichtlich fehlschlagender Rebase-Retest landet in der Dead-Letter-Queue statt endlos zu retryen (Phase 8.2)
- [ ] **12.** Permission-Stufen + Kill-Switch scharf schalten (Phase 10)

---

## Anhang 1: Vollständiger `docker-compose.yml` für den Orchestrator-Stack

```yaml
version: "3.9"
services:
  orchestrator:
    build: ./orchestrator
    ports:
      - "3000:3000"     # /docs (Swagger-UI), /docs-json (OpenAPI -> Tool-Schema-Generator)
    environment:
      - GITHUB_APP_ID=${GITHUB_APP_ID}
      - GITHUB_PRIVATE_KEY=${GITHUB_PRIVATE_KEY}
      - GITHUB_WEBHOOK_SECRET=${GITHUB_WEBHOOK_SECRET}
      - DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL}
      - REDIS_URL=redis://redis:6379
      - RABBITMQ_URL=amqp://orchestrator:orchestrator@rabbitmq:5672
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock   # siehe Sicherheitshinweis unten
      - orchestrator-data:/app/data
      - git-cache:/git-cache
    networks:
      - default       # für eingehende GitHub-Webhooks erreichbar
      - agent-net      # spricht mit Sub-Agent-Containern (einzige Doppelmitgliedschaft im System)
      - backend-net    # spricht mit Redis/RabbitMQ

  redis:
    image: redis:7-alpine
    networks: [backend-net]   # Agent-Container haben hierzu keine Route

  rabbitmq:
    image: rabbitmq:3-management-alpine
    environment:
      RABBITMQ_DEFAULT_USER: orchestrator
      RABBITMQ_DEFAULT_PASS: orchestrator
    ports:
      - "15672:15672"  # Management-UI, nur für lokales Debugging, nicht produktiv exponieren
    networks: [backend-net]

networks:
  agent-net:
    internal: true
  backend-net:
    internal: true

volumes:
  orchestrator-data:
  git-cache:
```

**Sicherheitshinweis zum Docker-Socket-Mount:** Das gibt dem Orchestrator vollen Zugriff auf den Docker-Daemon des Hosts (Docker-out-of-Docker). Für mehr als ein Experiment: Zugriff über `tecnativa/docker-socket-proxy` einschränken, der nur `containers/create`, `containers/start`, `containers/stop` erlaubt statt des vollen Socket-Zugriffs.

---

## Anhang 2: Shared-Contracts-Paket (DTOs/Event-Namen)

```
shared-contracts/
├── package.json          # @internal/orchestrator-contracts
├── src/
│   ├── dto/               # dieselben Klassen, die der Orchestrator zur Validierung nutzt
│   ├── events/
│   │   └── event-names.ts # z.B. export const PR_MERGED_REQUEUE = 'pr.merged.requeue'
│   └── index.ts
└── tsconfig.json
```

Wichtig zur Abgrenzung: dieses Paket wird **ausschließlich von Orchestrator-internen Modulen** importiert (`TasksModule`, `MergeQueueModule`, `EventsModule`) – es ist kein Paket, das Agent-Container als Dependency ziehen, weil Agenten nie direkt Events publizieren oder konsumieren (Phase 9). Falls künftig weitere dauerhafte, langlebige Services hinzukommen (z. B. der Checkout-Resolver als eigenständiges Microservice, falls er irgendwann von mehreren Orchestrator-Instanzen gemeinsam genutzt werden soll), ziehen die sich dieses Paket ebenfalls – aber wieder nur orchestrator-seitige Dauer-Services, nicht die ephemeren Bugfix-Agenten selbst.

```bash
# Lokale Verlinkung während der Entwicklung (pnpm-Workspace-typisch)
pnpm add @internal/orchestrator-contracts@workspace:*
```
