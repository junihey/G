# Schritt 5 – Unterblöcke auflösen, Werkzeuge prüfen

Datum 2026-10-17. Form: Werkzeug, Brücke, Quellen, Messung, Aussortiert, Offen.

## Werkzeug

Analyse ist aufgelöst. Was sie konnte, steht jetzt an jeder Funktionszeile unter „auch als“:

| früher in Analyse | jetzt |
|---|---|
| Ableitung & Stammfunktion | entfällt; „f′ und f″“ legt `f'(x)`, `f''(x)` an, `diff` und `integrate` stehen unter „Befehle“ |
| Tangente | „Tangente mit Regler“ legt `xt = 1`, `tanline(f(x), x, xt)` und `(xt, f(xt))` an; den Punkt zieht man auf der Bühne, `tanline` zeichnet sofort |
| Integral | „Fläche mit Reglern“ legt `xa = 0`, `xb = 2`, `area(f(x), x, xa, xb)` an; jedes bestimmte Integral und jede `area`-Zeile wird auf der Bühne schattiert |
| Schar, Ortskurven | „Ortskurven der Schar“ legt `ortskurve(f(x), x)` an (nur bei Funktionen mit Regler) |
| Wertetabelle | eigenes Werkzeug „Wertetabelle“ für die ausgewählte Funktion |
| besondere Punkte | bleiben auf der Bühne; ein Klick legt den Punkt als Zeile an |

Allgemein:

- Punkte, deren Koordinaten Regler sind, lassen sich auf der Bühne ziehen (`STAGE.hit` in `src/65-bruecken.js`).
- Jedes Werkzeug erscheint als ein Block; Abschnitte trennt nur eine Linie (`src/00-head.html`).
- Matrix A hat keine Karte „Zahlen“ mehr; `det`, `eig`, `inv`, `svd` stehen unter der Zeile.

## Prüfung aller Werkzeuge

Regel: Was ein Befehl kann, ist kein Werkzeug. Ein Werkzeug bleibt nur für Ziehen und Animieren, eigene Ansichten oder Erklärungen in Schritten.

| Werkzeug | Urteil | Grund |
|---|---|---|
| Analyse | aufgelöst | alles kann eine Zeile |
| Wertetabelle | neu, bleibt | eigene Ansicht |
| Matrix A, Inverse, Matrix 3×3 | bleibt | Animation auf der Zeitleiste |
| Eigenrichtungen, SVD, AB gegen BA, Ax = b | bleibt | Erklärung in Schritten, zwei Sichten |
| Matrix n×n | bleibt | vier Ansichten |
| z als Drehstreckung, Produkt, Potenzen, Möbius | bleibt | Erklärung, Zeitleiste |
| Phasenporträt | bleibt | eigene Ansicht |
| DGL, Jacobi, Hesse, Kegelschnitte | bleibt | Strömung, Ziehen, Höhenlinien, Hauptachsen |
| Graphen, Markov, Fourier | bleibt | Wege-Animation, Zustandsdiagramm, Ziehen der Abtastwerte |
| Daten & Regression, Tests & Intervalle | bleibt | Dateneingabe und Ansichten; Tests gibt es nicht als Befehl |
| Verteilungen | bleibt vorerst | Kandidat: als Lesart von `binompdf`, `normcdf` usw. |
| Folgen, Konstanten, Befehle | bleibt | Spinnweb und geschlossene Form; Nachschlagen |

## Brücke

- Funktion → Tangente, Fläche, Ableitungen, Ortskurven, Tabelle, Phasenporträt, Iteration (alle als Lesart).
- Bühne → Rechenblatt: besonderer Punkt per Klick als Zeile; Ziehen eines Punkts schreibt den Regler.

## Quellen

Keine.

## Messung

Gemeinsam mit Schritt 6 gemessen, siehe `schritte/06-alles-auf-buehne.md`.

## Aussortiert

Analyse (`analyse`), siehe `unsichtbar.md`.

## Offen

- Verteilungen als Lesart der Verteilungsbefehle statt als Werkzeug.
