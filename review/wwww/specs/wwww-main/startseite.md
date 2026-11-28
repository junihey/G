---
tags: [spec, wwww-main, startseite, prod]
created: 2026-11-12
topic: 'Die Startseite auf Prod -- drei gezeichnete Symbole unter schraffierten Ringen, Tipp und Wischen als einzige Gesten, die Ausstellung zieht nach /wwww/'
verification: 'Vom Nutzer am 2026-11-12 Frage fuer Frage entschieden, an einer Skizze (review\skizzen\startseite.html). O und Wurst sind aus seiner Handzeichnung auf die Mittellinie verduennt. Ringe und Feder sind schematisch, die endgueltige Oberflaeche entsteht spaeter, etwa mit ComfyUI. Nichts gebaut. Die Rechtsfragen sind Stellen zum Pruefen, keine Antworten.'
---

# Startseite — drei Türen unter einer schraffierten Fläche

Stand 2026-11-12. **Nichts davon ist gebaut.**

> [!abstract] Drei gezeichnete Türen, und jede Geste hat genau eine Richtung
> Auf `julianniklasheynert.xyz` liegen drei Symbole unter flächigen, schraffierten Ringen, die über den Bildrand hinausgehen. Ein Tipp öffnet eine Tür: O die Ausstellung, die Wurst Portfolio und Discord, das E eine Spalte nach oben und unten. Wischen zur Seite zeigt eine kleine Vorschau der Ausstellung.
>
> ```mermaid
> flowchart TD
>   S["Startseite<br/>O · E · Wurst<br/>zur Seite wischen:<br/>Vorschau"] --> W["Tipp O:<br/>/wwww/"]
>   S --> P["Tipp Wurst:<br/>Portfolio,<br/>Discord"]
>   S --> E["Tipp E:<br/>wächst hoch<br/>und runter"]
>   E --> G["hoch:<br/>Gedichte"]
>   E --> K["runter:<br/>Kontakt,<br/>Buchung, Vita"]
> ```

^blick

**Was hier steht:** wie die Startseite auf Prod aussieht und was jede Geste tut.

**Was hier nicht steht:** der Discord-Teil hinter der Wurst, der steht in `discord.md`. Wie Agenten die Seite lesen, steht in `webmcp.md`. Die Ausstellung selbst steht in `specs\wwww-threejs\`.

**Verwandt:** `archive\handoffs\2026-11-05-wwww-ideen-moeglichkeiten.md`, Abschnitt 14 (alle Möglichkeiten), `review\skizzen\startseite.html` (die Skizze), `review\skizzen\kalligrafie.html` (die Federn), `specs\wwww-main\originale.md` (das Galerie-Schild).

---

## Der Wortlaut

Aus der Liste des Nutzers vom 2026-11-05: „CSS HTML Overlay nicht auf installations Webseite, sondern auf haupt vps seite außerhalb der installation, hier wird der sonne-mond chat ersetzt durch eine einfache navigation zwischen drei symbolen.“ Links ein O mit Strichmensch, in der Mitte ein E, rechts eine „gehirnähnliche Wurst, deren Bögen immer wieder in der Mitte des gegenüberliegenden Bogens enden“. Darüber „verschiedene Kreisringe unterschiedlicher Qualitäten“, beweglich durch Zoom und Swipe, „an den Rändern zeigen sich Vorschau der wwww ausstellung seite“.

## Die Symbole

| Punkt | Festgelegt |
|---|---|
| **O und Wurst** | die Handzeichnung des Nutzers vom 2026-11-12, auf die Mittellinie verdünnt. Zwei kurze Reste in der Wurst sind entfernt. |
| **E** | vorerst von Claude im selben Stil gezogen. Zeichnet der Nutzer ein eigenes, wird es auf demselben Weg übernommen. |
| **Strich** | wie mit dem Kalligrafie-Werkzeug von Inkscape. Die Feder wandert ständig: Jeder ihrer sechs Regler (Breite, Ausdünnung, Masse, Winkel, Fixierung, Zittern) gleitet in 2 bis 6 Sekunden zu einem zufälligen Ziel. Alle drei Symbole teilen sich eine Feder. |
| **Grenzen in Ruhe** | Breite bis 9, Masse bis 0,5, Zittern bis 0,3 (Einheiten einer 100 hohen Zeichnung). So bleiben die Symbole lesbar. |
| **Klar beim Ansprechen** | Zeiger darauf, Tastaturfokus oder Tipp: Das Symbol gleitet in einer Zehntelsekunde zur klaren Feder (Breite 4, sonst alles 0). Nach einem Tipp bleibt es 2,5 Sekunden klar. |
| **Bewegung reduzieren** | Die Feder steht still. |
| **Farbe** | alles weiß auf schwarz, auch das E |

Jedes Symbol ist ein echter Link mit Namen. Sonst findet ein Screenreader oder Agent nichts (`webmcp.md`).

## Die Ringe

**Flächige Ringe, keine Kreise.** Jeder Ring ist eine Fläche zwischen zwei Radien, gefüllt mit einer mikroskopisch dichten Schraffur aus weißen Federzügen. Grau entsteht nur aus der Dichte, und die Dichte ist nicht gleichmäßig. Die Ringe reichen weit über den Bildschirm hinaus.

| Ring, von innen | Schraffur |
|---|---|
| 1 | Kamm: radiale Züge |
| 2 | Maserung: lange Züge entlang des Rings, dichte Flecken |
| 3 | Fischgrät, breite Feder; die Richtung kippt alle zwölftel Umlauf |
| 4 | Kreuzschraffur, nach außen dichter |
| 5 | Strömung: Züge folgen einem gewundenen Feld |
| 6 | Körnung: kurze Züge in zufälliger Richtung |
| 7 | Rhythmus: Bänder aus 1, dann 7, dann 12 Zeilen |

Die Länge der Züge schwankt zwischen dem 0,4- und 2,2-fachen ihres Grundmaßes. **Das ist ein Schema.** Die endgültige Oberfläche entsteht später, etwa mit ComfyUI. Die Ringe drehen sich nicht einzeln, das kostet bei dieser Dichte zu viel Speicher auf dem Handy.

## Die Gesten

| Geste | Was geschieht |
|---|---|
| Tipp auf O | die Ausstellung unter `/wwww/` |
| Tipp auf die Wurst | Portfolio und Discord |
| Tipp auf E | Eine Animation wächst aus dem E nach oben und nach unten. |
| danach wischen nach unten | Kontakt (Linktree, Patreon), Buchung (Bildung: Mathematik, Evaluierung, Programme), Vita (Zusammenarbeiten, Lebenslauf) |
| danach wischen nach oben | einzelne Gedichte |
| wischen nach links oder rechts | die Vorschau der Ausstellung öffnet sich am Rand |
| zoomen, mit zwei Fingern oder dem Mausrad | die ganze Fläche wird größer oder kleiner |

Das E ist kein Hover mehr. Ein Tipp geht am Rechner, am Handy und mit der Tastatur gleich. Die Gedichte des Hefts gibt es noch nicht (`konzept.md`).

## Die Vorschau

**Eine eigene, ganz einfache three.js-Szene**, nicht die Ausstellung. Links ein schwarzer Raum wie auf julianniklasheynert.com, rechts ein weißer Raum wie auf julianniklasheynert.xyz. In beiden hängt die Galerie der Scans, jeder mit Markierung und Galerie-Schild aus `originale.md`. Links und rechts zeigen also beide die Ausstellung, in verschiedenen Ausschnitten.

**Sie lädt erst nach dem ersten Wischen.** Die Startseite selbst lädt ohne three.js, wie `webmcp.md` es verlangt. Die Kamera wandert, damit sich der Loop nie ganz wiederholt.

## Die Trennung von der Installation

| Punkt | Festgelegt |
|---|---|
| **Adresse** | Die Startseite liegt an der Wurzel von `julianniklasheynert.xyz`, die Ausstellung zieht nach `/wwww/`. |
| **Chat und OSC** | ein Schalter in der `.env`. Auf Prod ist er aus: kein Sonne-Mond-Chat, keine Verbindung zum Mac. Die `.env` bleibt so der einzige Unterschied zwischen den Orten (`zaehlen\wwww\ARCHITEKTUR.md`). |
| **Quittungen unter `/q/`** | bleiben auf Prod, auch ohne Chat (`kette-entwurf.md`). |

## Rechtsfragen

Stellen, die jemand mit Rechtskenntnis prüfen soll. Keine Antworten.

| Stelle | Festgelegt |
|---|---|
| **Impressum und Datenschutz** | ein kleiner fester Link in einer Ecke jeder Seite, nicht hinter dem E |
| **Bildung** | geht online |
| **Homöopathische Anamnese** | bleibt verborgen, bis geprüft. Es kann als Ausübung der Heilkunde gelten, mit eigenen Regeln für Werbung. |
| **Hydrolate und Düfte** | bleiben verborgen, bis geprüft. Beim Verkauf kann Kosmetikrecht gelten. |
| **Das Textfeld für Discord** | sagt vor dem Absenden, dass der Text an Discord geht (`discord.md`). |

## Offen

- Was die Portfolio-Seite hinter der Wurst zeigt. Bisher steht sie nur als Ziel da.
- Das eigene E des Nutzers.
- Wie die Animation des E aussieht, wenn sie nach oben und unten wächst.
- Die endgültige Oberfläche der Ringe, etwa mit ComfyUI.
- Wer die Anamnese und die Hydrolate rechtlich prüft.
- Ob „schwarzer Raum wie auf julianniklasheynert.com“ mehr meint als den schwarzen Grund, etwa Schrift oder Anordnung. Claude konnte die Seite nicht ansehen.
