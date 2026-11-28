---
tags: [spec, wwww-threejs, welt]
created: 2026-11-10
topic: 'Die Welt, durch die man fliegt -- Raum, Schnatz, Nebel, Kaleidoskop, Mikroraeume, Ebenen, Grund, Bewegungsbild, Schleier und Renderer'
verification: 'Vom Nutzer am 2026-11-10 Frage fuer Frage entschieden, ausgehend von handoffs\2026-11-05-wwww-ideen-moeglichkeiten.md. Die Kurven der Ebenen sind gegen ihre Gleichungen nachgerechnet und als Skizze gezeichnet. Nichts davon ist gebaut, gehoert oder auf einem Handy gemessen. Bezuege auf Steiner und Adams sind Lesarten von Claude, soweit nicht anders vermerkt.'
---

# Welt — wodurch man fliegt

Stand 2026-11-10. **Nichts davon ist gebaut.**

> [!abstract] Alles geht von den Arbeiten aus, nichts berührt ihre Scans
> Die Welt ist ein Verlauf, unten weiß, oben schwarz. Jede Arbeit steht in klarer Luft, ferne Arbeiten falten sich zu Blüten. Ein Lichtpunkt unter den Arbeiten trägt ihre Farben auf Ebenen aus Fäden, die sich wölben und teilen können. Alles Digitale darf flimmern, zersplittern und sich öffnen, die Scans bleiben immer sauber.
>
> ```mermaid
> flowchart TD
>   L["Lichtpunkt<br/>unter den Arbeiten"] --> A["Arbeiten<br/>in klarer Luft"]
>   A -->|Farben| E["Ebenen<br/>aus Fäden"]
>   A -->|nah| M["Mikroraum<br/>hinter Portal"]
>   A -->|fern| K["Blüte aus<br/>Kopien"]
>   E -->|Figur unter 1| S["Spalt:<br/>zwei Ebenen"]
>   SN["Schnatz und<br/>Spiegel"] -.->|spiegeln| A
> ```

^blick

**Was hier steht:** wie die Welt von `wwww-threejs` aussieht, was in ihr liegt und womit sie gezeichnet wird.

**Was hier nicht steht:** Gesten und Tasten, die stehen in `steuerung.md`. Der Klang des Aufstiegs und der Ebenen steht in `specs\wwww-rnbo\aufstieg.md`. Die Schnitte stehen in `specs\wwww-installation\schnitte.md`.

**Verwandt:** `handoffs\2026-11-05-wwww-ideen-moeglichkeiten.md` (alle Möglichkeiten, aus denen hier gewählt ist), `specs\wwww-main\originale.md` (warum die Scans unberührt bleiben), `verraeumlichung.md` (Splats), `specs\wwww-main\konzept.md` (das Kaleidoskop).

---

## Der Raum

Ein Raum ohne Boden. **Seine Farbe ist ein Verlauf, unten weiß, oben schwarz.** Der Aufstieg führt ins Dunkle.

- Der Schnatz ist überall sichtbar, denn hinter ihm liegt nie dieselbe Farbe wie in seinem Spiegelbild.
- Die Höhe ist an der Helligkeit ablesbar.
- Licht von unten wird nach oben sichtbarer statt schwächer. „Nach oben immer transparenter“ braucht deshalb einen eigenen Regler, siehe „Die Ebenen“.

## Der Schnatz

Eine spiegelnde Kugel, die schnell durch die ganze Welt fliegt und klingt, wenn man sie trifft.

| Teil | Festgelegt |
|---|---|
| **Bahn** | Eine geschlossene Kurve durch die 12 Punkte. Wo er ist, hängt nur von der Uhrzeit ab, also sehen ihn alle Handys am selben Ort. |
| **Bewegung** | Sprünge mit kurzem Verweilen. Nur im Flug zwischen zwei Halten weicht er aus, wenn man nah kommt, und nur auf dem eigenen Handy, als kleiner Versatz von der gemeinsamen Kurve. Beim Verweilen lässt er Nähe zu. |
| **Spiegel** | Bei jedem Halt nimmt eine Kamera an seinem Ort ein Rundumbild von etwa 128 px auf. Im Flug bleibt es stehen. **Der Spiegel zeigt keinen Nebel**: Der Schnatz zeigt die fernen Arbeiten klar, die man selbst nur verschleiert sieht. |
| **Treffer** | Ein Tap zählt bis etwa 44 px neben ihm, jederzeit, auch im Flug. Am PC: Klick auf die Bildmitte oder `T`, in Version 2 trifft `T` ohne Zielen. Die Einzelheiten stehen in `steuerung.md`. |
| **Bewegung reduzieren** | Er fliegt langsamer und verweilt länger. |

**Liegt er vor einer Arbeit, löst ein Tap beides aus:** Der Schnatz klingt, und das Schild der Arbeit öffnet sich. Original und Spiegelbild stehen einen Moment nebeneinander. Drei Regeln gehören dazu:

1. Solange ein Schild offen ist, schließt ein Tap nur das Schild.
2. Beim Abdunkeln der Szene bleibt der Schnatz hell.
3. Verdeckt eine Arbeit den Schnatz, zählt er nicht.

### Sein Klang

**Gesungene Körner schlagen eine Metallkugel an.** Die Stimme klingt durch den Körper der Kugel. Das nimmt den Satz aus `konzept.md` auf: „Das Gedicht klingt in einem fremden Körper.“

| Teil | Wie |
|---|---|
| **Die Kugel** | einige Resonanzfilter wie eine angeschlagene Metallkugel (Modalsynthese), mit unregelmäßigen Obertönen |
| **Die Körner** | Silben aus den OpenUtau-Samples des Hefts, als Granularsynthese. Beim Treffer setzt eine dichte Wolke ein, die im Ausklang dünner wird. |
| **Der Korpus** | nach dem Prinzip von FluCoMa, „Building a 2D Corpus Explorer (Part 5)“, Patch `plotter-5.maxpat`: alle Samples verbinden, an den Einsätzen in Scheiben schneiden, jede Scheibe nach Klangfarbe beschreiben (MFCC), mit UMAP auf eine Karte mit zwei Achsen legen. Die Karte wird einmal in Max gerechnet und als kleine Datei exportiert, pro Scheibe zwei Koordinaten, Anfang und Ende. Die nächsten Nachbarn sucht das Handy in JS selbst. |
| **Gefärbt vom Ort** | Jede Scheibe merkt sich ihren Text. Im Feld eines Tierkreiszeichens klingen nur Silben aus dessen Gedicht, die Lage im Feld wählt den Punkt auf der Karte. Im Zwischenraum gilt die ganze Karte. Die Wolke sind die 5 bis 10 nächsten Nachbarn, leicht versetzt. |
| **Doppler im Ausklang** | Man trifft ihn meist im Verweilen, der Anschlag klingt also gerade. Springt er weiter, fällt der Ton, über die Abspielgeschwindigkeit der Körner und die Tonhöhe der Resonanzen. |

**Gebaut in zwei Stufen.** Zuerst die Kugel allein, sie geht ohne Samples. Die OpenUtau-Samples gibt es noch nicht, denn die Gedichte des Hefts fehlen noch. Sobald sie da sind, schlagen ihre Körner die Kugel an. Die Karte lässt sich vorher mit Test-Samples bauen.

**Er klingt im RNBO-Patch auf dem Handy**, zusammen mit den Feldern und dem Allpass-Netz der Ebenen (Nutzer, 2026-11-12, `specs\wwww-rnbo\aufstieg.md`).

## Der Nebel

**Um jede Arbeit liegt eine Kugel aus klarer Luft.** Der Nebel liegt fest im Raum zwischen den Arbeiten und hängt nicht am Spieler.

```
Nebel = Dichte · (Blickstrecke − Strecke in klaren Kugeln)
```

Es reichen die zwei oder drei nächsten Arbeiten. Radius, Dichte und Weichheit des Rands sind Werte pro Arbeit und werden beim Bauen festgelegt.

**Die Farbe des Nebels ist die des Verlaufs** in der jeweiligen Höhe. Ferne Dinge lösen sich in den Raum auf, unten ins Weiß, oben ins Schwarz. Spiegel zeigen keinen Nebel, weder der Schnatz noch der Spiegel am Grund.

## Das Kaleidoskop

**Nur die fernen Arbeiten falten sich, jede um ihren eigenen Mittelpunkt.** Sechs Stücke zu je 60°, abwechselnd gespiegelt. In der klaren Kugel einer Arbeit ist nichts gefaltet, mit dem Abstand von ihrem Rand wird die Faltung stärker. Beim Ankommen laufen die Kopien zu einer Arbeit zusammen.

- Der Verlauf, der Schnatz und die Arbeit, bei der man ist, bleiben heil. Oben bleibt überall oben.
- Gefaltet wird im eigenen Bild der Arbeit, nicht über den ganzen Bildschirm. Das ist billiger, und ein Tap auf eine Kopie trifft die Arbeit von selbst.
- Die Faltung wächst langsam, Blitze entstehen also nicht. Bei „Bewegung reduzieren“ fällt sie schwächer aus.

Damit hat die Stufe „Kaleidoskop“ aus `konzept.md` einen ersten Ort.

## Die Mikroräume

`wwww-threejs-schichten` wird den Großteil der Zeit so gezeigt, wie es ist. Erst ganz nah kann man in eine Arbeit hinein.

| Teil | Festgelegt |
|---|---|
| **Ab wann** | Sobald das Raster erschöpft ist: Ein Pixel des Scans ist auf dem Bildschirm so groß wie ein Pixel des Bildschirms oder größer. Mit Puffer an der Grenze wie bei den Feldern. |
| **Öffnen** | Durch Hineinfliegen, also Weiterfliegen mit „Halten“. Am PC öffnet `M` den nächsten Raum ohne Zielen. |
| **Hinweis** | Keiner. Die Arbeit bleibt, wie sie ist, man findet die Räume durch Zufall. |
| **Lage** | Die tiefsten Stellen, die Depth Anything im Scan findet. Das Modell liegt schon in `zaehlen\modelle\Depth-Anything-V2-Large\`, es braucht einen Lauf pro Arbeit. Es schätzt, wie tief ein Bild wirkt, nicht wie tief das Papier ist. |
| **Inhalt** | Pro Arbeit gewählt aus: die eigenen Ebenen, ein Makrofoto des Blatts, Arbeiten anderer Mitwirkender, Gestein aus dem Granit-Atlas, eine generierte Welt, nur Licht und Klang. Ein vergrößerter Ausschnitt des Scans scheidet aus, denn am Rasterpunkt zeigt er nichts Neues mehr. |
| **Verfahren** | Eine kleine echte Szene hinter einem Portal, sichtbar nur durch den Umriss der Stelle. Jeder Raum bekommt eigene Maße, die Fluchtlinien mehrerer Räume passen absichtlich nicht zusammen. |
| **Wie tief** | Einmal hinein. Ein Raum im Raum bräuchte eine Welt, die um den Spieler skaliert. |
| **Schließen und zurück** | Zurückfliegen durch den Umriss, am PC ein zweites `M`. Die Öffnung bleibt sichtbar, solange man am Rasterpunkt ist, danach schließt sie sich. |
| **Klang drinnen** | Frühe Reflexionen nach den Maßen des Raums, die Hörweite wird eng. |

Ein Tap im Raum zeigt das Schild seines Inhalts. Ein Tap auf die Arbeit schließt eine sichtbare Öffnung, denn er zeigt den Scan. Neues Bildmaterial braucht eine Zeile auf dem Schild und, wenn es Kunst zeigt, eine Bildbeschreibung (`originale.md`).

## Die Ebenen

Aus der Liste des Nutzers vom 2026-11-05: „Bewegung des Aufsteigens, in dessen Ebenen sich auch nochmal der Ton ändert (nested-feedback-feedforward-allpass-network). Auf den Ebenen kein Ton, dazwischen Ton. Ebenen sind Projektionen gebrochenen Lichts / oder Lichtpunkt in der Mitte des Raums von unter den Arbeiten, nach oben hin immer transparenter. Ebenen sind double curved.“

### Was eine Ebene ist

| Schicht | Die Ebene ist … |
|---|---|
| **Bild** | ein Schirm, auf dem die Arbeiten darunter als Licht erscheinen |
| **Klang** | der Ort, an dem das Allpass-Netz im Gleichgewicht ist: kein Ton auf der Ebene, ein Ton dazwischen. Ausgearbeitet in `specs\wwww-rnbo\aufstieg.md`. |
| **Form** | eine Fadenschicht, die sich wölben und teilen kann |

**Teilt sich eine Ebene, öffnet sich in der Mitte ein Spalt.** Durch ihn kann man aufsteigen. Im Bild erscheint das Abbild der Arbeiten doppelt, die Dopplung aus `konzept.md`. Im Klang entsteht mitten in der Ebene ein neues „Dazwischen“: eine Ebene in der Ebene, so wie das Allpass-Netz verschachtelt ist.

### Die Form

**Eine halbierte Lemniskatenfläche, um 90° in die Waagrechte gelegt** (Nutzer, 2026-11-10). Gebaut wie George Adams' Fadenmodelle:

1. Dieselbe Figur liegt auf einem hinteren und einem vorderen Brett, beide senkrecht.
2. Die Bretter sind um ±α gegeneinander gedreht.
3. Gerade Fäden laufen waagrecht von jedem Punkt hinten zum selben Punkt vorn.

Die Figur ist die obere Hälfte einer Cassinischen Kurve, also aller Punkte, deren Abstände zu zwei Brennpunkten dasselbe Produkt ergeben. Bei einem bestimmten Wert ist sie die Lemniskate. Weil die Bretter gedreht sind, laufen die geraden Fäden schräg aneinander vorbei, und die Fläche krümmt sich in zwei Richtungen.

| Regler | Was er ändert |
|---|---|
| **Wölbung** | wie hoch die Figur ist. Bei 0 liegt sie flach. |
| **Drehung** | der Winkel α zwischen den Brettern |
| **Figur** | über 1 ein Gewölbe, bei 1 die halbe Lemniskate mit zwei Gewölben, die sich berühren, unter 1 zwei getrennte Gewölbe mit Spalt |
| **Fäden** | wie dicht die Schicht ist. Genug Fäden liest das Auge als geschlossene, glatte Fläche. |

| Wölbung | Drehung | Ergebnis |
|---|---|---|
| 0 | 0 | eine ganz flache Ebene |
| 0 | über 0 | ein Fadensattel |
| über 0 | beliebig | Gewölbe, je nach Figur eines, zwei sich berührende oder zwei mit Spalt |

Die Skizze vom 2026-11-10 hat gezeigt: Bei Wölbung 0 und Drehung 0 liegen alle Fäden genau in einer Ebene.

**Nach oben weniger Fäden und schwächeres Licht.** So wird jede Ebene durchsichtiger und ihr Abbild brüchiger. Das ist der eigene Regler, den der schwarze Raum oben braucht.

### Das Licht

| Punkt | Festgelegt |
|---|---|
| **Wo die Arbeiten sitzen** | alle auf einer Höhe, unter der ersten Ebene, gerade, so wie sie sind. Darüber liegen drei Ebenen (Nutzer, 2026-11-11, `aufstieg.md`). |
| **Lichtquelle** | ein Lichtpunkt in der Mitte, unter allen Arbeiten. Er wirft jede Arbeit schräg nach außen und oben, wie eine Laterna magica. |
| **Was eine Ebene zeigt** | alle Arbeiten, denn alle stehen unter ihr. Je höher die Ebene, desto blasser. Die oberste trägt eine schwache Spur der ganzen Ausstellung. |
| **Wie gerechnet** | Für jeden Punkt eines Fadens läuft ein Strahl vom Lichtpunkt bis zur Arbeit, dort wird die Farbe abgelesen. Das folgt jedem Morph sofort. Echter Schattenwurf wäre auf dem Handy vermutlich zu teuer. |
| **Brechung** | durch die Wölbung, dazu ein Farbsaum: Rot, Grün und Blau leicht gegeneinander versetzt. Der Saum wächst mit der Wölbung. Eine flache Ebene zeigt die Arbeiten sauber, eine gewölbte bricht ihr Licht in Regenbogenfarben. |

Auf Fäden geworfen erscheint ein Bild in Streifen, und zwischen den Fäden sieht man hindurch. Brechung und Durchsicht kommen also aus demselben Material. Der Schichten-Prototyp kann das Prinzip im Kleinen schon: `?mode=leuchttisch` mit Schattenwurf macht jede Folie zum Farbfilter für Licht von hinten.

## Ganz unten

**Ein runder Spiegel ohne Rahmen, der sich wie ein Kreisel dreht und dabei kippelt.**

Kugelbad mit Brandung sowie Spiegel und Splatter aus der Liste vom 2026-11-05 fallen weg, es bleibt der Kreiselspiegel (Nutzer, 2026-11-13).

- Zu sehen ist nur das Kippeln: Der Rand wandert, und die gespiegelte Welt schwankt doppelt so stark, wie der Spiegel kippt. Ein runder, glatter Spiegel, der sich um sich selbst dreht, sieht aus wie ein stehender. Das Drehen kostet deshalb keine Rechnung.
- Etwa 3° Kippung, die Kippachse kreist etwa einmal in 30 Sekunden. Bei „Bewegung reduzieren“ kippelt er nicht.
- Er spiegelt den Raum darüber, der oben schwarz wird. Im weißen Grund liegt also eine dunkle Fläche, in der die Welt kopfüber steht.
- Die Szene wird für ihn ein zweites Mal gezeichnet, auf dem Handy in halber Auflösung, ohne Nebel.

## Das Bewegungsbild

Aus der Liste des Nutzers: „aliasing on moving“, mit dem three.js-Beispiel `webgl_materials_alphahash`. Es passt zu „Im Stillhalten erkennt man sich“ aus `konzept.md`.

| Punkt | Festgelegt |
|---|---|
| **Verfahren** | Im Flug keine Glättung an den Fäden: Sie flimmern und bilden Moiré. Im Stillstand sammelt das Handy mehrere leicht versetzte Bilder und mittelt sie, die Fäden werden ruhig und glatt. Ist das Bild fertig, rechnet das Handy fast nichts mehr. |
| **Worauf** | auf alles außer den Originalscans: Fäden, Spiegel, Schnatz und alle Erweiterungen der Scans, im Schichten-Prototyp also auf die auseinandergezogenen Ebenen und den Leuchttisch, dazu die Mikroräume und die gefalteten Kopien. |
| **Regel** | Je weiter eine Erweiterung vom Scan abweicht, desto stärker wirkt das Bewegungsbild. Bei `gap=0` ergeben die Ebenen den Scan, dort wirkt es nicht. |
| **Wovon es abhängt** | von der Fluggeschwindigkeit. Kleine Bewegungen zählen als Stillstand, denn ein Handy in der Hand zittert immer. |
| **Wie gerechnet** | zwei getrennte Bilder, eins für die Scans, eins für alles andere, mit gemeinsamer Tiefe |
| **Grenze** | höchstens drei Blitze pro Sekunde (`steuerung.md`). Ob Flimmern darunter fällt, zeigt erst ein echtes Handy. |

## Der Schleier

Vom Nutzer am 2026-11-26: „wie beim bewegen das aliasing kommt, ist es beim stillhalten diese schwarz weiß trennung.“ **Der Schleier ist das Gegenstück zum Bewegungsbild.** Er steht senkrecht zum Verlauf des Raums. Der Raum geht von unten nach oben, der Schleier von links nach rechts.

| Punkt | Festgelegt |
|---|---|
| **Form** | Ein konischer Verlauf um den Blickmittelpunkt, über das ganze Bild. Vom Blickmittelpunkt geht eine harte Kante senkrecht nach oben, links davon Schwarz, rechts Weiß. Von der Kante aus läuft der Verlauf im Kreis: einmal ganz herum (A) oder nur über die untere Hälfte (B). Die Ränder laufen in den Nebel. |
| **Wachsen** | Er wächst beim Stillhalten, sehr langsam. Er beginnt als A und wird zu B, das Grau zieht sich also aus der oberen Hälfte zurück. Was als Stillhalten zählt, regelt das Bewegungsbild. |
| **Kleben** | Fliegt man los, kommt er am Blick mit. Er löst sich, sobald man wegschaut. Wie weit man dafür den Blick drehen muss, wird beim Bauen festgelegt. |
| **Danach** | Er bleibt an der Stelle, an der man still gehalten hat, und zeigt in die Richtung, in die man geschaut hat. Man kann sich umdrehen und ihn ansehen. Ab einem Abstand, der beim Bauen festgelegt wird, ist er ganz vergangen. |
| **Nur einer** | Solange er nicht ganz vergangen ist, entsteht kein neuer. |
| **Scans und Schnatz** | Sie liegen über dem Schleier, die Arbeiten stehen also scharf darin, wie ausgeschnitten. Der Schleier kommt nur auf das Bild für alles andere, das für das Bewegungsbild ohnehin getrennt gerechnet wird. |
| **Bewegung reduzieren** | Er klebt nicht, sondern bleibt beim Losfliegen sofort stehen (Vorschlag von Claude). |
| **Rechnen** | Ausgewachsen ist er, wenn er ganz B ist. Bis dahin reichen vermutlich wenige Bilder pro Sekunde, denn er wächst sehr langsam. Danach steht das Bild, und das Handy hört wie bisher auf zu rechnen (Vorschlag von Claude). |

## Der Renderer

**Das aktuelle three mit `WebGLRenderer`.**

- Nichts in dieser Welt braucht WebGPU. Compute-Shader waren nur für ein Kugelbad gedacht, und das ist durch den Spiegel ersetzt.
- Die Shader bleiben GLSL, der Schichten-Prototyp hat seine schon so.
- Spark passt, denn es verlangt three ab Version 0.180. Splats erscheinen nur als möglicher Inhalt eines Mikroraums.
- Jedes Handy läuft auf demselben Weg. WebGPU gibt es laut den Quellen vom 2026-11-05 erst ab iOS 26 und nicht auf allen Android-Geräten.

**Was auf dem Handy spart**, egal welcher Renderer:

| Hebel | Was er spart |
|---|---|
| Auflösung höchstens das Zweifache der Bildschirmpunkte | `site\probe.html` macht das schon |
| im Stillstand aufhören zu rechnen, sobald das Bild klar ist | Akku, Wärme, und Rechenzeit für RNBO |
| der Spiegel am Grund in halber Auflösung | ein Viertel der Pixel des zweiten Durchgangs |
| der Spiegel des Schnatzes nur bei jedem Halt | sechs Aufnahmen ab und zu statt laufend |

`zaehlen\wwww\site\vendor\three\` hält noch r160. Das Update ist ein Download, seine Größe wird vorher gemessen.

## Was offen ist

- **Für die Installation:** was der Bildschirm V4 vom Schnatz und von den Mikroräumen zeigt, und welche Schnitte zu Schnatz, Ebene und Mikroraum gehören (`schnitte.md`).
- **Später vielleicht:** ein farbiger Hof um jede Arbeit, in ihrer Hauptfarbe. Als Hinweis auf Mikroräume ein leiser Ton im Wind beim Vorbeifliegen (Helmholtz-Resonanz) oder frühe Reflexionen nahe der Stelle. Die stehende Lemniskatenfläche als Schacht des Aufstiegs.
- **Vorerst nicht ausprobieren:** der Friedhof der Formen im Nebel, der zähe Zwischenraum.
- **Erst ein Lauf zeigt:** ob die tiefsten Stellen der Tiefenkarte sinnvolle Räume sind, ob das Flimmern unter die Blitz-Grenze fällt.
- **Die OpenUtau-Samples** gibt es noch nicht.

## Quellen

| Quelle | Stelle | Wofür |
|---|---|---|
| George Adams, *Lemniskatische Regelflächen*, `zaehlen\quellen\scans\mathe\` | Anhang I, Abschnitte 2.1 bis 2.8 | Fadenmodelle zwischen zwei gedrehten Brettern, die Lemniskatenfläche und ihre Gleichung, der Drehteller |
| Rudolf Steiner, GA 323 | 9. Vortrag, 9. Januar 1921 | die vier Formen der Cassinischen Kurve |
| Rudolf Steiner, GA 323 | 17. Vortrag, 17. Januar 1921, PDF-Seite 302 | die Lemniskate „nicht auf der Ebene, sondern im Raum zu denken“ |
| Rudolf Steiner, GA 324a | PDF-Seite 153 f. | zwei Paraboloide, Spitze an Spitze. Gelesen, nicht übernommen. |
| Olive Whicher, *Projektive Geometrie* | Abschnitt zu den Regelflächen | Hyperboloid und Sattel aus zwei Scharen gerader Linien |
| Christian Ostheimer, Renatus Ziegler, *Skalen und Wegkurven* | Figur 53, wirbelartige Wegkurven | für den Grund erwogen, nicht übernommen |
| FluCoMa, „Building a 2D Corpus Explorer (Part 5)“ | `learn.flucoma.org/examples/2d-plot/plotter-5.maxpat` | der Korpus des Schnatzes |
| three.js, `webgl_materials_alphahash` | Quelltext des Beispiels | das Bewegungsbild |
