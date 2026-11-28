---
tags: [spec, wwww-installation, wwww-threejs, schnitte, versuch]
created: 2026-10-23
topic: 'Harte Schnitte in Handy-Audio, Installations-Audio und Bild-Schleife -- woran der Besucher hoert und sieht, welche seiner Aktionen welchen Algorithmus ausloest'
verification: 'Im Gespraech am 2026-10-23 entwickelt. Alles hier ist ein Versuch und kann verworfen werden. "Gewaehlt" heisst: vom Nutzer als Versuch ausgewaehlt. Nichts gebaut, nichts gehoert. Zahlen zur Wahrnehmung aus Roads, Microsound (2002), mit Seitenangabe.'
---

# Schnitte — woran man die Algorithmen hört

Stand 2026-10-23. **Alles hier ist ein Versuch.** Nichts ist gebaut, nichts gehört, jede Zeile darf wieder fallen.

> [!abstract] Jede Aktion des Besuchers schneidet hart in alle drei Kanäle
> Die Länge des Schnitts sagt, welche Aktion es war: 1 ms für einen Tap bis 3,33 s für einen Fang vom Raummikrofon. Das Handy setzt aus, die Installation fügt einen Impuls ins FDN ein, im Bild pausiert die Kamera. Alles ist ein Versuch.
>
> ```mermaid
> flowchart TD
>   subgraph Leiter[Je mehr Körper, desto länger]
>     direction TB
>     K["Klick · 1 ms<br/>Tap auf ein Werk"] --> P["Pop · 4 ms<br/>Wischen, Echolot"] --> B["Bruch · 20 ms<br/>Feldgrenze"] --> S["Splitter · 80 ms<br/>Schütteln, Boost"] --> A["Atemzug · 3,33 s<br/>Fang vom Raummikrofon"]
>   end
>   Leiter -->|Lücke| H["Handy:<br/>der eigene Klang<br/>setzt aus"]
>   Leiter -->|Einfügung| I["Installation:<br/>ein Impuls<br/>ins FDN"]
>   Leiter -->|Vergessen| V["Bild:<br/>die Kamera<br/>pausiert"]
> ```

^blick

**Was hier steht:** welche Schnittlängen es gibt, wie jeder Kanal schneidet und wie die Dauer-Algorithmen Fliegen und Gyro schneiden.

**Was hier nicht steht:** die Gesten selbst. Die stehen in `specs\wwww-threejs\steuerung.md`. Die drei Schleifen stehen in `kommunikation.md`.

**Quelle:** Curtis Roads, *Microsound*, MIT Press 2002, in `zaehlen\quellen\scans\mathe\`.

---

## Was Roads vorgibt

Nur Längen, die in verschiedene Kategorien der Wahrnehmung fallen, sind unterscheidbar. Das sind etwa fünf.

| Länge | was man hört | Roads |
|---|---|---|
| unter 2 ms | ein Klick. Die Länge ist nicht hörbar, nur die Klangfarbe | S. 24 |
| 4 ms Lücke in einem Sinus | ein Pop. In rosa Rauschen unhörbar | S. 23 |
| 20 ms Lücke | der Ton bricht in zwei, wie doppelt angeschlagen | S. 23 |
| 14–45 ms Inhalt | ab hier hat ein Stück Klang eine Tonhöhe | S. 24 |
| etwa 20 Impulse pro Sekunde | sie verschmelzen zu einem Ton | S. 23 |

**Ein gleichbleibender Reiz wird ignoriert, Transienten ziehen die Aufmerksamkeit an** (S. 237). Deshalb schneidet ein Dauer-Algorithmus nur, wenn sich etwas ändert.

## Die Leiter — gewählt als Versuch

Je mehr Körper handelt, desto länger der Schnitt: Finger, Hand, Weg, Körper, Raum.

| Stufe | Länge | Aktion |
|---|---|---|
| Klick | 1 ms | Tap auf ein Werk |
| Pop | 4 ms | Wischen, Echolot |
| Bruch | 20 ms | eine Feldgrenze überfliegen, mit der Hysterese aus `steuerung.md` |
| Splitter | 80 ms | Schütteln, Boost |
| Atemzug | 3,33 s | ein Fang vom Raummikrofon, das Tor aus `kommunikation.md` |

Das Bild dazu steht oben im Blick.

## Wie jeder Kanal schneidet — gewählt als Versuch

Eine Aktion schneidet in allen drei Kanälen zugleich, mit derselben Stufe.

| Kanal | Art | was der Besucher erlebt |
|---|---|---|
| Handy | **Lücke**: der eigene Klang setzt hart aus | ein Schnitt in seinen eigenen Klang |
| Installation | **Einfügung**: ein harter Impuls in der Länge der Stufe geht ins FDN | das FDN wiederholt den Schnitt als abklingende Echos |
| Bild | **Vergessen**: die Kamera pausiert, der Beamer zeigt Schwarz | das ganze Bild oder ein Streifen verschwindet, danach baut sich das Feedback über Sekunden neu auf |

In der Installation wird eingefügt statt ausgespart. Der Teppich ist rauschartig, darin verschwindet eine 4-ms-Lücke (S. 23).

Im Bild wirkt der Schnitt auf das ganze Bild (Nutzer, 2026-10-23), solange wenig im Raum geschieht. Wie es sich bei mehr Aktionen in Streifen teilt, steht weiter unten. Ein Bild dauert bei 60 fps 16,7 ms. Klick, Pop und Bruch werden deshalb alle zu einem Bild Pause, das Bild unterscheidet nur drei Stufen:

| Stufe | Pause der Kamera |
|---|---|
| Klick, Pop, Bruch | 1 Bild |
| Splitter | 5 Bilder |
| Atemzug | 200 Bilder |

Nach Schwarz braucht die Schleife einen **Keim**, aus dem sie wieder wächst: Licht im Raum, Menschen im Bild, oder ein Rest, den der Rechner beimischt. Ohne Keim sieht die Kamera einen schwarzen Beamer und bleibt schwarz.

Die Variante **Halten** wäre: Die Kamera friert ihr letztes Bild ein, statt Schwarz zu zeigen. Das Bild steht still und läuft danach weiter, es baut sich aber nicht neu auf. Sie ist nicht gewählt und bleibt als Vergleich im Test.

**Die Menge der Aktionen im Raum teilt das Bild in senkrechte Streifen** (Nutzer, 2026-10-23). Gezählt werden die Aktionen der letzten 10 s aus allen drei Quellen: Handys, Kamera, Raummikrofon. Gezählt wird nicht, wie viele Handys verbunden sind. Eine Aktion in 10 s: ihr Schnitt pausiert das ganze Bild. Vier Aktionen: das Bild hat vier Streifen, und jeder Schnitt pausiert nur einen. Je mehr im Raum geschieht, desto feiner wird das Bild geteilt.

Was als eine Aktion zählt:

| Quelle | eine Aktion ist |
|---|---|
| Handy | ein Schnitt der Leiter: Tap, Wischen, Feldgrenze, Schütteln, Boost |
| Kamera | die Bewegung im Bild steigt über eine Schwelle, mit Hysterese wie bei der Feldgrenze |
| Raummikrofon | der Raum-Anteil steigt über die Schwelle aus `kommunikation.md`, auch wenn das Tor nach einem Fang noch gesperrt ist |

Wegmarken und Ratsche zählen nicht. Sie schneiden nur auf dem Handy und kämen auf Dutzende pro Sekunde.

Ein Fang vom Raummikrofon zählt mit, pausiert aber immer das ganze Bild. Er gehört dem ganzen Raum.

## Fliegen und Gyro — gewählt als Versuch

Beide schneiden **nur auf dem Handy**. In Installation und Bild erscheint vom Fliegen nur der Bruch an der Feldgrenze. Fliegen zehn Besucher und jeder Klick ginge auf die Genelecs, fände niemand seinen eigenen wieder.

**Fliegen — Wegmarken.** Pro Zehntel eines Feldradius Flugstrecke ein harter Klick. Langsam einzelne Klicks, ab etwa 20 pro Sekunde ein Ton, dessen Höhe die Geschwindigkeit ist.

**Gyro — Ratsche.** Alle 15° Drehung ein harter Klick. Zu einem Feld hin werden die Rasten feiner: 15°, 5°, 1°. Stillhalten ist still.

**Lauschen** (Stillhalten ab 0,4 s) ist der einzige Zustand ohne Schnitt auf dem Handy.

### Warum der harte Schnitt die Klangfarbe trägt

Zwei Wege, beide aus Roads, auf Schnitte übertragen.

**Ein einzelner Klick** hat keine hörbare Länge, aber eine Klangfarbe (S. 24). Unter 2 ms wird die Länge der Pause zur **Helligkeit**: je kürzer, desto heller und leiser. Das ausgeschnittene Stück ist der Klick, und ein Stück der Länge T hat seine Energie unterhalb von etwa 1/T.

| Pause | Samples bei 48 kHz | Energie bis etwa | klingt wie |
|---|---|---|---|
| 2 ms | 96 | 500 Hz | dumpfes „tock“ |
| 1 ms | 48 | 1 kHz | Klopfen |
| 0,5 ms | 24 | 2 kHz | „tick“ |
| 0,25 ms | 12 | 4 kHz | helles „tsk“, etwa 12 dB leiser als 1 ms |

Die Tabelle ist hergeleitet, nicht gehört. Für einen eingefügten Impuls im FDN gilt sie genauso.

Dazu färbt das **Material**: Die Ratsche schneidet in die Mischung, die der Besucher gerade hört. In einem tiefen Feld klingt der Klick dumpf, in einem hellen hell, er trägt die Farbe des Orts. Bei einem tiefen Drone hängt die Lautstärke davon ab, wo die Pause die Welle trifft: am Wellenberg laut, im Nulldurchgang fast nichts. Abhilfe: den Schnitt bis zum nächsten Wellenberg verzögern, bei 100 Hz höchstens 5 ms.

**Eine Kette von Klicks** ist wie ein Pulsar-Zug (S. 138). Die Rate ergibt die Tonhöhe, die Länge des einzelnen Impulses einen **Formanten**, beide getrennt steuerbar. Übertragen: Bei den Wegmarken ist die Fluggeschwindigkeit die Tonhöhe, die Schnittlänge die Klangfarbe. 1 ms liegt bei einem Formanten um 1 kHz, 4 ms um 250 Hz.

Ob die Übertragung von Pulsaren auf Lücken in einem laufenden Klang trägt, ist ungeprüft.

## Zu testen

| Was | Wie | Warum |
|---|---|---|
| **Füllung** statt Lücke | die Lücke wird mit dem Klang ihres Auslösers gefüllt: ein Fang mit Raummikrofon, eine Handy-Aktion mit Handyklang | der Schnitt zeigt seine Ursache. Hörbar erst ab etwa 14 ms (S. 24), also nicht bei Klick und Pop |
| Blindtest der Leiter | die fünf Stufen auf dem Teppich vorspielen, sortieren lassen | was verwechselt wird, darf nicht zwei Aktionen tragen |

## Offen

- **Das Fenster von 10 s.** Gewählt, weil das Feedback etwa so lange zum Neuaufbau brauchen dürfte. Nicht gemessen.
- **Welcher Streifen pausiert.** Reihum von links nach rechts, oder nach der Stelle, an der die Kamera die Bewegung sieht. Die zweite Lösung gibt es nur für die Kamera, Handy und Mikrofon haben keine Stelle im Bild. Offen.
- **Welche Stufe die Kamera schneidet.** In der Leiter fehlt sie noch. Vorschlag: Splitter, 80 ms, weil der ganze Körper handelt.
- **Wofür die Helligkeit dient.** Unter 2 ms ist sie als Merkmal frei. Vorschlag: eine Unterstufe innerhalb des Klicks, etwa Tap auf ein Werk gegen Tap auf ein Lesezeichen.
- **Gleichzeitigkeit.** Beamer und Kamera verzögern das Bild. Wie weit ein Schnitt im Bild hinter dem im Klang liegen darf, damit beide als ein Ereignis gelten, ist nicht gemessen.

## Nicht verfolgt

| Was | Warum |
|---|---|
| waagerechter Streifen im Bild: seine Höhe ist die Länge des Schnitts | der Nutzer will, dass der Schnitt das ganze Bild trifft, geteilt wird nur nach der Menge der Aktionen |
| Besucher und System unterscheiden, durch Takt, Muster oder Helligkeit | die Leiter trennt die Arten der Aktion schon, das Handy trennt mich von den anderen |
| weiche Flanke, 1 ms Blende | der Nutzer will den harten Schnitt, weil er die Klangfarbe trägt |
| Integrate-and-Fire: Bewegung füllt einen Speicher, voll schneidet er | Wegmarken und Ratsche gewählt |
| nur die Ränder: Beginn, Ende und Umkehr einer Bewegung schneiden | Wegmarken und Ratsche gewählt |
