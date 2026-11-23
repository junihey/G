# Modulation

Ein Modulations-Mixer: Merkmale mal die 16 Platz-Regler eines Ziel-Platzes, mit einer Tiefe pro Zelle. Kein Modul eines Platzes, sondern ein `bpatcher` im Patch.

Hervorgegangen aus dem Mix-Patch der Performance, `zaehlen\wwww-performance\mix\`. Am 20.11.2026 hierher umgezogen, weil jedes Modul ein allgemeiner Baustein ist (`..\README.md`, „Was ein Baustein sein soll“). Die Historie bis zum Umzug liegt im Repo `wwww-performance`, zuletzt in Commit `afadd30`. Wie das Modul rechnet und warum es so gebaut ist, erzählt die README des Mix-Patch, Abschnitt „Was hier liegt“: [README des Mix-Patch](file:///C:/Users/nolte/Desktop/zaehlen/wwww-performance/mix/README.md).

**Geprüft am 20.11.2026 nach dem Umzug:** `mix.maxpat` lädt alle zwölf Plätze aus `max-bausteine`, ohne eine Fehlermeldung in der Konsole.

## Was in `max\` liegt

| Datei | Was |
|---|---|
| `modulation.maxpat` | der Baustein mit Ziel-Menü und Raster |
| `modulation.js` | die Logik, hält die Tiefen aller Ziele und schreibt sie in `[pattr zustand]` |

Bedienung: [ANLEITUNG](ANLEITUNG.md).

## Daten der Anwendung

**Neu geordnet am 22.11.2026:** Zellen 24 × 24, Schrift 12, Zeilennamen links, das Ziel-Menü und „speichern“ oben, zusammen 504 × 436, gesetzt von `werkzeug\ordnen.py`. Geprüft am 22.11.2026: `layout.py` findet in Platz, allen Bedienfeldern, Modulations-Mixer, Mix- und Sax-Patch keinen Befund. Im Mix-Patch in Max: 16 Plätze laden ohne Fehler, die Namen stehen unter den Reglern, unbenutzte Regler sind grau, der Knopf „Feld“ öffnet den Platz im eigenen Fenster.

**Die Tiefen im Preset seit dem 21.11.2026.** `[pattr zustand]` hält sie wie das Fach eines Platzes: vorne `modulation`, dahinter jede Zelle, die nicht 0 ist, als Ziel, Zeile, Spalte und Tiefe. Ein Speicher hält es als `modulation::zustand`, beim Abruf gehen nur die geänderten Zellen an die `mcs.matrix~`. Ein Platz ist der Modulations-Mixer nicht: Er hört 16 Signale und gibt 8 Bündel zu je 16 aus, ein Platz hat ein Kabel zu 8 hinein und eines heraus. Das gleiche Fach macht ihn für den Speicher trotzdem gleich. Gemessen am 21.11.2026 im Mix-Patch, lautlos am Treiber „NonRealTime“: Preset 1 setzt den Eingang der Hüllkurve in `platz13` auf 12 dB, ein `sig~ 0.2` ergibt 0,796. Ein Zustand mit der Phase Distortion auf Spalte 5 legt sie im Mixer Quellen von MAIN R auf MAIN L, der Abruf von Preset 1 wieder zurück. `store` legt `platz11::zustand`, `platz13::zustand` und `modulation::zustand` im Speicher ab. Ein Klick ins Raster selbst ist nicht nachgestellt, der MCP-Server erreicht das Raster im Bedienfeld nicht.

**`modulation.json` neben der Anwendung** hält die Tiefen aller Ziele als Startwert beim Öffnen und für eine Anwendung ohne Presets. `modulation.js` geht dafür vom eigenen Patcher bis zum obersten Patch. Bis zum 20.11.2026 nahm es den eigenen Ordner.

## Was offen ist

- Ein Datenblatt im Katalog fehlt.
- Die Namen der Ziele stehen fest in `modulation.js`, für den Mix-Patch. Für eine zweite Anwendung gehören sie in `modulation.json`.
