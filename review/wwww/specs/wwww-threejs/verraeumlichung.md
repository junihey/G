---
tags: [spec, wwww-threejs, verraeumlichung]
created: 2026-10-04
topic: 'Wie die Zeichnung räumlich wird: ein Vorschritt, vier Wege, eine Voxel-Ansicht, und welche Modelle dafür in Frage kommen'
verification: 'im Gespräch festgelegt am 2026-10-04, Größen über die Hugging-Face-API gemessen am selben Tag, nichts davon gebaut'
---

# Verräumlichung

Festgelegt im Gespräch am 2026-10-04. **Nichts davon ist gebaut.**

> [!abstract] Ein Vorschritt, dann vier Wege in den Raum
> Zuerst wird die Buntstiftzeichnung quadratisch erweitert. Von dort führen vier Wege in den Raum: Tiefenkarte, Schalen, Objekte und eine generierte Welt. Die Voxel bauen auf der Tiefenkarte auf. Jeder Weg wird eine eigene Ansicht im Viewer von `wwww-threejs-schichten`.
>
> ```mermaid
> flowchart TD
>   Z["Buntstiftzeichnung<br/>4096 × 2538"] -->|"0 · FLUX.1 Fill"| Q["quadratisch<br/>4096 × 4096"]
>   Q --> T["1 · Tiefenkarte<br/>Depth Anything"]
>   T --> S[2 · Schalen]
>   Q --> O["3 · Objekte<br/>Bild zu 3D"]
>   Q --> W["4 · Welt<br/>Gaussian Splats"]
>   T --> VX[5 · Voxel]
> ```

^blick

**Gegenstand:** die Buntstiftzeichnung aus `zaehlen\quellen\medien\johannes kortex\`. Die fünf Scans dort sind dieselbe Zeichnung mit unterschiedlicher Helligkeit. Die Ebenen aus Scan `00001` liegen fertig in `wwww-threejs-schichten\web\layers\`.

**Wo es landet:** jede Ansicht als eigener Eintrag im Menü „Ansicht" des Viewers von `wwww-threejs-schichten`. Auflicht und Leuchttisch bleiben, wie sie sind.

---

## Die Reihenfolge

| Schritt | Was | Hängt ab von |
| --- | --- | --- |
| 0 | **Quadratisch erweitern:** FLUX.1 Fill malt oben 1558 px dazu, aus 4096 × 2538 wird 4096 × 4096. Die Masken der Ebenen werden nach oben verlängert. Ergebnis in `web\layers-quadrat\`. | — |
| 1 | **Tiefenkarte allein:** ein Mesh aus der Tiefenkarte von Depth Anything V2. | 0 |
| 2 | **Schalen:** jede Ebene gewölbt mit ihrem Ausschnitt der Tiefenkarte. | 0, 1 |
| 3 | **Objekte:** einzelne freigestellte Ebenen, zuerst `roehren`, durch einen Bild-zu-3D-Generator. | 0 |
| 4 | **Generierte Welt:** ein begehbarer Raum als Gaussian Splats. | 0 |
| 5 | **Voxel:** Pixelblöcke als Würfel auf der Tiefe der Tiefenkarte, Körnung per Regler. Mit Schritt 0 ein Würfel von etwa 128 × 128 × 128. | 0, 1 |

Der Würfel aus allen Ebenen ist eine Einstellung: sechs Ebenen über eine Bildbreite ergeben einen Abstand von 0,2 Bildbreiten.

---

## Modelle

Größe nur der Dateien, die ein Lauf braucht. Stand: 2026-10-04.

### Vorschritt und Weg 1, 2, 5

| Modell | Größe | Link | Stand |
| --- | --- | --- | --- |
| FLUX.1 Fill dev, GGUF Q6_K | 9,86 GB | https://huggingface.co/YarvixPA/FLUX.1-Fill-dev-GGUF/resolve/main/flux1-fill-dev-Q6_K.gguf | Download beim Nutzer |
| Depth Anything V2 Large | 1,34 GB | https://huggingface.co/depth-anything/Depth-Anything-V2-Large/resolve/main/depth_anything_v2_vitl.pth | Download beim Nutzer |

FLUX.1 Fill braucht `t5xxl_fp16`, `clip_l` und `ae.safetensors`. Alle drei liegen schon in ComfyUI.

### Weg 3 — Bild zu 3D

Alle erwarten ein Objekt vor leerem Hintergrund. Die freigestellten Ebenen sind genau das.

| Modell | Von | Größe | Link | Stand |
| --- | --- | --- | --- | --- |
| Hunyuan3D 2.1, Form | Tencent | 7,37 GB | https://huggingface.co/tencent/Hunyuan3D-2.1/resolve/main/hunyuan3d-dit-v2-1/model.fp16.ckpt | als Erstes testen, läuft in ComfyUI ohne Custom Nodes |
| Hunyuan3D 2.1, mit Farbe | Tencent | 14,91 GB | https://huggingface.co/tencent/Hunyuan3D-2.1 | offen |
| TRELLIS | Microsoft | 3,30 GB | https://huggingface.co/microsoft/TRELLIS-image-large | als Zweites testen; lädt beim ersten Start DINOv2 nach, Größe nicht gemessen |
| TRELLIS.2 | Microsoft | bis 16,24 GB | https://huggingface.co/microsoft/TRELLIS.2-4B | offen |
| TripoSG | VAST | 7,95 GB | https://huggingface.co/VAST-AI/TripoSG | offen, nur Form |
| Stable Fast 3D | Stability AI | 4,03 GB | https://huggingface.co/stabilityai/stable-fast-3d/resolve/main/model.safetensors | offen, Lizenz auf der Repo-Seite bestätigen |
| SPAR3D | Stability AI | 7,33 GB | https://huggingface.co/stabilityai/stable-point-aware-3d/resolve/main/model.safetensors | offen, Lizenz auf der Repo-Seite bestätigen |
| Step1X-3D | StepFun | bis 19,64 GB | https://huggingface.co/stepfun-ai/Step1X-3D | offen |
| Hi3DGen | Stable-X | 2,65 GB | https://huggingface.co/Stable-X/trellis-normal-v0-1 | offen; braucht ein Normalen-Modell, noch nicht benannt |
| Rodin | Hyper3D | — | über den Blender-MCP | offen, nur als Dienst, kostet pro Lauf |

Zeigen Hunyuan3D 2.1 und TRELLIS bei den Röhren dasselbe Problem, entfallen die übrigen.

### Weg 4 — Generierte Welt

| Variante | Größe | Link | Stand |
| --- | --- | --- | --- |
| **Marble** (World Labs), Dienst im Netz | 0 GB | https://marble.worldlabs.ai | **gewählt als Erstes**; die Zeichnung wird hochgeladen, Ergebnis als Splat-Datei nach `web\welt\` |
| Wan 2.2 + HunyuanWorld-Mirror | 5,06 GB | https://huggingface.co/tencent/HunyuanWorld-Mirror/resolve/main/model.safetensors | offen; Wan 2.2 liegt schon in ComfyUI |
| HunyuanWorld 1.0 + FLUX.1 dev | 1,56 GB + 23,80 GB | https://huggingface.co/tencent/HunyuanWorld-1 · https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors | offen; FLUX.1 dev passt in voller Größe nicht auf 16 GB, Lizenz bestätigen |
| HunyuanWorld-Voyager | 86,11 GB | https://huggingface.co/tencent/HunyuanWorld-Voyager | ausgeschlossen, zu groß |

Für die Anzeige im Viewer: Spark (`@sparkjsdev/spark`, Version 2.3.1 vom 2026-10-01). Mit three.js r160 läuft es nicht, denn Spark verlangt three ab Version 0.180 (laut npm am 2026-11-05). Am 2026-11-10 entschieden: Die Welt läuft auf dem aktuellen three mit `WebGLRenderer`, damit passt Spark (`welt.md`, „Der Renderer“). Dort erscheint eine generierte Welt nur als möglicher Inhalt eines Mikroraums.
