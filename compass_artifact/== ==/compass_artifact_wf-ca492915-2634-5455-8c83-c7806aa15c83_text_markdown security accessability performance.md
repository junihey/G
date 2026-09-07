# REVIEW-STANDARDS.md — Befüllung der drei Achsen: Security, Accessibility, Performance

Die drei leeren Achsen lassen sich vollständig im bestehenden Design-Bauprinzip („Guardrails + die ungeprüfte Hälfte") befüllen, weil für jede ein reifer, maschinennaher Katalog existiert (OWASP Top 10:2025, ASVS 5.0, CWE Top 25 2024, WCAG 2.2 + axe-core, Core Web Vitals + Azure-Performance-Antipatterns) — und die Claude-Skills liefern dabei genau ein wertvolles Teil: ihre Exclusion-Liste ist fast wörtlich eine Liste dessen, „was die Maschine nicht entscheiden kann".

## TL;DR
- **Ja, alle drei Achsen sind im gleichen Bauprinzip befüllbar.** Unten stehen je ~12–14 Guardrails (nach Entscheidungsmechanismus gruppiert), 5 Urteilsfragen und ein Smell-Katalog mit etablierten Namen. Der Kernbefund je Achse für die „ungeprüfte Hälfte": Security — Autorisierungslogik/IDOR ist notorisch **nicht** automatisch beweisbar; Accessibility — axe-core deckt im Schnitt nur **57,38 %** der WCAG-Issues ab; Performance — N+1 und Tail-Latency (p99) überleben jeden grünen Unit-Test.
- **Die Claude-Prompts taugen als Vorlage — aber nur teilweise.** Ihr größter Wert ist die **HARD-EXCLUSIONS-Liste (18 nummerierte Punkte)** im öffentlichen `/security-review`-Prompt: fast jeder Punkt ist ein Satz der Form „das kann/soll die Maschine nicht melden" und damit direktes Rohmaterial für „Was ungeprüft bleibt". Als Vorlage für das Regel-/Ratschen-Modell und die Urteilsfragen taugen sie **nicht** — sie sind diff-orientiert und auf false-positive-Minimierung getrimmt.
- **Konsistenz-Regel gegen Doppelführung:** Jede Regel hat genau eine Heimat-Achse — die, deren Mechanismus sie *maschinell* prüft. Andere Achsen dürfen sie in einer Urteilsfrage referenzieren, nicht als eigene Zeile duplizieren („every outbound call carries a timeout" bleibt in Design; Performance erbt nur die Urteilsdimension).

---

## ACHSE 3: SECURITY — Bauprinzip „Sink, Provenienz, Konfiguration"

Gruppiert nach Entscheidungsmechanismus. Grundlage: OWASP Top 10:2025 (A01 Broken Access Control … A03 Software Supply Chain Failures und A10 Mishandling of Exceptional Conditions sind 2025 neu), OWASP ASVS 5.0.0 (Mai 2025, drei kumulative Level L1/L2/L3), CWE Top 25 2024 (CISA/MITRE, aus 31.770 CVE-Records; #1 ist CWE-79 Cross-site Scripting, das nach drei Jahren CWE-787 wieder ablöst), OWASP Proactive Controls 2024 (C1–C10), Taint-Analyse (Semgrep/CodeQL: source → sink über propagators, geblockt durch sanitizer).

**Sink** (eine Taint-Analyse entscheidet die geprüfte Hälfte: nachweisbarer Datenfluss von Source zu Sink ohne Sanitizer)

| Regel | Was ungeprüft bleibt |
| --- | --- |
| every query is parameterized | Ob der String, der aus drei „sicheren" Teilen zusammengesetzt wird, doch einen tainted Teil enthält. |
| no shell string carries user input | Eine Eingabe, die erst durch drei Hilfsfunktionen wandert und dann in `exec` landet. |
| output is escaped at the sink | Ob der `dangerouslySetInnerHTML`-Aufruf wirklich schon serverseitig gesäubertes HTML bekommt. |
| no untrusted data is deserialized | Ob das Objekt, das „aus dem eigenen Cache" kommt, nicht vorher von außen befüllt wurde (CWE-502). |
| path input is confined to a base dir | Ob die Normalisierung vor oder nach dem Zusammensetzen des Pfads passiert (CWE-22). |

**Provenienz** (ein Typ oder Marker entscheidet die geprüfte Hälfte: woher stammt der Wert)

| Regel | Was ungeprüft bleibt |
| --- | --- |
| authorization is checked server-side | Ob die Prüfung das *richtige* Objekt betrifft — ob User A wirklich Ressource B besitzen darf (IDOR, CWE-862/863). |
| every endpoint declares its authz rule | Ob die Regel die fachlich korrekte ist oder nur irgendeine. |
| secrets never appear in source | Ob der Wert, der aus der Config kommt, nicht doch ein eingecheckter Default-Key ist (CWE-798). |
| tokens are validated, not just parsed | Ob Signatur, Ablauf und Audience zusammen geprüft werden — oder nur eins davon. |

**Konfiguration** (ein Scanner/Manifest entscheidet die geprüfte Hälfte)

| Regel | Was ungeprüft bleibt |
| --- | --- |
| TLS and security headers are set | Ob die Header-Werte sinnvoll sind — eine leere CSP zählt als „gesetzt". |
| dependencies carry signed provenance | Ob das Paket, dessen Signatur stimmt, nicht selbst kompromittierten Code enthält (SLSA prüft den Build, nicht den Inhalt). |
| errors don't leak internals | Ob die eine Ausnahme, die den Stacktrace durchreicht, den kritischen Pfad betrifft. |

**Ratschen** (ein Zähler entscheidet die geprüfte Hälfte)

| Regel | Was ungeprüft bleibt |
| --- | --- |
| untriaged findings may not grow | Ob die Alt-Findings, die als „akzeptiert" gelten, wirklich harmlos sind. |
| new dependencies per release may not grow | Ob die eine neue Abhängigkeit essenziell ist oder nur bequem. |
| public endpoints without authz may not grow | Ob ein bewusst öffentlicher Endpunkt zu Recht öffentlich ist. |

### Urteilsfragen Security
- Prüft die Autorisierung das richtige Objekt — oder nur, dass überhaupt jemand eingeloggt ist?
- Wurde die Eingabe validiert — oder nur an eine Stelle geschoben, wo sie später jemand anderes für sauber hält?
- Ist dieser Endpunkt bewusst öffentlich — oder hat nur niemand die Prüfung eingebaut?
- Ist das Geheimnis wirklich weg — oder nur aus dem Diff, während es in der History bleibt?
- Verkleinert diese Änderung die Angriffsfläche — oder verschiebt sie das Risiko nur hinter eine neue Schicht?

### Security-Smells (nach OWASP Top 10 / CWE Top 25 2024 — etablierte Namen)

| Smell | Was er beschreibt |
| --- | --- |
| **broken access control** | Der Client entscheidet, was er sehen darf; der Server glaubt ihm. OWASP A01, seit 2025 explizit inkl. BOLA/BFLA — notorisch nicht automatisch prüfbar. |
| **IDOR** | `/orders/123` liefert auch Order 124, wenn man die ID hochzählt. Kein Besitznachweis. |
| **injection** | Nutzereingabe wird als Code interpretiert: SQL/OS/Template (CWE-79/89/78, OWASP A05). |
| **hardcoded credentials** | Ein API-Key steht im Quelltext (CWE-798). „Nur temporär" bleibt bis zum Leak. |
| **insecure deserialization** | Ein Objekt wird aus fremden Bytes rekonstruiert und führt dabei Code aus (CWE-502). |
| **security misconfiguration** | Debug-Modus in Produktion, offene Default-Accounts, fehlende Header (OWASP A02, 2025 von #5 auf #2). |
| **SSRF** | Der Server holt eine URL, die der Angreifer kontrolliert (CWE-918; 2025 unter A01 subsumiert). |
| **supply chain failure** | Eine Abhängigkeit wird kompromittiert, bevor sie deinen Build erreicht (OWASP A03, neu 2025). |
| **exceptional-condition mishandling** | Ein Fehlerpfad lässt das System in unsicherem Zustand zurück (OWASP A10, neu 2025). |

---

## ACHSE 4: ACCESSIBILITY — Bauprinzip „Semantik vor ARIA"

Grundlage: WCAG 2.2 (W3C-Recommendation vom 5. Oktober 2023, aktualisiert 12. Dezember 2024, seit 2025 ISO/IEC 40500:2025; 9 neue Erfolgskriterien, davon 6 auf Level A/AA), die 5 Rules of ARIA („no ARIA is better than bad ARIA"), axe-core / Deque-Regelkatalog. **Zentraler Befund für die ungeprüfte Hälfte:** Der Deque *Automated Accessibility Coverage Report* fand „On average across all the audits included in the sample data … 57.38% of total issues were identified using Deque's automated tests" — über 2.000 Audits, mehr als 13.000 Erstseiten, fast 300.000 Issues. Die restlichen ~43 % verlangen menschliches Urteil (ist der Alt-Text sinnvoll, ist die Fokusreihenfolge logisch, sind Captions korrekt). WebAIM-Befund zur Warnung vor Übereifer: Homepages *mit* ARIA hatten im Schnitt 41 % mehr erkannte Fehler als solche ohne.

**Semantik** (der DOM / eine Lint-Regel entscheidet die geprüfte Hälfte)

| Regel | Was ungeprüft bleibt |
| --- | --- |
| native element before ARIA role | Ob das `<div role="button">` auch die Tastaturbedienung nachbaut, die `<button>` gratis hätte. |
| every control has an accessible name | Ob der Name beschreibt, was der Knopf *tut* — „Button" erfüllt die Regel und sagt nichts. |
| every image has an alt attribute | Ob der Alt-Text den Inhalt trägt oder nur „image123.png" wiederholt. |
| form fields have associated labels | Ob das Label fachlich zum Feld passt oder nur irgendein `for` gesetzt ist. |
| no ARIA attribute is invalid or orphaned | Ob ein *gültiges* ARIA-Attribut auch das *richtige* ist — bad ARIA ist schlimmer als keins. |

**Struktur** (der DOM-Baum entscheidet die geprüfte Hälfte)

| Regel | Was ungeprüft bleibt |
| --- | --- |
| headings form a nested outline | Ob die Reihenfolge der Überschriften der *logischen* Gliederung entspricht. |
| page has landmark regions | Ob die Landmarks den Inhalt sinnvoll teilen oder überall nur `role="main"` steht. |
| color contrast meets 4.5:1 | Ob der Text, der den Schwellwert knapp reißt, auf dem realen Hintergrundbild lesbar ist. |
| interactive targets are ≥ 24×24 px | Ob zwei knapp konforme Ziele nah beieinander trotzdem schwer treffbar sind (WCAG 2.2, 2.5.8). |

**Verhalten** (nur teils prüfbar — hier beginnt die ungeprüfte Hälfte früh)

| Regel | Was ungeprüft bleibt |
| --- | --- |
| every interactive element is focusable | Ob die Fokusreihenfolge der visuellen Reihenfolge folgt. |
| focus is not trapped | Ob der Fokus nach dem Schließen eines Dialogs dorthin zurückkehrt, wo er sinnvoll ist. |
| focused element stays visible | Ob ein Sticky-Header den fokussierten Button verdeckt (WCAG 2.2, 2.4.11 Focus Not Obscured). |
| motion respects reduced-motion | Ob eine Animation, die die Abfrage respektiert, trotzdem Schwindel auslöst. |

**Ratschen** (ein Zähler entscheidet die geprüfte Hälfte)

| Regel | Was ungeprüft bleibt |
| --- | --- |
| axe violations per page may not grow | Ob die ~43 %, die axe nicht sieht, sich still verschlechtern. |
| ARIA-widgets without keyboard handler may not grow | Ob bestehende Custom-Widgets je mit einem Screenreader getestet wurden. |

### Urteilsfragen Accessibility
- Trägt der Alt-Text den Inhalt — oder ist er nur vorhanden, damit der Scanner schweigt?
- Folgt die Fokusreihenfolge der Bedeutung — oder nur der DOM-Reihenfolge?
- Braucht dieses Widget wirklich ARIA — oder gäbe es ein natives Element, das alles gratis mitbringt?
- Ist der Kontrast lesbar — oder nur numerisch über der Schwelle?
- Wurde das mit Screenreader/Tastatur bedient — oder nur der Scanner grün gemacht?

### A11y-Smells (etablierte Antipatterns)

| Smell | Was er beschreibt |
| --- | --- |
| **div soup** | Alles ist `<div>`/`<span>`. Keine Semantik, für den Screenreader nichts zu greifen. |
| **bad ARIA** | ARIA haphazard drübergestreut. WebAIM: Seiten mit ARIA hatten 41 % mehr erkannte Fehler. |
| **click handler on non-button** | `onClick` auf einem `<div>`. Mit Maus bedienbar, mit Tastatur nicht. |
| **placeholder as label** | Der Platzhaltertext ersetzt das Label. Beim Tippen verschwindet die einzige Beschriftung. |
| **positive tabindex** | `tabindex="3"` erzwingt eine Fokusreihenfolge, die niemand pflegen kann. |
| **decorative/informative alt mix-up** | Dekobild mit sinnlosem Alt oder Inhaltsbild mit leerem Alt — beides falsch herum. |
| **keyboard trap** | Man kommt per Tab hinein, aber nicht wieder heraus. |
| **color-only meaning** | „Rote Felder sind Pflicht" — für Farbenblinde unsichtbar. |

---

## ACHSE 5: PERFORMANCE — Bauprinzip „Budgets + gemessene Optimierung"

Grundlage: Core Web Vitals (INP löste FID am **12. März 2024** als drittes Core Web Vital ab; „good"-Schwellen am 75. Perzentil der Felddaten: **LCP ≤ 2,5 s, INP ≤ 200 ms, CLS ≤ 0,1**), Performance Budgets (Lighthouse CI mit ESLint-artigen Assertions `off`/`warn`/`error`; Resource-Budgets via `budget.json`; Bundle-Ratschen via `size-limit`/`bundlesize`/webpack performance hints), Azure Performance-Antipatterns (10 benannte Muster), N+1/ORM-Literatur (`nplusone`, Query-Count-Assertions).

**Budgets** (ein Schwellwert im CI entscheidet die geprüfte Hälfte)

| Regel | Was ungeprüft bleibt |
| --- | --- |
| bundle size stays under budget | Ob die 20 KB, die dazukamen, dem Nutzer schaden oder ihm etwas bringen. |
| LCP/INP/CLS pass in CI | Ob das grüne Lab-Ergebnis dem realen p75-Feldwert der Nutzer entspricht. |
| resource count stays under budget | Ob die Requests, die unter dem Limit bleiben, trotzdem falsch getaktet sind. |
| no render-blocking asset is added | Ob das eine nicht-blockierende Skript trotzdem den Hauptthread blockiert. |

**Datenzugriff** (ein Query-Zähler/Profiler entscheidet die geprüfte Hälfte)

| Regel | Was ungeprüft bleibt |
| --- | --- |
| no query runs inside a loop | Ob der eine Batch-Load, der N+1 vermeidet, mehr Daten lädt als gebraucht. |
| every hot query hits an index | Ob der Index, der existiert, auch der ist, den der Planner wählt. |
| no endpoint fetches unused columns | Ob `SELECT *` bequem ist oder die Serialisierung erstickt (Extraneous Fetching). |
| list endpoints are paginated | Ob die Seitengröße zur realen Datenmenge passt. |

**Ressourcen** (Lint/AST entscheidet die geprüfte Hälfte)

| Regel | Was ungeprüft bleibt |
| --- | --- |
| every outbound call has a timeout | Ob Timeout, Backoff und Abbruch zusammen vernünftig sind (Heimat: Design). |
| retries use backoff and a cap | Ob die Retry-Politik unter Last einen Retry-Storm auslöst. |
| shared clients are reused, not recreated | Ob ein pro Request neu erzeugter Client den Pool erschöpft (Improper Instantiation). |
| blocking I/O is off the request thread | Ob ein „async" markierter Aufruf intern doch synchron blockiert. |

**Ratschen** (ein Zähler/Trend entscheidet die geprüfte Hälfte)

| Regel | Was ungeprüft bleibt |
| --- | --- |
| p99 latency may not regress | Ob der Mittelwert grün bleibt, während der Tail leidet. |
| queries per request may not grow | Ob eine bestehende Kopplung die Query-Zahl schon vorher aufgebläht hat. |
| main-thread blocking time may not grow | Ob das JS-Budget von Anfang an zu großzügig war. |

### Urteilsfragen Performance
- Wurde das Problem gemessen — oder optimierst du gegen ein Bauchgefühl?
- Ist der Mittelwert grün, während p99 leidet — leiden also gerade die, die es am meisten merken?
- Braucht dieser Cache eine Invalidierungsstrategie — oder liefert er bald falsche Daten schnell?
- Ist diese Abstraktion (ORM, Retry-Layer) noch dein Freund — oder erzeugt sie unter Last erst die Last?
- Ist es wirklich schneller geworden? Die Ratschen sagen nur, dass es nicht langsamer wurde.

### Performance-Smells (Azure Performance-Antipatterns — etablierte Namen)

| Smell | Was er beschreibt |
| --- | --- |
| **busy database** | Zu viel Rechenlogik in den Datenspeicher geschoben, der nicht mitskaliert. |
| **busy front end** | Ressourcenintensive Arbeit auf Threads, die eigentlich Nutzeranfragen bedienen sollten. |
| **chatty I/O** | Viele kleine Netzwerk-Requests statt weniger großer — jeder Round-Trip kostet. |
| **extraneous fetching** | Mehr Daten geholt als gebraucht — `SELECT *`, wo drei Spalten reichen. |
| **improper instantiation** | Objekte, die geteilt gehören (Clients, Connections), werden pro Aufruf neu erzeugt. |
| **monolithic persistence** | Ein Datenspeicher für Daten mit völlig verschiedenem Zugriffsmuster. |
| **no caching** | Immer wieder dasselbe teuer neu berechnet/geholt. |
| **noisy neighbor** | Ein Tenant verbraucht unverhältnismäßig viele geteilte Ressourcen. |
| **retry storm** | Fehlgeschlagene Requests zu oft und zu synchron wiederholt — der Server erstickt vollends. |
| **synchronous I/O** | Der aufrufende Thread blockiert, bis die I/O fertig ist. |
| **N+1 queries** | Eine Query für die Liste, dann eine pro Element. In jedem Unit-Test grün, in Produktion tödlich. (Nicht in Azures Liste, aber der klassische ORM-Fall — hier ergänzt.) |

---

## TEIL B: Taugen die Claude-Skills als Vorlage?

**Was öffentlich existiert (Stand September 2026):**
- **`/security-review`** — angekündigt am **6. August 2025** im Anthropic-Blog „Automate security reviews with Claude Code" (VentureBeat: „9:00 am, PT, August 6, 2025"; Feature-Lead Logan Graham, Anthropic frontier red team), veröffentlicht am selben Tag wie Claude Opus 4.1. Der zugrundeliegende Prompt ist **quelloffen**: Repo `anthropics/claude-code-security-review`, Datei `.claude/commands/security-review.md`. Es gibt eine gleichnamige GitHub Action, die diffbasiert auf jedem PR läuft.
- **`/code-review`** (`/review` ist heute ein Alias; vor v2.1.223 ein eigener single-pass, read-only Command) — dokumentiert unter `code.claude.com/docs`. Ein Team spezialisierter Agenten sucht „logic errors, security vulnerabilities, broken edge cases, and subtle regressions", taggt nach Severity, approved/blockt aber nicht; steuerbar über `CLAUDE.md`/`REVIEW.md`.
- **`/simplify`** — laut Docs seit v2.1.147 ein separater cleanup-only Review, der Fixes anwendet ohne Bug-Suche; wer damit Bugs suchte, soll auf `/code-review --fix` wechseln.
- Ergänzend: offenes `anthropics/skills`-Repo und das SKILL.md-Format (`claude.com/docs`).

**Die wertvollste Vorlage: die Exclusion-Liste.** Der `/security-review`-Prompt enthält (a) im Abschnitt CRITICAL INSTRUCTIONS drei grobe EXCLUSIONS (DoS, Secrets on Disk, Rate Limiting) und (b) im Abschnitt FALSE POSITIVE FILTERING eine mit **1–18 nummerierte „HARD EXCLUSIONS"-Liste** plus zusätzliche „PRECEDENTS". Diese Ausschlüsse markieren *exakt* die Grenze zwischen geprüfter und ungeprüfter Hälfte. Beispiele, die Claude explizit NICHT melden soll:
- DoS / Resource Exhaustion; Rate Limiting; Memory-/CPU-Exhaustion (Nr. 1, 3, 4)
- Input-Validation ohne nachweisbaren Security-Impact (Nr. 5) — deckt sich mit deiner Sink-Logik
- fehlendes Hardening statt konkreter Lücke (Nr. 7); rein theoretische Race Conditions (Nr. 8)
- veraltete Third-Party-Libs, „separat verwaltet" (Nr. 9); Memory-Safety in Managed Languages inkl. Rust (Nr. 10)
- Log-Spoofing (Nr. 12); SSRF, das nur den Pfad kontrolliert (Nr. 13); Regex-Injection/-DoS (Nr. 15/16); fehlende Audit-Logs (Nr. 18)
- Precedents: Env-Variablen und CLI-Flags gelten als vertrauenswürdig; React/Angular gelten als XSS-sicher außer bei `dangerouslySetInnerHTML`/`bypassSecurityTrustHtml`; clientseitige Authz-Checks sind kein Fund (Server ist zuständig).

**Das Confidence-Modell:** >80 % Confidence-Schwelle, Score-Bänder 0.7–1.0, nur HIGH/MEDIUM, dann ein zweiter paralleler Sub-Task, der Findings unter Confidence 8 herausfiltert. Genau dieses Muster („nur was beweisbar ist, blockt; der Rest ist Signal") rechtfertigt, warum bei dir manche Prüfungen als **Ratsche** statt als harter Blocker laufen.

**Urteil — was übernehmen:**
1. **Die Hard-Exclusions sind fertiges Rohmaterial für die ungeprüfte Hälfte der Security-Achse.** Jeder Punkt ist ein Satz „das kann die Maschine nicht verlässlich entscheiden". 1:1 als „Was ungeprüft bleibt"-Einträge nutzbar (z. B. Input-Validation-ohne-Sink, theoretische Race Condition, clientseitige Authz).
2. **Das Source→Sink-Prinzip** („You do not need to run commands … just read the code … trace data flow from user inputs to sensitive operations") ist genau der Entscheidungsmechanismus deiner Sink-Gruppe.
3. **Der Kategorienschnitt** (Input Validation / AuthN & AuthZ / Crypto & Secrets / Injection & Code Execution / Data Exposure) ist ein guter Sanity-Check gegen deine Gruppen Sink/Provenienz/Konfiguration.
4. **Das Confidence-Filtering** als Begründung des Ratschen-Modells.

**Urteil — was NICHT übernehmen:**
1. **Diff-zentriert statt dauerhaft:** Der Prompt bewertet ausdrücklich nur Neues („focus ONLY on security implications newly added by this PR. Do not comment on existing security concerns"). Deine Achsen brauchen dauerhafte Regeln + Ratschen über den ganzen Bestand.
2. **Kein Ratschen-/Trendmodell:** Der Prompt kennt keinen Zähler „darf nicht wachsen".
3. **Keine Urteilsfragen:** Er ist auf false-positive-Minimierung getrimmt und weicht gerade den Urteilssachen (IDOR/Broken Access Control) bewusst aus — das ist deine ungeprüfte Hälfte, nicht deren geprüfte.
4. **Nur Security:** Für A11y/Performance gibt es keinen analogen Anthropic-Prompt; `/code-review` deckt zwar mehrere Dimensionen ab, ist aber nicht katalogförmig.

**Konkrete Empfehlung:** Kopiere die 18 Hard-Exclusions in deine Security-Achse als „Was ungeprüft bleibt"-Sätze (1:1-Mapping). Nutze den Kategorienschnitt zur Validierung deiner Sink/Provenienz/Konfiguration-Gruppen. Verwirf die Diff-Orientierung; ergänze Ratschen + Urteilsfragen selbst — die liefert kein Prompt. Für A11y/Performance dienen die Skills nur als Struktur-Analogie (Severity-Tags, Confidence-Filter), nicht als Inhalt; dort liefern axe-core-Regeln bzw. Lighthouse-Budgets die geprüfte Hälfte.

---

## TEIL C: Konsistenz-Check über alle fünf Achsen

| Regel / Thema | Kommt vor in | Heimat-Empfehlung |
| --- | --- | --- |
| every outbound call carries a timeout | Design + Performance | **Design** (Resilienz-Deklaration, per Lint/AST prüfbar); Performance referenziert nur in der Urteilsfrage „ist das Timeout unter Last vernünftig?". |
| a boundary has its own types | Design + Security (Datenexposition) | **Design** für die Typtrennung; Security ergänzt nur die Urteilsdimension „was der ausgehende Typ weglassen muss". |
| middle man / no pass-through layer | Design (Guardrail) + Correctness (Smell) | Beide behalten — Guardrail = Regel, Smell = Beschreibung. Kein Konflikt, das ist gewollte Redundanz zwischen den beiden Formaten. |
| retry storm / retries use backoff | Performance | **Performance** (Resilienz-Last). Bewusst NICHT in Security — dort ist DoS/Rate-Limiting explizit exkludiert (Hard-Exclusion 1/3). |
| SSRF | Security | **Security** (A01/CWE-918). Nicht in Performance, obwohl es Round-Trips erzeugt. |
| input validation | Security | **Security**, aber: reine Validierung *ohne* nachweisbaren Sink ist laut Claude-Exclusion Nr. 5 kein harter Fund → als Ratsche/Urteilsfrage führen, nicht als Blocker. |
| color-only meaning / contrast | Accessibility | **Accessibility**. Die Kontrast-*Zahl* ist geprüft, der *Sinn* ist Urteil. |
| N+1 / extraneous fetching | Performance | **Performance**. Begrifflich nah an „feature envy" (Correctness), aber der Blickwinkel ist Last, nicht Struktur. |

**Regel gegen Doppelführung:** Jede Regel hat genau *eine* Heimat-Achse und steht nur dort in der Guardrail-Tabelle. Faustregel für die Heimat: **die Achse, deren Entscheidungsmechanismus die Regel maschinell prüft, besitzt sie.** Andere Achsen dürfen sie in einer Urteilsfrage referenzieren, aber nicht als eigene Zeile duplizieren. Beispiel: „every outbound call carries a timeout" wird per Lint/AST geprüft → Design/„Regeln" besitzt sie; Performance erbt nur die Urteilsdimension.

---

## Recommendations (gestaffelt)

1. **Sofort — Security-Achse zuerst befüllen und mit der Exclusion-Liste härten.** Übernimm die vier Gruppen oben, dann kopiere die 18 Hard-Exclusions aus `anthropics/claude-code-security-review/.claude/commands/security-review.md` als „Was ungeprüft bleibt"-Sätze. Das ist der schnellste Gewinn, weil hier eine primäre Quelle deine Grenze zwischen geprüft/ungeprüft schon gezogen hat. *Benchmark zum Weitergehen:* sobald deine Sink-Gruppe von einem Taint-Tool (Semgrep/CodeQL) abgedeckt ist, verschiebe „every query is parameterized" & Co. vom Review-Menü in die CI-Gate-Ebene.

2. **Als Nächstes — Accessibility mit axe-core als Ratsche verankern.** Setze `axe violations per page may not grow` als CI-Ratsche (jest-axe/Playwright). *Threshold, der die Empfehlung ändert:* Sobald du die 57,38-%-Grenze verlässt (d. h. Screenreader-/Tastatur-Tests etablierst), promoviere die vier „Verhalten"-Regeln von Urteilsfragen zu Pflicht-Checklisten im PR-Template.

3. **Dann — Performance mit „freeze, then reduce"-Budgets.** Setze Budgets zunächst knapp über den heutigen Baseline-Werten (z. B. aktuelle Bundle-Größe + kleiner Puffer, Lighthouse-Floor leicht unter aktuellem Score); halte die Linie einige Sprints, dann ratschen. Ergänze eine p99-Latenz-Ratsche neben den Lab-Metriken. *Threshold:* Wenn Lab-CWV grün, aber CrUX-p75 rot ist, ist das Signal, dass Feld-Monitoring (USE/RED) das Lab-Gate ergänzen muss.

4. **Querschnitt — Doppelführung einmalig auflösen.** Geh die Tabelle in Teil C durch und markiere in REVIEW-STANDARDS.md je Regel die Heimat-Achse; ersetze Duplikate in Fremd-Achsen durch Urteilsfragen-Referenzen.

## Caveats
- **Aktualität der Kataloge:** OWASP Top 10:2025 lag über weite Strecken 2025 als Release Candidate vor und wurde als achte Edition finalisiert; die Kategorienamen (A01–A10) oben entsprechen der 2025er-Fassung. ASVS 5.0.0 ist Mai 2025. Der CWE Top 25 ist die **2024er**-Liste (Release 20.11.2024) — eine 2025er-Liste war zum Redaktionsstand nicht als primär bestätigt greifbar; #1 ist CWE-79 (XSS). Prüfe vor Veröffentlichung, ob inzwischen eine neuere CWE-Liste erschienen ist.
- **Die 57 %-Zahl ist eine Deque-Messung, kein Naturgesetz:** Sie misst *Volumen* der Issues (nicht Anteil der WCAG-Kriterien) und beruht auf axe-cores bewusst false-positive-armem Ansatz; andere Tools „casten weiter" und finden nominal mehr, mit mehr Rauschen. Als Fundament für die ungeprüfte Hälfte ist der Punkt robust, die exakte Prozentzahl ist es weniger.
- **Der Claude-Prompt ist ein bewegliches Ziel:** `security-review.md` wird versioniert; die konkrete Nummerierung/Formulierung der 18 Exclusions kann sich ändern. Verlinke im Zweifel auf einen fixen Commit-Hash statt auf `main`. Der Prompt ist zudem ausdrücklich *nicht* gegen Prompt-Injection gehärtet und nur für vertrauenswürdige PRs gedacht — das ist ein Betriebs-, kein Vorlagen-Hinweis.
- **„N+1 queries"** habe ich dem Azure-Smell-Katalog hinzugefügt (es steht nicht in Azures offizieller 10er-Liste, ist aber der kanonische ORM-Fall). Als solches gekennzeichnet, damit klar bleibt, was etablierter Katalog und was Ergänzung ist.
- **Neu geprägte Regelnamen:** Die englischen Regelnamen in den Guardrail-Tabellen sind im Stil deiner Vorlage formuliert; die *Konzepte* stammen aus den genannten Katalogen, die exakten Kurznamen sind teils von mir geprägt (nicht wörtliche Zitate aus OWASP/WCAG). Die Smell-Namen dagegen sind durchweg etabliert.