---
tags: [spec, wwww-installation, granit-atlas, jitter, bild-schleife]
created: 2026-10-29
topic: 'Der Granit-Atlas in der Jitter-Projektion -- die Projektion wandert ueber die Kanten des Netzes, und die Art der Kante bestimmt den Uebergang zwischen zwei Fotografien'
verification: 'Ausgangspunkt vom Nutzer im Gespraech am 2026-10-29: der Granit-Atlas als logisches Netz zwischen Fotografien in der Jitter-Projektion, manchmal als Mesh mit Begriffen. Die Wanderung ueber die Kanten am selben Tag vorgeschlagen, vom Nutzer gutgeheissen, nicht festgelegt. Zahlen der Kanten und Fotos aus zaehlen\granit-atlas\daten\graph.json vom 2026-10-29. Nichts gebaut, nichts gesehen.'
---

# Granit-Projektion — die Verwandlung statt der Karte

Stand 2026-10-29. **Nichts davon ist gebaut.**

> [!abstract] Die Projektion zeigt nie das ganze Netz
> Sie wandert über die Kanten des Granit-Atlas, und die Kategorie einer Kante wählt den Übergang zwischen zwei Fotografien. Die Begriffe erscheinen nur unterwegs. Alles ist ein Vorschlag.
>
> ```mermaid
> flowchart LR
>   G[Granit] -->|Bestandteil<br/>zerfällt in Punkte| Q[Quarz]
>   G -->|Verwandtschaft<br/>Nebel| D[Diorit]
>   G -->|Bildungsweg<br/>Linien schieben| U[umgewandeltes Gestein]
>   G -->|Klassifikation<br/>harter Schnitt| P[Plutonit]
> ```

^blick

**Was hier steht:** wie der Granit-Atlas in die Jitter-Projektion der Bild-Schleife kommt.

**Was hier nicht steht:** was im Atlas steht. Das steht in `zaehlen\granit-atlas\README.md` und `recherche\DATENMODELL.md` dort. Die Bausteine für die Tiefe stehen in `zaehlen\max-bausteine\tiefe\README.md`.

**Verwandt:** `kommunikation.md` (die Bild-Schleife), `schnitte.md` (harte Schnitte und ihre Längen), `aufbau.json` (Beamer V1, Projektionsfläche V3).

---

## Vom Nutzer

| Was | Seit |
|---|---|
| Der Granit-Atlas läuft in der Jitter-Projektion über den Beamer, als logisches Netz zwischen den Fotografien. | 2026-10-29 |
| Die Steine sind Begriffe, und die Begriffe sind mit den Fotografien verbunden. Manchmal werden sie als Mesh sichtbar. | 2026-10-29 |

## Vorgeschlagen, nicht festgelegt

### Ein Bild auf einmal

Die Projektion zeigt immer nur eine Fotografie, etwa Granit. Danach folgt sie einer Kante zum nächsten Stein. **Das Netz steckt in der Reihenfolge**, nicht in einer Karte. Der Besucher sieht keine Übersicht über Steine, er sieht die Verwandlung selbst.

### Die Kante ist der Übergang

Jede Kante im Atlas hat eine Kategorie (`relation_category`) und eine genaue Beziehung (`predicate`). Die Kategorie wählt den Übergang:

| Kategorie | Kanten | Beispiel | Übergang | Baustein |
|---|---|---|---|---|
| Bestandteil | 44 | Granit `besteht_aus` Quarz, Feldspat, Glimmer | das Bild zerfällt in Punkte und setzt sich als Bestandteil neu zusammen | Demo `tiefe-punkte`, noch kein Baustein |
| Bildungsweg | 62 | `kann_umgewandelt_werden_zu`, `kann_teilschmelzen_zu`, `kann_kristallisieren_zu` | Umwandeln schiebt die Linien, Schmelzen verschwimmt | `tiefe.linien`, `tiefe.unschaerfe` |
| Verwandtschaft | 26 | Granit `ist_geschwister_von` Diorit | eine Überblendung durch Nebel | `tiefe.nebel` |
| Klassifikation | 46 | Granit `ist_ein` Plutonit | ein harter Schnitt ohne Übergang | – |

Das Bild dazu steht oben im Blick.

**Die Begriffe erscheinen nur unterwegs.** Das Mesh mit den Wörtern taucht während des Übergangs auf und ist weg, sobald die nächste Fotografie steht.

### Hörbar über die Schnitte

`schnitte.md` ordnet jeder Aktion eine Länge des harten Schnitts zu. Dieselbe Leiter könnte die Kategorie einer Kante hörbar machen. Der Klang sagt dann, welche Art Verwandlung gerade läuft.

## Was für den Bau gilt

- **Jede Fotografie braucht eine Depth Map**, hell = nah, so wie die Bausteine in `tiefe` sie erwarten. Sie lässt sich vorab mit Depth Anything rechnen.
- **Die Wanderung läuft nur über Steine mit Foto.** Heute haben 20 der 109 Knoten ein Foto, aus 17 Bilddateien in `medien\`.

## Was offen ist

- Wer die nächste Kante wählt: der Zufall, der Gesteinskreislauf als fester Pfad, oder die Besucher über die Handys.
- Ob die Wanderung die ganze Projektion ist, oder eine Schicht über der Bild-Schleife mit der Kamera.
- Ob 20 Steine mit Foto reichen, oder ob der Atlas mehr Fotografien braucht.
- Ob die Fotos aus Wikimedia Commons bleiben, oder ob eigene Fotografien sie ersetzen.
