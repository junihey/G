# Spatialisation in elektroakustischer Musik & immersivem Audio: Techniken, DSP-Grundlagen und genexpr-Code

## TL;DR
- Alle Bewegungs- und Gestaltungstechniken der Mehrkanal-Spatialisation lassen sich in sechs Familien ordnen: (1) Panning/Rendering-Verfahren (Stereo, VBAP/MDAP, DBAP, Ambisonics, Binaural, WFS), (2) Trajektorien & Bewegung, (3) Distanz-/Raumsimulation, (4) Breite/Dekorrelation, (5) granulare & mikrozeitliche Spatialisation, (6) spektrale Spatialisation und Klangregie/Diffusion.
- In gen~ lassen sich fast alle zeit- und amplitudenbasierten Verfahren nativ und effizient bauen (Panner, Distanzmodell, Doppler mit interpoliertem `delay`, Random Walk, Lissajous, Allpass-Dekorrelation, Crossover-Filterbank); FFT-basierte spektrale Verfahren gehören in `pfft~`+gen~ oder in `pvoc`/`mc.`-Objekte, und fertige Ambisonics/VBAP/WFS-Renderer holt man sich aus spat5, ICST, IEM, HOA-Library.
- Für die Praxis gilt: VBAP für präzise Punktquellen, DBAP für unregelmäßige Setups ohne Sweet-Spot, Ambisonics (mit max-rE-Decoder) für rotierbare Felder und größere Publikumsflächen, Dekorrelation/Spektralstreuung für Breite und „Timbre-Spatialisation", Diffusion (Acousmonium/BEAST) für die Live-Interpretation von Stereo/Reduktionen.

## Key Findings
- **Zwei Denkschulen**: „phantom source"-Verfahren (Amplituden-/Zeitpanning, Ambisonics) erzeugen Scheinquellen über Interferenz und sind sweet-spot-abhängig; „physikalische" Verfahren (WFS) rekonstruieren die Wellenfront und erlauben fokussierte Quellen im Publikum, brauchen aber sehr dichte Arrays.
- **genexpr-Syntax ist C-/JavaScript-ähnlich**: `Param`, `History`, `Delay`-Deklarationen; `in1..inN`/`out1..outN` bestimmen Ein-/Ausgänge; Funktionen wie `cos, sin, atan2, sqrt, pow, clamp, mix, wrap, fold, noise` sind verfügbar; Mehrkanal-Ausgabe über mehrere `out`-Objekte. Es gibt **kein natives FFT im Audio-gen~** — dafür `pfft~` mit gen~ innen.
- **Der Doppler-Effekt** entsteht in gen~ ganz natürlich durch eine variable, interpolierte Verzögerungszeit (`delay @interp linear/cubic`); Zipper-Noise vermeidet man durch geglättete Positionssteuerung und höherwertige Interpolation.
- **Konventions-Fallen bei Ambisonics**: FuMa ordnet W,X,Y,Z (mit W=1/√2), AmbiX/ACN ordnet W,Y,Z,X mit SN3D-Normalisierung (W=1). Decoder-Gewichtung entscheidet über die nutzbare Hörfläche: „basic" (Zentrum), „max-rE" (beste Allround-Lokalisation), „in-phase" (größte Fläche).
- **Timbre-Spatialisation** (Robert Normandeau, „Timbre Spatialisation: The Medium is the Space", Organised Sound 14/3, 2009) zerlegt einen Klang mit Bandpässen in 4–16 Bänder und verteilt sie auf verschiedene Lautsprecher — der Klang existiert als Ganzes nur virtuell im Raum. Verwandt: Gmebaphone/Cybernéphone (Bourges), Torchia/Lippe FFT-Verteilung (2004).

## Details

### 0. Grundkonzepte und genexpr-Werkzeugkasten

**Zwei Lokalisationsmechanismen.** Unser Gehör lokalisiert über interaurale Pegeldifferenzen (ILD), interaurale Zeitdifferenzen (ITD) und spektrale Färbung (HRTF). Alle Lautsprecher-Techniken bedienen sich dieser Reize: Amplitudenpanning erzeugt vor allem ILD-artige Reize (bei tiefen Frequenzen entstehen indirekt auch ITDs durch Summation), Zeitpanning (Haas/Präzedenz) nutzt ITD, HRTF-Binaural liefert alle Reize direkt an den Ohren, WFS rekonstruiert das physikalische Feld.

**genexpr-Sprache (Cycling '74, GenExpr Reference).** Wesentliche Punkte, die man für Spatialisation braucht:
- Ein-/Ausgänge werden durch `in1..inN` und `out1..outN` erkannt; `in`=`in1`, `out`=`out1`.
- Semikolons sind bei mehreren Statements Pflicht; einzeilige Ausdrücke ohne Zuweisung setzen implizit `out1`.
- `Param name (default), min=…, max=…;` deklariert steuerbare Parameter (Signal- oder Kontrollrate).
- `History name (init);` erzeugt eine Ein-Sample-Verzögerung und erlaubt Rückkopplung (Basis für Ein-Pol-Filter, Integratoren, Random Walk).
- `Delay name (maxlen, taps);` — die Delay-Deklaration; `@interp linear|cosine|cubic|spline` für fraktionale (interpolierte) Delays, `@feedback 0` für Delayzeiten < 1 Sample. Aufruf: `y = name.read(delaytime); name.write(x);` bzw. Objekt-Stil.
- Mehrfach-Rückgaben: `r, theta = cartopol(x, y);` und `x, y = poltocar(r, theta);`.
- Verfügbare Funktionen u.a.: `cos, sin, tan, atan2, sqrt, pow, exp, log, abs, sign, min, max, clamp, wrap, fold, mix (lineare Interpolation), scale, noise (weißes Rauschen −1..1), phasor, cycle, floor, ceil, round`.
- Sample&Hold/rate-limitierte Zufallswerte: `latch(signal, trigger)`, Zustandsänderung via `change` und `delta`.
- **Kein Array-Indexing `[i]`** in reinem genexpr; für Tabellen nutzt man `Data`/`Buffer` mit `peek`/`poke` bzw. `channels`/`dim`.
- **Kein FFT im Audio-gen~**: spektrale Verfahren gehören in `pfft~` (mit gen~ im Subpatch) oder in MSP-Objekte (`pfft~`, `pvoc~`, `mc.`-Objekte).

Für echte Mehrkanal-Praxis kombiniert man gen~ meist mit **MC (Multichannel) in Max 8/9**: ein `gen~` mit N Ausgängen speist `mc.`-Ketten, oder man nutzt `mc.gen~`.

---

### 1. Panning- und Rendering-Verfahren

#### 1.1 Stereo-Amplitudenpanning und Pan-Laws
**DSP einfach.** Eine Monoquelle wird mit zwei Gains g_L, g_R auf zwei Lautsprecher verteilt. Der wahrgenommene Ort hängt vom Verhältnis ab. Drei gängige „Pan-Laws":
- **Lineares Panning**: g_L = 1−p, g_R = p (p∈[0,1]). Problem: in der Mitte fällt die *Leistung* ab → Lautheitsloch (−6 dB in der Mitte bei gleicher Amplitude-Summe).
- **Constant Power / sin-cos (−3 dB)**: g_L = cos(θ), g_R = sin(θ) mit θ = p·(π/2). Da cos²+sin²=1 bleibt die Summenleistung konstant; in der Mitte je Kanal −3 dB. Standard für die meisten DAWs.
- **−4,5 dB-Kompromiss**: geometrisches Mittel aus linear und constant power.

Das Pan-Law entscheidet, ob beim Schwenken die Lautheit konstant bleibt. Für unkorrelierte Wiedergabe (getrennte Boxen) ist constant power richtig; bei Mono-Summierung wäre −6 dB linear korrekt.

```genexpr
// ---- Constant-Power Stereo-Panner ----
// in1 = Monosignal, Param pan = 0..1 (0=links, 1=rechts)
Param pan(0.5);
theta = pan * (pi * 0.5);   // 0..pi/2
gL = cos(theta);            // Gain links
gR = sin(theta);            // Gain rechts
out1 = in1 * gL;
out2 = in1 * gR;
```

#### 1.2 Pairwise Panning (Paarweises Panning)
**DSP einfach.** Bei einem Ring aus N Lautsprechern wird die Quelle immer nur auf das *nächste Lautsprecherpaar* verteilt, zwischen dem sie liegt — mit constant-power-Kurve. Das ist die klassische Verallgemeinerung von Stereo auf Kreise: John M. Chowning führte in „The Simulation of Moving Sound Sources" (Journal of the Audio Engineering Society 19/1, Januar 1971) quadrophonisches Amplitudenpanning zusammen mit Doppler und reverb-basierten Distanzcues ein — der intuitive Vorläufer von VBAP im 2D-Fall.

```genexpr
// ---- Pairwise / Rotations-Panner für 8 Lautsprecher im Kreis ----
// Winkel az (0..2pi) wählt das aktive Boxenpaar aus.
// Ausgabe: 8 Kanäle, jeweils constant-power zwischen Nachbarn.
Param az(0);                 // Azimut in Radiant
n = 8;                       // Anzahl Lautsprecher
seg = az / (2*pi) * n;       // Position in "Boxen-Einheiten" 0..8
seg = wrap(seg, 0, n);       // umlaufend
idx = floor(seg);            // Index der linken Box des Paars
frac = seg - idx;            // 0..1 Anteil zur nächsten Box
theta = frac * (pi*0.5);
gLo = cos(theta);            // Gain für Box idx
gHi = sin(theta);            // Gain für Box idx+1
// Verteilen auf 8 Ausgänge per Vergleich (kein Array-Index in genexpr):
out1 = in1 * ((idx==0)*gLo + (idx==7)*gHi);
out2 = in1 * ((idx==1)*gLo + (idx==0)*gHi);
out3 = in1 * ((idx==2)*gLo + (idx==1)*gHi);
out4 = in1 * ((idx==3)*gLo + (idx==2)*gHi);
out5 = in1 * ((idx==4)*gLo + (idx==3)*gHi);
out6 = in1 * ((idx==5)*gLo + (idx==4)*gHi);
out7 = in1 * ((idx==6)*gLo + (idx==5)*gHi);
out8 = in1 * ((idx==7)*gLo + (idx==6)*gHi);
// Hinweis: in der Praxis eleganter mit for-Schleife + poke in ein Data-Objekt.
```

#### 1.3 VBAP (Vector Base Amplitude Panning, Pulkki 1997)
**DSP einfach.** Grundlage ist Ville Pulkki, „Virtual Sound Source Positioning Using Vector Base Amplitude Panning", JAES 45(6): 456–466, Juni 1997. Jeder Lautsprecher wird durch einen Einheitsvektor l in seine Richtung beschrieben. Die gewünschte Quellrichtung ist ein Vektor p. Man wählt die zwei (2D) bzw. drei (3D) Lautsprecher, deren Vektoren p „umspannen", und löst g = p · L⁻¹, wobei L die Matrix aus den Lautsprechervektoren ist. Danach wird g normalisiert (meist auf konstante Leistung, ‖g‖=1). Ergebnis: die Quelle klingt aus genau diesem Boxen-Paar/-Triplett, sehr „punktförmig".

VBAP aktiviert die kleinstmögliche Boxenzahl → sehr präzise Lokalisation, aber Breiten- und Klangfarbenschwankungen bei bewegten Quellen (mal 1, mal 2 Boxen aktiv). 3D braucht eine Triangulation (konvexe Hülle) des Setups.

```genexpr
// ---- VBAP-artiges pairwise panning (2D, zwei Boxen) ----
// Praktisch für ein bekanntes Boxenpaar. Vektoren als Param übergeben.
// p = Zielrichtung (Einheitsvektor px,py); l1,l2 = Boxenrichtungen.
Param px(1), py(0);
Param l1x(1), l1y(0);   // Box 1 Richtung
Param l2x(0), l2y(1);   // Box 2 Richtung
// Inverse der 2x2-Matrix L = [[l1x,l1y],[l2x,l2y]]
det = l1x*l2y - l1y*l2x;
inv = det!=0 ? 1/det : 0;
// g = p * L^-1   (Zeilenvektor * inverse Matrix)
g1 = (px*l2y - py*l2x) * inv;
g2 = (-px*l1y + py*l1x) * inv;
// Negative Gains kappen (Quelle außerhalb des Paars) und Leistungs-Normalisierung:
g1 = clamp(g1, 0, 1e9);
g2 = clamp(g2, 0, 1e9);
norm = sqrt(g1*g1 + g2*g2);
norm = norm>0 ? 1/norm : 0;
out1 = in1 * g1 * norm;
out2 = in1 * g2 * norm;
```
Fertige Implementierungen: `vbap`-External (Pulkki, für Max/MSP und Pd), `spat5.pan~` (Modus VBAP), SPARTA/COMPASS-Panner, ICST. Für vollständiges Setup-Handling (Triangulation, Boxenwahl) nimmt man diese fertigen Objekte statt gen~.

#### 1.4 MDAP (Multiple-Direction Amplitude Panning, Pulkki 1999)
**DSP einfach.** Wie VBAP, aber die Quelle wird an mehreren leicht versetzten Richtungen zugleich gepannt und summiert → mehr aktive Boxen. Vorteil: die Quellbreite und Klangfarbe bleiben *richtungsunabhängig* konstant (kein „Aufblitzen", wenn die Quelle über eine Box läuft), Nachteil: größere scheinbare Quellbreite und geringere Lokalisationsschärfe außerhalb des Zentrums. MDAP ist der Standardweg, um in VBAP kontrollierten „Spread" zu erzeugen.

#### 1.5 DBAP (Distance-Based Amplitude Panning)
**DSP einfach.** Grundlage ist Trond Lossius (BEK, Bergen), Pascal Baltazar & Théo de la Hogue (GMEA, Albi), „DBAP – Distance-Based Amplitude Panning", Proc. ICMC 2009, Montreal. Das Verfahren macht *keine* Annahme über Hörerposition oder Boxenanordnung — im Originalwortlaut: „no assumptions are made concerning the layout of the speaker array nor the position of the listener". Es zählt nur der Abstand jeder Box zur virtuellen Quellposition. Alle Boxen sind immer aktiv; der Gain jeder Box fällt mit ihrer Distanz zur Quelle ab. Die Gains werden so normalisiert, dass die Gesamtleistung konstant bleibt:

g_i = k / d_i^a, mit d_i = Abstand Quelle↔Box i, a aus dem Rolloff R (dB pro Distanzverdopplung; R=6 dB ≈ Freifeld), und k so gewählt, dass Σg_i² = 1. Ein „spatial blur"-Parameter r_s verhindert die Division durch 0, wenn die Quelle genau auf einer Box liegt.

DBAP ist ideal für unregelmäßige Setups, Installationen und Bühnen ohne Sweet-Spot. Nachteil: keine echte „Außen"-Lokalisation, wenn die Quelle die Boxenhülle verlässt (alle Gains gleichen sich an). Die klassische Lossius-Variante erzeugt bei Quellen weit außerhalb Artefakte — Jacob Sundstrom beschreibt in „Speaker Placement Agnosticism: Improving the Distance-based Amplitude Panning Algorithm" (arXiv:2109.08704, 2021), dass die Lossius-Implementierung dort „distorted aural impressions and wildly undulating amplitudes" erzeugt, und liefert eine korrigierte ADBAP-Variante.

```genexpr
// ---- DBAP-Gainberechnung für 4 Lautsprecher ----
// Quellposition (sx,sy); Boxenpositionen als Param; rolloff R in dB.
Param sx(0), sy(0);
Param x1(-1),y1(-1), x2(1),y2(-1), x3(1),y3(1), x4(-1),y4(1);
Param R(6);                        // dB pro Distanzverdopplung
Param blur(0.2);                   // spatial blur (verhindert /0)
a = R / (20*log10(2));             // Exponent aus Rolloff
// Distanzen + blur:
d1 = sqrt((sx-x1)*(sx-x1)+(sy-y1)*(sy-y1) + blur*blur);
d2 = sqrt((sx-x2)*(sx-x2)+(sy-y2)*(sy-y2) + blur*blur);
d3 = sqrt((sx-x3)*(sx-x3)+(sy-y3)*(sy-y3) + blur*blur);
d4 = sqrt((sx-x4)*(sx-x4)+(sy-y4)*(sy-y4) + blur*blur);
g1 = pow(d1, -a); g2 = pow(d2, -a);
g3 = pow(d3, -a); g4 = pow(d4, -a);
// Leistungsnormalisierung: Summe der Quadrate = 1
p = sqrt(g1*g1+g2*g2+g3*g3+g4*g4);
p = p>0 ? 1/p : 0;
out1 = in1*g1*p; out2 = in1*g2*p;
out3 = in1*g3*p; out4 = in1*g4*p;
```
Fertig: `a-dbap2d`/`a-dbap3d` (André Sier, Max), Jamoma-Modul, ICST, SPAT (DBAP-Modus).

#### 1.6 Layer-basiertes Panning
**DSP einfach.** Höhen-/Etagen-Setups (z.B. 3D-Dome) werden oft in horizontale Ringe („Layer") zerlegt: horizontal wird per Pairwise/VBAP gepannt, die vertikale Position kreuzblendet zwischen den Ringen (constant power). Einfach, robust und CPU-günstig, aber weniger exakt als echtes 3D-VBAP/Ambisonics.

#### 1.7 Ambisonics (Encoding/Decoding)
**DSP einfach.** Ambisonics kodiert das Schallfeld in Kugelflächenfunktionen (spherical harmonics), unabhängig vom Lautsprecher-Setup. Eine Monoquelle wird zu B-Format-Kanälen kodiert; ein Decoder rechnet das Feld auf ein beliebiges Boxen-Setup. Höhere Ordnungen (HOA) = mehr Kanäle = schärfere Lokalisation und größerer Sweet-Spot. Standardreferenz ist das frei zugängliche Buch von Franz Zotter & Matthias Frank, *Ambisonics: A Practical 3D Audio Theory* (Springer Open Access, 2019, DOI 10.1007/978-3-030-17207-7).

**Encoding, 1. Ordnung** (Azimut θ, Elevation φ):
- **FuMa/B-Format** (Reihenfolge W,X,Y,Z): W = (1/√2)·s ≈ 0,707·s; X = cos(θ)cos(φ)·s; Y = sin(θ)cos(φ)·s; Z = sin(φ)·s. Das √2 (Gerzon, „Practical Periphony", AES Preprint 1571, 1980) gibt den Richtungskanälen im Mittel gleiche Energie wie W.
- **ACN/SN3D (AmbiX)** (Reihenfolge W,Y,Z,X = ACN 0,1,2,3): W=1·s; Y=sin(θ)cos(φ)·s; Z=sin(φ)·s; X=cos(θ)cos(φ)·s. SN3D garantiert, dass kein Kanal den W-Pegel übersteigt. N3D multipliziert die Richtungskanäle zusätzlich mit √3.

```genexpr
// ---- Ambisonics 1. Ordnung Encoder (AmbiX: W,Y,Z,X, SN3D) ----
// in1 = Monoquelle; az = Azimut, el = Elevation (Radiant)
Param az(0), el(0);
cel = cos(el);
W = in1;                       // SN3D: W = 1
Y = in1 * sin(az) * cel;       // ACN 1
Z = in1 * sin(el);             // ACN 2
X = in1 * cos(az) * cel;       // ACN 3
out1 = W; out2 = Y; out3 = Z; out4 = X;
```

**Decoding (basic/sampling decoder, 2D-Horizontalring, N Boxen)** aus W,X,Y (Z entfällt horizontal):
p_i = (1/N)·(√2·W + X·cos(θ_i) + Y·sin(θ_i)). Das √2 hebt den FuMa-W wieder auf Einheitspegel.

```genexpr
// ---- Einfacher Ambisonics-Decoder (2D, 4 Boxen, FuMa W,X,Y) ----
// Eingänge: in1=W, in2=X, in3=Y ; Boxenazimut als Param.
Param a1(0), a2(1.5708), a3(3.1416), a4(4.7124);  // 0,90,180,270°
N = 4;
s2 = 1.41421356;             // sqrt(2)
out1 = (1/N)*(s2*in1 + in2*cos(a1) + in3*sin(a1));
out2 = (1/N)*(s2*in1 + in2*cos(a2) + in3*sin(a2));
out3 = (1/N)*(s2*in1 + in2*cos(a3) + in3*sin(a3));
out4 = (1/N)*(s2*in1 + in2*cos(a4) + in3*sin(a4));
```

**Decoder-Gewichtung** (entscheidend für die nutzbare Hörfläche, Zotter & Frank 2019, Kap. 4):
- **basic** (Gewichte a_n=1): maximiert den Velocity-Vektor, korrekt nur im Zentrum/bei tiefen Frequenzen, ausgeprägte negative Nebenkeulen.
- **max-rE** (Energievektor-Maximierung, a_n = P_n(cos(137,9°/(N+1,51)))): beste Allround-Lokalisation, empfohlen für Off-Center-Hörer und große Publikumsflächen; für 1. Ordnung Richtungsgewicht ≈ 0,707 (2D).
- **in-phase** (keine negativen Keulen): breiteste Hauptkeule, aber größte nutzbare Fläche, robust auf unregelmäßigen Arrays.
- **AllRAD** (Zotter & Frank, „All-Round Ambisonic Panning and Decoding", JAES 60/10, 2012): dekodiert auf ein dichtes virtuelles t-Design-Boxenset und mappt dieses per VBAP auf die realen (auch unregelmäßigen) Boxen — der De-facto-Standard für Lautsprecherwiedergabe.

**Near-Field-Compensation (NFC).** Kodiert man endliche Distanzen, divergiert der Bass (unendlicher Bass-Boost, mit Ordnung zunehmend; Daniel, „Spatial Sound Encoding Including Near Field Effect", 23rd AES Conf. 2003). NFC-Filter (distance coding filters) kompensieren das; ohne sie ist NFC-HOA nicht praktikabel. Praktische Filter: Adriaensen, „Near Field filters for Higher Order Ambisonics".

**In Max praktisch**: Ambisonics baut man nicht per Hand in gen~ (außer 1. Ordnung als Lernübung), sondern mit **ICST Ambisonics** (`ambiencode~`/`ambidecode~`/`ambipanning~`, bis 11. Ordnung), **IEM Plug-in Suite** (bis 7. Ordnung, AllRADecoder), **HOA-Library/CICM** (`hoa.2d.encoder~` etc.), **spat5** (HOA-Modus), **ambiX**-Plugins.

#### 1.8 Binaurales Rendering (HRTF)
**DSP einfach.** Für Kopfhörer faltet man das Monosignal mit den kopfbezogenen Übertragungsfunktionen (HRIR) für linkes/rechtes Ohr aus der Zielrichtung. Das liefert ILD, ITD und spektrale Reize direkt an den Ohren → Externalisierung und Höhenwahrnehmung. Faltung ist FFT-basiert → nicht in Audio-gen~, sondern `pfft~`, `spat5.virtualspeakers~`, IEM `BinauralDecoder`, `mc.`-Faltung oder externe HRTF-Objekte. Ambisonics→Binaural (virtuelle Lautsprecher + HRTF) ist der gängige Produktionsweg für VR/360.

#### 1.9 Wave Field Synthesis (WFS, Berkhout 1988)
**DSP einfach.** Statt Scheinquellen zu erzeugen, rekonstruiert WFS die *physikalische Wellenfront* (Kirchhoff-Helmholtz-Integral, Huygens-Prinzip) mit einem dichten Lautsprecher-Array. Für jede virtuelle Quelle bekommt jede Box ein eigenes **Delay** (Ankunftszeit der Wellenfront) und eine **Amplitude** (Abstandsabhängig). Kehrt man die Delays um (äußere Boxen zuerst), entsteht eine konkave Wellenfront und die Quelle fokussiert *im Publikumsraum* — man kann um sie herumgehen. Grenzen: Aliasing oberhalb einer Grenzfrequenz (Boxenabstand), sehr hoher Hardware-Aufwand. Die Delay+Amplitude-Logik pro Kanal ist in gen~ prinzipiell abbildbar (viele `delay`-Taps), praktisch nimmt man SPAT Revolution (WFS-Modul), WFSCollider oder Instituts-Systeme.

---

### 2. Trajektorien und Bewegungserzeugung

Alle Trajektorien liefern letztlich eine Position (Winkel oder x/y/z), die in einen der Panner (Abschnitt 1) geht. Wichtig: **Bewegung erzeugen ≠ Bewegung rendern**. Man trennt Positionsgenerator und Panner.

#### 2.1 Rotation (Kreis) und Ellipse
Kreis: x = r·cos(ωt), y = r·sin(ωt). Ellipse: x = a·cos(ωt), y = b·sin(ωt). Ein Phasor liefert die Zeitbasis.

```genexpr
// ---- Rotations-/Ellipsen-Trajektorie ----
Param freq(0.2);   // Umläufe pro Sekunde
Param a(1), b(0.6); // Halbachsen (a=b -> Kreis)
phase = phasor(freq);          // 0..1 rampe
ang = phase * 2 * pi;
out1 = a * cos(ang);   // x
out2 = b * sin(ang);   // y
out3 = atan2(out2, out1); // Azimut (falls Panner Winkel will)
```

#### 2.2 Spirale (Radius über Zeit)
Radius wächst/schrumpft, während der Winkel umläuft → Quelle spiralt nach außen/innen. r(t) = r0 + k·t (oder oszillierend). Musikalisch: „Hereinziehen"/„Wegschleudern".

```genexpr
// ---- Spirale ----
Param rotFreq(0.3), radFreq(0.05);
ang = phasor(rotFreq) * 2 * pi;
rad = 0.5 + 0.5*sin(phasor(radFreq)*2*pi); // Radius oszilliert 0..1
out1 = rad*cos(ang);
out2 = rad*sin(ang);
```

#### 2.3 Pendel / Oszillation
Sinus-LFO auf einer Achse (oder Winkel), evtl. mit `fold` für „abprallende" Bewegung. x = A·sin(ωt). Auto-Panning mit LFO ist der einfachste Fall.

#### 2.4 Lissajous-Figuren
Zwei Oszillatoren unterschiedlicher Frequenz/Phase auf x und y: x = A·sin(f_x·t + δ), y = B·sin(f_y·t). Ganzzahlige Frequenzverhältnisse ergeben geschlossene Figuren, irrationale nie schließende, quasi-chaotische Bahnen — sehr ergiebig für sich langsam wandelnde Raumbewegungen.

```genexpr
// ---- Lissajous-Trajektorie ----
Param fx(0.2), fy(0.3), phase_x(0);
Param A(1), B(1);
// Zeit-Integrator (accum-Ersatz per History):
History tprev(0);
t = tprev + 1/samplerate;
tprev = t;
x = A * sin(2*pi*fx*t + phase_x);
y = B * sin(2*pi*fy*t);
out1 = x; out2 = y;
```

#### 2.5 Brownsche Bewegung / Random Walk
**DSP einfach.** Statt absoluter Zufallsposition addiert man in jedem Schritt eine kleine Zufallsänderung: pos += rate·noise. Das ergibt eine glatte, „driftende" Bahn (im Gegensatz zum sprunghaften weißen Rauschen). Mit Grenzen (`clamp`/`fold`) hält man die Quelle im Raum. Rate-limitiert man über `latch`, entstehen ruhigere Schritte.

```genexpr
// ---- Brownscher Random Walk als Positionsgenerator (x,y) ----
Param step(0.001);   // Schrittweite / "Temperatur"
Param rate(30);      // neue Zufallsrichtung pro Sekunde
History xpos(0), ypos(0);
// rate-limitierter Zufall via sample&hold:
trig = phasor(rate);
d = delta(trig);              // Sprung bei Wrap des Phasors
newx = latch(noise(), d<0);  // neue Zufallsrichtung bei jedem Zyklus
newy = latch(noise(), d<0);
xpos = clamp(xpos + step*newx, -1, 1);
ypos = clamp(ypos + step*newy, -1, 1);
out1 = xpos; out2 = ypos;
```

#### 2.6 1/f-Rauschen als Steuerung
**DSP einfach.** Weißes Rauschen ist zu zappelig, Random Walk driftet zu stark. 1/f- („pink") Rauschen liegt dazwischen und wirkt „natürlich/organisch" — ideal für lebendige, nicht vorhersehbare, aber nicht chaotische Bewegung. Erzeugung z.B. über gefiltertes weißes Rauschen (mehrere Ein-Pol-Tiefpässe, Voss-McCartney-Algorithmus) oder Summe mehrerer rate-limitierter Zufallsprozesse.

#### 2.7 Chaos-Systeme (Lorenz-Attraktor)
**DSP einfach.** Deterministisches, aber nie repetitives System dreier gekoppelter Differentialgleichungen. Man integriert schrittweise (Euler) und nutzt x,y,z als Koordinaten oder Steuergrößen. Klingt „lebendig", umkreist zwei Zentren (Schmetterlingsform).

```genexpr
// ---- Lorenz-Attraktor als 3D-Positionsgenerator ----
Param sigma(10), rho(28), beta(2.6667);
Param dt(0.005);   // Integrationsschritt (klein halten!)
History x(0.1), y(0), z(0);
dx = sigma*(y - x);
dy = x*(rho - z) - y;
dz = x*y - beta*z;
x = x + dt*dx;
y = y + dt*dy;
z = z + dt*dz;
// auf sinnvollen Bereich skalieren:
out1 = x*0.03; out2 = y*0.03; out3 = (z-25)*0.03;
```

#### 2.8 Interpolation zwischen Breakpoints, Easing, Geschwindigkeitskurven
Man definiert Wegpunkte und interpoliert (linear, cosine, cubic/Catmull-Rom). „Easing" (langsam-schnell-langsam) macht Bewegungen musikalisch: statt linearer Rampe eine S-Kurve (smoothstep: 3t²−2t³). In gen~ mit `mix`, `interp` oder eigener Kurvenformel; Breakpoint-Listen kommen von außen (`line`/`function`/`zmap`) oder aus einem `Data`-Buffer.

#### 2.9 Quantisierung auf Lautsprecherpositionen („Jumping"/Sprungtechniken)
**DSP einfach.** Statt kontinuierlich zu pannen, springt die Quelle auf diskrete Boxen — das nutzt den Präzedenzeffekt und erzeugt rhythmische, „punktuelle" Raumfiguren (Stockhausen-Tradition). Man rundet die Position auf die nächste Boxenrichtung (`round`) und schaltet hart oder mit sehr kurzer Blende um.

#### 2.10 Feldrotation im Ambisonics-Feld
**DSP einfach.** Statt jede Quelle einzeln zu bewegen, rotiert man das *gesamte* B-Format-Feld mit einer Rotationsmatrix (1. Ordnung nur auf X/Y/Z). Sehr effizient (alle Quellen zugleich) und CPU-billig — Grundlage für Head-Tracking im Binauralen. Auch Tilt/Tumble/Mirroring gehören hierher (Abschnitt 6.6).

```genexpr
// ---- Ambisonics-Feldrotation (Yaw) 1. Ordnung, FuMa X,Y ----
// Eingänge in1=X, in2=Y ; W,Z bleiben unverändert (hier weggelassen)
Param yaw(0);
c = cos(yaw); s = sin(yaw);
out1 = in1*c - in2*s;   // X'
out2 = in1*s + in2*c;   // Y'
```

---

### 3. Distanz- und Raumsimulation

#### 3.1 Abstandsgesetz (1/r) und Luftabsorption
**DSP einfach.** Schalldruck fällt mit 1/r (−6 dB pro Distanzverdopplung). Zugleich absorbiert Luft hohe Frequenzen stärker → ferne Quellen klingen dumpfer. Das simuliert man mit einem **Ein-Pol-Tiefpass**, dessen Cutoff mit der Distanz sinkt. In gen~ ist der Ein-Pol-Tiefpass die Kombination `mix` + `History`: y += b·(x − y), mit b = Cutoff-Koeffizient (0..1).

```genexpr
// ---- Distanzmodell: 1/r + Luftabsorptions-Tiefpass ----
// in1 = Signal; Param dist = Abstand (>= mindist)
Param dist(1), mindist(0.3);
d = max(dist, mindist);
gain = mindist / d;                 // 1/r, auf mindist normiert
// Cutoff-Koeffizient sinkt mit Distanz (mehr Absorption fern):
Param absorb(0.02);                 // Absorptionsstärke
b = clamp(1 - absorb*d, 0.02, 1);   // 1 = offen, ->0 = dumpf
History y(0);
y = y + b*(in1 - y);                // Ein-Pol-Tiefpass
out1 = y * gain;
```

#### 3.2 Direkt-/Diffusschall-Verhältnis, frühe Reflexionen, Nachhall pro Kanal
**DSP einfach.** Nähe = viel Direktschall, wenig Hall; Ferne = umgekehrt. Man kreuzblendet Direktsignal und Hallanteil abhängig von der Distanz (D/R-Ratio). Frühe Reflexionen (erste 5–80 ms) geben Distanz- und Raumgrößen-Reize; sie werden als kurze, richtungsabhängige Delays je Kanal gesetzt. Später diffuser Nachhall wird idealerweise *dekorreliert* auf mehrere Kanäle verteilt (sonst kollabiert der Raum in die Mitte). Fertige Raum-Engines: `spat5.spat~`/`spat5.reverb~` (perzeptiver Ansatz mit direkt/früh/spät-Segmenten), IEM `RoomEncoder`.

#### 3.3 Doppler-Effekt (variable Verzögerungszeit)
**DSP einfach.** Der Doppler-Effekt ist *kein* separater Pitch-Shifter — er entsteht automatisch, wenn sich die Verzögerungszeit (= Laufzeit Quelle→Hörer = Distanz/Schallgeschwindigkeit) *ändert*: verkürzt sie sich, wird der Ton höher, verlängert sie sich, tiefer. Man braucht also eine **fraktionale, interpolierte Delay-Leitung**, deren Länge = Distanz/343 m/s.

In gen~ liefert das `delay`-Objekt genau das: mit `@interp linear` (Standard) oder `@interp cubic`/`spline`. **Zipper-Noise/Klicks** entstehen, wenn sich die Delayzeit sprunghaft ändert → Positionssignal glätten (Ein-Pol-Tiefpass auf die Distanz) und höherwertige Interpolation wählen. Wichtig: gen~-`delay` ist ein *tapping buffer* — kontinuierliche Zeitänderung erzeugt genau den gewünschten Pitch-Effekt (anders als das intern gerampte `delay~`).

```genexpr
// ---- Doppler via interpoliertem Delay ----
// in1 = Signal; Param dist = Abstand in Metern
Param dist(1);
Param smooth(0.001);       // Glättung gegen Zipper
History dprev(1);
dsm = dprev + smooth*(dist - dprev);  // Distanz glätten
dprev = dsm;
c = 343;                   // Schallgeschwindigkeit m/s
delsamps = (dsm / c) * samplerate;    // Delay in Samples
// max. Delay 2 s, interpoliert:
Delay dl(96000, 1);
y = dl.read(delsamps, interp="cubic");
dl.write(in1);
// zusätzlich 1/r-Pegel:
out1 = y * (1 / max(dsm, 0.3));
```

#### 3.4 Nahfeld-Effekt / Bass-Boost, NFC, Parallaxe
Sehr nahe Quellen zeigen einen Bass-Boost (Proximity-Effekt); in Ambisonics ist das der oben genannte NFC-Aspekt. Bewegt sich der Hörer aus dem Zentrum, verschieben sich Winkel (Parallaxe) — dafür braucht es Nahfeldkompensation bzw. objektbasierte Systeme, die Hörerposition kennen. Diese Feinheiten liefern spat5, IEM (`RoomEncoder`/NFC), ICST fertig.

---

### 4. Breite und Diffusität (Dekorrelation)

#### 4.1 Dekorrelation (Kendall 1995)
**DSP einfach.** Grundlage ist Gary S. Kendall, „The Decorrelation of Audio Signals and Its Impact on Spatial Imagery", Computer Music Journal 19(4): 71–87, 1995. Aus einem Monosignal macht man mehrere Signale, die *gleich klingen*, aber *unterschiedliche Wellenformen/Phasen* haben. Werden sie auf verschiedene Boxen gelegt, wird die Quelle breit/umhüllend statt punktförmig, ohne Kammfilter-Kollaps. Kendall nennt drei Wege: (a) **Random-Phase-FFT** — flaches Betragsspektrum, Phasen zufällig ±π, per IFFT zu einem FIR-Filter (→ `pfft~`/Faltung, nicht Audio-gen~); (b) **Allpass-Ketten** mit randomisierten, langsam variierenden Koeffizienten (in gen~ machbar); (c) **Velvet Noise** (spärliche ±1-Impulse) als kurze Faltung.

Typische Fallstricke: zu viel Time-Smearing zerstört Transienten (Faustregel: ≤60 ms bei tiefen, 10–20 ms bei hohen Frequenzen); bei Mono-Summierung entstehen Kammfilter.

```genexpr
// ---- Dekorrelation über Allpass-Kette (ein Kanal) ----
// Erzeugt eine phasenveränderte, klanggleiche Variante von in1.
// Vier First-Order-Allpässe mit unterschiedlichen Koeffizienten.
Param k1(0.6), k2(-0.5), k3(0.7), k4(-0.45);
History x1(0), y1(0);
ap1 = -k1*in1 + x1 + k1*y1;  x1 = in1;  y1 = ap1;
History x2(0), y2(0);
ap2 = -k2*ap1 + x2 + k2*y2;  x2 = ap1;  y2 = ap2;
History x3(0), y3(0);
ap3 = -k3*ap2 + x3 + k3*y3;  x3 = ap2;  y3 = ap3;
History x4(0), y4(0);
ap4 = -k4*ap3 + x4 + k4*y4;  x4 = ap3;  y4 = ap4;
out1 = ap4;
// Für N Kanäle: N solcher Ketten mit je anderen (randomisierten) k-Werten.
// Koeffizienten langsam per rate-limitiertem noise() modulieren = dynamische Dekorrelation.
```

#### 4.2 Quellbreite/Spread in VBAP und Ambisonics
VBAP: Spread über MDAP (mehr Boxen). Ambisonics: **Ordnungsreduktion** verbreitert — je niedriger die effektive Ordnung eines Anteils, desto breiter/diffuser die Quelle (kontrollierter „Directional Blur"). IEM `MultiEncoder`/`DirectionalCompressor` und spat5 bieten Spread-Parameter direkt.

#### 4.3 Rotation der Phasenbeziehungen / Diffusion
Langsam variierende Allpass-Phasen (4.1) oder Feedback-Delay-Netzwerke erzeugen einen sich bewegenden, diffusen Klangschleier — Basis von „stereoisierten"/Multichannel-Reverbs.

---

### 5. Granulare und mikro-zeitliche Spatialisation

**DSP einfach.** In der granularen Synthese wird Klang in kurze Körner (1–100 ms) zerlegt (Curtis Roads, *Microsound*, MIT Press 2001). Bei granularer *Spatialisation* bekommt **jedes Korn eine eigene Position**: McLeran, Roads, Sturm & Shynk beschreiben in „Granular Sound Spatialization Using Dictionary-Based Methods" (Proc. 5th Sound and Music Computing Conference, Berlin 2008), dass „spatialisation can now be explored down to the microsound level of sonic structure, where individual spatial positions are assigned to every sonic grain". Man kann Körner streuen (scattering), konvergieren/divergieren lassen oder panoramisch verteilen — es entsteht ein „Wolken"-Raum statt einer Punktquelle. Entscheidend: **Korn-Rate und Bewegungsrate trennen** (die Wolke kann ruhen, während die Körner räumlich zittern, oder umgekehrt).

Praktisch: In Max baut man das mit `mc.`-Objekten, `poly~`, MuBu (`mubu.granular~`) oder mit einer gen~-Korn-Engine, bei der jedes Korn beim Start eine Zufallsposition/-richtung erhält und über einen der Panner (VBAP/DBAP/Ambisonics) gerendert wird. Jedes Korn kann zusätzlich eine eigene Distanz/Filterung bekommen (spektral-räumliche Streuung). Fallstricke: bei hoher Dichte verschmieren Einzelpositionen zur diffusen Textur (kann erwünscht sein); pro Korn eigene HRTF/Encodierung ist CPU-intensiv.

```genexpr
// ---- Skizze: pro Korn eigene Azimut-Position (Ein-Korn-Voice) ----
// erzeugt neue Zufallsposition je Korn.
Param spread(1);   // 0=alle mittig, 1=volle Streuung
grainPhase = phasor(20);         // 20 Körner/s (Beispiel)
newgrain = delta(grainPhase) < 0;
History az(0);
az = latch(spread * pi * noise(), newgrain);  // neue Richtung pro Korn
// Fenster (Hann) über das Korn:
win = 0.5 - 0.5*cos(2*pi*grainPhase);
g = in1 * win;
// constant-power auf Stereo als minimaler Renderer:
th = (az+pi)/(2*pi) * (pi*0.5);
out1 = g*cos(th); out2 = g*sin(th);
```

---

### 6. Spektrale Spatialisation und Feldoperationen

#### 6.1 Filterbank-Aufteilung (Crossover) — in gen~ machbar
**DSP einfach.** Man zerlegt den Klang mit Crossover-Filtern in Frequenzbänder und schickt jedes Band auf eine andere Box/Richtung. Das ist die zeitbereichs-basierte, gen~-taugliche Variante der spektralen Spatialisation. Linkwitz-Riley-Crossover (zwei kaskadierte Butterworth) sind phasenkohärent.

```genexpr
// ---- 3-Band-Crossover-Filterbank (Ein-Pol, einfach) ----
// in1 -> tief/mittel/hoch auf 3 Ausgänge (Boxen).
Param fc_lo(200), fc_hi(2000);
blo = clamp(fc_lo/samplerate*2*pi, 0, 1);
bhi = clamp(fc_hi/samplerate*2*pi, 0, 1);
History l1(0);  l1 = l1 + blo*(in1 - l1);   // Tiefpass 1
low = l1;
History l2(0);  l2 = l2 + bhi*(in1 - l2);   // Tiefpass 2
high = in1 - l2;                             // Hochpass = Signal - TP
mid = l2 - low;                              // Band = TP2 - TP1
out1 = low;    // -> Box 1
out2 = mid;    // -> Box 2
out3 = high;   // -> Box 3
```

#### 6.2 FFT-Bin-Verteilung / spektrales Panning — nicht in Audio-gen~
**DSP einfach.** Feiner als Filterbänke: jeder FFT-Bin (oder Bin-Gruppe) bekommt eine eigene Position; benachbarte Frequenzen können an entgegengesetzte Boxen. Ergebnis: ein einzelner Klang wird über den ganzen Raum „aufgefächert". **Braucht FFT** → `pfft~` (ggf. mit gen~ im Subpatch), `pvoc`, Torchia/Lippe-Ansatz (2004), oder Jitter-Matrizen. Nicht im Audio-gen~ realisierbar (kein natives FFT).

#### 6.3 Normandeaus „Timbre Spatialisation" (Organised Sound 14/3, 2009)
**DSP einfach.** In „Timbre Spatialisation: The Medium is the Space" (Organised Sound 14(3): 277–285, ZKM-20-Years-Ausgabe, Dezember 2009, DOI 10.1017/S1355771809990094) zerlegt Robert Normandeau einen komplexen Klang mit Bandpässen in **4 bis 16 Bänder** und spatialisiert jedes unabhängig — der Raum und die Ohren des Hörers dienen als „Summation", und „das Spektrum existiert als Ganzes nur virtuell im Konzertraum". McLuhans „the medium is the message" wird zu „the medium is the space". Umsetzbar mit der Crossover-Bank (6.1) plus je Band eigener Trajektorie.

#### 6.4 Bourges Gmebaphone/Cybernéphone — Frequenzbandaufteilung als Instrument
Das Gmebaphone (Clozier, Bourges, ab 1973) verteilte den Klang systematisch nach Frequenzbändern auf klanglich unterschiedliche Lautsprechergruppen — historischer Vorläufer der spektralen Spatialisation und der „Lautsprecher-Orchestrierung".

#### 6.5 Matrix-Mixing und Gain-Matrizen
**DSP einfach.** Jede Amplituden-Spatialisation ist letztlich eine Matrixmultiplikation: Ausgangs-Kanäle = Gain-Matrix × Eingangs-Kanäle. Statisches oder dynamisches Routing (Upmixing, Umverteilung, kanalunabhängiges/objektbasiertes Rendering) baut man mit `matrix~`, `mc.matrix~` oder in gen~ als Summen gewichteter Eingänge. Objektbasiertes Rendering trennt „was" (Klangobjekt + Metadaten Position) von „wie" (Renderer für das konkrete Setup) — das Prinzip hinter Dolby Atmos, spat5-Objekten und ADM.

#### 6.6 Ambisonics-Feldoperationen (Rotation, Tilt, Tumble, Mirroring, Zoom/Dominance, Focus/Blur)
**DSP einfach.** Am kodierten Feld kann man mit einfachen Matrizen den *ganzen Raum* manipulieren (Ambisonic Toolkit, Lossius & Anderson 2014):
- **Rotate/Tilt/Tumble**: Drehung um z-/x-/y-Achse (Feldrotation, 2.10).
- **Mirroring**: Spiegelung aller Quellen an eine Achse.
- **Dominance/Zoom**: Lautstärke-Balance zugunsten einer Richtung verschieben (wie „Hineinzoomen" in eine Klanglandschaft); kann Pegel stark verändern.
- **Focus/Press/Push**: „betonen" bzw. „drücken" von Elementen in Zielrichtung (Cardioid-Charakteristik).
- **Directional Blur**: Ordnungsreduktion → Feld wird diffuser/weniger gerichtet.
Fertig in ATK (Reaper/SuperCollider), IEM (`DirectivityShaper`, `SceneRotator`), spat5.

#### 6.7 Beamforming
Umkehrung des Encodings: aus dem Feld gerichtete „Strahlen" extrahieren (virtuelle Richtmikrofone), um Teile des Feldes zu isolieren oder Reflexionen zu dämpfen (Van Veen & Buckley 1988).

---

### 7. Zeit-, Phasen- und Netzwerktechniken

#### 7.1 Zeitbasiertes Panning (Präzedenz-/Haas-Effekt)
**DSP einfach.** Kommt derselbe Klang aus zwei Boxen, aber einer 1–35 ms später, lokalisieren wir ihn bei der *früheren* Box (Präzedenzeffekt), obwohl beide gleich laut sind. Als Lokalisationswerkzeug: kleine Delays statt/zusätzlich zu Pegeldifferenzen. Vorsicht: über ~35–50 ms kippt es in ein hörbares Echo. In gen~ trivial mit `delay`.

#### 7.2 Phasen-/Polaritäts-Tricks, phantom vs. real source
Polaritätsumkehr und Phasenmanipulation zwischen Kanälen verbreitern oder „entörtlichen" Klänge (out-of-phase → diffus, außerhalb der Boxen). „Phantom source" = Scheinquelle zwischen Boxen (fragil, sweet-spot-abhängig); „real source" = Klang liegt direkt auf einer Box (stabil, aber örtlich fixiert). Bewusster Wechsel ist ein Gestaltungsmittel (BEAST/Diffusionspraxis).

#### 7.3 Auto-Panning mit LFOs, Spatial Modulation
LFO auf die Panning-Position = Auto-Panning (2.3). Bei Audiorate wird daraus **Spatial Modulation** (ringmodulationsartiges Panning, McGee 2015 „spatial modulation synthesis") — die Bewegung wird so schnell, dass sie als Klangfarbe/Seitenbänder hörbar wird statt als Bewegung.

#### 7.4 Multichannel-Feedback-/Delay-Netzwerke im Raum, Delay-Kanonen
**DSP einfach.** Delays zwischen Boxen (mit Feedback) lassen einen Impuls durch den Raum „wandern" oder sich zu Texturen aufschaukeln (Feedback Delay Network, FDN). „Delay-Kanonen"/Trajektorien-Doubling: dasselbe Material zeitversetzt auf mehrere Boxen → räumlich verteilte Kanons. In gen~ mit mehreren `delay @feedback 1`-Leitungen und einer Rückkopplungsmatrix.

#### 7.5 Speaker-Orchestration (Lautsprecherfarbe als Gestaltungsmittel)
Im Acousmonium (Bayle, GRM, 1974) und BEAST (Harrison) sind Lautsprecher *nicht* neutral: verschiedene Typen/Größen/Positionen haben eigene Klangfarben („Solisten", Ferne/Nähe, Höhen-„Trees"). Der Diffuseur „orchestriert" den Klang über diese Farbpalette — ein eigenständiges kompositorisches Mittel.

---

### 8. Klangregie / Sound Diffusion (Live-Interpretation)

**DSP einfach.** Klangregie ist die *Live-Interpretation* einer (meist Stereo-)Aufnahme über viele Lautsprecher am Mischpult: der Diffuseur schickt das Stereopaar per Fader auf wechselnde Lautsprecherpaare/-gruppen im Saal und „spielt" so den Raum in Echtzeit. Jonty Harrison betont in „Diffusion: theories and practices, with particular reference to the BEAST system" (eContact! 2.4, 1999), dass Diffusion ausdrücklich *nicht* „the random throwing-around of sound which destroys the composer's intentions" sei, sondern eng mit der Komposition verwoben — der Diffuseur agiert als „zweiter räumlicher Komponist". Zwei Schulen:
- **Acousmonium (GRM, Bayle 1974)**: „Orchester von Lautsprechern", meist auf der Bühne, nach Klangcharakter angeordnet, teils asymmetrische „Solisten".
- **BEAST (Birmingham ElectroAcoustic Sound Theatre, gegründet 1982 unter Jonty Harrison)**: über 100 Lautsprecherkanäle, in Paaren/Ringen von vorn nach hinten dupliziert. Das Grund-Setup („Main Eight") besteht aus vier Paaren namens Main, Wide, Distant und Rear, dazu Sub-Bins und Hochton-„Trees" über dem Publikum.

Praktisch ist das eine dynamische Gain-Matrix (6.5), oft mit motorisierten Fadern/Tablet-Controllern. Software/Systeme: BEASTmulch, M2, MuBu-Mapping, spat5 (Matrix/Diffusion). Grenzen der Live-Diffusion: weniger Präzision als studiofixierte Automation, stark saal- und rehearsal-abhängig.

---

### 9. Werkzeuge im Überblick (was liefert die Technik fertig?)

- **IRCAM spat5** (Max, seit 1991; >300 Module): alle Panning-Verfahren (VBAP, DBAP, HOA, WFS, Binaural, Stereo AB/XY/MS), perzeptiver Reverb (direkt/früh/spät), `spat5.panoramix`-Mixing, ACN/FuMa/N3D/SN3D. Kostenlos über IRCAM Forum. **SPAT Revolution** (Flux/IRCAM): DAW-/Standalone-Version für immersives Mixing inkl. WFS-Modul.
- **ICST Ambisonics** (ZHdK, Max-Externals, bis 11. Ordnung): `ambiencode~`/`ambidecode~`/`ambipanning~`, GUI + Trajektorien/Splines. Kostenlos (ambisonics.ch).
- **IEM Plug-in Suite** (VST/open source, bis 7. Ordnung): `MultiEncoder`, `AllRADecoder`, `BinauralDecoder`, `SceneRotator`, `DirectivityShaper`, `RoomEncoder`, `EnergyVisualizer`. Kostenlos.
- **HOA-Library / CICM** (Max/Pd/openFrameworks): `hoa.2d/3d.*`.
- **Zirkonium** (ZKM, Miyama/Dipper/Brümmer): Toolkit für räumliche Komposition/Performance, Dome-Wiedergabe.
- **HoloEdit / Holophonix** (Amadeus/GRAME): Offline-Trajektorien-Editor mit Scripting (Bascou 2010) bzw. Renderer.
- **ambiX** (Kronlachner): HOA-Plugins inkl. Rotation/Transformation. **ATK** (Ambisonic Toolkit): Rotate/Tilt/Tumble/Focus/Zoom (Reaper/SC). **SPARTA/COMPASS** (Aalto/McCormack): VBAP-Panner, HOA, Binaural. **Envelop for Live** (Ambisonics in Ableton). **mc.-Objekte** (Max 8/9): native Mehrkanal-Infrastruktur. **MuBu** (IRCAM): granulare/korpusbasierte Werkzeuge. **BEASTmulch/M2**: Diffusionssysteme. **WFSCollider**: WFS in SuperCollider.

**Wann was?** VBAP → präzise Punktquellen, dichte Ringe/Dome. DBAP → unregelmäßige Installations-Setups, kein Sweet-Spot. Ambisonics (max-rE/AllRAD) → rotierbare Felder, größere Flächen, VR/Binaural. WFS → große Publikumsflächen, fokussierte Quellen, wenn Array-Dichte vorhanden. Dekorrelation/Spektralstreuung → Breite, Umhüllung, Timbre-Spatialisation. Diffusion → Live-Interpretation von Stereo/Reduktionen.

## Recommendations

1. **Lernpfad (jetzt starten)**: Baue in gen~ zuerst den constant-power Stereo-Panner, dann den 8-Kanal-Rotations-Panner und das Distanzmodell (1/r + Ein-Pol-TP). Das vermittelt die Kernbausteine (Winkel→Gains, `History`-Filter). Danach Doppler mit `delay @interp cubic` und den Brownschen Random Walk. Diese fünf Patches decken den Großteil der praktischen Bewegungsarbeit ab.
2. **Für echte Mehrkanal-Produktion nicht das Rad neu erfinden**: Nutze für VBAP/DBAP/Ambisonics/WFS/Binaural die fertigen Suiten (spat5 kostenlos über IRCAM Forum; IEM & ICST kostenlos/open source). Reserviere gen~ für das, was dort *nicht* fertig ist: eigene Trajektorien-Generatoren, mikro-zeitliche/granulare Spatialisation, maßgeschneiderte Dekorrelatoren, Distanz-/Doppler-Modelle, Feedback-Netzwerke.
3. **Ambisonics-Konvention früh festlegen**: Arbeite durchgängig in **AmbiX (ACN/SN3D)** — es ist der De-facto-Standard und vermeidet die W,X,Y,Z↔W,Y,Z,X-Falle. Verwende einen **max-rE- oder AllRAD-Decoder** (IEM `AllRADecoder`), sobald das Publikum größer als der Sweet-Spot ist.
4. **Zipper-/Kammfilter-Fallstricke vermeiden**: Positionssignale immer glätten (Ein-Pol-TP), bei Doppler höherwertige Interpolation; bei Dekorrelation Time-Smearing begrenzen (≤ ~20 ms hoch, ≤ ~60 ms tief) und niemals dekorrelierte Kanäle auf Mono summieren.
5. **Spektrale Spatialisation**: Für 4–16 Bänder (Normandeau) reicht die gen~-Crossover-Bank; für feine FFT-Bin-Verteilung wechsle zu `pfft~` (mit gen~ innen) oder `spat5`/Jitter. Plane die CPU-Last ein.
6. **Live-Diffusion**: Wenn du Stereo-/Reduktionsmaterial im Saal spielst, baue eine dynamische Gain-Matrix (`mc.matrix~`) mit Fader-/Tablet-Controller und *probe im Raum* — die musikalischen Entscheidungen (Rate, Zahl gleichzeitiger Boxen) sind saalabhängig, nicht theoretisch festlegbar (Harrison).

**Schwellen, die die Empfehlung ändern**: Sitzt das Publikum eng um den Sweet-Spot (< ~1,5 m Radius), genügt basic-Decoder/VBAP; darüber max-rE/AllRAD/DBAP. Steht ein sehr dichtes Frontarray (< ~0,4 m Boxenabstand, wie in SPAT-Revolution-Empfehlungen für WFS) zur Verfügung, wird WFS mit fokussierten Quellen sinnvoll; sonst bleib bei Amplitudenverfahren. Braucht die Arbeit Höhen-/3D, wechsle von Layer-Panning zu echtem 3D-VBAP oder HOA ≥ 3. Ordnung.

## Caveats
- **genexpr-Codebeispiele sind lehrhafte Gerüste**, keine getesteten Produktionspatches. Details der Delay-/Latch-Syntax variieren zwischen Max-Versionen; prüfe deine Version gegen die aktuelle GenExpr-Referenz (Cycling '74). Für Tabellen/mehrere identische Ketten sind `for`-Schleifen + `Data`/`poke` sauberer als der hier gezeigte explizite Ansatz. Cycling '74 selbst weist darauf hin, dass es keine vollständige offizielle GenExpr-Sprachreferenz gibt — vieles ist über Tutorials und Forenbeiträge dokumentiert.
- **`samplerate`/Integratoren**: Nicht alle hier verwendeten Bezeichner sind in jeder Version identisch benannt; im Zweifel Zeit-Integratoren per `History` selbst bauen (wie in 2.4 gezeigt) statt `accum` anzunehmen.
- **max-rE-Zahlenwert für 1. Ordnung**: Die genaue Dezimalgewichtung sollte gegen die Tabellen/Anhänge in Zotter & Frank (2019) verifiziert werden; die angegebene Formel und der 2D-Wert ≈0,707 sind korrekt hergeleitet, aber Konventionen (2D vs. 3D, Normalisierung) unterscheiden sich je Quelle.
- **FFT im Audio-gen~**: existiert nicht — alle FFT-basierten Verfahren (Random-Phase-Dekorrelation, spektrales Bin-Panning, HRTF-Faltung) brauchen `pfft~`/MSP/Jitter. Das ist eine harte Grenze der gen~-Umgebung.
- **Winkel-/Koordinatenkonventionen** unterscheiden sich stark zwischen Literatur und Software (θ=Azimut vs. Elevation; Grad vs. Radiant; +X vorn/links). Die hier gewählte Konvention (θ=Azimut, φ=Elevation, +X vorn, +Y links) folgt AmbiX; beim Übertragen in konkrete Externals immer die dortige Konvention prüfen.
- Einige zitierte Quellen sind hinter Paywalls (Cambridge/Organised Sound, JAES); frei zugänglich sind u.a. Zotter & Frank (Springer Open Access), das DBAP-Paper (jamoma.org), Harrisons BEAST-Text (econtact.ca), Sundstroms ADBAP (arXiv) und die ICST/IEM-Dokumentation.

### Zentrale Literatur (Auswahl)
Pulkki (VBAP, JAES 1997; MDAP, WASPAA 1999) · Lossius/Baltazar/de la Hogue (DBAP, ICMC 2009) · Sundstrom (ADBAP, arXiv 2021) · Gerzon (Periphony/Practical Periphony, AES) · Daniel (HOA-Dissertation 2001; NFC, AES 2003) · Zotter & Frank (*Ambisonics*, Springer Open Access 2019; AllRAD, JAES 2012) · Kendall (Dekorrelation, CMJ 1995) · Normandeau (Timbre Spatialisation, Organised Sound 2009) · Chowning (Moving Sound Sources, JAES 1971) · Roads (*Microsound*, MIT 2001; *Composing Electronic Music*, OUP 2015) · McLeran/Roads/Sturm/Shynk (granulare Spatialisation, SMC 2008) · Berkhout (WFS, JASA 1993) · Harrison (BEAST, eContact! 1999) · Torchia/Lippe (FFT-Spatialisation, 2004).