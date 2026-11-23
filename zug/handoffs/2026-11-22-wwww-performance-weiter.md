# Handoff: wwww-performance, einheitliche Patches und die offenen Punkte der Probe

**Datum: 22.11.2026. Auslöser:** Der Nutzer startet die Session neu. Dieser Handoff löst `archive\handoffs\2026-11-20-wwww-performance-aufbau.md` ab und trägt dessen offene Schritte weiter, unten unter „Die Schritte nach den Punkten“.

**Gebaut wird nach dem Skill `rivet`** (`C\skills\rivet\SKILL.md`), getestet über den MCP-Server `maxmsp` und die Diagnose. Vor jeder Datei in `zaehlen\max-bausteine\` liest du dessen `CLAUDE.md`, Regel 16 im Vault. Vor jeder Änderung an mehr als einer Datei steht eine Change-Liste, auch für Skripte, die viele Patches schreiben. **Ein neuer Platz kommt dorthin, wo `zaehlen\wwww-performance\README.md` unter „Wie hier gebaut wird“ ihn hinstellt,** und danach ordnet `max-bausteine\werkzeug\ordnen_anwendung.py` den Patch neu. **Ändert sich der Aufbau, wird das Canvas im selben Schritt neu gezeichnet:** `node katalog\patch-canvas.mjs wwww-performance`.

## Zuerst prüfen

Stand vom 22.11.2026. Prüfen, dann glauben.

```pruefen
test -f ../zaehlen/max-bausteine/werkzeug/layout.py               # das Prüfwerkzeug liegt
test -f ../zaehlen/max-bausteine/werkzeug/ordnen.py               # das Ordnen der Bausteine liegt
test -f ../zaehlen/max-bausteine/werkzeug/ordnen_anwendung.py     # das Ordnen der Anwendung liegt
grep -q "function namen" ../zaehlen/max-bausteine/platz/max/platz.js   # der Platz schreibt Namen unter seine Regler
grep -q "platz16" ../zaehlen/wwww-performance/mix/mix.maxpat      # der Mixer Rack steht im Mix-Patch
test -f archive/handoffs/2026-11-20-wwww-performance-aufbau.md    # der Vorgänger ist archiviert
```

| Was | Wie prüfen |
|---|---|
| Letzte Commits | `max-bausteine` `6e6073c`, `wwww-performance` `22878b9`. Was danach kam, ist neu. |
| Befunde | `python zaehlen\max-bausteine\werkzeug\layout.py pruefen --alle > zaehlen\max-bausteine\logs\layout.log`. Stand 22.11.: 4739 Befunde; in Platz, Bedienfeldern (Präsentation), Modulations-Mixer und Mix- und Sax-Patch nur noch lange Kabel und 3 fehlende Namen. |
| Max frisch und verbunden | Max liest ein geändertes Modul erst nach einem Neustart neu. Die Brücke sieht einen frisch geöffneten Patch oft erst über den Umweg: in `demo.maxpat` einen Unterpatcher anlegen, `front`, hinein, dann `switch_to_patcher("mix")`. Schließen ohne Dialog: `dispose` an `tp`. |
| Treiber | Das MOTU meldete am 22.11. „initialization error -1000“, vermutlich war es aus. Lautlose Tests über `; dsp setdriver NonRealTime`, danach zurück mit `; dsp setdriver ad_asio "MOTU Audio ASIO"`. |
| Offene Änderung des Nutzers | `zaehlen\wwww-performance\mix\merkmale.feld.json` und `mix\modulation.json` nie mitcommitten. |
| Bilder | `zaehlen\max-bausteine\logs\vorschau\` (nicht in git): `mix_spielansicht.png`, `mix_bauansicht.png`, `platz_neu.png`, `b_alle_plaetze.png`. |

## Was seit der Probe am 21.11. steht

- **Rack neu festgelegt:** ohne Disting, Persephone und Organ Drive; mit Veils, Add 2, Passive LPG, Chem LPG. Saxophon und Phase Distortion gehen über MAIN L und R direkt in den Messor, OUT 5 bis 8 über Veils. Peter fest auf IN 3 und 4. Spannungen des UltraLite im Katalog. Quelle: `specs\wwww-performance\setup.md`, `katalog\aufbau\wwww-performance.md`, `zaehlen\wwww-performance\VERKABELUNG.md`.
- **Steuerspannungen und Mixer Rack:** drei Plätze `huellkurve` (`platz13` Abhängigkeit, `platz14` Onsets, `platz15` Stille) spielen in den Mixer Rack `platz16`, der alles mischt, was ins Rack geht. **Jeder Ausgang kommt aus einem Mixer.** Testton 1 bis 10 wie die Buchsen.
- **Presets halten das Bedienfeld:** Fach `<platz>::zustand` in jedem Platz, `modulation::zustand`. Der Regler Eingang der Hüllkurve ersetzt das feste `*~ 4`.
- **Ein Maß für alle Patches** (Schrift 12, Drehregler 40, Zeile und Knopf 22, Rasterzelle 24, 8 px Abstand), geprüft von `werkzeug\layout.py`. Variante B: Platz-Regler 4 × 4 wie am EC4 mit den Namen, die das Bedienfeld schickt; das Bedienfeld zeigt nur den Rest. Der Mix-Patch öffnet in einer Spielansicht; in der Bauansicht zeigt jeder Platz sein Bedienfeld, in der Spielansicht zeigen nur Notengeber, Mixer und Raum es fest, die anderen über den Knopf „Feld“ (öffnet den Platz im eigenen Fenster).
- **`layout.py` prüft seit dem 22.11. auch:** Name neben jedem Regler (höchstens 6 Wörter), `[r diagnose]` in Testpatches, Modulen und Anwendungspatches, Kabel über 600 px.

**Der Panner, Stand 20.11. und weiter gültig:** Er folgt `specs\wwww-performance\raum.md`, bestätigt am 14.11. Gebaut ist Stufe 1: der Platz „Raum Saxophon“ (`platz12`) mit DBAP auf OUT 1 bis 4, fester Position auf der Heimat, `raeume.json` mit dem Beispielraum „probe“ und der Raumwahl. Gemessen, vom Nutzer gehört am 20.11.: Der leise Anteil auf den Nachbarn passt. Was gebaut und geprüft ist, steht in `zaehlen\wwww-performance\mix\README.md`, die Bedienung in `mix\ANLEITUNG.md`.

## Die offenen Punkte, in dieser Reihenfolge

| # | Was | Wie |
|---|---|---|
| 1 | **Stufe 3b-1, mechanische Fixes** | Zuerst die Change-Liste. **Lange Kabel über `send`/`receive`:** im Mix-Patch verteilt der Eingang jede Buchse mit `send~ in1` bis `send~ in8`, jeder Platz holt sie mit `receive~` direkt über sich; in Bedienfeldern, Platz und Modulations-Mixer gehen die Kabel zum Ausgang über `send #0werte`. Der Nutzer hat das am 22.11. bejaht (seine Antwort wiederholte die Frage; vor dem Bau einmal kurz bestätigen lassen). Dazu der Diagnose-Block (`r diagnose` → `gate` → `print`) in den 13 Patches ohne, Namen an den Reglern ohne, Testpatches ordnen. Prüfen mit `layout.py` und in Max. |
| 2 | **Stufe 3b-2, Twins und Preset-Editor** | 3948 Befunde in 9 Dateien. Ihre Präsentation bildet die Geräte nach, braucht also eine Gestaltung: pro Twin erst ein Bild, dann die Change-Liste. |
| 3 | **Stufe 3b-3, `tiefe`, `vektorfiguren`, `a-196`** | 304 Befunde, erst Bilder. |
| 4 | **Stufe 4, der Hook** | Wird in `max-bausteine` entwickelt und ruft `netz.mjs` und `layout.py`; jedes Projekt mit Max-Patches nutzt denselben Hook, zuerst `wwww-performance`. „Was jeder Testpatch trägt“ in `max-bausteine\README.md` wird die eine Liste aller Regeln mit einer Spalte „geprüft von“; `wwww-performance\README.md` verweist darauf. `max-bausteine\CLAUDE.md` nennt die Regel. Erst nach 3b, sonst blockiert der Hook jeden Commit. |
| 5 | **Punkt 5 der Probe: die Achse im Doppelgänger messen** | Der Nutzer hört nur feste Töne. Im Code ist die Achse stufenlos (`36 + r2 * 48` im `gen~`, keine Rundung in `platz.js` oder der Phase Distortion). In Max lautlos: Achse langsam drehen, Frequenz am Ausgang ablesen. |
| 6 | **Punkt 6 der Probe: die Phase Distortion** | Erst vergleichen: Sind alle Funktionen und Parameter der Vorlagen in `C:\Users\nolte\Desktop\E in C importieren\MaxUSB_Kyma_Nord_ES_VCV_Jack\TRAFO\4techniques\fm pd\phasedistortion` nachgebaut? Kann das Modul, was `C:\Users\nolte\Desktop\E in C importieren\OEß Äther O Niere\Neuer Ordner (2)\repros\Ripsaw – Acid Rain Technology.md` beschreibt? Taugt es für die Anreicherung mit Sägezahn im Sax-Patch (Schritt 12 unten)? Dann bauen: andere Notengeber wählbar (`zufallsweg` gibt es, dazu die Tonhöhe einer Stimme direkt, später `a196`); Platz-Regler 5 „Pegel“ streichen, auch im Bedienfeld und in `ordnen.py` (Namen); ein `function` im Bedienfeld, das eine Periode zeigt und sich bearbeiten lässt, dazu oder statt eines `scope~`, sein Zustand über das Fach `zustand`. Im Bedienfeld ist die Fläche dafür schon frei. |
| 7 | **Punkt 10 der Probe: Sax-Patch heißt `rack`** | Ordner, Preset-Datei, Storage-Name, `platz.start.js`-Argument, Dokumente und Handoffs. Er hört das Saxophon und spielt das Rack. |
| 8 | **Die vier Spielweisen in die Anleitung** | Sie stehen heute nur in `setup.md` („Saxophon und Phase Distortion“) und verstreut in Katalog und Verkabelung. `mix\ANLEITUNG.md` erklärt nur Versatz und Höhe von `platz13`. Eine Tabelle für den Spieler: Spielweise, Versatz und Höhe, Splice 1TO2 und Schalter, Kabel an D1. Dabei richtigstellen: Die Phase Distortion geht seit dem 22.11. über den **Mixer Rack** (Zeile 4, Spalte 6) auf MAIN R, nicht mehr über den Mixer Quellen. |
| 9 | **Kleinere Lücken** | Der Wächter braucht einen Ausgang, OUT 8 führt ins Rack (Vorschlag: S/PDIF OUT nach S/PDIF IN). Die gezeichneten Kurven A und B der Hüllkurve kommen noch nicht ins Preset. Bei der nächsten Probe: den Regler Eingang der Abhängigkeit einstellen, einen Klick ins Mixer-Raster speichern und wieder abrufen, die Spannungen von MAIN und OUT 5 bis 8 mit dem Voltmeter messen. |

Erledigt aus der Liste der Probe: Punkt 1 bis 4 (Rack), 7 (Schrift, jetzt das Maß), 8 (unterer Rand, jetzt geordnet und die Spielansicht), 9 (Mixer-Raster im Preset).

## Die Schritte nach den Punkten

Jeder Schritt endet mit einem Commit. Vor einer Änderung an mehr als einer Datei steht eine Change-Liste.

### B. Mix-Patch

7. **Panner, Stufe 2 bis 5** nach `raum.md`, „Baustufen“. Stufe 2: Bahnen Kreis, Pendel, Zufallsweg, dazu Regler Bahn, Tempo, Weite und Zittern. Die Bahnen rechnen in Metern relativ zur Heimat. Stufe 3: Sprünge, Signal folgen, Bass auf alle. Stufe 4: Nähe und Breite, Kanal 5 als Hall-Anteil. Stufe 5: die übrigen Bahnen und Doppler. Nach jeder Stufe die Rechenlast mit der Wache, am MOTU. Dazu die Raum-Plätze Yoga und Peter: Preset 2 und 3 stehen schon in `raum.js`, es fehlen die Plätze in `mix.maxpat` und die Nullen in Preset 1 von `mixer.feld.js` für ihre Zeilen. Offen in `raum.md`: welche Bahnen auf Regler 2 liegen, und ob die Bewegungen aus „Die Stimmen im Raum“ als Presets kommen.
8. **Hall für Peter und Yoga:** drei Kanäle wie die Fahne, in die Zeilen 6 bis 8 des Mixers Quellen. Er bekommt Kanal 5 der Raum-Plätze als Anteil aus „Nähe“.
9. **EC4 und Presets**, falls zur Probe nicht fertig. Siehe Punkt 4 und 5 im Probe-Handoff.

### C. Sax-Patch

10. **Treiber für das ES-8** (6.16.0), zweite Max-Instanz aus einer Kopie des Programmordners, **Test 2**. Vielleicht zur Probe erledigt.
11. **PLL:** erst **Test 3**, `a196` auf einer Aufnahme des Saxophons, mit und ohne Tiefpass, Plan B `fzero~`. Vorher `zaehlen\max-bausteine\a-196\max` in den Suchpfad.
12. **Anreicherung:** Das Modul `phasendistortion` bekommt einen Eingang für eine fremde Phase und biegt die Phase von `a196`. Danach der Chor aus 8 PLLs als Unison.
13. **Merkmale und Modulations-Mixer** im Sax-Patch, dazu der Platz „Rack“ mit OUT 5, 6 und 8 als Platz-Regler.
14. **Takte und Gates:** `rung-divisions` am Rechteck der PLL, die Hüllkurve auf OUT 2 und OUT 7.
15. **Formanten:** zwei Regler, „schmaler“ und „zur Mitte“, als Filterbank nach `formant vocal parameters.maxpat`.
16. **Vocoder, Ringmodulation, Artefakte, Mischer.**
17. **Lightpad:** Karte der Presets mit `recallmulti`, z per `udpsend` an den Platz „Fahne“ im Mix-Patch, Looper. Presets, Marken und Looper aus dem Twin des Lightpads und seinem `pattrstorage`.

### D. Rack

18. **Umstecken** nach „Die Module“ in `setup.md`, danach den Katalog nachziehen: `gehaeuse` der Module, `Pod 34X.md`, `Pod 48X.md`, `eurorack.canvas`. Vielleicht zur Probe erledigt.
19. **Test 6:** Messor am Saxophon von MAIN L, mit „Abhängigkeit“ über OUT 7 und Veils 1, vorher die Spannungen messen. Seit dem 21.11. ohne Disting.
20. **Gate nach Lautstärke** nach Art des SSG, mit Contour 1, Select 2 und Compare 2. Dann die vier Spielweisen an Splice, siehe `setup.md`, „Saxophon und Phase Distortion“.
21. **Fahne spielen:** Big Room, Fold 6, Polaris und HPO in der Fahne, die anderen Griffe im Stillen.

### E. Raum und Rahmen

22. **Installation einbinden:** Teppich auf IN 2, dazu ein Modus mit festen Abständen, damit die Installation nicht dauernd fängt.
23. **Vierter Lautsprecher:** Test 5, ein Sweep durch beide Stoffe, ohne Organ Drive. Daraus der Abgleich in dB für OUT 4 in `raeume.json`. Dazu den ersten echten Raum ausmessen und eintragen.
24. **Offene Fragen an andere:** was Peter und Yoga mitbringen, der Termin, die Genelec, ein Subwoofer, die Form des Stücks nach `specs\wwww-main\zahlen.md`.

### F. Controller frei verteilen

Gewünscht vom Nutzer am 21.11.: jeden Controller, also EC4, PC12, NMSVE und Lightpad, spontan dem Mix- oder dem Sax-Patch geben, mit einem Klick. Dafür eine eigene Spec `specs\wwww-controller\` anlegen, bevor gebaut wird.

25. **Presets ohne Controller:** Der Mix-Patch speichert die Platz-Regler direkt (`platzN::regler1` bis `16`, sichtbar über `autopattr` im Platz), `ec4::werte` fällt aus dem Abo. So macht es der Sax-Patch seit dem 21.11. schon. Dazu im Twin den Morph auf das ganze Preset umstellen (`recall A B x` statt `recall ec4::werte A B x`) und den Preset-Editor auf Platz-Regler. Die sechs Mix-Presets einmal umrechnen. Nebenbei sind danach auch die Regler 9–16 der halben Plätze im Preset.
26. **Test 7, ein MIDI-Port in zwei Instanzen:** Max und „Max 9 Kern 2“ öffnen beide das EC4. Bekommt nur eine den Port, wie bei klassischen Windows-MIDI-Treibern üblich, braucht es Schritt 28. Teilen sie ihn, reicht Schritt 27.
27. **Verteilung mit Port-Schalter:** Jeder Patch bekommt eine Projektliste pro Gerät, das er bedienen kann (`mix\pc12.ziele.csv`, `sax\ec4.ziele.csv` …). Eine Datei sagt, welches Gerät gerade welchem Patch gehört, ein Klick wählt eine Verteilung. Der Twin bekommt einen Schalter „Port zu“; die beiden Instanzen sagen sich über OSC (`udpsend`/`udpreceive`), wer öffnet. `inport`, `outport` und `#port` hat der Twin schon.
28. **Oder ein Controller-Patch:** Ein eigener Patch öffnet alle vier Geräte und schickt jeden Wert per OSC an den Patch, dem das Gerät gehört, den Rückweg zum Gerät ebenso. Die Ports bleiben offen, umschalten heißt eine Zeile ändern. Der größere Umbau, nur wenn Test 7 es verlangt oder Schritt 27 zu langsam ist. Schritt 17, das Lightpad über `udpsend`, gehört dann hier hinein.

## Was noch nicht gehört ist

Aus `mix\README.md`, „Was offen ist“: die Fahne, der Geist, Yoga 1 an IN 5, der Raum-Platz am MOTU mit Rechenlast. Die Probe kann davon einiges beantworten. Was der Nutzer dort gehört hat, wird in der README eingetragen, bevor weitergebaut wird.

## Bekannte Fehler

- **Absturz von Max** (`0xc0000409`) beim dritten Laden der Fahne am 13.11.2026. Nicht nachgestellt.
- **`: : bad number`** beim Laden während einer Blende, vermutlich aus `platz`.
- **`specs\wwww-main\review\messen.mjs` beendet sich nicht** nach dem Schreiben. Mit `timeout` aufrufen, Export, Messen und `canvas.mjs` von Hand nacheinander.

## Der nächste Schritt

Punkt 1: die Change-Liste für Stufe 3b-1 schreiben und vorher kurz bestätigen lassen, dass `send`/`receive` gegen lange Kabel gilt.
