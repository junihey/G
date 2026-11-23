# Schritt 10 – Bewegung: 2D kippt nach 3D, Phasenporträt auf der Grafikkarte

Datum 2026-10-17. Form: Werkzeug, Brücke, Quellen, Messung, Aussortiert, Offen.

## Werkzeug

**Kippen.** Der Knopf 3D kippt die Bühne in 0,6 s aus der Draufsicht in die Schrägsicht, 2D kippt zurück und schaltet erst danach um (`Cam3.tween`, `S3.tilt` in `src/70-3d.js`, `setDim` in `src/60-ui.js`). Die Draufsicht ist Neigung −90°: x nach rechts, y nach oben, also dieselbe Lage wie die 2D-Bühne. Die zuletzt benutzte Schrägsicht bleibt gespeichert. Bei „Bewegung reduzieren“ im System springt die Kamera. Der Ausschnitt springt beim Kippen trotzdem: 3D zeichnet den Würfel aus den Feldern x ∈ und y ∈, 2D den frei verschobenen Ausschnitt.

**Die 3D-Bühne sah bisher von unten.** Bei Neigung +0,55 lag die Kamera in `Cam3.P` unter dem Boden; die Tiefensortierung passte dazu, deshalb fiel es nicht auf. Gegenüber 2D war das Bild gespiegelt. Jetzt ist die Neigung negativ (Kamera oben), Ziehen nach unten zeigt mehr von oben. Folge: Der Boden (Kurven der Ebene, Flächen unter der Kurve) wird jetzt vor den Flächen gezeichnet, wenn die Kamera oben ist, sonst danach (`floor()` in `S3.draw`).

**Phasenporträt auf der Grafikkarte.** `cglsl` (`src/86-komplex.js`) übersetzt den Syntaxbaum wie `ccompile` in GLSL, komplexe Zahlen als `vec2`; `phaseShader` färbt nach Wegert wie bisher. `GPU` (`src/87-gpu.js`, neu) baut den Shader, übergibt Ausschnitt und Regler und liefert ein Canvas, das die Bühne wie ein Bild zeichnet. Volle Auflösung statt halber. Fehlt WebGL oder kennt der Shader eine Funktion nicht, rechnet der Hauptprozessor wie bisher. Schritt 14 (Fraktale) benutzt denselben Baustein.

**Beispielblätter** (`src/61-notebook.js`): „Fläche am Regler“, „Folgen: Zyklus und Chaos“, „z als Drehung und als Matrix“, „Verteilung und Test“. Je 2 bis 5 Rechenzeilen, dazwischen Textzeilen, die sagen, was man klickt und worauf man achtet. Ersetzt das große Beispielblatt „Rundgang“ aus Schritt 11; der Nutzer fand einen Rundgang über alles zu viel für ein Blatt.

**b in Ax = b** (`src/80-matrix.js`): b startet bei (3, 4) statt (2, 1). (2, 1) war die erste Spalte der Matrix im Rundgang; der Griff lag unter der Pfeilspitze. Der Griff ist jetzt ein gefüllter Punkt mit „b ziehen“.

Klickweg: `f(x) = x^2 - 2` und `z = x^2 - y^2` tippen, oben 3D drücken. Zuerst liegt die Parabel wie in 2D vor dir, dann kippt der Boden nach hinten und die Sattelfläche richtet sich auf.

## Brücke

- 2D und 3D sind jetzt sichtbar dieselbe Szene: die Draufsicht der 3D-Bühne ist die 2D-Bühne.
- Der Shader-Baustein verbindet Phasenporträt (Schritt 3) und Fraktale (Schritt 14).

## Quellen

Keine.

## Messung

`node bench/messen.mjs 10`, neuer Fall: Phasenporträt von (z − 1)/(z² + z + 1) 30 Bilder lang verschieben.

| Fall | Grafikkarte | Hauptprozessor |
|---|---|---|
| Rechenzeit pro Bild, Mittel | 0,8 ms | 28 ms |
| Rechenzeit pro Bild, höchstens | 2,5 ms | 70 ms |
| Bild, Median (mit Bildtakt) | 16,7 ms | 24,3 ms |
| Längster Block | 0 ms | 70 ms |
| Auflösung | voll | halb |

Übrige Fälle: Tippen bis zum Graphen 40 ms, Reglerbild 16,7 ms, Fläche am Regler 16,8 ms, kein Block über 50 ms.

`node bench/ansicht.mjs 10`: Bild der Grafikkarte gegen Bild des Hauptprozessors, 200 × 150 Pixel verglichen: 0,23 % der Pixel weichen sichtbar ab bei (z − 1)/(z² + z + 1), 0,33 % bei sin(z) + c/z mit Regler c (Höhenlinien von |f| an etwas anderer Stelle, 32- gegen 64-Bit-Zahlen). b mit echten Mausereignissen gezogen: (3, 4) → (1,9; 2,35), Zeile `b` folgt. Alle vier Beispielblätter ohne Fehler. Kippen fotografiert: Anfang (Draufsicht wie 2D), Mitte, Ende, Rückweg; nach 2D ist die 2D-Bühne wieder sichtbar. Alle 26 Werkzeuge in 2D und 3D ohne Konsolenfehler, keins mit eigener Grafik.

## Aussortiert

Nichts. Der Weg über den Hauptprozessor bleibt als Rückfall.

## Offen

- Die Zeilen `f(z) = …` sagen noch „auch als → Phasenporträt“; der Knopf heißt seit Schritt 7 „öffnen in“ (`src/50-rows.js`).
- Beim Kippen springt der Ausschnitt. Ein Übergang ohne Sprung bräuchte für 3D denselben Ausschnitt wie 2D.
- Objekte der Brücken-Tabelle (Pfeile, Parallelogramme) liegen in 3D auf z = 0, Kurven auf dem Boden z = −1; die Reihenfolge zu den Flächen stimmt nur für den Boden.

## Nachtrag 2026-10-17: die offenen Punkte

| Punkt | jetzt |
|---|---|
| Beim Kippen sprang der Ausschnitt | Kippen nach 3D schreibt den sichtbaren 2D-Ausschnitt in die Felder x ∈ und y ∈ (`S3.tilt(…, range)`); zurück in 2D stellt sich die Bühne genau auf diese Felder ein, ohne den Rand von `STAGE.fit`. Hin und zurück: −2,19 … 4,19 und −3,26 … 5,26 vorher wie nachher. Die 2D-Bühne war beim Einstellen noch verborgen und meldete die Breite 0; gemessen wird jetzt am Canvas selbst. Bleibt: Der Würfel ist quadratisch, die 2D-Bühne meist nicht; die Draufsicht ist deshalb leicht gestaucht. Hand eingestellte Felder x ∈, y ∈ überschreibt das Kippen. |
| Hinweis „auch als → Phasenporträt“ | „öffnen in → Phasenporträt f(z)“ (`src/50-rows.js`) |
| Pfeile, Parallelogramme, Punkte bei z = 0 | liegen auf dem Boden z = −1 wie die Kurven und werden mit ihm gezeichnet (`floor()`); die Reihenfolge zu den Flächen stimmt für Blick von oben und von unten. Vektoren aus ℝ³ und 3×3-Matrizen bleiben im Raum. |

Geprüft mit `node bench/ansicht.mjs 10b` und `node bench/messen.mjs 10b`.
