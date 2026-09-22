# Warten oder jetzt investieren? Ein Entscheidungs-Framework gegen die „Sherlocking"-Falle

## TL;DR
- **Dein Muster ist kein Pech, sondern die Regel.** Fähigkeiten wandern vorhersehbar von „Genesis" (neu, mühsam, Bastelei) zu „Commodity" (eingebaut, mühelos) — und im KI-Bereich passiert das derzeit in Monaten statt Jahren, weil Frontier-Labs (OpenAI, Anthropic, Google, xAI) Features aus Open-Source und Startups extrem schnell absorbieren. Die richtige Grundhaltung ist deshalb: **standardmäßig warten, gezielt früh adoptieren.**
- **Entscheide mit einer einfachen Regel:** Adoptiere sofort nur bei akutem, teurem Schmerz, wenn sich der Aufwand in ==unter ~4–6 Wochen amortisiert UND der Wechsel reversibel ist== (Bezos' „Two-Way Door"). In allen anderen Fällen: ==60–90-Minuten-Timebox-Test, dann auf eine Watchlist== statt fest integrieren — und 4–8 Wochen warten.
- **Investiere in das Dauerhafte, nicht in das Vergängliche:** ==übertragbares Fundamentalwissen (3D-Konzepte, nicht Blender-Klicks), modell-agnostische Abstraktionen, deine eigenen Eval-Sets, dokumentierte Workflows/Prompts/Specs und Datenportabilität.== Gerüst („Scaffolding") ist ein Wegwerf-Artikel mit Halbwertszeit von Wochen; das Fundament überlebt mehrere Modellgenerationen.

## Key Findings

**1. Warum das Muster entsteht.** Jede Technologie durchläuft laut Wardley Mapping vier Stufen — Genesis → Custom-Built → Product → Commodity. Was du früh tust, ist per Definition Custom-Built-Arbeit: teuer, differenzierend, aber vergänglich. Sobald eine Fähigkeit Richtung Commodity wandert, ist Eigenbau Zeitverschwendung. Simon Wardleys Kernregel: „Don't build what you can buy, don't buy what you should build." Der Gartner Hype Cycle beschreibt dieselbe Reise aus Erwartungssicht: Innovation Trigger → Peak of Inflated Expectations → Trough of Disillusionment → Slope of Enlightenment → Plateau of Productivity; Gartner beziffert die Gesamtdauer typischerweise auf drei bis fünf Jahre — im KI-Bereich aber oft deutlich kürzer.

**2. Die KI-Beschleunigung ist real und dokumentiert.** MCP (Model Context Protocol) wurde von Anthropic Ende November 2024 veröffentlicht und war binnen etwa eines Jahres von OpenAI, Google DeepMind und Microsoft übernommen. OpenAIs Zusage kam als Tweet von Sam Altman am 26. März 2025: „people love MCP and we are excited to add support across our products. available today in the agents SDK and support for chatgpt desktop app + responses api coming soon!" Im April 2025 bestätigte Demis Hassabis (Google DeepMind) MCP-Support in kommenden Gemini-Modellen; im Dezember 2025 spendete Anthropic MCP an die Agentic AI Foundation unter der Linux Foundation. Ein einzelnes offenes Protokoll wurde also in ~12 Monaten zum herstellerneutralen Industriestandard. Das ist das Tempo, gegen das ein einzelner Power-User antritt.

**3. Die „Bitter Lesson" für Workflows.** Richard Suttons „Bitter Lesson" (2019) besagt: generische Methoden, die auf Rechenleistung skalieren, schlagen langfristig jede handgebaute menschliche Struktur. Praktiker übertragen das heute auf KI-Workflows: ==Jedes Gerüst, das gebaut wird, um Modell-Schwächen zu kompensieren, wird obsolet, sobald das nächste Modell erscheint==. Rajiv Ayyangar formuliert es in seinem Essay „Buoyancy" (7. August 2026) verbatim so: „Scaffolding is a loan against the current model's weaknesses, and a payment comes due at every release. Buoyant teams treat it as disposable: the day a new model ships, they delete code, happily." Die abgeleitete Faustregel („Sutton's Test"): *==Wenn das nächste Modell 10× besser ist — wird dieser Baustein dann überflüssig oder mächtiger?==* Überflüssig = nicht investieren. Mächtiger = investieren.

**4. Es gibt eine klare Trennlinie zwischen dauerhaft und wegwerfbar.** Boris Cherny (Anthropic, Schöpfer von Claude Code) formulierte die Adoptionsstrategie im Y-Combinator-Lightcone-Podcast „Inside Claude Code With Its Creator Boris Cherny" (17. Februar 2026) verbatim so: „we don't build for the model of today, we build for the model six months from now … try to think about what is that frontier where the model is not very good at today, because it's gonna get good at it." Er ergänzte, wie schnelllebig das Gerüst ist: „There is no part of Claude Code that was around six months ago." Sam Altman warnte Startups im 20VC-Podcast mit Harry Stebbings („Which Companies Will Be Steamrolled by OpenAI?", April 2024) drastisch: „There's one strategy which is to assume the model is not going to get better and then you kind of like build all these little things on top of it … when we just do our fundamental job because we have a mission we're going to steamroll you" — und: „It's not personal; it's our mission. We're just going to steamroll." Brad Lightcap (COO OpenAI) nannte im selben Gespräch das positive Kriterium verbatim: „There should be a clear path for how better underlying intelligence accelerates that product and that company." Übersetzt für dich: ==Baue auf Dingen, die mit besseren Modellen *automatisch besser* werden== — nicht auf Krücken, die bessere Modelle *überflüssig* machen.

**5. Frühadoption zahlt sich manchmal wirklich aus — aber aus einem anderen Grund als du denkst.** Der Ertrag liegt selten im Tool selbst (das wird kommoditisiert), sondern im *==kompoundierenden Lernen==*: dem Verständnis dafür, wie eine Fähigkeitsklasse funktioniert. Dieses Wissen überträgt sich auf die kommerzielle, mühelose Version — und macht dich zu der Person, die sofort weiß, was damit möglich ist, wenn alle anderen erst anfangen.

## Details

### (a) Warum dieses Muster unvermeidlich ist

Drei Mental Models erklären dein Erlebnis vollständig:

- **Wardley-Evolution (Genesis → Commodity):** Technologiekomponenten wandern zwangsläufig von links (neu, unsicher, nur per Eigenbau nutzbar) nach rechts (standardisiert, als Utility kaufbar). Deine Frustration ist das Gefühl, in der Custom-Built-Phase gearbeitet zu haben, während die Komponente unter dir Richtung Product/Commodity rutschte. Wardleys strategische Konsequenz: Auf sich entwickelnden Komponenten (Genesis/Custom) differenzieren; auf stabilen (Product/Commodity) optimieren und kaufen.

- **Real-Optionstheorie / „Value of Waiting":** Aus der Investitionstheorie unter Unsicherheit (Dixit & Pindyck; Bessen 1999) folgt: Wenn eine bessere Version der Technologie mit hoher Wahrscheinlichkeit bald kommt, steigt der Optionswert des Wartens. Bessen zeigt: Firmen sollten eine neue Technologie oft *nicht* adoptieren, sobald sie marginal profitabel ist, sondern erst, wenn sie *substanziell* besser ist als der Status quo — weil sonst der „Second Mover" von der Effizienz der reiferen Version profitiert, ohne das Risiko und die Lernkosten getragen zu haben. Genau das erlebst du: Die Mainstream-Version kommt später, ist aber billiger und besser.

- **Gartner Hype Cycle & Trough of Disillusionment:** Frühe Adoption trifft dich oft am „Peak of Inflated Expectations", wo Features noch unausgereift sind. Der pragmatische Sweet Spot für die meisten Nutzer liegt am „Slope of Enlightenment", wenn Second-/Third-Generation-Produkte erscheinen und die Reibung sinkt. Wichtig als Warnung — The Economist schätzt verbatim (zitiert in der Gartner-Hype-Cycle-Darstellung): „We estimate that of all the forms of tech which fall into the trough of disillusionment, six in ten do not rise again." Warten schützt dich also auch vor Sackgassen.

### (b) Entscheidungskriterien: Checkliste & Scoring-Matrix

**Zuerst die Torfrage (Bezos' One-Way vs. Two-Way Door):**
Ist die Adoption reversibel? Kannst du mit geringen Kosten zurück, wenn es nichts wird? ==Two-Way-Door-Entscheidungen soll man laut Bezos schnell und mit ~70 % der Information treffen; One-Way-Door-Entscheidungen (hohe Switching Costs, Daten-Lock-in, tiefe Integration) langsam und vorsichtig.== Die meisten Tool-Adoptionen *sollten* Two-Way Doors sein — halte sie ==bewusst reversibel.==

**Scoring-Matrix (jede Frage 0–2 Punkte; max. 20):**

| # | Kriterium | 0 Punkte | 1 Punkt | 2 Punkte |
|---|-----------|----------|---------|----------|
| 1 | **Akuter Schmerz** | „nice to have" / Neugier | wiederkehrende Reibung | teurer, täglicher Engpass jetzt |
| 2 | **Time-to-Value** | > 3 Monate Setup | Wochen | Stunden/Tage |
| 3 | **Payback-Periode** | > 6 Monate | 6 Wochen–6 Monate | < 4–6 Wochen |
| 4 | **Reversibilität** | One-Way Door (Lock-in) | teilweise | Two-Way Door, leicht rückbaubar |
| 5 | **Sutton-Test** | nächstes Modell macht es überflüssig | neutral | wird mit besseren Modellen besser |
| 6 | **Auf der Roadmap der Labs?** | offensichtlich als Native-Feature angekündigt | unklar | außerhalb Lab-Interesse/Nische |
| 7 | **Thin Wrapper?** | reiner Wrapper auf Modell-Fähigkeit | etwas Eigenlogik | proprietäre Daten/Taste/Domänenwissen |
| 8 | **Konvergenz der Wettbewerber** | viele Anbieter konvergieren schnell | einige | einzigartig, kein Konvergenzdruck |
| 9 | **Transferierbares Lernen** | verpufft bei Tool-Wechsel | teils übertragbar | Fundamentalwissen, das bleibt |
| 10 | **Erwartete Shelf-Life** | Wochen | Monate | Jahre (Lindy-Kandidat) |

**Ablesung:**
- **15–20:** Jetzt adoptieren. Seltener Fall — meist akuter Schmerz + dauerhafter Wert + reversibel.
- **8–14:** Timebox-Experiment (60–90 Min bis max. 1 Tag), dann auf die **Watchlist**. Nicht tief integrieren. Wiedervorlage in 4–8 Wochen.
- **0–7:** Ignorieren. Auf Watchlist notieren, Trigger definieren („adoptiere erst, wenn Anbieter X es nativ hat" oder „wenn meine Evals > Y zeigen").

**Zwei zusätzliche Heuristiken:**
- **Die ==4–8-Wochen-Regel==:** Warte standardmäßig 4–8 Wochen nach dem Hype-Peak, ==es sei denn, es löst einen akuten Schmerz==. In KI-Zyklen filtert dieses Fenster einen großen Teil der Tools heraus, die entweder verschwinden oder von einem Lab absorbiert werden.
- **Modell-Upgrade nur bei Eval-Beweis:** Rüste dein Basismodell erst auf, wenn *deine eigenen* Evals eine Verbesserung *auf deinen Aufgaben* zeigen — nicht wegen MMLU/Benchmark-Marketing. Öffentliche Benchmarks sind gesättigt (GSM8K etwa liegt bei Top-Modellen bei ~99 %) und sagen nichts über deinen Use-Case. Das löst zugleich dein Problem #4 (bis das Setup fertig ist, ist das Modell veraltet): Wenn du eine feste, wiederverwendbare Eval-Suite hast, ist ein Modellwechsel ein 10-Minuten-Regressionstest statt eines Wochenprojekts.

### (c) Worin du stattdessen investieren solltest (das Dauerhafte)

Die Trennlinie lautet: **„==Thin harness, fat skills=="** (dünnes, wegwerfbares Gerüst; dickes, dauerhaftes Fundament). Investiere in:

1. **Übertragbares Fundamentalwissen.** 3D-Konzepte (Topologie, UV-Mapping, Licht, Komposition, Rigging) bleiben wertvoll, egal ob du in Blender klickst oder es per Prompt an eine KI delegierst. Das ==Wissen *bewertet* die Ausgabe der Automation== — der Klick-Skill nicht.
2. **Modell-agnostische Abstraktionsschichten.** ==Halte das Modell als austauschbare Komponente==. Hermes und OpenClaw etwa erlauben einen `hermes model`-Wechsel „no code changes, no lock-in". Nutze diese Portabilität aktiv.
3. **Eigene Eval-Sets.** Eine Sammlung von 20–100 deiner realen Aufgaben mit Erfolgskriterien ist dein persönlicher Benchmark. Das ist der einzige Weg, Modellwechsel objektiv zu entscheiden, und der Wert wächst mit jeder Modellgeneration.
4. **Dokumentierte Workflows, Prompts & Specs.** Deine verfeinerten Prompts und dokumentierten Abläufe sind laut a16z „process power / process engineering" — sie kompoundieren, statt zu verpuffen. a16z-Partner Alex Immerman & Santiago Rodriguez schreiben: „Better models don't make the application layer thinner: they make it more capable, because the hard part was never raw intelligence. It was knowing what to do with it."
5. **Datenportabilität.** Speichere in offenen, langlebigen Formaten (Plain Text, offene Standards). Das ist die Lindy-Wette: Was Jahrzehnte gelesen werden konnte, wird weiter lesbar sein.

Der Lindy-Effekt liefert die passende Linse: Für nicht-verderbliche Dinge (Konzepte, Formate, Fähigkeiten) ist die erwartete Rest-Lebensdauer proportional zum bisherigen Alter. Wähle beim Fundament „langweilige", bewährte Technologie — und hänge die neueste KI-Schicht *daran*, statt umgekehrt.

### (d) Anwendung auf deine vier Beispiele

**1) Blender manuell gelernt, dann kam Blender + AI/MCP.**
Bewertung: Das *==Tool-Wissen* (Menüs, Shortcuts) wurde teilweise kommoditisiert== — MCP-Server für Blender (ausgehend von Siddharth Ahujas Proof-of-Concept blender-mcp) erlauben heute Steuerung per natürlicher Sprache. Aber dein *Fundamentalwissen* (was ist eine gute Topologie, warum sieht ein Render falsch aus) ist genau das, was die Automation kontrolliert und bewertet. **Verdict: Kein Fehlinvestment.** Du sitzt jetzt auf transferierbarem Wissen (Kriterium 9: 2 Punkte). Lehre: Beim nächsten Werkzeug bewusst das *Konzept* lernen, ==nicht die *Klick-Choreografie==*.

**2) OpenClaw selbst nachgebaut; jetzt gibt es bessere Produkte (Grok bot, Hermes).**
Bewertung: Klassischer Fall von hohem ==Konvergenzdruck== (Kriterium 8: 0 Punkte). OpenClaw (Peter Steinberger, ab November 2025 als Clawdbot, >200.000 GitHub-Stars binnen ~60 Tagen) und Hermes (Nous Research, MIT-Lizenz) sind extrem schnell gereift; Steinberger ging im Februar 2026 zu OpenAI, das Projekt in eine Foundation — und Microsoft zeigte auf der Build einen von OpenClaw inspirierten Assistenten. Ein Eigenbau in diesem Feld war fast garantiert wegwerfbar. **Verdict: Der reine Nachbau war vergängliche Custom-Built-Arbeit.** ABER: Was du beim Nachbau über Agent-Architektur gelernt hast (Memory, Tool-Calling, Scheduling, Sicherheit) ist dauerhaftes Verständnis — nutze fertige Produkte (Hermes/OpenClaw) und investiere dein Wissen in *deine* Skills und Datenbestände obendrauf. Wichtig: OpenClaw hatte eine kritische RCE-Schwachstelle vor v2026.2.21 — fertige, gehärtete Produkte sind hier auch sicherheitstechnisch überlegen.

**3) Ein aktuelles Tool, von dem du erwartest, dass Anthropic/OpenAI es in Monaten nachbauen.**
Bewertung: Genau hier greift die Scoring-Matrix. Prüfe: Ist es ein Thin Wrapper auf Modell-Fähigkeit (Kriterium 7)? Steht es plausibel auf der Lab-Roadmap (Kriterium 6)? Wenn ja → **nicht tief integrieren, auf die Watchlist.** Definiere einen Trigger („Ich adoptiere die Native-Version, sobald sie da ist"). Falls es aber ein akuter Schmerz *jetzt* ist und reversibel bleibt (Two-Way Door), nutze es *bewusst als Wegwerf-Werkzeug* für den aktuellen Nutzen — aber baue keine dauerhafte Infrastruktur darum. Die Milch-Metapher (paddo.dev): Der Nutzen ist nicht wertlos, nur verderblich; der Fehler wäre, ihn wie Wein zu lagern (zu polieren, zu abstrahieren, zu „verewigen").

**4) Neue Modelle brauchen viel Setup; bis es fertig ist, ist ein neueres da.**
Bewertung: Das ist ein Prozessproblem, kein Modellproblem. Lösung: (a) Baue *einmal* eine modell-agnostische Setup-Pipeline und eine Eval-Suite. (b) Danach ist jedes neue Modell ein Regressionstest von Minuten, keine Neuinstallation. (c) Rüste nur auf, wenn deine Evals eine echte Verbesserung *auf deinen Aufgaben* zeigen. Cherny empfiehlt sogar, bei jedem neuen Modell das alte Gerüst (System-Prompt, Skills) testweise zu *löschen* und neu aufzubauen, weil das bessere Modell die alten Krücken oft nicht mehr braucht. So drehst du das Tempo von Gegner zu Verbündetem.

### (e) Wann Frühadoption sich wirklich lohnt (der ausgewogene Gegenpunkt)

Warten ist die Default-Empfehlung — aber es gibt vier Fälle, in denen frühe Adoption klar richtig ist:

1. **Kompoundierendes Lernen.** Wer eine Fähigkeitsklasse früh versteht, hat einen Startvorsprung, der sich über Zyklen aufsummiert. Der Vorteil liegt im *Verständnis*, nicht im spezifischen Tool. Genau das ist bei dir mit Blender passiert — das Wissen bleibt.
2. **Akuter, teurer Schmerz jetzt.** Wenn ein Engpass dich täglich Geld/Zeit kostet und ein Tool ihn heute löst mit Payback in Wochen, ist Warten teurer als Adoptieren — selbst wenn das Tool in 6 Monaten kommoditisiert wird.
3. **Wenn das Tool der Kern deines Geschäfts/Outputs ist.** Wer davon lebt, die Person zu sein, die das Neue am besten versteht (Creator, Berater, Early-Access-Content), für den *ist* der Vorsprung das Produkt.
4. **„Build for the model six months from now."** Wenn du an der Grenze arbeitest, wo das Modell heute schwach ist, aber absehbar stark wird, positionierst du dich für den Moment, in dem die Fähigkeit einrastet — genau Chernys Strategie bei Claude Code, das „die ersten sechs Monate kaum nutzbar" war und erst mit Opus 4 (Mai 2025) einrastete.

Die Synthese: ==**Sei früh mit dem *Lernen* und spät mit dem *Bauen*.**== Erforsche breit und billig (Timeboxes, Watchlist), aber gieße nur dann Beton, wenn Schmerz, Payback, Reversibilität und Dauerhaftigkeit zusammenkommen.

## Recommendations

**Sofort (diese Woche):**
1. Lege eine **Watchlist** an (eine einfache Notiz-Datei in offenem Format). Jedes verlockende Tool kommt zuerst hierhin — mit einem definierten *Trigger*, ab wann du es ernsthaft prüfst.
2. Baue deine **persönliche Eval-Suite**: 20–100 deiner echten, wiederkehrenden Aufgaben mit klaren Erfolgskriterien. Das ist die wichtigste einzelne Investition — sie macht jede künftige Modell-/Tool-Entscheidung objektiv und schnell.
3. Führe die **Scoring-Matrix** oben als Vorlage. Bevor du etwas integrierst, fülle sie in 5 Minuten aus.

**Als laufende Routine:**
4. **Default = warten 4–8 Wochen** nach dem Hype-Peak. Ausnahme nur bei akutem Schmerz + Payback < ~4–6 Wochen + Two-Way Door.
5. **Timebox statt Integration:** Neue Tools bekommen 60–90 Minuten (max. 1 Tag) Test, dann Entscheidung: adoptieren / Watchlist / verwerfen. Keine tiefe Integration in der Explorationsphase.
6. **Modell-Upgrades nur per Eval-Beweis.** Kein Upgrade wegen Benchmark-Schlagzeilen; nur wenn deine Evals auf deinen Aufgaben besser abschneiden.
7. **Trenne Gerüst von Fundament.** Behandle Prompts/Scaffolding als 90-Tage-Wegwerf-Artikel; investiere Sorgfalt nur ins Fundament (Konzepte, Evals, portable Daten, dokumentierte Workflows).

**Schwellen, die deine Entscheidung ändern (Trigger):**
- Wenn **≥2 Frontier-Labs** dieselbe Fähigkeit angekündigt haben → sofort auf Watchlist, nicht bauen.
- Wenn ein Tool **> 6 Monate** überlebt hat und mehrere Konkurrenten hat, aber keiner es nativ absorbiert → Lindy-Signal, jetzt sicherer zu adoptieren.
- Wenn deine **Payback-Rechnung < 4 Wochen** ergibt und reversibel → adoptieren, auch wenn Kommoditisierung droht.
- Wenn deine **Evals ≥ X %** Verbesserung zeigen → Modell/Tool wechseln, sonst nicht.

## Caveats

- **Meine Grundempfehlung (warten) kehrt sich um, wenn der Modellfortschritt stark verlangsamt.** Die gesamte „Scaffolding ist wegwerfbar"-Logik hängt daran, dass Modelle schnell besser werden. Wenn der Fortschritt fünf Jahre stagniert, hört Gerüst auf zu depreziieren, und sorgfältige Frühbauer gewinnen wieder — wie Ayyangar anmerkt. Beobachte das Release-Tempo als Meta-Signal.
- **„Sherlocking" hat auch eine positive Seite für dich als Nutzer:** Anders als beim App-Entwickler, dessen Geschäft stirbt, *profitierst* du als Power-User, wenn eine Fähigkeit kommoditisiert wird — du bekommst sie billiger und mühelos. Deine „verlorene" Zeit ist der Lernvorsprung, den du behältst.
- **Quellenlage:** Die strategischen Frameworks (Real-Optionen, Wardley, Lindy, Hype Cycle, Bezos-Türen, Bitter Lesson) sind gut belegt. Die konkreten Zitate von Cherny (YC Lightcone, Feb. 2026), Altman & Lightcap (20VC, April 2024) und a16z (Immerman/Rodriguez, 2026) stammen aus Podcasts/Essays und sind über mehrere Quellen korroboriert. Einige kursierende Statistiken zu „X % der Wrapper sterben" sind Blog-Behauptungen ohne belastbare Primärquelle — ich habe sie bewusst nicht als Fakten übernommen.
- **Tool-spezifische Details** (OpenClaw/Hermes-Versionen, GitHub-Stars, MCP-Daten) spiegeln den Stand um September 2026 und ändern sich schnell; prüfe aktuelle Versionen, besonders wegen Sicherheitsupdates (OpenClaw RCE vor v2026.2.21).
- **Die Scoring-Matrix ist ein Denkwerkzeug, kein Orakel.** Die Punktegrenzen (8, 15) sind Heuristiken; kalibriere sie nach ein paar echten Entscheidungen für deinen Kontext nach.