# Ergänzende Agent Skills, MCP-Server & Repos für Obsidian / PKM / Second Brain

*Recherchestand: 5. September 2026. Bevorzugt echte Agent Skills (SKILL.md) und MCP-Server; Community-Plugins nur wo sie die einzige Lösung sind. Sterne/Aktivitätsangaben sind, wo möglich, aus Primärquellen verifiziert — Directory-Aggregatoren sind unzuverlässig (siehe Caveats).*

## TL;DR
- Es gibt substanzielle, echte Ergänzungen zu deinen fünf bekannten Repos — am stärksten bei **Knowledge-Graph-Analyse** (obra/knowledge-graph: Louvain, Betweenness, PageRank als CLI+MCP), **Vektor-RAG über Vaults** (proofgeist/obsidian-notes-rag, robbiemu/vault-mcp, drewburchfield/obsidian-graph), **Zitationsverwaltung** (54yyyu/zotero-mcp, Xevos117/mcp-zotero, openags/paper-search-mcp), **Spaced Repetition/Anki** (mehrere MCP), **Memory-Layer** (basicmachines-co/basic-memory) und **Daily/Weekly-Reviews** (ballred/obsidian-claude-pkm).
- Die härtesten Lücken, für die **nichts Brauchbares als echter Skill/MCP** existiert: Notiz-**Deduplizierung** (nur Plugins), reiner **NER→Wikilink-Agent-Skill** (nur MCP-Nebenfeatures/Tag-Plugins), dedizierter **Split/Merge-Bulk-Refactoring-Skill**, **evergreen-notes-Methodik** (Andy-Matuschak-Stil), **Git-Versionierung/Sync** als Skill/MCP, und ein verifizierbares **AKU-7-Skills-Repo**.
- Priorisierung: Für echte Agent-Skills sind **sunnyhasija/obsidian-plugin-skills** (Dataview/Templater/Tasks — genau die kepano-Lücke), **obra/knowledge-graph** und **jykim obsidian-yaml-frontmatter** zentral; für MCP-Infrastruktur der offizielle **Local REST API** (mit eingebautem MCP), **Basic Memory** und die RAG/Graph-Server.

## Key Findings

### Neue echte Agent Skills (SKILL.md / Claude-Code-Plugins)
- **sunnyhasija/obsidian-plugin-skills** (github.com/sunnyhasija/obsidian-plugin-skills) — Claude Skills für **Dataview, Templater und Tasks** als SKILL.md-Dateien (`.claude/skills/dataview/SKILL.md` etc.). Füllt exakt die von dir benannte Dataview-/DataviewJS-Lücke (kepano deckt nur Bases) sowie Templater und Tasks. Format: SKILL.md. Lizenz/Sterne nicht verifiziert.
- **jykim/claude-obsidian-skills → obsidian-yaml-frontmatter** (lobehub.com/skills/jykim-…, skillsmp.com) — SKILL.md zur Frontmatter-Normalisierung/Validierung: Key-Casing/Aliases, Typkoercion (Datum, Boolean, Array), kanonische Datumsformate, schema-getriebene Validierung, Dry-Run-Reports, idempotente Rewrites, Batch-Verarbeitung. Füllt Frontmatter-Schema-Validierung / Property-Normalisierung. Verweist explizit auf begleitenden `obsidian-markdown-structure`-Skill für Dokumentstruktur.
- **goberomsu/claude-plugins → obsidian-frontmatter** (lobehub.com/skills/goberomsu-…) — shell-basierter Frontmatter-Toolkit-Skill (`fm-op`/`fm-bulk`): Bulk set/delete/validate über Glob-Pattern, Array-Append, Format-Erhaltung. Ergänzt Massen-Frontmatter-Migration.
- **tpitsunov/obsidian-skills** (github.com/tpitsunov/obsidian-skills) — agentische Skills im SKILL.md-Format: `/stats` (Vault-Metriken via Python), `/quiz` (szenariobasierte Prüfungsfragen mit Bewertung), `/toc`, `/todoist`, `/heal_links` (Broken-Link-Healer, der über semantischen Kontext Tippfehler/Aliases auflöst). Zero-LLM-Contact-Secret-Model via OS-Keychain (keine `.env`-Dateien). Deckt Teile von MOC/Link-Pflege und Vault-Statistik.
- **gapmiss/obsidian-plugin-skill** (github.com/gapmiss/obsidian-plugin-skill) — SKILL.md (~325 Zeilen + reference/) für **Obsidian-Plugin-Entwicklung**: ESLint-Regeln (eslint-plugin-obsidianmd v0.4.1), Scorecard-Guidance, Accessibility (mandatory), `create-plugin.js`-Scaffolder. Nutzt `.agents/skills/`-Standardpfad. Füllt Plugin-Entwicklung.
- **obra/knowledge-graph** (github.com/obra/knowledge-graph) — Claude-Code-Plugin, CLI (`kg`) UND MCP-Server in einem: parst Vault in untypisierten Graph (Dateien=Knoten, Wikilinks=Kanten), indexiert in SQLite mit Vektor-Embeddings + FTS5. **10 Operationen**: Community-Detection (Louvain), Bridge-Nodes (Betweenness Centrality), zentrale Notes (PageRank), Pfadsuche, N-Hop-Nachbarschaften, semantische + Keyword-Suche. Laut README: „10 operations, exposed as both a CLI (kg) and an MCP server", nutzt graphology für In-Memory-Graphalgorithmen und lokale Embeddings via **Xenova/all-MiniLM-L6-v2 (transformers.js, 22 MB quantisiert, keine Cloud-API)**. Getestet an einem Vault von rund 3.300 Notizen (Autor: Jesse Vincent/„fsck", Blogpost vom 20.03.2026). Füllt Knowledge-Graph-Analyse vollständig — keine Überschneidung mit deinen fünf Repos.
- **ballred/obsidian-claude-pkm** (github.com/ballred/obsidian-claude-pkm) — Claude-Code-Starterkit mit 10 Skills inkl. `/daily`, `/weekly` (30-min-Review mit Project-Rollup), `/monthly` (Roll-up der Weekly Reviews + Quartals-Milestones), `/review` (auto-detect), plus 4 spezialisierte Agents mit Memory. Struktur: `.claude/skills/`, `.claude/agents/`, Hooks. Füllt Daily/Journaling/Periodic Notes/Weekly-Monthly Reviews — reichhaltigster offener GitHub-Fund dieser Kategorie.
- **vanillaflava/tasknotes-skill** (github.com/vanillaflava/tasknotes-skill) — SKILL.md-Agent-Skill für Task-Management, liest/schreibt TaskNotes als Markdown+YAML, funktioniert mit reinem Filesystem-Zugriff (reicher mit TaskNotes-MCP). Zeit-Tracking, Schema-Diagnose. Füllt Tasks/GTD.
- **Kabilan108/dotfiles → obsidian-tasks** (skills.rest/skill/obsidian-tasks) — Skill für Obsidian-Tasks via Dataview inline fields, natürliche Sprache; setzt Obsidian Tasks + Dataview voraus.
- **Xevos117/mcp-zotero enthält einen Claude-Skill** — der MCP-Server bringt einen optionalen Claude-Skill für PDF-Upload-Policy und Zitierstil mit.

### Neue MCP-Server
**Obsidian-Kernzugriff / Refactoring:**
- **coddingtonbear/obsidian-local-rest-api** (github.com/coddingtonbear/obsidian-local-rest-api, **~2,8k★, v3.2.0**) — das offizielle REST-API-Plugin, inzwischen mit **eingebautem MCP-Server**. Laut README: „Several third-party MCP servers for Obsidian exist, but they are no longer necessary — this plugin ships a built-in MCP server that runs inside Obsidian." Transport: Streamable HTTP, Endpoint `/mcp/` auf `https://127.0.0.1:27124/mcp/`, Bearer-Token-Auth. Volle CRUD, section-patching (Heading/Block/Frontmatter), JsonLogic-Suche, Command-Ausführung. **Empfohlene Basis** für alle anderen Server.
- **StevenStavrakis/obsidian-mcp** (github.com/StevenStavrakis/obsidian-mcp, **~670★, TypeScript, v2**) — arbeitet direkt auf Markdown (Obsidian muss nicht offen sein), Node.js 22+, Transaktions-Recovery. **Link-erhaltende Moves** sind das Alleinstellungsmerkmal — laut README: „Moves recognize Obsidian Wikilinks, embeds, Markdown links, aliases, URL-encoded destinations, headings, and block anchors. A link is rewritten only when it resolves unambiguously to the source note; ambiguous links are reported and left unchanged." Füllt Bulk-Refactoring / Umbenennen mit Link-Erhalt.
- **cyanheads/obsidian-mcp-server** — read/write/search/surgical-edit via Local REST API, STDIO oder Streamable HTTP.
- **MarkusPfundstein/mcp-obsidian** — verbreiteter, schlanker Server via Local REST API (list/read/search/patch/append/delete).

**Vektor-/Embedding-RAG (echter Kontrast zu BM25):**
- **proofgeist/obsidian-notes-rag** (auch proofsh, github.com/proofgeist/obsidian-notes-rag) — lokaler Vektorstore in **sqlite-vec** (~200 KB, keine Telemetrie/Netzwerkaufrufe), Embeddings via OpenAI/Ollama/LM Studio (z.B. nomic-embed-text). CLI + MCP: `search`, `similar`, `context`, `watch` (auto-reindex), macOS-launchd-Service. Füllt Vektor-/Embedding-RAG — direkter Kontrast zu AgriciDaniel wiki-retrieve (BM25+Nomic-Rerank).
- **robbiemu/vault-mcp** — RAG über Obsidian + Joplin + beliebige Markdown-Sammlungen, Live-Sync, quality-based chunking, dualer API-+MCP-Betrieb.
- **Zackriya-Solutions/MCP-Markdown-RAG** — semantische Suche über Markdown, lokal-first, Heading-basiertes Chunking, `index_documents`/`search`.
- **drewburchfield/obsidian-graph** — semantischer Knowledge Graph mit **Voyage Context-4-Embeddings + PostgreSQL/pgvector**; `get_hub_notes` (min. 10 Verbindungen → MOC-Kandidaten), `get_orphaned_notes` (isolierte Notizen). Überbrückt Graph-Analyse und MOC-Generierung.

**Memory-Layer:**
- **basicmachines-co/basic-memory** (github.com/basicmachines-co/basic-memory, **~3,7k★**, MCP-Registry `io.github.basicmachines-co/basic-memory`) — führender Memory-Layer: „Knowledge management system that builds a persistent semantic graph in markdown, locally." Bidirektional (LLM und Mensch schreiben dieselben Dateien), Obsidian-nativ (Graph View/Backlinks), lokales SQLite-Index als source-of-truth-Ergänzung. MCP-Tools u.a. `write_note`, `search_notes`, `build_context`. Cloud-Variante $15/Monat. Apache/MIT-nah, self-hostbar. Füllt Memory-Layer.
- **obsidian-memory-mcp** — speichert AI-Memories als Markdown mit Entity/Relation/Observation für Obsidian-Graph-Visualisierung.
- Generische Alternativen (nicht Obsidian-spezifisch): **mem0** (passiver Memory-Layer), **Letta/MemGPT** (self-editing tiered memory, Apache 2.0), **Zep/Graphiti** (temporale Knowledge Graphs).

**Zettelkasten:**
- **zettelkasten-mcp** (mcp.so/server/zettelkasten-mcp, MIT) — implementiert Zettelkasten-Methode mit SQLite-Backing, atomare Notizen erzeugen/verlinken/abfragen.
- **Shepherd-Creative/obsidian-mcp** — Zettelkasten-optimierter MCP (12 Tools) via Local REST API, CREATE-Modus überschreibt nichts, Frontmatter-/Tag-Management.

**Zitations-/Literaturverwaltung:**
- **54yyyu/zotero-mcp** (github.com/54yyyu/zotero-mcp, **~3,3k★**, PyPI `zotero-mcp-server`) — Zotero 7/8, Add-Tools `zotero_add_by_doi/url/isbn/bibtex/csl_json`, Semantic-Scholar-/OpenAlex-/CrossRef-Integration, PDF, BibTeX-Import/Export. Laut README: „Retraction alerts: Scan your library for retracted or corrected papers — No Scite account required — uses public API endpoints." (Die „52 Tools"-Angabe stammt aus Directory-Snippets, im README nicht verifizierbar.) Füllt Zitations-/Literaturverwaltung.
- **Xevos117/mcp-zotero** — 15 Tools, DOI-Import, PDF-Fulltext-Indexierung, Open-Access-PDF via Unpaywall, **Citation-Injection direkt in .docx** (native Zotero-Feldcodes), inkl. optionalem Claude-Skill.
- **cookjohn/zotero-mcp** — Zotero-Plugin + MCP-Server (Streamable HTTP), Volltext-Analyse, mehrsprachig.
- **openags/paper-search-mcp** (github.com/openags/paper-search-mcp) — MCP + CLI + Skills, Suche/Download über arXiv, PubMed, bioRxiv, medRxiv, Semantic Scholar, CrossRef, OpenAlex, PMC, CORE, dblp u.v.m. Füllt Paper-Ingest.
- **arxiv-mcp-server** (Docker `mcp/arxiv-mcp-server`; r-uben-Variante mit GROBID + Mistral-OCR für PDF-Extraktion) — arXiv-Suche + PDF→Markdown-Konvertierung.

**Spaced Repetition / Anki (komplett neue Kategorie, keine Überschneidung):**
- **ankimcp/anki-mcp-server** (github.com/ankimcp/anki-mcp-server) — via AnkiConnect, lokal, keine Telemetrie; Review, Batch-Create (bis 100 Notizen), Note-Types/Templates/CSS.
- **nailuoGG/anki-mcp**, **scorzeth/anki-mcp**, **@arielbk/anki-mcp** (npm), **johwiebe/anki-mcp** — weitere Anki-MCP mit FSRS-Support, Cloze-Generierung, PDF→Karten. Über 26 Anki-MCP im Umlauf (MCP Market).

**Task-/Projektmanagement:**
- **jfim/obsidian-tasks-mcp** (github.com/jfim/obsidian-tasks-mcp, npm `@jfim/obsidian-tasks-mcp`) — extrahiert/abfragt **Obsidian-Tasks-Plugin-Tasks** aus Markdown; unterstützt Emoji-Format UND Dataview-Format.
- **aleksakarac/obsidian-mcp** — 45 Tools, `search_tasks` (status/priority/due), `create_task`, `execute_dataview_query` (DQL), Kanban-Board-Parsing/Card-Moves. Erweitert StevenStavrakis.
- **jarero321/mcp-obsidian-planner** (glama.ai/mcp/servers/nhzzfom5qd) — 17 Tools (TypeScript/NestJS): Daily Notes mit Top-3-Focus, Inbox, Tasks, Projects, **Weekly Reviews mit Completion-Rate**, GTD+PARA, Templater/Dataview-kompatibel. Überbrückt Tasks und Reviews.

**Audio/Video/YouTube-Ingest (neue Kategorie):**
- **artsamsonov/transcriptor-mcp** (Docker `artsamsonov/transcriptor-mcp`) — yt-dlp + Whisper-Fallback, unterstützt YouTube, X, Instagram, TikTok, Twitch, Vimeo u.a., stdio/HTTP/SSE, Pagination.
- **jackhp/mcp-youtube-transcribe** (lobehub.com/mcp/jackhp-…) — offizielle Transkripte bevorzugt, sonst whisper.cpp/Whisper-Fallback.
- **Media Ingest** (Claude Code Skill, mcpmarket.com/tools/skills/media-ingest) — YouTube-Metadaten + Podcast-RSS mit lokalem Whisper + Granola-Meeting-Notizen → Obsidian mit YAML-Frontmatter.
- **YouTube Transcript to Obsidian** (Claude Code Skill) — yt-dlp → timestamped Markdown mit Obsidian-Callouts.

**Datenschutz/Redaktion (nicht Obsidian-spezifisch, vor Ingest vorschaltbar):**
- **r3352/redact-mcp** (github.com/r3352/redact-mcp, npm `@mattzam/redact-mcp`) — MCP-Server UND Claude-Code-Plugin; erkennt/obfusziert sensible Daten bevor Claude sie sieht: Regex + **lokale KI-NER** (~110 MB Modell), erkennt IPs, Hostnames, E-Mails, API-Keys, Telefonnummern. Bidirektionales Mapping, Audit-Log, Hooks (Leak-Detection), Slash-Commands. Vollständig lokal.
- **cmalpass/mcp-presidio** — MCP auf Basis Microsoft Presidio, PII aus Text/Bildern, Custom-Recognizer, Anonymisierungsstrategien, F1-Validierung. Voll lokal/Open-Source.
- **gbrigandi/mcp-server-conceal** — Rust-Privacy-Proxy, Echtzeit-Pseudonymisierung mit konsistentem Mapping (statt Redaction), erhält semantische Relationen.

**Multi-Agent-Orchestrierung:**
- **tuan3w/obsidian-vault-agent** (github.com/tuan3w/obsidian-vault-agent) — Claude-Code-Plugin (`claude plugin marketplace add tuan3w/obsidian-vault-agent`): `/research` (zerlegt in Sub-Queries, Web+Vault parallel, Lückenerkennung), `/deep-research` (4 Quelltypen parallel: Web/Academic/Reddit/Vault, Exploration↔Critique-Loops, Citations + Confidence-Map), `/course`. Füllt Multi-Agent-Orchestrierung / Recherche-Subagenten.

### Community-Plugins, wo sie die einzige Lösung sind
- **Knowledge-Graph-Analyse:** *Graph Analysis* (Link-Prediction, Hub/Authority, Centrality, Louvain/Label-Propagation-Community-Detection), *Knowledge Graph Analysis* (Hubs/Bridges/Authorities, Network-Metrics-Scatterplots, KI-gestützte Connection-Suggestions), *Graph Metrics* (Hub Analysis via PageRank, BRAT). **InfraNodus** für externe Visualisierung + Text-Network-Analyse (Betweenness, topische Cluster).
- **RAG im Plugin:** *Analogy – RAG in your vault* (lokale ChromaDB-Embeddings + eingebauter MCP-Server, Semantic Walk).
- **Frontmatter/Schema:** *Frontmatter Operator* (Bulk-Edit + LLM-Generierung, OKF-Migration), *Propsec* (Schema-Validierung mit Cross-Field-Constraints, non-destruktiv), *obsidian-typechecker* (Typvalidierung gegen `.obsidian/types.json`).
- **Paper-Import + PDF-Annotation:** *arXiv Papers* (arXiv-API + OpenAlex-Fallback), *PaperFlow* (arXiv-ID/URL/lokale PDFs → Notizen + PDF++-Highlights + KI-Summaries), *Obsidian PDF Evidence MCP* (PDF-Content für Agents).
- **Highlights-Import:** *Readwise Official* — Kindle, Apple Books, Instapaper, Pocket, Medium, Twitter, PDFs, Hypothes.is (via Readwise). Jinja2-Templating, kontinuierlicher Sync. Deckt Readwise/Kindle/Instapaper/Pocket/Hypothes.is auf einen Schlag.
- **Migration/Import:** *Obsidian Importer* (offiziell: Notion, Evernote, Apple Notes, OneNote, Google Keep, Roam via HTML/JSON). CLIs: `bitbonsai/notion2obsidian` (High-Performance, npm), `LogSeqToObsidian` (`convert_notes.py`).
- **Transkription:** *Obsidian Transcription* (lokaler Whisper-ASR für Audio/Video mit Timestamps), *YouTube transcript fetcher*, *YTranscript*.
- **Deduplizierung:** *Document Merge and Dedupe* (exakte Duplikate + überlappende Absätze, Verifikationsreport), *Duplicate Detector* (zeilenbasiert). Kein Skill/MCP verfügbar.
- **Git/Sync:** *Obsidian Git* (Community-Plugin) als Standard — kein verifizierter Skill/MCP gefunden.
- **Spaced Repetition nativ:** *Spaced Repetition*-Plugin (für Andy-Matuschak-Stil-mnemonic-medium in Obsidian).

## Details: Zuordnung zu deinen Lücken

**Zettelkasten/atomare Notizen/evergreen:** zettelkasten-mcp und Shepherd-Creative/obsidian-mcp sind Zettelkasten-optimierte MCP-Tools (atomare Notizen, Linking). Überschneidung mit AgriciDaniel (wiki-mode Zettelkasten), aber als MCP-Tools statt Skills. **Kein dedizierter „evergreen notes/Andy-Matuschak-Stil"-Skill gefunden** — Lücke bleibt teilweise offen (nur konzeptuelle Blogs von Matuschak/Appleton).

**Knowledge-Graph-Analyse:** obra/knowledge-graph ist der stärkste, klar überlegene Fund (Louvain/Betweenness/PageRank, lokal, als CLI+MCP+Plugin). Keine Überschneidung mit deinen fünf Repos — starmynd hat typisierte Kanten, aber keine Graph-Metriken. Ergänzend Plugins + InfraNodus.

**MOC automatisch:** *vault-moc* und *Obsidian MOC Creator* (Claude Code Skills auf mcpmarket) sowie drewburchfield `get_hub_notes`. Überschneidung mit AgriciDaniel wiki-fold, unterscheidet sich durch reine MOC-Generierung aus Cluster-Analyse.

**Spaced Repetition/Anki:** Mehrere Anki-MCP — komplett neue Kategorie, keine Überschneidung.

**Zitation/Literatur:** 54yyyu, Xevos117, cookjohn, openags/paper-search-mcp, arxiv-mcp-server — neue Kategorie, keine Überschneidung.

**Vektor-RAG:** proofgeist, robbiemu/vault-mcp, drewburchfield, Zackriya — echter Vektor-Embedding-Kontrast zu AgriciDaniels BM25+Rerank.

**Import/Migration:** Obsidian Importer, notion2obsidian, LogSeqToObsidian — nur CLIs/Plugins, kein Agent-Skill.

**Audio/Video/YouTube:** transcriptor-mcp, mcp-youtube-transcribe, Media Ingest Skill, Obsidian Transcription — neue Kategorie.

**Daily/Journaling/Reviews:** ballred/obsidian-claude-pkm (Skills), jarero321 (MCP) — neue Kategorie.

**Tasks/GTD:** vanillaflava, Kabilan108 (Skills); jfim, aleksakarac (MCP) — neue Kategorie.

**Dataview:** sunnyhasija/obsidian-plugin-skills — genau die kepano-Lücke.

**Templater/QuickAdd/Plugin-Dev:** sunnyhasija (Templater), gapmiss (Plugin-Dev).

**Publish/Quartz/Digital Garden:** Quartz (jackyzha0), awesome-quartz — kein Agent-Skill, nur SSG.

**Git/Sync/Backup:** Nur Obsidian Git Community-Plugin — kein Skill/MCP verifiziert (Budgeterschöpfung).

**Ontologie/Schema/Frontmatter:** jykim, goberomsu (Skills); Frontmatter Operator, Propsec, obsidian-typechecker (Plugins).

**Bulk-Refactoring:** StevenStavrakis/obsidian-mcp (link-erhaltende Moves) — kein dedizierter Split/Merge-Skill.

**Deduplizierung:** Nur Plugins (Document Merge and Dedupe) — Lücke bleibt offen.

**Entity Extraction/NER→Wikilink:** newtype-01/obsidian-mcp (Auto-Backlink-Feature: „intelligent detection and conversion of note names to wikilinks"), akosbalasko/obsidian-autotagger-plugin (echtes NER via „Compromise"-NLP → aber Tags, keine Wikilinks). Kein reiner NER→Wikilink-Skill.

**Datenschutz/Redaktion:** r3352/redact-mcp, cmalpass/mcp-presidio, mcp-server-conceal — nicht Obsidian-spezifisch, aber vorschaltbar.

**Memory-Layer:** Basic Memory (führend), obsidian-memory-mcp, mem0/Letta/Zep (generisch) — neue Kategorie.

**Schreiben/Publizieren aus Vault:** content-research-writer und tapestry (awesome-claude-skills) — Überschneidung mit iusztinpaul research-render.

## Lücken ohne brauchbaren Fund (genauso wertvoll wie die Funde)
1. **Notiz-Deduplizierung / Near-Duplicate** als Skill/MCP — nur Community-Plugins (Document Merge and Dedupe).
2. **Reiner NER→Wikilink Agent-Skill** — nur MCP-Nebenfeatures (newtype-01 Auto-Backlink) und Tag-orientierte Plugins (autotagger).
3. **Dedizierter Split/Merge-Bulk-Refactoring-Skill** — nur link-erhaltende Moves (StevenStavrakis), kein Notiz-Aufteilen/Zusammenführen.
4. **Evergreen-Notes-Methodik (Andy-Matuschak-Stil)** als Skill — nur konzeptuelle Blogartikel und Spaced-Repetition-Plugin.
5. **Git-Versionierung/Sync/Konfliktauflösung** als Skill/MCP — nicht verifiziert (nur Obsidian Git Plugin).
6. **Verifizierbares AKU-7-Skills-Repo** (obsidian-mcp, inbox-triage, connection-review, weekly-synthesis, context-maintenance, vault-health-feedback, note-promotion) — als GitHub-Topic-Snippet bestätigt existent, aber exakter Owner/Repo-Name blieb trotz gezielter Suche unauflösbar. Der AKU-Begriff stammt aus dem Paper „Knowledge Activation: AI Skills as the Institutional Knowledge Primitive" (Gal Bakal).

## Recommendations
1. **Sofort installieren (echte Skills, größte Lücken):** `sunnyhasija/obsidian-plugin-skills` (Dataview/Templater/Tasks — schließt die kepano-Dataview-Lücke direkt), `obra/knowledge-graph` (Graph-Analyse, lokal, keine Cloud), `jykim obsidian-yaml-frontmatter` (Schema-Validierung/Normalisierung).
2. **MCP-Infrastruktur aufsetzen:** `coddingtonbear/obsidian-local-rest-api` (offiziell, eingebauter MCP über `/mcp/`) als Basis; darauf `StevenStavrakis/obsidian-mcp` für link-erhaltendes Refactoring; `basicmachines-co/basic-memory` als Memory-Layer, der denselben Vault teilt.
3. **Für RAG:** `proofgeist/obsidian-notes-rag` (lokal via Ollama/sqlite-vec) ergänzend oder statt BM25 in AgriciDaniel — echte Vektor-Semantik.
4. **Für Recherche-/Lernzyklen:** `54yyyu/zotero-mcp` + `openags/paper-search-mcp` + ein Anki-MCP (`ankimcp/anki-mcp-server`) für den durchgehenden Literatur→Karteikarten-Zyklus; `tuan3w/obsidian-vault-agent` für Multi-Agent-Recherche.
5. **Selbst bauen (größter Eigenbau-Wert, da nichts existiert):** Dedupe-Skill, NER→Wikilink-Skill, evergreen-notes-Methodik-Skill, Git-Sync-Skill. Diese vier sind echte Whitespaces im Ökosystem.
6. **Umentscheidungs-Schwellen:** (a) Falls ein verifiziertes AKU-Repo mit den 7 Skills auftaucht (GitHub-Codesuche nach `"connection-review" "note-promotion" "vault-health-feedback"`), dieses statt Eigenbau der Orchestrierung übernehmen. (b) Falls `redact-mcp`/`mcp-presidio` in Produktion stabil laufen, PII-Redaction als Pflicht-Vorstufe vor jedem externen Ingest verdrahten. (c) Sobald ein dedizierter Dedupe-MCP erscheint, den Eigenbau-Skill ablösen.

## Caveats
- **Sternangaben aus Directory-Aggregatoren sind unzuverlässig und vermischen Repos.** Beispiel kepano/obsidian-skills: SkillsLLM meldet 19.127★, EveryDev 32.974★ — tatsächlich laut GitHub-Profil/claudeskills.info aktuell rund **47,9k★, 3,4k Forks, 5 Skills, ~360.800 Installs**. Alle hier genannten Aggregator-Zahlen bitte vor Entscheidungen direkt auf GitHub prüfen.
- `mcpmarket.com`- und `lobehub.com/skills`-Einträge sind teils Marketplace-Listings ohne direkt sichtbares GitHub-Repo — Reifegrad/Lizenz schwer beurteilbar.
- Viele MCP-Server und Skills sind früh/experimentell. Bei Vault-**Schreibzugriff** besteht Prompt-Injection-Risiko (bösartige Notizinhalte können Agentenaktionen auslösen) — vor Installation Quellcode prüfen, Backups anlegen, Recovery-fähige Server (StevenStavrakis v2) bevorzugen.
- Die „52 Tools"-Angabe zu 54yyyu/zotero-mcp und die „45 Tools" zu aleksakarac stammen aus Snippets bzw. READMEs und wurden nicht vollständig gegenverifiziert.
- Die Kategorien **Git/Sync/Backup** und die drei zuletzt geplanten Suchen (NER, Dedupe, Git) konnten wegen Erschöpfung des Such-Budgets nur über den Subagenten bzw. gar nicht abschließend recherchiert werden — hier ist die Abdeckung dünner als bei den übrigen Kategorien.
- Das AKU-7-Skills-Repo (Lücke 6) existiert nachweislich als Muster, sein exakter Owner/Name ist aber unbestätigt; behandle es als Hinweis, nicht als gesicherten Fund.