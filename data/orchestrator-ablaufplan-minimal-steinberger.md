# Variante "Minimal nach Steinberger"

Parallel-Dokument zu `orchestrator-ablaufplan.md`. Kein eigener Server, kein DI-Framework, kein Message-Broker. Fünf bewegliche Teile statt elf Phasen. Jede Komponente existiert nur, weil ein konkretes Problem sie braucht – nicht, weil sie "sauber" wäre.

**Hinweis zur Einordnung:** Das ist eine Extrapolation aus zwei verifizierten Quellen – seinen öffentlichen Aussagen zu Workflow-Philosophie und seinem tatsächlichen, hochgeladenen CLAUDE.md – nicht sein Urteil über genau dieses Dokument.

---

## Die fünf Teile

1. Ein Skill-File (Markdown), das beschreibt: Bug-Report lesen → **Docker-Sandbox-Container starten** (kein Worktree, frischer Container pro Bug) → roten Test schreiben → fixen → Suite laufen lassen → `gh pr create`
2. Cron-Job, der alle 5 Minuten einen Agenten-CLI-Aufruf mit diesem Skill triggert
3. EIN `docker-compose.yml` für die Test-DB
4. GitHub native Merge Queue statt eigener Queue-Logik
5. Status geht direkt als Discord-Webhook-POST raus, kein Pub/Sub-Layer

Kein Sparse-Checkout-Resolver, kein CODEOWNERS-Dependency-Graph, keine eigene Statemachine-Bibliothek. Volle Klone in Wegwerf-Containern – bei Monorepo-Größen, die noch keine Probleme machen, ist das schlicht die einfachste Lösung, die funktioniert.

---

## 1. Skill-Files

### `skills/bugfix-loop/SKILL.md`

```markdown
# Bugfix Loop

## Trigger
Neues GitHub Issue mit Label `bug`.

## Steps
1. `gh issue view <number> --json title,body,labels` lesen.
2. Frischen Sandbox-Container für genau dieses Issue starten:
   `./scripts/spawn-bug-sandbox.sh <issue-number>`
3. Im Container: einen Test schreiben, der den Bug reproduziert.
4. Test ausführen. Exit-Code MUSS ungleich 0 sein.
   - Exit-Code 0 heißt: Test ist falsch, nicht dass der Bug nicht existiert.
     Test neu schreiben. Nicht behaupten, der Bug sei reproduziert, ohne
     den tatsächlichen Exit-Code geprüft zu haben.
5. Code ändern, bis der Test grün ist (Exit-Code 0).
6. Komplette Suite ausführen: `pnpm -s test`. Muss grün sein, sonst zurück zu Schritt 5.
7. `gh pr create --title "Fix: <issue-title>" --body "Closes #<issue-number>"`
8. `./scripts/notify-discord.sh "PR für Issue #<issue-number> erstellt"`
9. `./scripts/teardown-bug-sandbox.sh <issue-number>`
```

Das ist Schritt 4 unsere "Verifikation per Exit-Code statt Selbstauskunft" aus der vorherigen Einordnung – hier nicht als Statemachine-Code, sondern als direkte Anweisung im Prompt selbst. Der Agent bekommt keine Möglichkeit, den Schritt zu überspringen, weil es keinen Server gibt, der das erzwingt – die Disziplin liegt im Skill-Text.

### `skills/triage/SKILL.md`

```markdown
# Triage

## Steps
1. Alle offenen Issues mit Label `bug` über `gh issue list --label bug` holen.
2. Pro Issue entscheiden:
   - Reproduzierbar mit klarer Erwartung + kein Zugriff auf Security-relevante
     Pfade (`auth/`, `billing/`, `payments/`) -> autonomous, bugfix-loop starten
   - Alles andere -> needs_owner, Kommentar am Issue hinterlassen, NICHT selbst anfassen
3. Nie mehr als 3 Issues gleichzeitig autonom bearbeiten (Containerlimit, siehe Skript).
```

Zwei Markdown-Dateien, keine Datenbank für Permission-Stufen, keine `PermissionsService`-Klasse. Die Logik steht im Text und wird vom Agenten selbst beim Lesen angewendet.

---

## 2. Wake-Loop

```bash
# crontab -e
*/5 * * * * cd /path/to/repo && codex --skill triage --once >> /var/log/triage.log 2>&1
```

Kein Webhook-Server, der GitHub-Events live empfängt. Der Agent holt sich seine Arbeit selbst, alle 5 Minuten, durch aktives Nachfragen (`gh issue list`) statt durch Push-Benachrichtigung. Das eliminiert die komplette `GithubModule`/Webhook-Controller-Schicht aus der großen Variante.

---

## 3. Docker-Sandbox pro Bug (statt Worktree)

```bash
#!/bin/bash
# scripts/spawn-bug-sandbox.sh
set -e
ISSUE_NUMBER=$1
CONTAINER_NAME="bugfix-${ISSUE_NUMBER}"

docker run -d --name "$CONTAINER_NAME" \
  --network none \
  bug-sandbox:latest sleep infinity

docker exec "$CONTAINER_NAME" git clone "$REPO_URL" /repo
docker exec -w /repo "$CONTAINER_NAME" git checkout -b "agent/issue-${ISSUE_NUMBER}"
```

```bash
#!/bin/bash
# scripts/teardown-bug-sandbox.sh
docker rm -f "bugfix-${1}"
```

Voller Klon statt Sparse-Checkout, weil der Resolver-Aufwand (CODEOWNERS parsen, Dependency-Graph abfragen) erst lohnt, wenn Klonen tatsächlich langsam wird. Kein Worktree, weil ein kompletter Wegwerf-Container dieselbe Isolation einfacher liefert – der Container stirbt einfach, kein `git worktree remove`, kein Risiko eines liegen gebliebenen `.work/`-Verzeichnisses.

**Realer Vergleichspunkt:** Genau dieses Prinzip – Container statt Worktree, automatisches Aufräumen statt manuellem Cleanup – ist auch der dokumentierte Mechanismus hinter `agents.defaults.sandbox` (Docker-Backend, `workspaceAccess`, automatisches Pruning nach Idle-/Max-Age-Zeit), den wir vorhin verifiziert haben. Das Skript oben ist die Handgestrickt-Version desselben Patterns ohne das Tool selbst zu benötigen.

Aufräumen für vergessene Container, statt Pruning-Konfiguration in einem Server:

```bash
# crontab -e, zusätzlich zur Wake-Loop
0 * * * * docker ps -a --filter "name=bugfix-" --filter "status=exited" -q | xargs -r docker rm
```

---

## 4. Test-DB

```yaml
# docker-compose.test-db.yml
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev
      POSTGRES_DB: bugfix_test
    ports: ["5432:5432"]
```

```bash
# package.json script, Stil wie im echten CLAUDE.md ("pnpm run dev startet Docker automatisch")
"test:bugfix": "docker compose -f docker-compose.test-db.yml up -d && wait-on tcp:5432 && vitest run"
```

Eine geteilte Test-DB für alle Bugfix-Container statt einer eigenen Instanz pro Task. Das ist bewusst der Punkt, an dem diese Variante ein Risiko in Kauf nimmt, das die große Variante (Phase 5, DB-pro-Task) vermeidet: parallel laufende Agenten können sich hier theoretisch Testdaten überschreiben. Lösung in dieser Variante: das Triage-Skill-Limit aus Skript 1 ("nie mehr als 3 Issues gleichzeitig") hält die Kollisionswahrscheinlichkeit niedrig, statt sie architektonisch auszuschließen.

---

## 5. Merge-Queue & Status

```bash
gh api -X PUT repos/{owner}/{repo}/branches/main/protection \
  -f required_status_checks[strict]=true \
  -f merge_queue.enabled=true
```

Keine eigene RabbitMQ-Logik, kein Rebase-Retest in einem frisch gespawnten Container – GitHub übernimmt Rebase + Re-CI-Lauf. Der Tradeoff: Re-Tests laufen gegen die normale CI-Pipeline, nicht gegen einen isolierten Per-Task-DB-Zustand. Für die geteilte Test-DB aus Schritt 4 ist das ohnehin konsistent.

```bash
#!/bin/bash
# scripts/notify-discord.sh
curl -s -X POST -H "Content-Type: application/json" \
  -d "{\"content\": \"$1\"}" "$DISCORD_WEBHOOK_URL"
```

Ein `curl`-Aufruf statt `RedisPublisherService` + Pub/Sub-Konsumenten. Wer mehr als Discord-Benachrichtigungen braucht (Audit-Log, Dashboard), fügt einen zweiten `curl`-Aufruf im Skill-Text hinzu – kein Event-Bus, an den sich neue Konsumenten "anhängen".

---

## DTO/Zod-Prinzip, minimal angewendet

Die zweite übernommene Überzeugung – Transform-once-at-the-boundary, kein "handle both formats" – braucht kein NestJS-Modul, um zu gelten. Eine einzige Stelle, an der Issue-Daten ins System kommen:

```typescript
// scripts/lib/issue-schema.ts
import { z } from "zod";

export const IssueSchema = z.object({
  number: z.number(),
  title: z.string(),
  body: z.string().default(""),
  labels: z.array(z.object({ name: z.string() })),
});
export type Issue = z.infer<typeof IssueSchema>;
```

```bash
gh issue view "$1" --json number,title,body,labels | node -e "
  const { IssueSchema } = require('./scripts/lib/issue-schema');
  const data = IssueSchema.parse(JSON.parse(require('fs').readFileSync(0, 'utf-8')));
  console.log(JSON.stringify(data));
"
```

Eine Zod-Datei, ein Parse-Aufruf an der Grenze, fertig. Keine Swagger-Generierung, kein Tool-Schema-Export, keine drei Verwendungszwecke für dieselbe Klasse – nur die Grundüberzeugung selbst: einmal validieren, danach überall demselben Format vertrauen.

---

## Vollständige Repo-Struktur

```
.
├── AGENTS.md                       # General Rules, übernommen im Stil des echten CLAUDE.md
├── skills/
│   ├── bugfix-loop/SKILL.md
│   └── triage/SKILL.md
├── scripts/
│   ├── spawn-bug-sandbox.sh
│   ├── teardown-bug-sandbox.sh
│   ├── notify-discord.sh
│   └── lib/issue-schema.ts
├── docker-compose.test-db.yml
└── crontab.txt
```

Acht Dateien. Kein `node_modules` für einen eigenen Server, kein Datenbankschema für Task-Status (der Status steht implizit im PR/Issue-Zustand auf GitHub selbst), kein Netzwerk-Setup mit zwei internen Docker-Netzwerken.

---

## Wann sich der Umstieg auf die große Variante lohnt

Nicht vorab, sondern wenn eines davon tatsächlich beobachtet wird:

| Beobachtetes Problem | Upgrade aus `orchestrator-ablaufplan.md` |
|---|---|
| Mehr als ~5 Agenten parallel, Discord-Kanal wird unübersichtlich | Phase 7: Redis Pub/Sub mit mehreren Konsumenten |
| Tatsächliche Testdaten-Kollisionen trotz Container-Limit | Phase 5: eigene DB-Instanz pro Task |
| Klonen dauert spürbar lange (großes Monorepo) | Phase 4: Sparse-Checkout über CODEOWNERS |
| Wiederholt fehlschlagende Rebases trotz GitHub-Merge-Queue | Phase 8: eigene RabbitMQ-Queue mit Dead-Letter-Exchange |
| Skill-Text und tatsächliches Tool-Verhalten laufen auseinander | Phase 2.5/6.2: DTOs + Swagger-generierte Tool-Schemas |

Das ist der eigentliche Unterschied zwischen beiden Dokumenten: nicht "einfach vs. kompliziert", sondern *wann* welche Komplexität ihren Preis wert ist. Diese Variante hier ist der Startpunkt; die große Variante ist die Landkarte für den Moment, in dem einzelne Teile davon tatsächlich anfangen zu wehtun.
