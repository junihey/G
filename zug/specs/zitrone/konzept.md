# zitrone — eine Zeichnung wächst zum Muster

**Herkunft:** der Ordner `Desktop\animation\comfy\zitrone\`. Darin lagen eine Notiz vom 17.05.2026 (hier daneben als `notizen.txt`) und 16 Modelle. Zusammengestellt am 16.10.2026 aus beidem. Die Modelle liegen jetzt in `zaehlen\modelle\comfyui\`, die Kopien in `zitrone\` sind gelöscht.

**Stand (28.10.2026):** Prototyp gebaut, als Wärmeband im Heft `zaehlen\heft-25920` (Abschnitt „Ziel: das Wärmeband im Heft 25920“). Drei der vier offenen Fragen sind damit entschieden.

## Ziel: das Wärmeband im Heft 25920

Das Muster ist ein **Band über alle Seiten** des Hefts „25920 – Das platonische Weltenjahr“ (`C:\Users\nolte\Desktop\zaehlen\heft-25920`). Die rechte Kante jeder Seite geht nahtlos in die linke der nächsten über. Julians Notiz dazu (`specs\zitrone\lemon gelb leber ärger mond.md`, Zeile 16): „Eigentlich Leporello aber doch normales Buch und dann ein durchgängiges Band“.

Das Band erzählt eine Entwicklung: **Wärme, die in Flammen überschlägt.** Links stehen ruhige, waagerechte Wellenlinien wie das Wasser in den Holzschnitten. Nach rechts heben sie sich zu Zungen, zuletzt rollen sie über.

| Frage aus „Zu entscheiden“ | Entscheidung |
|---|---|
| Wofür das Muster? | Risodruck im Heft 25920, A5 hoch, zwei Ebenen: Schwarz und Zitronengelb (#FFE600) |
| Welche Zeichnung? | Julians sieben Kritzelzeichnungen auf Gelb, `heft-25920\quellen\inspiration\img392`–`img398`, eine je Seite, nach Dynamik geordnet |
| SD 1.5 oder SDXL? | SD 1.5, der erprobte Stand aus `comfyui-qr-monster` v27: DreamShaper 8, Stil-LoRA `hschraffur`, QR Code Monster v2, IP-Adapter plus |
| Eigenes Projekt? | Nein, Teil von `heft-25920`; Technik aus `comfyui-qr-monster` |

**Vorbild für Strich und Dynamik:** die Holzschnitte (`SnapInsta…jpg`) und die Zeichnungen in `heft-25920\quellen\inspiration\`.

**Umsetzung:** `heft-25920\src\band.py`, Ergebnisse in `heft-25920\band\ausgaben\`.

1. Ein Steuerbild für das ganze Band in Python. Weil es ein einziges Bild ist, läuft die Form über jede Seitengrenze.
2. Gleitendes Fenster, wie unter „Endloses Muster“ beschrieben: Jede Seite wird mit 128 px der vorigen gemalt. Diese 128 px hält eine Rauschmaske fest, sodass der Anschluss sitzt. Dafür braucht es keine Erweiterung: `SetLatentNoiseMask` ist eingebaut.
3. Je Seite eine Prompt-Stufe von „gentle warmth“ bis „flames overturning“.
4. Je Seite drei Bild-Prompts für den IP-Adapter: die Zeichnung und zwei Schraffuren aus den Holzschnitten (Wasserlinien, Strahlen, Hügel, Wasserfall, Busch, Wolkenring), ohne Figuren ausgeschnitten.
5. Hochrechnen mit 4x-UltraSharp auf 2048 px Breite (351 dpi), dann je Seite eine schwarze und eine gelbe 1-bit-Ebene.
6. **Gelb** (Julian, 28.10.2026): Seite 1 ohne Gelb. Seite 2 beginnt mit Punkten. Danach baut sich ein linearer Verlauf von unten auf und züngelt. Auf den letzten zwei Seiten überschlägt sich alles nichtlinear. Gedruckt wird ein Punktraster unter 45°, Vollton dort, wo der Verlauf 1 erreicht. (Version v2)
7. **Ab v4** (Julian, 28.10.2026): Flammen züngeln von oben und unten, nicht nur von unten. Der Verlauf liegt in Menge und Stärke der Wärme über das Band, nicht in der Höhe. Das Gelb ist eine Streuung von Punkten verschiedener Größe, mit Zonen von feinem Staub bis zu großen Flecken, so wechselnd wie die Schraffuren. Alle Versionen bleiben liegen: `heft-25920\band\ausgaben\<v>\`.

**Abweichung vom Workflow unter „Wie es gehen sollte“:** Die Zeichnung ist nicht das Ausgangsbild (Img2Img, denoise 0,55), und ControlNet Lineart fehlt. Beides hielte die Linien *einer* Zeichnung fest, das Band braucht aber eine Form über sieben Seiten. Diese Form kommt aus dem Steuerbild über QR Code Monster (Schritt 4 der Idee). Die Zeichnungen wirken nur über den IP-Adapter. Erste Fassung: `heft-25920\verworfen\band-v1\`.

### Offen

- ~~Img2Img aus der Zeichnung und Lineart: als Variante gegen den heutigen Weg testen.~~ Getestet als v5 (28.10.2026): Bei denoise 0,55 und Lineart 0,8 stehen die Zeichnungen fast wörtlich auf den Seiten, und die durchlaufende Form geht verloren. Für ein Band trägt der Weg über das Steuerbild (v4). Mittelweg als v6 gebaut: denoise 0,8 und Lineart 0,4.
- **Stil-LoRA `hband`** (28.10.2026) aus allen 16 Bildern in `heft-25920\quellen\inspiration` (7 Zeichnungen, 9 Holzschnitte), 192 Ausschnitte, 1200 Schritte, 24 min, in ComfyUI trainiert (`heft-25920\src\band_lora.py`). Liegt in `zaehlen\modelle\comfyui\loras\`. Genutzt ab v7.
- **Klare Kanten** (Julian, 28.10.2026, Vorbild `quellen\inspiration\a1787944900_10.jpg`): v9 bis v11. Die Linien bleiben wie Schraffur gelegt, ihre Ränder werden glatt und satt.
- Zonen mit eigenem Prompt: braucht Impact Pack, Regional Prompter und Segment Anything; keins davon ist installiert.
- Relief und Licht über eine Tiefenkarte: Marigold ist installiert, das Depth-ControlNet für SD 1.5 liegt bereit.
- Hochskalieren mit Details: heute nur 4x-UltraSharp, ohne Ultimate SD Upscale und Tile-ControlNet.
- SVG statt PNG wie die übrigen Motive des Hefts (Regel 1 in `heft-25920\CLAUDE.md`).
- Seitenzahl und Ausschießen: Welche Seiten liegen im gebundenen Heft nebeneinander?
- Nähte: An der Grenze von Seite 6 zu 7 ist der Übergang leicht verwischt.

## Die Idee

Eine gescannte Zeichnung ist der Samen. Ein Bildmodell lässt aus ihr ein Muster wachsen: Ranken, Blätter, Texturen, in Strich und Papier der Zeichnung. Eine verborgene Form steuert, wohin das Muster wächst. Am Ende steht ein Muster, das sich endlos fortsetzen lässt.

## Wie es gehen sollte

1. **Grundlage:** ein SDXL-Checkpoint im Img2Img-Modus. Die Zeichnung geht über `VAE Encode` in den latenten Raum, der KSampler malt mit denoise 0,55 darüber. Die Notiz empfiehlt Juggernaut XL oder DreamShaper XL.
2. **Strich und Papier halten:** ein IP-Adapter bekommt dieselbe Zeichnung als Bild-Prompt. Er überträgt Stil, Textur und Farbe, aber keine Linien.
3. **Linien halten:** ControlNet Lineart, Stärke 0,7 bis 0,9.
4. **Form verstecken:** ControlNet QR Code Monster mit einem Muster- oder QR-Bild, Stärke 0,5 bis 0,8, endet bei etwa 70 % der Schritte. So setzt sich danach der Stil durch.
5. Die beiden ControlNets laufen hintereinander, Lineart zuerst.

## Ausbaustufen aus der Notiz

| Stufe | Wie | Was dafür nötig ist |
|---|---|---|
| Endloses Muster | Kacheln mit nahtlosen Rändern; oder ein gleitendes Fenster: Bild 1 rechts um 1024 px erweitern, die neue Hälfte per Outpainting füllen, ausschneiden, als Bild 2 weiterreichen | Seamless Tile, Inspire Pack oder Impact Pack; `Pad Image for Outpainting` ist in ComfyUI eingebaut |
| Zonen mit eigenem Prompt | Formen im Muster erkennen und ihnen Materialien zuweisen | Impact Pack, Regional Prompter, Segment Anything mit `sam_vit_h_4b8939.pth` |
| Relief und Licht | aus einer Tiefenkarte zurück ins Bild | Marigold (Knoten installiert), Depth-ControlNet für SDXL, etwa `sai_xl_depth_256lora` |
| Hochskalieren | das Bild in Kacheln teilen, hochrechnen, Details dazumalen | Ultimate SD Upscale, Tile-ControlNet von TTPlanet, 4x-UltraSharp oder 4x_NMKD-Siax |

## Was dafür bereitlag

Alle liegen jetzt in `zaehlen\modelle\comfyui\<kategorie>\`.

| Modell | Kategorie | Basis | Rolle |
|---|---|---|---|
| `juggernautXL_version2`, `dreamshaperXL_lightningDPMSDE`, `ponyDiffusionV6XL_v6StartWithThisOne`, `sd_xl_base_1.0_0.9vae` | `checkpoints` | SDXL | Grundlage |
| `ip-adapter-plus_sdxl_vit-h` | `ipadapter` | SDXL | Strich und Papier |
| `SDXLopen_clip_pytorch_model_vit_h` (lag zweimal da, einmal als `open_clip_model`) | `clip_vision` | — | das „Auge“ des IP-Adapters |
| `control_v11p_sd15_lineart` (lag als `diffusion_pytorch_model.safetensors`) | `controlnet` | **SD 1.5** | Linien |
| `control_sd15_canny` (lag als `…(1)`) | `controlnet` | **SD 1.5** | Kanten |
| `control_v11p_sd15_inpaint` (lag als `…(2)`) | `controlnet` | **SD 1.5** | Muster fortführen |
| `control_v1p_sd15_qrcode_monster` (lag als `…(3)`, dazu die `.yaml`) | `controlnet` | **SD 1.5** | Form verstecken |
| `sai_xl_depth_256lora` | `controlnet` | SDXL | Relief |
| `TTPLANET_Controlnet_Tile_realistic_v2_fp16` | `controlnet` | SDXL | Hochskalieren |
| `sam_vit_h_4b8939.pth` | `sams` | — | Formen erkennen |
| `4x-UltraSharp.pth`, `4x_NMKD-Siax_200k.pth` | `upscale_models` | — | Hochskalieren |

Von den nötigen Erweiterungen ist in ComfyUI nur `comfyui-marigold` und `ComfyUI_IPAdapter_plus` installiert. Es fehlen Impact Pack, Inspire Pack, Regional Prompter, Segment Anything, Ultimate SD Upscale und die ControlNet-Preprocessors.

## Was nicht zusammenpasst

**Die vier ControlNets für Linien, Kanten, Inpaint und QR Code Monster sind für SD 1.5, die Checkpoints für SDXL.** Ein ControlNet wirkt nur auf der Basis, für die es trainiert ist. Die Notiz sagt selbst „für sdxl herunterladen“, geladen wurden aber die Fassungen für SD 1.5. Zu SDXL passen aus dem Ordner nur `sai_xl_depth_256lora` und das Tile-Modell von TTPlanet. Für den Kern der Idee fehlen also Lineart und QR Code Monster für SDXL, oder die Idee läuft auf SD 1.5.

## Was davon schon gebaut ist

`zaehlen\comfyui-qr-monster` (seit 14.09.2026) nutzt **dieselbe Technik** für ein anderes Ziel: scannbare QR-Codes als schraffierte Schreckwesen. Dort laufen QR Code Monster v2, Lineart, Canny, Scribble und ein IP-Adapter auf SD 1.5 mit DreamShaper 8, über 27 Versionen, mit Versuchsbuch und einer eigenen Stil-LoRA. Die Erfahrungen dort gelten hier: wie stark QR Code Monster sein darf, bevor das Bild kippt; dass der IP-Adapter den Strich nur ungefähr überträgt und deshalb eine LoRA nötig wurde.

Was es dort **nicht** gibt: eine eigene Zeichnung als Ausgangsbild, das Wachsen per Img2Img, das endlose Muster, Zonen, Relief.

## Zu entscheiden

Stand 16.10.2026. Drei Fragen hat der Abschnitt „Ziel“ am 28.10.2026 beantwortet. Offen bleibt, ob SDXL später nötig wird.

- **Eigenes Projekt oder nächste Stufe von `comfyui-qr-monster`?** Technik, Workflows und Versuchsbuch stehen dort schon. Ein neues Projekt finge bei null an.
- **SD 1.5 oder SDXL?** SD 1.5 nutzt, was in `comfyui-qr-monster` erprobt ist. SDXL braucht neue ControlNets, die noch nicht geladen sind.
- **Wofür das Muster?** Die Notiz nennt kein Ziel. Ob Druck, Laser (`idraw`), Projektion in `wwww` oder Bildschirm, entscheidet über Größe, Auflösung und ob es endlos sein muss.
- **Welche Zeichnung?** Die Notiz nennt keine.
