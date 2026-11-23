# Schritt 6 – Alle Werkzeuge zeichnen auf der Bühne, auch in 3D

Datum 2026-10-17. Form: Werkzeug, Brücke, Quellen, Messung, Aussortiert, Offen.

## Werkzeug

Kein sichtbares Werkzeug hat mehr eine eigene Grafik. Gemeinsame Bausteine in `src/65-bruecken.js`:

- `viewSel`: Hat ein Werkzeug mehrere Bilder, wählt man im Werkzeug, welches die Bühne zeigt.
- `STAGE.inset`: kleines Nebenbild in einer Ecke der Bühne (Spur-Determinanten-Ebene der DGL).
- `STAGE.hit` und `click`: Griffe ziehen (p bei Jacobi und Hesse, Abtastwerte bei Fourier), Klicks (Bahnen bei der DGL, Knoten bei Graphen).
- `STAGE.fit`: Beim Wechsel auf ein Werkzeug stellt sich die Bühne auf seinen Bereich ein.
- `STAGE3`: Ebenen im Raum.

| Werkzeug | Bühne | Zeile im Rechenblatt |
|---|---|---|
| DGL x′ = Ax | Feld, Bahnen, strömende Teilchen, Eigengeraden, Einschub Spur–det | `A` (dieselbe wie Matrix A) |
| Jacobi | Gitter um p, Bild unter F und unter J | `u(x, y)`, `v(x, y)` |
| Hesse | Höhenfarben, Höhenlinien, Gradient, Krümmungsrichtungen, kritische Punkte | ausgewählte Funktion von x und y, sonst `h(x, y)`; in 3D als Fläche |
| Kegelschnitte | Kurve xᵀQx = 1, Hauptachsen | `Q` |
| Graphen | Knoten, Kanten, ein Weg der Länge n | `G` |
| Markov | Zustandsdiagramm mit gefüllten Knoten oder Verlauf über n | `P` |
| Fourier | Signal mit Interpolation, Spektrum oder DFT-Matrix | `s` |
| Matrix 3×3 | verformter Würfel im Raum, Zeitleiste | `T` |
| Matrix n×n | Heatmap, Eigenwerte in ℂ, Singulärwerte oder projizierter n-Würfel | ausgewählte Matrix, sonst `N` |
| Daten & Regression | Streudiagramm, Residuen oder Histogramm mit Boxplot | `xs`, `ys` |
| Verteilungen, Tests & Intervalle | Verteilung mit markiertem Bereich | eigene Eingaben (offen) |
| Folgen | Folgenglieder oder Spinnwebdiagramm | eigene Eingaben (offen) |

3D (`src/70-3d.js`): Objekte der Brücken-Tabelle liegen auf dem Boden (Pfeile, Parallelogramme, Lösungspunkte), Vektoren aus ℝ³ stehen als Pfeile im Raum, jede 3×3-Matrix im Blatt erscheint als verformter Würfel. Ohne Flächen haben alle drei Achsen dieselbe Einheit.

## Brücke

- DGL und Matrix A teilen dieselbe Zeile: dieselbe Matrix als Abbildung und als Strömung.
- Hesse: Die untersuchte Funktion ist zugleich die Fläche in 3D.
- Fourier: Die DFT-Matrix besteht aus den Potenzen der Einheitswurzel, dieselben Zeiger wie im Werkzeug „Potenzen und Einheitswurzeln“.
- Das Beispielblatt „Matrizen im CAS“ zeigt sich jetzt auch in 3D.

Repariert im Rechenkern (`src/30-cas.js`): Parameter einer Funktion verdeckten gleichnamige Variablen nicht. Mit `z = 1.2 + 0.7i` im Blatt wurde `f(z)` falsch ausgewertet. Das Phasenporträt legt neue Zeilen nur noch unter einem freien Funktionsnamen an.

## Quellen

Keine.

## Messung

`node bench/messen.mjs 11`: Tippen bis zum Graphen 44 ms (Median), Reglerbild 16,8 ms, kein Block über 50 ms. Alle 27 Werkzeuge nacheinander geöffnet, ohne Konsolenfehler. Bildschirmfotos angesehen: DGL, Jacobi, Hesse, Kegelschnitt, Graph, Markov, Fourier, n×n, 3×3 in 3D, Daten, Test, Folgen (Spinnweb), Tangente und Fläche mit Reglern, „Matrizen im CAS“ in 3D. Ziehen des Tangentenpunkts per Skript geprüft.

## Aussortiert

Nichts Neues. Die alten Grafikfelder leben nur noch in den ausgeblendeten Werkzeugen `mx-m2` und `br-komplex`.

## Offen

- Folgen, Verteilungen und Tests haben noch eigene Eingaben statt Zeilen.
- b in Ax = b lässt sich noch nicht ziehen.
- Liegen viele Objekte im Blatt, wird die Bühne voll; die Ebenen-Liste blendet aus, eine Sortierung nach Werkzeug fehlt.
