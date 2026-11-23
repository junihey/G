# Schritt 7 – Klarheit und Tempo: zwei Reihen unter jeder Zeile, Fläche ohne Wartezeit

Datum 2026-10-17. Form: Werkzeug, Brücke, Quellen, Messung, Aussortiert, Offen.

## Werkzeug

Kein neues Werkzeug. Unter jeder Zeile stehen jetzt zwei Reihen statt „auch als“ und „Befehle“:

| Reihe | Was ein Klick tut | Beispiel an `f(x) = x^3 - 2x` |
|---|---|---|
| **weiterrechnen** | legt neue Zeilen an: Schreibweisen, Regler, Befehle | „Wertetabelle“ legt `table(f(x), x, -2, 1)` an |
| **öffnen in** ↗ | öffnet ein Werkzeug für genau diese Zeile; Knopf heißt wie das Werkzeug | „Phasenporträt f(z)“, „Folgen“ |

`BRIDGE.lesarten` (`src/65-bruecken.js`) liefert dafür `{weiter, oeffnen}`. Ein Eintrag in `oeffnen` ist eine Werkzeug-id; ausgeblendete Werkzeuge fallen von selbst heraus.

**Fläche und Integral folgen dem Regler im selben Bild.** Die Brücken-Tabelle hält die Grenzen von `area(f, x, a, b)` und `integrate(f, x, a, b)` als Terme (`BRIDGE.integral`, `BRIDGE.bounds`); die Bühne rechnet sie in jedem Bild mit den aktuellen Reglerwerten aus. Vorher stand die Schattierung bis zum Ergebnis des CAS am alten Rand. Rechnet das CAS noch, zeigt die Zeile sofort einen Näherungswert (`NB.preview`, `Num.integrate`, bei `area` über |f|); die exakte Form kommt danach.

Klickweg: „Leeren“, `f(x) = x^3 - 2x` tippen, unter der Zeile „Fläche mit Reglern“, dann `xb` ziehen. Die Fläche wandert mit; nach dem Loslassen steht nach rund 0,16 s „Fläche ≈ …“, nach rund 0,75 s die exakte Form.

## Brücke

- In 3D liegt die Fläche unter der Kurve jetzt auf dem Boden, wo auch die Kurve liegt (`src/70-3d.js`). Vorher fehlte sie dort.
- Die Wertetabelle ist eine Zeile `table(…)` statt eines Werkzeugs; sie lässt sich kopieren, ändern und mit Strg+Z zurücknehmen.

Repariert: Startet die Seite mit „Matrix A“ als erstem Reiter, war die Bühne leer. `MXT.fit` (`src/80-matrix.js`) teilte durch die Breite der Bühne, bevor sie vermessen war. Bisher verdeckt, weil die Wertetabelle vorn lag.

## Quellen

Keine.

## Messung

`node bench/messen.mjs 7`, neuer Fall `regler_flaeche`: `xb` an `area(f(x), x, xa, xb)` mit `f(x) = x^3 - 2x` ziehen.

| Fall | Wert |
|---|---|
| Reglerschritt bis Schattierung am neuen Rand, Median | 16,6 ms (ein Bildtakt) |
| Loslassen bis Näherungswert | 162 ms (150 ms davon wartet das Rechenblatt, ob weitergezogen wird) |
| Loslassen bis exakte Form | 753 ms |
| Langsam ziehen (6 Schritte mit 300 ms Pause): letzter Schritt bis exakt | 1 744 ms, Worker kein Mal ersetzt |
| Tippen bis Graph, Median | 52 ms; die Fassung vor Schritt 7 misst heute auf demselben Rechner 51 ms |
| Reglerbild, Median | 16,6 ms |
| Längster Block | 0 ms |

Der Worker wird erst nach 5 s statt 1,5 s ersetzt (`src/63-worker.js`). Vorher brach ein zweiter Reglerschritt die Rechnung ab und lud den Kern neu (rund 1,2 s), sodass `area(…)` beim Ziehen nie fertig wurde.

Alle 26 Werkzeuge in 2D und in 3D geöffnet, ohne Konsolenfehler, keins mit eigener Grafik. Bildschirmfotos angesehen: zwei Reihen an Funktion, komplexer Zahl und Matrix; Ziehen (Schattierung am neuen Rand, Zahl noch alt); Näherung; Wertetabelle als Zeile; Fläche in 3D; „öffnen in → Phasenporträt“.

## Aussortiert

Das Werkzeug Wertetabelle (`tabelle`): ersetzt durch den Befehl `table`. Eintrag in `unsichtbar.md`.

## Offen

- Während des Ziehens zeigt die Zeile noch die Zahl der alten Reglerstellung, erst nach dem Loslassen die Näherung. Die Näherung könnte in jedem Bild mitlaufen.
- Die exakte Form von `area` mit Reglern als Grenzen ist ein Term mit Beträgen in `xa` und `xb`, gilt aber nur für die aktuelle Lage der Nullstellen.
- Ein Bildschirmfoto-Skript gibt es nur im Scratchpad dieser Sitzung.
