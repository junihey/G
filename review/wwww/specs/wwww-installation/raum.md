---
tags: [spec, wwww-installation, raum, aufbau]
created: 2026-11-02
topic: 'Wie wwww ohne eigenen Raum auskommt -- der Raum entsteht durch Verhalten, drei Aufstellungen passen sich der zugewiesenen Flaeche an, Klang und Bild bleiben begrenzt'
verification: 'Entscheidungen vom Nutzer am 2026-11-02, nach der Kritik des Professors vom Review. Masse der Aufstellungen aus aufbau.json. Preise und Akustik sind Schaetzungen von Claude aus dem Gedaechtnis, nichts gemessen, nichts gebaut. Die Bild-Prototypen werden in den kommenden Tagen getestet.'
---

# Raum — der Raum entsteht durch Verhalten

Stand 2026-11-02. **Nichts davon ist gebaut, die Prototypen stehen noch aus.**

> [!abstract] Der Raum entsteht durch Verhalten, nicht durch Wände
> Der zugewiesene Raum ist erst kurz vorher bekannt, und die Nachbarn der Gruppenausstellung dürfen nicht gestört werden. Deshalb braucht wwww keine Wände und keine Verdunklung. Die Schwelle bilden die Blätter „barfuß“ und die Interaktion, es ist ein Erkenntnisraum. Vor Ort wird gemessen und eine von drei Aufstellungen gewählt.
>
> ```mermaid
> flowchart TD
>   F[Fläche vor Ort messen] --> A[Aufstellung wählen]
>   A --> B[Bahn]
>   A --> E[Ecke]
>   A --> I[Insel]
>   B --> S["Schwelle:<br/>Schuhe aus, „barfuß“"]
>   E --> S
>   I --> S
>   S --> G["Interaktion:<br/>Handy, Kamera, Mikrofon"]
>   G --> K[Klang öffnet sich]
>   G -.->|niemand da| ST["verklingt in bis zu 60 s,<br/>dann Stille"]
> ```

^blick

**Was hier steht:** die Aufstellungen, die Abgrenzung von Klang und Bild, die Aktivierung.

**Was hier nicht steht:** was die Arbeit ist und was ihr Titel sagt, das steht in `specs\wwww-main\konzept.md`. Wo jedes Element liegt, steht in `aufbau.json`.

**Verwandt:** `aufbau.json` (die drei Aufstellungen), `teppich.md` (die Ruhe als Regel), `kommunikation.md` (das Raummikrofon).

---

## Vom Nutzer, 2026-11-02

| Was | Wie |
|---|---|
| Der Raum | ein Erkenntnisraum, der durch Verhalten und Interaktion entsteht. Wände sind nicht nötig, die Schwelle bilden die Blätter „barfuß“ und die Interaktion. |
| Aufstellungen | Bahn, Ecke, Insel, in einer `aufbau.json` |
| Kacheln | 60 × 40 cm, damit sie in Eurokisten passen |
| Big Bags | zwei Rahmen auf gegenüberliegenden Seiten ziehen den Bag von 110 auf etwa 50 cm zusammen. Wandfläche 200 × 110 cm, 2 bis 3 Bags. |
| Tetraeder | im Sinne der Kugel: ein Körper, den man umrundet, kein Zelt und keine Höhle |

## Die drei Aufstellungen

Im aufbau-generator gewählt über die Knöpfe „Aufstellung“. **Bevorzugt ist die Insel**, vom Nutzer am 2026-11-02. Die Dokumente `aufbau-kurator.html` und `aufbau-technik.html` zeigen alle drei auf einer Seite: die Insel groß, Bahn und Ecke klein, darunter der Vergleich.

| Aufstellung | Teppich | Fläche | Big Bags |
|---|---|---|---|
| Bahn | 3,6 × 1,6 m | 7,2 × 2,5 m, ein Flur reicht | 2, an den beiden Enden |
| Ecke | ein L, außen 3 × 2,4 m | 4 × 4 m, zwei Wände | 2, an den beiden offenen Seiten |
| Insel | 2,4 × 2,4 m | 5 × 4 m | 3, als U |

**Der Teppich hat 12 Felder aus je zwei Kacheln**, also 60 × 80 cm pro Feld und 24 Kacheln. Das ist eine Lesart von Claude: Zwölf einzelne Kacheln ergäben nur 2,9 m². So bleibt die Zwölf der Kraftzentren erhalten, und die Größe passt zu den gewünschten Maßen. Auf der Karte ist der Teppich eine einzige Fläche.

**Die Insel folgt der Anordnung der alten Karte** in `aufbau-vor-aufstellungen.json`, halbiert von 10 × 8 m auf 5 × 4 m, vom Nutzer am 2026-11-02. Nur die Big Bags weichen ab: Zwei Wände von 2 m passen nicht nebeneinander an den Teppichrand, sie stehen deshalb als U.

Genelec und Beamer sind in keinem Plan eingezeichnet, solange Klang und Bild offen sind.

## Die Big-Bag-Wände

Zwei Rahmen aus Dachlatten, 200 × 110 cm, und vier Ratschengurte um beide. Das geht ohne Werkstatt, der Baumarkt schneidet zu.

**Offen:**

- **Die Füllung entscheidet über das Gewicht.** Ein Bag hat 1,1 m³. Mit Hafer wären das grob 500 kg, geschätzt mit 0,5 kg pro Liter. Stroh, Laub, Holzwolle oder Papierschnipsel wiegen einen Bruchteil.
- **Hoch oder quer.** Hochkant, 200 cm hoch auf 50 cm Fuß, kann er kippen. Quer, 110 cm hoch, steht er sicher und trägt den Kranz, aber der Klang geht darüber hinweg.

## Die Abgrenzung des Klangs

Der Klang ist grundlegend entgrenzend. Die drei Wege lassen sich verbinden. Die Preise sind Richtwerte aus dem Gedächtnis.

| Weg | Stärke | Nachteil | Was es braucht |
|---|---|---|---|
| **Big-Bag-Wände** | 50 cm Füllung schlucken auch tiefere Töne, und die Wand ist zugleich Bildfläche | nach oben offen, sperrt nicht ganz, schwer je nach Füllung | Bags, Rahmen, Gurte, Füllung |
| **Klangdusche** | der Klang hängt als Kegel über dem Teppich, nichts am Boden | **keine tiefen Frequenzen**, eine Schüssel von 60–80 cm bündelt erst ab etwa 500 Hz | alte Satellitenschüssel oder Schirm (0–30 €), kleiner Lautsprecher im Brennpunkt, zeigt in die Schüssel, Punkt an der Decke |
| **Körperschall** über die Füße | sehr wenig offener Schall, „barfuß“ bekommt einen zweiten Sinn | **keine hohen Frequenzen**, Teppich und Filz schlucken sie; Stein und Big Bag klingen kaum | Exciter von Visaton oder Dayton (10–20 € pro Stück), Sub oder Bass-Shaker wie Dayton TT25, Verstärkerplatine TPA3116 mit Netzteil (10–25 €), Platte aus Hartfaser oder Sperrholz, Filz gegen den Boden |

**Klangdusche und Körperschall ergänzen sich:** Die Exciter tragen die Tiefen, die Dusche die Höhen.

**Erster Test für etwa 15 €:** ein Exciter, eine PAM8403-Platine und eine Baumscheibe an einem Ausgang des Audient.

Verworfen: Rahmen mit Absorbern. Sie schlucken den Nachhall innen, sperren den Klang nach außen aber kaum.

## Die Abgrenzung des Bilds

Drei Prototypen, Test in den kommenden Tagen. Keiner braucht einen dunklen Raum.

| Prototyp | Wie | Die Schleife mit der Kamera |
|---|---|---|
| **Feedback über Bildschirm** | die Kamera filmt den Bildschirm V4 | Bild, Kamera und Rechner schließen sich direkt, wer dazwischengreift, greift ein |
| **Projektion an die Big-Bag-Wände** | der Beamer zielt auf die Wandfläche 200 × 110 cm | die Kamera filmt die Wand, wer davorsteht, wirft einen Schatten |
| **Schaukasten** | ein Tetraeder mit Milchfolie, Projektion von innen | die Kamera filmt die Folie |

## Aktivierung

Empfehlung von Claude, vom Nutzer in der Change-Liste am 2026-11-02 bestätigt.

**Interaktion schaltet den Klang ein. Die Raumlautstärke bestimmt nur, wie laut er ist.** Als Auslöser taugt sie nicht: Die Nachbarn würden wwww starten, und das Mikrofon hört auch den eigenen Ausgang.

| Was | Rolle |
|---|---|
| Geste am Handy, auch an M1 | öffnet den Klang |
| Kamera: jemand steht auf dem Teppich | öffnet den Klang |
| Mikrofon | zählt nur, solange jemand auf dem Teppich steht |
| Raumlautstärke | passt den Pegel an, mit fester Obergrenze, startet nichts |
| niemand da | der Eingang schließt, der Klang verklingt in bis zu 60 s, dann Stille |

## Was offen ist

- Füllung der Big Bags, hoch oder quer.
- Welcher Weg den Klang begrenzt: Testen mit dem 15-€-Aufbau.
- Welcher Bild-Prototyp trägt.
- Die Kabelwege in den drei Plänen, sie sind noch gerade Linien.
- Wo die verbundenen LEDs L1 liegen: Die Big Bags stehen nicht mehr nebeneinander. Heute liegen sie auf der Insel in der Ecke zwischen zwei Bags, in Bahn und Ecke bei einem Bag.
