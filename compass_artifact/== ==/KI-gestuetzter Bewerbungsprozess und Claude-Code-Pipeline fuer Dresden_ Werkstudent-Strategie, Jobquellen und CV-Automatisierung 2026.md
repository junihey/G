# KI-gestützter Bewerbungsprozess & Claude-Code-Pipeline für Julian N. Heynert (Dresden/Sachsen, Stand 2026)

## TL;DR
- **Der komplette Prozess ist automatisierbar** — Job-Ingestion über die inoffizielle Arbeitsagentur-REST-API + JobSpy + den öffentlichen TU-Dresden-Stellenticket-RSS-Feed + die Karriere-/ATS-Endpunkte der Silicon-Saxony-Fabs (Bosch/SmartRecruiters-API, GlobalFoundries/Workday-JSON, Infineon/Eightfold), dann LLM-Scoring gegen ein strukturiertes YAML-Master-Profil, LLM-Tailoring von CV/Anschreiben, PDF-Rendering (Typst/RenderCV für Industrie, HTML/CSS→WeasyPrint für Kreativ) und ein Markdown/CSV/SQLite-Tracker — **mit obligatorischer menschlicher Freigabe vor jedem Versand** (kein Auto-Apply).
- **Inhaltlich braucht der Bewerber zwei Varianten** (Industrie: MES/E-Learning/technische Redaktion vs. Kreativ: Creative Technologist/Zeitbasierte Medien): antichronologischer, ein- bis zweiseitiger CV mit Kurzprofil, ergebnisorientierten Bullets und Klartext für ATS. Der Doppel-Werdegang Ingenieur + Kunst ist als „Digital-Media-Engineer / Creative Technologist" ein echtes Alleinstellungsmerkmal, das aber aktiv gerahmt werden muss; Homöopathie und Anthroposophie gehören nicht in Industriebewerbungen.
- **Werkstudent-Achtung:** Jahrgang 1995 → 2026 ist der Bewerber 30/31 Jahre. Die studentische Pflichtversicherung (KVdS) endet mit dem Semester, in dem man 30 wird; das Werkstudentenprivileg (Beitragsfreiheit in KV/PV/ALV, 20h-Regel) bleibt aber altersunabhängig bestehen. Realistischer Stundenlohn in Dresden: **16,08 €** (Indeed, 162 Angaben, Stand 6. Februar 2026).

## Key Findings

### 1. Werkstudent-Rahmen (kritisch für genau diesen Bewerber)
- **Werkstudentenprivileg:** Befreiung von Kranken-, Pflege- und Arbeitslosenversicherungsbeiträgen; nur Rentenversicherung fällt an (Gesamtbeitrag 18,6 %, Arbeitnehmeranteil 9,3 %). Voraussetzung: ordentliches Studium als „Hauptsache", Beschäftigung als „Nebensache", max. 20 Wochenstunden in der Vorlesungszeit. Ausnahmen (Semesterferien, abends, nachts, Wochenende) sind über die **26-Wochen-Regel** (max. 26 Wochen bzw. 182 Kalendertage über 20h pro Zeitjahr) möglich (Quellen: AOK, TK, DAK, Studierendenwerke).
- **Zweitstudium + abgeschlossenes Diplom** sind unproblematisch, solange der Bewerber ordentlich immatrikuliert ist und das Studium der Schwerpunkt bleibt. Der Werkstudentenstatus knüpft am Beschäftigungsstatus an, nicht an einem fehlenden Erstabschluss.
- **Altersgrenzen:** Familienversicherung endet mit 25. Die **studentische Krankenversicherung (KVdS)** endet mit dem Semester, in dem man 30 wird. Da der Bewerber 1995 geboren und 2026 über 30 ist, muss er sich voraussichtlich **freiwillig gesetzlich oder privat versichern**. Größenordnung KVdS-Beitrag 2026 zum Vergleich (laut KKH): **150,48 € für Personen mit Kind bzw. 155,61 € für Kinderlose** pro Monat; der Beitrag beruht laut vdek auf dem KV-Anteil (10,22 % des BAföG-Bedarfssatzes von 855 €) plus kassenindividuellem Zusatzbeitrag und Pflegeversicherung. **Wichtig:** Mit 30 endet nur der günstige KVdS-Studententarif — das Werkstudentenprivileg im Job (Beitragsfreiheit KV/PV/ALV auf den Lohn) bleibt bestehen (Quelle: student-insurance.com, DAK).
- **Vergütung Dresden:** Ø **16,08 €/h** (Indeed, de.indeed.com, „162 Gehaltsangaben, zuletzt am 6. Februar 2026 aktualisiert"); Sachsen ~15,46 €/h (Indeed). Bei 20h/Woche entspricht das grob 1.250–1.400 € brutto/Monat. Was Arbeitgeber von einem Werkstudenten mit bereits abgeschlossenem Diplom erwarten: höhere Selbstständigkeit und schnellere Einarbeitung als von Erstsemestern — der Bewerber kann das als Vorteil verkaufen („Ingenieur-Level-Kompetenz zum Werkstudenten-Tarif").

### 2. Jobsuche mit KI — Quellen, Zugriff, Automatisierbarkeit
- **Bundesagentur für Arbeit** hat die größte Stellendatenbank Deutschlands, aber **keine offizielle API**. Es gibt eine breit genutzte inoffizielle REST-API (GitHub `bundesAPI/jobsuche-api`): Header `X-API-Key: jobboerse-jobsuche`, Stellensuche über `/pc/v6/jobs` bzw. `/pc/v4/app/jobs`, Details über `/pc/v4/jobdetails/{base64(refnr)}`. Relevante Filter: `arbeitszeit=ho` (Heim-/Telearbeit), `tz` (Teilzeit), semikolon-separierbar. Rechtlich Grauzone (öffentliche Daten, inoffizieller Zugang).
- **JobSpy** (`speedyapply/JobSpy`): scrapt LinkedIn, Indeed, Glassdoor, Google, ZipRecruiter mit einem Python-Call; Deutschland via `country_indeed='germany'`; liefert pandas-DataFrame. **Indeed** ist aktuell der stabilste Scraper (kein Rate-Limiting), **LinkedIn** am restriktivsten (Rate-Limit ~ab Seite 10, Proxies faktisch Pflicht). Achtung: kein PyPI-Release seit Juli 2025 — Bruchgefahr, ggf. Fork `ts-jobspy` (TypeScript, 2026 aktiv) prüfen.
- **TU Dresden Stellenticket** (`tud.stellenticket.de`): bietet **öffentlichen RSS-Feed** unter `https://tud.stellenticket.de/en/rss/` (DE: `/de/rss/`) plus E-Mail-Abo — der sauberste, rechtlich unbedenklichste Kanal für die Pipeline; umfasst Werkstudentenstellen, Praktika, SHK, Abschlussarbeiten. Dieselbe Engine treibt die DRESDEN-concept-Career-Offers-Seite (TUD + Fraunhofer + Leibniz-Partner).
- **Silicon Saxony Jobboard** (`jobs.silicon-saxony.de`, läuft auf Empfehlungsbund/`sisax.empfehlungsbund.de`): E-Mail-„Suchbot", **kein dokumentiertes öffentliches API/RSS** für Konsumenten. Empfehlungsbund importiert intern strukturierte Feeds der Mitglieder (d.vinci, Personio, SuccessFactors etc.), stellt sie aber nicht öffentlich bereit.
- **stellenwerk Dresden** (`stellenwerk.de/dresden`): geprüftes Hochschul-Jobportal für Dresdner Studierende (Werkstudent, Praktikum, Minijob); E-Mail-Alerts, **kein öffentliches RSS**.
- **Silicon-Saxony-Arbeitgeber & ihre ATS** (entscheidend für Ingestion):
  - **Infineon Dresden** — `jobs.infineon.com`, Kandidatenportal auf **Eightfold-AI**-Plattform, SuccessFactors-Backend; viele „Werkstudent (w/m/div) Dresden"-Stellen. Zugriff via internem JSON-Search-Endpunkt.
  - **Bosch (Robert Bosch Semiconductor Dresden)** — `jobs.smartrecruiters.com/BoschGroup`, **SmartRecruiters mit öffentlicher Posting-API** (`?company=BoschGroup`). Best automatisierbar.
  - **GlobalFoundries Dresden** — `globalfoundries.wd1.myworkdayjobs.com/External`, **Workday** (CxS-JSON-API). Beschreibt ausdrücklich „working students". Gut automatisierbar.
  - **ESMC/TSMC Dresden** — `careers.tsmc.com` (Custom-Portal); v.a. Ingenieure/Operator/Ausbildung, Werkstudentenstellen in der Fab-Aufbauphase begrenzt.
  - **X-FAB Dresden** — `xfabulous.com`, **SAP SuccessFactors** mit explizitem Filter „Working Students"/„Internship"/„Thesis" plus E-Mail-Suchbot.
  - **Fraunhofer** (`jobs.fraunhofer.de`, SuccessFactors-Muster/Haufe-Backend; 6 Institute in Dresden: IWS, IKTS, FEP, IPMS u.a.) und **Leibniz** (`leibniz-gemeinschaft.de/karriere/stellenportal`; IFW Dresden, IPF Dresden) — überwiegend PhD/technisch/SHK/Abschlussarbeiten; öffentliche RSS teils über `service.bund.de` (`RSSGenerator_Stellen.xml`) für öffentlich-rechtliche Arbeitgeber.
- **Kreativ-/Kulturportale:** **dasauge** (Design/Foto/Medien-Stellenmarkt + Portfolios, ~1.400 Design-Jobs), **Designtagebuch dt-Jobbörse**, **Kulturmanagement Network**, **media.net**, **meinestadt.de** (Design & Gestaltung Dresden). Meist nur manuell/HTML — für die Pipeline via HTML-Scraping der öffentlichen Listen.

### 3. Scraping-Recht (Deutschland/EU, 2026)
- Öffentlich zugängliche Seiten (ohne Login/Paywall) auszulesen ist im Grundsatz **zulässig** (BGH-Flugpreis-Rechtsprechung 2014; § 44b UrhG erlaubt Text-and-Data-Mining rechtmäßig zugänglicher Werke).
- **AGB-Scraping-Verbote** binden nur bei Zustimmung (typisch nach Login/Registrierung) — deshalb ist Scraping hinter LinkedIn-Login riskant, LinkedIn-AGB verbieten es ausdrücklich.
- **Umgehen technischer Schutzmaßnahmen** (CAPTCHA, Zugangssperren) kann **§ 202a StGB (Ausspähen von Daten)** erfüllen — klare rote Linie. Öffentliche, ungeschützte Seiten abrufen erfüllt den Tatbestand nicht.
- **DSGVO:** Stellenanzeigen sind meist nicht personenbezogen, aber Recruiter-Namen/Kontaktdaten schon — sparsam, zweckgebunden, lokal speichern. Präferiere offizielle/halb-offizielle APIs (SmartRecruiters, Workday-CxS, Arbeitsagentur) und den TUD-RSS gegenüber aggressivem HTML-Scraping.

### 4. Inhaltliche Standards 2025/2026
- **CV-Aufbau:** tabellarisch, antichronologisch (neueste Station zuerst), 1–2 A4-Seiten, **monatsgenaue** Daten („Oktober 2018 – Juni 2020"), lückenlos — ungeklärte Lücken >2–3 Monate führen zu Rückfragen/Ablehnung.
- **Foto:** rechtlich freiwillig (AGG verbietet Arbeitgebern, es zu verlangen), kulturell aber weiterhin erwartet. Die oft zitierte Quote — **„82 % der deutschen Lebensläufe enthalten weiterhin ein Bewerbungsfoto"** — stammt aus der StepStone-Recruiting-Studie 2024 und ursprünglich der Staufenbiel-Institut-Studie 2017 (297 befragte Unternehmen: „erst ein Foto macht eine Bewerbung komplett"). In Tech/Start-ups/öffentlichem Dienst wird zunehmend darauf verzichtet, und ATS/Screening-Tools ignorieren Fotos. **Empfehlung:** professionelles Foto für beide Varianten vorhalten, in anonymisierten/Tech-Verfahren weglassen.
- **Persönliche Daten:** Name, E-Mail, Telefon, Wohnort/Region sind Standard; Geburtsdatum/-ort, Familienstand, Nationalität freiwillig und rückläufig — für einen 30-jährigen Bewerber Geburtsdatum optional (Alter kann in konservativen Branchen erwartet werden, in Tech eher weglassen).
- **Anschreiben:** „Sehr geehrte Damen und Herren" und „Hiermit bewerbe ich mich" gelten als abgenutzte Floskeln (arbeits-abc, lebenslauf.de). Ansprechpartner recherchieren, korrekt anreden. Erfolgs-/ergebnisorientiert mit Zahlen formulieren („5 Produkte zur Marktreife entwickelt" statt „10 Jahre Erfahrung"). Keine Begründung über eigenen Aufstieg/Eigennutz; Mehrwert für den Arbeitgeber. Bei vielen großen Arbeitgebern (Deloitte etc.) ist „Anschreiben nicht erforderlich" — dann Energie in CV + optionales knappes Motivationsschreiben stecken.
- **ATS in Deutschland:** **Workday** ist Marktführer bei großen Konzernen (GlobalFoundries), **SAP SuccessFactors** sehr weit verbreitet (Infineon, X-FAB, Fraunhofer), **SmartRecruiters** bei Bosch. Konsequenz für den CV: Klartext, Standardschriften, keine Icons/Grafiken/Textboxen für Pflichtangaben, Keywords aus der Stellenanzeige spiegeln.

### 5. KI-Bewerbungen — Akzeptanz & Recht
- **Bewerber-Nutzung:** softgarden-Umfrage (Mai–Juli 2025, 6.929 Bewerbende, via PERSONALintern): **„43,2 Prozent der Bewerbenden nutzen inzwischen KI für ihre Anschreiben … mehr als verdreifacht seit 2023 … Das aktuell mit Abstand am meisten benutzte KI-Tool ist ChatGPT (85,8 Prozent)."** Der 2023-Vergleichswert von 12,7 % stammt aus softgarden „Candidate Journey 2023". Statista/Haufe (Jan 2026, 500 AN): 58 % der deutschen Bewerber nutzen KI, bei unter 30-Jährigen höher.
- **Recruiter-Akzeptanz:** gespalten. Deutsche Skepsis historisch hoch (IU-Studie 2022: 64,7 % sehen KI im Bewerbungsprozess kritisch), aber DAX-Konzerne/technikaffine Branchen zunehmend offen, besonders bei transparenter Nutzung. Softgarden-Report 2025 betont die „Mensch-Falle": Bewerber lehnen reine Arbeitgeber-KI-Entscheidungen stark ab (52,3 %). **Kernregel: Authentizität schlägt Perfektion; generische KI-Sprache und „Klingt nach ChatGPT" vermeiden.**
- **EU AI Act:** KI-Systeme zur Bewerber-Filterung/-Bewertung/-Ranking sind **Hochrisiko (Anhang III)**. Der **Digital Omnibus** (Verordnung (EU) 2026/1744 vom 8. Juli 2026, im Amtsblatt am 24. Juli 2026, in Kraft seit 27. Juli 2026) hat die zentralen Hochrisiko-Pflichten für Anhang-III-Systeme vom ursprünglich vorgesehenen 2. August 2026 auf den **2. Dezember 2027** verschoben; die Transparenzpflichten nach Art. 50 gelten weiterhin ab 2. August 2026. **Wichtig für diesen Bewerber:** Das betrifft die **Arbeitgeber-Seite** (Auswahlsysteme). Eine reine Schreibhilfe (ChatGPT/Claude für den eigenen CV) fällt NICHT unter die Hochrisiko-Pflichten.
- **DSGVO beim Hochladen:** Unterlagen zu KI-Diensten außerhalb der EU hochzuladen ist datenschutzsensibel. **Empfehlung:** EU-Serverstandort oder lokale Modelle (Ollama/LM Studio) für sensible Daten; bei Cloud-LLMs (Claude/ChatGPT) prüfen, ob Daten zum Training genutzt werden (in Business-/API-Tarifen i.d.R. nicht).

### 6. Tools & PDF-Generierung (Vergleich für eine Code-Pipeline)
| Ansatz | Stärken | Schwächen | Einsatz hier |
|---|---|---|---|
| **RenderCV** (Typst, YAML→PDF, JSON-Schema) | versionierbar, ATS-freundlich, „content-first", perfekte Typografie | begrenzte Design-Freiheit | **Industrievariante** — ideal für code-getriebene, seriöse CVs |
| **Typst** (direkt) | kompiliert in Millisekunden, saubere Syntax, 2026 für CVs LaTeX überlegen | kleinere Template-Bibliothek als LaTeX | Basis-Engine unter RenderCV |
| **LaTeX/moderncv** | riesige Template-Auswahl, akademischer Standard | langsam (2–10 s), Paket-Management | nur falls bestehende LaTeX-Templates genutzt werden sollen |
| **WeasyPrint** (HTML/CSS→PDF) | kein Browser, kleinste Dateien (~8–21 KB), exzellente CSS-Paged-Media, `@page`-Regeln | kein JS, C-Abhängigkeiten (Pango/Cairo), keine Warm-Mode-Concurrency | **Kreativvariante** — designbetonte HTML/CSS-CVs |
| **Playwright** (headless Chromium) | höchste Rendering-Treue, 15–75× schneller warm, JS/Grid | ~300 MB Chromium, schwer serverless | nur bei JS-Charts/komplexem CSS |
| **Reactive Resume** (self-hosted, MIT, Docker) | GUI, client-side PDF (@react-pdf/renderer), keine Tracking | weniger code-integrierbar | GUI-Ergänzung/Prototyping |
| **JSON Resume / Europass** | Standardschema, viele Themes / EU-behördenkonform | Europass optisch generisch, bei DE-Privatwirtschaft unbeliebt | JSON Resume als Datenzwischenformat denkbar |

**Resume-Tailoring-OSS (evaluiert):** `srbhr/Resume-Matcher` (lokale LLMs, Match-Score, Keyword-Highlighting, Cover Letter, PDF-Export); `resume-llm/resume-ai` (lokal-first, Pandoc→DOCX, Kanban-Tracker, ATS-Warnungen); `SherLock707/TailorCV` (Ollama, „ohne Übertreibung"); `anushibinj/resume-tailor` (LaTeX-Preamble bleibt unangetastet, per-Section-Changelog, Gap-Liste mit „Add to resume"-Button — kein Halluzinieren). Es existieren bereits **„resume tailoring agents on Claude Code based on experience bank"** (GitHub-Topic `resume-tailoring`) sowie ein „local-first … zero-token fact verification … Typst WASM PDF compilation"-Projekt — gute Vorlagen für die eigene Pipeline. **Risiko generell:** Auto-Apply-Bots (z. B. Selenium-basierte, die 9+ Plattformen scrapen und ATS-Formulare ausfüllen) verletzen AGB und produzieren generische Bewerbungen — meiden.

## Details

### Schwächen der aktuellen Unterlagen & konkrete Verbesserungen
1. **Fehlende Fokussierung (Zwei-Varianten-Problem):** Ein Universal-CV kann den Ingenieur-plus-Kunst-Spagat nicht überzeugend transportieren. → Zwei Master-Varianten aus einer Datenbasis: **(A) „Digital-Media-Engineer / MES & E-Learning"** (Industrie/Halbleiter/Hochschule) und **(B) „Creative Technologist / Zeitbasierte & Digitale Medien"** (Kultur/Design/XR).
2. **Doppel-Werdegang als vermeintlicher Bruch:** Ein Wechsel von Diplom-Ingenieur zu Bildender Kunst kann als Orientierungslosigkeit gelesen werden. → Aktiv als **Brücke** rahmen: „Ingenieur mit gestalterisch-medialer Zweitqualifikation". Der Bosch-MES-Job (Web Based Training im Halbleiterwerk) ist der **Beweis der Synthese** — Technik + Didaktik + Medienproduktion in einem — und sollte in beiden Varianten prominent stehen.
3. **Lücken/Selbstständigkeit/Parallelität:** Nachhilfe-Selbstständigkeit seit 2021 und die Projektstellen müssen monatsgenau und lückenlos erscheinen. Parallele Tätigkeiten (Studium HfBK + Bosch + HDS|D2C2) klar als parallel kennzeichnen, damit keine Scheinlücken/-brüche entstehen.
4. **Für Industriebewerbungen hinderliche Inhalte:** Weiterbildung „Klassische Homöopathie" und Interessen „Homöopathie/Anthroposophie" wirken in einem evidenzbasierten Ingenieurumfeld (Halbleiter, Medizintechnik-Normen ASTM F88/USP 861) potenziell polarisierend und sollten in Variante A **entfallen**. Saxofon (1,0), Latinum, Musikschule sind neutral bis positiv, aber Platzverschwendung — nur knapp unter „Weiteres" oder in der Kreativvariante. In Variante B (Kunst/Kultur) können Anthroposophie/Homöopathie je nach Ziel-Institution sogar neutral bis anschlussfähig sein — kontextabhängig entscheiden.
5. **Skill-Darstellung:** Skill-/Prozentbalken sind **nicht ATS-lesbar** und wirken beliebig („Was bedeutet 80 % SolidWorks?"). → Niveau-Angaben in Worten (Grundkenntnisse / gut / verhandlungssicher) und Gruppierung nach Kategorie (CAD/Konstruktion: SolidWorks, AutoCAD; Simulation: MATLAB/Simulink; Kreativ/Medien: Adobe CC, DaVinci Resolve, Blender, Max/MSP, Figma; Web: HTML/CSS, JavaScript-Grundkenntnisse; E-Learning: Moodle, Articulate 360; Dokumentation: Obsidian/Markdown/LaTeX). Für ATS die Keywords der Stellenanzeige spiegeln.
6. **Anschreiben-Anrede:** „Sehr geehrte*r [voller Name]" ist stilistisch falsch — entweder „Sehr geehrte Frau …" / „Sehr geehrter Herr …" (gegendert nur ohne konkreten Namen sinnvoll). Floskeln und Aufstiegs-/Eigennutz-Begründungen streichen.
7. **Portfolio (Variante B) fehlt vermutlich:** Für Bewerbungen in Zeitbasierte/Digitale Medien sind **eigene Website + PDF-Portfolio + kurzes Showreel** (Blender-/DaVinci-/Max-MSP-/Visualizer-Arbeiten) faktisch Pflicht.

### Empfohlene Zielrichtungen (nach Passung sortiert)
- **Sehr hohe Passung — E-Learning/Instructional Design/Web Based Training:** Bosch-MES-WBT-Erfahrung + Articulate 360 + Moodle + HfBK-Verbundprojekt HDS|D2C2 (E-Learning, hybride Lehre). Hier ist der Bewerber überdurchschnittlich qualifiziert und der Doppel-Werdegang ist reiner Vorteil.
- **Sehr hohe Passung — MES-/Halbleiter-nahe technische Schulung/Redaktion:** Silicon-Saxony-Fabs, WBT-/MES-Erfahrung direkt anschlussfähig; Ingenieur-Diplom sichert Fachverständnis.
- **Hohe Passung — Creative Technologist / 3D/Visualisierung/XR/Medientechnik:** Blender, Max/MSP (GenExpr), DaVinci, Figma, Visualizer-Erfahrung.
- **Hohe Passung — technische Dokumentation:** Ingenieur + Medien-/Textkompetenz + LaTeX/Markdown.
- **Hohe Passung — Hochschul-Digitalisierung:** bereits belegt durch HDS|D2C2 und Kustodie-Digitalisierung.
- **Mittlere Passung — UX/UI** (Figma vorhanden, wenig Portfolio-Nachweis) und **klassisches Engineering/Konstruktion/Prüftechnik/Faserverbund** (Diplom + BAM-Diplomarbeit + ITM, aber vom aktuellen Kunststudium thematisch entfernt — nur mit gezieltem Tailoring).

### Konkrete Arbeitgeber Dresden/Sachsen
- **Halbleiter/MES/Elektronik:** Infineon, Bosch, GlobalFoundries, ESMC/TSMC, X-FAB, SAW Components, Jenoptik (>80.000 Beschäftigte im Cluster, jeder dritte EU-Chip aus Dresden).
- **Forschung:** Fraunhofer (6 Dresdner Institute: IWS, IKTS, FEP, IPMS u.a.), Leibniz (IFW, IPF), TU Dresden.
- **Engineering-Dienstleister/Anlagenbau:** Exyte, Ferchau.
- **Kultur/Kreativ:** Staatstheater Dresden (Staatsoper/Staatsschauspiel), HfBK, regionale Kulturprojekte/Agenturen.

## Recommendations

### A) Unterlagen — Stufenplan
1. **Woche 1:** Master-Profil als `profile.yaml` anlegen (alle Stationen monatsgenau, Achievements mit Zahlen/Kennzahlen, Skill-Kategorien, zwei Positionierungs-Claims, Textbausteine für Anschreiben). Homöopathie/Anthroposophie aus Variante A entfernen.
2. **Woche 1–2:** Zwei RenderCV/Typst-Templates (Industrie: seriös-minimal, einseitig wenn möglich) + ein WeasyPrint-HTML/CSS-Template (Kreativ: zweiseitig, dezente Akzentfarbe, klare Typografie). Professionelles Foto (Kopf/Schultern, neutraler Hintergrund) erstellen.
3. **Woche 2–3:** Kreativ-Portfolio-Website + PDF-Portfolio + 60–90-Sekunden-Showreel.
4. **Laufend:** Pro Bewerbung Anschreiben tailoren, Keywords spiegeln, faktentreu bleiben (keine erfundenen Zahlen).

### B) Pipeline — Stufenplan
1. **MVP (Woche 1–2):** Arbeitsagentur-API + TU-Stellenticket-RSS → SQLite → Deduplizierung → LLM-Scoring gegen `profile.yaml` → Markdown/CSV-Tracker. **Kein Auto-Apply.**
2. **Ausbau (Woche 3–4):** JobSpy (Indeed/LinkedIn), SmartRecruiters-Posting-API (Bosch), Workday-CxS-JSON (GlobalFoundries) ergänzen; Tailoring-Modul (Claude) + PDF-Rendering (RenderCV / WeasyPrint) anschließen.
3. **Reife:** ATS-/Qualitäts-Check (Keyword-Coverage, Klartext-Prüfung), Human-in-the-Loop-Freigabe-UI, optional Notion-Sync.

### C) Architekturvorschlag für Claude Code (modular)
```
apply-pipeline/
├── profile/
│   ├── profile.yaml          # Master-Datenbasis: alle Stationen, Achievements, Skills, Varianten A/B
│   └── snippets.yaml         # wiederverwendbare Anschreiben-/Bullet-Bausteine
├── ingest/                   # 1. Job-Ingestion
│   ├── arbeitsagentur.py     # inoffizielle REST-API (X-API-Key)
│   ├── jobspy_source.py      # Indeed/LinkedIn/Google via JobSpy
│   ├── rss_tud.py            # TU-Dresden-Stellenticket-RSS
│   ├── smartrecruiters.py    # Bosch Posting-API
│   └── workday.py            # GlobalFoundries CxS-JSON
├── store/
│   └── jobs.sqlite           # normalisierte Jobs + Dedup (Hash aus Titel+Firma+Ort)
├── score/
│   └── llm_scorer.py         # 2. LLM-Scoring gegen Profil+Präferenzen (Werkstudent, 20h, Remote/Dresden)
├── tailor/
│   ├── cv_tailor.py          # 3. CV-Tailoring (Variante A/B je nach Job-Cluster)
│   └── letter_tailor.py      # Anschreiben-Tailoring, faktentreu, per-Section-Changelog
├── render/
│   ├── render_rendercv.py    # 4a. Industrie-PDF (Typst)
│   └── render_weasyprint.py  # 4b. Kreativ-PDF (HTML/CSS)
├── check/
│   └── ats_check.py          # 5. Keyword-Coverage, Klartext-/Longsatz-Prüfung, Gap-Report
├── track/
│   └── tracker.md / .csv     # 6. Bewerbungs-Tracker (Status, Datum, Kontakt, Fristen)
└── review/                   # 7. Human-in-the-Loop: Freigabe VOR Versand (manuell)
```
**Datenformate:** YAML für das Master-Profil (menschenlesbar, git-versionierbar, RenderCV-kompatibel); SQLite als Job-Store; Markdown/CSV für den Tracker (git-freundlich, ohne SaaS-Abhängigkeit). **Sprache/Libraries:** Python als Kern (JobSpy, requests, feedparser, pydantic für Schema-Validierung, RenderCV, WeasyPrint, Jinja2 für HTML-Templates, `anthropic`-SDK für Claude). Deduplizierung über Fuzzy-Match (Titel+Firma+Ort). Scoring/Tailoring mit strukturierten Prompts, die (a) nur Fakten aus `profile.yaml` verwenden dürfen, (b) fehlende Anforderungen als „Gap" ausweisen statt zu erfinden, (c) jede Formulierung auf eine Profil-Zeile zurückführen (Fact-Verification, wie bei `anushibinj/resume-tailor`).

**Bewährter Tailoring-Prompt (Muster für Claude):** „Du bist Bewerbungs-Assistent. Nutze AUSSCHLIESSLICH die Fakten aus dem folgenden YAML-Profil. Erfinde nichts. Ordne, gewichte und formuliere die vorhandenen Stationen so um, dass sie die Anforderungen der Stellenanzeige treffen. Markiere jede Anforderung, die das Profil NICHT abdeckt, separat als Lücke. Vermeide generische Floskeln und typische KI-Sprache; schreibe in der Ich-Perspektive des Bewerbers, sachlich, konkret, mit Zahlen. Ausgabe: (1) getailorte Bullet-Liste, (2) Changelog mit Begründung je Änderung, (3) Lücken-Report."

### D) Benchmarks, die die Empfehlung ändern
- **>20h/Woche gewünscht:** Werkstudentenprivileg entfällt → Midijob/reguläre Beschäftigung prüfen.
- **Auto-Apply erwogen:** NICHT umsetzen — AGB-/Reputationsrisiko, Recruiter-Skepsis, generische Ergebnisse.
- **Exmatrikulation:** kein Werkstudentenstatus mehr → dann Direkteinstieg/Teilzeit als Ingenieur oder Medienschaffender.
- **Über 30 & Versicherungskosten:** vor Vertragsabschluss Krankenkasse konsultieren (freiwillig gesetzlich vs. privat).

### E) Auto-Apply: klare Abratempfehlung
KI nur bis zum fertigen Entwurf einsetzen, Versand immer manuell nach Prüfung. Das schützt vor AGB-Verstößen, Faktenfehlern und dem „Klingt nach ChatGPT"-Effekt — und entspricht der dokumentierten Recruiter-Erwartung an Authentizität.

## Caveats
- **Inoffizielle Endpunkte:** Arbeitsagentur-API, Eightfold-/TSMC-JSON und teils Workday/SuccessFactors-Feeds sind inoffiziell bzw. tenant-abhängig — sie können jederzeit brechen oder rechtlich beanstandet werden. Jeden Endpunkt einzeln testen; RSS (TUD) und offizielle Posting-APIs (SmartRecruiters) bevorzugen.
- **Foto-Erwartungsquote (82 %):** basiert ursprünglich auf einer Staufenbiel-Studie von 2017 (297 Unternehmen) und wurde in neueren Sekundärquellen (u.a. von Foto-/CV-Anbietern) fortgeschrieben — als Tendenz, nicht als tagesaktueller Hartwert lesen. Der Trend geht klar zu weniger Fotos, v.a. in Tech.
- **KI-Nutzungsquoten** (43,2 % / 58 %) variieren je nach Stichprobe/Definition erheblich.
- **EU-AI-Act-Zeitplan** war 2026 in Bewegung (Digital-Omnibus-Verschiebung auf Dez. 2027) — für den Bewerber als reinen Anwender einer Schreibhilfe aber ohnehin nicht bindend.
- **Silicon-Saxony-Jobboard-Volumen** konnte nicht exakt ermittelt werden (JS-gerendert); vor Pipeline-Integration live prüfen.
- **Versicherungsdetails ab 30** sind komplex und einzelfallabhängig — Beitragsbeispiele (150–156 €) dienen nur der Größenordnung.