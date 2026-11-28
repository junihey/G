---
tags: [spec, wwww-performance, raum, panner]
created: 2026-11-13
updated: 2026-11-26
topic: 'Der Panner des Mix-Patch -- Bahnen erzeugen die Bewegung, DBAP rendert sie auf vier Lautsprecher, ein Raum-Platz pro Spieler mit acht Reglern pro Stimme'
verification: 'Vom Nutzer am 2026-11-13 festgelegt: Der Panner soll saemtliche Bewegungen aus raw\Raeumlicher Klang - Stereo und Mehrkanal.md ermoeglichen, die Heimat bleibt wie in Max (Yoga OUT 1, Saxophon OUT 2, Peter OUT 3). Am 2026-11-14: vier Lautsprecher mit OUT 4 hinter dem Organ Drive, Raeume frei eintragbar, und alle Vorschlaege von Claude bestaetigt. Dabei verworfen: das Rendern im Mixer Eingaenge, der Raum-Platz behaelt den Ton. Nichts gebaut, nichts gehoert. Am 2026-11-26: das Lightpad am Mix-Patch, allgemein ueber einen zweiten Modulations-Mixer auf die Raum-Plaetze, drei Finger mit je fuenf Werten, die Belegung erst nach Stufe 5: vom Nutzer festgelegt, von Claude vorgeschlagen. Abschnitt Woraus gebaut wird am selben Tag aus den Angaben dieser Spec zusammengestellt.'
---

# Raum — der Panner des Mix-Patch

Stand 2026-11-14. **Bestätigt. Gebaut ist Stufe 1:** der Raum-Platz Saxophon mit fester Position, `raeume.json` und die Raumwahl, gemessen am 2026-11-14, nicht gehört. Stand in `zaehlen\wwww-performance\mix\README.md`. Schritt B7 in `handoffs\2026-11-14-wwww-performance-raum.md`.

> [!abstract] Bewegung erzeugen ist nicht Bewegung rendern
> Jede Stimme hat eine Bahn, die ihre Position rechnet, und einen Antrieb, der die Bahn bewegt. DBAP macht aus der Position die Pegel für vier Lautsprecher: die drei Genelec und den des Geists hinter dem Organ Drive. Nähe und Breite färben die Stimme dazu. Ein Raum-Platz pro Spieler trägt zwei Stimmen mit je acht Platz-Reglern.
>
> ```mermaid
> flowchart TD
>   E[Stimme<br/>IN 1–7] --> R
>   B["Bahn<br/>Kreis, Pendel,<br/>Zufallsweg …"] --> P[Position]
>   A["Antrieb<br/>Tempo, Zittern,<br/>Signal folgen"] --> B
>   P --> R["Rendern<br/>DBAP, Sprünge,<br/>Nähe, Breite"]
>   R --> G1[OUT 1<br/>Genelec]
>   R --> G2[OUT 2<br/>Genelec]
>   R --> G3[OUT 3<br/>Genelec]
>   R --> G4[OUT 4<br/>Organ Drive]
> ```

^blick

**Was hier steht:** wie die Stimmen sich im Raum bewegen, welche Verfahren dafür gebaut werden, wie der Panner im Mix-Patch sitzt und in welcher Reihenfolge er entsteht.

**Was hier nicht steht:** wie die Verfahren funktionieren. Das erklärt `raw\Räumlicher Klang - Stereo und Mehrkanal.md`, die Kapitelnummern unten zeigen dorthin. Was im Mix-Patch sonst passiert, steht in `setup.md`.

**Verwandt:** `setup.md` („Die Stimmen im Raum“, „Mix-Patch“, „Zwei Mixer“), `zaehlen\wwww-performance\mix\` (der Patch), `zaehlen\max-bausteine\platz\` (der Baustein, in dem jeder Raum-Platz läuft).

## Woraus gebaut wird

| Quelle | Was übernommen wird |
| --- | --- |
| `raw\Räumlicher Klang - Stereo und Mehrkanal.md` | Der Grundsatz aus Kapitel 5, Bewegung erzeugen ist nicht Bewegung rendern. Dazu die Verfahren: DBAP mit Code für vier Lautsprecher (15.4), die Bahnen (5.1–5.9), der Antrieb (12.4, 12.9), Nähe (3.1–3.3), Breite (4.1), Lautsprecher als Farbe (18.3), geglättete Positionen (20.2). |
| Der Mix-Patch vor dem Panner, `zaehlen\wwww-performance\mix\` | Die Heimat jeder Stimme: Yoga auf OUT 1, Saxophon auf OUT 2, Peter auf OUT 3. |
| `setup.md`, „Die Stimmen im Raum“ und „Spielen“ | Die Bewegungen pro Stimme und der Takt aus `rung-divisions`, der Sprünge auslöst. |

**Was die Vorlagen falsch machten:**

- Der Mix-Patch verteilte jede Stimme über den Mixer Eingänge fest auf OUT 1 bis 4. Eine Stimme konnte sich nicht bewegen.
- Für das Buch ist nicht festgehalten, was es falsch machte.

---

## Festgelegt

| Was | Wie | Seit |
|---|---|---|
| Umfang | Der Panner ermöglicht sämtliche Bewegungen aus `raw\Räumlicher Klang - Stereo und Mehrkanal.md`, soweit vier Lautsprecher sie tragen. Ambisonics, WFS und Binaural sind schon in `setup.md` unter „Bewusst nicht drin“ ausgeschlossen. | 2026-11-13 |
| Heimat | Die Verteilung, die in Max steht: Yoga auf Genelec 1 (OUT 1), Saxophon und Rack auf Genelec 2 (OUT 2), Peter auf Genelec 3 (OUT 3). Die Heimat ist der Startpunkt jeder Bahn. | 2026-11-13 |
| Vier Lautsprecher | Der Panner spielt auf OUT 1 bis 4: die drei Genelec und den Lautsprecher des Geists hinter dem Organ Drive, unter Stoff. Eine Stimme, die dorthin wandert, bekommt Röhre und Stoff als Farbe (Kapitel 18.3, Lautsprecher als Farbe). Der Geist selbst bleibt fest auf OUT 4. | 2026-11-14 |
| Räume frei eintragen | Die Positionen der Lautsprecher stehen nicht im Patch, sondern pro Raum in einer Datei. Jeder Ort, an dem gespielt wird, bekommt seinen eigenen Eintrag, siehe „Die Räume“. | 2026-11-14 |
| Lightpad | Das Lightpad hängt am Mix-Patch und steuert die Raum-Plätze, als gemeinsamer Controller aller drei Spieler. Drei Finger geben je fünf Werte aus: x, y, Druck, Berührt (0 oder 1) und Anschlag. Die 15 Werte sind die Zeilen eines zweiten Modulations-Mixers, seine Ziele die drei Raum-Plätze. Wirksam ist wie beim ersten Modulations-Mixer der Grundwert vom EC4 plus Tiefe mal Wert. Sein Raster steht in jedem Preset, so legt jedes Preset fest, welcher Wert welchen Regler stellt. | 2026-11-26 |

## Bestätigt am 2026-11-14

Von Claude vorgeschlagen, vom Nutzer am 2026-11-14 ohne Änderung bestätigt. Erwogen und verworfen: Der Raum-Platz rechnet nur die Position, und der Mixer Eingänge verteilt den Ton über sein Raster. Nähe und Breite verändern den Ton selbst, das kann ein Raster nicht. Die Stimme läge dann halb im Raum-Platz und halb im Mixer.

### Die fünf Teile

Kapitel 5 sagt: Bewegung erzeugen ist nicht Bewegung rendern. Daraus folgen fünf Teile, jeder mit eigenen Reglern.

| Teil | Verfahren | Kapitel |
|---|---|---|
| **Rendern** | DBAP für vier Lautsprecher ohne festen Hörplatz. Der vierte hat einen eigenen Abgleich, weil Organ Drive und Stoff Pegel und Höhen ändern. Sprünge: die Position rastet auf den nächsten Lautsprecher, hart oder mit kurzer Blende. Bass unter einer Grenzfrequenz auf alle Genelec, über eine Frequenzweiche. | 15.4, 16.1, 17.1 |
| **Bahn** | Kreis und Ellipse, Spirale, Pendel, Lissajous, Zufallsweg, 1/f-Rauschen, Lorenz-Attraktor, Punkte mit Easing, LFO | 5.1–5.9 |
| **Antrieb** | Tempo der Bahn. Makro- und Mikrobewegung: eine langsame Bahn mit einem schnellen Zittern darüber. Signal folgen: Helligkeit oder Lautheit verschieben die Position. Der Takt aus `rung-divisions` löst Sprünge aus. | 12.4, 12.9, `setup.md` „Spielen“ |
| **Nähe** | Pegel nach 1/r, die Luft dämpft die Höhen, ein Anteil geht in Hall oder Fahne, Doppler über eine gleitende Verzögerung | 3.1–3.3 |
| **Breite** | Dekorrelation: dieselbe Stimme auf mehreren Lautsprechern, jeweils leicht verschieden | 4.1 |

**Spätere Erweiterungen**, im Spec vorgemerkt, nicht in den ersten Stufen: Timbre-Spatialisation nach Normandeau (Bänder auf verschiedene Lautsprecher, 17.3), granulare Spatialisation (6), Feedback- und Delay-Netze zwischen den Lautsprechern (18.2).

### Raum-Plätze

Ein Platz pro Spieler, je zwei Stimmen. Sie laden alle dasselbe Modul `raum`, das Preset im Feld sagt, welche Stimmen es sind.

| Platz | Stimme 1 | Stimme 2 | Heimat |
|---|---|---|---|
| Raum Saxophon | IN 1, Saxophon | IN 7, Rack zurück | Genelec 2 |
| Raum Yoga | IN 5, Yoga 1 | IN 6, Yoga 2 | Genelec 1 |
| Raum Peter | IN 3, Peter 1 | IN 4, Peter 2 | Genelec 3 |

Der Teppich bekommt keinen Raum-Platz, er bleibt diffus auf den drei Genelec, über den Mixer Eingänge. Der Geist wird nicht gepannt (`setup.md`, „Die Stimmen im Raum“).

**Acht Platz-Regler pro Stimme**, Stimme 1 auf 1 bis 8, Stimme 2 auf 9 bis 16. Das sind die 16 eines Platzes und eine Gruppe am EC4.

| Regler | Stimme 1 | Was er tut |
|---|---|---|
| 1 | Pegel | Wie laut die Stimme auf den vier Lautsprechern ist |
| 2 | Bahn | Wählt die Bahn, in Stufen. Welche Bahnen auf dem Regler liegen, stellt das Feld ein. |
| 3 | Tempo | Wie schnell die Bahn läuft, von stehend bis rasch |
| 4 | Weite | Wie weit sich die Stimme von ihrer Heimat entfernt, bis zu allen vier Lautsprechern |
| 5 | Zittern | Die Mikrobewegung über der Bahn |
| 6 | Signal folgen | Wie stark Helligkeit oder Lautheit die Position verschieben, negativ in die Gegenrichtung |
| 7 | Nähe | Nah und trocken bis fern, gedämpft und mit Hall |
| 8 | Breite | Ein Punkt bis über alle vier verschmiert |

Was man nur vorher einstellt, steht im Feld: die Liste der Bahnen auf Regler 2, Merkmal für „Signal folgen“, Grenzfrequenz für den Bass, Sprünge an oder aus, Rolloff und Unschärfe von DBAP.

### Der Weg zu den Lautsprechern

Heute verteilt der Mixer Eingänge jede Stimme fest auf OUT 1 bis 4. Mit dem Panner teilen sich die Aufgaben:

- **Die Raum-Plätze spielen auf OUT 1 bis 4.** Ihr Pegel, Regler 1 und 9, ist der Pegel der Stimme im Raum.
- **Der Mixer Eingänge wird zum Send-Mixer.** Er legt Stimmen auf OUT 5 und 6, also ins Rack. Seine Spalten OUT 1 bis 4 stehen für die gepannten Stimmen auf null. Für den Teppich bleiben OUT 1 bis 3 offen. Der Mixer Quellen legt den Geist weiter fest auf OUT 4.
- **Ein Raum-Platz gibt 8 Kanäle aus:** 1 bis 4 für die Lautsprecher, 5 als Anteil für den Hall aus „Nähe“, 6 bis 8 frei. Kanal 5 geht in den Platz „Hall“ (Schritt B8), beim Saxophon in die Fahne.

So hat jede Stimme zwei Pegel, wie ein Kanal am Pult mit Aux: einen in den Raum und einen ins Rack.

### Die Räume

DBAP fragt nur nach dem Abstand jedes Lautsprechers zur Stimme, nicht nach Hörplatz oder Anordnung (15.4). Darum kann jeder Raum frei eingetragen werden.

- **`zaehlen\wwww-performance\mix\raeume.json`** hält alle Räume. Ein Raum hat einen Namen und eine Liste seiner Lautsprecher. Jeder Eintrag hat einen Namen, eine OUT-Nummer, x und y in Metern und einen Abgleich in dB. Den Nullpunkt wählt man pro Raum frei, etwa die Mitte der Bühne, y zeigt ins Publikum.
- **Die Raumwahl** ist ein Menü im Mix-Patch. Sie schickt die Liste über `[s raum.lautsprecher]` an alle Raum-Plätze zugleich. Ein Wechsel während des Spiels gleitet über die Glättung der Pegel, er springt nicht.
- **Die Zahl der Lautsprecher ist frei.** Heute sind es vier, OUT 1 bis 4. Ein Raum-Platz hat 8 Kanäle, einer geht an den Hall, also trägt er bis zu 7 Lautsprecher, ohne Umbau. Die Bahnen rechnen in Metern relativ zur Heimat, eine Bahn passt deshalb in jeden Raum.
- **Eingetragen wird zuerst von Hand** in der Datei, dazu ein Knopf „neu laden“ im Patch. Ein Editor mit Feldern im Patch entsteht erst, wenn die Datei zweimal von Hand gepflegt wurde.
- **Ausmessen:** Bei jedem neuen Ort die Lautsprecher in Metern vom gewählten Nullpunkt aus messen, auch den des Geists unter Stoff. Der Abgleich des vierten folgt aus dem Hören: so weit, bis eine Stimme dort nicht lauter wirkt als auf einem Genelec.

Beispiel mit erfundenen Zahlen, nur für die Form:

```json
{
  "probe": {
    "notiz": "Probenraum, Nullpunkt Mitte der Bühne",
    "lautsprecher": [
      { "name": "Genelec 1", "out": 1, "x": -2.5, "y": 3.0, "abgleich_db": 0 },
      { "name": "Genelec 2", "out": 2, "x": 0.0, "y": 4.0, "abgleich_db": 0 },
      { "name": "Genelec 3", "out": 3, "x": 2.5, "y": 3.0, "abgleich_db": 0 },
      { "name": "Geist", "out": 4, "x": 0.0, "y": 1.0, "abgleich_db": -3 }
    ]
  }
}
```

### Wie gebaut wird

Ein Modul `raum` mit einem `gen~` pro Stimme. Darin rechnet die Bahn die Position x und y, der Antrieb bewegt sie, DBAP macht vier Pegel daraus (Kapitel 15.4 hat den Code für genau vier Lautsprecher). Die Positionen der Lautsprecher kommen aus der Raumwahl, siehe „Die Räume“. Alle Positionen werden geglättet, sonst knistert es (20.2, Punkt 4). Jedes Modul trägt die Diagnose: Bahn, Position und die vier Pegel einmal pro Sekunde.

**Baustufen:**

1. DBAP, `raeume.json` mit einem Raum und die Raumwahl, dazu der Weg zu den vier Lautsprechern, mit fester Position. Prüfen: Eine Stimme auf Weite 0 klingt nur aus ihrer Heimat.
2. Bahnen Kreis, Pendel, Zufallsweg, dazu Tempo, Weite und Zittern.
3. Sprünge, Signal folgen, Bass auf alle.
4. Nähe und Breite, mit dem Anteil für den Hall.
5. Die übrigen Bahnen: Ellipse, Spirale, Lissajous, 1/f, Lorenz, Easing, LFO. Dazu Doppler.

Nach jeder Stufe zeigt die Wache die Rechenlast. Drei Raum-Plätze mit sechs `gen~` kommen zu Spitzen, die im Leerlauf schon bei 89 % liegen.

## Offen

- **Die Maße des ersten Raums.** Bis sie gemessen sind, rechnet der Panner mit dem Beispiel aus „Die Räume“.
- **Welche Bahnen auf Regler 2 liegen**, und in welcher Reihenfolge.
- **Ob die Bewegungen aus „Die Stimmen im Raum“ als Presets mitkommen**, etwa Peter 2 mit Sprüngen am Anschlag, Yoga 1 langsam über 16 s mit Zittern.
- **Welcher Wert des Lightpads welchen Regler stellt**, je Preset. Entschieden wird nach Stufe 5, wenn alle Regler des Moduls `raum` gebaut sind. Vorher müssen die Namen der Ziele des Modulations-Mixers aus `modulation.js` nach `modulation.json`, sonst gibt es keinen zweiten mit eigenen Zielen.

## Was `setup.md` dafür geändert hat

Nachgezogen am 2026-11-14: Die Tabelle „Die Stimmen im Raum“ bekommt die Heimat aus Max (Yoga Genelec 1, Saxophon Genelec 2, Peter Genelec 3). Die Spirale klingt dann auf Genelec 2, beim Saxophon. Der Punkt „Panner“ unter „Mix-Patch“ verweist auf diesen Spec.
