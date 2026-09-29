---
tags: [learning, max-msp, gen, fdn, rauschen]
created: 2026-09-29
topic: 'FDN Teil 6 -- drei Arten von Rauschen, die Schleife als Rauschgenerator, wo jedes Verfahren aus noise-invertierbarkeit.md im Netz sitzt, das Verschlucken eines Klangs, einmal klar und dann nur im Rauschen, Umhuellen und Pegel'
verification: 'aus specs\wwww-installation\teppich.md und fdn.md (Stand 2026-09-28) und der Entscheidung vom 2026-09-29 umgeschrieben; Zuordnung der Verfahren gegen data\noise-invertierbarkeit.md gehalten; nichts gebaut oder gehoert, die Klangbeschreibungen sind erwartet'
---

# FDN 6 — Rauschen aus der Schleife

Teil 6 von 7 über Feedback Delay Networks. Lies von oben nach unten.

**Setzt Teil 1 bis 4 voraus**, vor allem: Leitung, Umlauf, Matrix, `d`, Allpass, Vorzeichen, Diffusor, frequenzabhängige Drehung, Auskopplung, verlustfrei, bijektiv, Körner-Tausch, Rückwärtslauf.

**Antwort zuerst:** Ein FDN erzeugt Rauschen selbst. Was lange genug kreist, zerfließt. Dieses Rauschen behält die Klangfarbe dessen, was hineinging. Ein Klang kann so im Rauschen versinken, nur einmal klar erklingen und erst beim Rückwärtslauf wieder klar auftauchen.

**Was hier nicht steht:** wie wwww die Leitungen aufteilt und welche Modelle hineinsingen. Das steht in `specs\wwww-installation\teppich.md`.

**Eine Quelle vorab:** `data\noise-invertierbarkeit.md` beschreibt Verfahren, die Klang in Rauschen verwandeln und dabei umkehrbar bleiben. Verweise wie „Teil I.3“ zeigen auf ihre Abschnitte.

## 1 · Drei Arten von Rauschen

Das Wort „Rauschen“ meint drei verschiedene Dinge (Teil I.3). Ein Trommelschlag als Beispiel:

| Art | Was zerstört wird | Was bleibt | Der Trommelschlag klingt wie |
|---|---|---|---|
| **(b) Phasenrauschen** | die zeitliche Gestalt: Anschlag, Rhythmus | das Spektrum, also die Klangfarbe | ein Zischen mit der Farbe der Trommel |
| **(a) Spektralrauschen** | auch die Klangfarbe | nur die Hüllkurve | weißes Rauschen, das so laut und leise wird wie die Trommel |
| **(c) Informationsverlust** | alles | nichts | — |

Ein bijektives Netz erreicht (c) nie. Was hineinging, steckt noch darin, bis es unter die Rechengenauigkeit abgeklungen ist (Teil 4 §14).

## 2 · Die Schleife ist der Rauschgenerator

Mit `d` = 1, Allpässen in jeder Leitung und Vorzeichen-Wechseln ist ein Klick nach etwa 20 Umläufen Rauschen. Ein eigener Rauschgenerator ist nicht nötig.

Dieses Rauschen ist vor allem Phasenrauschen. Es klingt deshalb nach dem, was hineinging. Spektralrauschen entsteht erst, wenn das Vorzeichen in jedem Sample wechselt. Überwiegt es, klingt das Netz nach einem Rauschgenerator und nicht mehr nach seinem Material.

## 3 · Vier Orte im Netz

Ein Verfahren kann an vier Orten sitzen:

| Ort | Was dort erlaubt ist |
|---|---|
| **im Kern:** in der Schleife, zwischen Leitung und Matrix | nur Verlustfreies; dann gehen Freeze und Rückwärtslauf |
| **im Kreis, neben dem Kern** | Bijektives; dann geht der Rückwärtslauf, aber kein Freeze |
| **vor dem Netz**, auf jeden Klang einzeln | alles. Es muss nur bei Regler 0 nichts tun (Teil IX). Umkehrbar muss es nicht sein, weil es nicht im Kreis sitzt. |
| **am Ausgang** | alles, was nur einmal wirken soll |

## 4 · Die Verfahren aus `noise-invertierbarkeit.md`, nach Ort

| Verfahren | Teil | Ort | Rückwärts | Freeze | Rauschart |
|---|---|---|---|---|---|
| Kette von Allpässen, Dispersion | IV.4 | Kern | ja | ja | (b) |
| Körner-Tausch mit Radius | V.2 | Kern | ja | ja | (b) |
| Vorzeichen mit Wechselrate | III.2 | Kern | ja | ja | alle 50–500 Samples körnig; in jedem Sample (a) |
| Rechteck-Modulation, also Vorzeichen im festen Takt | III.1 | Kern | ja | ja | metallisch, wie ein Ringmodulator |
| Random-Phase-FIR | IV.3 | Kern oder davor | ja | ja | (b) |
| Frequenzshift als laufende Drehung | IV.5 | Kern, im komplexen Netz | ja | ja | unharmonisch, dann (b) |
| frequenzabhängige Kopplung | X.2 | Kern | ja | ja | (b), von oben nach unten |
| Sättigung als Lifting | VII.1 | Kreis | ja | nein | Färbung |
| Clipping mit Residuum | VII.2 | Kreis | ja | nein | Färbung |
| XOR, Überlauf, ungerade Multiplikation | VI, II.4 | Kern eines Integer-Netzes; sonst davor | ja | im Integer-Netz ja | (a) |
| Amplitudenmodulation mit Offset | III.3 | davor | — | — | Tremolo bis Ringmodulator |
| Modulo-Folding | VII.4 | davor | — | — | kreischendes Fuzz |
| Potenzkennlinie, `tanh` | II.1, II.2 | davor | — | — | Verzerrung |
| Zeitverzerrung | V.1 | davor | — | — | Bandlaufwerk, Flattern |
| resonantes Filter | IV.6 | davor oder Kreis | — | — | Resonanz |
| rückwärtsadaptive Parameter | VII.3 | Steuerung | ja, wenn nur aus Samples berechnet, die der Schritt nicht verändert | — | — |
| Lautheitskompensation, spektrale Kopplung | X.5, X.4 | Ausgang | — | — | — |

**Rückwärtsadaptiv** heißt: Das Netz steuert sich selbst, etwa regelt sein eigener Pegel sein `d`. Im Kern geht das, wenn der Parameter nur aus Samples berechnet wird, die der aktuelle Schritt nicht verändert. Dann lässt er sich rückwärts genauso ausrechnen.

## 5 · Verschlucken

Ein Klang, der im Rauschen versinken soll, heißt hier **Stimme**. Er geht in eine eigene Leitung, die **Stimmen-Leitung**. Die Leitungen, die das Rauschen tragen, heißen **Rausch-Leitungen**. Beide sind über Drehungen gekoppelt (Teil 3 §7).

Das Verschlucken hat zwei Teile:

1. **Zerfließen.** Die Stimmen-Leitung hat ihr eigenes `d`: Allpässe, Körner-Tausch, Vorzeichen. Der Klang verliert seine Gestalt.
2. **Versinken.** Die Kopplung zu den Rausch-Leitungen ist eine frequenzabhängige Drehung (Teil 3 §11). Ihr Koeffizient wandert von 1 nach −1. Erst gehen die Höhen hinüber, dann die Tiefen: Der Klang löst sich von oben nach unten auf (Teil X.2).

**Die Stimme kommt nicht zurück**, obwohl die Drehung in beide Richtungen wirkt. Die Rausch-Leitungen verteilen, was sie bekommen, im selben Umlauf auf ihre anderen Leitungen. Zurück in die Stimmen-Leitung fließt Rauschen.

**Die Kopplung geht zwischen zwei Stimmen nie ganz auf 1 zurück.** Sonst kreist in der Stimmen-Leitung eine Schleife aus Rauschen und klingt als Kammfilter.

## 6 · Einmal klar, dann nur im Rauschen

Ein Netz spielt nur, was an den Enden seiner Leitungen herauskommt. Alles, was hineingeht, erklingt frühestens nach einem Umlauf. Ein gewöhnlicher Hall hat deshalb einen zweiten Weg: Beim **trockenen Weg** geht der Klang ohne Umweg zum Lautsprecher.

So erklingt eine Stimme genau einmal klar:

1. **Der trockene Weg** spielt sie sofort. Zwischen Auslöser und Klang liegt nur die Zeit, die der Klang zum Entstehen braucht.
2. **Die Stimmen-Leitung wird vorwärts nicht abgehört.** Ihr Faktor in der Auskopplung ist 0. Man hört die Stimme im Netz nur, sobald sie in den Rausch-Leitungen liegt.
3. **Das Zerfließen beginnt sofort.** Das `d` der Stimmen-Leitung steht von Anfang an hoch. Sonst taucht die Stimme in den Rausch-Leitungen als klares Echo auf.
4. **Im Rückwärtslauf wird die Stimmen-Leitung abgehört.** Die Auskopplung darf sich ändern, ohne den Zustand zu berühren (Teil 4 §12). Erreicht das Netz den Moment, in dem die Stimme hineinging, taucht sie dort wieder klar auf.

Rückwärts heißt: Sie erklingt rückwärts. Soll sie vorwärts wiederkommen, kehrt die Richtung am Ende des Kollapses noch einmal um, und die Stimmen-Leitung wird für einen Umlauf abgehört. Mit anderen Parametern als beim ersten Mal zerfließt sie danach anders.

**Bei langen Stimmen**, Dutzenden von Sekunden, passt der trockene Weg nicht. Er bliebe die ganze Zeit offen, und damit die Stimme trotzdem versinkt, müsste er langsam leiser werden. Das ist ein Überblenden, und davor warnt Teil X.4: Man hört dann zwei Schichten nebeneinander. Eine lange Stimme geht deshalb ohne trockenen Weg ins Netz, und ihre Stimmen-Leitung wird auch vorwärts abgehört. Ihr erster Umlauf ist klar, die folgenden sind schon zerflossen.

Wie laut der trockene Weg ist, bleibt ein Regler pro Stimme.

## 7 · Umhüllen

Die Energie der Stimme wandert selbst ins Rauschen, und Rauschen fließt an ihre Stelle. Man hört eine Schicht, die sich verwandelt, nicht zwei Schichten nebeneinander.

Das Rauschen um eine neue Stimme besteht aus früheren Stimmen. Weil es vor allem Phasenrauschen ist, hat es deren Klangfarbe.

Reicht das nicht, hilft am Ausgang eine **spektrale Kopplung** (Teil X.4): Das Rauschen nimmt die spektrale Hüllkurve der gerade klingenden Stimme an. Sie ist nicht umkehrbar und sitzt deshalb nur am Ausgang.

## 8 · Pegel

Die Rausch-Leitungen verlieren pro Umlauf so viel, wie ihre Nachhallzeit vorgibt. Kommen laufend Stimmen hinzu, stellt sich ein Pegel ein. Je länger die Nachhallzeit, desto lauter wird das Rauschen bei gleichem Zufluss.

Die **Lautheitskompensation** am Ausgang misst den Mittelwert des Pegels und gleicht ihn aus (Teil X.5). Sonst hört man jede Änderung von `d` als Lautstärkefahrt statt als Verwandlung.
