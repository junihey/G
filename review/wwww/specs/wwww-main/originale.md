---
tags: [spec, wwww-main, originale, barrierefreiheit]
created: 2026-09-30
topic: 'Wie ein ursprüngliches Kunstwerk in jedem Teil von wwww erhalten und beschrieben bleibt, und warum'
verification: 'im Gespräch festgelegt am 2026-09-30. Der Abschnitt "Warum das Original trennbar bleibt" ist der Gedanke des Nutzers vom 2026-11-24, im Wortlaut mit Claude abgestimmt und vom Nutzer bestätigt. Die Steiner-Stellen hat Claude im Volltext nachgesehen, das Zitat von Latour und Lowe nur aus der Recherche übernommen.'
---

# Originale — das ursprüngliche Werk bleibt erkennbar

Festgelegt im Gespräch am 2026-09-30, der Grund ergänzt am 2026-11-24. Gilt für jeden Teil von wwww, der ein ursprüngliches Kunstwerk zeigt: gescannt, digitalisiert, digital erweitert.

> [!abstract] Das Original bleibt trennbar, und die Erweiterung bindet an es zurück
> Das Original trägt die Materialität, der Scan die Erscheinung, die Bildbeschreibung das, was nur die Hand am Blatt weiß. Ein Tap blendet die Erweiterung aus und führt zum Original zurück. So zeigt die Erweiterung die Individualität der eigentlichen Arbeit, statt sie durch eine Neuschöpfung zu ersetzen.
>
> ```mermaid
> flowchart TD
>   O["Original<br/>Materialität"] --> S["Scan<br/>Erscheinung"]
>   O --> B["Bildbeschreibung<br/>was die Hand weiß"]
>   S --> E[Erweiterung]
>   B --> G[Galerie-Schild]
>   E -->|Tap| G
>   G -.->|zurück zu| O
> ```

^blick

**Die Regel:** Zeigt ein Werk ein ursprüngliches Kunstwerk, bleibt das Original ein trennbarer Teil des Modells, und die Bildbeschreibung entsteht beim Digitalisieren, vor dem Original.

---

## Woraus gebaut wird

| Quelle | Was übernommen wird |
|---|---|
| Steiner, GA 190, PDF-Seite 77 und 219, in `zaehlen\quellen\scans\steiner-ga\` | das Zeitalter der Bewusstseinsseele als „Zeitalter der bewußten Individualitäten“, in dem die Menschen „immer verschiedener werden müssen“ |
| Steiner, GA 73a, PDF-Seite 275, und GA 4, PDF-Seite 117 | Ideen, „die selbst zu Lebenskräften werden“; ein Ideal, „das Leben hat“ |
| Latour und Lowe, „The Migration of the Aura“, 2010, nach `raw\20261124 bezugspositionen.md` | Eine gute Fassung kann „add new layers of originality to the original“. |

**Was die Vorlagen falsch machten:**

- **Steiner spricht vom Menschen und vom sozialen Leben**, nicht von Kunstwerken. Die Übertragung auf die Fassungen eines Werks ist der Gedanke des Nutzers.
- **Bei Factum Arte ist das Ziel größte Treue, nicht Erweiterung.** Latour und Lowe stützen die Erweiterung nur darin, dass auch sie das Original erhalten lässt.
- **„Ideale sind Urbilder“ steht so in den durchsuchten Bänden nicht.** Am nächsten kommt GA 276, PDF-Seite 129, mit dem „Ideal-Urbild des Menschen“, und dort geht es um Eurythmie.

## Das Original bleibt trennbar

Scan und Erweiterung sind im Modell getrennte Teile, etwa zwei Knoten `original` und `erweiterung` in der glTF-Datei. Das muss schon in Blender feststehen.

Verschmolzen lässt sich die Erweiterung nicht mehr ausblenden. Das Original wäre dann nur noch als Teil des Digitalen zu sehen.

| Wo | Wie das Original zurückkommt |
|---|---|
| `wwww-threejs`, `steuerung.md` | ein Tap auf ein Werk blendet die Erweiterung aus und zeigt das Galerie-Schild |
| `zaehlen\wwww-threejs-schichten\` | die Form-Ebenen zusammengeschoben ergeben exakt den Scan |

**Was nur die Erweiterung trifft.** Das körnige Bewegungsbild aus `specs\wwww-threejs\welt.md` wirkt nie auf einen Scan. Es wächst damit, wie weit eine Erweiterung vom Scan abweicht. Bei zusammengeschobenen Form-Ebenen wirkt es gar nicht, denn sie sind dann der Scan. Festgelegt am 2026-11-10.

## Warum das Original trennbar bleibt

**Neuschöpfung oder Erweiterung.** Eine Neuschöpfung schöpft aus derselben Idee und drückt sie in der Individualität ihres neuen Autors aus. wwww erweitert dagegen die Arbeit selbst. Auf den ersten Blick verhärtet das die Idee, weil sie an ein Werk gebunden bleibt. Aber die Erweiterung führt die Idee weiter und bindet sie an die Arbeit zurück, und dadurch tritt deren Individualität stärker hervor. Jede Fassung wirft neues Licht auf die eigentliche Idee.

**Was der Scan behält.** Der Scan behält die Erscheinung, nicht die Materialität. Die Materialität bleibt im Original. Was nur die Hand am Blatt weiß, trägt die Bildbeschreibung.

## Die Bildbeschreibung entsteht vor dem Original

Die Bildbeschreibung sagt, was man auf dem Werk sieht. Sie ist für Menschen, die es nicht sehen, und trägt die Barrierefreiheit des Werks mehr als jede Taste.

**Sie wird von Hand geschrieben, beim Digitalisieren.** Der Scan zeigt weniger als das Original:

- Glanz, Relief und Papierstruktur gehen verloren.
- Die Farben verschieben sich je nach Scanner.
- Die Größe fehlt, ein Scan ist immer bildschirmgroß.

Ein Beispiel für eine Buntstiftzeichnung:

> Hochformat, etwa DIN A4. Auf weißem Papier drei ineinandergreifende Formen in Blau, Ocker und Rot. Die blaue Form füllt die untere Hälfte, dicht und fest schraffiert. Die rote ist nur umrissen, darin bleibt das Papier frei. Links oben ist der Stift so fest aufgedrückt, dass das Papier glänzt.

Den letzten Satz schreibt nur, wer das Blatt in der Hand hatte. Eine KI, die den Scan liest, sieht den Glanz nicht und weiß nicht, was am Werk wichtig ist.

„Später nachtragen" heißt oft: Das Original ist wieder im Schrank oder verkauft, und was man darüber wusste, ist weg.

## Was beim Digitalisieren mit entsteht

Die Zeilen des Galerie-Schilds aus `specs\wwww-threejs\steuerung.md`:

| Zeile | Beispiel |
|---|---|
| Künstler oder Künstlerin, Lebensdaten | |
| Titel, Jahr | |
| Technik und Material | Buntstift auf Papier |
| Maße | 29,7 × 21 cm |
| Sammlung oder Standort | |
| kurzer Text zum Werk | zwei bis vier Sätze |
| **Bildbeschreibung** | wie oben |
| **Digitale Erweiterung** | was gescannt und was hinzugefügt wurde, wann und womit |

Zeigt ein Mikroraum neues Bildmaterial (`specs\wwww-threejs\welt.md`), etwa ein Makrofoto des Blatts oder die Arbeit eines anderen Mitwirkenden, bekommt es eine Zeile unter „Digitale Erweiterung“. Zeigt es Kunst, braucht es auch eine eigene Bildbeschreibung.

## Wann die Regel weiterwandert

Taucht dieselbe Regel in einem Spec außerhalb von wwww auf, gehört sie in `TENETS.md`. Bis dahin steht sie hier.
