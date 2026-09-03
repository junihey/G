---
tags: [learning, pre-use, verifikation]
created: 2026-09-01
topic: Welche automatisierten Pruefungen objektiv ueber Codequalitaet und Architektur urteilen, wie sie unter der Haube arbeiten und in welcher Reihenfolge man sie einfuehrt
verification: 'extern -- Werkzeuge, die es auch ohne diesen Vault gaebe; aus dem Research-Artifact "Test- und Architektur-Verifikationsverfahren", Stand 2026'
---

# Test- und Architektur-Verifikation

**Was diese Datei ist:** eine Einführung in die Verfahren, die eine Maschine über Code urteilen lassen statt einen Menschen — Architekturtests, statische Analyse, Vertragstests, Property- und Fuzz-Tests, Mutationstests, Abhängigkeitsanalyse.

**Wie sie zu lesen ist:** von oben nach unten. Die Abschnitte bauen aufeinander auf; Abschnitt 8 benutzt zwei Begriffe aus 6 und 7, und Abschnitt 15 setzt fast alle davor voraus. Rückwärts nachschlagen kannst du über die Nummern.

**Was hier nicht steht:** was davon in diesem Vault oder in smithy läuft — hier läuft nichts davon, das ist der Grund, warum die Datei in `pre-use\` liegt. Ebenso wenig Preise, Anbieter-Vergleiche oder wer wem auf X widerspricht.

---

## 1. Das Problem: ein Urteil, das kein Mensch fällen muss

Code-Qualität wurde lange durch Lesen gesichert: ein zweiter Mensch schaut sich die Änderung an und sagt ja oder nein. Das hat zwei Grenzen. Menschen lesen langsam, und zwei Menschen urteilen verschieden.

Beide Grenzen werden dringend, sobald ein KI-Agent den Code schreibt. Er schreibt schneller, als du lesen kannst, und wenn du ihn selbst um ein Urteil bittest, bekommst du eine Meinung von derselben Sorte Maschine, die den Code produziert hat.

Die Antwort darauf ist das **Gate** — eine Prüfung, die bei gleicher Eingabe immer dieselbe Antwort gibt, und deren Antwort nur „bestanden" oder „durchgefallen" lautet. Das Wort dafür ist **deterministisch**: kein Ermessen, keine Stimmung, keine Temperatur. Ein Gate lässt nicht mit sich reden.

Daraus folgt die Regel, an der alles Weitere hängt: **ein Agent kann ein rotes Gate nicht übergehen.** Er kann nur den Code ändern und die Prüfung erneut laufen lassen. Ein Sprachmodell, das sich selbst benotet, kann sich durchwinken — ein Zyklen-Check nicht.

Diese Gates laufen in der **CI** (Continuous Integration), dem automatischen Lauf, den jeder Push oder Pull Request auslöst. Alles Weitere in dieser Datei ist die Frage: welche Gates gibt es, was misst jedes einzelne, und was kostet es.

## 2. Wo die Verfahren sitzen

Drei Landkarten ordnen die Verfahren. **In diesem Abschnitt fallen Namen, die erst später erklärt werden** — er ist die Übersicht, jedes Verfahren bekommt weiter unten seinen eigenen Abschnitt.

**Die Testpyramide** ordnet Tests nach Anzahl und Kosten. Unten breit die Unit-Tests: viele, schnell, prüfen eine Einheit isoliert. In der Mitte Integrations- und Vertragstests. Oben schmal die End-to-End-Tests (E2E), die das ganze System durchlaufen: wenige, langsam, brüchig.

Die Verfahren dieser Datei greifen an zwei Stellen an. Property-based Testing, Fuzzing und Mutation Testing **verstärken die Unit-Ebene** — sie machen die breite Basis schärfer. Vertragstests **ersetzen große Teile der Mitte und der Spitze**, weil sie die Verträglichkeit zweier Dienste prüfen, ohne beide gleichzeitig zu starten.

**Die Test-Quadranten** (Brian Marick) sortieren nach zwei Achsen: technologie- oder geschäftsorientiert, und teamunterstützend oder produktkritisierend. Statische Analyse, Architekturtests und Mutation Testing sitzen im technologiegetriebenen, teamunterstützenden Quadranten — sie helfen dem Team beim Bauen. Fuzzing und Performance-Tests sitzen im produktkritisierenden: sie greifen das fertige Produkt an.

**Shift Left** ist keine Landkarte, sondern eine Richtung. Ein Fehler wird teurer, je weiter er von seiner Entstehung entfernt gefunden wird — am billigsten im Editor, am teuersten in der Produktion. Jedes Gate in der Pipeline verschiebt Rückmeldung nach links, in den Pull Request.

## 3. Der Abhängigkeitsgraph

Fast alles, was über Architektur objektiv sagbar ist, sagt man über einen Graphen. Seine **Knoten** sind Module, Pakete oder Klassen; eine **Kante** von A nach B heißt „A benutzt B" — durch einen Import, einen Feldtyp, einen Methodenaufruf.

Ein **Zyklus** ist ein Weg, der zu seinem Ausgangsknoten zurückführt: A braucht B, B braucht A. Das **Acyclic Dependencies Principle** (ADP) verlangt, dass der Graph der Komponenten zyklenfrei ist — ein **DAG**, ein gerichteter azyklischer Graph. Der Grund ist praktisch: Module in einem Zyklus lassen sich nicht einzeln wiederverwenden, nicht einzeln testen und nicht einzeln freigeben. Eine Änderung an einem stößt den nächsten an, und der wieder den ersten.

**Zwei Wege lösen einen Zyklus auf.** Erstens die **Dependency Inversion**: man führt eine Schnittstelle ein, und beide Module hängen von der Abstraktion ab statt voneinander. Zweitens die **Extraktion**: der geteilte Teil wandert in ein drittes, neues Modul, von dem beide abhängen. Ergänzend hilft **Interface Segregation** — eine breite Schnittstelle in mehrere schmale zerlegen, damit niemand von etwas abhängt, das er nicht benutzt.

Auf demselben Graphen stehen vier Zahlen, die Robert C. Martin eingeführt hat und die jedes bessere Analysewerkzeug ausrechnet:

| Zahl | Bedeutung | Formel |
| --- | --- | --- |
| **Ca** (afferente Kopplung) | wie viele hängen von mir ab | eingehende Kanten |
| **Ce** (efferente Kopplung) | von wie vielen hänge ich ab | ausgehende Kanten |
| **I** (Instabilität) | wie leicht ich mich ändern kann | `Ce / (Ca + Ce)`, zwischen 0 und 1 |
| **A** (Abstraktheit) | wie viel von mir Schnittstelle ist | abstrakte Typen / alle Typen |

Ein Paket mit `I = 0` hängt von niemandem ab, aber viele hängen von ihm ab — es ist **stabil** im Sinne von „schwer zu ändern". Ein Paket mit `I = 1` hängt von vielen ab und niemand von ihm; es ist frei änderbar.

Aus A und I folgt die **Distance from Main Sequence**, `D = |A + I − 1|`. Die Hauptreihe ist die Linie `A + I = 1`: Was stabil ist, soll abstrakt sein; was konkret ist, soll änderbar sein. Zwei Ecken sind zu meiden — die **Zone of Pain** (stabil und konkret: viele hängen davon ab, und es lässt sich nicht erweitern) und die **Zone of Uselessness** (abstrakt, aber niemand benutzt es).

Zwei Regeln fallen daraus:

- **SDP** (Stable Dependencies Principle) — Abhängigkeiten sollen in Richtung des Stabileren zeigen, also zu niedrigerem `I`.
- **SAP** (Stable Abstractions Principle) — was stabil ist, soll abstrakt sein.

**Wann nicht:** Zyklenfreiheit auf Klassenebene zu verlangen ist meist überzogen. Ein Domänenmodell hat natürliche wechselseitige Bezüge — die Bestellung kennt ihre Positionen, die Position kennt ihre Bestellung. Die sinnvolle Ebene ist Modul und Paket.

## 4. Architekturtests, auch Fitness Functions

Eine **Fitness Function** ist nach Ford, Parsons und Kua „jeder Mechanismus, der eine objektive Integritätsbewertung einer oder mehrerer Architektur-Charakteristiken vornimmt". Ein Architekturtest ist die konkrete, ausführbare Form davon: eine Regel über die zulässige Struktur des Codes, die wie ein Unit-Test in der CI läuft.

**Warum das ein Diagramm nicht kann.** Ein Architekturdiagramm beantwortet die Frage „Was war die Absicht?". Es beantwortet nie die Frage „Wie sieht die Struktur heute wirklich aus?". Ab der ersten Abkürzung driftet es ab, und niemand merkt es. Ein Architekturtest ist der Sensor, der diese Drift meldet.

**Wie es unter der Haube arbeitet.** **ArchUnit** — das Java-Werkzeug, an dem sich die anderen orientieren — liest Bytecode und Klassenmetadaten, baut daraus den Abhängigkeitsgraphen aus Abschnitt 3 und wertet darauf Prädikate aus. Verwandte Pakete gruppiert es zu **Slices**; der Zyklen-Check arbeitet graphenbasiert auf diesen Slices.

```java
@AnalyzeClasses(packages = "com.example.shop")
class ArchitectureTest {

    @ArchTest
    static final ArchRule domain_kennt_kein_web_und_keine_db =
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

Für die üblichen Zuschnitte gibt es fertige Regeln: `onionArchitecture()` kennt `domainModels`, `domainServices`, `applicationServices` und `adapter` und erzwingt, dass Adapter die Domäne benutzen dürfen, die Domäne aber keine Adapter.

**Der Schlüssel für bestehenden Code heißt Freeze.** `FreezingArchRule.freeze(rule)` schreibt beim ersten Lauf alle bestehenden Verstöße in einen `ViolationStore` und lässt den Build danach nur noch bei *neuen* Verstößen fehlschlagen. Ohne das führt jede Regel in einer gewachsenen Codebasis sofort zu zweihundert roten Meldungen, und das Team löscht die Regel wieder.

**Dasselbe in anderen Ökosystemen:**

| Sprache | Werkzeuge |
| --- | --- |
| .NET | ArchUnitNET, NetArchTest |
| Python | import-linter (Verträge `layers`, `forbidden`, `independence` in `.importlinter`), PyTestArch |
| JS/TS | dependency-cruiser, ts-arch, eslint-plugin-boundaries |
| PHP | Deptrac |
| Go | go-arch-lint (Import-Zyklen verbietet Go ohnehin im Compiler) |

**Und das Diagramm?** Es bleibt nützlich — als Kommunikationsmittel, nicht als Prüfung. Mermaid rendert GitHub direkt im Markdown, PlantUML kann volles UML als Text, **Structurizr** setzt das **C4-Modell** von Simon Brown um (vier Zoomstufen: Context, Container, Component, Code) nach dem Prinzip „einmal modellieren, vielfach rendern". Graphviz zeichnet große Abhängigkeitsgraphen, CodeCharta und CodeScene färben sie nach Änderungshäufigkeit ein.

Der entscheidende Satz dazu: **ein Diagramm ist Feedforward ohne Sensor.** Es sagt, wohin es gehen soll, und misst nie, wo man ist. Erst zusammen mit einer deterministischen Regel wird daraus ein Gate. ArchUnit kann sogar direkt gegen ein PlantUML-Modell prüfen, mit `adhereToPlantUmlDiagram`.

**Fallstricke:** In einer Codebasis, die nach Feature statt nach Schicht geschnitten ist, gibt es keine Schicht-Pakete zum Anzeigen — dann müssen die Regeln über Namenskonventionen oder Annotationen greifen. Zu strenge Regeln ohne Freeze werden gelöscht. Und veraltete Regeln erzeugen Rauschen, das man irgendwann ignoriert.

**Wann nicht:** bei Wegwerfcode und bei Projekten, in denen es noch keine bewusste Schichtung gibt. Dann wird erst die Struktur entschieden, danach kodiert man sie.

## 5. Dependency-Analysis

Der Graph aus Abschnitt 3 trägt nicht nur Architekturregeln. Vier weitere Fragen hängen an denselben Kanten.

**Zyklen** brechen den Build. In JS/TS reicht dafür eine Konfiguration:

```json
{
  "forbidden": [
    { "name": "no-circular", "severity": "error",
      "from": {}, "to": { "circular": true } }
  ]
}
```

**Ungenutzte Pakete** stehen in der Paketliste, aber an keiner Kante — `deptry` und `depcheck` finden sie. **Transitive Abhängigkeiten** sind der umgekehrte Fall: Pakete, die du nie angefordert hast, die aber über ein anderes hereinkommen. Sie sind der Grund, warum die Paketliste nicht die Wahrheit ist.

**Bekannte Schwachstellen** findet man, indem man die tatsächlich installierten Versionen gegen Schwachstellendatenbanken abgleicht (CVE-Scanning). Das setzt voraus, dass du diese Liste hast — und das ist die **SBOM**, die Software Bill of Materials: eine maschinenlesbare Stückliste aller enthaltenen Komponenten. Zwei Formate teilen sich das Feld: **CycloneDX** (OWASP, auf Sicherheit ausgerichtet) und **SPDX** (Linux Foundation, auf Lizenzen). Der Nutzen zeigte sich bei Log4Shell: Wer eine SBOM hatte, fand die betroffenen Systeme in Minuten statt in Tagen. Regulatorisch wird sie zunehmend gefordert.

**Lizenzkonflikte** stehen an denselben Kanten. Eine Copyleft-Lizenz wie die GPL verlangt, dass abgeleitete Software unter denselben Bedingungen weitergegeben wird; permissive Lizenzen wie MIT oder Apache tun das nicht. Copyleft in einem proprietären Produkt ist ein Risiko, das kein Test findet, sondern nur ein Lizenz-Scan.

**Werkzeuge:** dependency-cruiser, madge und dpdm (JS/TS), jdeps und JDepend (Java), pipdeptree, pydeps und pylint-cyclic-import (Python), deptry und depcheck für Ungenutztes, OWASP Dependency-Check, Trivy und Grype für Schwachstellen, Renovate und Dependabot für automatische Updates, die Graph-Ansichten von Nx und Turborepo im Monorepo.

## 6. Statische Code-Analyse

**SAST** — Static Application Security Testing — analysiert Quellcode oder Bytecode, **ohne ihn auszuführen**. Sie ist selbst eine Fitness Function, nur auf der Ebene einzelner Anweisungen statt ganzer Module.

**Die Verarbeitungskette:** Der Lexer zerlegt den Text in Token, der Parser baut daraus den **AST**, den abstrakten Syntaxbaum — die Baumdarstellung des Programms ohne Klammern und Semikolons. Aus dem AST entsteht der **CFG**, der Control Flow Graph: alle möglichen Ausführungspfade als Graph. Darauf läuft die **Datenflussanalyse** — welcher Wert kommt wo an — und ihre wichtigste Spezialform, die **Taint Analysis**: Sie verfolgt nicht vertrauenswürdige Eingaben von einer **Source** (etwa `request.getParameter`) zu einem **Sink** (etwa der Ausführung einer SQL-Abfrage). Findet sie einen Weg ohne Prüfung dazwischen, ist das eine Injection-Lücke.

Darüber liegt optional die **symbolische Ausführung**: Statt mit konkreten Werten rechnet das Werkzeug mit Symbolen, sammelt die Bedingungen entlang eines Pfads als Formel und lässt einen SMT-Solver bestimmen, ob dieser Pfad überhaupt erreichbar ist. CodeQL geht einen anderen Weg und modelliert den Code als relationale Datenbank, gegen die man Abfragen schreibt.

### Die Metriken

**Zyklomatische Komplexität** (T. J. McCabe): `M = E − N + 2P`, mit E den Kanten, N den Knoten und P den verbundenen Komponenten des CFG. Praktisch gerechnet: eins plus die Anzahl der Verzweigungspunkte. Sie misst die Zahl unabhängiger Pfade durch eine Funktion — und damit die Mindestanzahl an Testfällen, die sie alle abdeckt. Als Höchstgrenze pro Funktion hat sich der NIST-Richtwert **10** eingebürgert.

**Kognitive Komplexität** (SonarSource) misst etwas anderes: nicht die Testbarkeit, sondern die Lesbarkeit. Sie startet bei 0, erhöht sich bei jedem Bruch des linearen Ablaufs und bestraft **Verschachtelung progressiv** — ein `if` in einem `while` in einem `for` kostet mehr als dieselben drei nebeneinander. Abkürzende Konstrukte ignoriert sie.

Der Unterschied ist an zwei Fällen greifbar. Ein flaches `switch` mit 20 Fällen hat hohe zyklomatische und niedrige kognitive Komplexität — man liest es in einem Zug. Verschachtelte `if` haben es umgekehrt. Zwei funktional identische Methoden mit jeweils zyklomatischer Komplexität 11 kommen auf kognitive Komplexität 11 (das `switch`) und 27 (die verschachtelten `if`). Eine empirische Untersuchung über 22 Projekte fand, dass die Zahl gut mit menschlicher Verständlichkeit korreliert.

**Halstead-Metriken** zählen Wörter statt Pfade. Aus η₁ (verschiedene Operatoren), η₂ (verschiedene Operanden) sowie N₁ und N₂ (ihre Gesamtzahlen) folgen Vokabular `η = η₁ + η₂`, Länge `N = N₁ + N₂`, **Volumen** `V = N · log₂(η)`, Schwierigkeit `D = (η₁/2) · (N₂/η₂)` und Aufwand `E = D · V`.

**Der Maintainability Index** fasst drei davon zusammen. In der Variante von Microsoft:

```
MI = MAX(0, (171 − 5,2·ln(V) − 0,23·CC − 16,2·ln(LOC)) · 100/171)
```

Gelesen wird er in drei Bändern: 0–9 niedrig, 10–19 moderat, 20–100 hoch.

### Gate, Schuld und Fehlalarm

Ein **Quality Gate** ist die Pass/Fail-Schwelle über diesen Zahlen — etwa „keine neuen Blocker, und Coverage auf neuem Code mindestens 80 %". Das Wort *neu* trägt hier das Gewicht: Ein Gate, das den Altbestand mitbewertet, ist am ersten Tag rot und wird abgeschaltet.

**Technische Schuld** (Ward Cunningham) ist der zukünftige Mehraufwand, den eine heutige Abkürzung erzeugt. SonarQube schätzt sie in Zeit — als absolute Zahl mit Vorsicht zu nehmen, als Rangfolge brauchbar.

**Fehlalarme** sind das Betriebsproblem der statischen Analyse. SAST meldet deutlich mehr davon als eine reine Abhängigkeitsprüfung, weil sie über Code urteilt und nicht über Versionsnummern. Ein Gate, dessen Meldungen zu oft falsch sind, wird ignoriert — deshalb steht die Auswahl der Regeln am Anfang, nicht das Einschalten aller.

### Die vier Buchstabenkürzel auseinanderhalten

| Kürzel | Was es tut | Was es nicht sieht |
| --- | --- | --- |
| **SAST** | statisch, liest Quellcode | Laufzeit- und Konfigurationsfehler |
| **DAST** | dynamisch, greift die laufende Anwendung von außen an | wo im Code der Fehler sitzt |
| **IAST** | instrumentiert die laufende Anwendung von innen | alles, was nicht ausgeführt wird |
| **SCA** | prüft die Abhängigkeiten auf Schwachstellen und Lizenzen | deinen eigenen Code |

**Werkzeuge:** SonarQube und SonarCloud (Quality Gates, kognitive Komplexität als eigene Regel), Semgrep (regelbasiert, die Regel sieht aus wie der gesuchte Code), CodeQL (semantisch und tief), Snyk Code, Checkmarx, PMD und SpotBugs (Java), ESLint (JS/TS), Ruff, Bandit und mypy (Python).

**Wann vorsichtig:** Sobald eine Metrik zum Ziel wird, hört sie auf, ein gutes Maß zu sein — das ist Goodharts Gesetz, und es trifft diese Zahlen alle. Maintainability Index und Halstead wissen nichts über Namensgebung und nichts über Bedeutung. Sie sind Wegweiser, keine Note.

## 7. Coverage und was sie nicht sagt

**Coverage** ist der Anteil des Codes, der beim Testlauf tatsächlich ausgeführt wurde — je nach Werkzeug gezählt in Zeilen, Zweigen oder Pfaden. Sie ist billig zu messen und deshalb überall.

Sie beantwortet genau eine Frage: **welche Zeilen wurden ausgeführt.** Sie beantwortet nicht, ob ein Test fehlschlägt, wenn der Code sich falsch verhält. Eine **Assertion** ist die Zeile im Test, die eine Behauptung prüft und den Test rot macht, wenn sie nicht stimmt. Ein Test ohne Assertion erzeugt volle Coverage und findet nichts.

Das ist keine Randerscheinung, sondern der Normalfall bei Tests, die auf eine Coverage-Zahl hin geschrieben wurden — von Menschen unter Druck genauso wie von einem Agenten, der die Zahl als Ziel bekommen hat.

Zwei Verfahren beantworten die beiden Fragen, die Coverage offenlässt. Die CRAP-Metrik (Abschnitt 8) fragt: **wo ist das Risiko am größten?** Mutation Testing (Abschnitt 9) fragt: **sind die Tests wirklich scharf?**

## 8. Die CRAP-Metrik

**CRAP** steht für *Change Risk Analysis and Predictions* und verbindet zwei Zahlen, die du inzwischen kennst — zyklomatische Komplexität und Coverage — zu einer Risikozahl pro Methode:

```
CRAP(m) = comp(m)² · (1 − cov(m)/100)³ + comp(m)
```

`comp` ist die zyklomatische Komplexität der Methode, `cov` ihre Coverage in Prozent. Die Schwelle ist **30**.

Die Form der Formel erklärt sich beim Einsetzen:

- Eine triviale, voll getestete Methode (`comp = 1`, `cov = 100`) ergibt **1** — die untere Schranke.
- Bei 100 % Coverage wird der zweite Faktor null; übrig bleibt `CRAP = comp`. Voll getesteter Code wird nur noch nach seiner Komplexität bewertet.
- Ab einer Komplexität um 30 hält **keine** Coverage den Wert mehr unter der Schwelle. Dann hilft kein Test mehr, sondern nur noch Refactoring.

Dazwischen sagt die Formel, wie viel Coverage eine Methode braucht, um unter 30 zu bleiben:

| Zyklomatische Komplexität | nötige Coverage |
| --- | --- |
| 0–5 | 0 % |
| 6–10 | 42 % |
| 11–15 | 57 % |
| 16–20 | 71 % |
| 21–25 | 80 % |
| 26–30 | 100 % |
| 31 und mehr | nicht mehr erreichbar — refactorn |

Als projektweite Toleranz galt im Original: Bis zu 5 % der Methoden dürfen über der Schwelle liegen.

**Werkzeuge:** Crap4j (Java), der CRAP-Index in PHPUnit, crap4dotnet (.NET, Vorgabe 30), cargo-crap (Rust), Clover.

**Kritik, die man mitdenken muss.** CRAP ist eine zusammengesetzte Zahl: Man sieht ihr nicht an, welcher der beiden Faktoren sie treibt — hohe Komplexität oder fehlende Tests. Sie belohnt außerdem Coverage-Fixierung und sagt nichts über die Qualität der Tests, nur über ihre Menge. Genau deshalb steht der nächste Abschnitt daneben.

**Für Code, den ein Agent schreibt**, wird oft eine deutlich strengere Grenze angesetzt als der NIST-Richtwert aus Abschnitt 6: zyklomatische Komplexität unter 4. Die Begründung ist nicht, dass Agenten weniger könnten — sondern dass unsauberer Code sie genauso ausbremst wie Menschen, nur unbemerkt.

## 9. Mutation Testing

Mutation Testing dreht die Prüfrichtung um. Statt zu fragen, ob die Tests grün sind, **baut es absichtlich Fehler in den Produktionscode ein und fragt, ob die Tests rot werden.**

Ein solcher künstlich veränderter Code heißt **Mutant**. Erzeugt wird er von **Mutationsoperatoren**, kleinen mechanischen Regeln:

- Vergleichsgrenzen verschieben (`<` zu `<=`)
- Bedingungen negieren
- Rückgabewerte ersetzen
- `++` zu `--`
- Aufrufe von Methoden ohne Rückgabewert ganz entfernen
- arithmetische Operatoren tauschen

Läuft die Testsuite gegen einen Mutanten und mindestens ein Test schlägt fehl, ist der Mutant **getötet** — gut, die Tests haben gegriffen. Läuft alles grün durch, hat der Mutant **überlebt**, und genau dort ist eine Lücke.

Der **Mutation Score** ist der Anteil getöteter an den gültigen Mutanten, mal 100. Damit die Zahl trägt, unterscheiden die Werkzeuge — hier in der Benennung von Stryker — fünf Ausgänge:

| Zustand | Bedeutung | zählt in den Score |
| --- | --- | --- |
| Killed | ein Test schlug fehl | ja, als erkannt |
| Survived | alle Tests blieben grün | ja, als nicht erkannt |
| Timeout | der Mutant lief in eine Endlosschleife | ja, als erkannt |
| No Coverage | keine Zeile davon wird je ausgeführt | nein, wird getrennt ausgewiesen |
| Compile- oder Runtime-Error | der Mutant war nie lauffähig | nein, ungültig |

**Das Kernproblem heißt äquivalenter Mutant.** Manche Änderungen verändern das Verhalten überhaupt nicht — etwa eine Grenze, die im gültigen Wertebereich nie erreicht wird. Ein solcher Mutant ist prinzipiell nicht tötbar, drückt aber den Score. Ihn automatisch zu erkennen ist im allgemeinen Fall nicht entscheidbar, also bleibt Handarbeit.

**Kosten.** Jeder Mutant erfordert einen eigenen Testlauf; das Verfahren ist von Natur aus rechenintensiv. Drei Optimierungen machen es tragbar: nur die Tests laufen lassen, die die mutierte Zeile überhaupt berühren; Mutanten ohne Coverage von vornherein überspringen; und inkrementell arbeiten, also nur den geänderten Code mutieren.

**Werkzeuge:** PIT/Pitest (Java), Stryker Mutator (JS/TS, C#, Scala), mutmut und cosmic-ray (Python), Infection (PHP), cargo-mutants (Rust).

**Warum das die Härteprüfung für KI-generierte Tests ist:** Ein Agent, dessen Ziel eine Coverage-Zahl war, schreibt Tests, die alles ausführen und wenig behaupten. Coverage sieht das nicht. Mutation Testing kehrt ein Gleichheitszeichen um und stellt fest, dass niemand widerspricht.

**Wann nicht:** auf trivialem Code, und nicht auf der ganzen Codebasis bei jedem Commit. Ein Score von 100 % ist kein sinnvolles Ziel — die äquivalenten Mutanten machen ihn unerreichbar. Sinnvoll ist eine Grenze um 70 bis 80 % auf den geschäftskritischen Modulen.

## 10. Property-based Testing

Ein Beispiel-Test prüft einen Fall: `sort([3,1,2]) == [1,2,3]`. Ein **Property-based Test** (PBT) prüft eine Aussage, die für **alle** Eingaben gelten muss: `sort(sort(x)) == sort(x)`. Das Werkzeug erzeugt daraufhin hunderte Eingaben — samt der Randfälle 0, 1 und Maximalwert — und sucht ein Gegenbeispiel.

**Drei Bestandteile** hat jedes dieser Werkzeuge, seit QuickCheck die Linie begründet hat:

1. **Generatoren** (in manchen Sprachen *Arbitraries*) erzeugen Eingaben nach Vorgaben — „eine Liste von Ganzzahlen", „ein String".
2. **Properties** sind die zu prüfenden Aussagen.
3. **Shrinking** minimiert ein gefundenes Gegenbeispiel automatisch auf die kleinste noch fehlschlagende Form. Aus einem Fehler bei 776.837 wird ein Fehler bei 1.

Der dritte Punkt ist der, der das Verfahren benutzbar macht. Ein Gegenbeispiel aus 300 zufälligen Zeichen sagt nichts; dasselbe auf zwei Zeichen geschrumpft zeigt die Ursache. Ergänzt wird das durch **Seeds**, mit denen ein Lauf reproduzierbar ist, und durch eine lokale Datenbank gefundener Fälle — Hypothesis merkt sich, was einmal fehlgeschlagen ist, und probiert es künftig zuerst.

**Die üblichen Muster**, nach denen man eine Property findet:

| Muster | Form | Beispiel |
| --- | --- | --- |
| Round-Trip | `decode(encode(x)) == x` | Serialisierung |
| Idempotenz | `f(f(x)) == f(x)` | Sortieren, Normalisieren |
| Kommutativität | `f(a,b) == f(b,a)` | Mengenvereinigung |
| Orakel | Ergebnis gegen eine Referenzimplementierung | neue schnelle gegen alte langsame Version |
| Invariante | eine Aussage, die immer gilt | Länge bleibt erhalten, Liste ist nicht absteigend |
| Metamorphic | eine bekannte Relation zwischen zwei Aufrufen | Suche mit mehr Filtern liefert nie mehr Treffer |

```python
from hypothesis import given, strategies as st

@given(st.lists(st.integers()))
def test_sortieren_ist_idempotent(xs):
    assert sorted(sorted(xs)) == sorted(xs)

@given(st.text())
def test_roundtrip(s):
    assert decode(encode(s)) == s
```

```javascript
import fc from 'fast-check';
test('zweimal umdrehen ergibt das Original', () => {
  fc.assert(fc.property(fc.array(fc.integer()),
    xs => expect([...xs].reverse().reverse()).toEqual(xs)));
});
```

**Werkzeuge:** QuickCheck (Haskell, das Original), Hypothesis (Python), jqwik und junit-quickcheck (Java), fast-check (JS/TS), PropEr (Erlang), FsCheck (.NET), proptest und quickcheck (Rust), ScalaCheck. jqwik läuft mit 1.000 Versuchen je Property und eingebautem Shrinking, einstellbar über `@Property(tries = 5000, shrinking = ShrinkingMode.OFF)`.

**Zustandsbehaftete Systeme** prüft man mit derselben Idee eine Ebene höher: Statt einer Eingabe erzeugt das Werkzeug eine **Folge von Kommandos** und vergleicht das Ergebnis mit einem stark vereinfachten Modell desselben Systems. In Hypothesis heißt das `RuleBasedStateMachine`.

**Fallstricke:** Ein schlecht gewählter Generator, der zu viele Eingaben wieder verwerfen muss, findet nichts mehr. Datenbankzugriff im Test macht hunderte Läufe unerträglich langsam — deshalb zuerst die reine Logik. Und „alle Tests bestanden" heißt wenig, wenn die Generatoren den fraglichen Code nie erreichen.

**Wann nicht:** wenn sich keine sinnvolle Invariante formulieren lässt, oder wenn der Eingaberaum so klein ist, dass man ihn aufzählen kann. Dann reichen Beispiele.

## 11. Fuzz Testing

Fuzzing füttert ein Programm mit massenhaft halb-zufälligen Eingaben, um es zum Absturz zu bringen. Drei Achsen unterscheiden die Verfahren:

- **Dumb oder Smart** — ohne oder mit Kenntnis des Eingabeformats.
- **Mutation-based oder Generation-based** — bestehende Beispiele verändern, oder aus einer Grammatik neue erzeugen.
- **Blind oder coverage-guided** — und das ist der wichtige Unterschied.

**Coverage-guided Fuzzing** benutzt die Coverage aus Abschnitt 7 als Kompass. Der Code wird beim Bauen instrumentiert, sodass der Fuzzer misst, welche Kanten des Kontrollflussgraphen eine Eingabe erreicht hat. Eingaben, die **neue** Coverage bringen, wandern in das **Corpus** und werden weiter verändert; alle anderen fliegen weg. So arbeitet sich der Fuzzer evolutionär in tiefe Pfade vor, die zufälliges Raten nie erreicht hätte. Die Startbeispiele heißen **Seeds**; ein Corpus lässt sich mit `-merge=1` auf die Eingaben zusammenkürzen, die zusammen dieselbe Coverage erreichen.

**Ohne Sanitizer sieht ein Fuzzer die Hälfte nicht.** Ein **Sanitizer** ist eine Instrumentierung, die einen Fehler schon meldet, wenn er passiert, statt erst beim Absturz irgendwann später. Vier gehören zum Standard: **ASan** für Speicherfehler wie use-after-free, **UBSan** für undefiniertes Verhalten, **MSan** für uninitialisierten Speicher, LeakSanitizer für Speicherlecks.

**Gefunden werden:** Abstürze, Pufferüberläufe, Speicherlecks, Endlosschleifen (als Timeout), Panics, Deserialisierungsfehler und verletzte Assertions.

| Sprache | Werkzeuge |
| --- | --- |
| C/C++ | libFuzzer, AFL++, honggfuzz |
| Go | eingebaut seit Go 1.18, älter go-fuzz |
| Rust | cargo-fuzz |
| JVM | Jazzer (`@FuzzTest`, Kantenabdeckung über JaCoCo, JUnit-5-Integration) |
| Python | Atheris (`TestOneInput`, `FuzzedDataProvider`, `instrument_imports()`) |
| dauerhaft | OSS-Fuzz und ClusterFuzz für Open Source, CIFuzz für den eigenen CI-Lauf |

```go
func FuzzParse(f *testing.F) {
    f.Add("hello=world")
    f.Fuzz(func(t *testing.T, s string) {
        _ = Parse(s) // darf unter keiner Eingabe paniken
    })
}
```

**Der Unterschied zu Property-based Testing**, weil beide Eingaben erzeugen und Gegenbeispiele suchen:

| | Property-based Testing | Fuzzing |
| --- | --- | --- |
| prüft | semantische Eigenschaften | Robustheit und Sicherheit |
| Eingaben | typisierte Generatoren | meist rohe Bytes |
| Steuerung | zufällig im Rahmen der Vorgaben | Coverage-Rückmeldung |
| Ausgabe bei Fehler | geschrumpftes Gegenbeispiel | die auslösende Eingabe |
| Laufzeit | Sekunden | Stunden bis dauerhaft |

Die Grenze ist durchlässig: Hypothesis und jqwik können fuzz-artig lange laufen, und ein Fuzz-Target darf Assertions enthalten und damit Properties prüfen.

**Fallstricke:** Fuzzing im selben Prozess ist anfällig für globalen Zustand, der von einem Lauf in den nächsten überlebt. Nicht-deterministische Ziele machen jeden Fund unreproduzierbar. Das Corpus wächst unbegrenzt, wenn man es nicht regelmäßig zusammenkürzt.

**Wann nicht:** Für reine Geschäftslogik mit klaren Invarianten ist PBT zielgerichteter. Fuzzing lohnt an Parsern, Deserialisierern, Datei- und Netzwerkeingängen, Kryptografie und nativem Code.

## 12. Snapshot Testing, auch Golden Master

Ein **Snapshot-Test** speichert beim ersten Lauf die erzeugte Struktur — einen UI-Baum, ein JSON, gerendertes HTML — als Referenz und vergleicht spätere Läufe dagegen. Weicht etwas ab, zeigt er ein Diff.

Der Satz, den man dazu immer mitsagen muss: **Ein Snapshot-Test behauptet „gleich wie vorher", nicht „richtig".** Ist die Referenz falsch, ist der Test grün und der Code trotzdem kaputt.

```javascript
test('rendert Button', () => {
  expect(render(<Button label="OK" />)).toMatchSnapshot();
});
```

In der CI verweigert Jest das Anlegen fehlender Snapshots und schlägt stattdessen fehl — sonst würde ein nicht committeter Snapshot lokal grün und in der Pipeline unbemerkt neu erzeugt.

**Werkzeuge:** Jest (`toMatchSnapshot`, Inline-Snapshots, `-u` zum Aktualisieren), Vitest, Verify und ApprovalTests (.NET), Snapper (C#), syrupy (Python), insta (Rust). Für Bildvergleiche Playwright, Percy und Chromatic.

**Der Sonderfall Legacy.** Michael Feathers nennt dasselbe Verfahren **Characterization Test**: Man fängt das *aktuelle* Verhalten eines Codes über viele Parameterkombinationen ein, um beim Refactoring ein Netz zu haben — **ohne den Code verstehen zu müssen**. Das Ziel ist ausdrücklich die Dokumentation des Ist-Verhaltens, nicht des Soll-Verhaltens. Fehler werden mit eingefangen, und das ist beabsichtigt: Beim Umbau soll sich nichts ändern, auch nicht die Fehler.

**Die drei Krankheiten:** **Snapshot Rot** — veraltete Referenzen, die niemand mehr liest. **Blindes Akzeptieren** — `-u` drücken, ohne das Diff anzusehen, womit der Test seinen Zweck verliert. Und **fehlender Determinismus**: Zeitstempel, erzeugte IDs, unsortierte Mengen und Zufallszahlen machen jeden Lauf verschieden. Dagegen helfen Property-Matcher und eigene Serializer, die diese Felder herausnehmen.

**Wann nicht:** für Kern-Geschäftslogik. Dort gehört eine explizite Assertion hin, die sagt, was gelten soll. Snapshots passen zu Darstellung und Serialisierung.

## 13. Vertragstests

**Das Problem:** In einem System aus vielen Diensten wächst die Zahl der Integrationspunkte schneller als die Zahl der Dienste. Ein E2E-Test, der alle beteiligten Dienste hochfährt, ist langsam, brüchig und teuer — und je mehr davon, desto seltener sind sie alle gleichzeitig grün.

**Die Idee des Consumer-Driven Contract:** Der aufrufende Dienst — der **Consumer** — schreibt einen Test gegen einen Mock-Server und beschreibt dabei genau die Interaktionen, die er wirklich benutzt. Daraus entsteht eine versionierte Datei, der **Pact**. Der aufgerufene Dienst — der **Provider** — spielt diese Erwartungen später gegen seine echte Implementierung ab.

**Der entscheidende Punkt: Consumer und Provider laufen nie gleichzeitig.** Das ist der Grund, warum das Verfahren skaliert.

Der Ablauf in sechs Schritten:

1. Der Consumer-Test läuft gegen den Mock und erzeugt die Pact-Datei.
2. Die Datei wird zum **Pact Broker** veröffentlicht — einer Registry für Verträge, Verifikationsergebnisse und die Frage, welche Version wo läuft.
3. Der Provider holt sich die Pacts und spielt die Requests gegen sich selbst ab. Damit `GET /users/10` nicht fälschlich 404 liefert, richtet ein **Provider State** die Vorbedingung ein: `given("ein User mit id 10 existiert")` ruft beim Provider die passende Vorbereitungsmethode auf.
4. Das Ergebnis der Verifikation geht zurück an den Broker.
5. Vor jedem Deploy fragt **`can-i-deploy`** den Broker: Ist diese Version mit allen Versionen verträglich, die in der Zielumgebung gerade laufen? Nur dann wird deployt.
6. **Pending Pacts** verhindern, dass eine brandneue Consumer-Erwartung sofort fremde Pipelines rot macht — sie zählen erst, wenn der Provider sie einmal erfüllt hat.

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

**Verwandte Ansätze:**

- **Spring Cloud Contract** schreibt die Verträge in Groovy oder YAML und erzeugt daraus Provider-Tests und Consumer-Stubs.
- **Bi-Directional Contract Testing** dreht die Richtung um: Der Provider stellt seine OpenAPI-Spezifikation bereit, und die Consumer-Erwartungen werden dagegen abgeglichen. Weniger Kopplung zwischen den Teams, dafür weniger Genauigkeit.
- **Schema-Tests** gegen OpenAPI oder JSON Schema prüfen die Struktur, wissen aber nicht, *welches* Feld ein Consumer tatsächlich liest — genau das ist der Mehrwert des Consumer-Driven-Ansatzes.
- Für Nachrichten statt Aufrufe: Die **Schema Registry** bei Kafka erzwingt Kompatibilitätsregeln bei der Schema-Evolution (`BACKWARD`, `FORWARD`, `FULL`), verwaltet nach Subjects wie `orders-value`. Pact kennt dafür Message Pacts.

**Struktur ist nicht Bedeutung.** Ein Schema kann strukturell verträglich bleiben — das Feld existiert weiterhin — und semantisch brechen, weil sich seine Bedeutung geändert hat. Aus Betrag in Euro wird Betrag in Cent, und kein Vertragstest merkt es. Dafür braucht es weiterhin fachliche Tests.

**Fallstricke:** Nicht sauber aufgesetzte Provider States lassen die Verifikation aus dem falschen Grund scheitern. Exakte Werte statt Matchern wie `like` und `eachLike` machen den Vertrag brüchig — er bricht bei jeder neuen Testdatenbank.

**Und der Fall, der hier neu ist:** Schreibt derselbe Agent beide Seiten, kann er den Vertrag mitverbiegen, statt den Fehler zu melden. Genau die Abweichung, die eine unabhängige Verifikation aufdecken soll, verschwindet dann. Ein Vertragstest ist nur so unabhängig wie die zwei Seiten, die ihn schreiben.

**Zu E2E:** Ein kleines Set kritischer Durchläufe bleibt sinnvoll. Vertragstests decken die Breite der Integrationspunkte ab, die E2E niemals bezahlbar abbilden könnte.

## 14. Deep Modules

Die bisherigen Abschnitte prüfen fertigen Code. Dieser sagt, wofür man baut, damit die Prüfungen billig zu bestehen sind — und er ist der Grund, warum ein Agent an manchen Codebasen scheitert und an anderen nicht.

Ein **tiefes Modul** (John Ousterhout) verbirgt viel Funktionalität hinter einer kleinen, einfachen Schnittstelle. Das Gegenteil ist ein **flaches Modul**: Seine Schnittstelle ist fast so kompliziert wie seine Implementierung, und deshalb bringt es kaum Nutzen.

Die Rechnung dahinter ist einfach: **Die Kosten eines Moduls sind die Komplexität seiner Schnittstelle, sein Nutzen ist seine Funktionalität.** Übersteigen die Kosten den Nutzen, ist das Modul ein Minusgeschäft — man hätte den Code besser dort gelassen, wo er stand.

Ousterhouts Musterbeispiele für Tiefe: Die Datei-Ein- und -Ausgabe von Unix verbirgt hinter fünf Funktionen die gesamte Verwaltung von Dateisystemen, Puffern und Geräten. Ein Garbage Collector hat gar keine Schnittstelle. Die entgegengesetzte Neigung — alles in möglichst viele winzige Klassen zu zerlegen — nennt er **Classitis**.

**Was Tiefe herstellt und was sie zerstört:**

| | Begriff | Bedeutung |
| --- | --- | --- |
| stellt her | **Information Hiding** | eine Entwurfsentscheidung lebt in genau einem Modul |
| zerstört | **Information Leakage** | dieselbe Entscheidung steckt in mehreren Modulen; ändert sich eine, müssen alle mit |
| zerstört | **temporale Dekomposition** | die Struktur folgt der Ausführungsreihenfolge statt dem Wissen — lesen, verarbeiten, schreiben als drei Module, die alle dasselbe Format kennen müssen |

Dazu ein Prinzip und ein Warnsignal. Das Prinzip heißt **„different layer, different abstraction"**: Wenn eine Schicht dieselbe Abstraktion anbietet wie die darunter, trägt sie nichts bei. Das Warnsignal ist die **Pass-Through-Methode** — eine Methode, die nichts tut, als denselben Aufruf weiterzureichen.

Ousterhout unterscheidet drei Erscheinungsformen von Komplexität, an denen man sie erkennt: **Change amplification** (eine Änderung erzwingt viele weitere), **cognitive load** (man muss zu viel wissen, um etwas zu ändern) und **unknown unknowns** (man kann nicht einmal sehen, was man wissen müsste).

**Warum das für Agenten zählt.** Ein Agent, der ein tiefes Modul *benutzt*, muss nur die kleine Schnittstelle lesen — nicht die Implementierung. Das spart Kontextfenster und vermeidet Fehler. Viele flache Module zwingen ihn umgekehrt, viele Schnittstellen zu lernen, um irgendetwas zu tun: teuer in Token und fehleranfällig.

**Zum Widerspruch mit „Funktionen sollen klein sein":** Beide Seiten wollen dasselbe, nämlich beherrschte Komplexität. Kleinheit ist eine nützliche Voreinstellung, aber kein Ziel an sich — zu viele kleine Funktionen erzeugen flache Module und verstreute Logik. Die eigentliche Regel ist Kohäsion und eine durchgehaltene Abstraktionsebene. Praktisch heißt das: **kleine Funktionen innerhalb tiefer Module**, nicht viele flache Module mit breiten Schnittstellen.

## 15. Eine Agentenkette aus lauter Gates

Alle vorigen Abschnitte zusammen ergeben eine Arbeitsweise, die statt eines Menschen am Ende eine Kette von Rollen kennt — jede mit einem eigenen, deterministischen Gate. Ein Zuschnitt, der öffentlich beschrieben ist, benutzt sechs Rollen:

| Rolle | Auftrag | Ihr Gate |
| --- | --- | --- |
| **Specifier** | wandelt ein menschliches Dokument in Akzeptanztests und eine QA-Prozedur | die Akzeptanztests, geschrieben in **Gherkin** — der Schreibweise aus Given/When/Then-Sätzen |
| **Coder** | implementiert, schreibt Unit-Tests und das Test-Gerüst | alle Gherkin-Tests grün |
| **Cleaner** | refactort Code und Tests | **DRY** (jede Aussage steht genau einmal im Code) und die CRAP-Schwelle |
| **Architect** | verwaltet Module und Abhängigkeitsrichtungen | die Regeln aus Abschnitt 4, Zyklenfreiheit aus Abschnitt 3 |
| **Hardener** | härtet die Testsuite | Mutation Testing, auf Sprachebene und auf Gherkin-Ebene |
| **QA** | macht aus der QA-Prozedur ausführbare Oberflächen-Skripte | der deterministische Durchlauf an der Oberfläche |

Drei Eigenschaften der Kette sind wichtiger als die Rollennamen:

**Jede Stufe ist formaler als die vorige, und die menschliche Beteiligung nimmt ab.** Der Mensch liest die Akzeptanztests und die QA-Prozedur — je nach Kritikalität gründlich oder als Stichprobe. Die Unit-Tests liest er nicht.

**Jede Rolle arbeitet isoliert**, in einer eigenen Sitzung und einem eigenen Worktree. Das hält die Aufgabe schmal, und eine schmale Aufgabe hält das Kontextfenster klein — nur dann haften die Regeln, die der Rolle mitgegeben wurden.

**Kein Agent kann ein rotes Gate übergehen.** Er kann nur den Code ändern und erneut prüfen lassen. Das ist die Regel aus Abschnitt 1, hier in ihrer strengsten Form.

Der Preis ist Zeit: Eine Aufgabe, die ein einzelner Agent in fünf Minuten mit fragwürdigem Ergebnis erledigt, braucht durch die ganze Kette rund eine Stunde. Dafür ist das Ergebnis strukturell und nicht zufällig gut.

**Das Umfeld** heißt **Spec-Driven Development**: die Spezifikation als das eigentliche Artefakt, aus dem der Code folgt — als Gegenentwurf zum Drauflos-Prompten. Werkzeuge in dieser Familie sind das GitHub Spec Kit (eine agenten-agnostische Kommandozeile), AWS Kiro (eine spec-native Entwicklungsumgebung mit der EARS-Notation für Anforderungen), Tessl, BMAD und OpenSpec.

**Was diese Kette nicht ist:** ein etablierter Industriestandard. Sie ist ein laufendes Experiment, und die Rollenaufteilung ist eine von vielen möglichen. Übertragbar ist nicht der Zuschnitt, sondern das Prinzip: erst die Gates, dann die Agenten.

## 16. Was die Gates nicht leisten

Drei Grenzen gehören zur Methode dazu, nicht als Fußnote.

**Die Metrik wird zum Ziel.** Sobald eine Zahl bewertet wird, wird auf sie hin optimiert, und sie hört auf zu messen, was sie messen sollte. Coverage lässt sich ohne Assertions erreichen, ein Mutation Score durch das Abschalten unbequemer Mutationsoperatoren, eine Komplexitätsgrenze durch das Zerhacken einer Funktion in drei sinnlose. Jede Schwelle in dieser Datei ist ein Wegweiser, keine Note.

**Metriken geben Vertrauen in die Funktion, keine Sicherheit.** Sie sagen nichts über eine absichtlich eingeschleuste Schwachstelle und nichts über toten Code, den ein erfahrener Mensch auf einen Blick erkennt. Das ist der ernstzunehmendste Einwand gegen die Kette aus Abschnitt 15, und die Antwort darauf ist keine weitere Metrik, sondern eine Ergänzung: Abhängigkeits- und Laufzeitprüfungen (SCA, DAST) plus gezielte menschliche Reviews an sicherheitsrelevanten Änderungen plus Bedrohungsmodellierung.

**Jedes Gate hat sein eigenes Rauschen.** Statische Analyse meldet Fehlalarme, Mutation Testing produziert nicht tötbare äquivalente Mutanten, Snapshots verrotten, Architekturregeln veralten. Ein Gate, dessen Meldungen zu oft nicht stimmen, wird ignoriert — und ein ignoriertes Gate ist schlechter als keines, weil es Sicherheit vortäuscht.

## 17. Die Reihenfolge

### In der Pipeline, nach steigenden Kosten

Der Grundsatz heißt *fail fast*: Was billig ist und oft fehlschlägt, läuft zuerst.

1. **Lint und Format** — Sekunden, vollständig deterministisch.
2. **Build und Unit-Tests** samt Coverage.
3. **Statische Analyse, Architekturtests, Zyklen-, Lizenz- und Schwachstellenprüfung, SBOM** — untereinander parallelisierbar.
4. **Vertragstests**: Der Consumer veröffentlicht seinen Pact, der Provider verifiziert, `can-i-deploy` entscheidet.
5. **Property-based Tests** — als Teil oder Ergänzung der Unit-Stufe.
6. **Quality Gate** über Coverage, Komplexität und CRAP-Schwellen.
7. **Nachts oder gesondert:** Mutation Testing (inkrementell) und dauerhaftes Fuzzing.
8. **Deploy-Gate:** nur wenn alle deterministischen Gates grün sind.

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
      - name: SAST
        run: pipx run semgrep ci
      - name: Abhaengigkeiten (Zyklen und Schwachstellen)
        run: npx depcruise src --validate && npm audit --audit-level=high
      - name: SBOM
        run: npx @cyclonedx/cyclonedx-npm --output-file sbom.json
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Unit- und Property-Tests
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
      - name: Stryker, inkrementell
        run: npx stryker run --incremental
```

### Bei der Einführung, nach steigendem Aufwand

**Zuerst** die billigsten und deterministischsten Gates: Linting, statische Analyse, Abhängigkeitsprüfung und SBOM. Das Quality Gate greift auf *neuem* Code, nicht auf dem Altbestand.

**Danach** Architekturtests, zunächst eingefroren gegen den Bestand, und der Zyklen-Check. Ein C4-Diagramm daneben als Kommunikationsmittel.

**Dann** Property-based Testing für reine Logik, Parser und Encoder; bei vielen Diensten Vertragstests mit `can-i-deploy`.

**Zuletzt** Mutation Testing auf den kritischen Modulen, Fuzzing an den Parsern, CRAP zur Priorisierung.

**Und erst dann eine Agentenkette.** Ohne stehende Gates prüft sie nichts, sondern verteilt nur dieselbe Unsicherheit auf sechs Rollen.

### Alles auf einen Blick

| Verfahren | Prüft | Werkzeuge | Aufwand | Wann |
| --- | --- | --- | --- | --- |
| Architekturtests | Schichten, Modulgrenzen, Zyklen | ArchUnit, import-linter, dependency-cruiser, Deptrac | niedrig–mittel | sobald es bewusste Struktur gibt |
| Statische Analyse | Bugs, Sicherheit, Komplexität | SonarQube, Semgrep, CodeQL, ESLint, Ruff | niedrig | ab Tag 1, in jeder Pipeline |
| Vertragstests | Verträglichkeit Consumer↔Provider | Pact, Spring Cloud Contract, Schema Registry | mittel | viele Dienste, viele Integrationen |
| Dependency-Analysis | Zyklen, Ungenutztes, Schwachstellen, Lizenzen | madge, jdeps, deptry, Trivy, Renovate | niedrig | jedes Projekt mit Abhängigkeiten |
| Property-based Testing | Invarianten über alle Eingaben | Hypothesis, jqwik, fast-check, proptest | mittel | reine Logik, Parser, Encoder |
| Fuzz Testing | Abstürze, Speicherfehler, Robustheit | libFuzzer, AFL++, Jazzer, Atheris, OSS-Fuzz | mittel–hoch | Parser, Deserialisierer, nativer Code |
| Snapshot / Golden Master | Ist-Ausgabe gegen Referenz | Jest, Vitest, syrupy, insta, Playwright | niedrig | Oberfläche, Serialisierung, Legacy-Umbau |
| CRAP-Metrik | ungetestete Komplexität als Risiko | Crap4j, crap4dotnet, cargo-crap | niedrig | Priorisierung, Agenten-Output |
| Mutation Testing | echte Qualität der Testsuite | PIT, Stryker, mutmut, cargo-mutants | hoch | kritische Module, KI-Tests härten |
| Architektur-Diagramme | Struktur sichtbar machen | Mermaid, PlantUML, Structurizr/C4, Graphviz | niedrig | Kommunikation, als Gate nur mit Regeln |

### Die Schwellen, die eine Entscheidung ändern

| Beobachtung | Konsequenz |
| --- | --- |
| Zyklomatische Komplexität über 10 in einer Methode | refactorn; bei Agenten-Output gilt oft schon 4 |
| CRAP über 30 | testen oder refactorn — bei Komplexität über 30 nur noch refactorn |
| Mutation Score deutlich unter 70–80 % auf kritischen Modulen | Tests verstärken, aber keine 100 % erzwingen |
| Eine neue zyklische Abhängigkeit | Build brechen, per Dependency Inversion oder Extraktion auflösen |
| Vertragsverifikation rot oder `can-i-deploy` negativ | kein Deploy |
| Ein Gate meldet dauernd Falsches | Regel abschalten oder schärfen — nicht wegsehen |
