# Blender → ComfyUI: Strukturgeführte Videogenerierung

**Learning-Dokument, Stand September 2026**
Zielhardware: 16 GB VRAM, 32–64 GB System-RAM

---

## 1. Worum es geht

Du baust in Blender eine untexturierte Szene (Clay Render / Whitebox): grobe Geometrie, echte Kamerafahrt, Figuren als Proxys. Diese Szene liefert nicht das fertige Bild, sondern die **Struktur**: Wo ist was im Raum, wie bewegt sich die Kamera, wo verlaufen die Silhouetten. ComfyUI generiert daraus das eigentliche Video und legt Texturen, Licht und Stil darüber.

Der Vorteil gegenüber reinem Prompting: Kamerafahrt, Bildaufbau und Objektpositionen sind exakt das, was du geplant hast, und nicht das, was das Modell sich ausdenkt. Der Vorteil gegenüber klassischem 3D-Rendering: du brauchst keine Texturen, kein Shading, kein Lookdev.

**Kernbegriff:** Bytedance nennt dieses Verfahren *clay render referencing*. Der Begriff ist nützlich, weil danach die meiste aktuelle Literatur sortiert ist.

---

## 2. Das Grundprinzip: 3D-Wahrheit statt Schätzung

Die meisten Video-to-Video-Tutorials machen es so:

> Video rendern → durch einen Depth-Estimator schicken → geschätzte Tiefenkarte als Steuerung nutzen

Das ist bei einer Blender-Quelle **falsch**. Der Depth-Estimator rät sich aus einem fertigen Bild zusammen, was Blender exakt weiß. Zwei Probleme entstehen dabei:

1. **Ungenauigkeit.** Geschätzte Tiefe ist relativ und grob, echte Z-Tiefe ist metrisch und pixelgenau.
2. **Flackern.** Estimators arbeiten frameweise. Kleine Schätzfehler ändern sich von Frame zu Frame, das Ergebnis zittert.

Richtig ist:

> AOVs direkt aus Blender exportieren → als Steuerung nutzen

Das ist der wichtigste einzelne Qualitätssprung in der ganzen Pipeline.

---

## 3. Teil A — Die Blender-Seite

### 3.1 Szenenaufbau

Wenn ein MCP-Agent die Szene baut, gib ihm diese Vorgaben mit. Jede einzelne davon hat eine Wirkung auf das Endergebnis:

| Vorgabe | Warum |
|---|---|
| Reale Maßstäbe (Figur = 1,75 m) | Das Videomodell hat gelernt, wie ein Mensch relativ zu Türhöhen und Möbeln aussieht. Ein 3-Einheiten-Quader gibt ihm keinen Anhaltspunkt. |
| Echte Brennweite + Sensorgröße | 24 mm und 85 mm erzeugen völlig verschiedene perspektivische Verzerrung, und die liest das Modell aus der Tiefenkarte ab. |
| Depth of Field aktiv | Gibt dem Modell einen Hinweis auf den Bildfokus. |
| Grobe Humanoide statt Quader | Ein Würfel enthält keine Pose. Rigify-Mannequin oder simples Mixamo-Mesh reicht völlig. |
| Blockout-Licht setzen | Auch bei untexturiertem Render. Der Clay-Beauty-Pass mit plausiblem Key/Fill gibt dem Modell die Lichtrichtung vor. |
| **16 fps, Framezahl = 4n+1** | Wan-Modelle sind auf 16 fps trainiert und wollen 81 Frames (= gut 5 s). Direkt richtig rendern spart Retiming-Artefakte. |

### 3.2 Die Passes

| Pass | Blender-Quelle | Wofür |
|---|---|---|
| **Tiefe** | Z-Pass oder Mist-Pass | Hauptsteuerung. Raumlage, Kamerafahrt, Objektabstände. |
| **Normalen** | Normal-Pass | Oberflächenausrichtung. Hilft dem Modell beim Ableiten von Licht und Schatten. |
| **Kanten** | Freestyle | Silhouetten, harte Objektgrenzen. |
| **Masken** | Cryptomatte pro Objekt/Collection | Layering, getrennte Generierung, Compositing. |
| **Bewegung** | Vector-Pass | Optional, für Flow-Führung. |
| **Clay Beauty** | Normaler Render, Standard-Material | Lichtreferenz und Sichtkontrolle. |

**Zu Freestyle:** Nur `Silhouette` und `Contour` aktivieren, **keine** `Crease`-Kanten. Sonst ziehst du die Facettenkanten deines Low-Poly-Meshes ins Endergebnis, und das Video sieht aus wie ein Drahtgitter mit Textur drüber.

### 3.3 Die Depth-Falle (wichtigster Einzelpunkt)

Tiefenkarten müssen über den **gesamten Shot mit denselben Min/Max-Werten** normalisiert werden, nicht pro Frame.

Was passiert, wenn du es falsch machst: Sobald ein Objekt näher an die Kamera kommt, verschiebt sich die Normalisierung des ganzen Frames. Die Tiefe "atmet", und im generierten Video pumpen Helligkeit und Perspektive sichtbar mit.

**Umsetzung:** Map-Range-Node im Compositor mit fest eingetragenen From-Min / From-Max in Metern. Die Werte ermittelst du einmal über den gesamten Kamerapfad (nächster und fernster relevanter Punkt in der Szene, über alle Frames).

### 3.4 Export

- **16-bit PNG**, nicht 8-bit. 256 Tiefenstufen sind zu wenig, das erzeugt Terrassen im Raum.
- Bildsequenz, nicht Videodatei. Kein Kompressionsverlust an den Kanten.
- Ordnerstruktur pro Pass: `/depth/`, `/edge/`, `/normal/`, `/masks/`, `/clay/`
- Gleiche Frame-Nummerierung über alle Passes, sonst laufen die Sequenzen in ComfyUI auseinander.

---

## 4. Teil B — Die ComfyUI-Seite

### 4.1 Modellwahl bei 16 GB

**Die Wahl bei 16 GB: Wan 2.2.** Apache 2.0, native ComfyUI-Unterstützung, das mit Abstand größte Control-Ökosystem.

Die naheliegende Alternative wäre **LTX-2.5**: IC-LoRA-Konditionierung für Depth, Pose, Edge Maps und Motion Tracks, dazu natives Audio im selben Pass. Technisch für diesen Anwendungsfall die interessantere Architektur, aber der Einstieg liegt bei 32 GB distilled. Auf 16 GB nicht nutzbar. Relevant, sobald du auf eine größere Karte wechselst.

Konkrete Konfiguration:

```
Hauptmodell:   Wan 2.2 A14B GGUF, Q5_K_S
               (beide Teile: HighNoise UND LowNoise)
Text Encoder:  UMT5-XXL GGUF, Q5_K_M
VAE:           Wan 2.2 VAE
Attention:     SageAttention 2.x   → ca. 30 % schneller
```

Mit Q8 und 64 GB System-RAM sind laut Nutzerberichten 5-Sekunden-Clips bei 1024×574 in etwa 7 Minuten möglich. Q5 bei 832×480 ist entsprechend komfortabel.

Für die Steuerung nimmst du **nicht** ein nachgeschaltetes ControlNet, sondern eine control-fähige Variante der Wan-Reihe: **VACE** oder die **Fun-Control**-Linie. Beide gibt es als GGUF-Quantisierungen. Diese Modelle nehmen Control-Video, Referenzbild und Maske nativ entgegen.

> **Budget beachten:** Das Control-Video kostet zusätzliche Latent-Tokens. Ein VACE-Run verträgt bei gleichem Quant weniger Auflösung als ein reiner Text-to-Video-Run.

### 4.2 Zwei Stufen, ein Modell

| Stufe | Setup | Zweck |
|---|---|---|
| **Iteration** | Wan 2.2 **5B**, 480p, 33–49 Frames, 4-Step-Lightning-LoRA | Läuft ab 6–8 GB, auf deiner Karte sehr schnell. Prüfen, ob die Depth-Führung liest und der Prompt zur Kamerafahrt passt. Unter einer Minute pro Test. |
| **Final** | Wan **14B** + VACE/Fun-Control, Q5_K_S, 81 Frames @ 832×480 | Der eigentliche Render. |

Der Grund, beide Stufen aus derselben Modellfamilie zu nehmen: Prompts, LoRAs und Control-Einstellungen sind übertragbar. Bei einem Wechsel zwischen zwei verschiedenen Modellen sagt dir dein Prototyping-Ergebnis nichts über den Final Render, und du fängst beim Tuning bei null an.

### 4.3 Der Graph

```
Load Video  (Depth-Sequenz, 16bit)  ─┐
Load Video  (Edge-Sequenz)          ─┼─→ VACE Control Embeds ─→ WanVideo Sampler ─→ VAE Decode
Load Image  (Charakter-/Style-Ref)  ─┘                              ↑
Load Masks  (Cryptomatte)           ──────────────────────────────  ┘
```

### 4.4 Control Strength richtig setzen

Volle Stärke über die gesamte Laufzeit ist der häufigste Fehler. Das Ergebnis wird steif und behält den Clay-Look, weil das Modell die untexturierte Struktur zu wörtlich nimmt.

```
Depth:  Stärke 0.7 – 0.85
        auslaufen lassen bei ca. 60–70 % der Steps
Edge:   Stärke 0.3 – 0.5, nur Silhouetten
```

Die letzten Steps braucht das Modell frei, um Textur, Material und Licht plausibel aufzubauen.

### 4.5 Layering mit Cryptomatte

Hier hast du einen echten strukturellen Vorteil, den reine Prompt-Pipelines nicht haben. Weil du Masken pro Objekt aus Blender hast, kannst du getrennt generieren:

1. Hintergrund mit voller Depth-Führung generieren
2. Figur separat generieren, eigener Prompt, eigene Referenz, eigenes LoRA
3. Über die Cryptomatte-Alpha zusammensetzen

Vorteil: Du kannst die Figur über mehrere Shots hinweg mit identischer Referenz generieren, während die Umgebung wechselt. Das ist der zuverlässigste Weg zu Charakterkonsistenz in einer lokalen Pipeline.

---

## 5. Teil C — Längere Sequenzen

Ein Durchgang gibt dir rund 5 Sekunden. Für längere Shots: **überlappende Fenster**, also die letzten 8–16 Frames eines Chunks als Konditionierung für den nächsten.

Was dabei hält und was driftet:

| | Verhalten |
|---|---|
| Kamerafahrt, Objektpositionen | **Halten exakt.** Kommen aus Blender, nicht aus dem Modell. |
| Gesichter, Charakterdetails | Driften. Gegenmittel: gleiches Referenzbild + Charakter-LoRA in jedem Chunk. |
| Farbe, Belichtung | Driften. Gegenmittel: fester Seed, Color Matching im Comp. |
| Dramaturgie über mehrere Einstellungen | Musst du selbst planen. Das Modell sieht immer nur den aktuellen Chunk. |

**Praktische Konsequenz:** Denk in Fünf-Sekunden-Einstellungen und schneide wie im Film. Schnitte verstecken Drift, eine durchgehende lange Kamerafahrt legt ihn offen.

---

## 6. Teil D — Post

Reihenfolge ist wichtig:

1. **Frame-Interpolation** (RIFE oder GIMM-VFI): 16 fps → 24 oder 30 fps
2. **Spatial Upscale**: danach

Umgekehrt ist es teurer und liefert schlechtere Ergebnisse, weil du hochauflösende Frames interpolierst statt niedrigauflösende.

3. **Color Matching** über alle Chunks eines Shots
4. **Grade**

---

## 7. Vergleich mit Seedance 2.5

Seedance 2.5 (ByteDance, Juli 2026) hat *clay render referencing* als explizites Produktfeature. Der Vergleich lohnt sich, weil er zeigt, wo die lokale Pipeline gewinnt und wo sie strukturell verliert.

### 7.1 Gegenüberstellung

| | Lokal (Blender + Wan 2.2) | Seedance 2.5 |
|---|---|---|
| Clip-Länge am Stück | ~5 s | 30 s, mit Verlängerung mehrere Minuten |
| Kohärenz über die Länge | Chunk-weise, Drift an Klebestellen | Ein Denoising-Pass, kein Drift möglich |
| Schnitte innerhalb einer Sequenz | Nur manuell, jede Einstellung separat | Modell plant Übergänge und Szenenwechsel selbst |
| Referenzen pro Durchgang | 1–2 Bilder, nicht adressierbar | 30 Bilder, 10 Videos, 10 Audioclips, per `@Image 5` adressierbar |
| Audio | Nicht vorhanden | Synchron, im selben Pass |
| Frame-genaue Masken | **Ja**, Cryptomatte aus 3D | Nein, nur Greenscreen-artige Region-Edits |
| Iterationskosten | Strom | Pro Generierung |
| Datenhoheit | Vollständig lokal | Cloud |
| Reproduzierbarkeit | Seed + Graph = identisches Ergebnis | Eingeschränkt |
| Lizenz | Apache 2.0, kommerziell frei | Plattform-Bedingungen |

### 7.2 Was das praktisch bedeutet

**Die 30 Sekunden am Stück:** Lokal klebst du sechs Häppchen zusammen. An jeder Klebestelle verändert sich das Gesicht ein bisschen und die Farbstimmung verschiebt sich ein bisschen. Nach sechs Stück steht eine leicht andere Person in einem leicht anders beleuchteten Raum. Seedance rechnet alles gemeinsam, da kann nichts driften.

**Die Referenzdichte:** Bei Seedance wirfst du 30 Fotos rein und sagst "dieses Gesicht, dieser Raum, dieses Cello". Das funktioniert, weil das Modell mit einem Adressierungsschema trainiert wurde, das Referenzindizes an Textbeschreibungen bindet. Lokal gibst du ein Referenzbild mit, und das Modell mittelt darüber. Du kannst nicht sagen, welche Referenz wofür gilt.

Der lokale Ersatz ist **Training statt Inferenz**: Identität kommt aus einem LoRA (20–40 Bilder, unter einer Stunde Training pro Figur), Look aus einem Style-LoRA. Für ein Projekt mit wiederkehrenden Figuren ist das sogar konsistenter als Referenzbilder. Für "dreißig Referenzen ad hoc" ist es der falsche Workflow.

### 7.3 Der Hybrid-Weg

Beide Wege nutzen **dasselbe Blender-Setup**. Das ist der entscheidende Punkt: du verlierst nichts, wenn du die 3D-Seite sauber aufbaust, egal wohin du sie schickst.

Sinnvolle Aufteilung:

- **Blockout und Clay Render** → immer in Blender
- **Lange, durchgehende Einstellungen mit Ton** → Seedance (über Jimeng, Doubao Pro; API war über BytePlus ModelArk angekündigt)
- **Iteration, Masken-Arbeit, frame-genaue Eingriffe, alles was oft wiederholt wird** → lokal

---

## 8. Fehlerdiagnose

| Symptom | Ursache | Behebung |
|---|---|---|
| Video "pumpt" in Helligkeit/Tiefe | Depth pro Frame normalisiert | Map Range mit festen Min/Max über den ganzen Shot |
| Terrassen / Stufen im Raum | 8-bit Depth-Export | Auf 16-bit PNG umstellen |
| Drahtgitter-Look | Freestyle mit Crease Edges | Nur Silhouette + Contour |
| Ergebnis bleibt clay-artig, steif | Control Strength zu hoch / zu lang | Auf 0.7–0.85, bei 60–70 % der Steps auslaufen lassen |
| Zittern über Frames | Depth-Estimator statt Z-Pass | AOVs aus Blender exportieren |
| Figur wirkt zu groß/klein für den Raum | Szene nicht in realen Maßstäben | Blender-Units auf Meter, Figur 1,75 m |
| Gesicht wechselt zwischen Chunks | Nur Frame-Chaining | Referenzbild + Charakter-LoRA in jedem Chunk |
| CUDA OOM beim Modellladen | Bekanntes Problem auf 16-GB-Karten | ComfyUI mit `--disable-pinned-memory` starten |
| Sehr langsam trotz passendem Quant | Kein SageAttention, zu wenig System-RAM | SageAttention installieren, 64 GB RAM |

---

## 9. Checkliste vor dem ersten Final Render

**Blender**
- [ ] Szene in Metern, Figuren 1,75 m
- [ ] Kamera mit realer Brennweite + Sensorgröße
- [ ] Blockout-Licht gesetzt
- [ ] 16 fps, Framezahl 4n+1 (81 für 5 s)
- [ ] Map Range mit festen Min/Max über gesamten Kamerapfad
- [ ] Freestyle nur Silhouette + Contour
- [ ] Export als 16-bit PNG-Sequenz, ein Ordner pro Pass
- [ ] Cryptomatte für alle Objekte, die getrennt behandelt werden sollen

**ComfyUI**
- [ ] SageAttention installiert
- [ ] Q5_K_S GGUF für HighNoise und LowNoise
- [ ] Control Strength 0.7–0.85, Auslauf bei 60–70 %
- [ ] Erst mit 5B bei 480p testen, dann 14B final
- [ ] Fester Seed über alle Chunks eines Shots

**Post**
- [ ] Interpolation vor Upscale
- [ ] Color Matching über Chunk-Grenzen

---

## 10. Alternative Frontends

**Wan2GP** ist ein Frontend, das explizit für knappen VRAM gebaut ist und Wan 2.1/2.2, LTX-2 und Hunyuan abdeckt. Weniger flexibel als ein eigener ComfyUI-Graph, aber deutlich weniger Fummelei bei den Offloading-Einstellungen. Guter Einstieg, wenn die Modellseite erstmal laufen soll, bevor du die Control-Kette baust.

---

## Quellen

- ByteDance Seed: *One-take Creation, Flexible Referencing: Introducing Seedance 2.5*, 31.07.2026
- ComfyUI Docs: Wan VACE Video Examples
- Wan 2.2 auf Hugging Face (Apache 2.0)
- Community-Benchmarks zu Wan 2.2 GGUF auf 16-GB-Karten
