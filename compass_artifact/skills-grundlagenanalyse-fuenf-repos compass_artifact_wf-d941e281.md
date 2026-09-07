# Skills-Grundlagenanalyse: fünf Repos für Obsidian / LLM-Wikis / Knowledge Graphs

*Basisdokument. Alle fünf Repos wurden geklont und jede Skill-Datei gelesen. Zuerst pro Repo, dann die Überschneidungs-Analyse. Dieses Dokument ist die Grundlage, auf der der ergänzende Recherchebericht („Lücken füllen") aufsetzt.*

---

## Überblick

| Repo | Skills | Grundidee | Format |
|---|---|---|---|
| **bholmesdev/llm-knowledge-base-skills** | 6 | Rohnotizen automatisch anreichern + Karpathy-„llm-wiki" pflegen, nachts per Cloud-Scheduler | `skills/<name>/SKILL.md`, sehr kurz |
| **starmynd-org/infinite-brain-os** | 37 | Komplettes „Betriebssystem" für ein Firmen-/Personen-Gehirn: Namespaces, Canon, Loops, Departments, Governance | flache `.md` in `.claude/skills/`, schwere YAML-Ontologie |
| **kepano/obsidian-skills** | 5 | Reine Obsidian-Syntax-/Werkzeug-Referenzen (vom Obsidian-CEO) | `SKILL.md` + `references/`, dokumentationsartig |
| **AgriciDaniel/claude-obsidian** | 15 | Produkt-Plugin: quellenbelegte Vault-Wissensbasis mit Transaktions-, Consent- und Provenance-Modell | `SKILL.md` + Python-Core (`scripts/`) |
| **iusztinpaul/ai-research-os-workshop** | 7 | Persistentes Forschungs-Wiki aus Obsidian + Readwise + NotebookLM + Web | `SKILL.md`, teils sehr lang (931 Zeilen), mit Sub-Skripten |

---

# 1. bholmesdev/llm-knowledge-base-skills (6 Skills)

Erwartetes Vault-Layout: `raw/` (unantastbare Rohnotizen), `wikis/` (agentengepflegte Synthese), `tags.md` (Tag-Registry).

**`enrich-note`** – Reichert *eine* Notiz an: (1) Tags aus der zentralen Registry `tags.md` im Vault-Root, mit ausdrücklicher Sparsamkeitsregel („sei zurückhaltend beim Erfinden neuer Tags"); (2) `source:`/`url:`-Frontmatter, falls die Notiz einen echten Ursprung hat – erfinden ist verboten; (3) einen `## Related`-Abschnitt mit Wikilinks nur auf real existierende Notizen. Am Ende Stempel `enrichedAt` (ISO-Timestamp) als Idempotenz-Marker.

**`enrich-notes-loop`** – Läuft `enrich-note` über alle Notizen ohne `enrichedAt`, unbeaufsichtigt („while I sleep"). Sonderregel beim allerersten Lauf: erst das Corpus überfliegen und die Tag-Registry mit den echten wiederkehrenden Themen füllen, damit Tags ab Notiz eins konsistent sind.

**`refresh-wiki`** – Pflegt jedes Wiki unter `wikis/` nach Karpathys Muster. Jedes Wiki hat eigene `AGENTS.md`, `index.md`, `overview.md`, `log.md`. Vier Schritte: lokales Schema lesen (es gewinnt immer über die Skill-Regeln) → neue Quellnotizen finden (bei Zweifel überspringen und in `log.md` vermerken statt raten) → ingestieren (Source-Page, Konzept-/Personen-/Organisationsseiten, `index.md`-Zähler, `log.md`) → leichter Lint (tote Wikilinks, Waisenseiten, veraltete Aussagen, Duplikate). Außerhalb von `wikis/` wird nie geschrieben.

**`enrich-notes-loop-cloud`** – Dünner Wrapper: `ob sync` → `enrich-notes-loop` gegen `~/vault` → `ob sync`. Bei Sync-Konflikten oder Auth-Fehlern: stoppen und melden, nie weiter editieren, nie löschen.

**`refresh-wiki-cloud`** – Derselbe Wrapper um `refresh-wiki`, zusätzlich Berichtspflicht (welche Wikis, welche Seiten, welche übersprungenen Kandidaten).

**`setup-oz-automations`** – Meta-Skill: richtet auf der Oz-Plattform (oz.dev, von Warp) das Environment und zwei Cron-Schedules ein – nächtlich Enrichment, wöchentlich Wiki-Refresh. Legt den Obsidian-Headless-Token als Secret an, installiert `obsidian-headless`, zieht die Skills direkt aus dem GitHub-Repo, Default-Modell `kimi-k26-fireworks`.

**Interne Beziehungen:** `enrich-note` ← `enrich-notes-loop` ← `enrich-notes-loop-cloud` ← `setup-oz-automations`; parallel dazu `refresh-wiki` ← `refresh-wiki-cloud` ← `setup-oz-automations`. Klassische dreistufige Kaskade: Einzeloperation → Batch → Scheduler-Wrapper.

---

# 2. starmynd-org/infinite-brain-os (37 Skills)

Formal ein Sonderfall: die Skills liegen als **flache `.md`-Dateien** in `.claude/skills/`, nicht als `skills/<name>/SKILL.md`. Sie sind Kopien („Shims") der kanonischen Dateien in `entities/skills/`, erzeugt von `sync-adapters.sh` – dasselbe gibt es für `.codex/`. Das Frontmatter ist eine eigene Ontologie: `id`, `aliases`, `type`, `namespace`, `lifecycle_state`, `summary`, `confidence` (0–1), `retrieval_class` (identity/domain), `export_class` (internal/department/public) und typisierte `edges` mit Relation + Confidence. Zwei Namespaces dominieren: `personal-operator` und `ai-architecture`.

## Gruppe A – Entitäten bauen (die `build-*`-Familie)

**`shape-ai-work`** *(retrieval_class: identity, confidence 0.96)* – Der Einstiegs-Skill. Aus einem unscharfen menschlichen Problem das *kleinstmögliche* gültige Entitätssystem ableiten: Wird das Wissen, Workflow, Agent, Projekt, Task oder Swarm? Explizit gegen Over-Packaging, versteckte Autonomie und Kategorienfehler.

**`build-knowledge-node`** – Wissenstragende Knoten mit korrektem Frontmatter, Namespace-Disziplin, „filename-first"-Verlinkung und Lifecycle-Haltung.

**`build-namespace`** *(identity, 0.96)* – Neuer Namespace oder Migration eines Alt-Korpus, mit expliziten Grenzregeln, Canon-Auswahl-Logik, Zielknoten-Karte und provenienzbewusster Quellenbehandlung. Kernregel: das Quellmaterial darf **nicht** zu ein paar Summary-Notizen kollabieren.

**`build-knowledge-base`** – Ebene darüber: aus einem *realen* Quellkorpus einen Namespace bauen, gesteuert per Alltagssprache statt Flags. Nutzt `build-namespace`, `migrate-legacy-knowledge-to-v2` und `canonize-namespace`.

**`build-profile-example-namespace`** – Baut unter `knowledge/_examples/` einen kleinen Referenz-Namespace, der die Ordnerform und Lint-Schwerpunkte *eines* Profils beweist, bevor ein echter Namespace dieses Profil übernimmt.

**`build-tool-contract-namespace`** – Aus öffentlicher API-Doku einen tiefen „Tool-Contract"-Namespace bauen: Canon, Operation-Knoten, Beispiele, plus einen „recommended-calls"-Router, der einem Agenten sagt, welchen Call er genau machen soll.

**`build-agent`** – Ein begrenzter Spezialist-Agent unter `entities/agents/` mit klaren Trigger-Bedingungen, Verhaltensschritten und Governance-Grenzen.

**`build-skill`** – Ein wiederverwendbarer Skill mit stabilen Trigger-Regeln, knappen Schritten und expliziten Anti-Patterns.

**`build-command-and-rule`** – Entscheidungsregel: Wird ein Verhalten ein Command (Direktaufruf), eine Rule (querschnittliche Norm) oder keins von beidem? Danach das richtige Artefakt schreiben.

**`build-workflow`** – Wiederholbare Schrittfolgen unter `workflows/` – mit der ausdrücklichen Einschränkung, dass ein Workflow keine Laufzeitumgebung vortäuscht.

**`build-project-and-task`** – Projekt-Anker und Task-Strukturen, die die Trennung persönliche vs. geteilte Planung respektieren und den richtigen Ausführungsmodus wählen.

**`build-swarm-sprint`** – Für swarm-förmige Arbeit ein Sprint-Paket mit erhaltener kanonischer Task-Bedeutung, expliziten Gates und Approval-sicherer Governance.

**`build-department`** *(ai-architecture)* – Eine „AI-Schattenabteilung" unter `departments/`: Head-Agent, Intake-Grenze, Kern-Namespaces und -Workflows, menschliche Review-Schicht, tägliche Update-Haltung.

**`scaffold-multi-brain-workspace`** – Parent-Workspace über mehrere „Brains": `.claude/`-Router über `brains/`, gemeinsames + individuelles Brain, `/start`-Bootstrap, governtes `/sync` (individuell frei, Shared-Core nur über Proposal-Branch), read-only Copy-up der Runtime-Layer, generierter Brain-Auswahlindex.

## Gruppe B – Wissenspflege & Qualität

**`canonize-namespace`** – Baut/erneuert den `canon/`-Ordner aus Pillars, Concepts, Decisions und Archiv als komprimierte First-Principles-Synthese – hinter einem Operator-Approval-Gate, mit `derived_from`-Provenance und Changelog.

**`promote-support-to-canon`** – Der Beförderungspfad: Rohquelle → support → synthesis → canon-candidate → (nach Operator-Freigabe) canon, mit Provenance-Erhalt an jedem Schritt.

**`detect-contradictions`** – Findet Widersprüche zwischen Knoten, Canon und Archiv und schreibt sie als „contradiction-map" nach `synthesis/`, mit vorläufiger Bestlösung pro Knotenpaar.

**`review-knowledge-freshness`** – Staleness-Prüfung *nach deklarierter Freshness-Posture*: nur Namespaces/Knoten, deren Zustand tatsächlich verfällt, werden geprüft; stabile Doktrin wird nicht grundlos aufgewühlt. Aktionen: re-verify, revise, archive.

**`review-output-linkage`** – Testet, ob Canon überhaupt tragend ist: Konsumieren die behaupteten Outputs/Projekte/Decisions den Namespace wirklich? Canon, der nichts antreibt, wird geflaggt.

**`lint-namespace`** – Zweistufig: erst das deterministische `validate.sh`, dann die *unscharfe* Prüfung, die kein Skript kann – Abschnittspräsenz und -reihenfolge, „ist der Canon wirklich komprimiert oder nur kopiert?", Passung zum Profil-Ordner.

**`refine-namespace-index`** – Verwandelt eine dünne oder bloß ordnerlistende `INDEX.md` in den vom Schema geforderten **Zehn-Abschnitts-Retrieval-Router**.

**`migrate-legacy-knowledge-to-v2`** – Additives Upgrade auf V2: Profil zuweisen, `canon/` und `synthesis/` ergänzen, INDEX aufwerten, `v2_status: upgraded`, alle Edges und Aliases erhalten, mit `validate.sh` beweisen. Bestehende Ordner werden nicht umgebaut.

**`harden-tool-contract`** *(lifecycle_state: scratch)* – Testet einen Tool-Contract-Namespace gegen das *echte* Tool: zweistufiger Testplan aus dem Coverage-Ledger, Ausführung unter Safety-Gates, Triage der Abweichungen, evidenzbasiertes Upgrade der Verification-Posture.

## Gruppe C – Loops (die vierteilige Kette)

**`design-loop`** – Einen Loop als begrenztes Feedbacksystem entwerfen: Objective, kontrollierte Oberfläche, Evaluator, State-Substrat, Stop-Bedingung, menschliche Gates, Absorptionspfad.

**`plan-loop`** – Konzept → konkreter Bauplan: Dateien, Entitäten, Runtime-Substrat, Review-Gates, Output-Belege.

**`implement-loop`** – Plan → Repo-Artefakte: kanonischer Workflow, unterstützender Agent und Skills, Safety-Constraints, sichtbare Output-Receipts.

**`improve-loop`** – Bestehenden Loop schärfen: Evaluator-Qualität, State-Sichtbarkeit, Rauschen, „authority drift", Absorption wiederkehrender Findings – ohne Ontologie-Wildwuchs.

## Gruppe D – Betrieb & Governance

**`apply-correction-loop`** – Wenn der Mensch dieselbe Fehlerklasse zum zweiten/dritten Mal korrigiert („third-time test"), wird die Korrektur zu dauerhafter Struktur (Rule, Playbook, Decision, Canon-Revision), statt in jedem Chat neu bezahlt zu werden.

**`manage-ai-session`** – Erzwungene Start- und Closeout-Disziplin für KI-Sessions: Transkript sichern, Kontext deklarieren, dauerhaftes Signal in Memory/Tasks/Swarms/Knowledge befördern.

**`process-namespace-intake`** – Ein einzelnes Intake-Item → Routing-Entscheidung → Änderung im Ziel-Namespace → „processed receipt", die den Kreis zum Quelldatensatz schließt.

**`triage-human-items`** – Routet menschengebundene Items der „Chief-of-Staff-Membran" nach: auto-handle / surface-now / batch / escalate-urgent. Default konservativ; externe und canon-berührende Items werden immer sichtbar gemacht. **Auf Stufe L1 ist Lernen AUS: nichts wird auto-handled.**

**`prioritize-backlog`** – Wendet das Priority-Model an: signalgewichteter Score, harte Regeln, Anti-Starvation, deterministischer Tie-Break, plus eine Zeile Begründung je Top-Item.

**`interview-business`** *(export_class: public)* – Phasiertes, adaptives Founder-Interview, eine Frage nach der anderen, Ergebnis: eine strukturierte „Business Map" in `intake/processed/`, die alle späteren Empfehlungen zitieren können. Wird von `/onboard-business` aufgerufen.

**`recommend-architecture`** *(public)* – Nachfolger davon: bildet die Business Map auf die OS-Ontologie ab und liefert eine begrenzte, priorisierte Empfehlungsmenge (Namespaces, Departments, Workflows) mit Aufwand, Priorität, Begründung *in den Worten der Person* – plus eine explizite **„noch-nicht-bauen"-Liste**.

**`summarize-source`** – Beliebige Quelle (Webseite, Dokument, Knoten, Transkript) zu einem kompakten, zitierfähigen Eintrag verdichten.

**`write-product-description`** *(namespace `emberline-studio`)* – Demo-Skill für einen fiktiven Kerzenhersteller: Duftnoten (top/heart/base), Brenndauer, ehrliche Materialien, eine sinnliche Szene, eine Pflegezeile, in der Markenstimme. Zeigt, wie ein Domänen-Skill im System aussieht.

---

# 3. kepano/obsidian-skills (5 Skills)

Vom Obsidian-CEO; folgt der [agentskills.io](https://agentskills.io)-Spezifikation und ist bewusst **agentenneutral** (Claude Code, Codex, OpenCode). Diese Skills *beschreiben Formate*, sie definieren kein Workflow-System.

**`obsidian-markdown`** (196 Z. + `references/`) – Obsidian Flavored Markdown: Wikilinks (`[[Note#Heading]]`, `[[Note#^block-id]]`, Alias-Pipe), Embeds (`![[…]]`, Bildbreite, PDF-Seite), Callouts, Properties/Frontmatter, Kommentare, Highlights, Math, Mermaid. Standard-Markdown wird als bekannt vorausgesetzt. Explizite Regel: Wikilinks intern, Markdown-Links nur extern. Referenzdateien: `PROPERTIES.md`, `EMBEDS.md`, `CALLOUTS.md`.

**`obsidian-bases`** (499 Z.) – `.base`-Dateien (Obsidians Datenbankansichten): globale und View-spezifische `filters` (rekursiv mit genau einem `and`/`or`/`not`-Key), `formulas`, `properties` mit `displayName`, `summaries`, Views vom Typ `table`/`cards`/`list`/`map`, `groupBy`, `limit`, `order`. Mit Validierungs-Workflow und typischen YAML-Quoting-Fallen.

**`json-canvas`** (244 Z.) – `.canvas`-Dateien nach [JSON Canvas 1.0](https://jsoncanvas.org/spec/1.0/): `nodes`/`edges`, 16-stellige Hex-IDs, Positionierung mit 50–100 px Abstand, `fromSide`/`toSide`, Kantenlabels. Vier Workflows (neu erstellen, Knoten hinzufügen, verbinden, bearbeiten), jeder mit Validierungsschritt für ID-Eindeutigkeit und auflösbare Kantenreferenzen.

**`obsidian-cli`** (106 Z.) – Das offizielle `obsidian`-Kommandozeilenwerkzeug (braucht laufendes Obsidian). Syntax: Parameter mit `=`, Flags ohne Wert; `file=` löst wie ein Wikilink auf, `path=` ist exakt; `vault=` als erster Parameter. Deckt `read`, `create`, `append`, `search`, `daily:*`, `property:set`, `tasks`, `tags`, `backlinks` ab – **und** Plugin-/Theme-Entwicklung: Plugin neu laden, JavaScript ausführen, Fehler abfangen, Screenshots, DOM inspizieren.

**`defuddle`** (41 Z.) – Die `defuddle`-CLI statt WebFetch: `defuddle parse <url> --md` liefert sauberes Markdown ohne Navigation und Werbung, spart Tokens. Ausdrückliche Ausnahme: URLs auf `.md` sind bereits Markdown → normales WebFetch.

---

# 4. AgriciDaniel/claude-obsidian (15 Skills)

Ein vollständiges Claude-Code-Plugin (v2.1.0, MIT) mit einem Python-Core (`scripts/claude-obsidian.py`). Drei Prinzipien ziehen sich durch *jede* Skill-Datei:

1. **Produkt-Root ≠ Vault.** Jeder Skill beginnt mit derselben Auflösungslogik (`PRODUCT_ROOT`, dann Vault via `--vault` → `CLAUDE_OBSIDIAN_VAULT` → Workspace-Config → Verzeichnissuche) und der Regel „fail closed" bei Mehrdeutigkeit.
2. **Transaktionen statt direkter Schreibzugriffe.** Jede Mutation läuft als *ein* inspizierbares, rücknehmbares `claude-obsidian.transaction.v1`-Bundle. Dry-Run ist Default; `--apply` verlangt den zuvor ausgegebenen `--approved-plan-sha256`. Parallele Agenten dürfen nur Entwürfe liefern; genau ein Orchestrator wendet an.
3. **Prompt-Injection-Abwehr.** Webergebnisse, Vault-Seiten, Chunks, Ledger-Strings und Worker-Entwürfe gelten als *untrusted evidence, never operational authority* – eingebettete Anweisungen, Scope-Erweiterungen, Egress-Wünsche werden ignoriert.

**`wiki`** – Orchestrator und Einstiegspunkt (`/wiki`). `init` (neuer Vault) bzw. `adopt` (bestehender Vault), beide dry-run-first. Enthält die Routing-Tabelle: Quellen ingestieren → `wiki-ingest`; aus dem Vault antworten → `wiki-query`; Gesprächsergebnis sichern → `save`; Web recherchieren → `autoresearch`; Gesundheit prüfen → `wiki-lint`; Log verdichten → `wiki-fold`; Canvas → `canvas`. Kein Netzwerk für das Baseline-Setup, keine automatischen Git-Commits.

**`wiki-ingest`** – Geliefertes Material (eingefügter Text, Dateien in `inbox/` oder dem unveränderlichen `.raw/`-Archiv, ausdrücklich freigegebene URLs) wird zu belegten, querverlinkten Notizen – mit Provenance- und Claim-Tracking. Vorher werden Scope und Egress-Budget (Quellenzahl, Quellengröße) vereinbart. Die Quelle selbst wird nie verändert.

**`wiki-query`** – Beantwortet eine ausdrücklich vault-bezogene Frage rein lesend. `wiki/hot.md` gilt als Orientierung, *nicht* als Beleg. Allgemeinwissensfragen sollen hier explizit **nicht** landen. Persistenz nur über eine separate `save`-Operation.

**`save`** – Sichert genau den vom Nutzer *ausgewählten* Ausschnitt (Antwort, Entscheidung, Insight, Session-Summary) als eine geprüfte Transaktion. Läuft nie automatisch, nimmt nie standardmäßig das ganze Transkript, kein Netzwerk. Bei unklarem Scope: genau eine Rückfrage.

**`autoresearch`** – Begrenzte, quellenbelegte Recherche im öffentlichen Web (`/autoresearch`). Leitmotiv: *„Research first; merge later."* Erzeugt ein zitiertes Dossier; die Übernahme in den kanonischen Vault ist eine **separat geprüfte** Merge-Operation – Webfunde werden nicht dadurch kanonisch, dass sie abgerufen wurden.

**`wiki-lint`** – Deterministischer, rein lesender Health-Check über die portable Lint-Engine: Graph, Links, Frontmatter, Provenance-Ledger, leere Abschnitte, veraltete Indizes. Erstellt ausdrücklich **keine** Reports, Dashboards, Canvases, Stubs oder Fixes.

**`wiki-fold`** – Additive, extraktive, strukturell idempotente Verdichtung eines begrenzten Bereichs von `wiki/log.md`. Kinder-Einträge werden nie verändert, verschoben oder gelöscht; keine Fold-of-Folds, keine automatische Auslösung; Dry-Run-Vorschau als Default.

**`wiki-retrieve`** – Vault-lokaler hybrider Retrieval-Index: `contextual-prefix.py` (Chunking an Absatzgrenzen) → `bm25-index.py` → `retrieve.py` → optional `rerank.py` (mehrsprachiges Nomic-Cosine-Reranking). Abgeleitete Caches liegen ausschließlich unter `.vault-meta/`; kanonische Notizen bleiben unangetastet; Remote-Egress braucht Zustimmung; fehlendes Reranking fällt deterministisch zurück.

**`wiki-mode`** – Liest/konfiguriert die Ablage-Methodik (`.vault-meta/mode.json`): Generic, LYT, PARA oder Zettelkasten, und schlägt Ziele für geplante Notizen vor. Schreibt selbst nichts und migriert nichts. Bei defekter Konfigurationsdatei: fail closed statt stiller Rückfall auf Generic.

**`wiki-cli`** – Erkennt das offizielle `obsidian`-Binary und nutzt es **nur lesend/suchend** als Transport. Bloße Existenz des Binaries beweist nicht die Nutzbarkeit; Probe ohne Host-State zu hinterlassen. Mutationen gehen niemals über diesen Weg, sondern immer über den Transaktions-Core.

**`canvas`** – Erstellt/inspiziert/aktualisiert JSON-Canvas-Boards (Text-, Datei-, Link-, Gruppen- und Kanten-Knoten). Lesen read-only, Mutationen über eine Transaktion. Verweist ausdrücklich auf kepanos `json-canvas`-Skill als bevorzugte Syntaxquelle, sonst auf die eigene `references/canvas-spec.md`.

**`obsidian-markdown`** – Kompakte Fallback-Referenz für Obsidian-Syntax; bevorzugt kepanos gleichnamigen Skill, dann Obsidian Help. Syntaxfragen read-only; Vault-Änderungen nur als Transaktion mit `operation_type: markdown` und ausschließlich `wiki/`-Zielen.

**`obsidian-bases`** – Ebenso: kompakter Workflow + Fallback-Syntax, bevorzugt kepanos `obsidian-bases`, dann die offizielle Bases-Doku. `.base`-Änderungen nur über eine geprüfte Transaktion.

**`defuddle`** – Behandelt Defuddle als *optionalen externen Extraktor*, nicht als eingebaute Fähigkeit: nur HTTPS, nur artikelartige Seiten, ausdrückliche Netzwerk-Zustimmung. Reinigung, Rohkopie und Wiki-Ingest sind drei getrennte Operationen. Für aktuelle CLI-Flags: kepanos Skill bevorzugen, aber die eigenen Privacy-/Consent-/Transaktionsregeln behalten.

**`think`** – Der Ausreißer: ein zehnstufiger Reasoning-Loop (OBSERVE, OBSERVE, LISTEN, THINK, CONNECT, CONNECT, FEEL, ACCEPT, CREATE, GROW) für folgenreiche oder mehrdeutige Entscheidungen – Architektur-Reviews, Postmortems, Trade-off-Analysen. Vorher wird ein Evidenzrahmen aufgespannt: *Observed / Inferred / Unknown / Preference*. Vollständig read-only; wenn die CREATE-Stufe eine Änderung empfiehlt, muss danach ein Mutations-Skill separat autorisiert werden.

---

# 5. iusztinpaul/ai-research-os-workshop (7 Skills)

Aus einem AI-Engineer-World's-Fair-Workshop. Ziel: nicht jede Woche dasselbe Thema neu recherchieren. Verzeichnisstruktur pro Thema: `working-dir/research-<topic-slug>/` mit `raw/` (unveränderliche Quellen), `wiki/` (sources, concepts, entities, comparisons, overview, synthesis, open-questions, contradictions, renders), `index.yaml`/`index.md` (Katalog, den zukünftige Agenten zuerst lesen) und `log.md`. Obsidian ist optional – nur eine visuelle IDE für das erzeugte Markdown.

**`research`** (931 Zeilen – der Kern) – Konversationeller Einstiegspunkt mit **Vier-Modi-Routing**:

- *query* – schnelle, rein lesende Antwort aus dem bestehenden Wiki (Sekunden bis <1 Min). Default, sobald ein passendes Verzeichnis existiert und eine Frage gestellt wird – auch wenn das Wort „research" fällt.
- *append* – nur die gelieferten Quellen ingestieren, keine Discovery; Seeds bekommen `relevance_score: 1.0`, Dedup gegen `index.yaml` (~1–10 Min).
- *deep* – explizite Discovery mit Tiefenpreset `fast` (5–10 Min) / `light` (10–20) / `deep` (20–40+). Wenn Quellen geliefert werden und der Nutzer weder zu- noch abgesagt hat, greift ein **Deep-Research-Gate** *vor* jeder teuren Aktion.
- *init* – neues Forschungsverzeichnis anlegen, dann append oder deep.

Quellen: Obsidian-Vault, Readwise-Highlights, NotebookLM, GitHub-Repos, YouTube-Transkripte, Web-Seeds, abgelegte PDFs.

**`research-lint`** – Sieben Checks: orphan sources, fehlende Entity-/Concept-Hubs, fehlende Comparison-Kandidaten, tote Wikilinks, veraltete Claims, Widersprüche, Open-Question-Synthese. Die vier billigen laufen als parallele Skripte und flaggen nur; die drei LLM-Checks können übersprungen werden. Geschrieben wird ausschließlich in `wiki/open-questions.md`, `wiki/contradictions.md`, `index.yaml`, `index.md`, `log.md` – nie in Source-, Entity-, Concept-Seiten oder `raw/`. **Immer nutzerausgelöst, nie automatisch.** Prüft außerdem das v4-Layout und verweist bei älteren Layouts auf `migrate_layout.py`.

**`research-distill`** – Die Audit-/Export-Seite: nimmt ein Forschungsverzeichnis plus die Inhaltsdateien, an denen der Nutzer arbeitet, und erzeugt *eine* `research.md` mit **nur den tatsächlich verwendeten** Quellen – reduziert auf die Claims, Zitate und Nuancen, auf die der Text sich wirklich stützt. „Verwendet" wird über explizite Nennungen (Titel, Autor, URL, Zitatnummer, Dateiname) oder inhaltliche Übereinstimmung bestimmt. Jede Quelle behält ihren vollen Metadaten-/URI-Envelope, damit ein Writer-Agent zurückspringen kann.

**`research-render`** – Multi-Form-Antworten aus Wiki-Seiten, idempotent abgelegt unter `wiki/renders/<format>/<slug>`: **marp** (Foliendeck), **chart** (matplotlib-PNG plus reproduzierbares `.py`), **canvas** (Obsidian `.canvas`), **brief** (Social-Content-Brief für LinkedIn/Substack/X/Reddit). Mehrere Formate pro Lauf möglich, dann parallele Writer. Ein fünftes Format „table" wurde bewusst verworfen – Tabellen gehören in `comparison`-Seiten.

**`obsidian-cli`** – Zugriff auf den Obsidian-Vault als Quelle.

**`readwise-cli`** – Die `@readwise/cli`: Highlights (Bücher, Artikel, Podcasts) und Reader-Dokumente (Later, Shortlist, Archive), inklusive semantischer Suche `reader-search-documents --query …`, `--json` für maschinenlesbare Ausgabe, Login per Access-Token.

**`nlm-skill`** (709 Zeilen, versioniert 0.5.13) – NotebookLM über `nlm`-CLI **oder** MCP-Server. Beginnt mit zwingender Tool-Detection: Sind beide verfügbar, **muss der Nutzer gefragt werden**, welchen Weg er will. Deckt Notebooks anlegen/verwalten, Quellen hinzufügen (URLs, YouTube, Text, Google Drive) und Generierung ab: Podcasts/Audio-Overviews, Reports, Quizze, Karteikarten, Mindmaps, Slides, Infografiken, Videos, Datentabellen.

---

# Gleich, ähnlich, verschieden – die Querschnittsanalyse

## A. Namensgleiche Skills

### `obsidian-cli` — kepano vs. ai-research-os

**Nahezu identisch.** ai-research-os hat kepanos Datei praktisch übernommen: gleiche `description` Wort für Wort, gleiche Struktur (Syntax, File-Targeting, Vault-Targeting, Common Patterns). **Unterschied:** ai-research-os ergänzt einen „Install / Enable"-Abschnitt (Obsidian 1.12.7+, Settings › General › Advanced › CLI) samt Windows-Pfad `%LOCALAPPDATA%\Programs\Obsidian\Obsidian.com`, `OBSIDIAN_CLI`-Env-Variable und einem Hinweis, dass `/research` diesen Pfad im Preflight selbst probiert. Also: kepano = kanonische Referenz, ai-research-os = kanonische Referenz + Deployment-Härtung.

### `obsidian-cli` (kepano) vs. `wiki-cli` (claude-obsidian)

Gleiches Werkzeug, **entgegengesetzte Philosophie.** Kepano dokumentiert die *volle* CLI, Lesen wie Schreiben (`create`, `append`, `property:set`, `daily:append`) plus Plugin-Debugging. claude-obsidian nutzt dieselbe CLI **ausschließlich als Lese-/Suchtransport** und verbietet Mutationen darüber explizit – sie müssen durch den Transaktions-Core. Zusätzlich Skepsis gegenüber der Verfügbarkeit („binary presence alone does not prove it is usable") und Probing ohne Host-State-Änderung. Kepano beschreibt ein Werkzeug; claude-obsidian bändigt es.

### `defuddle` — kepano vs. claude-obsidian

Gleiches Ziel (sauberes Markdown statt WebFetch), **völlig andere Rahmung.**

- kepano (41 Z.): pragmatisches Cheat-Sheet. Installation, `--md`/`--json`/`-p`, Ausgabeformate, Ausnahme für `.md`-URLs. Token-Ersparnis ist das Argument.
- claude-obsidian (104 Z.): Defuddle ist ein *optionaler externer* Extraktor mit Safety-Contract – nur HTTPS, ausdrückliche Netzwerkzustimmung, saubere Trennung von Reinigung / Rohkopie / Ingest. Und es sagt selbst: für aktuelle Flags nimm kepanos Skill, behalte aber meine Consent-Regeln.

### `obsidian-markdown` und `obsidian-bases` — kepano vs. claude-obsidian

Dasselbe Muster, hier sogar **explizit deklariert**: claude-obsidian nennt seine Versionen „compact fallback" und schreibt in beide Dateien, man solle einen separat installierten kepano-Skill bevorzugen. Umfangsverhältnis: 196 vs. 141 Zeilen (Markdown), 499 vs. 142 (Bases). Der funktionale Unterschied ist aber nicht Umfang, sondern **Schreibrecht**: kepano zeigt, *wie* die Datei aussehen muss; claude-obsidian beantwortet Syntaxfragen read-only und leitet jede Dateiänderung durch ein `claude-obsidian.transaction.v1`-Bundle mit `operation_type: markdown` und Zielbeschränkung auf `wiki/`.

### `json-canvas` (kepano) vs. `canvas` (claude-obsidian) vs. Canvas in `research-render`

Drei Ebenen desselben Formats:

- kepano `json-canvas` = die **Formatspezifikation** (244 Z., ID-Vergabe, Kollisionsvermeidung, Abstände, Validierung).
- claude-obsidian `canvas` = **Vault-Operation** auf Canvas-Dateien, Lesen read-only, Schreiben transaktional; delegiert die Syntax ausdrücklich an kepano.
- ai-research-os `research-render` (Format `canvas`) = **Generierung** einer Canvas als eines von vier Ausgabeformaten aus Wiki-Seiten, abgelegt unter `wiki/renders/canvas/`.

Merksatz: kepano definiert, claude-obsidian bearbeitet sicher, ai-research-os erzeugt.

## B. Funktionsgleiche Skills mit anderen Namen

### Lint / Health-Check: `refresh-wiki` (Schritt 4) · `wiki-lint` · `research-lint` · `lint-namespace`

Alle vier suchen tote Links, Waisen, veraltete Aussagen, dünne Stellen. Die Unterschiede sind aufschlussreich:

| | Auslösung | Schreibrechte | Intelligenz |
|---|---|---|---|
| bholmes `refresh-wiki` §4 | automatisch, als Teil jedes Refresh | repariert das Einfache, loggt den Rest | LLM-Urteil |
| claude-obsidian `wiki-lint` | Nutzer | **keine** – reine Beobachtung, keine Reports, keine Fixes | deterministische Engine |
| ai-research-os `research-lint` | Nutzer, „nie automatisiert" | eng begrenzt: nur `open-questions.md`, `contradictions.md`, Index, Log | 4 Skripte + 3 LLM-Checks |
| IBOS `lint-namespace` | Nutzer | über Folge-Skills | **bewusst zweistufig**: erst `validate.sh`, dann die unscharfe Prüfung, die kein Skript kann |

`lint-namespace` ist der einzige, der die Grenze zwischen Deterministischem und Urteilsbehaftetem zum expliziten Designprinzip macht. `wiki-lint` ist der strengste bezüglich Nebenwirkungen. `refresh-wiki` ist der einzige, der ungefragt repariert – konsequent, denn er ist für unbeaufsichtigte Nachtläufe gebaut.

### Widerspruchserkennung: `detect-contradictions` (IBOS) vs. der contradictions-Check in `research-lint`

IBOS macht daraus einen **eigenen Skill** mit dauerhaftem Artefakt (eine „contradiction-map" in `synthesis/`, mit vorläufiger Bestlösung pro Knotenpaar, gedacht zur bewussten Auflösung durch den Operator). ai-research-os macht daraus **einen von sieben Lint-Checks**, der als teuer und langsam markiert und an `wiki/contradictions.md` angehängt wird. Gleiches Problem, unterschiedliches Gewicht.

### Verdichtung: `wiki-fold` (claude-obsidian) vs. `canonize-namespace` (IBOS) vs. `research-distill` (ai-research-os)

Alle drei komprimieren – aber drei verschiedene Dinge:

- `wiki-fold` verdichtet **Log-Einträge** (chronologisches Rauschen), extraktiv, additiv, idempotent, ohne Kinder anzufassen.
- `canonize-namespace` verdichtet **Wissen zu First Principles** (Canon), hinter einem Approval-Gate, mit `derived_from` und Changelog. `lint-namespace` prüft eigens, ob dabei wirklich komprimiert und nicht bloß kopiert wurde.
- `research-distill` verdichtet **nach Verwendung**: nur was in einem konkreten Text tatsächlich zitiert wurde, mit Rücksprungfähigkeit über URI-Envelopes.

Also: zeitliche Verdichtung vs. epistemische Verdichtung vs. verwendungsbezogene Verdichtung.

### Quellen-Ingest: `enrich-note` · `wiki-ingest` · `research` (append-Modus) · `summarize-source` · `process-namespace-intake`

Die größte Familie, mit dem breitesten Spektrum an Sorgfalt:

| Skill | Was hineingeht | Sicherung |
|---|---|---|
| `enrich-note` | Notizen, die schon im Vault liegen | „nichts erfinden", nur existierende Linkziele, `enrichedAt`-Stempel |
| `summarize-source` (IBOS) | beliebige Quelle → zitierfähiger Eintrag | Style-Rule, Namespace-Intake-Rules |
| `process-namespace-intake` (IBOS) | *ein* Intake-Item | „processed receipt" schließt den Kreis zur Quelle |
| `wiki-ingest` | Text, `inbox/`-Dateien, `.raw/`, freigegebene URLs | Provenance- und Claim-Ledger, vorab vereinbartes Egress-Budget, Quelle unverändert |
| `research` (append) | Obsidian, Readwise, NLM, GitHub, YouTube, PDFs, Web | `relevance_score: 1.0` für Seeds, Dedup gegen `index.yaml` |

`wiki-ingest` ist mit Abstand das strengste (Claim-Ledger mit Authority, Freshness, Support, Contradiction, Confidence, Review-State); `research` ist das breiteste bezüglich Quelltypen; `enrich-note` das schlankeste.

### Recherche: `autoresearch` (claude-obsidian) vs. `research` deep-Modus (ai-research-os)

Beide: begrenzte Web-Recherche mit Budget und Gate.

- `autoresearch` trennt **Recherche und Merge in zwei Operationen**: das Dossier entsteht zitiert, aber wird erst durch eine separat geprüfte Merge-Operation kanonisch. Kernsatz: „Research first; merge later."
- `research` deep begrenzt über **Tiefenpresets mit Laufzeitschätzungen** (fast/light/deep) und ein Gate vor teuren Aktionen; das Ergebnis landet direkt im Wiki.

Unterschiedliche Sicherheitsachse: claude-obsidian schützt die *Kanonizität*, ai-research-os schützt *Zeit und Kosten*.

### Abfragen: `wiki-query` vs. `research` query-Modus

Sehr ähnlich – beide rein lesend, beide mit Persistenz nur als separatem Schritt. Feiner Unterschied in der Routing-Regel: `wiki-query` sagt „route hier keine allgemeinen Wissensfragen hin"; `research` query sagt umgekehrt „wenn ein Verzeichnis existiert, ist query der Default, selbst wenn das Wort *research* fällt". Beide bekämpfen dasselbe Failure-Mode – teure Discovery für eine Frage, die das Wiki schon beantwortet – von zwei Seiten.

## C. Was nur in *einem* Repo existiert

- **Scheduling / Unattended-Betrieb** – nur bholmes (`*-cloud`, `setup-oz-automations`). Kein anderes Repo hat einen Cron-Weg; claude-obsidian und ai-research-os verbieten Automatik sogar ausdrücklich.
- **Tag-Registry als geteilte, sparsam wachsende Ressource** – nur bholmes (`tags.md`).
- **Governance-Ontologie mit typisierten Kanten, `confidence`, `retrieval_class`, `export_class`** – nur IBOS.
- **Loops als eigene Entitätsklasse mit vierteiligem Lebenszyklus** – nur IBOS.
- **Organisationsstrukturen (Departments, Swarms, Sprints, Multi-Brain-Workspaces)** – nur IBOS.
- **Onboarding-Interview → Architekturempfehlung** (`interview-business` → `recommend-architecture`, inklusive „do-not-build-yet"-Liste) – nur IBOS.
- **Menschliche Korrekturen als Strukturänderung** (`apply-correction-loop`, „third-time test") – nur IBOS.
- **Transaktionsmodell mit SHA-256-Approval und Recovery** – nur claude-obsidian.
- **Explizite Prompt-Injection-Abwehr in fast jeder Skill-Datei** – nur claude-obsidian.
- **Ablage-Methodiken (PARA / LYT / Zettelkasten) als konfigurierbarer Modus** – nur claude-obsidian (`wiki-mode`).
- **Lokaler hybrider Retrieval-Stack (BM25 + Nomic-Reranking)** – nur claude-obsidian (`wiki-retrieve`).
- **Strukturierter Reasoning-Loop** (`think`) – nur claude-obsidian; inhaltlich am nächsten an IBOS' `design-loop`/`shape-ai-work`, aber read-only und auf einzelne Entscheidungen statt auf Systementwurf gerichtet.
- **Readwise- und NotebookLM-Anbindung** – nur ai-research-os.
- **Multi-Form-Rendering** (Marp, matplotlib, Canvas, Social-Brief) – nur ai-research-os (`research-render`).
- **Verwendungsbezogener Export** (`research-distill`) – nur ai-research-os.
- **Vier-Modi-Routing in einem einzigen Skill** – nur ai-research-os (`research`).
- **Obsidian-Formatspezifikationen in Referenztiefe** – nur kepano (und als Fallback bei claude-obsidian).

## D. Architektur-Muster im Vergleich

**Wie wird Wissen geschichtet?** Alle fünf trennen unveränderliche Quelle von gepflegter Synthese, aber unterschiedlich fein:

| Repo | Schichten |
|---|---|
| bholmes | `raw/` → `wikis/` (2) |
| ai-research-os | `raw/` → `wiki/sources/` → concepts/entities/comparisons → overview/synthesis → renders (5) |
| claude-obsidian | `.raw/`/`inbox/` → `wiki/` mit Source-/Claim-Ledgern → `.vault-meta/` (abgeleitet) (3+) |
| IBOS | Rohquelle → support → synthesis → canon-candidate → canon (5, mit Approval-Gate) |
| kepano | — (kein Wissensmodell, nur Formate) |

IBOS ist als einziges Repo so gebaut, dass der Aufstieg einer Aussage in die höchste Schicht eine **menschliche Freigabe** erfordert.

**Wie wird der Mensch eingebunden?** bholmes minimiert ihn (das ist der Punkt: „you write things down, agents handle the organizing"). claude-obsidian macht ihn zum Gatekeeper jeder Mutation (Dry-Run + SHA-Bestätigung). IBOS macht ihn zum Approver von Canon und zum Adressaten einer Triage-Membran. ai-research-os macht ihn zum Auslöser (Lint und Render sind „always user-triggered"). kepano stellt die Frage nicht.

**Wie kompatibel sind sie untereinander?**

- kepano ↔ claude-obsidian: **entworfene Koexistenz** – claude-obsidian erkennt kepano-Skills und tritt bei Syntaxfragen zurück.
- kepano ↔ ai-research-os: **Code-Übernahme** bei `obsidian-cli`.
- bholmes ↔ ai-research-os: **gemeinsamer Ahne** – beide berufen sich auf Karpathys llm-wiki-Muster (`index.md`, `overview.md`, `log.md`, Source-/Konzeptseiten). bholmes ist die minimale, ai-research-os die ausgebaute Lesart.
- IBOS ↔ alle anderen: **weitgehend isoliert.** Eigenes Frontmatter-Schema, flache Dateiablage statt `SKILL.md`-Ordner, Adapter-Muster mit `entities/` als Quelle der Wahrheit. Es ist kein Obsidian-Toolkit, sondern ein Betriebsmodell, das Obsidian nur als Anzeige nutzt.

## E. Kurzempfehlung nach Anwendungsfall

- **Nur Obsidian-Syntax korrekt hinbekommen** → kepano, allein. Alles andere ist Overhead.
- **Notizen sollen sich selbst sortieren, ohne dass ich etwas tue** → bholmes.
- **Quellenbelegte Wissensbasis, bei der ich jede Änderung kontrolliere** → claude-obsidian (+ kepano danebeninstallieren, das ist so vorgesehen).
- **Recherche über Obsidian + Readwise + NotebookLM, die über Monate hält und in Decks/Artikel mündet** → ai-research-os.
- **Ein ganzes Team-/Firmen-Gehirn mit Governance, Rollen und Verfallsregeln modellieren** → IBOS – mit dem Vorbehalt, dass die meisten Skills `lifecycle_state: research` tragen und das Repo stark auf seine eigene Ordnerkonvention zugeschnitten ist.

Zwei Kombinationen sind konfliktfrei: kepano + claude-obsidian (explizit vorgesehen) und kepano + ai-research-os (teilt bereits Code). bholmes + claude-obsidian dagegen kollidiert im Grundsatz – der eine ist für unbeaufsichtigte Nachtläufe gebaut, der andere verlangt für jede Mutation eine menschliche Bestätigung.

---

## Anhang: Die Lücken, die dieses Fundament offenlässt

Aus der Querschnittsanalyse ergeben sich die Bereiche, die keines der fünf Repos abdeckt und die im ergänzenden Recherchebericht behandelt werden:

- Knowledge-Graph-Metriken (Zentralität, Community Detection, Hub-/Bridge-Erkennung)
- Automatische MOC-Erzeugung aus Cluster-Analyse
- Spaced Repetition / Anki / Flashcards
- Zitations- und Literaturverwaltung (Zotero, BibTeX, arXiv, Semantic Scholar)
- Vektor-/Embedding-basiertes RAG (statt nur BM25)
- Import/Migration aus Notion, Roam, Logseq, Evernote, Apple Notes
- Audio-/Video-/YouTube-/Meeting-Transkription als Ingest-Quelle
- Daily Notes, Journaling, Periodic Notes, Wochen-/Monatsreviews
- Task-/Projektmanagement (Obsidian Tasks, GTD)
- **Dataview / DataviewJS** (kepano deckt nur Bases ab)
- Templater/QuickAdd sowie Plugin-Entwicklung
- Obsidian Publish, Quartz, Digital Garden
- Git-Versionierung, Sync-Strategien, Backups
- Frontmatter-Schema-Validierung und Property-Normalisierung
- Bulk-Refactoring (Split/Merge, Umbenennen mit Link-Erhalt)
- Deduplizierung und Near-Duplicate-Erkennung
- Entity Extraction / NER mit automatischer Verlinkung
- Datenschutz/Redaktion vor dem Ingest
- Memory-Layer für LLMs (Basic Memory, mem0, Letta)
- Obsidian-MCP-Server als Zugriffsschicht
