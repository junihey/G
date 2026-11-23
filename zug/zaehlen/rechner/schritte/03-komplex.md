# Schritt 3 – Komplexe Zahlen auf der Bühne

Datum 2026-10-16. Form: Werkzeug, Brücke, Quellen, Messung, Aussortiert, Offen.

## Werkzeug

Der Brücken-Unterreiter „Komplexe Zahlen“ zerfällt in fünf Werkzeuge ohne eigene Grafik (`src/86-komplex.js`). Sobald eines offen ist, heißen die Achsen Re und Im.

| Werkzeug | zeichnet auf der Bühne | Zeitleiste |
|---|---|---|
| z als Drehstreckung | Gitter, Quadrat, Kreis, Figur F unter Multiplikation mit z | ja |
| Produkt z · w | z, w, z·w mit Winkelbögen | nein |
| Potenzen und Einheitswurzeln | z⁰ … zⁿ als Spirale, Lote auf die reelle Achse | nein |
| Möbius-Transformation | Bilder von Kreisen und Strahlen unter F(z) = (az + b)/(cz + d) aus Matrix A, Fixpunkte | ja, E → A |
| Phasenporträt f(z) | Farbe = Phase von f(z), wahlweise Höhenlinien von \|f\| und Phasenlinien | nein |

Für das Phasenporträt rechnet `ccompile` den Syntaxbaum direkt komplex aus (+ − · / ^, exp, ln, sqrt, sin, cos, tan, sinh, cosh); ein Bild in halber Auflösung kostet rund 40 ms und wird nur bei neuer Ansicht oder neuer Funktion neu gerechnet.

## Brücke

| Von | Nach | Quelle |
|---|---|---|
| z = a + bi | Matrix a·I + b·J, J = Drehung um 90° = i; „als Matrix A öffnen“ | Katja, „matrix view“ |
| Multiplikation mit z | Drehstreckung der Ebene | Wegert, Kap. 2.3 „rotostretch (Drehstreckung)“ |
| Möbius-Transformation | Matrix A: Verketten = Produkt, Umkehrung = A⁻¹, Fixpunkte = Eigenrichtungen als x/y (komplex bei Drehanteil) | Wegert, Kap. 2.3 |
| Einheitswurzel e^{2πi/n} | Realteile der Potenzen als Punkte, dazu y = cos(2π/n · x) im Rechenblatt: abgetasteter Kosinus | Katja, „roots of unity“ |
| Phasenporträt f(z) | „Nullstellen/Pole ins Rechenblatt“ legt `solve` an; die Lösungen erscheinen als Punkte genau an den Stellen, um die die Farben laufen | Wegert, Kap. 2.5 |
| komplexe Zahl im Blatt | Lesart „als Drehstreckung“ öffnet das Werkzeug mit diesem z | – |

Repariert: Eine einzelne Lösung von `solve` (z. B. z = 1) wurde als Zahl statt als Punkt gelesen.

## Quellen

Gelesen, gezielt nach Index:

- Wegert, Visual Complex Functions, PDF-S. 40–49 (Kap. 2.3 Arithmetic and Geometry, 2.4 Analytic Landscape, 2.5 Color Representations bis „Enhanced Phase Portraits“). Übernommen: Drehstreckung, Inversion, Möbius mit Umkehrformel, Farbschema (rot = positiv reell, 0 schwarz, ∞ weiß), Standardbeispiel f(z) = (z − 1)/(z² + z + 1).
- Katja, sinusoids and complex plane: Abschnitte „Matrix View“ und „Complex Roots of Unity“. Übernommen: z = a·I + b·(Spiegelung·Vertauschung), Potenzen der Einheitswurzel als Abtastwerte.

Noch nicht gelesen, aber naheliegend für später: Wegert 3.5 (Zahlenkugel), 4.5 (Residuen), 6.3 (Möbius ausführlich); Katja „complex resonator“, „fourier matrix“.

## Messung

`node bench/messen.mjs 9`: Tippen bis zum Graphen 36 ms (Median), Reglerbild 17,7 ms, kein Block über 50 ms. Alle 27 sichtbaren Werkzeuge geöffnet, ohne Konsolenfehler. Bildschirmfotos von Phasenporträt mit Polen aus `solve` und von Möbius mit Fixpunkten ±i angesehen.

## Aussortiert

Der alte Brücken-Unterreiter „Komplexe Zahlen“ (`br-komplex`), siehe `unsichtbar.md`.

## Offen

- Die Regler für z gibt es in drei Werkzeugen; liegen sie zusammen in einem Reiter, folgen die anderen Regler nicht sichtbar mit (der Wert stimmt).
- Beim Verschieben der Bühne rechnet das Phasenporträt jedes Bild neu (rund 40 ms); flüssig wäre es erst auf der Grafikkarte.
