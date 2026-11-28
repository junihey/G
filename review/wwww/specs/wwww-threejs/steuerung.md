---
tags: [spec, wwww-threejs, wwww-rnbo, steuerung]
created: 2026-09-27
topic: 'Wie der Spieler auf dem Handy durch den latenten Raum fliegt und wie das den RNBO-Klang steuert'
verification: 'im Gespräch festgelegt am 2026-09-27, noch nicht gebaut'
---

# Steuerung — Flug durch den latenten Raum

Festgelegt im Gespräch am 2026-09-27, Zeile für Zeile bestätigt. **Nichts davon ist gebaut.**

**Grundlage:** `raw\20260927 threejs controls und gesten.md` (die Controls und Gesten von three.js) und `specs\wwww-rnbo\raw\20260907 three.js controls an rnbo koppeln.md` (wie ein Wert aus three.js bei RNBO ankommt).

> [!abstract] Ein Finger bewegt, zwei Finger formen den Klang, das Handy selbst schaut
> Der Standpunkt entscheidet, welche Felder klingen, die Blickrichtung gewichtet unter ihnen. Daraus wird die Mischung der Presets, die RNBO auf dem Handy spielt. Festgelegt am 2026-09-27, nichts gebaut.
>
> ```mermaid
> flowchart LR
>   subgraph Ein[Ein Finger bewegt]
>     FL["halten, tippen<br/>→ Flug"]
>     EC["wischen<br/>→ Echolot,<br/>Lesezeichen"]
>   end
>   subgraph Zwei[Zwei Finger formen]
>     PA["ziehen, drehen<br/>→ Parameter 1 bis 3"]
>     HW["Pinch<br/>→ Hörweite"]
>     LA["still halten<br/>→ Lauschen"]
>   end
>   subgraph Handy[Das Handy schaut]
>     BL["Gyroskop<br/>→ Blickrichtung"]
>     ST["Schütteln<br/>→ Streuung"]
>   end
>   FL --> SP["Standpunkt:<br/>welche Felder<br/>klingen"]
>   BL --> GW["Gewicht unter<br/>diesen Feldern"]
>   HW --> GW
>   LA --> GW
>   SP --> MI["Mischung<br/>der Presets<br/>in RNBO"]
>   GW --> MI
>   PA --> MI
>   ST --> MI
>   EC -.->|kurz, aus<br/>der Ferne| MI
> ```

^blick

**Verwandt:** `specs\wwww-installation\schnitte.md` (welchen harten Schnitt jede Geste auslöst, Wegmarken fürs Fliegen, Ratsche für den Gyro; ein Versuch), `specs\wwww-main\morphing.md` (Gruppenkurven und Glättung für die Mischung; Vorschläge).

---

## Die Welt

In einem 3D-Koordinatensystem liegen Punkte des latenten Raums. Jeder Punkt trägt eine Position, einen Radius und ein RNBO-Preset als Vektor aus `normalizedValue`-Werten. Um jeden Punkt liegt ein kugelförmiges Feld.

**Über den Arbeiten wird die Kugel zur Säule** mit demselben Radius, nach oben je Stockwerk ein Viertel leiser. Festgelegt am 2026-11-11 in `specs\wwww-rnbo\aufstieg.md`.

**Sichtbar ist der Punkt, als schwaches Licht.** Die Hülle der Kugel leuchtet nur auf, wenn der Spieler eintritt oder das Echolot sie trifft.

Jede Kugel hat drei Zonen:

| Zone | Klang |
|---|---|
| **Kern**, das innerste Drittel | nur das Preset dieses Punkts |
| **Hülle** | Mischung mit den anderen Feldern, in denen der Spieler steht |
| **Grenze** | beim Eintritt ein einmaliges Ereignis, etwa eine Glocke, über `scheduleEvent` auf den Takt gesetzt |

Die Grenze hat eine Hysterese: Eintritt bei 0,95 des Radius, Austritt bei 1,05. Sonst flattert das Ereignis, wenn der Spieler genau auf der Grenze fliegt.

## Wie der Klang entsteht

**Der Standpunkt entscheidet, welche Felder klingen.** Ein Feld ist nur hörbar, wenn der Spieler in seiner Kugel ist.

**Auf einer Ebene schweigt alles**, auch die Felder. Zwischen den Ebenen laufen sie durch ein verschachteltes Allpass-Netz, an den Arbeiten klingen sie pur. Festgelegt am 2026-11-11 in `specs\wwww-rnbo\aufstieg.md`.

**Die Blickrichtung gewichtet unter diesen Feldern.** Das Feld, auf das der Spieler schaut, wird präsenter. Sie macht nie ein Feld hörbar, in dem er nicht steht.

```js
const d = player.distanceTo(p.pos) / p.radius;         // 0 = Zentrum, 1 = Rand
let w = d < 1 ? Math.pow(1 - d * d, schaerfe) : 0;     // Pinch steuert schaerfe
w *= 0.6 + 0.4 * Math.max(0, blick.dot(richtungZuP));  // Aufmerksamkeit per Gyroskop
```

Die Mischung ist das gewichtete Mittel aller Presets. Ist die Summe der Gewichte kleiner als 1, füllt ein eigenes **Zwischenraum-Preset** den Rest auf. Zwischen den Feldern klingt also ein eigener Klang, etwa ein Drone.

Vier Festlegungen aus der RNBO-Notiz:

- `setPreset` springt und blendet nicht über. Die Mischung wird in JS pro Frame gerechnet.
- Mehr als etwa 60 Aktualisierungen pro Sekunde bringen nichts, ein Wert wirkt frühestens im nächsten Audioblock (128 Samples). Viele Parameter gehen als **eine Liste über einen Inport**, nicht als einzelne Parameter.
- Parameter mit `steps`, etwa eine Wellenform-Auswahl, werden nicht gemittelt. Sie kommen vom Punkt mit dem höchsten Gewicht.
- Schreibt RNBO zurück in die Szene, gilt `ParameterNotificationSetting.Internal`, sonst entsteht eine Rückkopplung.

## Ein Finger bewegt

Über dem ganzen Bildschirm liegt ein XY-Feld. Die Mitte heißt vorwärts, oben heißt hoch, unten runter, links links, rechts rechts.

| Geste | Im Raum | Im Klang |
|---|---|---|
| **halten** | Flug in Richtung der Zone, wird mit der Haltedauer schneller | die Geschwindigkeit steuert eine Wind- oder Rauschschicht |
| **tippen** | kurzer Schub | kleiner Transient, wie ein Flügelschlag |
| **Doppeltap** | Fokusflug: weicher Kameraflug zu dem Punkt, der am nächsten am Tap-Strahl liegt | blendet über ein bis zwei Sekunden zu dessen Preset |
| **wischen, beliebige Richtung** | **Echolot**: ein leuchtendes Teilchen fliegt in die Wischrichtung | trifft es ein Feld, erklingt dessen Preset kurz aus der Ferne, leiser und mit Hall |
| **wischen nach unten** | **Lesezeichen ablegen**: an der Position erscheint eine kleine Kugel | sie speichert die Mischung, die gerade klingt, und spielt sie beim nächsten Besuch wieder, unabhängig von der Hörweite |
| **wischen nach oben** | das letzte Lesezeichen verschwindet | — |

Lesezeichen sehen anders aus als Felder, kleiner und in einer eigenen Farbe.

## Zwei Finger formen den Klang

Ziehen, Drehen und Pinch sind **eine Geste mit drei Messwerten**: die Wanderung der Mitte zwischen den Fingern, die Änderung des Winkels und die Änderung des Abstands. Jeder Messwert hat eine eigene Totzone, damit ein Ziehen nicht nebenbei dreht.

| Zwei Finger … | Wirkung |
|---|---|
| ziehen waagerecht | Parameter 1 |
| ziehen senkrecht | Parameter 2 |
| drehen | Parameter 3 |
| auseinander / zusammen (Pinch) | **Hörweite**: weit mischt viele Felder weich, eng lässt das nächste scharf dominieren |
| still halten, ab 0,4 s | **Lauschen**: von den Feldern, in denen der Spieler steht, bleibt nur das hörbar, auf das er schaut |

**Welche drei Parameter des Devices das sind, wird später festgelegt.**

### Versatz oder fest

Jeder der drei Parameter hat zwei Quellen: den Ort, also die Mischung der Felder, und die zwei Finger. Pro Parameter wählt der Spieler, wie sie sich verbinden.

- **Versatz** (Voreinstellung): Die Finger addieren einen Wert zur Mischung. Er reist mit dem Spieler und **bleibt, bis der Spieler ihn zurückzieht**.
- **Fest**: Die Finger setzen den Wert. Das Fliegen ändert diesen Parameter nicht mehr.

| Moment | Der Ort sagt | Versatz | Spieler hört |
|---|---|---|---|
| in Feld A | 0,4 | — | 0,4 |
| zwei Finger nach rechts | 0,4 | +0,3 | 0,7 |
| weiter zu Feld B | 0,2 | +0,3 | 0,5 |
| ins Leere | 0,1 | +0,3 | 0,4 |

### Das Overlay

```
Filter    ──────●───┊────       ┊ = Wert des Ortes
Hall      ───┊───●──────        ● = was der Spieler hört
Körnung   ─●┊───────── 🔒       🔒 = fest, sonst Versatz
```

- klein und halb durchsichtig in einer Ecke
- erscheint bei der Berührung mit zwei Fingern, verblasst zwei Sekunden danach
- ein Tap auf eine Zeile schaltet zwischen Versatz und fest um. Diese Ecke gehört nicht zum XY-Feld.

Weil ein Versatz bleibt, ist das Overlay der einzige Hinweis, dass er aktiv ist.

## Das Handy schaut

| Eingabe | Im Raum | Im Klang |
|---|---|---|
| **Gyroskop** | Blickrichtung | Aufmerksamkeit: ein Feld, auf das der Spieler schaut, klingt präsenter |
| **Schütteln** | die Punkte zittern kurz | Streuung: Zufallsversatz auf alle Parameter, der langsam zurückfedert |

`DeviceOrientationControls` ist aus three.js entfernt. Das Gyroskop wird direkt über `DeviceOrientationEvent` gelesen.

## Der Start

Ein Knopf **„Eintreten"** holt mit einem Tap zwei Freigaben, die beide eine Geste des Nutzers brauchen: den AudioContext und die Gyro-Erlaubnis auf iOS (`requestPermission`, nur über HTTPS).

Derselbe Tap legt fest, welche Haltung des Handys „geradeaus" heißt. Ein kleiner Knopf in einer Ecke tut das später noch einmal, weil der Kompasswinkel driftet.

Derselbe Tap prüft auch, ob echte Gyro-Werte kommen:

```js
async function gyroVerfuegbar() {
  if (typeof DeviceOrientationEvent?.requestPermission === 'function') {   // iOS
    if (await DeviceOrientationEvent.requestPermission() !== 'granted') return false;
  }
  return new Promise(resolve => {
    const t = setTimeout(() => resolve(false), 1000);                     // 1 s ohne Werte = kein Gyro
    addEventListener('deviceorientation', e => {
      if (e.beta !== null) { clearTimeout(t); resolve(true); }
    }, { once: true });
  });
}
```

| Ergebnis | Zonen links und rechts |
|---|---|
| Gyroskop da | schieben seitlich |
| kein Gyroskop oder Erlaubnis abgelehnt | **Lenkrad-Modus**: drehen den Blick, sonst gäbe es kein Rückwärts |

## Wo bin ich?

Ein kleiner Knopf in einer freien Ecke, nicht in der des Overlays und nicht in der des Knopfs „geradeaus". Ein Tap zeigt drei Sekunden lang eine Zeile:

```
In Feld 3 und 5 · Blick auf Feld 5 · Hörweite eng
```

Zugleich leuchten für dieselben drei Sekunden die Hüllen der Felder auf, in denen der Spieler steht. Dasselbe gilt für die Taste `I`.

Im Zwischenraum ist der Klang der einzige Hinweis auf den Standort. Der Knopf gibt einen zweiten. Weil er ein echter `<button>` ist, lesen VoiceOver und TalkBack die Zeile auch auf dem Handy vor.

## Die Werke

In den Feldern stehen three.js-Objekte, die von ursprünglichen Kunstwerken ausgehen: gescannt, digitalisiert und digital erweitert. Festgelegt am 2026-09-30. Für sie gilt die Regel aus `specs\wwww-main\originale.md`: Das Original bleibt trennbar, die Bildbeschreibung entsteht vor dem Original.

**Ein Finger auf einem Werk bedeutet etwas anderes als ein Finger im leeren Raum.** Beim Berühren prüft ein Raycaster, ob der Finger ein Werk trifft. Trifft er keins, gilt die Geste aus „Ein Finger bewegt".

| Geste auf einem Werk | Im Raum | Im Klang |
|---|---|---|
| **tippen** | **Galerie-Schild**: statt Schub | der Klang läuft weiter |
| **halten** | **Aufladen**: das Werk zittert und glüht, höchstens 1,5 s | — |
| **loslassen nach dem Halten** | **Boost**, stärker je länger geladen | ein Ereignis über einen Inport, per `scheduleEvent` auf den Takt, die Ladestärke als Wert |

### Das Galerie-Schild

Ein Tap auf ein Werk löst vier Dinge zugleich aus:

1. Die digitale Erweiterung blendet aus. Übrig bleibt der Scan des ursprünglichen Werks.
2. Der Scan leuchtet auf wie unter einem Galeriestrahler, der Rest der Szene wird dunkler.
3. Der Flug hält an.
4. Neben dem Werk erscheint das Schild, als HTML.

| Zeile auf dem Schild | Beispiel |
|---|---|
| Künstler oder Künstlerin, Lebensdaten | |
| Titel, Jahr | |
| Technik und Material | Öl auf Leinwand |
| Maße | 120 × 80 cm |
| Sammlung oder Standort | |
| kurzer Text zum Werk | zwei bis vier Sätze |
| **Bildbeschreibung** | was man auf dem Werk sieht, für blinde Besucher |
| **Digitale Erweiterung** | was gescannt und was hinzugefügt wurde, wann und womit |

Weil das Schild HTML ist, lesen Screenreader, VoiceOver und TalkBack es vor.

**Schließen:** ein zweiter Tap, oder weiterfliegen. Danach blendet die Erweiterung wieder ein.

### Der Boost

Etwa 3 Sekunden, danach federt alles zurück wie bei der Streuung:

- die Morph Targets des Modells auf Extremwerte
- Rauschen im Shader auf der Oberfläche
- Pulsieren in der Größe und Drehen
- starkes Glühen und herausspritzende Partikel

Danach 5 Sekunden Pause, sonst wird der Boost zum Dauerfeuer. Bei `prefers-reduced-motion` bleiben nur Glühen und Klang.

## Schnatz und Mikroräume

Festgelegt im Gespräch am 2026-11-10. **Nichts davon ist gebaut.** Wie beide aussehen und klingen, steht in `welt.md`. Hier steht, wie man sie bedient.

| Geste | Im Raum | Im Klang |
|---|---|---|
| **tippen auf den Schnatz** | trifft bis etwa 44 px neben ihm, jederzeit, auch im Flug | sein eigener Klang, gefärbt vom Ort |
| **tippen auf den Schnatz vor einem Werk** | Schnatz und Galerie-Schild zugleich | sein Klang, der Klang des Felds läuft weiter |
| **hineinfliegen** an einer Stelle des Werks, sobald das Raster erschöpft ist | öffnet den Mikroraum dort | frühe Reflexionen nach den Maßen des Raums, die Hörweite wird eng |
| **zurückfliegen** durch den Umriss | führt hinaus, die Öffnung bleibt sichtbar, bis man sich entfernt | — |
| **tippen im Mikroraum** | Schild seines Inhalts | — |

**Drei Regeln für den Tap vor einem Werk:**

1. Solange ein Schild offen ist, schließt ein Tap nur das Schild.
2. Beim Abdunkeln der Szene bleibt der Schnatz hell.
3. Verdeckt ein Werk den Schnatz, zählt er nicht.

Ein Tap auf ein Werk schließt eine sichtbare Öffnung, denn das Schild zeigt den Scan. Lesezeichen gelten auch im Mikroraum. Wer dort eines legt, findet die verborgene Stelle wieder.

## Tastatur, Maus und Screenreader

Festgelegt am 2026-09-30. Jede Geste hat eine Taste, für PC-Nutzer und für Barrierefreiheit. Grundlage ist Abschnitt 4 der Gesten-Recherche.

**Zwei Zielgruppen, eine Belegung.** Am PC wird gehalten und kombiniert. Für Barrierefreiheit gilt: eine Taste nach der anderen, kein Timing. Deshalb hat jede gehaltene Taste auch einen Umschalter.

| Handy | Tastatur | Maus |
|---|---|---|
| halten: Flug | `W` halten, wird schneller; `Q` schaltet den Flug an und aus | – |
| tippen: Schub | `W` kurz | – |
| XY-Feld: hoch, runter, seitlich | `Leertaste` hoch, `C` runter, `A`/`D` seitlich | – |
| Doppeltap: Fokusflug | `N` wählt das nächste Feld nach Abstand, `Umschalt+N` das vorige, `Enter` fliegt hin | Doppelklick |
| wischen: Echolot | `E`, in Blickrichtung | Rechtsklick |
| wischen nach unten: Lesezeichen | `B` | – |
| wischen nach oben: Lesezeichen weg | `Rücktaste` | – |
| zwei Finger ziehen, drehen: Parameter 1–3 | `1`/`2`/`3` wählen, `,` und `.` ändern | Regler im Overlay |
| Pinch: Hörweite | `+` und `−` | Mausrad |
| Tap auf eine Overlay-Zeile: Versatz oder fest | `F`, für den gewählten Parameter | Klick auf die Zeile |
| — | `X` setzt den Versatz zurück | – |
| still halten: Lauschen | `L` schaltet um | – |
| Gyroskop: Blickrichtung | Pfeiltasten | Version 1: Maus bewegen |
| Schütteln: Streuung | `G` | – |
| Knopf „geradeaus" | `Pos1` | – |
| — | `H` zeigt und sagt die Belegung an | – |
| Knopf „Wo bin ich?" | `I` sagt an, wo man ist | – |
| Tap auf ein Werk: Schild | `O` wählt das nächste Werk im Blick und öffnet das Schild, ein zweites `O` schließt es | Version 1: Klick auf die Bildmitte |
| auf einem Werk halten: Boost | `V` halten lädt auf, loslassen zündet; `V` kurz zündet mit halber Stärke | – |
| Tap auf den Schnatz | `T`; in Version 1 nur, wenn er nahe der Bildmitte ist, in Version 2 ohne Zielen | Version 1: Klick auf die Bildmitte |
| Hineinfliegen in einen Mikroraum | `M` öffnet den nächsten, ein zweites `M` führt hinaus | – |

`X` gibt es nur hier: Am Handy zieht man den Versatz von Hand zurück, mit Tasten wäre das mühsam.

### Zwei Versionen

Am PC gibt es zwei Versionen. **Ohne `Esc` läuft immer Version 1. Nur `Esc` wechselt, in beide Richtungen.**

| | Version 1: barrierebeschränkt | Version 2: barrierefrei |
|---|---|---|
| Maus | eingefangen, jede Bewegung dreht den Blick | frei, Zeiger sichtbar |
| Doppelklick, Rechtsklick | zielen auf die Bildmitte | – |
| Overlay | nur Anzeige | anklickbar, mit `Tab` erreichbar |
| Ansagen | nur der Hinweis am Start | an |

Die Tasten aus der Tabelle, Halten und Umschalten, gelten in beiden.

- **Der Start:** Es gibt nur den Knopf „Eintreten". Sein Klick fängt die Maus ein (Pointer Lock API) und startet Version 1.
- **Die Ansage am Start:** Bekommt der Knopf den Fokus, sagt der Screenreader: „Eintreten. Mit Escape wechselst du in die barrierefreie Version und zurück." Ein unsichtbarer Text am Knopf, per `aria-describedby`. Ohne Screenreader sieht und hört man nichts davon.
- **Wechsel zu Version 2:** sobald der Browser die Maus freigibt, abgefragt über `pointerlockchange`. Das ist `Esc`, aber auch der Wechsel in ein anderes Fenster. Der Screenreader sagt: „Barrierefreie Version, Ansagen an."
- **Wechsel zu Version 1:** `Esc` in Version 2. Ansagen und anklickbares Overlay gehen sofort aus, der Screenreader sagt davor noch „Version 1, Ansagen aus". Die Maus wird erst beim nächsten Klick eingefangen, denn der Browser fängt sie nie auf `Esc` hin ein. Dieser Klick tut sonst nichts.
- **Ein Klick wechselt nie die Version.** In Version 2 wirkt die Maus nur auf das Overlay.

Die Seite schaltet keinen Screenreader an. Er läuft auf dem Rechner des Nutzers. Version 2 gibt ihm etwas zum Vorlesen.

### Screenreader

- **Das Canvas bekommt `tabindex="0"`, einen sichtbaren Fokusrahmen und `role="application"`.** Nur mit `application` gibt ein Screenreader wie NVDA die Tasten an die Szene weiter. Mit `role="img"` fängt er `E` oder `H` selbst ab.
- **Die Tasten wirken nur, solange das Canvas den Fokus hat.** Einzelne Buchstaben als Kürzel verlangen das (WCAG 2.1.4).
- **`Tab` bleibt frei und führt hinaus.** Sonst ist das Canvas eine Tastaturfalle (WCAG 2.1.2). `Esc` gehört dem Wechsel der Versionen.
- **Tasten per `event.code`, nicht `event.key`.** WASD liegt so auf jeder Tastatur an derselben Stelle. `Z` und `Y` bleiben frei, sie sind zwischen QWERTZ und QWERTY vertauscht.
- **Keine Kombination mit `Strg`.** `Strg+W` schließt den Tab.

Diese fünf Punkte gelten in beiden Versionen. Sie sind unsichtbar und stören niemanden.

**Die Ansagen** gibt es nur in Version 2. Sie laufen über ein unsichtbares `<div aria-live="polite">`. Der Klang trägt die meiste Rückmeldung schon. Angesagt wird nur, was man nicht hört:

| Ereignis | Ansage |
|---|---|
| Feld betreten, verlassen | „Feld 3, Hülle" |
| `N` wählt ein Feld | „Feld 5, 12 Meter entfernt" |
| Echolot trifft | „Echo von Feld 2" |
| Lesezeichen gesetzt, entfernt | „Lesezeichen 2 gesetzt" |
| Parameter geändert | Name und Endwert, erst 0,5 s nach der letzten Änderung |
| Lauschen, Versatz oder fest | „Lauschen an", „Filter fest" |
| alle Felder verlassen | „Zwischenraum" |
| Zone wechselt im selben Feld | „Feld 3, Kern" |
| Fokusflug angekommen | „Bei Feld 5" |
| Echolot trifft nichts | „Kein Echo" |
| Lesezeichen erreicht | „Lesezeichen 2" |
| `Rücktaste` ohne Lesezeichen | „Kein Lesezeichen" |
| `Q`: Flug an, aus | „Flug an", „Flug aus" |
| `1`/`2`/`3`: Parameter gewählt | „Filter gewählt, 40 %" |
| Hörweite geändert | „Hörweite eng" bis „Hörweite weit", gedrosselt wie die Parameter |
| `X`: Versatz zurückgesetzt | „Versatz zurückgesetzt" |
| `G`: Streuung | „Streuung" |
| `Pos1`: Blick zurückgesetzt | „Blick geradeaus" |
| `I`: Wo bin ich? | „In Feld 3 und 5, Blick auf Feld 5, Hörweite eng" |
| Schild geöffnet | Titel und Künstler, danach liest der Screenreader das Schild |
| Boost | „Boost, [Titel]" |
| `T` trifft den Schnatz | „Schnatz, über Feld 7" |
| Mikroraum geöffnet | „Mikroraum 2 offen" |

Ohne die Drossel von 0,5 s würde der Screenreader jeden Zwischenwert vorlesen.

### Das Overlay

**Das Overlay besteht aus echten `<input type="range">`, nicht aus Strichen im Canvas.** Tastatur und Screenreader bedienen sie ohne eigenen Code, etwa „Filter, Schieberegler, 40 %". Das Aussehen aus „Das Overlay" oben bleibt, per CSS.

- Am Handy lassen sich die Parameter so auch mit einem Finger einstellen (WCAG 2.5.1).
- **In Version 1** erscheint es nur, wenn ein Parameter geändert wird: mit `1`/`2`/`3`, `,` oder `.`. Zwei Sekunden danach verblasst es, wie am Handy.
- **In Version 2** hält es sich, solange ein Regler den Fokus hat.
- Der Schalter „fest" ist ein `<button aria-pressed>`.

## Der Guide

Festgelegt am 2026-10-03. Grundlage sind `raw\scene-tools.js`, `raw\page-agent.js` und `raw\server.js`.

**Der Guide liest nur vor.** Er bewegt nichts und ändert keinen Klang. Deshalb kann er weder mit dem Finger um die Kamera kämpfen noch die Mischung überschreiben.

Ein Besucher fragt in eigenen Worten, etwa „Was ist hier?" oder „Was zeigt das Bild vor mir?". Ein Sprachmodell antwortet und benutzt dafür drei Werkzeuge:

| Werkzeug | Liefert | Entspricht |
|---|---|---|
| `where_am_i` | Felder, in denen der Spieler steht, Zone, Blick, Hörweite | Knopf „Wo bin ich?", Taste `I` |
| `list_fields` | alle Felder mit Nummer, Abstand und Richtung | `N` |
| `show_sign` | die Zeilen des Galerie-Schilds eines Werks, mit Bildbeschreibung | Tap auf ein Werk, Taste `O` |

- Die Werkzeuge rufen dieselben Funktionen auf wie Knopf und Tasten.
- Die Antwort läuft über dasselbe `aria-live`-Feld wie die Ansagen.
- Der API-Schlüssel bleibt auf dem Server. Der Server braucht eine Grenze pro IP und eine Tagesgrenze, weil die Seite öffentlich ist.
- Der Verlauf wird nach den letzten Runden abgeschnitten, sonst lehnt der Server ab 60 Nachrichten ab.

## Der Zwilling auf V4

Festgelegt im Gespräch am 2026-10-29 und 2026-10-30, das Nachlaufen am 2026-11-04. **Nichts davon ist gebaut.**

Der Bildschirm V4 liegt am Rand des Teppichs auf dem Boden, das feste Handy M1 hängt über der Mitte am Federzug (`aufbau.json`). **V4 zeigt dieselbe Welt wie M1**, vom selben Standpunkt mit demselben Blick. Nur haben einzelne three.js-Objekte auf V4 andere Parameter. Manchmal sind beide Bilder genau gleich, manchmal weit voneinander entfernt. Die Symmetrie liegt im Raum: M1 hängt oben, V4 liegt darunter.

| Was | Wirkung auf V4 |
|---|---|
| ein ☽, alle 240 s | setzt ein neues Ziel: wie weit die Parameter abweichen |
| jeder Atemzug, alle 3,33 s | geht einen Schritt auf dieses Ziel zu |
| jemand bedient M1 | V4 läuft M1 einen Atemzug (3,33 s) hinterher. Erst wenn der Spieler still hält, sind beide Bilder gleich. Lässt er M1 los, läuft V4 wieder auf sein Ziel zu. |

Wer M1 spielt, sieht seine Welt doppelt. Wer zuschaut, sieht sie sich verwandeln.

**Wie es läuft:** Der Mac mini rechnet die Welt ein zweites Mal, in einem Browser neben Max. Standpunkt und Blick schickt M1 ohnehin per OSC, wie jedes Handy (`kommunikation.md`, „Was wo läuft“).

**Am laufenden Prototyp entschieden:** welche Parameter abweichen, etwa Zeit, Farbe und Material, Geometrie oder Kamera, und ob man sich nach 3,33 s Nachlauf im Bild noch wiedererkennt.

## Was für den Bau gilt

- `canvas { touch-action: none; }`, sonst fängt der Browser Pinch und Wischen ab.
- Aktionen lösen bei `pointerup` aus, nicht bei `pointerdown`. So lässt sich eine Geste durch Wegziehen abbrechen.
- Bei `prefers-reduced-motion` werden Trägheit und Kamerafahrten verkürzt, abgefragt per `matchMedia` in JS. Der Schnatz fliegt dann langsamer und verweilt länger, der Spiegel am Grund kippelt nicht, und die Faltung der fernen Werke fällt schwächer aus (`welt.md`).
- Die Gesten erkennt ein Zustandsautomat: `pointerdown`, abwarten, dann Tippen, Halten, Wischen oder zweiter Finger. `@use-gesture/vanilla` nimmt diese Logik ab.
- Der Bildschirmrand bleibt frei, weil iOS und Android dort „Zurück" erkennen.
- **Scan und Erweiterung sind im Modell getrennte Teile**, sonst lässt sich die Erweiterung nicht ausblenden. Wie, steht in `specs\wwww-main\originale.md`.
- **Höchstens drei Blitze pro Sekunde**, in beiden Versionen (WCAG 2.3.1). Schnelles Flackern kann einen epileptischen Anfall auslösen. Das gilt vor allem für den Boost.

## Bewusst nicht drin

| Draußen | Warum |
|---|---|
| Wischen links/rechts als 90°-Drehung, Wischen nach unten als Bremsen | abgelehnt, das Wischen gehört dem Echolot und den Lesezeichen |
| 2 Finger tippen zum Neuausrichten | ersetzt durch den Start-Tap und den Knopf in der Ecke |
| 3 Finger tippen für eine Übersicht | abgelehnt, drei Finger auf dem Handy sind unbequem |
| „Zeit drehen" | abgelehnt, das Drehen steuert Parameter 3 |
| Handy seitlich kippen als Parameter | abgelehnt |
| Handy mit dem Display nach unten als Pause | im Gespräch nicht bestätigt |
| Spur der Flugbahn mit Echo | abgelehnt |
| zweiter Knopf „Barrierefrei eintreten" | abgelehnt, ein Knopf mit Ansage reicht |
| freie Maus als Voreinstellung, Blick durch Ziehen, `M` zum Einfangen | abgelehnt, ohne `Esc` läuft immer Version 1 |
| Vibration beim Eintritt | abgelehnt, iOS kennt `navigator.vibrate` ohnehin nicht |
| Gyroskop abschaltbar mit Ziehen am Rand als Ersatz | abgelehnt, der Lenkrad-Modus deckt die Geräte ohne Gyroskop ab |
| Doppeltap öffnet das Schild | abgelehnt, der Tap ist direkter, und der Fokusflug bleibt ohne Schild möglich |
| `Esc` schließt das Schild | geht nicht, `Esc` wechselt die Version |
| ein Klick in die Szene wechselt zu Version 1 | abgelehnt, ein Klick auf ein Werk wechselte sonst unerwartet die Version |
| eine eigene Taste wie `P` für den Rückweg zu Version 1 | abgelehnt, `Esc` wechselt in beide Richtungen |
| `DragControls`, `TransformControls` für die Werke | passen nicht, sie verschieben Objekte wie in einem Editor |
| schreibende Werkzeuge für den Guide: Fokusflug, Parameter, Hörweite, Lesezeichen | vorerst draußen, die Kamerafahrt stört den Finger, und die Mischung pro Frame überschreibt jeden Wert |

## Was offen ist

- **Die drei Parameter** für Ziehen und Drehen.
- **Was der Boost trifft:** nur die digitale Erweiterung, oder das ganze Werk samt Scan. Wird getestet.
- **Die Zuordnung zum Motiv-Rahmen** aus `specs\wwww-main\raw\20260808 context infos.md`: 12 Punkte als die „äußerlich stillen Kraftzentren", die Gesten als die 7 Bewegungen. Das trägt nur, wenn der latente Raum 12 Punkte hat. Die Punkte tragen die Tierkreiszeichen, die Bewegungen die Planeten (`specs\wwww-main\konzept.md`, „Das Heft als Ursprung“). Offen ist, welche Geste zu welchem Planeten gehört.
- **Den latenten Raum direkt lesen statt Presets mischen.** Läuft der Decoder des Modells im Browser, macht er aus der Position des Spielers einen eigenen Parametersatz. Zwischen den Feldern entstünden dann neue Klänge statt Mischungen.
- **Wie der Besucher den Guide fragt:** über ein Textfeld oder per Spracheingabe.
- **Ob der Guide ohne Internet laufen muss.** In der Installation fehlt ihm sonst das Sprachmodell.
