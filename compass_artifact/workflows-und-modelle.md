---
tags: [learning, comfyui]
created: 2026-09-14
topic: 'Wie ComfyUI aus Nodes, Modellen und Einstellungen Bilder baut -- Grundgraph, Img2Img, ControlNet, IP-Adapter, LoRA samt Training, Hochrechnen, mehrere Stufen, Mischen, Kacheln, Outpainting, Regionen und Tiefe --, mit dem QR-Code-Monster-Projekt als durchgehendem Beispiel'
verification: 'extern -- ComfyUI gibt es ohne diesen Vault; Werte aus workflows\*.json, versuchsbuch\, referenzen\ und werkzeuge\ von zaehlen\wwww-qr-monster, Stand 2026-09-14; SDXL-Techniken aus zwei Textnotizen vom 2026-05-17; Node-Namen und Eingänge gegen ComfyUI Desktop 0.35.0 und ComfyUI_IPAdapter_plus a0f451a gelesen, CLIP-Vision-Zuordnung gegen dessen README, per Hand'
---

# ComfyUI: Workflows, Modelle, Einstellungen

**Was das ist:** eine Einführung in ComfyUI, die bei einem leeren Graphen anfängt und bei mehrstufigen Workflows mit selbst trainierter LoRA aufhört. Die Werte stammen aus einem Projekt, das scannbare QR-Codes als schraffierte Wesen erzeugt. Es dient als durchgehendes Beispiel, weil es fast jede Stellschraube einmal bewegt hat. Dazu kommen Techniken für SDXL, die über dieses Projekt hinausgehen.

**Wie zu lesen:** von oben nach unten. Jeder Abschnitt benutzt nur, was vor ihm steht. Teil I baut ein Bild, Teil II steuert es, Teil III verkettet mehrere Durchgänge, Teil IV behandelt Muster und Flächen, Teil V die Arbeitsweise. Wo ein Wert *vorgesehen* heißt, ist er empfohlen, aber noch nicht erprobt.

**Was hier nicht steht:** keine Installation der Desktop-App Schritt für Schritt. Keine Preise und keine Download-Seiten im Einzelnen. Nicht, welche Version des Projekts wie oft gescannt wurde — das steht im Versuchsbuch des Projekts. Nicht das Versuchsbuch-Werkzeug selbst. Nicht die elf Motiv-Prompts des Projekts; einer steht als Beispiel in Abschnitt 6.

---

# Teil I · Ein Bild bauen

## 1 · Was ComfyUI ist

ComfyUI ist ein Programm, in dem ein Bild aus **Bausteinen** entsteht, die man mit Kabeln verbindet. Ein Baustein heißt **Node**. Das Ganze heißt **Workflow** oder Graph.

Jeder Node hat Eingänge links und Ausgänge rechts. Ein Kabel trägt immer genau eine Art Daten, und nur gleiche Arten passen zusammen. Die Arten, die hier vorkommen:

| Art | Was durch das Kabel geht |
| --- | --- |
| `MODEL` | das Bildmodell, das rechnet |
| `CLIP` | der Teil des Modells, der Text versteht |
| `VAE` | der Übersetzer zwischen Pixeln und Latent (kommt in Abschnitt 4) |
| `CONDITIONING` | ein übersetzter Prompt, eventuell mit Vorgaben daran |
| `LATENT` | ein Bild in der Rechenform des Modells |
| `IMAGE` | ein normales Pixelbild |
| `MASK` | eine Graustufen-Maske: welche Stellen bearbeitet werden |

Ein Workflow läuft, wenn man ihn in die **Warteschlange** stellt. ComfyUI rechnet nur die Nodes neu, deren Eingänge sich seit dem letzten Lauf geändert haben.

**Ein Workflow wird auf zwei Arten gespeichert.** Das UI-Format enthält auch die Positionen der Nodes auf der Fläche. Das **API-Format** enthält nur Nodes und Werte, jeder Node mit seinem Typnamen — im Code `class_type`, zum Beispiel `KSampler`. Das API-Format ist das, was ein Skript an ComfyUI schickt, und das, was sich in git sauber vergleichen lässt. Zusätzlich trägt jedes gespeicherte PNG seinen Workflow in sich. Zieht man das PNG in ComfyUI, steht der Graph wieder da.

**Zwei Ordner gehören zum Programm.** Der Eingangsordner — in der Desktop-App die Einstellung `inputDir` — ist der einzige Ort, aus dem der Node zum Laden eines Bilds liest. Der Ausgangsordner — `outputDir` — ist der Ort, in den gespeicherte Bilder gehen. Beide stehen in der Desktop-App in `%APPDATA%\Comfy Desktop\settings.json` und `installations.json`. Zeigen sie auf den Projektordner, landet jedes Bild direkt im Projekt, ohne Kopie.

Die Desktop-App lauscht auf Port 8000. Eine von Hand installierte ComfyUI lauscht auf 8188. Anleitungen, die ein Skript an 8188 schicken, brauchen für die Desktop-App die andere Zahl.

## 2 · Wo Modelle und Erweiterungen liegen

Ein **Modell** ist hier eine große Datei mit gelernten Gewichten, meist mit der Endung `.safetensors`. ComfyUI sucht sie in festen Unterordnern von `models\`. Welcher Node welchen Ordner liest, entscheidet, wohin eine Datei gehört. Die Abschnittsnummern in der Tabelle zeigen nach vorn, dorthin, wo die Art erst erklärt wird:

| Ordner | Was hinein gehört | Beispiele aus diesem Text |
| --- | --- | --- |
| `checkpoints\` | Grundmodelle | `DreamShaper_8_pruned`, Juggernaut XL, SDXL Base 1.0 |
| `controlnet\` | ControlNets und Control-LoRAs (Abschnitt 7) | `control_v1p_sd15_qrcode_monster_v2`, `sai_xl_depth_256lora` |
| `ipadapter\` | IP-Adapter-Modelle (Abschnitt 10) | `ip-adapter-plus_sd15` |
| `clip_vision\` | Bildverständnis für den IP-Adapter | `CLIP-ViT-H-14-laion2B-s32B-b79K` |
| `loras\` | LoRAs (Abschnitt 11) | eine selbst trainierte Stil-LoRA |
| `upscale_models\` | Modelle zum Hochrechnen (Abschnitt 13) | `4x-UltraSharp.pth`, `4x_NMKD-Siax_200k.pth` |
| `sams\` | Segment Anything (Abschnitt 18) | `sam_vit_h_4b8939.pth` |
| `diffusers\` | Modelle im Diffusers-Ordnerformat | `marigold-lcm-v1-0` (Abschnitt 19) |

Liegen die Modelle woanders als neben ComfyUI, sagt eine Konfigurationsdatei, wo — `extra_models_config.yaml`, in der Desktop-App zusätzlich eine Datei unter `instance-model-paths\`. Fehlt dieser Eintrag, zeigt jeder Lade-Node eine leere Liste.

**Nodes, die nicht mitgeliefert werden**, heißen **Custom Nodes**. Sie liegen als Ordner in `custom_nodes\`. Man installiert sie über den **ComfyUI-Manager** (im Menü *Manager* → *Install Custom Nodes*, suchen, installieren, *Restart*) oder von Hand mit `git clone <adresse>` in diesem Ordner und einem Neustart. Der Manager selbst ist ebenfalls ein Custom Node; fehlt er, kommt er auf dem zweiten Weg.

Die Pakete, die in diesem Text vorkommen:

| Paket | Liefert |
| --- | --- |
| `ComfyUI_IPAdapter_plus` | IP-Adapter-Nodes |
| `comfyui_controlnet_aux` (im Manager „ControlNet Preprocessors“) | Vorverarbeitung wie Lineart- und Tiefen-Erkennung |
| `ComfyUI-Marigold` | Tiefenkarten aus Fotos |
| `ComfyUI_UltimateSDUpscale` | Hochrechnen in Kacheln |
| `ComfyUI-Impact-Pack`, `ComfyUI-Inspire-Pack` | Masken, Regionen, Hilfs-Nodes |
| `ComfyUI-Segment-Anything` | Formen im Bild automatisch erkennen |

Ein Custom Node mit einer festen git-Version — `git checkout <commit>` — verhält sich morgen wie heute. Ohne sie kann ein Update eine Einstellung umbenennen.

## 3 · Die Modellfamilie

Grundmodelle gehören zu einer **Familie**. Die zwei, die hier vorkommen:

| | SD 1.5 | SDXL |
| --- | --- | --- |
| natürliche Bildgröße | 512–768 px | 1024 px |
| Beispiele | DreamShaper 8 | Juggernaut XL, DreamShaper XL, SDXL Base 1.0, Pony Diffusion V6 |
| Speicherbedarf | klein | groß |

**Jeder Zusatz muss zur Familie des Grundmodells passen** — jedes ControlNet, jeder IP-Adapter, jede LoRA. Eine SD-1.5-LoRA an einem SDXL-Modell tut nichts Brauchbares. Der Dateiname sagt es meist: `sd15` oder `sdxl`, `xl`.

Das ist oft die eigentliche Entscheidung. QR Code Monster v2 gibt es für SD 1.5. Wer es benutzt, arbeitet in SD 1.5, auch wenn SDXL feinere Texturen malt.

## 4 · Der Grundgraph: Text zu Bild

Ein Diffusionsmodell malt nicht direkt Pixel. Es rechnet in einer verkleinerten Form des Bilds, dem **Latent**. Ein 768 × 768-Bild ist dort ein Feld von 96 × 96 Werten mit vier Kanälen. Das Modell beginnt mit Rauschen und entfernt es in vielen Schritten, bis ein Bild übrig ist, das zum Prompt passt.

Sechs Nodes bilden das kleinste vollständige Bild:

1. **Das Grundmodell laden** — `CheckpointLoaderSimple`. Er gibt drei Kabel aus: `MODEL`, `CLIP` und `VAE`.
2. **Den Prompt übersetzen** — `CLIPTextEncode`, zweimal. Einer bekommt den positiven Prompt, einer den negativen. Beide nehmen `CLIP` vom Checkpoint.
3. **Die leere Fläche anlegen** — `EmptyLatentImage` mit `width`, `height` und `batch_size`. `batch_size` 4 heißt: vier Bilder in einem Lauf.
4. **Rechnen** — `KSampler`. Er nimmt `MODEL`, beide Prompts und das Latent.
5. **Zurückübersetzen** — `VAEDecode` macht aus dem Latent Pixel, mit dem `VAE` vom Checkpoint.
6. **Speichern** — `SaveImage`. Sein `filename_prefix` darf einen Unterordner enthalten: `monster/gnom_v25` legt das Bild in `ausgaben\monster\` ab.

Die Einstellungen des `KSampler`:

| Einstellung | Was sie tut | Wert im Projekt |
| --- | --- | --- |
| `seed` | Startwert des Rauschens. Gleicher Seed, gleiche Einstellungen, gleiches Bild. | fest pro Reihe, z. B. 424242 |
| `steps` | Zahl der Rechenschritte | 30 |
| `cfg` | wie streng der Prompt befolgt wird. Höher = wörtlicher, aber härter. | 7 |
| `sampler_name` | das Rechenverfahren pro Schritt | `dpmpp_2m` |
| `scheduler` | wie die Schritte über das Rauschen verteilt sind | `karras` |
| `denoise` | wie viel neu gemalt wird (kommt gleich in Abschnitt 5) | 1,0 bei leerer Fläche |

Übliche Spannen für diese Art Bild sind 30–50 Schritte, CFG 7–9 und als zweites Verfahren `euler_ancestral`. Mehr Schritte machen ein Bild selten besser, nur langsamer.

Das Projekt rechnet in 768 × 768 mit DreamShaper 8. Das ist für SD 1.5 schon groß und gibt einem QR-Code genug Pixel pro Feld; warum das zählt, kommt in Abschnitt 8.

## 5 · Img2Img und `denoise`

Statt mit Rauschen kann der `KSampler` mit einem **fertigen Bild** anfangen. Das heißt Img2Img. Der Graph ändert sich an einer Stelle: statt `EmptyLatentImage` kommt

- `LoadImage` — lädt ein Bild aus dem Eingangsordner,
- `VAEEncode` — übersetzt es mit dem `VAE` des Checkpoints ins Latent,
- optional `RepeatLatentBatch` mit `amount` 2 oder 3, damit aus einem Startbild mehrere Varianten mit verschiedenem Rauschen entstehen.

Das Latent geht in den Eingang `latent_image` des `KSampler`. Jetzt entscheidet **`denoise`**, wie viel vom Startbild bleibt:

| `denoise` | Was passiert |
| --- | --- |
| 0,25 | Nur feine Details ändern sich. Nachschärfen. |
| 0,3–0,5 | Oberfläche und Strich ändern sich, Aufbau bleibt. |
| 0,55 | Guter erster Wert, um eine Zeichnung „weiterwachsen“ zu lassen. |
| 0,7–0,8 | Aufbau wird umgebaut, Gestalt bleibt erkennbar. |
| 0,9 | Fast neu, das Startbild ist nur noch eine Ahnung. |
| 1,0 | Alles neu, das Startbild ist egal. |

**Die Lehre dazu:** Ein zu niedriger Wert kann eine neue Struktur nicht hineinbringen. Soll ein fertiges Bild zusätzlich ein Muster tragen, reicht 0,3–0,55 nicht, egal wie stark die Vorgabe ist — das Bild bleibt, wie es war. Zwischen 0,7 und 0,8 liegt das Fenster, in dem Gestalt bleibt und Neues trotzdem hineinkommt. Oben kippt es: bei 0,8 erfindet das Modell schon eigene Gesichter.

## 6 · Prompts

Der positive Prompt sagt, was im Bild sein soll, der negative, was nicht. Beide sind kommagetrennte Begriffe auf Englisch.

**Ein Stil wird ein festes Anhängsel.** Soll eine Serie gleich aussehen, hängt an jedes Motiv derselbe Stil-Text, **wortgleich**. Jede Umformulierung verschiebt den Stil. Das Stil-Anhängsel des Projekts:

```
single subject centered, empty background, consistent lighting series,
full-figure creature study, sculptural carved volumes,
dense pen-and-ink cross-hatching, engraved parallel line shading, stippling,
scratchboard woodcut illustration, 1920s expressionist occult plate,
stark chiaroscuro, large connected black masses against bare white paper,
pure black and white, no color, crisp fine linework, high contrast
```

Ein Motiv davor, als Beispiel:

```
small gnarled earth-being with an oversized luminous head, crouched among tangled tree roots
underground, skin like weathered ore and mica flaking in plates, countless tiny watchful eyes
scattered over the whole body, sharp mocking intelligent expression, ...
```

**Der negative Prompt hat zwei Teile.** Ein fester Teil gegen den falschen Stil (`color, photorealistic, 3d render, smooth gradients, blurry, text, watermark, cute, anime, cel shading, ...`). Und ein wachsender Teil gegen das, was in dieser Serie immer wieder ungewollt auftaucht. Im Projekt waren das Menschen und Säulenformen: `human, humanoid face, tree stump, trunk, pillar, tower, column, window`. Wer ein ungewolltes Objekt zweimal sieht, schreibt es hinein.

Weitere Regeln für eine Serie: ein fester Seed-Block (etwa 1000–1010 für elf Motive), gleiche Bildgröße, gleicher Sampler. Wird ein Motiv zu flach, rückt `sculptural carved volumes` nach vorn — was vorn steht, wiegt mehr.

---

# Teil II · Das Bild steuern

## 7 · ControlNet

Ein Prompt beschreibt, *was* im Bild ist, aber nicht *wo*. Ein **ControlNet** gibt dem Modell zusätzlich ein **Steuerbild**, dessen Aufbau es übernimmt: Kanten, Linien, Tiefe oder ein Hell-Dunkel-Muster. Es ist ein eigenes Modell, das zur Familie passen muss (Abschnitt 3).

Zwei Nodes gehören dazu:

- `ControlNetLoader` lädt das Modell aus `models\controlnet\`.
- `ControlNetApplyAdvanced` wendet es an. Eingänge: `positive`, `negative`, `control_net`, `image`. Ausgänge: `positive` und `negative`, jetzt mit der Vorgabe daran.

**Das ControlNet hängt am Prompt, nicht am Modell.** Das Kabel geht vom `CLIPTextEncode` durch `ControlNetApplyAdvanced` in den `KSampler`. Das `MODEL` geht daran vorbei direkt in den `KSampler`. Mehrere ControlNets schaltet man in Reihe, indem `positive` und `negative` des ersten in das zweite gehen. Anleitungen, die das `MODEL` durch die ControlNets führen, verwechseln die beiden Kabel.

Drei Regler hat jede Anwendung:

| Regler | Was er tut |
| --- | --- |
| `strength` | wie stark das Steuerbild erzwungen wird. 1,0 ist normal, darüber drückt es. |
| `start_percent` | ab welchem Anteil der Schritte es wirkt. 0,0 = von Anfang an. |
| `end_percent` | bis zu welchem Anteil es wirkt. 1,0 = bis zum letzten Schritt. Danach malt das Modell frei. |

**Früh legt der Aufbau sich fest, spät die Details.** Ein ControlNet, das bei 0,3 aufhört, bestimmt die grobe Form und lässt die Oberfläche frei. Eines, das bis 1,0 läuft, bestimmt auch den letzten Strich.

Manche Steuerbilder muss man erst herstellen. Das macht ein **Preprocessor**. Kanten erzeugt der mitgelieferte Node `Canny` mit `low_threshold` und `high_threshold` — im Projekt 0,3 und 0,7. Lineart- und Tiefen-Preprocessoren kommen aus `comfyui_controlnet_aux`.

Die Arten von ControlNet, die hier vorkommen:

| Art | Steuerbild | Wofür |
| --- | --- | --- |
| QR Code Monster | Hell-Dunkel-Muster | ein Muster im Bild verstecken (kommt in Abschnitt 8) |
| Canny | harte Kanten aus einem Bild | Umrisse eines Vorbilds übernehmen |
| Scribble | grobe Striche | eine Skizze als Formvorgabe |
| Lineart | saubere Konturen | Linien einer Zeichnung genau halten |
| Depth | Graustufen-Tiefenkarte | Relief und Raum (kommt in Abschnitt 19) |
| Inpaint | Bild mit Lücke | eine Lücke passend zum Rest füllen |
| Tile | das Bild selbst | beim Hochrechnen Aufbau halten (kommt in Abschnitt 13) |

Eine **Control-LoRA** ist ein verkleinertes ControlNet von Stability AI, zum Beispiel `sai_xl_depth_256lora.safetensors`. Trotz des Namens ist sie keine LoRA im Sinn des späteren Abschnitts 11. Sie liegt in `models\controlnet\` und lädt über `ControlNetLoader`.

## 8 · QR Code Monster und wie ein Scanner liest

**QR Code Monster** — im Code `control_v1p_sd15_qrcode_monster_v2` — ist ein ControlNet, das ein Schwarz-Weiß-Muster so ins Bild legt, dass das Motiv es trägt. Dunkle Stellen des Musters werden dunkle Stellen im Bild, helle werden hell. Ist das Muster ein QR-Code, bleibt das Bild scannbar.

Um es einzustellen, muss man wissen, woran ein Scanner einen Code erkennt:

- **Felder** — die kleinen Quadrate des Codes. Jedes ist hell oder dunkel.
- **Ecken-Quadrate** — die drei großen Quadrate mit Ring und Kern oben links, oben rechts und unten links. An ihnen *findet* der Scanner den Code. Ist eines zerstört, liest er nichts, auch wenn alle Felder stimmen. Ab einer gewissen Größe kommt ein kleines Quadrat unten rechts dazu.
- **Ruhezone** — ein heller Rand um den Code, üblich vier Felder breit. Ohne ihn findet der Scanner den Anfang nicht.
- **Fehlerkorrektur** — ein Teil der Felder ist Reserve. Stufe H verträgt etwa 30 % falsche Felder. Für ein Bild, das Felder verfälscht, ist H Pflicht.
- **Version** — die Größe des Codes in Feldern. Eine kurze Adresse ergibt eine niedrige Version und damit große Felder. `HTTPS://W/A` in Großbuchstaben ergibt Version 2 mit 25 × 25 Feldern; Großbuchstaben passen in einen sparsameren Zeichenmodus.
- **Pixel pro Feld** — mindestens 12. Bei 768 px und 25 Feldern plus Ruhezone sind es etwa 23.

**Die Vorlage** baut man mit der Python-Bibliothek `qrcode`: `ERROR_CORRECT_H`, `border` 4, dann mit `NEAREST` auf 768 px vergrößern, damit die Kanten hart bleiben. Das Projekt tut das mit `werkzeuge/qr_vorlage.py`, das den fertigen Code zur Kontrolle gleich mit `zxing-cpp` liest. Zwei Varianten davon:

- **Code klein, Rest grau** (`--feld 16 --umgebung "#808080"`): der Code sitzt mittig mit fester Feldgröße, der Rand ist neutral grau. So empfiehlt es die Modellseite. Grau heißt für das ControlNet „hier frei“, das Motiv darf dort machen, was es will.
- **Weiche Graustufen** (`--dunkel "#1a1a1a" --hell "#e5e5e5"`) statt reinem Schwarz und Weiß — *vorgesehen*. Die Idee: ein weniger hartes Steuerbild lässt dem Stil mehr Raum.

Die Einstellungen:

| Regler | Spanne | Wirkung |
| --- | --- | --- |
| `strength` | 1,0–1,5, zum Retten bis 2,0 | Höher = besser lesbar, weniger Motiv. Schwarz-Weiß-Stile brauchen weniger als bunte, weil sie schon Kontrast haben. Unter 1,0 kommt das Raster nicht in ein Bild hinein. |
| `start_percent` | 0,0–0,15 | Unter 0,05 frisst das Muster die Anatomie. |
| `end_percent` | 0,8–1,0 üblich; 0,6–0,75 *vorgesehen* | Früher aufhören lässt den Stil die letzten Schritte frei malen. Motive mit viel Hell brauchen eher 0,75. |

**Was sich über viele Läufe gezeigt hat:**

- **Die Stärke allein verschiebt nur.** Sie tauscht Motiv gegen Lesbarkeit, bringt aber nicht beides zusammen. Dafür braucht es eine zweite Vorgabe für die Form oder getrennte Stufen; beide kommen später, in Abschnitt 9 und 14.
- **Die Ecken-Quadrate werden etwas.** Das Modell macht aus ihnen Augen, Fenster, Mäuler oder Laternen. Das lässt sich lenken: steht „lantern“ oder „eyes“ im Prompt, werden sie das. Steht nichts, werden es oft Fenster oder Kästen.
- **Große Dunkelflächen sind der eigentliche Hebel.** Ein Prompt, der *große zusammenhängende schwarze Massen auf weißem Papier* verlangt, hilft mehr als eine höhere Stärke — aber nur, wenn das Dunkel dort liegt, wo der Code dunkle Felder hat. Große schwarze Flächen an der falschen Stelle verschlucken helle Felder, und der Code liest nicht.
- **Feine Punkte zerlegen kleine Felder.** Punktierung und feine Stichel machen aus einem Feld ein graues Mittel. Flache Farbflächen wie im Beispielbild der Modellseite tragen einen Code leichter als ein Kupferstich.
- **Ein Referenzbild kann selbst ein Code sein.** Das Beispiel-Monster der Modellseite ist ein QR-Code. Wer es als Vorbild benutzt — wie, kommt in Abschnitt 10 —, holt dessen Ecken-Formen ins eigene Bild.

## 9 · ControlNets für die Form, zusammen mit QR Code Monster

Soll ein bestimmtes Wesen im Code stehen, bekommt es eine zweite Vorgabe: Canny, Scribble oder Lineart, in Reihe mit QR Code Monster (Abschnitt 7). Das Steuerbild wird am besten **auf das QR-Raster gezeichnet**, sodass die Augen der Skizze auf den Ecken-Quadraten sitzen. Liegen die Augen einer Gestalt 100 px auseinander und die Ecken-Quadrate 420 px, kämpfen beide Vorgaben gegeneinander.

Die Werte, die im Projekt liefen:

| Art | `strength` | `end_percent` | Wirkung |
| --- | --- | --- | --- |
| Canny | 0,35–0,6 | 0,3–0,5 | Umriss kommt, Code bleibt lesbar |
| Scribble | 0,45–0,85 | 0,4–0,7 | grobe Gestalt; stärker = mehr Wesen |
| Lineart | 0,55–0,8 | 0,3–0,7 | bei 0,8 bis 0,6 überstimmt die Linie den Code ganz |

Die allgemeine Empfehlung für zwei Vorgaben ist Scribble oder Lineart nur bis 0,4–0,5 der Schritte. Bei einer SDXL-Kombination aus Lineart und QR Code Monster: Lineart 0,7–0,9, QR Code Monster 0,5–0,8 oder bis 0,7.

**Zwei Lehren dazu.** Eine starke Formvorgabe über die ganze Laufzeit macht das Wesen deutlich und den Code unsichtbar. Und ein Kantenbild bringt **alle** Formen seines Ursprungs mit, auch die ungewollten: zieht man Canny aus einem Bild mit Säulen, entstehen wieder Säulen. Man zieht Kanten nur aus einem Bild, das man ganz so will.

Ein per Skript gezeichnetes Steuerbild wirkt geometrisch und ergibt geometrische Gesichter. Eine Skizze von Hand oder eine Kante aus einer gemalten Gestalt ist lebendiger.

## 10 · IP-Adapter: ein Bild als Prompt

Ein **IP-Adapter** nimmt ein Bild und macht daraus eine Vorgabe, als stünde es im Prompt. Er ist nicht auf das eigene Bild trainiert; er *schaut* mit einem Bildverständnis-Modell, dem **CLIP Vision**, und übersetzt, was er sieht. Er überträgt Stil, Textur, Farbe und — je nach Einstellung — auch Inhalt. Linien überträgt er nicht genau; dafür ist Lineart da (Abschnitt 7).

Anders als ein ControlNet sitzt er **am Modell**: das `MODEL` geht vom Checkpoint durch den IP-Adapter in den `KSampler`.

Die Nodes aus `ComfyUI_IPAdapter_plus`:

- `IPAdapterModelLoader` — lädt das Modell aus `models\ipadapter\`.
- `CLIPVisionLoader` — lädt das Bildverständnis aus `models\clip_vision\`.
- `IPAdapterAdvanced` — wendet an. Eingänge `model`, `ipadapter`, `image`, `clip_vision`, optional `image_negative`.
- `IPAdapterUnifiedLoader` — lädt beide Modelle in einem Node nach einer Voreinstellung. Bequem, aber man sieht nicht, welche Datei er nimmt. Der einfache Anwendungs-Node dazu heißt `IPAdapter`.

**Welches CLIP Vision zu welchem Modell gehört**, steht nicht im Dateinamen und ist die häufigste Fehlerquelle:

| IP-Adapter | CLIP Vision |
| --- | --- |
| `ip-adapter-plus_sd15.safetensors` | `CLIP-ViT-H-14-laion2B-s32B-b79K` |
| `ip-adapter-plus_sdxl_vit-h.safetensors` | ebenfalls `CLIP-ViT-H-14-laion2B-s32B-b79K` |
| `ip-adapter_sdxl.safetensors` | `CLIP-ViT-bigG-14-laion2B-39B-b160k` |

Das `vit-h` im Namen heißt: ViT-H, auch bei SDXL. `clip_vision_g` ist das bigG-Modell und passt nur zur dritten Zeile.

Die Regler von `IPAdapterAdvanced`:

| Regler | Was er tut | Im Projekt |
| --- | --- | --- |
| `weight` | wie stark | 0,35–1,0; meist 0,7 |
| `weight_type` | *welche Teile* des Modells beeinflusst werden | meist `linear` |
| `combine_embeds` | wie mehrere Bilder zusammengehen: `concat`, `add`, `subtract`, `average`, `norm average` | `average` bei acht Bildern |
| `start_at`, `end_at` | in welchem Teil der Schritte | Stil ab 0,3; Gestalt bis 0,5–0,8 |
| `embeds_scaling` | wie die Vorgabe in das Modell gerechnet wird | `V only` |
| `image_negative` | ein Gegenbild: *nicht so* | ein Menschengesicht |

**`weight_type` entscheidet, ob Inhalt mitkommt.** `linear` wirkt auf alle Schichten gleich und bringt Stil *und* Inhalt: nimmt man eine Tafel mit Figuren als Stilvorbild, tauchen Figuren und Gesichter aus der Tafel im Bild auf. `style transfer` wirkt nur auf die Schichten, die Stil tragen, und lässt den Inhalt weg. `composition` wirkt nur auf den Aufbau. Weitere Stufen: `strong style transfer`, `style and composition`, `style transfer precise`, `composition precise`, und Verläufe wie `ease in`, `ease out`.

**Mehrere Vorbilder** kommen über `ImageBatch` in einen Eingang: `ImageBatch` nimmt zwei Bilder, sieben davon in Reihe sammeln acht. Mit `combine_embeds` `average` wird daraus ein gemittelter Stil, in dem keine einzelne Tafel dominiert.

**Zwei IP-Adapter in Reihe** trennen Stil und Gestalt: der erste mit dem Stilvorbild, `start_at` 0,3, der zweite mit dem Gestaltvorbild, `end_at` 0,5–0,8. Die Gestalt legt sich früh fest, der Stil malt spät darüber.

**Vorbilder vorbereiten:** quadratisch, mit weißem Rand, ohne Bildunterschrift. CLIP Vision schneidet sonst selbst zu. Ein Ausschnitt ohne Gesichter bringt keine Gesichter mit.

Im Img2Img-Graph aus Abschnitt 5 sitzt der IP-Adapter zwischen Checkpoint und `KSampler`, gefüttert mit demselben Bild, das auch ins `VAEEncode` geht. Er hält dann den Strich des Originals, während `denoise` Neues wachsen lässt.

## 11 · LoRA: ein trainierter Zusatz

Eine **LoRA** ist eine kleine Datei, die ein Grundmodell in eine Richtung verschiebt: einen Stil, eine Figur, einen Gegenstand. Anders als der IP-Adapter ist sie **trainiert** und braucht zur Laufzeit kein Vorbild. Sie liegt in `models\loras\`.

Zwei Nodes laden sie, beide direkt hinter dem Checkpoint:

- `LoraLoader` — verschiebt `MODEL` und `CLIP`, hat zwei Stärken.
- `LoraLoaderModelOnly` — verschiebt nur `MODEL`, eine Stärke `strength_model`.

Die Reihenfolge der Kabel ist dann Checkpoint → LoRA → IP-Adapter → `KSampler`. Stärke 0,6–0,9 ist üblich; 1,0 und mehr kippt oft.

Die meisten LoRAs haben ein **Auslösewort**, das im Prompt stehen muss, meist als erstes Wort. Es ist beim Training festgelegt.

Eine LoRA kommt von drei Orten: fertig heruntergeladen, zum Beispiel von Civitai; trainiert mit einem eigenen Programm wie OneTrainer oder kohya_ss; oder trainiert in ComfyUI selbst, wie der nächste Abschnitt zeigt.

## 12 · Eine LoRA in ComfyUI trainieren

ComfyUI kann eine LoRA mit mitgelieferten Nodes trainieren. Das lohnt, wenn ein IP-Adapter einen Strich nur ungefähr trifft. Das Beispiel: acht kleine Schraffur-Tafeln (296–448 px) werden zu einer Stil-LoRA mit dem Auslösewort `hschraffur`.

**Der Datensatz** ist ein Ordner im Eingangsordner mit Bildpaaren: `t141_4.png` und daneben `t141_4.txt` mit der Beschreibung. Aus wenigen kleinen Vorlagen wird ein brauchbarer Satz so:

1. Jede Tafel **vierfach hochrechnen** mit einem Upscale-Modell wie `4x-UltraSharp` — wie das geht, kommt in Abschnitt 13 — und dann auf **zweifach verkleinern**. So bleiben feine Linien fein, statt nur weich vergrößert zu werden.
2. Bildunterschriften weiß übermalen, sonst lernt die LoRA Schrift.
3. Pro Tafel fünf Ausschnitte von 512 px (vier Ecken und Mitte) und die ganze Tafel auf 512 px mit weißem Rand.
4. Alles zusätzlich gespiegelt. Aus 8 Tafeln werden 96 Bilder.
5. Die Beschreibung: Auslösewort, dann Stil, dann **der Inhalt der Tafel beim Namen** — `hschraffur, black and white pen and ink engraving, dense fine parallel hatching ..., a screaming head with open mouth, a raised hand`. Was benannt ist, ordnet das Modell dem Namen zu. Was nicht benannt ist, landet im Auslösewort. So lernt `hschraffur` den Strich und nicht die Figuren.

Das Projekt erzeugt diesen Ordner mit `werkzeuge/lora_datensatz.py`, das mit der Python-Umgebung von ComfyUI läuft, weil es `torch` und `spandrel` für das Upscale-Modell braucht. Ein abgeleiteter Ordner wird bei jedem Lauf geleert und neu gebaut, nie von Hand geändert.

**Der Trainings-Graph** hat fünf Nodes:

1. `CheckpointLoaderSimple` — dasselbe Grundmodell, mit dem die LoRA später läuft.
2. `LoadImageTextDataSetFromFolder` — `folder` ist der Ordnername im Eingangsordner.
3. `MakeTrainingDataset` — übersetzt Bilder mit `VAE` und Texte mit `CLIP`.
4. `TrainLoraNode` — trainiert.
5. `SaveLoRA` mit `prefix` `loras/hschraffur` schreibt die Datei; `LossGraphNode` zeichnet den Verlauf.

Die Einstellungen von `TrainLoraNode`, die trugen:

| Einstellung | Wert | Bedeutung |
| --- | --- | --- |
| `steps` | 600 pro Lauf | Trainingsschritte |
| `learning_rate` | 0,0001 | Schrittweite des Lernens |
| `rank` | 16 | Größe der LoRA; 16 ergibt 34 MB |
| `optimizer` | `AdamW` | Verfahren |
| `loss_function` | `MSE` | Maß des Fehlers |
| `batch_size`, `grad_accumulation_steps` | 1, 1 | ein Bild pro Schritt |
| `training_dtype`, `lora_dtype` | `bf16` | Rechengenauigkeit; spart Speicher |
| `gradient_checkpointing` | an | spart Speicher, kostet Zeit |
| `algorithm` | `LoRA` | |
| `existing_lora` | leer, oder die Datei des vorigen Laufs | setzt ein Training fort |

600 Schritte dauern auf einer 16-GB-Karte etwa sechs Minuten. Mit `existing_lora` baut der zweite Lauf auf dem ersten auf, der dritte auf dem zweiten; so entstehen Stände nach 600, 1200 und 1800 Schritten, die man nebeneinander testen kann. Der Verlust pendelt dabei um 0,09–0,2 und sagt wenig über die Qualität — das Bild sagt es.

**`SaveLoRA` schreibt in den Ausgangsordner, geladen wird aus `models\loras\`.** Die Datei muss also verschoben werden. Verschieben, nicht kopieren, sonst gibt es zwei Stände mit gleichem Namen.

**Wann eine LoRA übertrainiert ist:** der Stand nach 600 und 1200 Schritten legt den Strich gleichmäßig über das ganze Bild. Der nach 1800 setzt Stichel und Flächen wie aus den Tafeln zusammengeklebt, und die Gestalt zerfällt. Der mittlere Stand ist meist der richtige.

---

# Teil III · Mehrere Durchgänge

## 13 · Hochrechnen

Es gibt drei Wege, ein Bild größer zu machen, und sie tun Verschiedenes.

**Im Latent mit Nachmalen** — der **Schärfe-Durchgang**. `LatentUpscaleBy` mit `scale_by` 1,5 und `upscale_method` `nearest-exact` vergrößert das Latent aus dem ersten `KSampler`. Ein zweiter `KSampler` malt es mit `denoise` 0,4 nach, mit anderem Seed. Das Ergebnis ist größer und schärfer, weil das Modell die Details in der neuen Größe neu malt. Die ControlNets bekommen im zweiten Durchgang schwächere Werte: QR Code Monster 0,9–1,0 statt 1,4, eine Formvorgabe 0,4. Sonst drückt der zweite Durchgang das Muster hart ins Bild und der Stil geht verloren.

**In Pixeln mit einem Upscale-Modell.** `UpscaleModelLoader` lädt ein Modell aus `models\upscale_models\`, `ImageUpscaleWithModel` rechnet das Bild damit vierfach hoch. `4x-UltraSharp` hält harte Kanten und feine Linien, `4x_NMKD-Siax` ist weicher. Das Modell erfindet nichts dazu, es schärft nur, was da ist.

**In Kacheln mit Nachmalen** — für sehr große Bilder. `ComfyUI_UltimateSDUpscale` rechnet das Bild mit einem Upscale-Modell hoch, schneidet es in Kacheln (`tile_width`, `tile_height`, etwa 1024), malt jede Kachel mit einem `KSampler` nach und setzt sie wieder zusammen. Damit eine Kachel nicht ein eigenes kleines Bild im Bild erfindet, läuft ein **Tile-ControlNet** mit, das den Aufbau der Kachel festhält: `TTPLANET_Controlnet_Tile_realistic` für fotografische Details, oder die Tile-Modelle von xinsir oder bdsqlsz. Übliche Werte bei SDXL: `denoise` um 0,6, Tile-ControlNet um 0,5.

## 14 · Stufen: erst die Gestalt, dann das Muster

Alle Vorgaben in einem Lauf kämpfen gegeneinander (Abschnitt 8). Getrennte Läufe lösen das: jede Stufe hat eine Aufgabe, und die nächste fängt mit dem Bild der vorigen an.

**Stufe A · die Gestalt, ohne Code.** Leere Fläche, `denoise` 1,0. Kein QR Code Monster. Formvorgabe: Scribble mit einer Skizze auf den Positionen der Ecken-Quadrate, `strength` 0,85 bis 0,7. Stil: IP-Adapter mit den Tafeln und dem Gegenbild. Ergebnis: ein Wesen, dessen Augen dort sitzen, wo später die Ecken-Quadrate hinkommen. Eine Stil-LoRA wirkt hier am besten, weil noch kein Code da ist, den sie stören kann.

**Stufe B · den Code hineinmalen.** Das Bild aus A geht als Startbild in den Graph (Abschnitt 5). Dazu:

- `denoise` 0,75 — das Fenster aus Abschnitt 5. 0,65 lässt den Code nicht hinein, 0,8 erfindet neue Gesichter. Die Empfehlung liegt bei 0,7–0,8.
- Canny aus demselben Bild, 0,5 bis 0,5 — hält die Gestalt aus A.
- QR Code Monster 1,4. Die Empfehlung ist 1,0–1,4 bis 0,75; bis 1,0 ist die übliche Voreinstellung.
- IP-Adapter wie in A. `style transfer` statt `linear` ist hier *vorgesehen*.
- Danach der Schärfe-Durchgang aus Abschnitt 13.

**Eine Stil-LoRA gehört nicht mit voller Laufzeit in Stufe B.** Ihre Schraffur füllt gern ein Ecken-Quadrat: aus Ring und Kern wird ein gleichmäßig schraffiertes Rechteck. Die Felder stimmen dann fast alle, aber der Scanner findet den Code nicht mehr. *Vorgesehen* sind drei Auswege: die LoRA nur in Stufe A, die LoRA in B erst ab der Hälfte der Schritte, oder die Ecken-Quadrate per Maske ausnehmen.

**Stufe C · nachschärfen** — *vorgesehen*. Nur Bilder, die schon lesen, bekommen einen letzten Durchgang mit `denoise` 0,25 und QR Code Monster 0,6 bis 0,5. Er soll Details zurückholen, die Stufe B geglättet hat, ohne den Code anzutasten.

**Eine Rettung** für ein Bild, das fast liest: dasselbe Bild als Start, QR Code Monster 2,0 bis 1,0, `denoise` 0,3–0,5. Sie hilft nur, wenn wenige Felder falsch sind. Muss der Aufbau sich ändern, reicht der niedrige `denoise` nicht.

## 15 · Latents mischen

Mehrere Bilder lassen sich im Latent zu einem verbinden. Jedes geht durch `VAEEncode`, dann:

- `LatentBlend` — mischt zwei Latents gleicher Größe mit `blend_factor`. 0,5 ist halb und halb.
- `LatentComposite` — setzt `samples_from` an die Stelle `x`, `y` in `samples_to`, mit weichem Rand `feather`. Das ist Collage, nicht Überblendung.

Das Gemisch ist noch kein Bild, sondern eine Überlagerung. Ein `KSampler` mit `denoise` 0,4–0,6 malt es zu einem Ganzen zusammen.

`LatentBatch` gehört nicht dazu, obwohl der Name es nahelegt: er legt Latents nur **nebeneinander** in einen Stapel, sodass der `KSampler` sie getrennt rechnet. Er mischt nichts.

Ein Startbild aus zwei Quellen geht auch in Pixeln: Code und Skizze übereinanderlegen, als Startbild nehmen, `denoise` 0,9. Das Bild bekommt so eine Anfangsrichtung, ohne dass ein ControlNet sie erzwingt.

---

# Teil IV · Muster und Flächen

## 16 · Nahtlose Kacheln

Ein Muster, das sich endlos wiederholen soll, braucht Ränder, die ineinander übergehen: der rechte Rand passt an den linken, der obere an den unteren. Das Modell weiß davon nichts. Ein Custom Node für nahtloses Kacheln — etwa „Seamless Tile“ oder Nodes aus `ComfyUI-Inspire-Pack` und `ComfyUI-Impact-Pack` — stellt das Modell so um, dass es beim Rechnen über die Ränder hinweg weiterrechnet. Das Ergebnis lässt sich nebeneinanderlegen, ohne dass eine Naht sichtbar ist.

## 17 · Outpainting mit gleitendem Fenster

Soll ein Muster sich *verwandeln*, während es weiterläuft, hilft nahtloses Kacheln nicht. Man lässt dann jedes Bild aus dem vorigen herauswachsen:

1. Bild 1 erzeugen, zum Beispiel 1024 × 1024.
2. `ImagePadForOutpaint` mit `right` 1024, `left`, `top`, `bottom` 0. Die Fläche ist jetzt 2048 × 1024, rechts leer. `feathering` macht den Übergang weich. Der Node gibt Bild und `MASK` aus.
3. `VAEEncodeForInpaint` mit Bild und Maske. `grow_mask_by` vergrößert die Maske ein Stück ins alte Bild hinein, damit die Naht mitgemalt wird.
4. `KSampler` mit `denoise` **1,0**. Die leere Hälfte wird neu gemalt; weil das Modell die linke Hälfte sieht, führt es Linien an der Naht weiter.
5. `ImageCrop` mit `width` 1024, `height` 1024, `x` 1024, `y` 0 schneidet die neue rechte Hälfte aus. Sie ist Bild 2 und der Anfang des nächsten Durchgangs.

Ein Inpainting-Checkpoint oder das Inpaint-ControlNet aus Abschnitt 7 füllt solche Lücken sauberer als ein normales Grundmodell.

## 18 · Regionale Prompts

Ein Prompt gilt normalerweise für das ganze Bild. Mit **regionalen Prompts** bekommt jede Zone ihren eigenen Text: links Metall, rechts Ranken. Die Nodes dafür kommen aus `ComfyUI-Impact-Pack` oder als Regional Prompter beziehungsweise Attention Couple. Jede Region ist eine Maske mit einem eigenen `CLIPTextEncode`.

Die Masken muss man nicht malen. **Segment Anything** — `ComfyUI-Segment-Anything` mit dem Modell `sam_vit_h_4b8939.pth` in `models\sams\` — erkennt Formen im Bild und gibt sie als Masken aus. So bekommen die Formen eines vorhandenen Musters automatisch je ein Material.

## 19 · Relief und Licht aus einer Tiefenkarte

Eine **Tiefenkarte** ist ein Graustufenbild: hell ist nah, dunkel ist fern. Aus ihr baut das Depth-ControlNet (Abschnitt 7) ein Bild mit Relief und passendem Licht. Der Weg hat zwei Teile.

**Tiefe schätzen.** `MarigoldDepthEstimation` aus `ComfyUI-Marigold` rechnet aus einem Bild eine Tiefenkarte. Sein `model` ist `Marigold` oder das schnellere `marigold-lcm-v1-0`. Das LCM-Modell liegt als Ordner in `models\diffusers\marigold-lcm-v1-0\`, nicht im Ordner des Custom Nodes. Einfachere Tiefen-Preprocessoren kommen aus `comfyui_controlnet_aux`.

**Tiefe anwenden.** Die Karte geht als Steuerbild in ein Depth-ControlNet: für SD 1.5 `control_v11f1p_sd15_depth`, für SDXL `diffusers/controlnet-depth-sdxl-1.0-small` oder die Control-LoRA `sai_xl_depth_256lora`. Beide SDXL-Varianten liegen in `models\controlnet\` und laden über `ControlNetLoader`.

Damit wird aus einer flachen Zeichnung ein Relief: Zeichnung → Tiefenkarte → neues Bild mit Licht und Schatten, das den Linien der Zeichnung folgt.

---

# Teil V · Die Arbeitsweise

## 20 · Vergleichen, prüfen, festhalten

**Eine Reihe bewegt eine Stellschraube.** Gleicher Seed, gleiche Einstellungen, ein Wert in Stufen — etwa QR Code Monster 1,0 bis 1,5 in Schritten von 0,1. Der Wert steht im Dateinamen: `gnom_v8_c60e30q150` heißt Version 8, Canny 0,6 bis 30 %, QR 1,5. Die Bilder einer Reihe landen nebeneinander auf einem Übersichtsbogen.

**Jeder Workflow wird eine Datei.** Im API-Format mit dem Namen seiner Version, unter git. Das PNG trägt ihn zusätzlich, aber nur die Datei lässt sich vergleichen und wiederfinden.

**Vor dem Lauf eine Erwartung.** Ein Satz, was herauskommen soll — „ich erwarte 8 von 20 und einen Kopf“. Danach das Ergebnis, die Schwäche, der nächste Schritt. Ohne die Erwartung bestätigt jedes Ergebnis, was man ohnehin dachte.

**Ein automatischer Scan ist ein Hinweis, kein Urteil.** Ein Test mit `zxing-cpp` liest jedes Bild in 20 Versuchen: fünf Größen (768, 384, 256, 192, 128 px) mal vier Unschärfen (0, 1, 2, 4), jeweils mit automatischem Kontrast und weißem Rand von einem Achtel der Größe. Die Zahl der Treffer ordnet eine Reihe. Sie weicht aber vom Handy ab, in beide Richtungen: ein Bild mit 1 von 20 kann das Handy lesen, eines mit 8 von 20 nicht. **Das Handy entscheidet.** Kandidaten gehen immer auch dort durch.

**Nachbearbeitung per Skript** ist der sichere Nebenweg: ein fertiges Bild aufhellen, in jede Feldmitte einen Punkt setzen, die Ecken-Quadrate voll zeichnen. Der Code liest dann immer. Man sieht aber einen Code über einem Bild, nicht ein Bild, das ein Code ist.
