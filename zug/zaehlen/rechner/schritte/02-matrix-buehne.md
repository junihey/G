# Schritt 2 – Zeitleiste und Matrix 2×2 auf der Bühne

Datum 2026-10-16. Form: Werkzeug, Brücke, Quellen, Messung, Aussortiert, Offen.

## Werkzeug

Das Matrix-Labor 2×2 zerfällt in sechs Werkzeuge ohne eigene Grafik (`MXT` in `src/80-matrix.js`). Jedes meldet eine Ebene auf der Bühne an (`STAGE.add`):

| Werkzeug | zeichnet auf der Bühne | Zeitleiste |
|---|---|---|
| Matrix A (2×2) | Gitter, Einheitsquadrat, Einheitskreis, Figur F, Basisvektoren unter E → A | ja, Polarzerlegung |
| Eigenrichtungen | v und Av, alle Bilder des Einheitskreises, Eigengeraden | nein, Winkel von v als Regler |
| Singulärwertzerlegung | Kreis → Ellipse in drei Phasen Vᵀ, Σ, U | ja |
| AB gegen BA | Figur F unter AB und unter BA, grau der Zwischenstand | nein |
| Ax = b | Zeilensicht (zwei Geraden) und Spaltensicht (x·a₁ + y·a₂ = b) | nein |
| Inverse | A zurück zur Einheitsmatrix | ja, rückwärts |

Die Zeitleiste liegt unten in der Mitte der Bühne (`TIMELINE` in `src/65-bruecken.js`) und erscheint nur, solange ein Werkzeug sie braucht. Alle sechs teilen sich `MX.A`, `MX.B`, `MX.b`; nur „Matrix A“ und „AB gegen BA“ haben Eingabefelder, die anderen zeigen A und springen mit „A ändern“ dorthin.

## Brücke

| Von | Nach |
|---|---|
| Matrix A im Werkzeug | Rechenblatt: „A ins Rechenblatt“ legt `A := …` an, dort greifen die Lesarten aus Schritt 1 |
| Eigenrichtungen | Rechenblatt: `eig(A)` erscheint als Punkte in ℂ, bei Drehanteil also abseits der reellen Achse |
| Ax = b | Rechenblatt: das Gleichungssystem als `solve([…])` mit Rechenweg |
| komplexe Zahl, 2×2-Matrix im Blatt | Werkzeug Matrix A, startet die Zeitleiste |

## Quellen

Keine gelesen; der Index entsteht als Nächstes.

## Messung

Alle sechs Werkzeuge einzeln und zusammengelegt geöffnet, ohne Konsolenfehler. Ax = b mit A = [[1.5, 1], [0.25, 1]], b = (2, 1) ergibt x = y = 0,8, nachgerechnet. Bildschirmfotos von Matrix A, SVD bei t = 0,55, Ax = b und der Gruppe Matrix A + AB gegen BA angesehen.

## Aussortiert

Das alte Matrix-Labor 2×2 als Ganzes (`mx-m2`), siehe `unsichtbar.md`.

## Offen

- b lässt sich auf der Bühne noch nicht ziehen, nur eintippen.
- 3×3 und n×n haben noch eigene Grafiken.
