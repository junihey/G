# Schritt 4 – Das Rechenblatt als einzige Quelle

Datum 2026-10-17. Form: Werkzeug, Brücke, Quellen, Messung, Aussortiert, Offen.

## Werkzeug

Kein neues Werkzeug. Werkzeuge halten keine eigenen Werte mehr, sie lesen und schreiben Zeilen (`SHEET` in `src/65-bruecken.js`).

| Werkzeug | gebunden an |
|---|---|
| Matrix A, Eigenrichtungen, SVD, Inverse | `A := …` (bei „als Abbildung“ die Zeile, von der man kam, z. B. `M := …`) |
| AB gegen BA | zusätzlich `B := …` |
| Ax = b | zusätzlich `b := [ , ]` |
| z als Drehstreckung, Potenzen | `z = …` |
| Produkt z · w | `z = …`, `w = …` |
| Phasenporträt | ausgewählte Funktion von z, sonst die erste, sonst neu `f(z) = …`; bei „auch als → Phasenporträt“ auch eine Funktion von x |

Fehlt die Zeile, legt das Werkzeug sie an. Tippt man im Werkzeug, gewinnt die eigene Eingabe für 0,6 s; danach liest das Werkzeug wieder die Zeile.

Rechenblatt (`src/61-notebook.js`):

| Kürzel | Wirkung |
|---|---|
| Enter | neue Zeile darunter |
| Strg+Enter | Ergebnis als neue Zeile; Funktionen bekommen einen Namen (`F(x)` nach `integrate`, sonst `g(x)` …), Matrizen `M := …` |
| Strg+C | ohne Markierung: ganze Zeile kopieren |
| Strg+V | kopierte Zeile oder mehrere Zeilen als neue Zeilen; sonst normales Einfügen |
| Strg+D | Zeile duplizieren |
| Strg+Z / Strg+Y | Verlauf des ganzen Blatts, bis 200 Schritte, Tippen wird nach 0,5 s Pause zu einem Schritt zusammengefasst |

Die letzte, leere Zeile klebt am Fuß des Rechenblatts („+ neue Zeile“). Tippt man in sie, entsteht darunter sofort die nächste.

## Brücke

- Phasenporträt → Bühne: Nullstellen (schwarze Ringe) und Pole (weiße Ringe) erscheinen sofort, gerechnet mit `solve` im Worker. „Ins Rechenblatt“ braucht man nur noch zum Weiterrechnen.
- Funktion von x → „auch als → Phasenporträt (x → z)“.
- Funktionen von z (`f(z) = …`) zeichnen keinen reellen Graphen mehr; ihre Lesart ist das Phasenporträt (`src/50-rows.js`, kleine Änderung im Rechenkern, in der Change-Liste nicht vorgesehen).
- Ergebnis → Zeile → Bühne: Strg+Enter auf `integrate(…)` zeichnet die Stammfunktion sofort.

## Quellen

Keine.

## Messung

`node bench/messen.mjs 10`: Tippen bis zum Graphen 49 ms (Median), Reglerbild 16,6 ms, kein Block über 50 ms. Alle 27 Werkzeuge geöffnet, ohne Konsolenfehler. Geprüft per Skript: Strg+Enter, Strg+D, Strg+Z, Strg+Y; Matrix-Eingabe → Zeile `A` und Zeile `A` → Werkzeug; Nullstelle 1 und Pole −0,5 ± 0,866i des Standardbeispiels. Strg+C/V nur im Code geprüft, Chrome ohne Fenster hat keine Zwischenablage.

## Aussortiert

Nichts.

## Offen

- Die übrigen Werkzeuge (Analyse, DGL, Jacobi, Hesse, Kegelschnitte, Graphen, Markov, Fourier, 3×3, n×n, Statistik, Folgen) haben noch eigene Werte; sie binden sich in ihrem Umzugsschritt an Zeilen.
- 3D zeigt nur Flächen und Kurven, nicht die Objekte der Brücken-Tabelle (Pfeile, Parallelogramme, Lösungspunkte).
