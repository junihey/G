## Von den Grundlagen her

### 1. Das Grundproblem: zwei Sorten von Review-Sätzen

Jeder Satz, den man in einem Code-Review sagen kann, gehört in genau eine von zwei Schubladen:

- **Sätze, die eine Maschine entscheiden kann.** „Dieser Aufruf hat kein Timeout.“ Ja oder nein, kein Streit.
- **Sätze, die nur ein Mensch entscheiden kann.** „Dieses Timeout ist zu kurz gewählt.“ Da hilft kein Werkzeug.

Fast alle schlechten Review-Standards entstehen dadurch, dass man die beiden Sorten in denselben Topf wirft. Dann steht in der Regelliste „Fehlerbehandlung muss sauber sein“ neben „keine `console.log` im Produktionscode“. Der erste Satz ist unprüfbar und wird ignoriert, der zweite ist prüfbar und gehört gar nicht ins Review, sondern in den Linter.

Deine bestehende Struktur löst das. Sie sortiert konsequent nach dieser Grenze.

### 2. Die zentrale Idee: die ungeprüfte Hälfte

Hier steckt der eigentliche Gedanke deines Systems, und er ist nicht offensichtlich.

Wenn man eine Regel automatisiert, passiert etwas Unangenehmes: Die Sorge, die hinter der Regel stand, zerfällt in zwei Teile. Die Maschine nimmt sich den Teil, den sie greifen kann. Der andere Teil verschwindet nicht. Er wird nur **unsichtbar**, weil die Anzeige grün ist.

Beispiel aus deiner Design-Achse:

> **Regel:** every outbound call carries a timeout  
> **Ungeprüft:** Ob Timeout, Backoff und Abbruchbedingung vernünftig sind.

Die Maschine prüft die Anwesenheit einer Zahl. Die eigentliche Frage war nie „steht da eine Zahl“, sondern „überlebt das System einen langsamen Nachbarn“. Ein `timeout: 300000` erfüllt die Regel und beantwortet die Frage nicht.

Das ist der Trick deiner Tabellen: Du zwingst dich, neben jede automatisierte Regel den Satz zu schreiben, den sie **nicht** beantwortet. Damit bleibt die Restsorge im Dokument sichtbar, statt hinter dem grünen Haken zu verschwinden.

Merksatz: **Automatisierung löst ein Problem nicht auf, sie halbiert es. Die andere Hälfte muss einen Namen bekommen, sonst wird sie vergessen.**

### 3. Warum nach Mechanismus gruppiert wird

Deine Design-Achse gruppiert nicht nach Thema, sondern danach, **wer die geprüfte Hälfte entscheidet**. Das ist eine Rangfolge, von stark nach schwach:

|Mechanismus|Wer entscheidet|Stärke|
|---|---|---|
|Deklaration / Struktur|Verzeichnisgrenze, Modulmanifest|Verstoß ist praktisch unmöglich|
|Typen|Der Compiler|Verstoß compiliert nicht|
|Lint / AST|Ein Regelwerk|Verstoß bricht den Build|
|Ratsche|Ein Zähler über die Zeit|Verstoß ist erlaubt, wird aber sichtbar|

Warum das wichtig ist: Wenn du eine Regel aufschreibst, ist die erste Frage nicht „ist die Regel gut“, sondern „auf welcher Stufe kann ich sie verankern“. Eine Regel, die nur als Satz im Dokument steht, ist keine Regel, sondern eine Hoffnung.

Und je weiter oben eine Regel verankert ist, desto kleiner ist ihre ungeprüfte Hälfte. Der Compiler lässt weniger Ausweichmöglichkeiten als ein Linter.

### 4. Die Ratsche: der Sonderfall

Eine Ratsche ist ein Zähler, der nicht wachsen darf. „Die öffentliche Oberfläche dieses Moduls hat heute 14 Exporte. Morgen dürfen es nicht 15 sein.“

Sie ist deswegen so nützlich, weil sie das Henne-Ei-Problem löst: Man kann eine Regel einführen, ohne vorher den ganzen Altbestand aufzuräumen. Man friert den Ist-Zustand ein und lässt ihn nur noch in eine Richtung.

Ihre Grenze steht schon in deinem Dokument, in der vierten Urteilsfrage:

> Ist das Design besser geworden? Die Ratschen sagen nur, dass es nicht schlechter wurde.

Eine Ratsche kann niemals „gut“ sagen. Sie kann nur „nicht schlimmer“ sagen. Deshalb braucht jede Ratsche eine Urteilsfrage als Partner.

### 5. Die zweite Bauform: Smells

Die Correctness-Achse ist anders gebaut. Sie besteht nicht aus Verboten, sondern aus **Namen für Wahrnehmungen**. Fowlers Katalog gibt einem Sprache für ein Gefühl, das man beim Lesen hat.

Warum ist das eine eigene Bauform? Weil ein Smell keine Maschine hinter sich hat und auch keine braucht. „Feature envy“ ist kein Verstoß. Es ist ein Verdacht. Der Wert liegt darin, dass zwei Leute im Review dasselbe Wort für denselben Verdacht benutzen und nicht mehr aneinander vorbeireden.

Also:

- **Guardrail** = ein Zaun mit einem Motor dahinter. Antwort: bestanden / nicht bestanden.
- **Smell** = eine Vokabel. Antwort: „hier riecht es nach X, lass uns reden.“
- **Urteilsfrage** = ein Prüfstein am Ende. Antwort: nur durch Nachdenken.

Die drei ergänzen sich. Deine fünf Achsen benutzen alle drei, nur in unterschiedlicher Mischung.

### 6. Und jetzt die drei neuen Achsen

Für jede neue Achse ist die entscheidende Vorarbeit immer dieselbe Frage: **Was genau kann die Maschine hier sehen, und wo hört ihr Blick auf?** Erst danach schreibt man Regeln.

#### Security

Was die Maschine gut kann: **Datenflüsse verfolgen.** Ein Wert kommt von außen (Source), landet in einer gefährlichen Operation (Sink), und unterwegs war kein Sanitizer. Das ist mechanisch beweisbar. Deshalb sind Injection-Regeln automatisierbar.

Was die Maschine nicht kann: **Absicht und Berechtigung beurteilen.** Ob Nutzer A die Bestellung 124 sehen darf, steht nirgends im Code. Es steht in der Fachlichkeit. Ein Scanner sieht nur, dass eine Prüfung stattfindet, nicht ob sie das richtige prüft.

Das ist der Grund, warum Broken Access Control seit Jahren auf Platz 1 der OWASP-Liste steht, obwohl es Scanner in Massen gibt. Es ist die klassische ungeprüfte Hälfte.

Merksatz: **Die Maschine sieht den Fluss, nicht die Erlaubnis.**

#### Accessibility

Was die Maschine gut kann: **Anwesenheit von Struktur prüfen.** Hat das Bild ein `alt`? Hat das Feld ein Label? Ist der Kontrastwert über 4,5:1?

Was sie nicht kann: **Beurteilen, ob die Struktur sinnvoll ist.** `alt="bild_042.png"` erfüllt die Regel vollständig und hilft niemandem.

Hier gibt es sogar eine Zahl dafür: Deques Messung über mehr als 2.000 Audits kommt auf rund 57 % der Issues, die automatisiert gefunden werden. Die restlichen gut 40 % sind per Definition die ungeprüfte Hälfte. Das ist der seltene Fall, in dem dein Bauprinzip empirisch belegt ist.

Merksatz: **Die Maschine sieht die Anwesenheit, nicht die Bedeutung.**

#### Performance

Was die Maschine gut kann: **Zählen und Schwellwerte prüfen.** Wie groß ist das Bundle? Wie viele Queries pro Request? Ist der Lighthouse-Score über X?

Was sie nicht kann: **Beurteilen, ob es sich für echte Nutzer schnell anfühlt.** Zwei Fallen stecken hier drin, und beide sind lehrreich:

1. **Mittelwert vs. Tail.** Der Durchschnitt kann grün sein, während das 99. Perzentil leidet. Es leiden dann genau die Nutzer mit den meisten Daten, den ältesten Geräten, der schlechtesten Verbindung.
2. **Labor vs. Feld.** Ein Lighthouse-Lauf im CI ist eine Simulation auf einer sauberen Maschine. Die Core Web Vitals werden aber am 75. Perzentil echter Nutzer gemessen. Grün im Labor, rot im Feld ist ein Standardbefund.

Merksatz: **Die Maschine sieht die Zahl, nicht die Erfahrung.**

### 7. Warum die Ausschlussliste von `/security-review` so wertvoll ist

Das ist der Punkt aus Teil B, und er ist subtiler, als er wirkt.

Anthropic musste beim Bau des Security-Review-Prompts genau dein Problem lösen: Was soll das Werkzeug melden, und was soll es bewusst verschweigen, damit es nicht in Fehlalarmen ertrinkt? Das Ergebnis ist eine nummerierte Liste von Dingen, die **nicht** gemeldet werden.

Diese Liste ist aus deiner Perspektive kein Ausschluss, sondern eine Landkarte. Jeder Punkt darauf heißt übersetzt: „Hier hört die maschinelle Entscheidbarkeit auf.“ Also genau das, was in deine Spalte „Was ungeprüft bleibt“ gehört.

Analogie: Wenn dir jemand die Liste der Dinge gibt, die sein Metalldetektor **nicht** findet, hast du damit gratis die Liste dessen, wonach du selbst suchen musst.

Was du dort **nicht** abschreiben solltest: Der Prompt bewertet nur den Diff, nicht den Bestand. Er kennt keine Ratschen und keine Urteilsfragen. Er ist ein Finder, kein Standard.

### 8. Wie man das im Alltag benutzt

Der Ablauf ist immer derselbe, und er läuft von unten nach oben:

1. **Die Guardrails laufen ohne dich.** Wenn im Review noch jemand über Timeouts oder `alt`-Attribute diskutiert, ist die Regel an der falschen Stelle verankert. Verschieb sie in CI.
2. **Die Smells geben dir Vokabeln.** Statt „das fühlt sich falsch an“ sagst du „das ist shotgun surgery“ oder „das ist extraneous fetching“. Damit wird der Einwand diskutierbar statt persönlich.
3. **Die Urteilsfragen sind das eigentliche Review.** Sie sind der einzige Teil, für den ein Mensch im Raum sein muss. Genau deshalb stehen sie bei dir nicht im Menü, sondern im Schlussabschnitt.

Und der eine Satz, der alles zusammenhält: **Grün heißt nie „gut“. Grün heißt „die eine Hälfte stimmt.“ Die andere Hälfte steht daneben in der Spalte und wartet auf dich.**

Wenn du willst, gehe ich eine der drei Achsen im Detail durch und leite jede einzelne Regel her, statt sie nur zu benennen.