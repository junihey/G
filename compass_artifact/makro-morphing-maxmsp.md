# Makro-Morphing zwischen Parameter-Zuständen
## Best-Practice-Anleitung für Max/MSP

---

## 0. Die Grundarchitektur

Ein Makrocontroller ist eine Funktion `f: [0,1] → ℝ^N` — ein Regler hinein, N Parameterwerte heraus. Der Parameterraum ist N-dimensional, aber dein Makro ist nur ein *Pfad* durch diesen Raum. Bei zwei Makros (XY-Pad) wird daraus `f: [0,1]² → ℝ^N`.

Die Kette in vier Stufen:

```
Makrowert t (0…1)
    ↓
[1] Kurvenauswertung  →  normalisierte Parameterwerte (0…1)
    ↓
[2] Smoothing         →  zipper-freie normalisierte Werte
    ↓
[3] Denormalisierung  →  physikalische Werte (Hz, dB, ms …)
    ↓
[4] Koeffizienten     →  DSP
```

Die Reihenfolge ist nicht beliebig. Smoothing gehört in die normalisierte Domäne (Stufe 2), weil ein One-Pole dort gleichmäßig wirkt; in Hz geglättet würde eine Cutoff-Fahrt im Bass kriechen und in den Höhen springen.

---

## 1. Laufzeit vs. LUT — die wichtigste Entscheidung

Es gibt zwei grundsätzlich verschiedene Ansätze, und die Wahl bestimmt die gesamte Struktur.

### Laufzeit-Interpolation

Du hältst deine Zustandsmatrix im Speicher und rechnest bei jedem Update:

1. finde die zwei (oder mehr) relevanten Zustände für den aktuellen Makrowert
2. blende zwischen ihnen

**Vorteile:** Zustände können sich zur Laufzeit ändern (User speichert einen neuen Preset, Zustände werden umsortiert). Kein Vorbereitungsschritt. Speicherbedarf = Anzahl Zustände × Parameter.

**Nachteile:** Kosten steigen mit der Interpolationsart. Bei Splines brauchst du Nachbarsuche und Tangentenberechnung im Audiothread oder zumindest im Kontrollpfad. Bei 50 Parametern und einem XY-Pad mit RBF-Gewichtung wird das schnell unangenehm.

**Nimm das, wenn:** die Zustände sich zur Laufzeit ändern, du wenige Parameter hast, oder du noch in der Designphase bist.

### LUT (Look-Up Table)

Du wertest alle Kurven einmalig offline an z.B. 512 gleichmäßig verteilten Stellen aus und legst das Ergebnis als Tabelle ab. Zur Laufzeit: ein Index-Zugriff plus lineare Interpolation.

**Vorteile:** Konstante Kosten pro Parameter, unabhängig davon, wie kompliziert die Kurve ist. Cache-freundlich (alle Werte für einen Makropunkt liegen nebeneinander). Die Kurve kann aus einer PCHIP-Spline, einem gezeichneten Breakpoint-Editor, einer Messung oder einem Regressionsmodell stammen — dem Audiothread ist das egal. Speicherbar als Datei, versionierbar, deterministisch.

**Nachteile:** Vorbereitungsschritt nötig. Zustandsänderungen erfordern Neubacken (bei 512×50 Floats aber Millisekunden). Quantisierungsfehler.

**Nimm das, wenn:** du mehr als etwa 10 Parameter hast, in Richtung Release gehst, oder mit mehr als einem Makro arbeitest.

### Der Quantisierungsfehler ist kein Argument

Bei 512 Stützstellen und linearer Interpolation liegt der maximale Fehler einer glatten Kurve bei unter 10⁻⁵ des Wertebereichs. Das anschließende Smoothing (Stufe 2) verwischt Größenordnungen mehr. Bei 512 Punkten × 50 Parametern × 4 Byte sind das 100 KB — nichts.

### Empfehlung

**Entwickle mit Laufzeit-Interpolation, liefere mit LUT aus.** Beides kann dieselbe Kurvendefinition benutzen; du tauschst nur die Auswertung. Wenn du die LUT-Variante von Anfang an vorsiehst, ist der Umstieg ein Nachmittag.

---

## 2. Speichere die Matrix normalisiert

**Speichere jeden Parameter als Wert zwischen 0 und 1, nicht in Hz, dB oder Millisekunden.**

Das ist die wirkungsvollste einzelne Entscheidung in dieser ganzen Anleitung, und sie ist auch die, die man am häufigsten falsch macht.

### Warum

Jeder Parameter in deinem Plugin hat bereits eine Abbildung `normalisiert → physikalisch`. Die GUI braucht sie (ein Cutoff-Regler ist logarithmisch skaliert), die Automation braucht sie (Hosts arbeiten in 0…1), die Presetdatei braucht sie. Diese Abbildung **enthält bereits die richtige Krümmung**.

Wenn du im normalisierten Raum linear interpolierst und *danach* die vorhandene Abbildung anwendest, ist die Domänenfrage automatisch gelöst. Ein Morph von 0.2 nach 0.8 auf einem logarithmischen Cutoff-Regler bewegt sich exakt so, wie es sich anfühlt, wenn ein Mensch den Regler gleichmäßig zieht. Genau das willst du.

Speicherst du hingegen 100 Hz und 10000 Hz und interpolierst linear, passiert bei t=0.5 der Wert 5050 Hz — also nach der halben Reglerbewegung bist du schon fast oben. Der Morph fühlt sich an, als hätte er am Ende einen Sprung.

### Was das erspart

Ohne Normalisierung brauchst du **zwei** Abbildungsgesetze pro Parameter: eines für die GUI und ein separates für die Morph-Domäne, und die müssen konsistent bleiben. Das ist eine Fehlerquelle, die sich über Jahre durch den Code zieht.

### Konkret

```
Matrix[zustand][parameter]  →  alle Werte in [0, 1]

Morph:      pNorm = interpoliere(Matrix, t)
Smoothing:  pSmooth = onePole(pNorm)
Anwendung:  pPhys = deineVorhandeneMappingFunktion(pSmooth)
```

Die einzige Ausnahme sind Parameter, deren GUI-Skalierung aus anderen Gründen nicht der sinnvollen Morph-Domäne entspricht. Das ist selten. Wenn es auftritt, ist meistens die GUI-Skalierung das eigentliche Problem.

---

## 3. Interpolationsdomänen im Überblick

Falls du doch in physikalischen Einheiten interpolieren musst (Legacy-Code, externe Presets), hier die Domänen. Die Faustregel: **interpoliere in der Domäne, in der ein Slider linear aussehen würde.**

| Parametertyp | Domäne |
|---|---|
| Cutoff, LFO-Rate, Delayzeit, Pitch | log₂(f), bzw. Cent = 1200·log₂(f / f_ref) |
| Gain, Level, Threshold, Mix | dB, mit Floor bei ca. −80 dB statt −∞ |
| Attack, Decay, Release | logarithmisch |
| Q / Resonanz | logarithmisch, oder in Bandbreite in Oktaven |
| Feedback nahe 1 | nicht im Koeffizienten, sondern in RT60 / Decayzeit |
| Dry/Wet, Panorama | Equal-Power (sin/cos oder √), nicht linear |
| Phase, Winkel, Stereo-Rotation | zirkulär, kürzester Weg über Wrap ±180° |
| Filtertyp, Modus, Waveform | diskret, nicht interpolierbar |

### Anmerkungen zu den kniffligen Fällen

**Gain und der −∞-Punkt.** Ein Gain von 0 ist in dB minus unendlich. Setz einen Floor bei −80 oder −96 dB und behandle den als „aus". Alternativ interpolierst du in `amplitude^(1/3)`, was näherungsweise der Lautheitswahrnehmung entspricht und bei 0 sauber definiert ist.

**Feedback.** Ein Delay-Feedback von 0.90 und eines von 0.99 klingen völlig verschieden (RT60 etwa Faktor 10), 0.10 und 0.19 dagegen fast gleich. Rechne das Feedback in eine Abklingzeit um, interpoliere die, rechne zurück:

```
rt60 = -3 * delayTime / log10(feedback)
feedback = pow(10, -3 * delayTime / rt60)
```

**Zirkuläre Größen.** Von 350° nach 10° sind es 20° vorwärts, nicht 340° rückwärts. Vor der Interpolation die Differenz wrappen:

```
diff = b - a
if (diff >  180) diff -= 360
if (diff < -180) diff += 360
result = a + diff * t
```

**Diskrete Parameter.** Filtertyp, Waveform, Modus lassen sich nicht interpolieren. Zwei Möglichkeiten: hart umschalten in der Segmentmitte, oder — wenn hörbar — beide Signalpfade parallel rechnen und über 5–20 ms crossfaden. Die zweite Variante kostet CPU, ist aber die einzige, die wirklich klickfrei ist.

**Equal-Power.** Bei Dry/Wet und Panning führt lineares Mischen zu einem Lautheitseinbruch in der Mitte. Nimm `dry = cos(t·π/2)`, `wet = sin(t·π/2)`.

---

## 4. Pro-Parameter-Kurven: was ein Makro musikalisch macht

Ohne Kurven steht bei t = 0.5 **jeder** Parameter exakt in der Mitte zwischen zwei Zuständen. Alles bewegt sich gleichzeitig und gleich schnell. Das ist ein Crossfade, kein Instrument, das sich verwandelt.

Mit einer eigenen Kurve pro Parameter bestimmst du, *wann* auf der Reglerbewegung sich was tut. Das ist der Unterschied zwischen „technisch korrekt" und „fühlt sich gut an".

### Beispiel: ein Makro von „dunkel und trocken" nach „hell und weit"

| Parameter | Exponent k | Effekt |
|---|---|---|
| Cutoff | 0.4 | öffnet sofort, ist bei t = 0.3 schon halb offen |
| Drive | 1.0 | linear mit |
| Reverb-Mix | 2.0 | schleicht sich langsam ein |
| Resonanz | 3.0 | lange nichts, kommt erst zum Schluss dazu |

Das erste Drittel des Reglers ist damit „Filter öffnet". Das mittlere Drittel bringt Raum dazu. Das letzte Drittel kippt es mit Resonanz über die Kante. Aus einem Crossfade wird eine Dramaturgie.

`t' = pow(t, k)`, dabei bedeutet **k < 1** „früh viel", **k > 1** „spät viel", **k = 1** linear.

### Für Makros über mehrere Parameter: Staffelung als Entwurfsprinzip

Wenn dein Makro 20 oder 50 Parameter bewegt, ist die Kurvenwahl kein Feintuning mehr, sondern der eigentliche Entwurf. Drei Prinzipien, die verlässlich funktionieren:

**Gruppen statt Einzelwerte.** Teile die Parameter in 3–5 Gruppen mit gemeinsamer Kurve: „Klangfarbe" (früh), „Raum" (mittig), „Extreme" (spät), „Modulation" (spät und steil). 50 unabhängige Kurven zu tunen ist nicht handhabbar, 5 Gruppen schon. Innerhalb einer Gruppe kannst du dann einzelne Ausreißer noch verstellen.

**Staffelung statt Gleichzeitigkeit.** Wenn alles gleichzeitig passiert, hört man einen einzigen undifferenzierten Effekt. Wenn die Ereignisse sich über den Reglerweg verteilen, hört man eine Entwicklung. Als Startpunkt: verteile die k-Werte deiner Gruppen über den Bereich 0.4 bis 3.0.

**Gefährliches spät.** Parameter, die aus dem Ruder laufen können (Resonanz, Feedback, Drive, Modulationstiefe), bekommen ein hohes k. Dann ist der Regler auf den ersten 70 % gutmütig, und der Nutzer erreicht die extremen Zustände nur bewusst am oberen Ende. Das ist gleichzeitig ein Sicherheitsmechanismus.

### Wenn pow nicht reicht

Ein häufiger Fall: ein Parameter soll in der Mitte ein Maximum haben und an beiden Enden niedrig sein — etwa eine Resonanz, die im Übergang aufblüht und in beiden Zielzuständen ruhig ist. Mit einem Exponenten geht das nicht. Das ist der Punkt, an dem du von `pow` auf echte Kurventabellen wechselst (Abschnitt 5).

Ein zweiter Fall: Plateaus. Ein Parameter soll auf dem ersten Reglerdrittel konstant bleiben und sich dann bewegen. Auch das braucht Stützstellen, keinen Exponenten.

---

## 5. Kurven in Max/MSP: drei Wege

Es gibt kein fertiges PCHIP-Objekt in Max. Drei Ansätze, in aufsteigender Genauigkeit und aufsteigendem Aufwand.

---

### Weg A: das `function`-Objekt

Ein Breakpoint-Editor mit ziehbaren Punkten. Im `curve`-Modus (per Shift-Drag verstellbar) bekommt jedes Segment eine exponentielle Krümmung. Das ist kein PCHIP, aber innerhalb jedes Segments garantiert monoton — also kein Überschwingen, keine negativen Cutoffs.

**Für Makrokurven ist das musikalisch fast immer ausreichend**, und du zeichnest sie mit der Maus statt sie auszurechnen. Ein `function` pro Parameter (oder pro Parametergruppe), alle über `pattr` benannt oder in einem `bpatcher` gesammelt.

Abfrage im Patch mit `next $1`:

```
[Makrowert 0…1]
     ↓
[scale 0. 1. 0. 1000.]        ← function-Domain ist standardmäßig 0…1000
     ↓
[prepend next]
     ↓
[function @name curve_cutoff]
     ↓  (linker Outlet: y-Wert)
```

Auslesen aus v8, um die Punkte weiterzuverarbeiten oder zu backen:

```js
// v8: Breakpoints eines function-Objekts holen
function readFunction(objName) {
    var f = this.patcher.getnamed(objName);
    if (!f) { error("function '" + objName + "' nicht gefunden\n"); return null; }

    // getvalueof() liefert die Breakpoints als flache Liste.
    // Format einmal mit post() prüfen — je nach Max-Version
    // kann pro Punkt ein Krümmungswert mitkommen.
    var raw = f.getvalueof();
    post("raw: " + raw.join(" ") + "\n");
    return raw;
}
```

**Vorteil:** schnellste Iteration, du hörst und siehst gleichzeitig.
**Nachteil:** nur exponentielle Segmente, keine echte C¹-Glattheit über die Breakpoints hinweg.

---

### Weg B: `curve~` im Signalpfad

Wenn du keine Kurve über den Makrowert brauchst, sondern eine exponentielle **Rampe über die Zeit** zwischen zwei Werten — etwa beim harten Umschalten zwischen zwei Presets mit definierter Übergangszeit.

```
[3000 500 0.5(          ← Zielwert 3000, in 500 ms, Krümmung 0.5
     ↓
[curve~]
```

Der dritte Wert ist der Krümmungsfaktor: negativ = schneller Start, positiv = langsamer Start, 0 = linear. Das ist eine Ergänzung zu A und C, kein Ersatz — `curve~` interpoliert über die Zeit, nicht über den Makrowert.

---

### Weg C: echtes PCHIP in `v8`

`v8` ist in Max 9 der Nachfolger von `js`. Unter Max 8 nimmst du `js`, der Code ist praktisch identisch (v8 kann modernes JavaScript, `js` will ES5 — der Code unten ist bewusst ES5-kompatibel).

#### Die Mathematik, kurz

Eine kubische Spline braucht pro Stützstelle nicht nur den Wert, sondern auch die **Steigung**, mit der die Kurve dort durchgeht. Die naive Wahl — arithmetisches Mittel der Nachbarsteigungen, das ist Catmull-Rom — erzeugt Überschwingen. Bei den Werten 0, 0, 100 bekäme der mittlere Punkt eine Steigung nach oben, und die Kurve müsste davor unter null tauchen, damit sie den Punkt trifft. Deine Cutoff wird negativ.

PCHIP (Fritsch-Carlson) ändert zwei Dinge:

1. **Vorzeichenwechsel → Steigung null.** Steigt die Kurve vor dem Punkt und fällt danach, ist der Punkt ein lokales Maximum. Dort muss die Steigung null sein.
2. **Gewichtetes harmonisches Mittel statt arithmetischem.** Das harmonische Mittel wird vom *kleineren* Wert dominiert: bei 0 und 100 ergibt es 0, bei 1 und 100 etwa 2. Ein flaches Segment neben einem steilen zieht die Steigung nach unten, die Kurve bleibt zwischen den Stützwerten.

Damit ist garantiert: die Kurve verlässt nie den Bereich zwischen zwei benachbarten Stützwerten.

#### Der Code

```js
// ============================================================
// pchip.js  —  monotone kubische Hermite-Interpolation
// v8 (Max 9) oder js (Max 8)
// ============================================================
autowatch = 1;
inlets  = 1;
outlets = 2;   // 0 = Wert, 1 = Status/Debug

// ------------------------------------------------------------
// Kurvendefinition: pro Parameter eine Liste von Stützstellen.
// x = Position auf dem Makroregler (0…1)
// y = normalisierter Parameterwert (0…1)
// ------------------------------------------------------------
var curves = {
    cutoff:    { x: [0, 0.33, 0.66, 1], y: [0.10, 0.55, 0.80, 0.95] },
    resonance: { x: [0, 0.33, 0.66, 1], y: [0.05, 0.08, 0.30, 0.90] },
    reverb:    { x: [0, 0.33, 0.66, 1], y: [0.00, 0.15, 0.60, 0.75] },
    drive:     { x: [0, 0.50, 1],       y: [0.20, 0.65, 0.40] }  // Maximum in der Mitte
};

var names = [];      // stabile Reihenfolge = Kanalzuordnung im Buffer
var segs  = {};      // vorberechnete Segmentkoeffizienten

// ------------------------------------------------------------
// Tangenten nach Fritsch-Carlson
// ------------------------------------------------------------
function pchipTangents(xs, ys) {
    var n = xs.length;
    var h = [], d = [], i;

    for (i = 0; i < n - 1; i++) {
        h[i] = xs[i + 1] - xs[i];
        if (h[i] <= 0) { error("x-Werte muessen streng steigend sein\n"); return null; }
        d[i] = (ys[i + 1] - ys[i]) / h[i];
    }

    var m = new Array(n);

    // Randpunkte: einfachste sichere Wahl — Steigung des Randsegments.
    // (Die dreipunktige Randformel ist genauer, kann aber ueberschwingen,
    //  wenn man sie nicht zusaetzlich begrenzt.)
    m[0]     = d[0];
    m[n - 1] = d[n - 2];

    for (i = 1; i < n - 1; i++) {
        if (d[i - 1] * d[i] <= 0) {
            m[i] = 0;                         // lokales Extremum
        } else {
            // gewichtetes harmonisches Mittel, korrekt fuer ungleiche Abstaende
            var w1 = 2 * h[i] + h[i - 1];
            var w2 = h[i] + 2 * h[i - 1];
            m[i] = (w1 + w2) / (w1 / d[i - 1] + w2 / d[i]);
        }
    }
    return m;
}

// ------------------------------------------------------------
// Aus Punkten + Tangenten die Polynomkoeffizienten pro Segment.
//   p(u) = ((a*u + b)*u + c)*u + dd     mit u in [0,1]
// ------------------------------------------------------------
function buildSegments(xs, ys) {
    var m = pchipTangents(xs, ys);
    if (!m) return null;

    var out = [];
    for (var i = 0; i < xs.length - 1; i++) {
        var h  = xs[i + 1] - xs[i];
        var m0 = m[i]     * h;            // Tangenten auf Segmentbreite normiert
        var m1 = m[i + 1] * h;
        var dy = ys[i + 1] - ys[i];

        out.push({
            x0: xs[i],
            x1: xs[i + 1],
            h:  h,
            a:  m0 + m1 - 2 * dy,
            b:  3 * dy - 2 * m0 - m1,
            c:  m0,
            dd: ys[i]
        });
    }
    return out;
}

function rebuild() {
    names = [];
    segs  = {};
    for (var k in curves) {
        if (!curves.hasOwnProperty(k)) continue;
        var s = buildSegments(curves[k].x, curves[k].y);
        if (!s) continue;
        segs[k]  = s;
        names.push(k);
    }
    outlet(1, "rebuilt", names.length);
}

// ------------------------------------------------------------
// Auswertung. Bei gleichmaessigen Stuetzstellen kann die Suche
// durch floor(t * nSegmente) ersetzt werden — konstante Kosten.
// ------------------------------------------------------------
function evalCurve(name, t) {
    var s = segs[name];
    if (!s) return 0;

    if (t <= s[0].x0) return s[0].dd;
    var last = s[s.length - 1];
    if (t >= last.x1) return ((last.a + last.b) + last.c) + last.dd;

    var k = 0;
    while (k < s.length - 1 && t >= s[k].x1) k++;

    var g = s[k];
    var u = (t - g.x0) / g.h;
    return ((g.a * u + g.b) * u + g.c) * u + g.dd;   // Horner
}

// ------------------------------------------------------------
// Max-Schnittstelle: Float am Inlet = Makrowert, Liste raus
// ------------------------------------------------------------
function msg_float(t) {
    var vals = [];
    for (var i = 0; i < names.length; i++) vals.push(evalCurve(names[i], t));
    outlet(0, vals);
}

function loadbang() { rebuild(); }
rebuild();
```

**Vorteil:** exakte Kontrolle, garantiert kein Überschwingen, Kurven als Text versionierbar.
**Nachteil:** kein visuelles Editieren. In der Praxis kombinierst du: Kurven in `function` zeichnen, Punkte auslesen, in v8 als PCHIP durchlegen, backen.

---

### Zwei Makros: `rbfi` und `nodes`

Sobald du ein XY-Pad willst, wird aus der Kurve eine Fläche. Max hat dafür eingebaute Objekte:

- **`rbfi`** — Radial-Basis-Function-Interpolation zwischen frei platzierten Punkten in einer 2D-Fläche. Trifft die Stützstellen exakt und gibt für jeden Punkt der Fläche Gewichte aus, mit denen du deine Zustände mischst. Das ist der richtige Weg, wenn deine Zustände nicht auf einem Raster liegen.
- **`nodes`** — einfachere Distanzgewichtung mit einstellbaren Einflussradien pro Knoten.

Für ein regelmäßiges Raster genügt bilineare Interpolation, oder Tensorprodukt-Bikubik, wenn du Glattheit brauchst.

---

## 5b. Der reine Max-Weg, ohne gen~

Nicht jedes Projekt braucht gen~. Wenn du bei den Standardobjekten bleibst, sieht die Kette so aus:

```
[metro 5]                       ← Kontrollrate, 5 ms genügt für Makros
    ↓
[Makrowert 0…1]
    ↓
[v8 pchip.js]  oder  [function]-Objekte
    ↓  (Liste mit N normalisierten Werten)
[zl slice] / [unpack]           ← auf Einzelparameter verteilen
    ↓
[line~ 20]  pro Parameter       ← Rampe über 20 ms, füllt die Lücken
    ↓
[Denormalisierung als Signal]   ← z.B. [scale~] oder [expr~]
    ↓
[filtercoeff~]  →  [biquad~]
```

**`filtercoeff~`** ist hier das Schlüsselobjekt: es nimmt Frequenz, Q und Gain als *Signale* entgegen und liefert die fünf Biquad-Koeffizienten als Signale, direkt verwendbar in `biquad~` oder `cascade~`. Damit bekommst du „Design-Parameter interpolieren, Koeffizienten neu rechnen" (Abschnitt 3) geschenkt, ohne selbst Filtermathematik zu schreiben.

**In gen~ nimmst du es trotzdem nicht** — dort schreibst du die Mathematik ohnehin selbst hin, und dann gleich als TPT-Struktur (Abschnitt 6) statt als Direct-Form-Biquad. Die ist unter schneller Modulation deutlich gutmütiger, weil ihre State-Variablen als Integratorzustände interpretierbar bleiben und ihre Bedeutung nicht mit den Koeffizienten wechselt. `filtercoeff~` ist also der richtige Weg im Max-Pfad und überflüssig im gen~-Pfad.

**Glättung**: `line~` gibt lineare Rampen mit definierter Zeit — gut, um die 5-ms-Lücken des `metro` zu füllen. Gegen Zipper-Noise ist ein One-Pole besser: `slide~` oder `rampsmooth~`. `slide~ 500 500` entspricht bei 44,1 kHz etwa 11 ms Zeitkonstante. In der Praxis kombiniert man beides: `line~` für die Grobbewegung, `slide~` dahinter für die Glättung.

**Bei vielen Parametern** ersetzt du die N Einzelobjekte durch `mc.`-Varianten: `mc.line~`, `mc.slide~`, `mc.sig~`. Ein Multichannel-Strang statt fünfzig Kabel — das ist bei dieser Aufgabe der Unterschied zwischen wartbar und nicht wartbar.

### Was in gen~ geht und was nicht

**Vollständig in gen~ möglich:** Buffer-Lookup (`sample`, `peek`), Spline-Auswertung im Codebox, Smoothing (`slide` oder eigener One-Pole mit `History`), Denormalisierung, komplette Filterkoeffizienten-Mathematik, Kontrollraten-Dezimierung über Counter und `latch`. Der gesamte Signalpfad also.

**Nicht in gen~ möglich:**
- **Kein Scheduler.** Kein `metro`, kein `qmetro`, kein `defer`. Alles läuft pro Sample; Kontrollraten baust du mit `History`-Countern selbst.
- **Keine GUI-Objekte.** Kein `function`, kein `multislider`, kein `rbfi`. Kurven zeichnest du außerhalb.
- **Kein bequemes Buffer-Schreiben beim Start.** `poke` kann zwar schreiben, aber ohne Scheduler gibt es keinen sauberen „einmal beim Laden"-Moment. Das Backen bleibt Aufgabe von `v8`.
- **Kein Dateizugriff, kein Dict, kein Coll.** Presets und Zustandsmatrizen leben außerhalb.

**Die saubere Aufteilung lautet deshalb: v8 backt, gen~ liest.** Zwischen beiden liegt nur ein `buffer~`. Alles Zustandsbehaftete, Editierbare und Ladbare bleibt in der Max-Domäne; gen~ sieht nur noch eine Tabelle.

---

## 6. LUT-Backen in Max, gelesen in gen~

Die Arbeitsteilung: **v8 backt beim Laden, gen~ liest im Audiothread.** Dazwischen liegt ein einziger `buffer~`.

### Aufbau

```
[buffer~ macroLUT 512 samps 4]
                  │      │   └── Kanäle = Anzahl Parameter
                  │      └────── Einheit
                  └───────────── Stützstellen
```

Ein Kanal pro Parameter. `buffer~` kann viele Kanäle; bei sehr vielen Parametern nimmst du mehrere Buffer.

### Backen in v8

Ergänze das Skript aus Weg C um:

```js
// ------------------------------------------------------------
// LUT-Backen: jede Kurve an N Punkten auswerten, in buffer~ schreiben
// ------------------------------------------------------------
var BUFNAME = "macroLUT";

function bake() {
    var buf = new Buffer(BUFNAME);
    var N   = buf.framecount();

    if (N < 2) { error("buffer~ '" + BUFNAME + "' nicht gefunden oder leer\n"); return; }
    if (buf.channelcount() < names.length) {
        error("buffer~ hat zu wenige Kanaele: " +
              buf.channelcount() + " < " + names.length + "\n");
        return;
    }

    for (var p = 0; p < names.length; p++) {
        var vals = new Array(N);
        for (var i = 0; i < N; i++) {
            vals[i] = evalCurve(names[p], i / (N - 1));
        }
        // ACHTUNG Kanalindizierung: in der js/v8-Buffer-API sind Kanäle
        // 1-basiert, in gen~ 0-basiert. Einmal mit einer Testrampe prüfen.
        buf.poke(p + 1, 0, vals);
    }

    outlet(1, "baked", names.length, N);
    post("LUT gebacken: " + names.length + " Parameter, " + N + " Punkte\n");
    post("Kanalzuordnung: " + names.join(", ") + "\n");
}

function msg_bang() { rebuild(); bake(); }
```

Trigger: `[loadbang] → [deferlow] → [t b] → [v8 pchip.js]`. Das `deferlow` ist wichtig, damit der `buffer~` beim Zugriff schon existiert.

Die ausgegebene Kanalzuordnung solltest du dir merken oder in ein `coll` schreiben — sie ist der Vertrag zwischen v8 und gen~.

### Lesen in gen~

```
[gen~ @title macroMorph]
```

Codebox-Inhalt:

```
// ============================================================
// macroMorph — LUT-Lookup, Smoothing, Denormalisierung, TPT-SVF
// in1 = Audio, in2 = Makrowert 0…1
// ============================================================

Buffer lut("macroLUT");

Param smoothMs(30);          // Glättungszeit in ms
Param fcMin(20), fcMax(20000);

// --- LUT-Lookup ------------------------------------------------
t   = clamp(in2, 0, 1);
idx = t * (dim(lut) - 1);

cutN = sample(lut, idx, 0);      // Kanal 0 = cutoff
resN = sample(lut, idx, 1);      // Kanal 1 = resonance
revN = sample(lut, idx, 2);      // Kanal 2 = reverb
drvN = sample(lut, idx, 3);      // Kanal 3 = drive

// --- Smoothing in der normalisierten Domäne --------------------
sc = 1 - exp(-1 / (smoothMs * 0.001 * samplerate));

History cutS(0), resS(0), revS(0), drvS(0);
cutS = cutS + sc * (cutN - cutS);
resS = resS + sc * (resN - resS);
revS = revS + sc * (revN - revS);
drvS = drvS + sc * (drvN - drvS);

// --- Denormalisierung ------------------------------------------
fc = fcMin * pow(fcMax / fcMin, cutS);     // logarithmisch
Q  = 0.5   * pow(40, resS);                // 0.5 … 20, logarithmisch

// --- TPT State Variable Filter (Zavalishin / Cytomic) ----------
// Stabil unter schneller Modulation, billig neu zu berechnen.
g  = tan(PI * min(fc, samplerate * 0.45) / samplerate);
k  = 1 / Q;
a1 = 1 / (1 + g * (g + k));
a2 = g * a1;
a3 = g * a2;

History ic1eq(0), ic2eq(0);
v3 = in1 - ic2eq;
v1 = a1 * ic1eq + a2 * v3;
v2 = ic2eq + a2 * ic1eq + a3 * v3;
ic1eq = 2 * v1 - ic1eq;
ic2eq = 2 * v2 - ic2eq;

out1 = v2;        // Lowpass. Bandpass = v1, Highpass = in1 - k*v1 - v2
out2 = revS;      // an nachgeschaltete Objekte
out3 = drvS;
```

`sample()` interpoliert linear zwischen den Buffer-Punkten. `dim()` gibt die Framezahl.

### Kontrollraten-Dezimierung, falls nötig

Der teure Teil ist `tan()`. Bei einem einzelnen Filter ist das auf moderner Hardware irrelevant. Bei 30 Filtern lohnt sich Dezimierung:

```
History cnt(0);
cnt = (cnt + 1) % 64;
doUpdate = (cnt == 0);

// Koeffizienten nur alle 64 Samples neu, dazwischen halten
g_ = latch(tan(PI * fc / samplerate), doUpdate);
```

Das Smoothing bleibt bei voller Samplerate — es ist billig und genau der Teil, der die Sprünge glättet.

### Datenformat: Float32Array in v8

Wenn du die LUT auch visuell weiterverwenden willst (Kurvenanzeige, `jit.matrix`, Canvas), lohnt sich ein `Float32Array` als kanonisches Format. `v8` ist echtes V8 und unterstützt TypedArrays vollständig — der alte `js`-Interpreter aus Max 8 nicht, das bindet dich also an Max 9.

**Präzision ist unkritisch.** JavaScript rechnet grundsätzlich in float64; ein `Float32Array` ist reine Speicherung, beim Lesen bekommst du wieder einen Double. Deine PCHIP-Koeffizienten entstehen also weiterhin voll genau. Und `buffer~` ist intern ohnehin 32-Bit-Float — du verlierst nichts, was nicht sowieso verloren ginge.

**Layout: frame-major, interleaved.**

```
[t0_p0, t0_p1, … t0_pN,   t1_p0, t1_p1, … t1_pN,   …]
```

Alle Parameter für einen Makropunkt liegen nebeneinander. Das ist cache-freundlich beim Lesen, entspricht dem internen Layout eines Multichannel-`buffer~` und lässt sich direkt als `jit.matrix` mit `planecount = nParams` interpretieren.

```js
var N_POINTS = 512;
var lutData;                       // kanonische Datenhaltung

function buildLUT() {
    var nP = names.length;
    lutData = new Float32Array(N_POINTS * nP);

    for (var i = 0; i < N_POINTS; i++) {
        var t = i / (N_POINTS - 1);
        for (var p = 0; p < nP; p++) {
            lutData[i * nP + p] = evalCurve(names[p], t);   // frame-major
        }
    }
}

// Für buffer~ pro Kanal deinterleaven.
// Buffer.poke() will vermutlich ein normales Array — einmal testen.
function pokeChannel(buf, p, nP) {
    var col = new Array(N_POINTS);
    for (var i = 0; i < N_POINTS; i++) col[i] = lutData[i * nP + p];
    buf.poke(p + 1, 0, col);       // js/v8: Kanäle 1-basiert
}
```

**Für die visuelle Seite** hast du damit drei Optionen:

- **`jit.matrix` mit mehreren Planes.** `jit.matrix macroLUT 32 float32 512` — bis 32 Parameter passt jeder in eine Plane, das Layout ist identisch zum Array oben. Darüber hinaus nimmst du eine 2D-Matrix mit einer Plane, `512 × nParams`.
- **`jit.buffer~`.** Liest einen bestehenden `buffer~` als Matrix. Wenn du ohnehin schon in den Buffer bäckst, ist das der bequemste Weg — du hältst die Daten nicht doppelt.
- **Direkt zeichnen** in `jsui` / `v8ui` aus dem `Float32Array`. Für eine simple Kurvenanzeige ist das der kürzeste Weg und braucht gar keine Jitter-Objekte.

Der Punkt: **eine Datenquelle, drei Konsumenten.** Das `Float32Array` ist die Wahrheit, `buffer~` ist die Audio-Sicht darauf, `jit.matrix` die visuelle. Kurven änderst du an genau einer Stelle und rufst `bake()`.

### Visuelle Werte direkt in der LUT: RGBA und Co.

Du kannst in derselben Tabelle nicht nur Steuerdaten für Jitter transportieren, sondern die visuellen Werte selbst. Farbe ist aus Sicht der LUT einfach ein weiterer Parameter, der zwischen Zuständen morpht — und weil dein Makro ohnehin die Dramaturgie vorgibt, ist es sinnvoll, dass Klang und Bild aus derselben Quelle kommen.

Praktisch reservierst du vier zusätzliche Kanäle:

```
Kanal  0 … N-1   Audio-Parameter (normalisiert)
Kanal  N   … N+3  R, G, B, A  (0…1)
```

Ein Bake, ein Array, ein `buffer~`. gen~ liest die Audio-Kanäle, Jitter die Farbkanäle. Beide sehen automatisch denselben Makrowert, ohne Synchronisationslogik.

**Farbe hat eine eigene Interpolationsdomäne.** Das ist die direkte Fortsetzung von Abschnitt 3 und der häufigste Fehler beim Farbmorphing:

| Fall | Domäne |
|---|---|
| RGB allgemein | linear-light, **nicht** sRGB — sonst wird die Mitte matschig und zu dunkel |
| Hue (HSL/HSV) | zirkulär, kürzester Weg über Wrap ±180° — dieselbe Regel wie bei Phase |
| Wahrgenommene Helligkeit / Sättigung | Oklab oder CIELab, wenn es wirklich gleichmäßig wirken soll |
| Alpha | premultiplizieren vor der Interpolation, sonst Farbsäume an transparenten Rändern |

sRGB-Werte sind gammakodiert. Der Mittelwert zweier sRGB-Werte ist nicht die mittlere Helligkeit — deshalb sieht ein Blend von Rot nach Grün in der Mitte nach Schlamm aus statt nach Gelb. Vor dem Interpolieren nach linear konvertieren (`pow(c, 2.2)` als grobe Näherung), danach zurück (`pow(c, 1/2.2)`). Wenn du die Farben nur in einem GL-Kontext verwendest, der ohnehin linear rechnet, entfällt der Rückweg.

Der elegantere Weg: **speichere die Farbe als HSL in der LUT** und konvertiere erst beim Auslesen nach RGB. Dann ist der Hue-Kanal ein ganz normaler zirkulärer Parameter wie jeder andere, und du kannst ihn mit derselben PCHIP-Kurve behandeln — nur mit Wrap statt Clamp.

**Zwei Fallstricke in Jitter:**

- **Plane-Reihenfolge ist ARGB, nicht RGBA.** Bei `jit.matrix 4 char` ist Plane 0 = Alpha, 1 = Rot, 2 = Grün, 3 = Blau. Die GL-Objekte erwarten dagegen an vielen Stellen RGBA. Leg dir die Reihenfolge einmal fest und dokumentiere sie, sonst suchst du Farbfehler, die keine sind.
- **char vs. float32.** Eine `char`-Matrix ist 0…255, eine `float32`-Matrix 0…1. Weil deine LUT ohnehin normalisiert ist, passt `float32` direkt ohne Skalierung — und die GL-Pipeline rechnet sowieso in Float. Nimm `float32`, außer du brauchst explizit `char` für ein bestimmtes Objekt.

**Auslesen für die Bildseite:** Farben brauchen keine Samplerate. Ein `qmetro` mit 16 ms genügt, dazu ein `v8`-Lookup ins `Float32Array` oder ein `jit.peek~` in den `buffer~`. Alternativ, wenn du im GL-Kontext arbeitest: schick die LUT als Textur an einen `jit.gl.slab`-Shader. Dann kann der Shader die Kurve pro Pixel nachschlagen, und du bekommst Verläufe, die dem Makro folgen, ohne dass CPU-seitig etwas passiert.

**Was dabei sonst noch in die LUT gehört:** Skalierungen, Rotationen, Partikelanzahl, Blur-Radius, Feedback-Faktor der Bildkette. Alles, was du beim Morph mitbewegen willst. Der Kern des Ansatzes ist ja gerade, dass ein Makro ein *Zustand* ist und nicht ein Audioparameter — und Bildparameter sind Teil dieses Zustands.

---

## 7. Der zweite Weg: Samples statt Synthese-Parameter

Alles bisherige setzt voraus, dass deine Zustände aus *Zahlen* bestehen, die sich stetig verbinden lassen. Bei Samples gilt das nicht. Zwischen einer Kick und einer Snare gibt es kein „halbes Sample" — der Zwischenwert zweier Wellenformen ist kein Klang zwischen ihnen, sondern beide gleichzeitig. Deshalb braucht dieser Fall eine eigene Architektur, und hier wird Regression tatsächlich zum richtigen Werkzeug.

### Das Grundprinzip: die Makroachse wird gefunden, nicht gezeichnet

Bei Synthese-Parametern setzt du die Stützstellen selbst: „bei t = 0.5 soll die Cutoff hier stehen". Bei einem Korpus aus 2000 Slices kannst du das nicht — du überblickst die 2000 Klänge nicht und kannst sie nicht von Hand in eine sinnvolle Reihenfolge bringen.

Also drehst du die Richtung um. Statt die Kurve vorzugeben, **lässt du die Anordnung aus dem Material entstehen**:

```
Korpus (n Slices)
    ↓  Analyse
Deskriptorvektor pro Slice  (z.B. 13 MFCCs + Spektralschwerpunkt + Loudness)
    ↓  Standardisierung
vergleichbare Dimensionen
    ↓  Dimensionsreduktion  (UMAP / PCA)
1D-Achse  ←  das ist dein Makroregler
    ↓  Nachbarsuche (KD-Tree)
welches Slice klingt am nächsten zu Position t?
```

Der Makroregler fährt jetzt durch den *Klangraum* deines Korpus. Weil UMAP ähnlich klingende Slices nebeneinander legt, wird die Bewegung hörbar kontinuierlich, obwohl die Klänge diskret sind.

Auf 2D reduziert bekommst du dasselbe für ein XY-Pad — und damit dieselbe Struktur wie `rbfi` aus Abschnitt 5, nur mit gelernten statt gesetzten Positionen.

### Objekte

Der Unterbau ist FluCoMa; Data Knot verpackt das in performanceorientierte Abstraktionen mit niedriger Latenz.

| Aufgabe | FluCoMa |
|---|---|
| Slicing | `fluid.bufonsetslice`, `fluid.bufnoveltyslice` |
| Analyse | `fluid.bufmfcc`, `fluid.bufspectralshape`, `fluid.bufloudness`, `fluid.bufstats` |
| Datenhaltung | `fluid.dataset`, `fluid.labelset` |
| Vergleichbar machen | `fluid.standardize`, `fluid.normalize`, `fluid.robustscale` |
| Reduktion | `fluid.umap`, `fluid.pca`, `fluid.mds` |
| Nachbarsuche | `fluid.kdtree` |
| Regression | `fluid.mlpregressor`, `fluid.knnregressor` |
| Gruppierung | `fluid.kmeans`, `fluid.knnclassifier` |

### Wo Regression wirklich Regression ist

Drei Fälle, in denen du ein Modell trainierst statt Stützstellen zu setzen:

**Deskriptoren → Syntheseparameter.** Du willst, dass dein Synth einem eingehenden Klang folgt. Eingang sind 15 Deskriptoren, Ausgang 40 Parameter. Du gibst 50 Beispielpaare vor („bei diesem Klang soll es so klingen") und `fluid.mlpregressor` lernt die Abbildung dazwischen. Von Hand ist das nicht machbar — du kannst einen 15-dimensionalen Eingaberaum nicht mit Stützstellen abdecken.

**Gestensteuerung.** Sensor mit 6 bis 8 Achsen, Ausgang deine Parametermatrix. Gleiches Argument: der Eingaberaum ist zu groß zum Aufzählen. Du demonstrierst Beispiele statt sie zu spezifizieren.

**Korpus-Navigation mit Klangvorgabe.** Ein Zielklang wird analysiert, das Modell sagt dir, welche Syntheseparameter ihn nachbilden. Das ist Parameter-Estimation und ohne Lernverfahren praktisch unlösbar.

Der gemeinsame Nenner bleibt der aus Abschnitt 0: **Regression ist die Antwort auf einen Eingaberaum, den du nicht überblickst.** Ein Regler von 0 bis 1 ist keiner.

### Was aus den anderen Abschnitten weiterhin gilt

**Deskriptoren brauchen Domänen — genau wie Parameter.** Ein Spektralschwerpunkt in Hz und eine Loudness in dB haben völlig verschiedene Wertebereiche; ohne Standardisierung dominiert schlicht die Dimension mit den größten Zahlen die Distanzberechnung, und dein KD-Tree sortiert nach dem falschen Kriterium. Deshalb steht `fluid.standardize` nicht optional in der Kette. Frequenzdeskriptoren gehören zusätzlich vorher nach log oder MIDI-Note gewandelt — dieselbe Tabelle wie in Abschnitt 3.

**Backen gilt auch hier, und zwar besonders.** UMAP ist nicht deterministisch: zweimal ausgeführt bekommst du zwei verschiedene Anordnungen. Für ein Instrument ist das inakzeptabel — dein Makro darf sich nicht bei jedem Programmstart anders verhalten. Also: Reduktion **einmal** offline rechnen, Ergebnis mit `write` als Datei speichern, zur Laufzeit nur noch `read`. Die Analyse eines großen Korpus dauert ohnehin Minuten und gehört nicht in den Start.

**Die diskreten Sprünge musst du behandeln.** Ein neues Slice ist ein harter Schnitt. Übliche Lösungen: kurzer Crossfade (5–20 ms) zwischen altem und neuem Slice, oder ein granularer Ansatz mit überlappenden Körnern, bei dem jedes Korn seine Position im Korpus selbst wählt. Letzteres verwischt die Grenzen so weit, dass die Bewegung durch den Korpus als kontinuierliche Klangfarbenänderung wahrnehmbar wird.

**Ein „Spread"-Parameter lohnt sich.** Statt immer das exakt nächste Slice zu nehmen, wählst du zufällig aus den k nächsten. Bei k = 1 bekommst du reproduzierbares Verhalten, bei größerem k lebendige Variation. Das ist selbst wieder ein Parameter, den dein Makro mitbewegen kann.

### Beide Wege kombinieren

Der interessante Fall ist die Kombination, und sie ist einfacher als sie klingt: **ein Makrowert t, zwei Konsumenten.**

```
                         t (0…1)
                    ┌───────┴───────┐
                    ↓               ↓
            LUT-Lookup        KD-Tree-Lookup
         (Abschnitt 1–6)      (dieser Abschnitt)
                    ↓               ↓
        Synth- und Bildparameter   Slice-Auswahl
```

Die LUT liefert Filter, Hüllkurven, Farben — alles Stetige, von dir gestaltet. Der KD-Tree liefert das Klangmaterial. Beide bekommen denselben Makrowert und sind damit automatisch synchron. Du kannst die reduzierte Korpusachse sogar als zusätzlichen Kanal in dieselbe LUT backen, dann hast du wieder eine einzige Datenquelle.

Praktischer Effekt: du gestaltest die Dramaturgie (Abschnitt 4) weiterhin von Hand, überlässt aber die Auswahl des Materials dem Verfahren, das den Korpus tatsächlich kennt.

---

## 8. Checkliste

**Struktur**
- [ ] Matrix normalisiert (0…1), nicht in Hz/dB/ms
- [ ] Denormalisierung ist dieselbe Funktion wie in der GUI, nicht eine zweite
- [ ] Smoothing sitzt **vor** der Denormalisierung
- [ ] Kanalzuordnung Parameter ↔ Buffer dokumentiert

**Kurven**
- [ ] Jeder Parameter (oder jede Gruppe) hat eine eigene Kurve, nicht alle dieselbe
- [ ] Kurven gestaffelt: nicht alles passiert bei t = 0.5
- [ ] Riskante Parameter (Resonanz, Feedback, Drive) haben hohes k, kommen spät
- [ ] Interpolation kann die Stützwerte nicht verlassen (PCHIP oder `function`-curve)

**Laufzeit**
- [ ] Design-Parameter interpoliert, nicht Filterkoeffizienten
- [ ] Filtertopologie modulationsfest (TPT/SVF oder wenigstens Direct Form I)
- [ ] One-Pole-Smoothing pro Parameter, 20–50 ms für Makros, 5–10 ms für Amplituden
- [ ] fc gegen Nyquist geklemmt, Q gegen Instabilität
- [ ] Diskrete Parameter schalten hart oder crossfaden — nicht interpoliert

**Test**
- [ ] Makro auf jede Stützstelle setzen: kommt exakt der gespeicherte Zustand heraus?
- [ ] Makro sehr schnell auf und ab bewegen: klickt es?
- [ ] Makro mit einem Rechteck-LFO springen lassen: bleibt der Filter stabil?
- [ ] Extremzustand + kalter Start: knallt es beim ersten Sample?

**Wenn Samples im Spiel sind (Abschnitt 7)**
- [ ] Deskriptoren standardisiert, Frequenzen vorher nach log/MIDI gewandelt
- [ ] Reduktion offline gerechnet und als Datei gespeichert, nicht beim Start
- [ ] Zweimal starten: liefert derselbe Makrowert dasselbe Slice?
- [ ] Slice-Wechsel gecrossfadet oder granular verwischt
- [ ] Makro langsam durchfahren: ist die Reihenfolge klanglich plausibel?

---

## 9. Kurzentscheidungshilfe

| Situation | Ansatz |
|---|---|
| < 10 Parameter, Prototyping | Laufzeit + `function`-Objekte |
| 10–50 Parameter, Release | LUT in `buffer~`, gelesen in gen~ |
| Kurven sollen editierbar bleiben | `function` zeichnen → v8 auslesen → PCHIP → backen |
| Zwei Makros, Raster | bilineare Interpolation oder 2D-LUT (`jit.matrix`) |
| Zwei Makros, freie Punkte | `rbfi` |
| Zustände ändern sich zur Laufzeit | Laufzeit-Interpolation, oder neu backen (ist schnell) |
| Bildparameter sollen mitmorphen | zusätzliche Kanäle in derselben LUT (Abschnitt 6) |
| Zustände sind Samples/Slices | Deskriptoren → Reduktion → KD-Tree (Abschnitt 7) |
| Reihenfolge des Korpus unbekannt | UMAP/PCA auf 1D, einmal offline, Ergebnis speichern |
| Eingang ist eine Geste oder Audioanalyse | Regression (`fluid.mlpregressor`) — anderes Problem |
| Beides gleichzeitig | ein t, zwei Konsumenten: LUT für Parameter, KD-Tree für Material |
