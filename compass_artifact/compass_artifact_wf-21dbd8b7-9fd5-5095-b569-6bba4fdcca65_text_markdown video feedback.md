# Video-Feedback zwischen Beamer und Kurokesu C3: Mechanismen, Filter, Algorithmen und Praxis

Eine Beamer-Kamera-Schleife mit der Kurokesu C3 ist ein diskretes, räumlich gekoppeltes dynamisches System: Jeder Umlauf wendet eine Abbildung I(n+1) = T(I(n)) auf das ganze Bild an. Welche Muster entstehen, bestimmen fast nur drei Dinge, nämlich die Schleifenverstärkung (Gain), der räumliche Frequenzgang (Blur/Sharpen/DoG) und die Geometrie (Zoom/Rotation). Farbraum-Tricks, Keys und zeitliche Filter formen dann aus, wie diese Dynamik aussieht. Der wichtigste praktische Schritt ist deshalb, alle Automatiken der Kamera abzuschalten (Belichtung, Weißabgleich, Gain, Schärfe, HDR/WDR). So wird die Kamera zu einem vorhersagbaren, linearen Glied, und die gesamte Nichtlinearität liegt kontrolliert in der eigenen Software.

## TL;DR

- **Hardware:** Für DLP-Beamer eignet sich die C3-234 (onsemi AR0234, Global Shutter, laut Kurokesu 2 MP @ 60 fps) am besten. Die C3-462 (Sony IMX462, 2,9 µm Pixel, 60 fps MJPEG) ist die lichtstarke Alternative mit Rolling Shutter. Die C3-415 (4K, nur 30 fps) ist für Feedback meist zu langsam. Man sollte immer MJPEG über USB 2.0 nutzen, alle Automatiken per UVC/v4l2 abschalten und die Belichtungszeit auf ein ganzzahliges Vielfaches der Beamer-Bildperiode legen.
- **Mechanismen:** Die Schleife verhält sich wie Crutchfields Modell I(n+1) = L·I(n) + Diffusion + s·f·I(n)(b·R·x). Liegt die Gesamtverstärkung unter 1, klingt das Bild ab. Liegt sie über 1, wächst es, bis Clipping oder Sensorsättigung es begrenzen, und genau dort entstehen Muster. Blur plus Sharpen bzw. Difference of Gaussians wirkt als Bandpass und erzeugt Turing-/Reaction-Diffusion-Muster. Hue-Rotation pro Frame ergibt Farbzyklen, Luma-/Chroma-Keys wirken als Masken, die nur Teile des Bildes zurückführen.
- **Umsetzung:** In Software reicht eine Kette aus Kamera → Homographie-Entzerrung → Farb-/Filterstufe → Mischung mit dem letzten Frame → Beamer. Das geht mit dem Feedback TOP in TouchDesigner, jit.gl.pix/jit.gl.slab in Max, src(o0) in Hydra, Waaave Pool auf dem Raspberry Pi oder Python/OpenCV. Die Parameter werden per MIDI/OSC gesteuert. Analoge Alternativen sind LZX-Module (z. B. der FKG3-Keyer), Video-Mischer und Colorizer in der Tradition des Sandin Image Processor.

## Key Findings

1. **Die C3 ist eine Familie, kein einzelnes Modell.** Die drei Sensoren unterscheiden sich stark: IMX415 mit 3840×2160, 1,45 µm Pixeln, Rolling Shutter und „MJPG – 30fps in all modes“. IMX462 mit 1920×1080, 2,9 µm, Rolling Shutter und „MJPG – 60fps in all modes“. AR0234 als Global-Shutter-Sensor, laut Features-Seite mit 60 fps. Alle hängen an USB 2.0 High-Speed (480 Mb/s) mit MJPEG- und YUY2-Streams.\[1\]\[2\]\[3\] Unkomprimiertes YUY2 schafft über USB 2.0 volle Bildraten nur bei kleinen Auflösungen.
2. **Die C3 bietet alle nötigen UVC-Steuerungen.** Dazu gehören Belichtung, Gain, Weißabgleich (2000–10000 K), Gamma, Backlight Compensation, Anti-Flicker, HDR/WDR, ROI und digitaler Zoom/Pan/Tilt. Die letzten Einstellungen speichert ein On-Board-EEPROM.\[2\]\[3\] Einen offiziellen Latenzwert nennt Kurokesu nicht, man muss ihn selbst messen.
3. **Crutchfield (Physica D 10, 1984) liefert das passende Modell.** Er beschreibt Video-Feedback als dissipatives dynamisches System mit Fixpunkt-, Grenzzyklus- und chaotischen Attraktoren. Der Fokus wirkt als Gauß-Diffusion, Zoom und Rotation als nichtlokale Kopplung. Farbkopplungen werden über Matrizen modelliert.\[4\]
4. **Blur + Unsharp Mask in der Schleife ist mathematisch ein Reaction-Diffusion-System.** Das zeigt Andrew Werth (Bridges 2015). Blur wirkt als Diffusion, Schärfen als Selbstverstärkung mit langreichweitiger Hemmung. Blurrt man zu stark, „diffundiert das System zu Grau“.\[5\]\[6\]
5. **Pixelraster erzeugen eigene Fraktale.** Courtial, Leach und Padgett (Universität Glasgow, Nature 414, S. 864, Dezember 2001) zeigten, dass Feedback mit pixelbasierten Monitoren „stationary fractal patterns such as von-Koch snowflakes and Sierpinski gaskets“ erzeugen kann. Die ausführliche Fassung in Contemporary Physics 44(2), 137–143 (2003) führt als entscheidenden, „previously unidentified parameter“ die Lage des Zoom-Zentrums relativ zu den einzelnen Pixeln ein. Beim Beamer spielen Projektorpixel, Sensorpixel und Moiré dieselbe Rolle.
6. **DLP-Beamer mit Farbrad zeigen Farben nacheinander.** Eine Rolling-Shutter-Kamera nimmt deshalb horizontale Farbbänder auf, die von Frame zu Frame wandern, weil jede Sensorzeile zu einem anderen Zeitpunkt belichtet.\[7\] In der Schleife werden diese Bänder verstärkt. Abhilfe schaffen lange, synchrone Belichtungszeiten, ein Global Shutter oder ein LCD-/3-Chip-Beamer.

## Details

### 1. Kurokesu C3: Eckdaten und was davon für Feedback zählt

| Merkmal | C3-415 (IMX415) | C3-462 (IMX462) | C3-234 (AR0234) |
|---|---|---|---|
| Auflösung | 3840×2160 (8 MP) | 1920×1080 (2 MP) | 2 MP; Sensor nativ 1920×1200 laut onsemi, die Wiki-Vorschau nennt 1920×1080 |
| Pixelgröße | 1,45 µm | 2,9 µm | 3,0 µm (onsemi AR0234CS, 1/2,6″; der Sensor schafft bei voller Auflösung bis zu 120 fps, die 60 fps der C3 begrenzen also Kamera bzw. USB 2.0) |
| Shutter | Electronic Rolling Shutter | Electronic Rolling Shutter | Global Shutter |
| Bildrate | MJPG 30 fps in allen Modi | MJPG 60 fps in allen Modi | 60 fps (Features-Seite); ältere Angabe 1080p@30 |
| Farbe | RGB | RGB oder Mono | RGB |
| Filter | IR-Cut, NF (ohne), NIR1 (850 nm LP) | dito | dito |

Gemeinsam haben alle Varianten: USB-C mit UVC, „High-Speed 480Mb/s, MJPEG & YUY2 streams“, unter 2 W aus 5 V USB, ein Boxgehäuse von 33×33×24,5 mm und 36 g sowie native CS-Mount-Aufnahme (C-Mount über einen 5-mm-Spacer) oder M12/M12L auf Board-Level.\[3\]\[8\] Zu den Objektiven gehören bei Kurokesu unter anderem ein 2,8–12 mm CS-Varifokal mit 130,5° bis 39,14° diagonal, ein 10–55 mm C-Mount-Zoom mit ≤ −0,1 % TV-Verzerrung und ein 12–36 mm C-Zoom mit 10 cm Naheinstellgrenze. Alle haben manuelle Iris, manuellen Fokus und manuellen Zoom.\[9\]

**Widersprüche in den Quellen:** Für die C3-234 nennt die Features-Seite 60 fps, eine ältere Blog-Meldung 1080p@30 fps. Für die IMX415 zeigt eine Shop-Seite „60 fps“, das Wiki dagegen 30 fps.\[2\]\[3\]\[9\]\[10\] Der Wiki-Wert ist technisch plausibler. Ich empfehle, vor dem Kauf `v4l2-ctl --list-formats-ext` am konkreten Gerät zu prüfen oder beim Hersteller nachzufragen.

**Was davon für Feedback relevant ist:**

- **Automatiken abschalten.** Auto-Exposure und Auto-White-Balance bilden eine *zweite, langsame Regelschleife* innerhalb der optischen Schleife. Diese Regelung kämpft gegen jede Helligkeitsdynamik: Sie dunkelt ab, sobald das Feedback aufblüht, und hellt auf, sobald es verlischt. So entstehen träge „Atem“-Oszillationen, und die Belichtungssprünge wirken wie Grenzzyklen, die man nicht kontrollieren kann. Außerdem abschalten sollte man die kamerainterne Schärfung (ein unkontrollierter Hochpass in der Schleife), Backlight Compensation und HDR/WDR, weil beide nichtlineare, bildabhängige Tonkurven sind. Gamma stellt man auf neutral.
- **Beispiel mit v4l2-ctl (Linux).** Die Control-Namen stammen aus Kurokesus V4L2-Rezept. Die dort gezeigte Liste stammt von einer C2-Kamera,\[11\] deshalb vorher mit `v4l2-ctl --list-ctrls` an der eigenen C3 prüfen:
  ```
  v4l2-ctl -d /dev/video0 -c exposure_auto=1            # 1 = Manual Mode
  v4l2-ctl -d /dev/video0 -c exposure_absolute=167      # UVC-Einheit 100 µs → ≈16,7 ms
  v4l2-ctl -d /dev/video0 -c white_balance_temperature_auto=0 -c white_balance_temperature=6500
  v4l2-ctl -d /dev/video0 -c gain=0 -c gamma=100 -c sharpness=0 -c backlight_compensation=0
  v4l2-ctl -d /dev/video0 -c power_line_frequency=0     # Anti-Flicker aus, wenn Belichtung manuell
  ```
  Beim C2-Beispiel reichen die Werte so: exposure_absolute 1–10000 (Default 156), gain 0–63, gamma 72–500, WB 2800–10000 K.\[11\] Dass die Einheit 100 µs ist, folgt aus der UVC-Norm und ist nicht Kurokesu-spezifisch dokumentiert.\[12\]
- **Mit OpenCV** (Backend V4L2) steht `CAP_PROP_AUTO_EXPOSURE = 0.25` für „manual exposure“, `0.75` für Auto. Das verhält sich je nach Version unzuverlässig. Robuster ist es, v4l2-ctl *nach* dem Öffnen der Capture aufzurufen, weil OpenCV sonst Einstellungen überschreibt.\[12\]\[13\]\[14\]
- **Latenz.** Kurokesu nennt keinen Wert. Die Schleifenlatenz setzt sich zusammen aus Belichtung, Sensor-Readout, MJPEG-Encode in der Kamera, USB-Transfer, Decode, eigener Verarbeitung, GPU-Present und dem Input-Lag des Beamers. Nach meiner Einschätzung, nicht gemessen, sind bei 60 fps insgesamt etwa 3–6 Frames realistisch. Diese Verzögerung ist kein Fehler, sondern Teil der Dynamik: Sie bestimmt Periode und Geschwindigkeit von Oszillationen und Spiralen.\[15\] Die Pufferung sollte man trotzdem minimieren, etwa mit MJPEG statt H.264, `CAP_PROP_BUFFERSIZE=1`, VSync bewusst gesetzt und dem „Game Mode“ des Beamers.\[16\]\[17\]
- **Rolling Shutter und DLP-Farbrad.** Ein Ein-Chip-DLP färbt weißes Licht zeitlich nacheinander über das Farbrad ein. Eine Rolling-Shutter-Kamera belichtet jede Zeile zu einem anderen Zeitpunkt und sieht deshalb rote, grüne und blaue Bänder, deren Lage von der Farbrad-Drehzahl und der Belichtungsverschiebung abhängt.\[7\]\[18\] Eine Canon/Casio-Patentschrift zum Abfotografieren von DLP-Bildern empfiehlt, die Belichtung deutlich länger als die Farbradperiode zu wählen, etwa 1/15 oder 1/30 s, damit sich die Farbsegmente ausmitteln.\[19\] Für die Schleife heißt das:
  - (a) Belichtung = k × Beamer-Frameperiode, also 16,7 ms oder 33,3 ms bei 60 Hz;
  - (b) Iris zu oder ND-Filter, um trotz langer Belichtung nicht zu clippen;
  - (c) am besten die C3-234 mit Global Shutter, weil sie keine zeilenweise Zeitverschiebung hat;
  - (d) alternativ ein LCD-, 3-Chip- oder LCoS-Beamer ohne Farbrad.
  Die Bänder lassen sich aber auch als *Musterquelle* nutzen: Leicht asynchrone Belichtung ergibt langsam wandernde Farbstreifen, die das Feedback aufgreift.
- **Mono-Variante.** Die C3-462M hat laut Kurokesu „better light sensitivity“.\[1\] Für rein luminanzbasiertes Feedback, das man später in Software einfärbt (Colorizer-Ansatz), ist sie eine interessante Wahl. Die NIR- und NF-Varianten erlauben Feedback mit IR-Anteilen, etwa bei Lampen-Beamern.

### 2. Das Grundmodell: Feedback als dynamisches System

Crutchfields Kernmodell für monochromes Feedback ist:

```
I(n+1)(x) = L·I(n)(x) + L'·(G_σ * I(n))(x) + s·f·I(n)(b·R_φ·x)
```

- L ist das Nachleuchten bzw. der Speicher (beim Vidicon vom Photoleiter dominiert).\[4\]
- G_σ ist eine Gauß-Diffusion, deren Breite der **Fokus** steuert.\[4\]
- s = ±1 steht für Luminanz-Inversion.\[4\]
- f ∈ [0,1] ist die **Blende**.\[4\]
- b ist der **Zoom**, R_φ die **Rotation** zwischen Kamera- und Monitorraster.\[4\]

Für Farbe werden L und L' zu Matrizen: Die Diagonale steuert den Abfall pro Kanal, die Nebendiagonalen das Übersprechen zwischen den Farben. Das kontinuierliche Gegenstück ist eine Reaction-Diffusion-Gleichung dI/dt = L·I + s·f·I(bRx) + a·∇²I. Ihr Unterschied zu Turings Modellen ist die *nichtlokale* Kopplung durch Rotation und Zoom.\[4\]

**Stabilität und Gain.** Als Faustregel für eine lineare Analyse, die ich aus dem Modell ableite: Für eine räumliche Frequenz k gilt ungefähr H(k) = g · K̂(k). Dabei ist g die gesamte Schleifenverstärkung aus Beamerhelligkeit × Reflexion × Blende × Belichtung × Software-Gain, und K̂ der Frequenzgang aller räumlichen Filter.
- |H(k)| < 1 für alle k: Jede Störung klingt ab. Das Bild wird schwarz bzw. konvergiert gegen einen Fixpunkt, etwa den „Tunnel“ aus Bildern im Bild.
- |H(k)| > 1 für ein Frequenzband: Diese Moden wachsen exponentiell, bis **Clipping** (8-Bit-Sättigung, Sensorsättigung, Beamer-Maximum) oder ein Soft-Limiter sie begrenzt. Diese Nichtlinearität wählt Muster aus und stabilisiert sie. Das ist die Zone, in der Streifen, Flecken, Spiralen und Chaos entstehen.
- Gain knapp über 1 ist der interessanteste Bereich. Nahe den Bifurkationen treten lange, verschlungene Übergangsphasen auf. Crutchfield empfiehlt ausdrücklich, mit einem Finger zwischen Kamera und Schirm zu stören, um nahe Komplexität sichtbar zu machen.\[4\]

Crutchfields Attraktortypen lassen sich direkt beobachten:
- Standbild als Fixpunkt;
- periodisch wiederkehrende Bildfolgen als Grenzzyklus;
- aperiodische Bildfolgen als chaotischer Attraktor;
- Lichtausbrüche zu zufälligen Zeitpunkten bei großem Zoom, weil dort Rauschen exponentiell verstärkt wird. Er nennt das „limit cycle with noise-modulated stability“.\[4\]

Bei Zoom deutlich unter 1 entsteht die unendliche Regression aus Bildern im Bild. Kommt etwas Rotation hinzu, windet sie sich zur logarithmischen Spirale. Ist das Bild nach einer Störung dunkel geblieben, braucht es oft einen Lichtimpuls von außen, etwa eine Taschenlampe, um zum Attraktor zurückzukehren.\[4\]

**Nichtlinearitäten gezielt einsetzen.** Neben dem harten Clipping lohnen sich:
- ein weicher Limiter y = tanh(g·x) oder x/(1+x);
- eine S-Kurve (Kontrast);
- Solarisation;
- eine Logistik-Abbildung pro Pixel, y = r·x·(1−x), die zusammen mit Blur ein „Coupled Map Lattice“ bildet. Crutchfield verweist selbst auf Logistic- und Circle-Lattices.

### 3. Feedback im Farbraum

**3.1 RGB-Kanal-Feedback**

- *Kanal-Gain:* I' = clip(diag(g_R, g_G, g_B)·I + b). Ist ein Kanal knapp über 1 und die anderen darunter, „gewinnt“ diese Farbe mit der Zeit, weil die Schleife sie aussortiert.
- *Kanaltausch:* Mit der Permutation (R,G,B) → (G,B,R) pro Umlauf rotiert die Farbe in drei Frames einmal durch. Zusammen mit Zoom entstehen farbige Ringe im Tunnel.
- *Matrix-Mischung (Crutchfields Kopplungsmatrix):*
  ```
  [R']   [a b c] [R]
  [G'] = [d e f]·[G]  + Offset,  danach clip(0,1)
  [B']   [g h i] [B]
  ```
  Die Eigenwerte der Matrix bestimmen das Langzeitverhalten. Ein reeller Eigenwert > 1 bedeutet, dass die zugehörige Farbrichtung wächst. Ein komplexes Eigenwertpaar mit Betrag ≈ 1 bedeutet, dass die Farben *rotieren*, also langsam zyklisch den Farbton wechseln. Eine Rotationsmatrix um die Grauachse ist damit eine lineare Hue-Rotation.
- Hardware-Äquivalent: Eine 3×3-Matrixmischung gibt es auch als Modul, etwa LZX „3X3 Matrix Mixer“.\[20\]

**3.2 HSV/HSL-Feedback**

```
hsv = rgb2hsv(I)
h = fract(h + Δh)          # Hue-Rotation pro Umlauf
s = clamp(s·k_s, 0, 1)     # Sättigungsverstärkung
v = clamp(v·k_v + o, 0, 1) # Helligkeit = eigentlicher Schleifen-Gain
I' = hsv2rgb(h, s, v)
```

- Ein konstantes Δh erzeugt Regenbogenringe entlang der Zoom-Richtung: Jede „Generation“ im Tunnel hat einen anderen Farbton. Mit Δh ≈ 1/N wiederholt sich die Farbe alle N Umläufe.
- k_s > 1 treibt alles zu gesättigten Primärfarben (Sättigungsclipping). Das Ergebnis sieht plakativ aus und erinnert an Colorizer.
- Getrennte Dämpfung von H, S und V ist das Kernfeature von Andrei Jays Waaave Pool. Laut Hersteller entstehen damit „shimmering fading trails“ bis „bold super saturated reaction diffusion patterns“.\[21\]
- Der Hue-Wert macht bei 0/1 einen Sprung. Blur sollte man daher nicht im HSV-Raum anwenden, sondern in RGB oder Lab, sonst entstehen Farbartefakte.

**3.3 Luma-Key und Chroma-Key als Maske in der Schleife**

Luma-Key als Soft-Key:
```
Y = 0.2126R + 0.7152G + 0.0722B          # Rec.709-Luma
α = smoothstep(t − w, t + w, Y)          # w = Weichheit; w→0 = Hard-Key
out = mix(neu, feedback, α)              # Feedback nur, wo hell
```
Chroma-Key: α aus dem Abstand in der CbCr-Ebene bzw. aus dem Hue-Abstand zur Schlüsselfarbe, mit Toleranz und Weichheit.

Typische Schleifentopologien:
- *Key auf dem Feedback-Pfad:* Nur helle oder nur bestimmte Farben werden zurückgeführt. Diese Regionen wachsen mit jedem Umlauf, der Rest wird durch frisches Material (Kamera, Generator) ersetzt. Das ergibt „Flammen“ und selektive Trails.
- *Invertierter Key:* Nur dunkle Bereiche werden rekursiv. Es entstehen Negativraum-Tunnel.
- *Key als Schwellwert-Nichtlinearität:* Ein Hard-Key ist eine Stufenfunktion. Er macht aus weichen Verläufen scharfe Grenzen, die zusammen mit Blur wie ein Zellularautomat wirken. Crutchfield beschreibt Video-Feedback ausdrücklich als möglichen Simulator für 2D-Zellularautomaten.\[4\]
- *Key-Schwelle modulieren* (LFO, Audio): Die Grenzen „atmen“.
- Umsetzungen:
  - Max hat Shader wie `co.chromakey.hsv.jxs` und `co.lumakey.jxs` (Parameter binary, fade, tol) sowie die Vizzie-Module CHROMAKEYR und LUMAKEYR.\[22\]
  - TouchDesigner hat das RGB Key TOP bzw. das Chroma Key TOP.
  - Analog gibt es den LZX FKG3 mit Luma-Key und Chroma-Key für R, G und B sowie einer „variable edge“, die vom Crossfader bis zum Hard-Key reicht.\[23\]

**3.4 Weitere Farbtransformationen**

- *YUV/YCbCr:* Man trennt Luma von Chroma und kann so Helligkeit stark verstärken, während man die Chroma dämpft, oder umgekehrt. Chroma lässt sich rotieren, indem man den Winkel in der CbCr-Ebene ändert: eine saubere Hue-Rotation.
- *Lab/LCh:* Wahrnehmungsgleichmäßige Hue-Rotation. Blur im Lab-Raum vermeidet Farbsäume.
- *Gamma:* y = x^γ. γ > 1 drückt Mitteltöne ab, Dunkles stirbt schneller, der Kontrast steigt. γ < 1 hebt Schatten an, Rauschen wird verstärkt und das System startet leichter von selbst. Gamma pro Umlauf wirkt kumulativ: x^(γⁿ).
- *Invertierung:* y = 1 − x, bei Crutchfield s = −1. In der Schleife erzeugt sie Oszillationen mit Periode 2 (hell/dunkel im Wechsel) und bei Zoom Schachbrett-Ringe.
- *Solarisation:* y = x für x < t, sonst 1 − x. Das ist eine nicht-monotone Abbildung. Iteriert entstehen Konturlinien und fraktale Grenzen, ähnlich der Logistik-Abbildung.
- *Posterisierung:* y = floor(x·n)/n. Sie quantisiert die Zustände. Mit Blur entstehen terrassierte, cartoonartige Flächen und stabile Zellstrukturen. Das analoge Vorbild ist der Amplitude Classifier im Sandin Image Processor, aus dem ein „threshold based colorizer“ wird.\[24\]

### 4. Räumliche Filter in der Schleife

**4.1 Tiefpass / Gauß-Blur.** Im Frequenzraum gilt K̂(k) = exp(−σ²k²/2). Hohe Frequenzen sterben pro Umlauf ab, und das Bild wird zu weichen, fließenden Farbwolken („Rauch“). Optisch lässt sich Blur ganz ohne Software mit dem **Objektivfokus** erzeugen, denn nach Crutchfield ist der Fokus die bequemste Steuerung der Diffusionsrate.\[4\] Ein Gauß-Blur zusammen mit leichtem Zoom über 1 ergibt nach außen strömenden Nebel.

**4.2 Hochpass, Sharpen und Unsharp Mask.**
```
USM: y = x + α·(x − G_σ*x)   → K̂(k) = 1 + α·(1 − exp(−σ²k²/2))
```
Für hohe Frequenzen ist die Verstärkung 1 + α > 1. In der Schleife explodieren also Kanten und Rauschen, bis das Clipping sie fängt. Das Ergebnis sind harte Konturen, „elektrische“ Linien und Glitzern. Allein ist das oft instabil, erst in Kombination mit Blur wird es interessant.

**4.3 Blur + Sharpen = Reaction-Diffusion (Turing-Muster).** Werth hat gezeigt, dass wiederholtes Gauß-Blur mit anschließender Unsharp Mask dem generischen RD-Modell entspricht. In seinem Photoshop-Rezept (Bridges 2015, S. 459) wendet man einen Gauß-Blur mit etwa fünf Pixeln Radius an, danach eine Unsharp Mask mit 100 % Stärke, zehn Pixeln Radius und Schwellwert 0, und wiederholt beides immer wieder. Die Parameter bestimmen, ob überhaupt Muster entstehen („blur too much and the system diffuses to gray“), wie schnell sie sich stabilisieren und welche Wellenlänge sie haben. In der Beamer-Schleife passiert das *live* und mit Kamerarauschen als Keim. So entstehen Labyrinthe, Zebrastreifen und Leopardenflecken, die durch Zoom und Rotation zusätzlich driften und rotieren. Pseudocode für einen GLSL-Pass pro Frame:
```
b1 = gauss(prev, σ1)            // Diffusion
b2 = gauss(prev, σ2)            // σ2 > σ1, breite Hemmung
x  = prev + k·(b1 − b2)         // DoG-Reaktion (Bandpass-Verstärkung)
x  = smoothstep(0.5−w, 0.5+w, x)// weiche Sättigung = Nichtlinearität
out = mix(cam, x, fb)
```

**4.4 Difference of Gaussians (DoG).** Ein DoG ist ein Bandpass mit K̂(k) = exp(−σ1²k²/2) − exp(−σ2²k²/2). Sein Maximum liegt bei einer bestimmten Frequenz k*. Nur diese Wellenlänge erreicht |H| > 1, und die Schleife „stimmt“ sich auf ein Muster dieser Größe ein. Das ist der sauberste Weg, die Mustergröße per Regler zu wählen: Das Verhältnis σ2/σ1 ≈ 1,6 ist klassisch, σ1 legt die Skala fest. Mehrere DoG-Bänder mit eigenen Gains ergeben „Multi-Scale-Turing-Muster“.

**4.5 Kantenfilter (Sobel, Laplace).** Sobel ergibt |∇I|. Zurückgeführt wird jede Kante zu einer Doppelkante, und es entstehen konzentrische Konturwellen („Topografie-Linien“). Der Laplace-Operator ∇²I ist genau der Diffusionsterm aus Crutchfields Gleichung (7).\[4\] Mit positivem Vorzeichen addiert wirkt er als Diffusion, mit negativem als Anti-Diffusion, also als Sharpen. In TouchDesigner ist das Edge TOP in der Schleife ein Klassiker. Im Tutorial von Akira Nakayasu reagiert die Feedback-„Strength“ im Bereich von etwa 0,06–0,09 besonders empfindlich.\[25\] Emboss liefert gerichtete Reliefmuster, die in Filterrichtung wandern.

**4.6 Frequenzbereichsfilter (FFT).** Ablauf: FFT des Frames, Multiplikation mit einer Maske (Ring-Bandpass, Richtungsfilter, Kerbfilter gegen Moiré-Spitzen), dann inverse FFT. Vorteile:
- beliebig scharfe Bandpässe, also eine präzise Musterwellenlänge;
- Richtungsfilter, die nur Streifen in einem Winkel erlauben;
- gezieltes Entfernen der Moiré-Frequenz aus Projektor- und Sensorraster.

Die Phase kann man verfremden, etwa per Phasenrotation oder Phasen-Randomisierung, und erhält so „kristalline“ Texturen. Die Kosten sind bei 720p auf der GPU tragbar (cuFFT, VkFFT, OpenCV `cv2.dft`), auf der CPU knapp. Für die meisten Zwecke ist ein DoG die günstigere Näherung.

**4.7 Weitere Operatoren.** Median- und Morphologie-Filter (Erode/Dilate) wirken wie ein nichtlinearer Blur: Flächen wachsen oder schrumpfen, und es entstehen zellige Strukturen. Ein Bilateral-Filter glättet, erhält aber Kanten, und es entsteht ein „aquarelliger“ Look. Werth und andere Praktiker nennen als weitere „Reaktions“-Filter Levels, Edge-Detect und Threshold, und als „Diffusion“ Median oder Min/Max.\[26\]

### 5. Zeitliche Filter und Mischung

- **IIR-Decay / Nachleuchten** entspricht Crutchfields L-Term:
  ```
  acc = a·acc + (1−a)·x        # a∈[0,1); Zeitkonstante τ ≈ −1/ln(a) Frames
  ```
  Bei a = 0,9 ist τ ≈ 9,5 Frames, bei a = 0,98 ≈ 50 Frames. In TouchDesigner entspricht das einem Level TOP mit Opacity 0,9–0,98 im Feedback-Pfad. Jede Generation wird mit 0,9, dann 0,81, dann 0,729 gewichtet.\[27\]\[28\] Beachten: Beim Beamer liefert die *optische* Schleife bereits ein Nachleuchten, denn das alte Bild steht auf der Wand und wird erneut abgefilmt. Software-Decay und optischer Gain multiplizieren sich.
- **Max-/Min-Blending** (acc = max(a·acc, x)) ergibt Lichtspuren, die nie über das Maximum hinaus aufbauen und daher stabiler sind als additives Blending.
- **Frame-Delay** (Ringpuffer mit N Frames): out = mix(x, buf[n−N], k). Die Verzögerung wird zum Parameter. Sie legt fest, wie schnell Tunnel und Spiralen „laufen“, und erzeugt Echos. Waaave Pool bietet eine Verzögerung von 33 bis 2000 ms aus einem Puffer von 2 s.\[21\] Achtung: Die physische Schleifenlatenz addiert sich immer dazu.
- **Frame-Differencing:** d = |x(n) − x(n−k)|. Nur Veränderung wird zurückgeführt, statische Bereiche sterben ab. Das ergibt bewegungsgetriebenes Feedback, das bei Interaktion (Hand im Lichtkegel) aufblüht und in Ruhe verlischt, also ideal für Installationen. In Hydra erledigt das `diff()`.\[29\]
- **Zeitlicher Tiefpass:** Er glättet Strobo-Flackern (Periode-2-Oszillationen bei Invertierung) und das Beat-Flackern zwischen Kamera- und Beamerrate. Waaave Pool nennt seinen „temporal filter“ ausdrücklich als Mittel, um „strobing effects“ zu glätten.\[21\]
- **Zeitlicher Hochpass:** x − acc (Bewegungsbetonung) zurückgeführt ergibt Oszillatoren und pulsierende Ränder.
- **Zeitliche Filter in der Kette:** Eine Hintereinanderschaltung aus Tiefpass und Hochpass ergibt einen zeitlichen Bandpass, sodass nur Veränderungen mit bestimmter Frequenz überleben. Damit kann man „Resonanzfrequenzen“ des Bildes einstellen.

### 6. Geometrische Transformationen

Die allgemeine Form um das Zentrum c ist:
```
x' = b·R(φ)·(x − c) + c + t        # Zoom b, Rotation φ, Verschiebung t
sample prev at x' (bilinear), außerhalb = 0 oder wrap/mirror
```
- **Zoom b > 1** (optisch: näher heran oder Brennweite verlängern): Inhalte strömen nach außen, das Zentrum wird zur Quelle, Rauschen wird verstärkt, es entstehen Ausbrüche. **b < 1:** Tunnel, unendliche Regression.
- **Rotation φ:** Spiralen, rotierende Sterne. Mit Zoom entstehen logarithmische Spiralen. Crutchfield empfiehlt für den Einstieg 20–60° Rotation bei variiertem Zoom.\[4\] Mit Winkeln φ = 360°/N entstehen N-zählige Symmetrien.
- **Verschiebung t:** Driftende Vorhänge, Wasserfälle. In Hydra geht das etwa mit `src(o0).scrollY(-0.001)`.\[30\]
- **Spiegelung / Kaleidoskop:** Polarwinkel mod 2π/N, jedes zweite Segment gespiegelt (Hydra `kaleid(N)`). In der Schleife werden Symmetrien *erzwungen*, und es entstehen Mandala-artige, stabile Muster. Auch physisch möglich: Spiegel im Strahlengang oder eine zweite Projektion.
- **Displacement / Feedback-Warping:** Abtastung bei x + k·D(x), wobei D Rauschen, ein Oszillator oder der *Gradient des Bildes selbst* ist. Selbstmodulation erzeugt Flüssigkeits- und Marmoreffekte. Hydra: `osc().modulate(src(o0))` oder `src(o0).modulate(noise(3), 0.02)`.\[30\] In TouchDesigner das Displace TOP mit einem Noise TOP als Quelle.
- **Nichtlineare Warps:** Ein Swirl (Rotation abhängig vom Radius) ergibt Strudel. Eine Möbius-Transformation ergibt doppelte Spiralen mit zwei Fixpunkten.
- **Optische Parameter** (Crutchfields Tabelle I):
  - Zoom = räumliche Vergrößerung;
  - Fokus = Diffusion bzw. Schärfe;
  - Blende = Gain;
  - Rotation und Translation zwischen Kamera- und Projektionsraster.
  Dazu kommen beim Beamer der **Einfallswinkel** (Keystone, also perspektivische Verzerrung als Teil der Abbildung), die **Oberfläche** (Struktur, Krümmung, Stoff) und **Objekte im Lichtkegel**.\[31\] Mit manuellem Zoom, Fokus und Iris an einem CS-Varifokalobjektiv sind das echte „Hardware-Regler“. Eine Kombination aus optischer Grobeinstellung und digitaler Feinjustage ist ideal.

**Pixelraster-Fraktale:** Nach Courtial et al. (ausführliche Fassung in Contemporary Physics 44, 2003) entscheidet bei pixelbasierten Displays die Lage des Zoom-Zentrums relativ zu den einzelnen Pixeln über die Art der entstehenden Fraktale (Sierpinski, Koch). Wer das gezielt will, projiziert scharf, zoomt digital mit Nearest-Neighbour-Sampling und verschiebt das Zentrum subpixelgenau.

### 7. Konkrete Umsetzungen

**Minimaler Python/OpenCV-Loop** (CPU, gut für Prototypen; für 1080p60 besser auf die GPU gehen):
```python
import cv2, numpy as np, subprocess
cap = cv2.VideoCapture(0, cv2.CAP_V4L2)
cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc(*'MJPG'))
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280); cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
cap.set(cv2.CAP_PROP_FPS, 60); cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
subprocess.call("v4l2-ctl -d 0 -c exposure_auto=1 -c exposure_absolute=167 "
                "-c white_balance_temperature_auto=0 -c gain=0", shell=True)
H = np.load("cam2proj_homography.npy")      # aus Kalibrierung (s. Abschnitt 9)
acc = None
while True:
    ok, f = cap.read()
    x = cv2.warpPerspective(f, H, (1920,1080)).astype(np.float32)/255
    # Farbe: Hue-Rotation
    hsv = cv2.cvtColor(x, cv2.COLOR_BGR2HSV); hsv[...,0] = (hsv[...,0]+3)%360
    x = cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)
    # Raum: DoG-Bandpass + Soft-Clip
    x = x + 1.5*(cv2.GaussianBlur(x,(0,0),2) - cv2.GaussianBlur(x,(0,0),3.2))
    x = np.tanh(1.2*x)
    # Geometrie: leichter Zoom + Rotation
    M = cv2.getRotationMatrix2D((960,540), 1.5, 1.02); x = cv2.warpAffine(x, M, (1920,1080))
    # Zeit: IIR
    acc = x if acc is None else 0.85*acc + 0.15*x
    cv2.imshow("out", acc); cv2.waitKey(1)   # Fenster fullscreen auf Beamer
```

**TouchDesigner.** Ein Feedback TOP liefert das Bild des vorherigen Frames eines Ziel-TOPs („Target TOP“). So lassen sich Schleifen bauen ohne „cook dependencies or infinitely recursive loops“.\[32\]\[33\] Typisches Netzwerk:
- Video Device In TOP (C3) → Transform/Corner Pin TOP (Entzerrung) → Composite TOP.
- Feedback TOP → Level TOP (Opacity 0,98) → Blur TOP (z. B. Filter Size 16) → HSV Adjust TOP → Transform TOP (Zoom/Rotate) → zurück in das Composite.\[27\]
- Das Composite TOP ist als Target eingetragen.\[34\] Ausgabe über das Window COMP auf den Beamer.
- Keys über RGB Key TOP bzw. Chroma Key TOP, Kanten über das Edge TOP, eigene DoG-/RD-Shader im GLSL TOP.
- Steuerung über MIDI In CHOP bzw. OSC In CHOP.

**Max/MSP/Jitter.** Man nimmt jit.grab → jit.gl.pix bzw. jit.gl.slab. Beide Objekte kopieren eingehende Texturen, was „prevents feedback from becoming an infinite loop“. Ein leeres jit.gl.slab dient als Feedback-Speicher um ein jit.gl.pix,\[35\] in dem Zoom, Offset und Farb-Scale/Bias passieren.\[36\] Keys laufen über `co.lumakey.jxs` bzw. `co.chromakey.hsv.jxs`, Crossfades über `jit.gl.pix @gen xfade`. Für Einsteiger gibt es Vizzie-Module wie LUMAKEYR, CHROMAKEYR und XFADR.\[22\] Die ältere CPU-Variante mit jit.op (+, *, avg), jit.xfade, jit.rota und jit.brcosa funktioniert,\[37\] ist aber langsamer.

**Hydra (Browser, Live-Coding).** Die Ausgabepuffer o0 bis o3 können sich selbst als Quelle nutzen. Hydra nennt Crutchfields Film ausdrücklich als Inspiration.\[30\]\[38\]
```js
s0.initCam()                                   // C3 als UVC-Webcam
src(o0).scale(1.015).rotate(0.01)              // Geometrie im Loop
  .hue(0.01).saturate(1.02)                    // HSV-Feedback
  .modulate(noise(3), 0.005)                   // Displacement
  .blend(src(s0).thresh(0.5, 0.1), 0.1)        // Luma-Key-artiges Einspeisen
  .out(o0)
```

**VVVV, openFrameworks, Processing, GLSL.** Das Prinzip ist überall das „Ping-Pong“ aus zwei Framebuffern: Man liest aus A, schreibt nach B und tauscht dann. openFrameworks nutzt dafür ofFbo, Processing PGraphics und einen Shader, VVVV gamma die Feedback-/Texture-Knoten. Waaave Pool von Andrei Jay ist in openFrameworks und GLSL geschrieben, läuft auf dem Raspberry Pi und nutzt USB-Kameras sowie USB-MIDI-Controller (Korg nanoKONTROL). Er ist Open Source und eine gute Vorlage.\[39\]\[40\]\[41\] Ein Port für den Pi 5 mit 1920×1080 @ 60 fps existiert.\[42\]

**Resolume und OBS.** Beide sind Mixer mit Effektketten. Feedback entsteht optisch über die Kamera oder über Effekte bzw. Shader mit Zugriff auf den vorherigen Frame. Für präzise Schleifenalgorithmen (DoG, RD, Keys im Loop) sind TouchDesigner, Max oder eigene Shader flexibler. OBS eignet sich eher, um das Ergebnis mitzuschneiden oder zu streamen.

**Analog und Hardware.**
- *LZX Industries* (Eurorack-Video):
  - FKG3 (Luma- und Chroma-Key mit variabler Kante, Compositor);\[23\]
  - RGB-Keyer/Fader, 3×3-Matrix-Mixer, Waveshaper und Ringmodulatoren (z. B. „Factors“);\[20\]\[43\]
  - „Visual Cortex“ als Zentrale mit Decoder, Encoder, Sync und Keying.\[44\]
  Für den Loop braucht man Kamera → analoger Eingang (Komponente oder Composite) → Module → Encoder → Beamer. Die C3 liefert nur USB, deshalb braucht man einen Rechner oder einen HDMI-zu-analog-Weg. Alle Quellen müssen synchron laufen.\[45\]
- *Sandin Image Processor* (1971–73): Patchbarer Analogrechner für Video, entworfen als visuelles Pendant zum Moog. Laut Sherry Miller Hocking (Experimental Television Center / Video History Project) schätzte Sandin, dass mindestens 15 Systeme gebaut wurden; Amanda Long nennt in ihrem ISEA-Vortrag „Copy-It-Right. The Distribution Religion“ mehr als 20 Kopien. Feedback-Verkettung durch Rückführung der Modulausgänge ist dort ein Kernverfahren.
- *Video-Mischer* mit Rückführung des Programmausgangs in einen Eingang („Mixer-Feedback“) sowie Colorizer und Keyer sind die typische Live-Ausrüstung. Die Community (z. B. Modwiggler) nennt als wichtigste Behandlungen Farbsteuerung, Kanten, Colorizer und Modulation.\[46\]

### 8. Künstlerische Praxis und Referenzen

- **Pioniere:**
  - Nam June Paik zeigte Mitte der 1960er Feedback-Clips in New York.\[15\]
  - Steina und Woody Vasulka gründeten 1971 u. a. mit Richard Lowenberg The Kitchen.\[15\]\[47\]
  - Skip Sweeney gründete Video Free America in San Francisco und ist bekannt für Feedback-Installationen.\[15\]\[48\]
  - Eric Siegel machte „Psychedelevision in Color“ mit Feedback und Colorizer.\[49\]
  - Peter Campus schuf interaktive Closed-Circuit-Installationen mit Projektion, Spiegelung und Chroma-Key („Three Transitions“, 1973).\[50\]
- **Wissenschaft und Film:**
  - Crutchfields Film „Space-Time Dynamics in Video Feedback“ (1984, 16 min) und das Paper in Physica D 10 (1984) 229–245 sind frei online.\[4\]\[51\]
  - Courtial, Leach & Padgett, „Fractals in pixellated video feedback“, Nature 414 (2001), und die ausführliche Fassung in Contemporary Physics 44 (2003).\[52\]\[53\]
  - Werth, „Turing Patterns in Photoshop“, Bridges 2015.\[5\]
- **Heutige Praxis:**
  - Andrei Jay (Waaave Pool, Video Synthesis Ecosphere RPI, Kurse zu Framebuffern und Feedback);\[40\]\[41\]
  - Olivia Jack (Hydra);
  - Andrew Benson (Jitter-Feedback-Rezepte bei Cycling '74);\[35\]
  - die Tutorials von Derivative (TouchDesigner) und Interactive & Immersive HQ;
  - LZX-Community und Modwiggler-Forum (Gear-Setups für Live-Feedback).\[46\]
- **Beamer-spezifisch:** Der Beamer macht die Schleife *raumgroß*. Publikum, Schatten, Objekte und die Wandstruktur werden Teil der Abbildung T.\[31\] Crutchfields Rat, mit Hand oder Taschenlampe zu stören, wird damit zur Interaktionsform.

### 9. Praktische Hinweise für Beamer-Kamera-Feedback

1. **Umgebungslicht:** Möglichst dunkel arbeiten. Fremdlicht wirkt als konstanter Offset, der das System aus dem Nullzustand „anschiebt“ und dunkle Attraktoren verhindert. Crutchfield beschreibt, dass manche Verhaltensweisen bei Fremdlicht gar nicht erst auftreten. Umgekehrt ist gezielt dosiertes Licht (Taschenlampe) der Startknopf.\[4\] Bei Netzfrequenz-Lampen 50-Hz-Flimmern berücksichtigen (power_line_frequency) oder Lampen ausschalten.
2. **Gain-Staging:** Die Grundhelligkeit mit Blende oder ND-Filter und fester Belichtung einstellen, sodass bei neutraler Software (Gain 1) *knapp unter* der Selbsterregung gearbeitet wird. Dann den Software-Gain als feinen, reproduzierbaren Regler um 1 herum nutzen. Kamera-Gain auf 0 lassen (Rauschen). Beamer im „Kino/Standard“-Modus betreiben, dynamischen Kontrast und Auto-Iris des Beamers **abschalten**, denn das ist die nächste versteckte Regelschleife.
3. **Ausbrennen vermeiden:** Einen Soft-Clip (tanh, Knee) statt harter 8-Bit-Sättigung verwenden. Einen Decay < 1 immer im Pfad lassen und einen „Panic“-Reset per Taste haben (Feedback TOP: Reset Pulse).\[33\] Moderne CMOS-Sensoren brennen nicht ein wie Crutchfields Röhren, aber Weißflächen bleiben als Attraktor „kleben“.\[4\]
4. **Geometrische Kalibrierung:** Eine Homographie Kamera→Beamer bestimmen. Dafür ein Schachbrett oder Gray-Code-Muster projizieren, Punkte finden und `cv2.findHomography` rechnen. Für präzise Anwendungen gibt es die Methode mit lokalen Homographien von Moreno & Taubin (2012) samt Open-Source-Tool procam-calibration.\[54\]\[55\] Mit der Homographie ist die „Identität“ definiert, also Zoom = 1 und Rotation = 0, und Zoom, Rotation und Verschiebung werden zu präzisen, reproduzierbaren Parametern statt Stativgefummel. Die Objektivverzeichnung der Kamera vorher entfernen (`cv2.undistort`).
5. **Photometrische Kalibrierung:** Beamer und Kamera haben nichtlineare Tonkurven, und ihr Produkt ist die effektive Schleifen-Nichtlinearität. Zum Messen Graustufen von 0–255 projizieren, den Kameramittelwert aufnehmen und eine Inverse-LUT anlegen. Erst damit sind „Gain 1“ und Farbmatrizen in der Software wirklich linear. Den Weißabgleich fest auf die Farbtemperatur des Beamers legen.
6. **Moiré:** Es entsteht aus der Interferenz von Projektorpixelraster, Sensorraster und Bayer-Muster. Gegenmittel:
   - (a) minimal defokussieren, also optischer Tiefpass;
   - (b) Kamera-Auflösung bzw. Bildausschnitt so wählen, dass ein Projektorpixel deutlich unter oder über einem Kamerapixel liegt;
   - (c) digitalen Blur mit σ ≈ 0,5–1 px vor der Verarbeitung;
   - (d) Kerbfilter im FFT-Raum.
   Man kann Moiré aber auch bewusst als Musterquelle nutzen (siehe Courtial).
7. **Latenzmessung:**
   - *Blink-Test:* Im eigenen Loop an Frame n ein Weißbild ausgeben, im Kamerastrom den Frame suchen, in dem die mittlere Helligkeit springt, und die Differenz in Frames bzw. ms ablesen. Wiederholen und die Verteilung auswerten.\[56\]
   - *Glass-to-Glass-Messung:* Eine Uhr mit ms-Anzeige wird abgefilmt und zusammen mit ihrem projizierten Bild fotografiert.\[56\]\[57\]\[58\]
   Für die Messung sollte man die Glättung durch lange Belichtung berücksichtigen.
8. **Timing und Synchronisation:** Kamera und Beamer mit derselben Nennrate betreiben (60/60). Die unvermeidliche Schwebung zwischen beiden Takten zeigt sich als langsames Rollen oder Pulsieren. Das dämpft man mit einem zeitlichen Tiefpass oder mit einer Belichtung gleich der Frameperiode. Bei Ein-Chip-DLP gelten die Hinweise aus Abschnitt 1.
9. **Echtzeit-Steuerung per MIDI/OSC:** Die wichtigsten Regler sind:
   - Feedback-Gain bzw. Decay;
   - Zoom, Rotation, Verschiebung;
   - Hue-Δ und Sättigung;
   - Key-Schwelle und Weichheit;
   - σ1/σ2 und k (DoG/RD);
   - Mix frisch/Feedback;
   - Delay-Frames.
   Parameter *glätten* (Slew/Lag, z. B. Lag CHOP bzw. `jit.slide`), weil Sprünge in Gain oder Zoom das System schlagartig in ein anderes Attraktorbecken werfen können. Für Gain und Zoom logarithmische Skalen mit feiner Auflösung um 1 herum verwenden (z. B. 14-Bit-MIDI oder OSC-Float). Werkzeuge sind MIDI In CHOP und OSC In CHOP (TouchDesigner), ctlin und udpreceive (Max), in Python `mido` bzw. `python-osc`. Waaave Pool bringt ein fertiges nanoKONTROL-Mapping mit uni- und bipolaren Reglern mit.\[39\]
10. **Sicherheit:** Feedback kann schnelle Hell-Dunkel-Wechsel erzeugen, etwa Periode-2-Oszillationen bei Invertierung. Bei öffentlichem Einsatz Flash-Raten begrenzen (Richtwert nach W3C WCAG 2.x, Erfolgskriterium 2.3.1 „Three Flashes or Below Threshold“: nichts darf in einer Sekunde öfter als dreimal blitzen) und mit einem zeitlichen Tiefpass absichern.

## Recommendations

1. **Kamera:** Mit einem DLP-Beamer die C3-234 (Global Shutter) nehmen. Mit einem LCD- oder Laser-3-Chip-Beamer und wenig Licht die C3-462C, für reines Luma-Feedback mit Software-Colorizer die C3-462M. Die C3-415 nur, wenn Auflösung wichtiger ist als Bildrate. Dazu ein manuelles CS-Varifokal (z. B. 2,8–12 mm), damit Zoom, Fokus und Iris als physische Regler dienen.
2. **Signalweg:** MJPEG mit 1280×720 oder 1920×1080 bei 60 fps. Alle Automatiken aus, Belichtung = 16,7 ms oder 33,3 ms, Gain 0, Schärfe 0. Homographie und photometrische LUT einmal kalibrieren.
3. **Algorithmus-Startpunkt:** Den Kern bilden IIR-Decay (0,85–0,95), Zoom 1,01–1,03, Rotation 0,5–3° pro Frame und ein weicher Clip. Dann schrittweise nacheinander hinzufügen:
   - (a) Hue-Rotation 1–3° pro Frame;
   - (b) Blur mit σ 1–3 px;
   - (c) DoG bzw. Unsharp für Turing-Muster;
   - (d) Luma-Key im Feedback-Pfad;
   - (e) Displacement mit Noise.
   Immer nur einen Parameter über die Stabilitätsgrenze schieben.
4. **Plattform:** TouchDesigner für schnelles, visuelles Arbeiten mit MIDI und OSC. Hydra für Live-Coding. Eigene GLSL-Shader (in TouchDesigner, Max oder openFrameworks) für RD/DoG/FFT. Waaave Pool, wenn ein eigenständiges Pi-Gerät gewünscht ist. Analoge LZX-Module nur, wenn ohnehin ein analoger Videopfad vorhanden ist, denn die C3 selbst ist rein digital (USB).
5. **Dokumentation:** Parameter-Presets speichern. Nahe an Bifurkationen sind die Zustände empfindlich und nur mit exakt gleichen Werten und gleicher Kalibrierung reproduzierbar.

## Caveats

- Die C3-Spezifikationen in Kurokesus Quellen widersprechen sich teilweise: C3-234 mit 30 oder 60 fps, IMX415 mit 30 oder 60 fps, YUY2-Bildraten nicht dokumentiert. Die Beispiel-Control-Liste stammt von einer C2, nicht von einer C3. Am eigenen Gerät verifizieren.
- Für die C3 gibt es keinen veröffentlichten Latenzwert. Meine Angabe von 3–6 Frames ist eine Schätzung, keine Messung.
- Die lineare Stabilitätsanalyse (H(k) = g·K̂(k)) ist eine Vereinfachung. Zoom und Rotation koppeln verschiedene Frequenzen und Orte nichtlokal, und reale Kameras und Beamer sind nichtlinear. Sie dient als Orientierung, nicht als exakte Vorhersage.
- Einige Aussagen zu Praxiswerten (Opacity 0,98, Blur 16, Strength 0,06–0,09) stammen aus Tutorials für bestimmte Szenen und sind nur Startpunkte.
- Die Aussagen zu DLP-Farbband-Effekten stützen sich auf Patentschriften und das allgemeine Funktionsprinzip. Wie stark der Effekt ist, hängt vom konkreten Beamer ab (Farbradgeschwindigkeit, Segmentzahl, LED- bzw. Laser-Lichtquelle).

## Quellen

1. [C3-462 - High sensitiv... | Kurokesu](https://wiki.kurokesu.com/books/c3/page/c3-462-high-sensitivity-rgbmono)
2. [C3-415 - 8M/4K (was C3... | Kurokesu](https://wiki.kurokesu.com/books/c3/page/c3-415-8m4k-was-c3-4k)
3. [Features | Kurokesu](https://wiki.kurokesu.com/books/c3/page/features)
4. <https://csc.ucdavis.edu/~cmg/papers/Crutchfield.PhysicaD1984.pdf>
5. [Turing Patterns in Photoshop Andrew Werth Independent Fine Artist](https://archive.bridgesmathart.org/2015/bridges2015-459.pdf)
6. [(PDF) Turing Patterns in Photoshop](https://www.researchgate.net/publication/280626953_Turing_Patterns_in_Photoshop)
7. [Projection-type video display device](https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/11146766)
8. [C3 | Kurokesu](https://wiki.kurokesu.com/books/c3)
9. <https://www.kurokesu.com/item/C3-415C>
10. [New global shutter cameras in C3 family - KUROKESU](https://kurokesu1.rssing.com/chan-68865378/latest.php)
11. [V4L2 | Kurokesu](https://wiki.kurokesu.com/books/recipes/page/v4l2)
12. [Manual Exposure Control of OpenCV Video | Peter F. Klemperer](https://peterklemperer.com/blog/2018/02/10/manual-exposure-control-of-opencv-video/)
13. [Exposure Time values · Issue #6 · yuripourre/v4l2-ctl-opencv](https://github.com/yuripourre/v4l2-ctl-opencv/issues/6)
14. [VideoCapture set manual exposure not working · Issue #14494 · opencv/opencv](https://github.com/opencv/opencv/issues/14494)
15. [Video feedback](https://en.wikipedia.org/wiki/Video_feedback)
16. [How to Reduce USB Camera Latency in Real-Time Applications](https://www.aiusbcam.com/news/USB-camera-latency-real-time-vision-systems.html)
17. [How to Reduce Latency in USB Camera Modules](https://www.aiusbcam.com/news/773515473934221354.html)
18. [Digital light processing](https://en.wikipedia.org/wiki/Digital_light_processing)
19. [Projector device, and photographing method and program of projected image](https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/7369762)
20. [LZX Industries](https://modulargrid.net/e/vendors/view/153)
21. [WAAAVE\_POOL — andrei\_jay\_creative\_coding](https://andreijaycreativecoding.com/WAAAVE_POOL)
22. [Article: Jitter Shaders or Gen Patcher Equivalents for Common Jitter Objects | Cycling '74](https://cycling74.com/articles/jitter-shaders-or-gen-patcher-equivalents-for-common-jitter-objects)
23. [LZX Industries FKG3 Keyer Eurorack Video Module | Reverb](https://reverb.com/item/47523250-lzx-industries-fkg3-keyer-eurorack-video-module)
24. [Sandin Image Processor - Excerpts of Description of Analog IP modules from Pioneers of Electronic Art | Video History Project](https://www.videohistoryproject.org/sandin-image-processor-excerpts-description-analog-ip-modules-pioneers-electronic-art)
25. [Feedback – Akira Nakayasu / Lectures](https://lecture.nakayasu.com/en/docs/touchdesigner/feedback/)
26. [Tutorial: Reaction-Diffusion in Photoshop | Videos & Movies on Vimeo](https://vimeo.com/61154654)
27. [A Beginners Guide to Feedback Loops - TouchDesigner Tutorial — Cyanea Studio](https://www.cyaneastudio.com/blog/touchdesigner-feedback-loops-mouse)
28. [On how to use the Feedback](https://github.com/LucieMrc/TD_feedback_love_EN)
29. [updated everything · hydra-synth/hydra-docs-v2@b780dd5](https://github.com/hydra-synth/hydra-docs-v2/commit/b780dd582eca11d5018341b7d58e811215012df0)
30. [Getting started - HackMD](https://hackmd.io/@QqpoHxzXRm2Q_hoeDZ36uw/SyX1mSbZc)
31. [Video Feedback: How to Create Fractal Loops | Glitchology](https://glitchology.com/video-feedback/)
32. [Creating a Feedback – TouchDesigner Curriculum](https://learn.derivative.ca/courses/100-fundamentals/lessons/102-tops-working-with-images/topic/creating-a-feedback/)
33. [Feedback TOP - TouchDesigner Documentation](https://docs.derivative.ca/Feedback_TOP)
34. [Understanding Feedback Loops in TouchDesigner - The Interactive & Immersive HQ](https://interactiveimmersive.io/blog/touchdesigner-lessons/understanding-feedback-loops-in-touchdesigner/)
35. [Tutorial: My Favorite Object: jit.gl.pix | Cycling '74](https://cycling74.com/tutorials/my-favorite-object-jit-gl-pix)
36. [Tutorial: Jitter Recipes: Book 4, Recipes 44-53 | Cycling '74](https://cycling74.com/articles/jitter-recipes-book-four)
37. [Max MSP Tutorials for Beginners: Jitter #3 Feedback | by Myk Eff | Sound & Design](https://soundand.design/jitter-3-feedback-e22ddc423955?gi=4da7d35ac00f)
38. [Hydra Getting Started - deprecated - HackMD](https://hackmd.io/@naoto-hieda/rJKwGJI2t)
39. [Waaave\_Pool manual — andrei\_jay\_creative\_coding](https://andreijaycreativecoding.com/Waaave_Pool-manual)
40. [Video Synthesis Ecosphere RPI — andrei\_jay\_creative\_coding](https://andreijaycreativecoding.com/Video-Synthesis-Ecosphere-RPI)
41. [INTRODUCTION TO VIDEO SYNTHESIS ON THE RASPBERRY PI — andrei\_jay\_creative\_coding](https://andreijaycreativecoding.com/INTRODUCTION-TO-VIDEO-SYNTHESIS-ON-THE-RASPBERRY-PI)
42. [GitHub - bar2098/WAAAVE-POOL-RP5-PORT: Rasberry Pi 5 Port of Andrei Jay's incredible video synth delay instrument. · GitHub](https://github.com/bar2098/WAAAVE-POOL-RP5-PORT)
43. [LZX INDUSTRIES | Schneidersladen](https://schneidersladen.de/en/lzx-industries)
44. [Visual Cortex Video Synthesizer | Perfect Circuit](https://www.perfectcircuit.com/lzx-industries-visual-cortex.html)
45. [Sandin Image Processor](https://grokipedia.com/page/sandin_image_processor)
46. [Video feedback for live shows: gear and setup - MOD WIGGLER](https://www.modwiggler.com/forum/viewtopic.php?t=193036)
47. [10 Video Artists Who Revolutionized Technology in Art | Artsy](https://www.artsy.net/article/editorial-the-history-of-video-art-in-a)
48. [Video Art Movement Overview | TheArtStory](https://www.theartstory.org/movement/video-art/)
49. [Video Colour Image Processors | Chris Meigh-Andrews](https://www.meigh-andrews.com/writings/essays/video-colour-image-processors)
50. [Peter Campus](https://en.wikipedia.org/wiki/Peter_Campus)
51. [Space-Time Dynamics in Video Feedback - YouTube](https://www.youtube.com/watch?v=B4Kn3djJMCE)
52. [Fractals in pixellated video feedback: Contemporary Physics: Vol 44, No 2](https://www.tandfonline.com/doi/abs/10.1080/0010751021000029598)
53. [Fractals in pixellated video feedback | Nature](https://www.nature.com/articles/414864a)
54. [procam-calibration/README.md at main · kamino410/procam-calibration](https://github.com/kamino410/procam-calibration/blob/main/README.md)
55. [Projector-Camera Calibration / 3D Scanning Software](http://mesh.brown.edu/calibration/)
56. [A SYSTEM FOR HIGH PRECISION GlASS-TO-GLASS DELAY MEASUREMENTS IN VIDEO COMMUNICATION](https://ar5iv.arxiv.org/html/1510.01134)
57. [Glass-to-glass latency measurement | MRTech SK](https://mr-technologies.com/iff-sdk/latency-mesurement/)
58. [Vadzo: The Relevance of Low Latency Camera Streaming](https://www.vadzoimaging.com/post/what-is-relevance-low-latency-camera-streaming)
