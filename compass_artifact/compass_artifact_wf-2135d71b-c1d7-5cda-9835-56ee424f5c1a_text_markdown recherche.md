# MCP-Server & Claude Skills für die philosophische Forschung an deutschen Hochschulen

## TL;DR
- **MCP-Server**: Für die Metadaten- und Literaturrecherche gibt es ausgereifte, kostenlose Open-Source-MCP-Server (OpenAlex, Semantic Scholar, arXiv, Crossref, Zotero); für Philosophie-Spezifika (PhilPapers/PhilArchive, Deutsches Textarchiv, Perseus) gibt es teils fertige Server, teils nur offene APIs (OAI-PMH, CTS, SRU), aus denen man selbst einen Server bauen kann.
- **Google Scholar** hat keine offizielle API; alle „Google-Scholar-MCP" beruhen auf Scraping (ToS-Verstoß, IP-Blocks, CAPTCHAs) oder kostenpflichtigen Diensten (SerpAPI/Apify). Als freie Alternative dienen OpenAlex + Semantic Scholar + Crossref + CORE.
- **Skills**: Anthropic liefert produktionsreife Dokument-Skills (docx, pdf, pptx, xlsx); für den Wissenschaftsworkflow existieren Community-Skill-Suiten (z. B. `academic-research-skills`). Den deutschen Rechts-/Verfahrensrahmen (DFG-Kodex, DEAL, Citavi-Ausstieg, Promotions-Publikationspflicht, KI-Kennzeichnung) muss man in selbst gebauten Skills abbilden.

## Key Findings
1. Die stabilste, vollständig kostenlose Basis sind **OpenAlex** (derzeit keine Kosten, nur E-Mail für den „polite pool"), **Semantic Scholar** (freier Key, höhere Rate Limits), **arXiv** (offene API) und **Crossref** (kein Key, mailto empfohlen). Für alle existieren mehrere gepflegte MCP-Server. **Wichtige Änderung**: OpenAlex hat laut einem Data-Quality-Audit von Pebblous (23.07.2026) am 13.02.2026 angekündigt, dass API-Keys verpflichtend werden und die Preise auf nutzungsbasierte Stufen umgestellt werden — der bisher key-freie Zugang läuft also aus (Stand vor Nutzung prüfen).
2. **Zotero-MCP** ist der zentrale Workflow-Baustein: lokale Bibliothek (Local API) oder Zotero Web API, PDF-Volltext, Zitationsexport — mehrere reife Server (`54yyyu/zotero-mcp`, `kujenga/zotero-mcp`).
3. **Philosophie-spezifisch**: PhilPapers/PhilArchive bietet eine freie OAI-PMH-Schnittstelle (nur Open-Access-Metadaten/Volltexte); dafür gibt es sogar einen fertigen Server (`sea9401/philosophy-mcp`). Deutsches Textarchiv (OAI-PMH + TEI-Download, CC BY-SA) und Perseus (CTS-API) sind ideale Bausteine für selbstgebaute Server.
4. **Paywall/keine API**: JSTOR, Project MUSE, De Gruyter, TLG, Loeb, Philosopher's Index — hier gibt es keine freien MCP-Server; Zugang nur über Uni-Lizenz (Shibboleth/DFN-AAI).
5. **Deutscher Kontext**: Citavi-Campuslizenzen laufen bundesweit aus (Wechsel zu Zotero); DEAL-Verträge (Wiley/Springer Nature/Elsevier) bis Ende 2028; DFG-Kodex verbindlich; KI muss gekennzeichnet werden und kann keine Autorschaft tragen; Dissertations-Publikationspflicht mit Pflichtexemplaren und DNB-Ablieferung.

## Details

### TEIL 1 — MCP-Server für die akademische Recherche

**Grundlegende Einordnung (Aktualität):** Das MCP-Ökosystem verändert sich sehr schnell; viele Server sind Ein-Personen-Projekte ohne Wartungsgarantie. Prüfe vor Installation immer das letzte Commit-Datum, offene Issues und ob ein Paket auf PyPI/npm sauber gepflegt wird. Bevorzuge Server, die über `uvx`/`npx` direkt ausführbar sind.

#### A. Metadaten & Literaturrecherche (offen, kostenlos)

**OpenAlex** — vollständig offener Katalog; das OpenAlex Help Center nennt „over 320 million works … with tens of thousands added every day", die TU-Hamburg-Bibliothek (Feb. 2026) sogar „474+ million works". Derzeit keine API-Kosten und (noch) kein Pflicht-Key; für den schnelleren „polite pool" gibt man eine E-Mail (`OPENALEX_EMAIL`) an. **Achtung**: Ab 2026 werden API-Keys verpflichtend und die Nutzung wird in Preisstufen überführt (Ankündigung 13.02.2026) — das kann die „vollständig kostenlos"-Einordnung ändern; vor produktiver Nutzung den aktuellen Stand prüfen. MCP-Server u. a.:
- `oksure/openalex-research-mcp` (auch als Claude Skill gebündelt)
- `cyanheads/openalex-mcp-server` (STDIO & HTTP)
- `drAbreu/alex-mcp` (Autor-Disambiguierung)

Einschränkung: OpenAlex speichert überwiegend keine Volltexte (Copyright), sondern Metadaten + Abstracts + OA-Links. Für Philosophie besonders wertvoll, weil breit interdisziplinär und ohne den STEM-Bias einer reinen arXiv/PubMed-Lösung.

**Semantic Scholar (S2)** — großer Korpus (offizielle „Papers"-Abfragen ergaben zuletzt „the set of 206M papers"). Nutzung ohne Key möglich, aber mit strengen Rate Limits; ein kostenloser API-Key erhöht die Limits (Antrag über semanticscholar.org/product/api). MCP-Server:
- `zongmin-yu/semantic-scholar-fastmcp-mcp-server` (16 Tools, an offizieller API ausgerichtet)
- `smaniches/semantic-scholar-mcp` (via `uvx s2-mcp-server`)

Einschränkung: Abdeckung in den Geisteswissenschaften geringer als in STEM; als Ergänzung, nicht als alleinige Quelle.

**arXiv** — offene API, kein Key. Für Philosophie nur begrenzt relevant (v. a. Logik, Philosophy of Physics, formale Erkenntnistheorie unter math.LO/physics.hist-ph). Reifer Server: `blazickjp/arxiv-mcp-server` (auf offiziellem MCP-Registry, PyPI `arxiv-mcp-server`); Achtung: gleichnamiges npm-Paket ist ein anderes Projekt.

**Crossref** — laut Crossref-Blog enthielt die Datenbank am 14.03.2026 „180.034.490 metadata records"; kein Key nötig, mailto für den „polite pool" empfohlen. MCP-Server: `JackKuo666/Crossref-MCP-Server`. Ideal für DOI-Auflösung und Metadaten-Anreicherung.

**Multi-Source-Server** (bündeln viele Quellen in einem Server):
- `openags/paper-search-mcp` — „free-first"-Strategie, deckt arXiv, PubMed, bioRxiv, Semantic Scholar, Crossref, OpenAlex, CORE, Europe PMC, DOAJ, BASE, Zenodo, HAL, Unpaywall u. a. ab; optionale Keys. Enthält auch einen Sci-Hub-Workflow — den aus rechtlichen Gründen deaktiviert lassen (siehe Caveats).
- `LinXueyuanStdio/academic-mcp`

#### B. Open-Access-Volltexte

**CORE.ac.uk** — laut core.ac.uk „the world's largest index of open access research literature serving over 400 million records and enabling machine access to over 40 million full text documents." Freier API-Key erforderlich (über core.ac.uk registrieren). In `paper-search-mcp` als Connector integriert (`PAPER_SEARCH_MCP_CORE_API_KEY`).

**Unpaywall** — findet legale OA-Versionen per DOI. Kein Key, nur E-Mail-Angabe. MCP-Server: `ElliotPadfield/unpaywall-mcp` (inkl. PDF-Textextraktion). Sehr nützlich, um zu prüfen, ob ein Paywall-Artikel legal frei verfügbar ist.

**OpenAIRE / BASE / DOAJ** — offene APIs; in Multi-Source-Servern (paper-search-mcp) enthalten. BASE (Bielefeld Academic Search Engine) hat eine eigene API (Registrierung/IP-Freischaltung nötig).

#### C. Google Scholar — Sonderfall (wichtig)

Google Scholar hat **keine offizielle API**. Es existieren zahlreiche „Google-Scholar-MCP", aber alle beruhen auf einem von zwei Wegen:
1. **Scraping** (z. B. via `scholarly`-Bibliothek oder Playwright; z. B. `rnkarmakar/scholar-mcp`, docxmxm-Server). Das verstößt gegen die Google-ToS und führt schnell zu IP-Blocks und CAPTCHAs; für seriöse, reproduzierbare Forschung ungeeignet.
2. **Kostenpflichtige Dienste**: SerpAPI oder Apify-Actors (Apify hostet mehrere Google-Scholar-Scraper als MCP, teils „pay per result", ~0,50 USD/1000). Stabiler, aber nicht kostenlos.

**Empfehlung**: Google Scholar nicht als MCP betreiben. Die Kombination OpenAlex + Semantic Scholar + Crossref + CORE deckt die Abdeckung von Scholar weitgehend legal und kostenlos ab. Scholar selbst weiter manuell im Browser nutzen.

#### D. Zotero (zentral für den Workflow)

Zotero ist der Dreh- und Angelpunkt. Zwei Zugangswege:
- **Lokale API** (Zotero-App, „Allow other applications…" bzw. Local API aktivieren) — Daten bleiben lokal.
- **Zotero Web API** (API-Key + Library-ID unter zotero.org/settings/keys) — auch für Gruppenbibliotheken.

Reife Server:
- `54yyyu/zotero-mcp` — sehr umfangreich (`zotero-mcp setup` konfiguriert Claude Desktop automatisch; semantische Suche optional; PyPI `zotero-mcp-server`).
- `kujenga/zotero-mcp` — Python, `uvx zotero-mcp`, Web-API oder lokal, Docker verfügbar.
- `Xevos117/mcp-zotero` — 15 Tools inkl. Zitations-Injektion in .docx, OA-PDF-Discovery via Unpaywall.
- `masaki39/zotero-mcp` — schlank, lokale API + PDF-Volltextextraktion.

#### E. Notizen & Wissensmanagement (MCP)

- **Obsidian** (kein offizieller Server, mehrere Community-Server): `MarkusPfundstein/mcp-obsidian` (über das Community-Plugin „Local REST API"), `StevenStavrakis/obsidian-mcp`, `Piotr1215/mcp-obsidian` (direkter Vault-Dateizugriff). Alle Open Source. Besonders passend für die Zettelkasten-Methode.
- **Notion**: offizieller `makenotion/notion-mcp-server` (Open Source, benötigt Integrations-Token; Read-only-Modus möglich).
- **Paperless-ngx** (Dokumenten-/PDF-Archiv): `nloui/paperless-mcp` (npx), `cubinet-code/paperless-ngx-mcp` (ISC). Erfordern eigene Paperless-ngx-Instanz + Token.

#### F. PDF-Lesen & -Extraktion

- Anthropics **pdf-Skill** (siehe Teil 2) deckt Textextraktion, Merge/Split, Formulare, OCR ab.
- Die meisten Zotero-MCP-Server extrahieren PDF-Volltext direkt aus Anhängen.
- Für reine Dateisystem-PDFs: Filesystem-MCP + pdf-Skill oder `unpaywall-mcp` (PDF-Text).

#### G. Philosophie-spezifische Quellen

**PhilPapers / PhilArchive** — freie **OAI-PMH-Schnittstelle** v2.0 unter `https://philarchive.org/oai.pl`. Wichtig: Nur Open-Access-/nutzereingereichte Inhalte sind über OAI verfügbar; die kostenpflichtige PhilPapers-Indexierung (Universitätsabo, u. a. Philosopher's Index) ist **nicht** über OAI abrufbar. ToS beachten (keine Massenredistribution). Fertiger Server: `sea9401/philosophy-mcp` (keyless; zieht laut Beschreibung PhilPapers/PhilArchive, OpenAlex, Project Gutenberg und SEP ein; MIT; Wartungsstand vor Produktivnutzung prüfen).

**Stanford Encyclopedia of Philosophy (SEP)** — Open Access, aber **keine offizielle API** und kein offizieller Datendump. Es existieren inoffizielle Datensätze (HuggingFace `AiresPucrs/stanford-encyclopedia-philosophy`) und eine inoffizielle `sep-api` (writeonlycode). Für einen MCP-Server bliebe nur ein (inoffizieller) Dump oder Scraping.

**Internet Encyclopedia of Philosophy (IEP)** — peer-reviewed, Open Access, aber **keine API**, nur Website-Suche. Hinweis: IEP nimmt ausdrücklich keine KI-generierten Artikel an.

**Antike Primärquellen**:
- **Perseus Digital Library** — offene **CTS-API** (Canonical Text Services) + XML/TEI, Open Source (Scaife Viewer). Ideal für griechische/lateinische Primärtexte; guter Kandidat für einen selbstgebauten MCP-Server.
- **Thesaurus Linguae Graecae (TLG)** — überwiegend paywalled (Abo); kostenlose „Abridged"-Version nach Registrierung. Keine offene API.
- **Loeb Classical Library** — paywalled (Abo, De Gruyter/HUP). Keine API (275 gemeinfreie Alt-Bände separat frei).

**Deutschsprachige Primärtexte**:
- **Deutsches Textarchiv (DTA, BBAW)** — Volltexte frei als XML/TEI, HTML, Text herunterladbar; Metadaten per **OAI-PMH** harvestbar; Gesamtkorpus-Download (`deutschestextarchiv.de/download`, API unter `/api`); Lizenz CC BY-SA 4.0 (Kernkorpus). Beste offene Basis für einen deutschen Primärtext-MCP.
- **Zeno.org** — kostenlos lesbar, aber **keine API** und restriktive Lizenz (nur privater, nichtkommerzieller Gebrauch).
- **Projekt Gutenberg-DE** — kostenlos lesbar, aber **keine API**, nur privater Gebrauch (nicht zu verwechseln mit gutenberg.org, das Bulk-Downloads mit klarer Lizenz bietet).

**Digitale Philosophen-Editionen**:
- **Nietzsche Source** (eKGWB, Colli/Montinari) — offene digitale Edition, XML-TEI-kodiert, stabile zitierfähige URLs (`nietzschesource.org/eKGWB/...`), aber TEI-Quelldateien nicht öffentlich als Bulk, keine API.
- **Kant — Bonner Kant-Korpus / Akademieausgabe** (IKP Uni Bonn, korpora.org) — frei lesbar; Datenpaket bei LINDAT/CLARIN (`hdl.handle.net/11372/LRT-1122`); keine echte API; korpora.org derzeit wegen eines Cyber-Angriffs auf die Uni Duisburg-Essen eingeschränkt.
- **Wittgenstein Archives Bergen (WAB)** — offene Editionen (Wittgenstein Source, wittgensteinonline.no); TEI-XML-Transkriptionen über das CLARINO Bergen Repository als Download; keine Live-API.
- **Hegel** — keine einheitliche offene Edition mit API gefunden; Einzelwerke über DTA/Zeno/Gutenberg.

**FID Philosophie / philportal.de** — DFG-geförderte Discovery-Plattform (Universitäts- und Stadtbibliothek Köln, Thomas-Institut, CCeH). Der „PhilFinder" (per philportal.de: „Mit dem PhilFinder lassen sich über 32.000 verknüpfte philosophische Wissensobjekte entdecken – von ausführlichen Autor:innenprofilen … bis hin zu Volltexten und Datenprovenienzen.") bündelt u. a. Philosopher's Index, Philosophy Documentation Center, PhilArchive, JSTOR und Verbundkataloge (500+ Zeitschriften im Volltext). Freie Suche ohne Anmeldung (KUG, BVB, OLC, JSTOR u. a.); Premium (z. B. DGPhil-Mitglieder) erweitert um den Philosopher's Index. **Keine öffentliche API** dokumentiert.

#### H. Bibliothekskataloge im deutschsprachigen Raum (offene APIs → selbst als MCP baubar)

- **DNB (Deutsche Nationalbibliothek)** — **SRU-Schnittstelle** (`https://services.dnb.de/sru/dnb`), CQL-Abfragen, XML (MARC21-xml/Dublin Core), SRU 1.1. Kostenlos; Einwilligung gilt nur solange keine Lastprobleme entstehen. Auch OAI für größere Bestände. Referenz-Tool: `deutsche-nationalbibliothek/SRUQueryTool`.
- **K10plus** (GBV/BSZ-Verbund) — **SRU** unter `https://sru.k10plus.de/opac-de-627` bzw. `/gvk`, CQL (pica-Indizes), XML. Kostenlos.
- **BASE** — API (Registrierung nötig).
- **Karlsruher Virtueller Katalog (KVK)**, **WorldCat/OCLC** — WorldCat hat APIs, aber überwiegend kostenpflichtig/institutionell; KVK ist eine Meta-Suche ohne offene Endnutzer-API.

Für all diese gibt es keine fertigen Philosophie-MCP-Server, aber die offenen SRU/OAI-Schnittstellen lassen sich mit dem `mcp`/FastMCP-SDK in wenigen Stunden zu einem eigenen Server verpacken. Es existiert ein generischer SRU-Katalog-Harvester (Apify), der DNB, LoC, K10plus u. a. per CQL abfragt.

**PubMed / Europe PMC** — für Philosophie wenig relevant (Ausnahme: Medizinethik, Philosophy of Mind/Neurophilosophie). Offene APIs (E-utilities, Europe PMC REST); in Multi-Source-Servern enthalten.

### TEIL 2 — Skills & Workflows für den wissenschaftlichen Arbeitsprozess

#### Öffentlich verfügbare Skills (Stand 2025/2026)

**Anthropic offiziell** (`anthropics/skills`): Die **Dokument-Skills** docx, pdf, pptx, xlsx sind produktionsreif (source-available, nicht Open Source; die übrigen Beispiele Apache-2.0). Installation als Claude-Code-Plugin: `/plugin marketplace add anthropics/skills`, dann `/plugin install document-skills@anthropic-agent-skills`. Enthält außerdem `skill-creator` (zum Bauen eigener Skills) und `mcp-builder`. Auf bezahlten Claude.ai-Plänen sind die Dokument-Skills bereits aktiv.

**Community-Skills für Wissenschaft**:
- `Imbad0202/academic-research-skills` (MIT) — Suite für die komplette Paper-Pipeline: research → write → review → revise → finalize.
- `ComposioHQ/awesome-claude-skills` (u. a. content-research-writer) — kuratierte Sammlung.
- Diverse „academic-writing"/„research-paper-writer"-Skills in Marktplätzen (awesomeskill.ai, ClaudSkills) — Qualität stark schwankend; die meisten sind auf IEEE/ACM-STEM-Formate ausgelegt, nicht auf deutsche geisteswissenschaftliche Fußnotenzitation. Vor Nutzung inhaltlich prüfen.

Da fertige Skills den **deutschen** Rahmen und die Philosophie-Konventionen kaum abdecken, empfiehlt sich, die zentralen Phasen als eigene Skills anzulegen (SKILL.md-Format).

#### Der Workflow — Phase für Phase

1. **Themenfindung & Exposé** — Skill mit Struktur-Templates (Fragestellung, Forschungsstand, Methode, Zeitplan). FINER-Kriterien für Forschungsfragen.
2. **Literaturrecherche & Beschaffung** — MCP-gestützt (OpenAlex/S2/Crossref/PhilPapers). Beschaffung über Uni-Zugang (Shibboleth/DFN-AAI), Fernleihe und **Subito** (kostenpflichtiger Dokumentlieferdienst). OA-Versionen zuerst über Unpaywall/CORE prüfen. **Sci-Hub**: in Deutschland Urheberrechtsverletzung — nicht nutzen und nicht empfehlen; entsprechende MCP-Workflows deaktiviert lassen.
3. **Literaturverwaltung** — **Citavi-Campuslizenzen laufen bundesweit aus** (Beispiele mit Datum: HTW Dresden Ende 02/2025, HS Bonn-Rhein-Sieg 31.01.2025, Uni Greifswald 31.05.2025, HS RheinMain 31.05.2027, Uni Göttingen 30.11.2026; frühere Ausstiege u. a. DHBW und Uni Konstanz 31.03.2024). Empfehlung nahezu aller Bibliotheken: Wechsel zu **Zotero** (kostenlos, Open Source, plattformübergreifend). Beim Import Citavi→Zotero gehen Kategorien/Schlagworte an Wissenselementen verloren; rechtzeitig migrieren (nach Lizenzende kein Zugriff mehr auf Cloud-Projekte). Alternativen: JabRef (BibTeX-nativ), für LaTeX BibLaTeX/biber. Zitationsstile: In der Philosophie oft deutsche Fußnotenzitation oder Chicago (Notes-Bibliography); CSL-Stile in Zotero. Es gibt keinen festen einheitlichen „DGPhil-Stil" — meist gelten die Vorgaben des jeweiligen Instituts/Verlags.
4. **Lesen, Exzerpieren, Zettelkasten** — Obsidian/Logseq/Zettlr, Luhmann-Methode; MCP-Anbindung an Obsidian für KI-gestützte Verknüpfung. In der Philosophie besonders verbreitet.
5. **Schreiben** — LaTeX (Overleaf, TeXLive) für formale/logische Arbeiten; Word für viele geisteswissenschaftliche Kontexte; Pandoc/Markdown-Workflows (Zettlr) als Brücke. Deutsche Uni-Vorlagen meist fakultätsspezifisch.
6. **Qualitative Analyse** — MAXQDA, ATLAS.ti (Campuslizenzen) — für Philosophie selten nötig, eher bei empirisch/experimenteller Philosophie.
7. **Forschungsdatenmanagement** — DFG verlangt Umgang mit Forschungsdaten nach **FAIR-Prinzipien**; Datenmanagementpläne (DMP) via RDMO oder DMPonline. Repositorien: Zenodo, RADAR. Für Geisteswissenschaften zentral: die NFDI-Konsortien **Text+** (sprach-/textbasiert) und **NFDI4Culture**, außerdem NFDI4Memory/NFDI4Objects (kooperieren als „Humanities@NFDI"/Memorandumsgruppe).
8. **Gute wissenschaftliche Praxis** — **DFG-Kodex „Leitlinien zur Sicherung guter wissenschaftlicher Praxis"** (seit 01.08.2019 in Kraft, 19 Leitlinien, aktuelle Version v3 2025, DOI 10.5281/zenodo.14281892), von allen Hochschulen rechtsverbindlich in eigene Satzungen umgesetzt (Voraussetzung für DFG-Fördermittel); Ombudspersonen; Plagiatsvermeidung. **KI-Nutzung**: KI kann keine Autorschaft übernehmen („nur verantwortlich handelnde natürliche Personen"); der Einsatz muss offengelegt/gekennzeichnet werden; die konkrete Kennzeichnungspflicht regeln die Prüfungsordnungen der jeweiligen Hochschule (HRK-Empfehlungen; individuelle Regelungen z. B. an TUM/LMU/HU). Ab 16.04.2026 gelten neue DFG-Leitlinien zum KI-Einsatz auch in der Begutachtung (aktive Zustimmung im elan-Portal).
9. **Veröffentlichung** — **DEAL-Verträge** mit Wiley, Springer Nature, Elsevier („Publish & Read"); der zweite Elsevier-Vertrag wurde am 24.11.2023 unterzeichnet und läuft bis Ende 2028, laut DEAL-Konsortium „können rund 900 Einrichtungen in Deutschland" teilnehmen. Publikationsfonds der Unis. **Zweitveröffentlichungsrecht** nach § 38 Abs. 4 UrhG: unabdingbares Recht, einen mind. zur Hälfte öffentlich geförderten Beitrag aus einer mind. zweimal jährlich erscheinenden Sammlung nach 12 Monaten in der akzeptierten Manuskriptversion frei zugänglich zu machen (nicht-kommerziell, Quelle nennen). Institutionelle Repositorien (OPUS, Hochschulschriftenserver), DOI via DataCite, ORCID, GND.
10. **Dissertation** — In Deutschland **Publikationspflicht**: erst nach Veröffentlichung + Abgabe der Pflichtexemplare wird die Urkunde ausgehändigt und der Titel darf geführt werden. Frist meist 1–2 Jahre nach der Disputation (z. B. Philosophische Fakultät Uni Potsdam: 5 gedruckte Exemplare innerhalb von 2 Jahren, falls keine Verlags-/Online-Publikation). Wege: Verlag, Selbstverlag/Book-on-Demand oder Open-Access über den Hochschulschriftenserver (von fast allen Unis akzeptiert). Ablieferung über die Hochschulschriftenstelle; die DNB erhält die Ablieferung. Zahl der gedruckten Pflichtexemplare variiert je nach Form und Fakultät stark (bei Online-/Verlagspublikation oft nur wenige).
11. **Preprints/Fachrepositorien Philosophie** — **PhilArchive** (das führende OA-Preprint-Archiv der Philosophie), PhilPapers, SSRN, Humanities Commons.
12. **Peer Review & Zeitschriftenauswahl** — Predatory Journals erkennen via **Think.Check.Submit** und **DOAJ**; seriöse philosophische Journals (international z. B. Mind, Journal of Philosophy, Noûs; deutschsprachig z. B. Deutsche Zeitschrift für Philosophie, Zeitschrift für philosophische Forschung).
13. **Wissenschaftskommunikation & Fachgesellschaften** — **DGPhil** (Deutsche Gesellschaft für Philosophie) und **GAP** (Gesellschaft für Analytische Philosophie); Kongresse, Tagungen.

## Recommendations

### Zu installierende MCP-Server (5–8, konkret)
Priorisiert nach Nutzen/Kosten für einen Philosophie-Workflow. Alle derzeit kostenlos.

1. **Zotero** — `54yyyu/zotero-mcp` oder `kujenga/zotero-mcp`. Installation: `uvx zotero-mcp` bzw. `zotero-mcp setup`. Herzstück des Workflows.
2. **OpenAlex** — `oksure/openalex-research-mcp` oder `cyanheads/openalex-mcp-server`. Nur E-Mail konfigurieren. Breiteste kostenlose Abdeckung inkl. Geisteswissenschaften — Key-Pflicht ab 2026 beobachten.
3. **Semantic Scholar** — `zongmin-yu/semantic-scholar-fastmcp-mcp-server`; kostenlosen API-Key beantragen für bessere Limits.
4. **Crossref** — `JackKuo666/Crossref-MCP-Server`; mailto setzen. DOI-Auflösung/Metadaten.
5. **Unpaywall** — `ElliotPadfield/unpaywall-mcp`; nur E-Mail. Legale OA-Volltexte finden.
6. **paper-search-mcp** (Multi-Source) — `openags/paper-search-mcp` via `uvx paper-search-mcp`. Deckt CORE/BASE/DOAJ/OpenAIRE-Quellen ab; Sci-Hub-Option deaktiviert lassen, CORE-Key optional.
7. **PhilPapers/PhilArchive** — `sea9401/philosophy-mcp` (`npx -y philosophy-mcp`); Wartungsstand prüfen. Alternativ selbst über OAI-PMH bauen.
8. **Obsidian** (falls Zettelkasten genutzt) — `MarkusPfundstein/mcp-obsidian` mit dem „Local REST API"-Plugin.

Selbst zu bauen (offene APIs, kein fertiger Server): **DNB-SRU**, **K10plus-SRU**, **Deutsches Textarchiv (OAI-PMH/TEI)**, **Perseus (CTS)** — mit dem `mcp`/FastMCP-Python-SDK und dem `skill-creator`/`mcp-builder` aus `anthropics/skills`.

### Anzulegende Skills (5–8, konkret)
1. **Zitation & Bibliografie (Philosophie DE)** — deutsche Fußnotenzitation + Chicago Notes-Bibliography, BibLaTeX/biber, CSL; Institutsvorgaben als Referenzdatei.
2. **Literatur-Review-Workflow** — Suchstrategie über die MCP-Server, Deduplizierung, Screening, Exzerpt-Templates. Als Basis `Imbad0202/academic-research-skills` adaptieren.
3. **Primärquellen-Handling (Antike/klassische Texte)** — kanonische Stellenangaben (Bekker, Stephanus), Perseus/DTA-Anbindung, Zitierregeln.
4. **Deutsche wissenschaftliche Schreibkonventionen** — Exposé, Gliederung, Argumentationsstruktur; docx-Skill als technische Basis.
5. **GWP & KI-Kennzeichnung** — DFG-Kodex-Checkliste, KI-Offenlegungsvorlage, Plagiatsprüfungs-Erinnerung; abgeleitet aus der jeweiligen Prüfungsordnung.
6. **Open-Access-/Publikations-Entscheidungshilfe** — DEAL-Prüfung, § 38 Abs. 4 UrhG (Zweitveröffentlichung), Repositorien-Upload, ORCID/DOI.
7. **Dissertations-Publikationspflicht** — Checkliste Pflichtexemplare, Fristen, Hochschulschriftenserver vs. Verlag, DNB-Ablieferung.
8. **PDF-/Dokumentpipeline** — anthropics `pdf`/`docx`/`pptx` als installierte Skills; eigener Wrapper-Skill für den Exzerpt→Notiz→Entwurf-Fluss.

### Staffelung / Schwellen
- **Sofort**: Zotero-MCP + OpenAlex + Crossref + Unpaywall installieren; Citavi-Projekte (falls vorhanden) nach Zotero migrieren, bevor die eigene Campuslizenz ausläuft.
- **Woche 2–3**: Semantic Scholar (Key), paper-search-mcp, philosophy-mcp; Skills 1, 2, 5 anlegen.
- **Bei Bedarf**: Perseus/DTA/DNB-SRU selbst bauen, wenn Primärquellen/Katalog-Recherche zentral werden.
- **Trigger für Neubewertung**: Wenn ein Server >6 Monate ohne Commit ist oder Fehler wirft → Alternative aus dem jeweiligen Cluster wählen (die Server sind austauschbar). Bei OpenAlex zusätzlich: sobald die Key-/Preispflicht greift, Nutzung und Alternativen (Crossref + S2 + CORE) neu bewerten.

## Caveats
- **Aktualität**: Das MCP-Ökosystem ändert sich monatlich. Konkrete Repos, Installationsbefehle und Paketnamen können veralten; immer das aktuelle README, letzte Commits und PyPI/npm prüfen. Die genannten GitHub-Namen sind Momentaufnahmen (September 2026).
- **OpenAlex-Kostenmodell**: Die Ankündigung verpflichtender API-Keys und nutzungsbasierter Preise (13.02.2026) stammt aus einem Drittanbieter-Audit (Pebblous) — vor Nutzung direkt bei OpenAlex verifizieren, da dies die „kostenlos"-Empfehlung beeinflussen kann.
- **Wartungsrisiko**: Fast alle Server sind Einzelprojekte ohne SLA. Für kritische Arbeit lieber zwei Server pro Aufgabe vorhalten.
- **Rechtliches**: Google-Scholar-Scraping verstößt gegen die ToS; Sci-Hub ist in Deutschland eine Urheberrechtsverletzung — beides nicht verwenden. OAI-/API-Nutzung an die jeweiligen ToS halten (PhilPapers untersagt Massenredistribution; DTA CC BY-SA; Zeno.org/Gutenberg-DE nur privater Gebrauch).
- **Paywall bleibt Paywall**: JSTOR, Project MUSE, De Gruyter, TLG, Loeb, Philosopher's Index sind ohne Uni-Lizenz nicht per MCP zugänglich; Zugang über Shibboleth/DFN-AAI.
- **KI in Prüfungen**: Regelungen sind hochschul- und teils fakultätsspezifisch und ändern sich; vor jeder Abgabe die aktuelle Prüfungsordnung prüfen. KI kann keine Autorschaft tragen.
- **Skills-Lücke**: Fertige Wissenschafts-Skills sind stark STEM-/englischsprachig geprägt; für deutsche geisteswissenschaftliche Konventionen müssen sie angepasst oder neu gebaut werden.
- **Zahlen zu Datenbankgrößen** schwanken je nach Quelle und Stichtag (OpenAlex-Angaben reichen von 320 bis 474 Mio. Werken); sie dienen der Größenordnung, nicht als exakte Kennzahl.