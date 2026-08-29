# Moderne Test- und Architektur-Verifikationsverfahren — Ein didaktisches Lehrdokument

## TL;DR
- Moderne Softwarequalität entsteht nicht durch mehr manuelles Code-Lesen, sondern durch **deterministische, automatisierte Prüf-Gates** in der CI/CD-Pipeline: Architekturtests, statische Analyse, Vertragstests, Property-/Fuzz-/Mutationstests und Abhängigkeitsanalyse bilden zusammen ein Sicherheitsnetz, das mit KI-Agenten wichtiger denn je wird.
- Der rote Faden: **Coverage lügt, Mutation Testing sagt die Wahrheit** — und die CRAP-Metrik (CRAP = comp²·(1−cov)³ + comp, Schwelle 30) verbindet Komplexität und Coverage zu einer Risikozahl. Robert C. Martin nutzt genau diese Metriken als "Wächter" für KI-generierten Code.
- Einstieg empfohlen mit den billigsten, deterministischsten Gates (Linting/SAST, ArchUnit, Dependency-Cycle-Checks), dann Property-based Testing, dann als "Härteprüfung" Mutation Testing und Fuzzing.

## Key Findings
1. **Architekturtests (Fitness Functions)** machen Diagramme überflüssig, indem Regeln wie "Domain darf nicht auf Web/DB zugreifen" als ausführbare Tests kodiert werden (ArchUnit u. a.). Freeze-Mechanismen erlauben schrittweise Einführung in Legacy-Code.
2. **Statische Analyse (SAST)** basiert auf AST → CFG → Datenfluss/Taint-Analyse; Metriken wie zyklomatische Komplexität (McCabe 1976) und kognitive Komplexität (SonarSource, White Paper von G. Ann Campbell, 10. September 2018; Metrik erstmals Dezember 2016 in SonarCloud) sowie die Martin-Metriken (Instabilität, Distance from Main Sequence) quantifizieren Wartbarkeit.
3. **Vertragstests** lösen die Integrationstest-Explosion in Microservices; Pact (consumer-driven) mit Broker und `can-i-deploy` ist der De-facto-Standard.
4. **Property-based Testing** prüft Invarianten statt Beispiele; **Fuzzing** ist coverage-gesteuertes Property-Testing für Robustheit/Sicherheit; **Mutation Testing** misst die echte Qualität der Testsuite.
5. **Uncle Bobs Multi-Agenten-Pipeline** (Specifier → Coder → Cleaner → Architect → Hardener → QA, Projekt "SwarmForge") verkörpert "verification-first development" mit deterministischen Gates statt LLM-Urteilen.
6. **Deep Modules** (Ousterhout) stehen im spannungsreichen, aber teils versöhnbaren Verhältnis zu Uncle Bobs "kleinen Funktionen" — für KI-Kontextfenster besonders relevant.

## Details

### Einleitung: Der rote Faden

Alle behandelten Verfahren teilen ein gemeinsames Ziel: **objektive, automatisierbare Aussagen über Qualität**, die nicht auf menschliche Wachsamkeit oder das Urteil eines LLM angewiesen sind. Ordnet man sie ein:

- **Testpyramide** (unten breit, oben schmal): Unit-Tests → Integrations-/Vertragstests → E2E. Property-based, Fuzz und Mutation Testing verstärken die Unit-Ebene; Contract Testing ersetzt große Teile der Integrations-/E2E-Ebene.
- **Test-Quadranten** (Brian Marick): Technologie- vs. Business-orientiert, teamunterstützend vs. produktkritisierend. SAST, Architekturtests, Mutation Testing sitzen im technologiegetriebenen, teamunterstützenden Quadranten (Q1); Fuzzing/Performance im produktkritisierenden Q4.
- **Shift Left**: Fehler früh und billig finden. Deterministische Gates in der Pipeline verschieben Feedback von der Produktion in den Pull Request.

Der 2026 besonders akute Treiber: KI-Agenten schreiben Code schneller, als Menschen ihn lesen können. Robert C. Martin ("Uncle Bob") formulierte auf X: *"I don't review code written by agents. I measure things like test coverage, dependency structure, cyclomatic complexity, module sizes, mutation testing, etc. ... The code itself I leave to the AI. Humans are slow at code."* Damit werden die hier beschriebenen Verfahren von "nice to have" zu tragenden Säulen.

---

### 1. Architekturtests / Fitness Functions

**Was ist das?** Eine *Fitness Function* ist laut Neal Ford, Rebecca Parsons und Patrick Kua ("Building Evolutionary Architectures", 2017) "jeder Mechanismus, der eine objektive Integritätsbewertung einer oder mehrerer Architektur-Charakteristiken vornimmt". Architekturtests sind die konkrete, ausführbare Form davon: Regeln über die zulässige Struktur des Codes (Schichten, Modulgrenzen, Zyklenfreiheit), die wie Unit-Tests in CI laufen.

**Warum braucht man es?** Ein Architekturdiagramm beantwortet die Frage "Was war die Absicht?" — nie die Frage "Wie sieht die Struktur heute wirklich aus?". Diagramme driften ab dem ersten Shortcut ab. Ein Fitness-Function-Test ist der Sensor, der diese Drift meldet. Besonders KIs richten schnell "architektonisches Chaos" an, weil sie lokal optimieren, ohne globale Struktur zu wahren.

**Wie funktioniert es unter der Haube?** ArchUnit importiert Bytecode/Klassenmetadaten, baut ein Modell von Klassen, Paketen, Methoden und deren Abhängigkeiten (Importe, Feldtypen, Methodenaufrufe) und wertet darauf Prädikate aus. "Slices" gruppieren verwandte Pakete; Zyklen-Checks arbeiten graphenbasiert auf diesen Slices.

**Tools & Code:**

*ArchUnit (Java) — Schichtenregel:*
```java
@AnalyzeClasses(packages = "com.example.shop")
class ArchitectureTest {

    @ArchTest
    static final ArchRule domain_darf_nicht_auf_web_oder_db_zugreifen =
        noClasses().that().resideInAPackage("..domain..")
            .should().dependOnClassesThat()
            .resideInAnyPackage("..web..", "..persistence..");

    @ArchTest
    static final ArchRule schichten =
        layeredArchitecture().consideringAllDependencies()
            .layer("Controller").definedBy("..web..")
            .layer("Service").definedBy("..service..")
            .layer("Persistence").definedBy("..persistence..")
            .whereLayer("Controller").mayNotBeAccessedByAnyLayer()
            .whereLayer("Service").mayOnlyBeAccessedByLayers("Controller")
            .whereLayer("Persistence").mayOnlyBeAccessedByLayers("Service");

    @ArchTest
    static final ArchRule keine_zyklen =
        slices().matching("..shop.(*)..").should().beFreeOfCycles();
}
```

*Onion/Hexagonal Architecture:* ArchUnit bietet `onionArchitecture()` mit `domainModels`, `domainServices`, `applicationServices` und `adapter`. Adapter dürfen Domain nutzen, Domain aber keine Adapter.

*Freeze für Legacy:* `FreezingArchRule.freeze(rule)` speichert bestehende Verstöße beim ersten Lauf in einem `ViolationStore` und lässt den Build danach nur bei *neuen* Verstößen fehlschlagen — der Schlüssel zur Einführung in Altbestände ohne z. B. 200 sofortige Fehler.

**Äquivalente in anderen Ökosystemen:**
- **.NET:** ArchUnitNET, NetArchTest
- **Python:** import-linter (Contracts wie `layers`, `forbidden`, `independence` in `.importlinter`), PyTestArch
- **JS/TS:** dependency-cruiser (Regeln + Graph), ts-arch, eslint-plugin-boundaries
- **PHP:** Deptrac
- **Go:** go-arch-lint (Go verbietet Import-Zyklen ohnehin auf Compilerebene)

**Fallstricke:** (a) Package-by-feature-Codebasen haben keine Layer-Pakete zum Anzeigen — dann Regeln über Namenskonventionen/Annotationen. (b) Zu strenge Regeln gegen Altbestand ohne Freeze führen dazu, dass das Team die Regel wieder löscht. (c) Regeln müssen mitwachsen; veraltete Regeln erzeugen Rauschen.

**Wann NICHT?** Bei winzigen Prototypen/Wegwerfcode oder wenn es (noch) keine bewusste Schichtung gibt — dann erst Struktur definieren.

---

### 2. Statische Code-Analyse (SAST)

**Was & warum?** SAST analysiert Quellcode/Bytecode ohne Ausführung, um Bugs, Sicherheitslücken und Wartbarkeitsprobleme früh zu finden. Sie ist eine Form der Fitness Function.

**Unter der Haube:** Pipeline Lexer → Parser → **AST** (Abstrakter Syntaxbaum) → **CFG** (Control Flow Graph) → **Datenflussanalyse** → **Taint Analysis** (Verfolgung "verschmutzter" Eingaben von *Sources*, z. B. `request.getParameter`, zu *Sinks*, z. B. SQL-Ausführung) → optional **symbolische Ausführung** (Pfadbedingungen als Formeln, per SMT-Solver gelöst). CodeQL modelliert Code sogar als relationale Datenbank und lässt Queries darauf laufen.

**Metriken mit Berechnung:**
- **Zyklomatische Komplexität (T. J. McCabe, "A Complexity Measure", IEEE TSE Vol. SE-2, No. 4, Dez. 1976, S. 308–320):** M = E − N + 2P (E = Kanten, N = Knoten, P = verbundene Komponenten im CFG). Praktisch: 1 + Anzahl Verzweigungspunkte. Misst Anzahl unabhängiger Pfade = Mindestanzahl Testfälle. Das NIST übernahm später eine empfohlene Höchstgrenze von **10 pro Funktion** — eine Schwelle, die viele Teams bis heute verwenden.
- **Kognitive Komplexität (SonarSource, White Paper von G. Ann Campbell, 10. September 2018; erstmals Dezember 2016 in SonarCloud eingeführt):** Startet bei 0, erhöht sich bei Bruch des linearen Flusses und bestraft Verschachtelung progressiv. Ignoriert Shorthand-Strukturen. Ein flacher `switch` mit 20 Fällen: hohe zyklomatische, niedrige kognitive Komplexität. Verschachtelte `if` in `while`: umgekehrt. Beispiel aus SonarSource-Trainingsmaterial: zwei funktional identische Methoden mit gleicher zyklomatischer Komplexität (11), aber kognitiver Komplexität 11 (switch) vs. 27 (nested ifs). Eine empirische Validierung (Muñoz Barón, Wyrich, Wagner, Uni Stuttgart, ESEM 2020, arXiv:2007.12520) über 22 Projekte fand, dass die Metrik gut mit menschlicher Verständlichkeit korreliert.
- **Kopplung (Robert C. Martin):** Afferente Kopplung Ca (wie viele hängen von mir ab), efferente Ce (von wie vielen hänge ich ab). **Instabilität I = Ce / (Ca + Ce)** ∈ [0,1]. **Abstraktheit A** = abstrakte Typen / alle Typen. **Distance from Main Sequence D = |A + I − 1|**: Ideal liegen Pakete auf der Linie A+I=1. "Zone of Pain" (I≈0, A≈0: stabil und konkret) und "Zone of Uselessness" (I≈1, A≈1) sind zu meiden. **SDP (Stable Dependencies Principle):** Abhängigkeiten sollen zu stabileren Komponenten zeigen (zu niedrigerem I).
- **Halstead-Metriken (1977):** aus η₁ (distinkte Operatoren), η₂ (distinkte Operanden), N₁, N₂: Vokabular η=η₁+η₂, Länge N=N₁+N₂, **Volumen V = N·log₂(η)**, Schwierigkeit D=(η₁/2)·(N₂/η₂), Aufwand E=D·V.
- **Maintainability Index (Oman & Hagemeister 1992, MS-Variante):** MI = MAX(0, (171 − 5,2·ln(V) − 0,23·CC − 16,2·ln(LOC))·100/171). 0–9 niedrig, 10–19 moderat, 20–100 hoch (MS/Visual-Studio-Schwellen).

**Tools:** SonarQube/SonarCloud (Quality Gates, kognitive Komplexität als First-Class-Regel), Semgrep (regelbasiert, Syntax ähnelt Zielcode; Cross-File-Taint nur in Pro), CodeQL (semantisch, tief), Snyk Code, Checkmarx, PMD, SpotBugs (Java), ESLint (JS/TS), Ruff/Bandit/mypy (Python).

**False Positives, Quality Gates, technische Schuld:** SAST hat laut Branchenquellen (Konvu-Vergleich 2026) deutlich höhere False-Positive-Raten (15–60 %) als SCA (2–10 %). Ein *Quality Gate* ist eine Pass/Fail-Schwelle (z. B. "keine neuen Blocker, Coverage auf neuem Code ≥ 80 %"). *Technische Schuld* (Ward Cunningham) = zukünftiger Mehraufwand durch heutige Abkürzungen; SonarQube schätzt sie in Zeit.

**Abgrenzung:**
- **SAST** — statisch, Quellcode, findet Code-Level-Bugs, keine Laufzeit-/Konfigfehler.
- **DAST** — dynamisch, laufende App von außen (Auth-Bypass, CORS, Serverfehler).
- **IAST** — Instrumentierung zur Laufzeit, kombiniert Innensicht + Ausführung.
- **SCA** — analysiert Abhängigkeiten (CVEs, Lizenzen), niedrige False-Positive-Rate.

**Wann NICHT/vorsichtig?** Metriken nie blind als Ziel setzen (Goodharts Gesetz); MI und Halstead ignorieren Namensgebung und Semantik — nur als Wegweiser nutzen.

---

### 3. Vertragstests / Contract Testing

**Problem:** In Microservices explodiert die Zahl der Integrationspunkte. Vollständige E2E-Tests, die alle Services hochfahren, sind langsam, brüchig und teuer. Die Testpyramide fordert stattdessen viele schnelle Tests unten.

**Consumer-Driven Contract Testing (Pact):** Der *Consumer* definiert in einem Test gegen einen **Mock-Server** genau die Interaktionen (Requests/Responses), die er wirklich nutzt. Daraus entsteht eine versionierte JSON-Datei (das "Pact"). Der *Provider* verifiziert später gegen seine echte Implementierung, dass er diese Erwartungen erfüllt. **Wichtig: Consumer und Provider laufen nie gleichzeitig.**

**Ablauf Schritt für Schritt:**
1. Consumer-Test läuft gegen Pact-Mock → erzeugt Pact-Datei.
2. Pact wird zum **Pact Broker / PactFlow** publiziert (Vertrags-Registry + Verifikationsergebnisse + Deployment-Metadaten).
3. Provider holt Pacts, spielt Requests gegen sich selbst ab. **Provider States** (`given("ein User mit id 10 existiert")`) richten deterministische Vorbedingungen ein (in Java `@State`-Methode), damit `GET /users/10` nicht fälschlich 404 liefert.
4. Verifikationsergebnisse gehen zurück zum Broker.
5. **`can-i-deploy`** fragt den Broker vor jedem Deploy: Ist diese Version mit allen aktuell in der Zielumgebung laufenden Versionen kompatibel? Nur dann wird deployt.
6. **Pending/WIP Pacts** verhindern, dass neue Consumer-Erwartungen fremde Pipelines blockieren.

*Consumer-Beispiel (Pact JS, vereinfacht):*
```javascript
const { PactV4, MatchersV3 } = require('@pact-foundation/pact');
const { like } = MatchersV3;

const provider = new PactV4({ consumer: 'WebApp', provider: 'UserAPI' });

test('GET /users/10', () =>
  provider
    .addInteraction()
    .given('ein User mit id 10 existiert')
    .uponReceiving('eine Anfrage nach User 10')
    .withRequest('GET', '/users/10')
    .willRespondWith(200, b =>
      b.jsonBody(like({ id: 10, name: like('Alice') })))
    .executeTest(async (mock) => {
      const res = await getUser(mock.url, 10);
      expect(res.name).toBe('Alice');
    }));
```

**Weitere Ansätze:**
- **Spring Cloud Contract:** Contracts in Groovy/YAML; generiert Provider-Tests und Consumer-Stubs.
- **Bi-Directional Contract Testing (PactFlow):** Provider stellt OpenAPI-Spec bereit, Consumer-Erwartungen werden dagegen abgeglichen — weniger Kopplung zwischen Teams.
- **OpenAPI/JSON-Schema-basiert:** Schema-Tests prüfen Struktur, wissen aber nicht, *welches* Feld ein Consumer wirklich nutzt — genau der Vorteil von CDC.
- **Schema Registry bei Kafka (Avro/Protobuf/JSON Schema):** Confluent Schema Registry erzwingt Kompatibilitätsregeln (BACKWARD/FORWARD/FULL) bei der Schema-Evolution. Subjects wie `orders-value`. Für Events gibt es zusätzlich Pact Message Pacts.

**Strukturelle vs. semantische Kompatibilität:** Ein Schema kann strukturell kompatibel sein (Feld existiert), aber semantisch brechen (Bedeutung ändert sich). Contract Testing prüft primär Struktur/erwartete Werte; Semantik braucht ergänzende Tests.

**Abgrenzung zu E2E:** Ein kleines Set kritischer E2E-Journeys behalten; Contract Tests decken die Breite der Integrationspunkte ab, die E2E nicht bezahlbar abbilden kann.

**Fallstricke:** Provider States nicht sauber aufsetzen (Verifikation scheitert aus falschem Grund); exakte Werte statt Matcher (`like`, `eachLike`) → brüchige Contracts. **Achtung KI:** Wenn derselbe Agent beide Seiten schreibt, kann er den Contract mitverbiegen — genau die Drift, die unabhängige Verifikation aufdecken soll.

---

### 4. Dependency-Analysis

**Abhängigkeitsgraph & Zyklen:** Das **Acyclic Dependencies Principle (ADP, R. C. Martin)** verlangt: Der Abhängigkeitsgraph der Komponenten muss zyklenfrei sein (ein DAG). Zyklen erzeugen enge Kopplung (Module nicht einzeln wiederverwendbar/testbar), Domino-Effekte, mögliche Endlosrekursionen und Memory-Leaks.

**Auflösung von Zyklen** (zwei klassische Strategien laut ADP):
1. **Dependency Inversion:** Eine Schnittstelle einführen, sodass beide von der Abstraktion abhängen statt voneinander.
2. **Gemeinsames Modul extrahieren:** Die geteilte Abhängigkeit in ein neues Paket ziehen.
Ergänzend: **Interface Segregation** und Beachtung von **SDP** (Abhängigkeit zu Stabilem) und **SAP** (Stable Abstractions Principle: stabile Pakete sollen abstrakt sein).

**Weitere Themen:**
- **Ungenutzte Pakete** (deptry, depcheck), **transitive Abhängigkeiten** (indirekt hereingezogen).
- **Supply-Chain-Sicherheit & SBOM:** Software Bill of Materials in **CycloneDX** (OWASP, sicherheitsfokussiert) oder **SPDX** (Linux Foundation, lizenzfokussiert). Bei Log4Shell fanden Organisationen mit SBOM betroffene Systeme in Minuten statt Tagen. Zunehmend regulatorisch gefordert (US EO 14028, EU Cyber Resilience Act).
- **Lizenzkonflikte:** Copyleft (GPL) vs. permissiv (MIT/Apache) — Copyleft in proprietärem Produkt ist ein Risiko.
- **CVE-Scanning:** Abgleich Paketversionen gegen Schwachstellendatenbanken.

**Tools:** dependency-cruiser/madge/dpdm (JS/TS), jdeps/JDepend (Java), pipdeptree/pydeps/pylint-cyclic-import (Python), deptry/depcheck (ungenutzt), OWASP Dependency-Check/Trivy/Grype (CVE), Renovate/Dependabot (Update-Automation), Nx/Turborepo Graph (Monorepo).

*Beispiel dependency-cruiser (Zyklen verbieten):*
```json
{
  "forbidden": [
    { "name": "no-circular", "severity": "error",
      "from": {}, "to": { "circular": true } }
  ]
}
```

**Wann NICHT?** Zyklenfreiheit auf Klassenebene ist manchmal überzogen (Domänenmodelle haben natürliche wechselseitige Bezüge); Fokus auf Modul-/Paketebene.

---

### 5. Property-Based Testing (PBT)

**Konzept:** Statt fixer Beispiele (`sort([3,1,2]) == [1,2,3]`) definiert man **Eigenschaften/Invarianten, die für ALLE Eingaben gelten** (`sort(sort(x)) == sort(x)`). Das Framework generiert hunderte Zufallseingaben inkl. Randfälle (0, 1, MAX) und sucht Gegenbeispiele.

**Drei Kernkomponenten (QuickCheck-Linie, Claessen & Hughes, ICFP 2000):**
- **Generatoren/Arbitraries:** erzeugen Eingaben nach Constraints.
- **Properties:** die zu prüfenden Invarianten.
- **Shrinking:** minimiert ein gefundenes Gegenbeispiel automatisch auf die kleinste fehlschlagende Form (z. B. 776.837 → 1) — entscheidend fürs Debugging. **Seeds** machen Läufe reproduzierbar; gefundene Fälle werden gespeichert (Hypothesis-DB).

**Typische Property-Muster:**
- **Round-Trip/Inverse:** `decode(encode(x)) == x`
- **Idempotenz:** `f(f(x)) == f(x)`
- **Kommutativität:** `f(a,b) == f(b,a)`
- **Orakel/Modellvergleich (differential):** Ergebnis gegen Referenzimplementierung prüfen.
- **Invarianten:** z. B. sortierte Liste ist nicht-absteigend; Länge bleibt erhalten.
- **Metamorphic Testing:** bekannte Relation zwischen Ein-/Ausgaben mehrerer Aufrufe.

*Hypothesis (Python):*
```python
from hypothesis import given, strategies as st

@given(st.lists(st.integers()))
def test_sort_idempotent(xs):
    assert sorted(sorted(xs)) == sorted(xs)

@given(st.text())
def test_roundtrip(s):
    assert decode(encode(s)) == s
```

*jqwik (Java):*
```java
@Property
void absIstNichtNegativ(@ForAll int x) {
    assertThat(Math.abs((long) x)).isGreaterThanOrEqualTo(0);
}
```
Default 1.000 Tries, integriertes Shrinking; konfigurierbar via `@Property(tries = 5000, shrinking = ShrinkingMode.OFF)`.

*fast-check (JS/TS):*
```javascript
import fc from 'fast-check';
test('reverse zweimal', () => {
  fc.assert(fc.property(fc.array(fc.integer()),
    xs => expect([...xs].reverse().reverse()).toEqual(xs)));
});
```

**Frameworks:** QuickCheck (Haskell, Original), Hypothesis (Python, Goldstandard), jqwik/junit-quickcheck (Java), fast-check (JS/TS), PropEr (Erlang), FsCheck (.NET), proptest/QuickCheck (Rust), ScalaCheck.

**Stateful/Model-based PBT:** Sequenzen von Kommandos gegen ein vereinfachtes Modell prüfen (Hypothesis `RuleBasedStateMachine`, jqwik State-based). Findet Bugs in zustandsbehafteten Systemen.

**Fallstricke:** schlecht gewählte Generatoren (hohe Verwerfungsrate bei Assumptions), DB-Setup macht Tests langsam (erst reine Domänenlogik), "All tests passed" ohne zu prüfen, ob die Generatoren den Code wirklich abdecken.

**Wann NICHT?** Wenn keine sinnvolle Invariante formulierbar ist oder Eingaberaum trivial; dann reichen Beispiel-Tests.

---

### 6. Fuzz Testing

**Grundlagen:** Fuzzing füttert ein Programm mit massenhaft (semi-)zufälligen Eingaben, um Abstürze zu provozieren.
- **Dumb vs. Smart:** ohne vs. mit Kenntnis des Eingabeformats.
- **Mutation-based vs. Generation-based:** bestehende Seeds mutieren vs. aus Grammatik/Modell erzeugen.
- **Coverage-guided (AFL/AFL++, libFuzzer, honggfuzz):** Instrumentierung misst erreichte Code-Kanten; Eingaben, die *neue* Coverage bringen, kommen ins **Corpus** und werden weiter mutiert. So findet der Fuzzer evolutionär tiefe Pfade. libFuzzer nutzt LLVMs SanitizerCoverage; die Original-Autoren arbeiten inzwischen an Centipede, libFuzzer ist im Maintenance-Modus.
- **Seeds/Corpus:** Startbeispiele; `-merge=1` minimiert Corpora.
- **Sanitizer:** ASan (Speicherfehler, use-after-free), UBSan (undefiniertes Verhalten), MSan (uninitialisierter Speicher), LeakSanitizer. Fast Standard in Fuzz-Builds.

**Was Fuzzing findet:** Abstürze, Pufferüberläufe, Speicherlecks, Endlosschleifen (Timeouts), Panics, Deserialisierungsfehler, Assertion-Verletzungen.

**Tools nach Sprache:**
- **C/C++:** libFuzzer, AFL++, honggfuzz.
- **Go:** natives Fuzzing seit Go 1.18 (`func FuzzXxx(f *testing.F)` mit `f.Add` Seeds und `f.Fuzz`), älteres go-fuzz.
- **Rust:** cargo-fuzz (libFuzzer-basiert).
- **JVM:** Jazzer (coverage-guided, in-process; `@FuzzTest`; JaCoCo-basierte Kantenabdeckung; JUnit5-Integration).
- **Python:** Atheris (Google, libFuzzer-basiert; `TestOneInput(data)`, `FuzzedDataProvider`, `instrument_imports()`).
- **Continuous Fuzzing:** OSS-Fuzz (Google, große Open-Source-Projekte), ClusterFuzz, CIFuzz (Fuzzing im CI).

*Go natives Fuzzing:*
```go
func FuzzParse(f *testing.F) {
    f.Add("hello=world")
    f.Fuzz(func(t *testing.T, s string) {
        _ = Parse(s) // darf nie paniken
    })
}
```

*Jazzer (JVM):*
```java
@FuzzTest
void fuzzDecode(FuzzedDataProvider data) {
    byte[] input = data.consumeRemainingAsBytes();
    try { MyDecoder.decode(input); }
    catch (IllegalArgumentException expected) {} // ok
}
```

**Fuzzing ↔ PBT:** Beide erzeugen Eingaben und suchen Gegenbeispiele. Unterschied: **PBT prüft semantische Eigenschaften** mit typisierten Generatoren und Shrinking (Korrektheit); **Fuzzing ist coverage-gesteuert und robustheits-/sicherheitsorientiert**, arbeitet meist auf rohen Bytes und läuft lange. Es gibt starke Überschneidung — jqwik/Hypothesis können fuzz-artig laufen, Fuzzer können Properties (Assertions) prüfen.

**Fallstricke:** in-process-Fuzzing ist fragil (globaler Zustand); nicht-deterministische Targets; Corpus-Explosion; ohne Sanitizer werden viele Speicherfehler nicht sichtbar.

**Wann NICHT?** Für reine Business-Logik mit klaren Invarianten ist PBT zielgerichteter; Fuzzing lohnt v. a. an Parsern, Deserialisierern, Datei-/Netzwerk-Eingängen, Krypto, nativem Code.

---

### 7. Snapshot Testing (Approval / Golden Master)

**Konzept:** Die erzeugte Struktur (UI-Baum, JSON, AST, gerendertes HTML) wird beim ersten Lauf als **Referenz-Snapshot** gespeichert. Spätere Läufe vergleichen dagegen und zeigen ein Diff bei Abweichung. Snapshot-Tests behaupten nur "gleich wie vorher" — **nicht** "korrekt".

**Tools:** Jest (`toMatchSnapshot`, Inline-Snapshots, `-u` zum Update), Vitest, Verify (.NET), ApprovalTests, Snapper (C#), syrupy (Python), insta (Rust). **Visual Regression:** Playwright, Percy, Chromatic.

*Jest:*
```javascript
test('rendert Button', () => {
  expect(render(<Button label="OK" />)).toMatchSnapshot();
});
```
In CI verweigert Jest das Schreiben fehlender Snapshots und schlägt fehl — so werden nicht committete Snapshots erkannt.

**Golden Master / Characterization Tests (Michael Feathers):** Technik für Legacy-Code, den man nicht versteht: Man fängt das *aktuelle* Verhalten über viele Parameter-Kombinationen ein, um beim Refactoring ein Sicherheitsnetz zu haben — ohne den Code verstehen zu müssen. Ziel ist Dokumentation des Ist-Verhaltens, nicht des Soll.

**Vor-/Nachteile:** Schnell hohe Abdeckung, serialisierbar, im Code-Review sichtbar. Aber: **"Snapshot Rot"** (veraltete Snapshots), **blindes Akzeptieren** von Änderungen mit `-u`, **Determinismus-Probleme** (Zeitstempel, IDs, Sortierung, Zufall) → Property-Matcher/Serializer nötig, große Snapshots werden unlesbar.

**Wann NICHT?** Für Kern-Business-Logik lieber explizite Assertions; Snapshots eignen sich für Repräsentation/Serialisierung. Nie ohne Diff-Review updaten.

---

### 8. CRAP-Metrik

**Formel:** CRAP(m) = comp(m)² × (1 − cov(m)/100)³ + comp(m), mit comp = zyklomatische Komplexität und cov = Coverage in Prozent.

**Herkunft:** Eingeführt am **2. Oktober 2007 von Alberto Savoia und Bob Evans** (Agitar Labs). Primärquelle: Alberto Savoia, *"The Code C.R.A.P. Metric Hits the Fan – Introducing the crap4j Plug-in"* (Artima/Agitar, 2. Oktober 2007): *"my Agitar Labs colleague Bob Evans and I have been experimenting with a metric ... The Change Risk Analysis and Prediction (CRAP) score."* Das Akronym wird kanonisch als *Change Risk Analysis and Predictions* aufgelöst (teils auch als *Change Risk Anti-Patterns*). Schwelle im Original: **30**; projektweit galten bis zu 5 % "crappy" Methoden als tolerabel.

**Interpretation:**
- Triviale Methode (CC=1, 100 % Coverage): CRAP = 1 (untere Schranke).
- Bei 100 % Coverage kollabiert der quadratische Term und CRAP = CC.
- Ab CC ≈ 30 hält keine Coverage den Wert mehr unter 30 → refactorn.
- Coverage-Tabelle aus der Crap4j-FAQ/Savoia (Coverage, die nötig ist, um unter 30 zu bleiben): CC 0–5 → 0 %, 6–10 → 42 %, 11–15 → 57 %, 16–20 → 71 %, 21–25 → 80 %, 26–30 → 100 %, 31+ → "Time to refactor".

**Tools:** Crap4j (Java, historisch), PHPUnit CRAP-Index, Clover, cargo-crap (Rust), crap4dotnet (.NET, Schwelle default 30), Uncle Bobs eigenes crap4java.

**Kritik:** Composite-Zahl — schwer zu sehen, *was* sie treibt; belohnt evtl. Coverage-Fixierung; sagt nichts über Testqualität (nur -menge) — daher Ergänzung durch Mutation Testing. Sie ist ein Risiko-Wegweiser, kein Ziel an sich.

**Uncle Bob & KI-Komplexitätsgrenzen — Faktenlage (wichtig, mit Korrektur):** Robert C. Martin empfiehlt konkret: *"Reduce all functions below a CC of 4 or so."* Er beschreibt CRAP als "cyclomatic complexity mixed with code coverage" (X, ~Juli 2026). **Die im Umlauf befindliche Behauptung, er erlaube KI-Agenten explizit eine höhere Komplexität (6 oder 8) wegen deren größerem/präziserem Kurzzeitgedächtnis, ließ sich in Primärquellen NICHT belegen.** Im Gegenteil argumentiert Martin, dass Agenten sich an unsauberem Code genauso verheddern wie Menschen (*"Messy code slows my agents down ... I constrain the hell out"*) und deshalb *strikt* auf CC < 4 begrenzt werden. Die Zahlen "6" bzw. "8" stammen aus einem Drittanbieter-Tutorial (Medium, Adrian Bailador, `dotnet crap --threshold 6`, Beispiel `// complexity: 8`) — nicht aus Martins eigenen Aussagen und ohne Kurzzeitgedächtnis-Begründung. Dieses Dokument stellt die Sachlage daher richtig: verbürgt ist CC < 4 als Zielwert, den Martin auf KI-Output anwendet. (Ein von einem Blogger stammender Paraphrase-Satz *"the threshold may sit higher, but the threshold is still there"* ist keine Martin-Aussage und nicht mit Arbeitsgedächtnis begründet.)

---

### 9. Mutation Testing

**Grundlagen:** Ein Mutation-Testing-Tool erzeugt **Mutanten** — kleine Änderungen am Produktionscode via **Mutationsoperatoren** — und lässt die Testsuite dagegen laufen. Fällt mindestens ein Test → Mutant **getötet** (gut). Fällt keiner → Mutant **überlebt** (Testlücke).

**Typische Operatoren:** Konditionalgrenzen (`<` ↔ `<=`), Negation von Bedingungen, Rückgabewerte ersetzen, Increments (`++`↔`--`), Void-Method-Calls entfernen, arithmetische Operatoren tauschen.

**Mutation Score = detektierte / valide Mutanten × 100.** Zustände (Stryker): Killed, Survived, Timeout (zählt als detektiert), No Coverage (separat, nicht in Score), Compile-/Runtime-Error (invalid). **Äquivalente Mutanten** ändern das Verhalten nicht und sind prinzipiell nicht tötbar — das Kernproblem (verzerrt den Score, manuelle Prüfung nötig). **Performance:** rechenintensiv (jeder Mutant × Testlauf); Optimierungen: nur betroffene Tests, Coverage-Filter, Inkrementalität.

**Tools:** PIT/Pitest (Java; Operatoren wie RetStaRep/FunCalDel u. a. auch integrationsrelevant), Stryker Mutator (JS/TS, C#, Scala), mutmut/cosmic-ray (Python), Infection (PHP), cargo-mutants (Rust).

*Stryker (JS) Konzept:* ändert `price <= 0` zu `price < 0`; überlebt der Mutant, fehlt ein Test für die Grenze.

**Warum es die echte Testqualität misst:** Coverage sagt nur, welche Zeilen *ausgeführt* wurden — nicht, ob ein Test bei falschem Verhalten *fehlschlägt*. Man kann 100 % Coverage mit Tests ohne Assertions haben. Mutation Testing deckt genau diese blinden Flecken auf.

**Einsatz als Härteprüfung für KI-generierte Tests:** KI-Agenten neigen zu Tests, die Coverage erzeugen, aber schwach assertieren. Mutation Testing "mutiert den Code gnadenlos" (z. B. Umkehr von Gleichheitszeichen) und prüft, ob die Suite wirklich rot wird — die Rolle des "Hardener"-Agenten (s. u.).

**Fallstricke:** äquivalente Mutanten, lange Laufzeiten, zu hoher Score-Zielwert (nicht 100 % erzwingen — auf risiko-/geschäftskritische Module fokussieren).

**Wann NICHT?** Auf trivialem Code oder ganzer riesiger Codebasis in jedem Commit zu teuer; gezielt und/oder inkrementell einsetzen.

---

### 10. Multi-Agenten-Testpipeline für KI-gestützte Entwicklung

**Uncle Bobs Agentenkette (Projekt "SwarmForge", auf X beschrieben, Repo unclebob/swarm-forge, gestartet 17.04.2026):** Jeder Agent läuft in eigener tmux-Session/eigenem Git-Worktree, mit einer Rolle aus dem Craftsmanship-Playbook. Menschliche Interaktion nimmt pro Stufe ab; jede Stufe ist formaler als die vorige. Die Kette ("six-pack"):

1. **Specifier** — wandelt ein menschliches Dokument in **Gherkin**-Akzeptanztests + eine benutzerorientierte, UI-getriebene QA-Prozedur. (Diese reviewt der Mensch — mal gründlich, mal Stichprobe.)
2. **Coder** — implementiert Funktionalität, schreibt Unit-Tests und das Acceptance-Test-Harness, bis alle Gherkin-Tests grün sind.
3. **Cleaner** — erzwingt Qualitäts-Gates **DRY** und **CRAP**, refactort iterativ Code und Tests, bis beide Gates erfüllt sind.
4. **Architect** — verwaltet Module und Abhängigkeitsrichtungen (Struktur, Zyklen).
5. **Hardener** — führt **Mutationstests** (Sprach-Ebene und Gherkin-Ebene) durch; rechenintensiv "by design", umgibt den Code mit hoher Test-Resilienz.
6. **QA** — verwandelt die QA-Prozedur in ausführbare UI-Skripte und prüft das System deterministisch an der Oberfläche.

Martins Kernaussage zum Modell: *"My agents write the unit tests. I don't review those. They also write the gherkin acceptance tests and the QA procedures. I review those ... depending on criticality."* Der Trade-off: Eine Aufgabe, die ein einzelner Agent in 5 Minuten (mit fragwürdigem Ergebnis) macht, dauert durch die "Gauntlet" ~1 Stunde — dafür strukturell höhere Qualität.

**Deterministische Gates vs. LLM-Judgement:** Zentrales Prinzip — *kein Agent kann ein fehlgeschlagenes Gate übergehen; er kann nur den Code ändern und die Checks erneut laufen lassen.* Die deterministischen Werkzeuge (Tests, CRAP, Mutation, ArchUnit-artige Regeln, Coverage) sind die "Wächter", weil LLM-Selbsteinschätzung unzuverlässig ist. Schmale Aufgaben halten das Kontextfenster klein, sodass die Regeln "haften".

**Kritische Gegenstimme:** Grady Booch widerspricht Martin öffentlich — Metriken gäben Vertrauen in Funktionalität, aber keinerlei Sicherheit gegen eingeschleuste Schwachstellen oder toten Code, die ein erfahrener Ingenieur "auf einen Blick" erkennt. Fair einzuordnen: Metrik-Gates und menschliches/zusätzliches Security-Review (SAST/SCA/DAST) ergänzen sich.

**Ähnliche Konzepte:** Spec-Driven Development (SDD) als Antwort auf "Vibe Coding"; **GitHub Spec Kit** (Open-Source-CLI, agenten-agnostisch, MIT-Lizenz, erstellt am 21.08.2025; laut star-history.com im August 2026 rund 120.200 GitHub-Stars, 10.700 Forks, 245 Contributors; Workflow `/speckit.specify → /speckit.implement`), **AWS Kiro** (spec-native IDE, EARS-Notation), Tessl, BMAD, OpenSpec; "verification-first"/test-first mit Coding-Agents.

---

### 11. Visuelle Architektur-Prüfung & harte Regeln

**Diagramm-/Viewer-Werkzeuge:** Mermaid (in GitHub-Markdown nativ gerendert), PlantUML (docs-as-code, volle UML), **Structurizr** (DSL, "model once, render many" für das **C4-Modell** von Simon Brown: Context/Container/Component/Code), Graphviz (große Dependency-Graphen), Nx Graph (Monorepo), CodeCharta/CodeScene (Verhaltens-/Hotspot-Analyse). Manche Tools (z. B. repowise) leiten die Architektur aus dem Repo ab und halten sie aktuell.

**Deterministische Erzwingung:** Der entscheidende Punkt — ein Diagramm ist "Feedforward ohne Sensor". Erst kombiniert mit deterministischen Regeln (ArchUnit, dependency-cruiser, import-linter) wird aus dem Bild ein Gate: Alarm bei zyklischen Abhängigkeiten, automatische Reparatur-Anleitung via Dependency Inversion. ArchUnit kann sogar gegen ein PlantUML-Modell prüfen (`adhereToPlantUmlDiagram`).

**Warum KIs Chaos anrichten & wie eindämmen:** LLMs optimieren lokal und "vergessen" globale Struktur, sobald sie außerhalb des Kontextfensters liegt. Eindämmung: (1) harte, deterministische Struktur-Gates; (2) Architect-Agent, der nur Abhängigkeiten überwacht; (3) automatische, stets aktuelle Graphen; (4) Deep Modules (kleine Interfaces), damit der Agent nicht die ganze Implementierung lesen muss.

---

### 12. Deep Modules (John Ousterhout, "A Philosophy of Software Design")

**Konzept:** Ein **tiefes Modul** verbirgt viel Funktionalität (komplexe Implementierung) hinter einer **kleinen, simplen Schnittstelle**. Das Gegenteil — **flache (shallow) Module** — hat eine Schnittstelle fast so komplex wie die Implementierung und bringt daher wenig Nutzen. Ousterhouts Beispiele für Tiefe: Unix-I/O (5 Funktionen verbergen enorme Komplexität), Garbage Collector (gar keine Schnittstelle). Er nennt die Neigung, alles in viele winzige Klassen zu zerlegen, **"Classitis"**.

**Interface- vs. Implementierungskomplexität:** Kosten eines Moduls = Komplexität seiner Schnittstelle; Nutzen = seine Funktionalität. Ein Modul wird zum Netto-Minus, wenn die Schnittstellenkosten den Nutzen übersteigen. **Information Hiding** ist der Schlüssel zu Tiefe; **Information Leakage** (Designentscheidung sickert in mehrere Module) und **temporale Dekomposition** (Struktur nach Ausführungsreihenfolge statt nach Wissen) sind Antimuster. Prinzip **"Different layer, different abstraction"**: Pass-Through-Methoden/-Variablen sind ein Red Flag; auch der Decorator wird von Ousterhout kritisch gesehen. Ousterhout identifiziert drei Erscheinungsformen von Komplexität: *Change amplification*, *cognitive load* und *unknown unknowns*.

**Warum für KI-Modelle vorteilhaft:** Ein Agent, der ein tiefes Modul *nutzt*, muss nur die kleine Schnittstelle lesen — nicht die gesamte Implementierung. Das spart Kontextfenster/Token-Budget und reduziert Fehler (Kontext-Engineering). Umgekehrt zwingen viele flache Module den Agenten, viele Interfaces zu lernen — teuer in Token und fehleranfällig.

**Der Ousterhout-vs-Martin-Disput — fair dargestellt:**
- **Uncle Bob (Clean Code):** Funktionen und Klassen sollen **klein** sein ("The first rule of functions is that they should be small. The second rule ... is that they should be smaller than that."), eine Sache tun, selbstdokumentierend statt kommentiert.
- **Ousterhout:** Größe allein ist nur ein Indikator, kein Ziel. Zu viele kleine Funktionen erzeugen flache Module, Zerstreuung und **erhöhte Schnittstellenkomplexität**; Kommentare seien fundamental für Abstraktionen; das Zerhacken zugunsten von "self-documenting code" könne schaden. Die beiden führten dazu eine bekannte, öffentlich dokumentierte Debatte.
- **Versöhnung:** Beide wollen **beherrschte Komplexität**. Cohesion und konsistente Abstraktionsebene (Ousterhout) sind die eigentliche Regel; Kleinheit (Martin) ist ein nützlicher Default, aber kein Selbstzweck. Praktisch: kleine Funktionen *innerhalb* tiefer Module — nicht viele flache Module mit breiten Schnittstellen.

---

### Übersichtstabelle: Verfahren → was es prüft → Tools → Aufwand → wann sinnvoll

| Verfahren | Prüft | Tool-Beispiele | Aufwand | Wann sinnvoll |
|---|---|---|---|---|
| Architekturtests / Fitness Functions | Schichten, Modulgrenzen, Zyklen | ArchUnit, ArchUnitNET, import-linter, dependency-cruiser, Deptrac | niedrig–mittel | sobald es bewusste Struktur gibt; KI-Projekte |
| Statische Analyse (SAST) | Bugs, Sicherheit, Komplexitäts-/Wartbarkeitsmetriken | SonarQube, Semgrep, CodeQL, PMD, SpotBugs, ESLint, Ruff/Bandit | niedrig | von Tag 1, in jeder Pipeline |
| Contract Testing | Kompatibilität Consumer↔Provider | Pact/PactFlow, Spring Cloud Contract, Schema Registry | mittel | Microservices, viele Integrationen |
| Dependency-Analysis | Zyklen, ungenutzt, CVEs, Lizenzen, SBOM | madge, jdeps, deptry, OWASP Dep-Check, Trivy, Renovate | niedrig | jedes Projekt mit Dependencies |
| Property-based Testing | Invarianten über alle Eingaben | Hypothesis, jqwik, fast-check, FsCheck, proptest | mittel | reine Logik, Parser, Encoder |
| Fuzz Testing | Abstürze, Speicherfehler, Robustheit | libFuzzer, AFL++, Jazzer, Atheris, go/cargo-fuzz, OSS-Fuzz | mittel–hoch | Parser, Deserializer, nativer/sicherheitskritischer Code |
| Snapshot / Golden Master | Ist-Ausgabe vs. Referenz | Jest, Vitest, Verify, syrupy, insta, Playwright | niedrig | UI, Serialisierung, Legacy-Refactoring |
| CRAP-Metrik | untested Komplexität (Risiko) | Crap4j, crap4dotnet, cargo-crap, PHPUnit | niedrig | Risiko-Priorisierung, KI-Output |
| Mutation Testing | echte Testsuite-Qualität | PIT, Stryker, mutmut, Infection, cargo-mutants | hoch | kritische Module, KI-Tests härten |
| Architektur-Visualisierung | Struktur sichtbar machen | Mermaid, PlantUML, Structurizr/C4, Graphviz, Nx | niedrig | Kommunikation + als Gate mit Regeln |

### CI/CD-Pipeline-Stufenfolge (Vorschlag)

Reihenfolge nach steigenden Kosten und "Fail fast":
1. **Lint & Format** (schnell, deterministisch).
2. **Build & Unit-Tests** inkl. Coverage.
3. **SAST + Architekturtests + Dependency-Cycle/Lizenz/CVE + SBOM** (parallelisierbar).
4. **Contract Tests** (Consumer publiziert Pact; Provider verifiziert) + `can-i-deploy`-Gate.
5. **Property-based Tests** (als Teil/Ergänzung der Unit-Stufe).
6. **Quality Gate** (SonarQube: Coverage/Komplexität/CRAP-Schwellen).
7. **Nightly/gesondert:** Mutation Testing (inkrementell), Continuous Fuzzing (CIFuzz/OSS-Fuzz).
8. **Deploy-Gate:** nur wenn alle deterministischen Gates grün.

*GitHub Actions (Skizze):*
```yaml
name: quality-gates
on: [pull_request]
jobs:
  static:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Lint
        run: npm ci && npm run lint
      - name: SAST (Semgrep)
        run: pipx run semgrep ci
      - name: Dependencies (Zyklen + Audit)
        run: npx depcruise src --validate && npm audit --audit-level=high
      - name: SBOM (CycloneDX)
        run: npx @cyclonedx/cyclonedx-npm --output-file sbom.json
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Unit + Property Tests
        run: npm ci && npm test -- --coverage
  arch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: '21' }
      - name: ArchUnit
        run: ./mvnw -q -Dtest=ArchitectureTest test
  mutation:
    if: github.event_name == 'schedule'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Stryker (inkrementell)
        run: npx stryker run --incremental
```

## Recommendations

**Lernpfad / Reihenfolge für ein Team:**
1. **Sofort (Woche 1):** Linting + SAST (SonarQube CE/Semgrep) und Dependency-Audit/CVE + SBOM einführen — billigste, deterministischste Gates. Quality Gate auf *neuem* Code, nicht auf Altbestand.
2. **Früh (Wochen 2–4):** Architekturtests mit ArchUnit (o. Ä.), zunächst mit **Freeze** gegen Legacy; Zyklen-Check aktivieren. Ein C4/Structurizr-Diagramm als Kommunikationsmittel.
3. **Mittel:** Property-based Testing für reine Logik/Parser/Encoder; bei Microservices Contract Testing mit Pact + `can-i-deploy`.
4. **Fortgeschritten:** Mutation Testing auf kritische Module (inkrementell), Fuzzing an Parsern/Deserializern (CIFuzz), CRAP zur Risiko-Priorisierung.
5. **KI-Workflow:** Erst wenn deterministische Gates stehen, lohnt eine Agentenkette (Specifier→…→Hardener→QA). Gates sind nicht verhandelbar; Agenten dürfen nur nachbessern.

**Benchmarks/Schwellen, die Entscheidungen ändern:**
- Zyklomatische Komplexität > 10 pro Methode (NIST-Richtwert) → refactorn; für KI-Output strebt Martin CC < 4 an.
- CRAP > 30 → testen oder refactorn.
- Mutation Score deutlich < ~70–80 % auf kritischen Modulen → Tests verstärken (aber nicht 100 % erzwingen).
- Neue zyklische Abhängigkeit → Build brechen; via Dependency Inversion/Extraktion auflösen.
- Contract-Verifikation rot oder `can-i-deploy` negativ → kein Deploy.

**Positionierung:** Verlasse dich für *Funktionalität* auf Metriken + Tests, aber ergänze für *Sicherheit* explizit SCA/DAST und — Boochs berechtigter Einwand — gezielte menschliche Reviews bei kritischen/security-relevanten Änderungen. Metriken sind Wächter, kein Ersatz für Bedrohungsmodellierung.

## Caveats
- **Uncle-Bob-KI-Komplexitätsgrenzen:** Die Aussage, er erlaube KI-Agenten CC 6/8 wegen größeren Kurzzeitgedächtnisses, ist **nicht primärbelegt** und steht im Widerspruch zu seinen tatsächlichen Aussagen (CC < 4, Agenten leiden unter Chaos wie Menschen). Als unbestätigt behandeln.
- Viele X-Zitate stammen aus Sekundärquellen (direkter X-Abruf war blockiert); Formulierungen sind über mehrere Quellen konsistent, Datierungen teils approximativ (April/Juli 2026).
- SwarmForge und die Agentenkette sind ein aktuelles, sich schnell entwickelndes Experiment Martins (Repo seit April 2026), kein etablierter Industriestandard.
- Zahlen zu Spec-Kit-Sternen, Kiro-Zeitersparnissen und SAST/SCA-False-Positive-Raten stammen aus Anbieter-/Blog-/Community-Quellen (z. B. star-history.com) und sind als Größenordnung, nicht als exakte Messung zu lesen.
- CRAP-Akronym: "Change Risk Analysis and Predictions" (kanonisch, Savoia 2007) vs. "Change Risk Anti-Patterns" (verbreitete Variante) — beide in Umlauf.
- Tool-Landschaft und Versionsstände ändern sich rasch (Stand 2026); libFuzzer im Maintenance-Modus (Nachfolger Centipede).

## Weiterführende Literatur
- Neal Ford, Rebecca Parsons, Patrick Kua: *Building Evolutionary Architectures* (O'Reilly, 2. Aufl. 2022) — Fitness Functions.
- Robert C. Martin: *Clean Architecture* (ADP, SDP, SAP, Instabilität/Abstraktheit) und *Clean Code*.
- John Ousterhout: *A Philosophy of Software Design* — Deep Modules, Information Hiding.
- Michael Feathers: *Working Effectively with Legacy Code* — Characterization Tests.
- G. Ann Campbell (SonarSource): *Cognitive Complexity — A new way of measuring understandability* (White Paper, 10. September 2018).
- Muñoz Barón, Wyrich, Wagner: *An Empirical Validation of Cognitive Complexity as a Measure of Source Code Understandability* (ESEM 2020, arXiv:2007.12520).
- T. J. McCabe: *A Complexity Measure* (IEEE TSE, Vol. SE-2, No. 4, 1976, S. 308–320).
- Oman & Hagemeister: *Metrics for assessing a software system's maintainability* (ICSM 1992).
- Alberto Savoia: *The Code C.R.A.P. Metric Hits the Fan – Introducing the crap4j Plug-in* (Artima/Agitar, 2. Oktober 2007).
- Koen Claessen, John Hughes: *QuickCheck* (ICFP 2000) — Property-based Testing.
- Offizielle Dokus: ArchUnit (archunit.org), Pact (docs.pact.io), Stryker (stryker-mutator.io), PIT (pitest.org), Hypothesis, jqwik (jqwik.net), fast-check, libFuzzer/AFL++, Jazzer, Atheris, OWASP CycloneDX, SonarSource.
- Robert C. Martin auf X (@unclebobmartin) 2026 zu KI-Agenten & SwarmForge; Cleancoders-Serie "Agentic Discipline".

## Glossar
- **AST** — Abstrakter Syntaxbaum, Baumdarstellung des Quellcodes.
- **CFG** — Control Flow Graph, Graph möglicher Ausführungspfade.
- **Taint Analysis** — Verfolgung nicht vertrauenswürdiger Daten von Source zu Sink.
- **Fitness Function** — automatisierte, objektive Prüfung einer Architektur-Charakteristik.
- **Slice** — Menge verwandter Pakete (ArchUnit) für Zyklen-/Unabhängigkeitschecks.
- **Freeze** — Bestehende Verstöße einfrieren, nur neue brechen den Build.
- **Consumer-Driven Contract** — Der Konsument definiert den Vertrag; Provider verifiziert.
- **Provider State** — deterministische Vorbedingung für die Provider-Verifikation.
- **can-i-deploy** — Broker-Gate, ob eine Version sicher deploybar ist.
- **Shrinking** — Minimierung eines Gegenbeispiels auf kleinste fehlschlagende Form.
- **Coverage-guided Fuzzing** — Fuzzing gesteuert durch Code-Coverage-Feedback.
- **Sanitizer** — Laufzeit-Instrumentierung (ASan/UBSan/MSan) zur Fehlererkennung.
- **Golden Master / Characterization Test** — Snapshot des Ist-Verhaltens als Refactoring-Netz.
- **Mutant / Mutation Score** — künstlicher Fehler / Anteil detektierter Mutanten.
- **Äquivalenter Mutant** — Mutant ohne Verhaltensänderung, nicht tötbar.
- **CRAP** — Change Risk Analysis and Predictions; comp²·(1−cov)³+comp.
- **Zyklomatische Komplexität** — Anzahl unabhängiger Pfade (M=E−N+2P).
- **Kognitive Komplexität** — Maß der Lesbarkeit, bestraft Verschachtelung.
- **Instabilität I / Abstraktheit A / Distance D** — Martin-Paketmetriken.
- **SBOM** — Software Bill of Materials (CycloneDX/SPDX).
- **ADP/SDP/SAP** — Acyclic/Stable Dependencies/Stable Abstractions Principle.
- **Deep/Shallow Module** — tiefes vs. flaches Verhältnis Interface:Implementierung.
- **Spec-Driven Development** — Spezifikation als primäres Artefakt für Coding-Agents.