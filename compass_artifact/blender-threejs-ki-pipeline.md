# Blender-Clay-Szene → Three.js mit KI

**Learning-Dokument, Stand September 2026**
Companion zu *Blender → ComfyUI: Strukturgeführte Videogenerierung*

---

## 1. Abgrenzung: warum das eine andere Pipeline ist

Bei der Video-Pipeline ist das Endprodukt ein Bildstrom. Die KI darf dort alles erfinden, weil nichts davon später angefasst wird.

Three.js braucht echte Assets: Meshes mit Topologie, UV-Koordinaten, PBR-Texturen, Lichter, Kollisionsgeometrie. **Es gibt kein KI-Werkzeug, das dir aus einer Clay-Szene ein fertiges Three.js-Projekt macht.** Wer das verspricht, meint entweder ein einzelnes Objekt oder ein Gaussian Splat.

Was bleibt, ist dasselbe Grundprinzip wie bei der Video-Kette:

> Layout, Maßstab, Proportionen und Kamera bleiben deine 3D-Wahrheit aus Blender. Die KI liefert die Oberfläche.

Der Unterschied: Bei Video liefert sie die Oberfläche als Pixel, hier als Textur-Maps.

---

## 2. Was Three.js von dir verlangt

Diesen Abschnitt zuerst lesen, nicht zuletzt. Er begrenzt alle vier Wege, und KI-generierte Assets verletzen praktisch jeden dieser Werte im Auslieferungszustand.

| Aspekt | Zielwert | Warum |
|---|---|---|
| Format | glTF 2.0 / GLB | Einziges Format mit brauchbarem PBR-Support im Web |
| Mesh-Kompression | Draco **oder** Meshopt | Meshopt dekodiert deutlich schneller, Draco komprimiert etwas stärker |
| Texturformat | **KTX2 / Basis Universal** | GPU-komprimiert. Spart nicht nur Download, sondern Videospeicher. PNG/JPG werden auf der GPU voll entpackt. |
| Texturgröße | 1K–2K | 4K und 8K sind für Film und Print |
| Polycount gesamt | ~100k–500k Dreiecke | Abhängig von Zielgerät |
| Draw Calls | unter ~100 | Materialien zusammenfassen, Geometrie mergen |
| Gesamtgröße | unter 10 MB für Mobile | Realistischer Wert, kein Ideal |

**Typischer Auslieferungszustand eines KI-generierten Assets:** 200.000 Dreiecke pro Objekt, 4K-PNG-Texturen, keine sinnvollen UVs. Der Aufräumschritt ist kein optionales Extra, er ist Teil der Pipeline.

---

## 3. Die vier Wege im Überblick

| Weg | Was die KI macht | Geometrie | Licht | Editierbar | Eignung |
|---|---|---|---|---|---|
| **A** Texturing | Materialien auf deine Meshes | Deine, exakt | Dynamisch möglich | Voll | Standardfall |
| **B** Rückprojektion | Look aus ComfyUI auf Geometrie backen | Deine, exakt | Eingebacken | Teilweise | Stilisierte Looks |
| **C** Asset-Generierung | Erzeugt neue Meshes | KI-generiert | Dynamisch möglich | Nach Cleanup | Props, Deko |
| **D** Gaussian Splatting | Erzeugt die ganze Szene als Splat | Keine im klassischen Sinn | Eingebacken | Nein | Feste Perspektiven |

---

## 4. Weg A — Geometrie behalten, KI texturiert

Der Standardweg. Deine Clay-Geometrie *ist* schon die Szene, ihr fehlen nur Materialien.

### 4.1 Wie die Modelle arbeiten

Moderne Texturing-Modelle sind geometrie-konditioniert. Ein 2D-Diffusionsmodell wird zu einem Multi-View-Generator erweitert, der das Mesh kennt, und die erzeugten Ansichten werden per View-Projection in hochauflösende Texture Maps gebacken. Das Modell sieht also deine Geometrie, nicht nur ein Bild davon.

Zwei Probleme werden dabei systematisch adressiert: Konsistenz zwischen den Ansichten, und die Erweiterung von reinen RGB-Texturen auf vollständige PBR-Material-Sets.

Das ist der Grund, warum diese Werkzeuge besser funktionieren als selbstgebaute Projektions-Workflows (siehe Weg B).

### 4.2 Werkzeuge

| Werkzeug | Typ | Hinweis |
|---|---|---|
| Hunyuan3D | Open Source, lokal | Tencent. Text- **oder** Bildprompt, nicht beides gleichzeitig |
| Meshy | Cloud | Multiview-Diffusion-Texturing, bis 8K Base Color, gute UV-Behandlung, kann bestehende UVs erhalten |
| Trellis 2 | Cloud/Open | Auch als Image-to-3D, mit Remesh und Decimation |
| Tripo | Cloud | |
| 3D AI Studio | Cloud, Aggregator | Bündelt mehrere Engines, hat ein eigenes UV-Unfold-Tool |

Alle exportieren PBR-Sets (Base Color, Roughness, Metalness, Normal) als glTF-Material im GLB.

### 4.3 Schritte

**1. Geometrie aufräumen (Blender)**
- Manifold prüfen (`Mesh → Clean Up → Merge by Distance`, dann 3D-Print-Toolbox)
- Normalen neu berechnen (`Shift+N`)
- Objekte trennen, die unterschiedliche Materialien bekommen sollen
- Nicht-sichtbare Geometrie löschen (Rückseiten, Innenräume)

**2. UV-Unwrap**
- Smart UV Project reicht für einfache Formen
- UVPackmaster für dichtere Packung
- Seams manuell setzen, wo die Form es verlangt
- Texel Density über alle Objekte angleichen, sonst sind manche Oberflächen sichtbar unschärfer als andere

> Ohne saubere UVs wird das Texturing unbrauchbar. Manche Dienste unwrappen automatisch, aber das Ergebnis ist schlechter als ein bewusst gesetztes Layout.

**3. Objekt für Objekt texturieren**
- Prompt oder Referenzbild pro Objekt
- PBR aktivieren
- Auflösung 2K, nicht höher
- Vorhandene UVs erhalten lassen, wo die Option existiert

**4. Zurück in Blender**
- GLB importieren oder Maps manuell zuweisen
- Szene zusammensetzen, Materialien vereinheitlichen wo möglich
- Materialien zusammenfassen reduziert Draw Calls in Three.js

**5. Beleuchtung**
- Entweder dynamisch in Three.js (wenige Lichter, Environment Map)
- Oder in Cycles backen (siehe Kapitel 8)

**6. Export** (siehe Kapitel 9)

### 4.4 Bewertung

**Stärke:** Topologie bleibt exakt so, wie du sie gebaut hast. Alles bleibt editierbar. Funktioniert mit dynamischer Beleuchtung.
**Schwäche:** Objektweise Arbeit. Bei 40 Props sind das 40 Durchläufe plus Cleanup.

---

## 5. Weg B — Den ComfyUI-Look zurückprojizieren

Hier verbindest du beide Pipelines: Du nutzt das generierte Video-Bild als Texturquelle.

### 5.1 Schritte

1. Orthografische Renders aus 6–12 Winkeln um Objekt oder Szene
2. Jeden Render mit Depth-ControlNet umstylen. **Gleicher Seed, gleiche Referenz, gleicher Prompt** über alle Ansichten
3. In Blender per *Project from View* auf die Geometrie projizieren
4. Auf die UV-Map backen
5. Nähte und Überlappungen im Texture Paint Mode übermalen
6. Export

### 5.2 Bewertung

**Stärke:** Du bekommst exakt den Look, den du im Video schon abgenommen hast. Kein zweiter Look-Development-Zyklus.

**Schwäche:** Die Ansichten driften gegeneinander, weil jede einzeln generiert wird. Genau dieses Problem haben dedizierte Texturing-Modelle intern gelöst, du löst es hier von Hand. Außerdem ist das Licht in die Textur eingebrannt, dynamische Beleuchtung fällt weg.

**Verdikt:** Für stilisierte, flächige Looks gut. Für Fotorealismus mühsam. Als Ergänzung zu Weg A sinnvoll, wenn ein einzelnes Hero-Objekt exakt aussehen muss wie im Video.

---

## 6. Weg C — Proxies durch KI-Geometrie ersetzen

Deine Clay-Quader sind Platzhalter. Du generierst echte Assets und setzt sie an die Transform-Werte der Platzhalter.

### 6.1 Schritte

1. Pro Proxy einen Prompt oder ein Referenzbild vorbereiten
2. Image-to-3D oder Text-to-3D generieren
3. Blender: Asset importieren, an Position, Rotation und Scale des Proxies snappen
4. **Remesh oder Decimate** auf das Web-Budget
5. Neu unwrappen, falls das Remesh die UVs zerstört hat
6. Texturen neu backen (High-Poly → Low-Poly)

### 6.2 Werkzeuge

Hunyuan3D, Trellis 2, Meshy, Tripo, Rodin. Die meisten bieten Text-to-3D, Single-Image-to-3D und Multi-Image-to-3D (mehrere Ansichten desselben Objekts oder Kombination von Merkmalen).

Trellis 2 macht aus einem einzelnen Referenzbild ein texturiertes GLB und bringt Decimation-Target- und Remesh-Optionen direkt mit. Nützliche Parameter über die Werkzeuge hinweg: Face Limit, Geometry Quality, Quad Mesh, Texture Size.

### 6.3 Bewertung

**Stärke:** Sehr schnell für Props, Möbel, Deko, Vegetation.
**Schwäche:** Topologie ist meist Marching-Cubes-Ergebnis, also gleichmäßig dichtes Dreiecksnetz ohne Edge Loops. Für Architektur, Räume und Layout ungeeignet, dafür ist deine Blender-Geometrie in jeder Hinsicht besser.

**Faustregel:** Alles, was der Nutzer betreten oder umlaufen kann, baust du selbst. Alles, was darin herumsteht, kann von der KI kommen.

---

## 7. Weg D — Gaussian Splatting

Der einzige Weg, bei dem der KI-Look tatsächlich zu einer 3D-Repräsentation wird.

### 7.1 Schritte

1. **Langsame** Orbit-Kamerafahrt in Blender um die Szene
2. Mit der Depth-geführten ComfyUI-Kette generieren
3. Frames als Bilddatensatz für 3D-Gaussian-Splatting-Rekonstruktion
4. In Three.js über einen Splat-Loader rendern

### 7.2 Der entscheidende Trick

Splatting aus generiertem Video scheitert normalerweise daran, dass COLMAP die Kameraposen aus den Frames nicht sauber rekonstruieren kann. Generierte Bilder haben keine echte Parallaxe-Konsistenz, das Structure-from-Motion bricht zusammen.

**Du hast die Posen aber exakt.** Sie kommen aus Blender. Intrinsics (Brennweite, Sensor, Auflösung) und Extrinsics (Position, Rotation pro Frame) kannst du direkt exportieren und die Rekonstruktion mit bekannten Kameras starten. COLMAP entfällt komplett.

Das ist der Punkt, der diesen Weg von "funktioniert selten" zu "funktioniert zuverlässig" hebt, und er ergibt sich direkt daraus, dass du mit einer 3D-Szene startest statt mit Footage.

### 7.3 Bewertung

**Stärke:** Fotorealistisch, günstig zu rendern, beeindruckend.
**Schwäche:** Nicht editierbar. Kein dynamisches Licht. Keine Kollisionsgeometrie, also keine echte Interaktion. Große Dateien. Und die generierten Frames müssen multiview-konsistent sein — langsame Orbits mit starker Depth-Führung funktionieren, schnelle Fahrten und Schnitte nicht.

---

## 8. Der Produktions-Hybrid

Was die meisten echten Web-Projekte tatsächlich machen:

| Element | Herkunft |
|---|---|
| Geometrie | Blender, sauber und niedrig aufgelöst |
| Materialien | Weg A |
| Beleuchtung | In Cycles gerechnet, in **Lightmaps gebacken** |
| Environment | KI-generiertes 360°-HDRI (Skybox AI, oder SD-Panorama mit ControlNet) |
| Dynamische Lichter | Nur die wenigen, die sich wirklich bewegen |

Gebackenes Cycles-Licht sieht besser aus als alles, was Three.js in Echtzeit rechnen kann, und kostet zur Laufzeit fast nichts. Das ist der größte einzelne Qualitätshebel im Web-3D, und er hat mit KI nichts zu tun.

**Lightmap-Workflow in Kürze:**
1. Zweiter UV-Kanal, nicht-überlappend (`Lightmap Pack` oder UVPackmaster im Lightmap-Modus)
2. Cycles-Bake auf `Combined` oder `Diffuse → Indirect`
3. Lightmap als zweite Textur exportieren
4. In Three.js über `material.lightMap` und `geometry.attributes.uv1` zuweisen

---

## 9. Export und Optimierung

### 9.1 Blender-Export

- Format: **glTF 2.0 (.glb)**
- `Include → Selected Objects` wenn du in Teilen exportierst
- `Transform → +Y Up` aktiviert lassen (Three.js-Konvention)
- `Geometry → Apply Modifiers`, UVs, Normals
- `Compression` in Blender kann Draco, ist aber weniger flexibel als der nachgelagerte CLI-Schritt

### 9.2 Optimierung mit gltf-transform

Der Blender-Export ist nie die finale Datei. Nachbearbeitung mit `gltf-transform` (npm):

```bash
# Alles auf einmal
gltf-transform optimize in.glb out.glb \
  --compress meshopt \
  --texture-compress ktx2

# Oder einzeln, mit mehr Kontrolle
gltf-transform dedup       in.glb  a.glb   # doppelte Meshes/Materialien
gltf-transform prune       a.glb   b.glb   # ungenutzte Daten
gltf-transform resize      b.glb   c.glb --width 2048 --height 2048
gltf-transform uastc       c.glb   d.glb   # KTX2, hohe Qualität (Normal Maps)
gltf-transform etc1s       d.glb   e.glb   # KTX2, kleiner (Base Color)
gltf-transform meshopt     e.glb   out.glb
gltf-transform inspect     out.glb          # Kontrolle
```

Flags ändern sich zwischen Versionen, `gltf-transform --help` prüfen.

**Faustregel zu KTX2:** ETC1S für Base Color (klein), UASTC für Normal und Roughness (verlustärmer, Kompressionsartefakte fallen dort stärker auf).

### 9.3 Three.js-Ladeseite

```js
import { GLTFLoader }   from 'three/addons/loaders/GLTFLoader.js';
import { KTX2Loader }   from 'three/addons/loaders/KTX2Loader.js';
import { MeshoptDecoder } from 'three/addons/libs/meshopt_decoder.module.js';

const ktx2 = new KTX2Loader()
  .setTranscoderPath('/basis/')      // aus three/examples/jsm/libs/basis/
  .detectSupport(renderer);          // renderer muss existieren

const loader = new GLTFLoader();
loader.setKTX2Loader(ktx2);
loader.setMeshoptDecoder(MeshoptDecoder);

loader.load('/scene.glb', (gltf) => {
  scene.add(gltf.scene);
});
```

Bei Draco statt Meshopt stattdessen `DRACOLoader` mit `setDecoderPath('/draco/')` und `loader.setDRACOLoader(draco)`. Beides zusammen brauchst du nicht.

Nicht vergessen: `renderer.outputColorSpace = THREE.SRGBColorSpace` und eine Environment Map, sonst sehen PBR-Materialien flach und dunkel aus.

---

## 10. Fehlerdiagnose

| Symptom | Ursache | Behebung |
|---|---|---|
| Textur sieht auf manchen Flächen unschärfer aus | Ungleiche Texel Density | UVs mit einheitlicher Dichte packen |
| Sichtbare Nähte im Material | UV-Seams an ungünstiger Stelle | Seams verlegen, oder im Texture Paint übermalen |
| Modell ist schwarz in Three.js | Keine Environment Map, oder falscher Color Space | `scene.environment` setzen, `SRGBColorSpace` |
| Modell ist winzig oder riesig | Blender-Units nicht angewendet | Scale applyen (`Ctrl+A`) vor dem Export |
| Normal Map sieht invertiert aus | Green-Channel-Konvention (DirectX vs OpenGL) | Grünkanal invertieren, glTF erwartet OpenGL |
| Datei viel zu groß | PNG-Texturen im GLB | KTX2 |
| Ruckelt trotz kleiner Datei | Zu viele Draw Calls | Materialien zusammenfassen, Meshes mergen |
| KI-Asset hat kaputte UVs nach Remesh | Remesh zerstört UV-Layout | Nach Remesh neu unwrappen und High→Low backen |
| Splat ist matschig | Generierte Frames nicht multiview-konsistent | Langsamere Orbit, stärkere Depth-Führung, fester Seed |

---

## 11. Checkliste vor dem Deploy

**Geometrie**
- [ ] Scale und Rotation applyed
- [ ] Manifold, keine doppelten Vertices
- [ ] Nicht-sichtbare Geometrie gelöscht
- [ ] Polycount im Budget

**UVs**
- [ ] Kein Overlap (außer bewusst)
- [ ] Einheitliche Texel Density
- [ ] Zweiter UV-Kanal für Lightmaps, falls verwendet

**Material**
- [ ] PBR-Set vollständig
- [ ] Normal Map in OpenGL-Konvention
- [ ] Texturen auf 2K reduziert
- [ ] Materialanzahl minimiert

**Export**
- [ ] GLB, +Y Up
- [ ] Meshopt oder Draco
- [ ] KTX2 (ETC1S für Color, UASTC für Normal/Roughness)
- [ ] `gltf-transform inspect` geprüft
- [ ] Gesamtgröße unter Zielwert

---

## 12. Entscheidungsbaum

- **Interaktive Szene, freie Bewegung** → Weg A, plus gebackene Lightmaps
- **Produktkonfigurator, einzelne Objekte** → Weg C für Assets, Weg A für Materialien
- **Stilisierter Look, den du im Video entwickelt hast** → Weg B für Hero-Objekte, Weg A für den Rest
- **Fotorealistischer Raum, feste Perspektiven, keine Interaktion** → Weg D
- **Prototyp bis morgen** → Weg C für alles, Cleanup später

---

## Quellen

- Hunyuan3D Studio / Hunyuan3D 2.x, Tencent (Multi-View-PBR-Texturing, geometrie-konditioniert)
- Trellis 2 (Structured 3D Latents), Meshy v6, Tripo, Hyper3D Rodin
- Meshy: PBR-Texturing-Guide 2026
- three.js Dokumentation: GLTFLoader, KTX2Loader, Meshopt
- glTF-Transform CLI
