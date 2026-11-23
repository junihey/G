# Mixer

Ein Raster aus 8 Eingängen und 8 Ausgängen in einem Platz. Platz-Regler 1 bis 8 sind die Pegel der Eingänge, das Raster im Feld legt jeden Eingang mit eigenem Pegel auf jeden Ausgang.

Hervorgegangen aus dem Mix-Patch der Performance, `zaehlen\wwww-performance\mix\`. Am 20.11.2026 hierher umgezogen, weil jedes Modul ein allgemeiner Baustein ist (`..\README.md`, „Was ein Baustein sein soll“). Die Historie bis zum Umzug liegt im Repo `wwww-performance`, zuletzt in Commit `afadd30`. Wie das Modul rechnet und warum es so gebaut ist, erzählt die README des Mix-Patch, Abschnitt „Was hier liegt“: [README des Mix-Patch](file:///C:/Users/nolte/Desktop/zaehlen/wwww-performance/mix/README.md).

**Geprüft am 20.11.2026 nach dem Umzug:** `mix.maxpat` lädt alle zwölf Plätze aus `max-bausteine`, ohne eine Fehlermeldung in der Konsole. Im Mix-Patch gemessen am Treiber „NonRealTime“: ein `sig~ 0.5` in Zeile 2 des Mixers Eingänge, Platz-Regler 2 auf 0,794, kommt mit 0,5006 auf OUT 1, 2 und 3 an, wie am 13.11.2026. Zeile 1 des Mixers Quellen kommt mit 0,5 auf OUT 6 an. Im Sax-Patch kommt ein Ton mit 0,5 mit 0,5006 auf ES-8 OUT 1 an.

## Was in `max\` liegt

| Datei | Was |
|---|---|
| `mixer.modul.maxpat` | das Modul: 8 Pegel mit der Kurve eines Faders, dahinter `matrix~ 8 8` |
| `mixer.feld.maxpat` | das Feld: Zeilennamen, Raster, Text |
| `mixer.feld.js` | liest das Preset aus `mixer.json` neben der Anwendung und schickt jeden Weg ans Modul. Schickt das Raster als `zustand <64 Pegel>` an den Platz, nach jedem Klick und nach dem Laden, und stellt es nach einem `zustand` vom Platz wieder ein. |

Bedienung: [ANLEITUNG](ANLEITUNG.md).

## Daten der Anwendung

**`mixer.json` neben der Anwendung** hält die Presets. Die Namen der Zeilen sind seit dem 22.11.2026 auch die Namen der Platz-Regler 1 bis 8 und müssen deshalb kurz sein, etwa 9 Zeichen; `_` heißt frei. `load mixer <preset> 0` wählt eins, als Zahl oder Name. Ein Preset nennt `name`, acht `zeilen`, einen Satz `spalten` zu den Ausgängen, einen `hinweis` und die `wege` als `[zeile, spalte]` oder `[zeile, spalte, pegel]`, gezählt ab 0. Beispiele: `wwww-performance\mix\mixer.json` (Eingänge, Quellen) und `wwww-performance\sax\mixer.json` (sax).

**Das Raster im Preset seit dem 21.11.2026.** Ein Klick geht wie bisher über den Patch als `weg` ans Modul und zusätzlich als `zelle` an `mixer.feld.js`, das den ganzen Stand als Zustand an den Platz gibt. Wie der Platz ihn speichert: `..\platz\README.md`, „Der Zustand des Bedienfelds im Preset“. Gemessen am 21.11.2026 im Mix-Patch, lautlos am Treiber „NonRealTime“: Preset 1 setzt den Eingang der Hüllkurve in `platz13` auf 12 dB, ein `sig~ 0.2` ergibt 0,796. Ein Zustand mit der Phase Distortion auf Spalte 5 legt sie im Mixer Quellen von MAIN R auf MAIN L, der Abruf von Preset 1 wieder zurück. `store` legt `platz11::zustand`, `platz13::zustand` und `modulation::zustand` im Speicher ab. Ein Klick ins Raster selbst ist nicht nachgestellt, der MCP-Server erreicht das Raster im Bedienfeld nicht.

## Was offen ist

- Ein Datenblatt im Katalog fehlt. Das Modul hat keine `inlet`- und `outlet`-Objekte mit Tooltip, `datenblatt.mjs` findet also nichts zum Lesen.
- Bis zum 20.11.2026 standen die zwei Presets des Mix-Patch im Code von `mixer.feld.js` und das Raster hatte 6 Spalten.
