# Vom Sample zum Rauschen und zurück

## Ein systematischer Aufbau invertierbarer Zerstörungsverfahren, und ihre Abgrenzung zum graduellen Makro-Übergang

---

## Wie dieses Dokument aufgebaut ist

Teil I klärt die Begriffe. Ohne diese Grundlagen wirken viele der späteren Verfahren wie Zaubertricks, mit ihnen sind sie offensichtlich.

Teil II bis VII entwickeln die Verfahren in aufsteigender Allgemeinheit. Jede Klasse hebt eine Einschränkung der vorherigen auf. Die Reihenfolge ist so gewählt, dass am Ende jeder Klasse klar ist, *warum* die nächste nötig wird.

Teil VIII fasst zusammen.

Teil IX markiert den entscheidenden Bruch: Der graduelle Übergang von Sample zu Rauschen ist eine **andere mathematische Aufgabe** als Invertierbarkeit. Teil X und XI behandeln sie eigenständig.

---

# TEIL I — GRUNDLAGEN

## 1. Was "invertierbar" genau bedeutet

Eine Abbildung `F` ist invertierbar, wenn es eine Abbildung `F⁻¹` gibt mit `F⁻¹(F(x)) = x` für alle zulässigen `x`. Die notwendige und hinreichende Bedingung dafür ist **Injektivität**: Zwei verschiedene Eingaben dürfen niemals dieselbe Ausgabe erzeugen.

Formal:

```
F injektiv  ⟺  ( F(a) = F(b) ⟹ a = b )
```

Alles, was in diesem Dokument folgt, ist eine Antwort auf die Frage: *Wie baue ich eine Abbildung, die maximal zerstörerisch klingt und trotzdem injektiv bleibt?*

### Warum Hard Clipping durchfällt

Betrachte `y = clip(x, T) = max(-T, min(T, x))`. Für jedes `x > T` gilt `y = T`. Die Urbildmenge des Wertes `T` ist das gesamte Intervall `[T, ∞)`. Die Abbildung kollabiert ein Kontinuum auf einen Punkt und ist damit nicht injektiv.

Dasselbe Argument erledigt:

| Verfahren | Grund für Nicht-Injektivität |
|---|---|
| Hard Clipping | Plateau, Urbild ist ein Intervall |
| Wavefolding (Foldback) | Faltung, mehrere `x` treffen dasselbe `y` |
| Gleichrichtung | `+a` und `−a` werden identisch |
| Bitcrushing / Quantisierung | Ein Quantisierungsschritt ist ein Intervall |
| Decimation ohne Speicher | Verworfene Samples sind verworfen |

Diese Liste ist wichtig, weil sie fast identisch mit der Liste der klanglich attraktivsten Verfahren ist. Der Rest des Dokuments beschreibt Auswege.

## 2. Zwei Ebenen der Invertierbarkeit

Das ist der zentrale konzeptionelle Unterschied, aus dem später mehrere Verfahren erwachsen.

**Punktweise Invertierbarkeit.** `y[n]` hängt nur von `x[n]` ab, und die Abbildung `ℝ → ℝ` ist injektiv. Jedes Sample lässt sich isoliert zurückrechnen. Sehr robust, aber stark eingeschränkt.

**Folgen-Invertierbarkeit.** Die Abbildung `x[·] → y[·]` von der ganzen Folge auf die ganze Folge ist injektiv, obwohl die punktweise Abbildung es nicht ist. Der Dekoder darf beliebig viel Kontext benutzen.

Ein Verfahren kann also aus einer nicht-injektiven Punktabbildung bestehen und trotzdem als Ganzes umkehrbar sein. Genau das nutzen Lifting (Teil VII.1), rückwärtsadaptive Parameter (VII.3) und Modulo-Folding (VII.4). Wer diesen Unterschied nicht sauber trennt, wird die zweite Hälfte des Dokuments für falsch halten.

## 3. Drei Bedeutungen von "Rauschen"

Der Begriff verschmilzt drei unabhängige Eigenschaften, und die Verwirrung darüber ist die Quelle der meisten Missverständnisse in diesem Themenfeld.

**(a) Spektral.** Flaches Betragsspektrum. Messbar über die spektrale Flachheit (geometrisches durch arithmetisches Mittel des Leistungsspektrums), Wert nahe 1 heißt rauschartig.

**(b) Strukturell / phasisch.** Keine kohärenten Transienten, keine erkennbare zeitliche Gestalt. Ein Signal kann ein völlig unflaches Spektrum haben und trotzdem als Rauschen wahrgenommen werden, wenn nur die Phase zerstört ist. Das ist der Kern von Teil IV.

**(c) Informationstheoretisch.** Echter Informationsverlust, die Entropie der Quelle ist im Ergebnis nicht mehr enthalten.

**Der Schlüsselsatz dieses Dokuments:** Invertierbare Verfahren können (a) und (b) beliebig weit treiben, aber (c) niemals erreichen. Eine Bijektion vernichtet keine Information, sie stellt sie nur unhörbar dar.

Daraus folgt eine hilfreiche Umdeutung: *Invertierbare Rauscherzeugung ist Verschlüsselung.* Die Verfahren in Teil III und VI sind buchstäblich Chiffren, das One-Time-Pad und die Stromchiffre. Wer nach Ideen sucht, findet in der Kryptografie einen unerschöpflichen Katalog bijektiver Abbildungen, die statistisch wie Rauschen aussehen.

## 4. Numerik: Kondition und Fehlerfortpflanzung

Mathematische Invertierbarkeit ist notwendig, aber nicht hinreichend für praktische Brauchbarkeit. Entscheidend ist der **Verstärkungsfaktor der Umkehrung**:

```
κ(x) = 1 / |F'(x)|
```

Ist die Vorwärtskennlinie an einer Stelle flach, so ist die Rückwärtskennlinie dort steil, und jeder Fehler im Zwischensignal wird um `κ` verstärkt. Fehlerquellen sind Fließkomma-Rundung, jede Quantisierung auf dem Weg, jedes Dithering, jede verlustbehaftete Zwischenspeicherung.

Drei praktische Konsequenzen:

1. Durchgehend in **Float64** rechnen. Ein Zwischenexport nach 16 Bit zerstört die meisten schlecht konditionierten Verfahren vollständig.
2. Verfahren mit **flachem Betragsgang** (Allpass, Vorzeichenmodulation, Permutation, XOR, Lifting) sind perfekt konditioniert. `κ = 1` überall.
3. Immer den **Round-Trip-Fehler messen**, siehe Teil XI. Ein Verfahren, das formal invertierbar ist und bei −25 dB Fehler landet, ist praktisch nicht invertierbar.

### Der Sonderfall der exakten Arithmetik

In `ℤ/2ⁿ` (Integer mit natürlichem Overflow) und bei Bit-Operationen gibt es **keine Rundung**. Verfahren, die dort leben, sind bitgenau umkehrbar, unabhängig von der Kondition. Das ist der Grund, warum Teil II.4, Teil VI und die Integer-Variante des Lifting eine Sonderstellung einnehmen.

---

# TEIL II — KLASSE A: GEDÄCHTNISLOSE KENNLINIEN

**Prinzip.** `y[n] = f(x[n])`, dieselbe Funktion für jedes Sample.
**Bedingung.** `f` muss **streng monoton** sein.
**Inversion.** `x[n] = f⁻¹(y[n])`, punktweise.

Das ist die einfachste Klasse und die einzige, in der man die Umkehrfunktion buchstäblich hinschreiben kann.

## 1. Potenzkennlinie

```
f(x)   = sign(x) · |x|^p          mit 0 < p < 1
f⁻¹(y) = sign(y) · |y|^(1/p)
```

Bei `p = 0.05` ist die Kennlinie so flach, dass die Wellenform im Oszilloskop nahezu rechteckig aussieht. Der Oberton-Reichtum entspricht fast dem von Hard Clipping, aber die Abbildung bleibt streng monoton.

**Kondition.** Im normalisierten Bereich `|x| ≤ 1` ist die Ableitung minimal bei `|x| = 1` und beträgt dort `p`. Die Fehlerverstärkung ist also durch `1/p` beschränkt, bei `p = 0.05` also Faktor 20, rund 26 dB. Das ist unangenehm, aber beherrschbar. Nahe null ist die Vorwärtskennlinie steil, dort ist die Umkehrung sogar kontrahierend.

**Klang.** Aggressive, obertonreiche Verzerrung mit stark angehobenen leisen Signalanteilen. Der Rauschboden des Originals wird mit hochgezogen.

## 2. Sättigungskennlinien

```
f(x)   = tanh(g·x)
f⁻¹(y) = artanh(y) / g
```

Ebenfalls streng monoton, also formal in Ordnung. Die Kondition ist jedoch **deutlich schlechter** als bei der Potenzkennlinie, weil `tanh` exponentiell abflacht: Die Fehlerverstärkung wächst wie `e^(2g|x|)/2`. Bei `g = 50` ist das astronomisch, und `artanh` divergiert zusätzlich, sobald durch Rundung ein Wert `|y| ≥ 1` entsteht.

Praktische Regel: `tanh` ist als invertierbares Verfahren nur bis etwa `g ≈ 5` brauchbar. Wer härter will, nimmt die Potenzkennlinie.

Besser konditionierte Verwandte: `arsinh(g·x)/arsinh(g)` (wächst logarithmisch statt zu sättigen) und `x/(1+g|x|)` mit rationaler Umkehrung.

## 3. Grenzen dieser Klasse

Jede gedächtnislose monotone Kennlinie hat eine unüberwindbare Eigenschaft: Sie erhält die **Nulldurchgänge und die Ordnung der Samplewerte**. Das Ergebnis klingt immer nach "verzerrtes Original", niemals nach Rauschen im Sinne von Teil I.3(b). Für echte Dekohärenz braucht man Gedächtnis oder externe Modulation.

## 4. Der Ausweg: Bijektionen in ℤ/2ⁿ

Sobald man die reelle Achse verlässt und in Integer-Arithmetik mit natürlichem Überlauf rechnet, ist Monotonie keine Bedingung mehr. Gefordert ist nur noch, dass die Abbildung `ℤ/2ⁿ → ℤ/2ⁿ` bijektiv ist.

**Wrap-Around statt Clipping.**

```
y = (int16)(g · x)          // Überlauf wird nicht abgefangen
x = (int16)(y) / g          // exakt, solange g|x| im Wertebereich abgebildet wurde
```

Der Überlauf ist modulo `2¹⁶` bijektiv. Klanglich ist das der härteste Digitalcharakter überhaupt, ein zersägtes Kreischen, weil bei jedem Überlauf ein Sprung über den gesamten Wertebereich stattfindet.

**Multiplikation mit einer ungeraden Konstante.**

```
y = (a · x) mod 2ⁿ          mit a ungerade
x = (a⁻¹ · y) mod 2ⁿ        a⁻¹ existiert, weil ggT(a, 2ⁿ) = 1
```

Ein Sample mal 26317 modulo 65536 ergibt statistisch weißes Rauschen und ist trotzdem exakt umkehrbar. Das modulare Inverse berechnet man einmalig mit dem erweiterten euklidischen Algorithmus.

Diese Verfahren sind **bitgenau** invertierbar, `κ` ist irrelevant, weil keine Rundung stattfindet. Der Preis ist, dass man den Integer-Pfad nicht verlassen darf.

---

# TEIL III — KLASSE B: MULTIPLIKATIVE MODULATION

**Prinzip.** `y[n] = c[n] · x[n]` mit einem bekannten Modulator `c[n]`.
**Bedingung.** `c[n] ≠ 0` für alle `n`.
**Inversion.** `x[n] = y[n] / c[n]`.

Der Modulator muss beim Dekodieren reproduzierbar sein, also entweder deterministisch berechenbar (Oszillator mit bekannter Phase) oder aus einem seedbaren PRNG.

## 1. Rechteck-Modulation

Ein Rechteck mit Werten `±1` erfüllt die Bedingung trivial. Bei hoher Modulationsfrequenz entstehen dichte Seitenband-Cluster, klanglich metallisch und ringmodulatorisch.

## 2. Zufällige Vorzeichenfolge

Die Zuspitzung: `c[n] ∈ {−1, +1}`, pro Sample zufällig aus einem seedbaren PRNG oder LFSR.

```
y[n] = c[n] · x[n]
x[n] = c[n] · y[n]          // dieselbe Operation, denn c[n]² = 1
```

Das Verfahren ist **involutorisch**, es ist sein eigenes Inverses. Keine Division, keine Rundung, exakt bis aufs Bit.

**Ergebnis.** Perfekt weißes Rauschen mit der Amplitudenhüllkurve des Originals. Das Betragsspektrum wird vollständig flachgeklopft, weil eine Zufalls-Vorzeichenfolge ein flaches Spektrum hat und Multiplikation im Zeitbereich Faltung im Frequenzbereich bedeutet.

**Einordnung.** Das ist Direct-Sequence Spread Spectrum, beziehungsweise ein One-Time-Pad im Sample-Bereich. Die Information ist vollständig erhalten, nur maximal gespreizt.

**Variation über die Rate.** Wechselt das Vorzeichen nicht jedes Sample, sondern alle 50 bis 500 Samples, entsteht statt Rauschen eine zerhackte, granulare Textur mit hörbaren Klick-Artefakten an den Vorzeichenwechseln. Die Umschaltrate ist eine eigenständige Klangachse, siehe Teil X.

## 3. Amplitudenmodulation mit Offset

Für weichere Ergebnisse einen Träger mit Gleichanteil verwenden:

```
c[n] = 1.2 + sin(2π f n / fs)          // Minimum 0.2, nie null
```

Die Division bleibt stabil, solange der Offset komfortabel über der Modulationsamplitude liegt. Die Fehlerverstärkung ist `1/min(c)`, hier also Faktor 5.

**Warnung.** Ein Sinus ohne Offset ist unbrauchbar, weil er bei jedem Nulldurchgang die Information des zugehörigen Samples vernichtet und die Division dort explodiert.

---

# TEIL IV — KLASSE C: LINEARE PHASENVERFAHREN

Diese Klasse ist konzeptionell die eleganteste und numerisch die beste. Sie greift die Erkenntnis aus Teil I.3(b) auf: Rauschcharakter entsteht auch ohne jede Änderung des Betragsspektrums, allein durch Zerstörung der Phasenkohärenz.

**Prinzip.** Filterung mit `H(z)`, wobei `|H(e^{jω})| = 1` für alle `ω`.
**Bedingung.** Allpass-Eigenschaft.
**Inversion.** `1/H(z)`, realisiert über Zeitumkehr.

## 1. Warum das funktioniert

Ein Allpass ändert nur die Phase jedes Frequenzanteils, nicht dessen Amplitude. Ein Schlagzeug-Transient ist ein Ereignis, bei dem alle Frequenzen phasenkohärent zusammenfallen. Zerstört man diese Kohärenz, verschmiert der Transient über hunderte Millisekunden zu einer diffusen Wolke. Das Spektrum bleibt dabei **exakt identisch**, weshalb der Klangcharakter durchgehend erkennbar bleibt.

Das ist genau die Wahrnehmung von "dasselbe Signal löst sich auf", im Gegensatz zu "ein anderes Signal wird eingeblendet".

## 2. Der Zeitumkehr-Trick

Das direkte Inversfilter `1/A(z)` hat seine Pole dort, wo `A` seine Nullstellen hat, und diese liegen bei einem Allpass außerhalb des Einheitskreises. Das Inversfilter ist also kausal instabil. Der Ausweg nutzt die definierende Eigenschaft reeller Allpässe:

```
A(z) · A(1/z) = 1
```

`A(1/z)` ist der zeitumgekehrte Filter. Also:

```
Rekonstruktion:  Signal umkehren → durch dasselbe A(z) → wieder umkehren
```

Die Phasendrehung hebt sich exakt auf. **Einschränkung:** Zeitumkehr erfordert das vollständige Signal, das Verfahren ist damit offline-only oder blockbasiert mit entsprechender Latenz. Für Echtzeit muss man stattdessen eine parallele Trockenkopie mitführen oder auf Klasse VII ausweichen.

## 3. Random-Phase-Impulsantwort

Die Verallgemeinerung mit maximaler Zerstörungskraft:

```python
# Konstruktion einer Allpass-FIR mit zufälliger Phase
phi = random_uniform(0, 2*pi, N//2+1)
phi[0] = 0; phi[-1] = 0                    # DC und Nyquist reell halten
H = exp(1j * phi)                          # Betrag überall 1
h = irfft(H, N)                            # reelle Impulsantwort

y = convolve(x, h)                         # Vorwärts
x = convolve(y, h[::-1])                   # Rückwärts, exakt
```

Das Ergebnis ist ein "Rausch-Reverb" ohne Nachhallfahne im üblichen Sinn, das Signal wird in eine diffuse Wolke der Länge `N` verschmiert. Bei `N` von einigen tausend Samples ist von einem Drumhit nichts mehr als ein Zischen übrig.

Zu beachten: lineare gegen zirkulare Faltung sauber trennen, sonst stimmt die Rekonstruktion an den Blockrändern nicht. Die Gesamtlatenz des Round-Trips beträgt `2N`.

## 4. Dispersiver Allpass in Kaskade

Die Echtzeit-taugliche Variante: Kaskade von Allpässen erster oder zweiter Ordnung.

```
A(z) = (a + z⁻¹) / (1 + a·z⁻¹)          mit |a| < 1
```

Bei 50 bis 200 Stufen entsteht die charakteristische frequenzabhängige Gruppenlaufzeit, die tiefe Frequenzen stark verzögert und hohe kaum. Klanglich der "Laserstrahl" oder "Sproing"-Effekt. Der Koeffizient `a` und die Stufenzahl sind zwei getrennte Achsen. Für den Makro-Übergang in Teil X ist das die wichtigste Struktur überhaupt, weil sie einen stufenlosen Parameter besitzt, der bei `a = 0` die Identität ergibt.

## 5. Frequenzverschiebung

Echtes Frequency Shifting über die Hilbert-Transformation verschiebt alle Frequenzanteile um denselben absoluten Betrag, macht harmonische Verhältnisse also inharmonisch. Das klingt bei größeren Verschiebungen schnell nach Klingeln und schließlich nach Rauschen.

**Invertierbar** durch Rückverschiebung, solange nichts über 0 Hz oder Nyquist hinausgefaltet wurde. Genau das ist die praktische Hürde, denn tiefe Anteile bei negativer Verschiebung falten sich an DC und sind dann verloren. Sicherheitshalber vorher hochpassfiltern.

## 6. Minimalphasige Filter

Jedes IIR-Filter mit Nullstellen innerhalb des Einheitskreises ist durch das Inversfilter exakt umkehrbar, auch ein absurd resonantes mit `Q = 200`. Die Kondition ist allerdings genau dort schlecht, wo das Filter tiefe Notches hat, denn dort verstärkt das Inversfilter massiv. Formal invertierbar, praktisch mit Vorsicht.

---

# TEIL V — KLASSE D: ZEITACHSEN-VERFAHREN

## 1. Zeitverzerrung / echte Phasenmodulation

```
y[n] = x(n + m[n])          // Lesekopfposition wird moduliert
```

Das ist Phasenmodulation im wörtlichen Sinn: die Position im Sample wird verschoben, nicht die Amplitude.

**Bedingung.** Die Warp-Funktion `τ(t) = t + m(t)` muss streng monoton sein, also:

```
m'(t) > −1
```

Sichere Praxisregel: `|m'(t)| < 1`. Wird die Bedingung verletzt, läuft der Lesekopf rückwärts, dieselbe Stelle wird mehrfach gelesen, und die Abbildung ist nicht mehr injektiv.

**Inversion.** Numerische Umkehrung der Warp-Funktion, in der Praxis durch Aufbau einer Lookup-Tabelle von `τ` und Interpolation der Umkehrung.

**Kondition.** Der wunde Punkt ist nicht die Mathematik, sondern die **Interpolation**. Jedes Lesen an nicht-ganzzahligen Positionen ist eine Näherung. Mit linearer Interpolation ist der Round-Trip hörbar dumpf, brauchbar wird es erst ab Sinc- oder hochordnungs-Lagrange-Interpolation. Rechne mit einem Round-Trip-Fehler um −60 bis −80 dB statt der −300 dB der Phasenverfahren.

**Klang.** Bei niedrigen Modulationsraten Wow und Flutter, bei hohen ein zerfetztes, körniges Chaos. Erreicht selten echtes Rauschen, ist aber ein hervorragender Zwischenzustand.

## 2. Permutationen

Umsortieren von Samples oder kurzen Grains nach einer seedbaren Permutation. **Per Konstruktion bijektiv**, die Umkehrung ist die inverse Permutation. Keinerlei Rundungsfehler, bitgenau.

Zwei orthogonale Parameter:

- **Granulat.** Einzelsamples ergeben Rauschen mit unverändertem Amplitudenhistogramm. Grains von 20 bis 200 Samples ergeben körnige Texturen mit erhaltenem lokalen Spektrum.
- **Radius.** Wie weit darf ein Element maximal verschoben werden? Kleine Radien geben Flatter und Zischeln, große geben vollständige Auflösung. Dieser Parameter ist für Teil X besonders wertvoll, weil Radius 0 exakt die Identität ergibt.

---

# TEIL VI — KLASSE E: BIT-EBENE

Der radikalste Bruch mit der Signalvorstellung: Das Sample wird als Bitmuster behandelt, nicht als Zahl.

```
y[n] = x[n] XOR k[n]          // k aus seedbarem PRNG
x[n] = y[n] XOR k[n]          // involutorisch, exakt
```

Das ist eine Stromchiffre. Werden alle 16 Bit ge-XOR-t, ist das Ergebnis statistisch nicht von weißem Rauschen zu unterscheiden. Die Information ist vollständig erhalten.

**Die entscheidende Achse ist die Bit-Tiefe `k`:** Nur die untersten `k` Bits XOR-verknüpfen. Bei `k = 0` passiert nichts, bei `k = 4` liegt ein leises Zischen über dem unveränderten Signal, bei `k = 10` dominiert das Rauschen, bei `k = 16` ist das Original perzeptiv verschwunden. Der Rauschboden steigt kontinuierlich **durch das Signal hindurch**, statt es zu ersetzen. Das ist eine der am feinsten dosierbaren Achsen überhaupt.

Verwandt: Bit-Permutation innerhalb des Wortes, ebenfalls bijektiv und exakt.

---

# TEIL VII — DER UNIVERSALTRICK: STRUKTURELLE INVERTIERBARKEIT

Alle bisherigen Klassen mussten eine Bedingung an die Zerstörungsoperation stellen: Monotonie, Nullstellenfreiheit, Allpass, Warp-Monotonie. Die folgenden Konstruktionen heben diese Beschränkung auf. Sie sind der Grund, warum man am Ende doch Hard Clipping, Gleichrichtung und Bitcrushing invertierbar bekommen kann.

## 1. Lifting

Teile das Signal in zwei Kanäle auf, etwa gerade und ungerade Samples oder Tief- und Hochband. Dann:

```
y₁ = x₁
y₂ = x₂ + f(x₁)
```

**Inversion:**

```
x₁ = y₁
x₂ = y₂ − f(y₁)          // f(x₁) ist rekonstruierbar, weil x₁ = y₁ unverändert vorliegt
```

Die entscheidende Beobachtung: **`f` darf absolut beliebig sein.** Hard Clipping, Gleichrichtung, ein Chaos-Iterator, ein Bitcrusher, ein neuronales Netz, ein ganzer Effekt-Rack. `f` muss weder monoton noch stetig noch überhaupt sinnvoll sein. Die Invertierbarkeit kommt allein aus der Struktur, nicht aus `f`.

Der Preis: Ein Kanal bleibt unberührt. Das löst man durch **Kaskadierung mit wechselnder Rolle**:

```
y₂ = x₂ + f₁(x₁)
y₁ = x₁ + f₂(y₂)          // beachte: y₂, nicht x₂
z₂ = y₂ + f₃(y₁)
...
```

Jeder Schritt ist einzeln invertierbar, also auch die Kette, indem man sie rückwärts durchläuft. Nach drei bis vier Schritten ist kein Kanal mehr im Originalzustand, und beliebig brutale `f` sind im Spiel.

**Integer-Variante.** Mit `y₂ = x₂ + round(f(x₁))` bleibt alles ganzzahlig und damit bitgenau. Das ist exakt das Prinzip hinter Integer-Wavelets und verlustfreien Audiocodecs.

Für maximale Zerstörung bei garantierter Umkehrbarkeit ist Lifting der ergiebigste Ansatz im gesamten Dokument.

## 2. Der Residuum-Ansatz

Der Spezialfall, der die Sache am ehrlichsten macht:

```
y = clip(x, T)
r = x − clip(x, T)          // das Abgeschnittene
x = y + r                   // trivial
```

`r` ist meistens Stille mit gelegentlichen kleinen Buckeln, also spottbillig zu speichern oder in den unteren Bits von `y` unterzubringen (Steganografie im eigenen Signal).

Das ist formal nur ein Lifting-Schritt, aber es formuliert das Grundprinzip in seiner klarsten Form: **Du kannst Clipping haben, du kannst Invertierbarkeit haben, und wenn du beides willst, musst du die entfernte Information irgendwo ablegen.** Es gibt keinen Weg, der diese Buchhaltung umgeht.

## 3. Rückwärtsadaptive Parameter

Ein Mechanismus, der sich mit allen vorherigen Klassen kombinieren lässt und ihnen enorme Lebendigkeit gibt.

**Regel.** Jeder Parameter deiner Verzerrung, also Schwelle, Gain, Modulus, Modulationstiefe, Allpass-Koeffizient, darf beliebig wild in der Zeit variieren, **solange er sich ausschließlich aus bereits dekodierten vergangenen Samples berechnet.**

```
Encoder:  T[n] = g(x[n-1], x[n-2], ...)   →   y[n] = F(x[n], T[n])
Decoder:  T[n] = g(x[n-1], x[n-2], ...)   →   x[n] = F⁻¹(y[n], T[n])
```

Der Dekoder läuft sequenziell, kennt beim Sample `n` bereits die gesamte Vergangenheit und berechnet daraus **dieselbe** Parameterfolge wie der Encoder. Es muss keinerlei Seiteninformation übertragen werden.

Das ist das Prinzip rückwärtsadaptiver Quantisierer in ADPCM. Praktisch heißt es: Ein Peak-Follower steuert die Kennlinienhärte, ein vom Signal gefütterter Chaos-Oszillator moduliert die Vorzeichenfolge, ein Onset-Detektor schaltet die Allpass-Kaskade. Alles legal, alles exakt umkehrbar.

**Wichtige Einschränkung.** Der Dekoder muss strikt sequenziell laufen, Sample für Sample. Keine Blockparallelisierung, keine Vektorisierung über die Zeitachse.

## 4. Modulo-Folding mit Oversampling

Der interessanteste Fall von Folgen-Invertierbarkeit, in der Literatur als *Unlimited Sampling* bekannt (Bhandari, Krahmer, Raskar, ab 2017). Es ist der nächste Verwandte zu einem tatsächlich invertierbaren Hard Clipping.

```
y[n] = ((x[n] + λ) mod 2λ) − λ
```

Statt zu clippen, springt das Signal bei jedem Überschreiten von `λ` auf `−λ` zurück. Klanglich brutaler als Clipping, ein zersägtes Fuzz-Kreischen.

**Als Punktabbildung ist das nicht injektiv.** Als Folge schon, und zwar so:

Bilde die Differenz `Δy[n] = y[n] − y[n−1]`. Die Faltungen erscheinen darin als Sprünge, die **exakt Vielfache von `2λ`** sind. Wenn man hoch genug oversampled, ist die echte Signaldifferenz `|Δx| < λ`, und dann lassen sich Faltungssprünge eindeutig von echter Signalbewegung unterscheiden. Man zählt die Faltungen mit, addiert die Vielfachen von `2λ` wieder auf und integriert zurück.

**Die praktische Hürde.** Das funktioniert nur bei der hohen Abtastrate. Dezimiert man das gefaltete Signal auf 44,1 kHz, zerstört das Antialiasing-Filter genau die scharfen Kanten, aus denen die Rekonstruktion die Faltungen abliest. Der reversible Pfad muss also durchgehend bei acht- bis sechzehnfachem Oversampling laufen, und nur die Ausgabe wird dezimiert.

**Fehlerfortpflanzung.** Ungnädig. Eine einzige verpasste Faltung verschiebt alles Folgende um `2λ`. Robuste Algorithmusvarianten existieren, vertragen aber nur begrenzt Rauschen.

---

# TEIL VIII — GESAMTÜBERSICHT

| # | Verfahren | Bedingung | Art der Inversion | Kondition | Klangcharakter |
|---|---|---|---|---|---|
| A1 | Potenzkennlinie | streng monoton | geschlossene Formel | mäßig (`1/p`) | harte Verzerrung |
| A2 | tanh / arsinh | streng monoton | geschlossene Formel | schlecht bei hohem `g` | Sättigung |
| A3 | Integer-Wrap | Bijektion mod 2ⁿ | Rückrechnung | exakt | Digitalkreischen |
| A4 | Mult. mit ungeradem `a` | ggT(a,2ⁿ)=1 | modulares Inverses | exakt | weißes Rauschen |
| B1 | Rechteck-Modulation | `c ≠ 0` | Division | gut | Ringmod, metallisch |
| B2 | Zufalls-Vorzeichen | — | involutorisch | exakt | weißes Rauschen |
| B3 | AM mit Offset | `min c > 0` | Division | `1/min(c)` | Tremolo bis Ringmod |
| C1 | Random-Phase-IR | Allpass | Faltung mit `h[−n]` | exakt | diffuse Wolke |
| C2 | Allpass-Kaskade | `\|a\| < 1` | Zeitumkehr-Filterung | exakt | Dispersion, Sproing |
| C3 | Frequency Shift | kein DC/Nyq-Wrap | Rückverschiebung | gut | inharmonisch, Klingeln |
| C4 | Minimalphasiges IIR | Nullst. innerhalb EK | Inversfilter | schlecht bei Notches | Resonanz |
| D1 | Zeitverzerrung | `m' > −1` | numerische Umkehr | Interpolation begrenzt | Flutter bis Chaos |
| D2 | Permutation | — | inverse Permutation | exakt | granular bis Rauschen |
| E1 | XOR-Stromchiffre | — | involutorisch | exakt | Rauschboden im Signal |
| F1 | **Lifting** | **keine** | strukturell | exakt (Integer) | beliebig |
| F2 | Residuum-Speicherung | keine | Addition | exakt | echtes Clipping |
| F3 | Rückwärtsadaptiv | Kausalität | sequenziell | wie Basisverfahren | lebendig, signalabhängig |
| F4 | Modulo-Folding | Oversampling | Δ-Analyse + Integration | fragil | Fuzz-Kreischen |

**Ableseregel.** Willst du garantierte Exaktheit, nimm C1, C2, B2, D2, E1 oder F1. Willst du maximale Zerstörung ohne Rücksicht auf die Kennlinie, nimm F1. Willst du echtes Hard Clipping, nimm F2 und akzeptiere die Buchhaltung.

---

# TEIL IX — DER BRUCH: WARUM DER MAKRO-ÜBERGANG EINE ANDERE AUFGABE IST

Bis hier ging es um eine einzige Frage: Wie rekonstruiere ich `x` aus einem zerstörten `y`? Der graduelle Übergang von Sample zu Rauschen und zurück stellt eine **andere Frage**, und die Verwechslung der beiden ist die häufigste Fehlerquelle in diesem Themenfeld.

## 1. Die formale Gegenüberstellung

**Invertierbarkeit** ist eine Eigenschaft *einer* Abbildung:

```
Gesucht: F⁻¹  mit  F⁻¹(F(x)) = x
Die Information wird aus dem zerstörten Signal zurückgerechnet.
```

**Der Makro-Übergang** ist eine Eigenschaft einer *Familie* von Abbildungen:

```
Gesucht: F_d  für d ∈ [0,1]  mit  F_0 = Identität
und stetiger Abhängigkeit von d.
Die Information wird nie zurückgerechnet, sie war nie weg.
```

Mathematisch ist das zweite eine **Homotopie zur Identität**, nicht eine Bijektion. Der Rückweg besteht schlicht darin, `d` wieder auf 0 zu fahren, während das trockene Original weiterläuft. Bei `d = 0` tut der Prozess nichts, also erscheint das Original von selbst wieder.

## 2. Die beiden Eigenschaften sind unabhängig

Das ist der Punkt, an dem die meisten Missverständnisse entstehen. Alle vier Kombinationen existieren:

| | invertierbar | nicht invertierbar |
|---|---|---|
| **`F_0 = id` vorhanden** | Allpass mit `a → 0`, XOR mit `k → 0` | Clipping mit `T → ∞`, Bitcrush mit `bits → 16` |
| **kein Pfad zur Identität** | fixe Zufalls-Permutation, Integer-Wrap mit `a = 26317` | Faltung mit fremder IR |

Für deinen Anwendungsfall zählt **nur die linke Spalte der Zeilenbedeutung**, also die obere Zeile. Ob das Verfahren zusätzlich invertierbar ist, spielt für das Hörergebnis keine Rolle.

Konkret: Deine ursprüngliche Idee, die Clipping-Schwelle über die Signalamplitude hinauszuschieben, **erfüllt die Makro-Anforderung perfekt**, obwohl Clipping nicht invertierbar ist. Bei `T > max|x|` ist der Clipper die Identität. Genau das ist gefordert.

## 3. Wann Invertierbarkeit für den Makro doch nützt

Drei Fälle rechtfertigen den Mehraufwand:

1. **Bitgenaue Rückkehr.** Wenn das Ergebnis bei `d = 0` exakt das Original sein muss, nicht nur perzeptiv, etwa weil weiterverarbeitet oder mit einer Trockenspur summiert wird.
2. **Feedback-Strukturen.** Läuft das Signal wiederholt durch die Kette, akkumulieren sich Artefakte nicht-invertierbarer Verfahren. Ein Allpass kann tausendfach durchlaufen werden, ein Bitcrusher nicht.
3. **Konzeptuell.** Zu wissen, dass die Information die ganze Zeit vollständig vorhanden war und nur unhörbar dargestellt wurde, ist eine tragfähige kompositorische Idee, nicht nur ein technisches Detail.

Für den reinen Höreffekt eines Sweeps ist Invertierbarkeit **keine Anforderung**.

---

# TEIL X — DEN MAKRO-ÜBERGANG BAUEN

## 1. Die drei Anforderungen

Ein Parameter `d ∈ [0,1]` taugt für den Sweep, wenn:

1. **`F_0 = id`.** Bei `d = 0` passiert nachweislich nichts, Bit für Bit.
2. **Stetigkeit.** Kleine Änderungen von `d` ergeben kleine Änderungen im Klang. Keine Sprünge, keine Zipper-Noise. Parameter sample-genau glätten.
3. **Interessante Mitte.** Der Weg von 0 nach 1 sollte durchgehend etwas Neues erzählen, nicht nur monoton lauter rauschen.

Punkt 3 ist der schwierigste und wird in Abschnitt 4 und 5 behandelt.

## 2. Die beste Achse: Phasen-Dekohärenz

Wenn der Übergang sich anfühlen soll wie *dasselbe Signal, das sich auflöst*, und nicht wie zwei übereinandergelegte Sounds, dann ist das die richtige Wahl. Begründung siehe Teil IV.1: Das Betragsspektrum bleibt unangetastet, also bleibt die Klangfarbe über den gesamten Weg erkennbar, während die zeitliche Gestalt zerfällt.

**FFT-Variante:**

```
φ_neu[k] = φ_orig[k] + d · φ_rand[k]
```

mit über die Zeit **eingefrorenem** `φ_rand`. Wird `φ_rand` pro Block neu gewürfelt, entsteht Flackern statt eines stabilen Zustands.

**Zeitbereichs-Variante (echtzeitfähig):** Allpass-Kaskade nach IV.4, wobei `d` entweder den Koeffizienten `a` oder die Anzahl aktiver Stufen steuert. Bei `a = 0` ist der Filter die Identität, die Anforderung `F_0 = id` ist strukturell erfüllt.

**Verfeinerung mit großem Effekt.** Randomisiere die Phase nur oberhalb einer Grenzfrequenz `f_c` und fahre `f_c` von Nyquist nach unten. Der Klang löst sich dann von oben nach unten auf, was wesentlich filmischer wirkt als eine gleichmäßige Verwaschung. `f_c(d)` logarithmisch mappen.

## 3. Weitere Achsen mit brauchbarer Mitte

**Vorzeichen-Dropout.** Kippe pro Sample mit Wahrscheinlichkeit `d/2` das Vorzeichen. Bei `d = 0` Identität, bei `d = 1` weißes Rauschen mit der Hüllkurve des Originals (der Grenzfall von III.2). Die Mitte klingt nach starkem Zerren mit ansteigendem Rauschteppich. Sehr aggressiv, rechnerisch fast kostenlos.

**Bit-XOR-Tiefe.** `k = round(16·d)` untere Bits verrauschen, siehe Teil VI. Der Rauschboden steigt kontinuierlich durch das Signal hindurch. Die feinste Dosierbarkeit aller Achsen, besonders schön im unteren Drittel des Sweeps.

**Scramble-Radius.** Permutation nach V.2, maximale Verschiebedistanz wächst mit `d`. Radius 0 ist exakt die Identität. Die Grain-Größe ist ein zweiter, unabhängiger Regler für die Textur.

**Modulationstiefe der Zeitverzerrung.** Nach V.1, ohne die Monotonie-Schranke, weil nichts zurückgerechnet werden muss. Klingt nach kaputtem Bandlaufwerk, erreicht selten echtes Rauschen. Guter Zwischenschritt in der ersten Hälfte des Sweeps.

**Kennlinienhärte.** `p = 1 − d·0.95` bei der Potenzkennlinie, oder `T = max|x| · (1−d)` beim Clipping. Bei `d = 0` Identität. Ändert die Klangfarbe stark, zerstört aber die zeitliche Gestalt nicht, klingt also nach "verzerrt", nicht nach "aufgelöst".

**Rausch-Grenzfrequenz.** Ersetze das Spektrum oberhalb `f_c(d)` durch phasenrandomisierten Inhalt gleicher Energie. Kombiniert Achse 2 mit einer klaren spektralen Front.

## 4. Warum reines Dry/Wet enttäuscht

Da für den Makro keine Invertierbarkeit nötig ist, liegt der Gedanke nahe, irgendeinen zerstörerischen Effekt zu nehmen und einfach überzublenden. Das Problem ist ästhetisch, nicht technisch: Ein Crossfade klingt nach **zwei gleichzeitig laufenden Signalen**, nicht nach einer Verwandlung. Man hört in der Mitte beide Zustände nebeneinander statt eines Zwischenzustands.

Der gewünschte Effekt entsteht nur, wenn der Parameter **im** Prozess sitzt und das Signal selbst deformiert.

Falls doch gemischt wird, hilft eine spektrale Kopplung: Dem Wet-Anteil das Betragsspektrum des Dry-Signals aufprägen (Spectral Morphing), dann verschmelzen die beiden Schichten hörbar zu einer.

## 5. Mapping und Kalibrierung

Das ist der Schritt, der über Erfolg oder Misserfolg entscheidet und der am häufigsten übersprungen wird.

**Das Problem.** Fast alle genannten Parameter haben eine hässliche Kennlinie, bei der die ersten 10 Prozent bereits fast alles zerstören und der Rest nichts mehr tut. Ein linearer Regler fühlt sich dann kaputt an.

**Die Lösung.**

1. Definiere eine grobe Kohärenzmetrik `C(d)`, siehe Teil XI.2.
2. Miss `C` an 20 bis 50 Stützstellen über `d`.
3. Invertiere die gemessene Kurve numerisch und lege sie als Mapping-Tabelle zwischen Regler und Parameter.

Ergebnis ist ein Regler, dessen wahrgenommene Zerstörung linear mit der Position wächst.

**Lautheitskompensation.** Die meisten Verfahren ändern die Lautheit erheblich. Miss den RMS bei `d = 0` und bei `d = 1` und gleiche über eine Kompensationskurve aus, sonst wird der Sweep als Lautstärkefahrt gehört statt als Verwandlung.

## 6. Layering: mehrere Achsen auf einen Regler

Der wichtigste Kniff für Punkt 3 der Anforderungen. Lege zwei oder drei Achsen mit **versetzten Startpunkten und Rampen** auf dasselbe Makro:

```
d ∈ [0.00 … 0.55]   Phasendispersion         (Allpass-Kaskade)
d ∈ [0.25 … 0.80]   Rausch-Grenzfrequenz     (Nyquist → 200 Hz, log)
d ∈ [0.45 … 1.00]   Bit-XOR-Tiefe            (0 → 16 Bit)
d ∈ [0.70 … 1.00]   Vorzeichen-Dropout       (0 → 0.5)
```

Der Sweep erzählt dann über den gesamten Weg etwas Neues: erst löst sich die Zeitstruktur auf, dann frisst sich das Rauschen von oben ins Spektrum, dann steigt der Rauschboden von unten durch das Signal, zuletzt bleibt nur die Hüllkurve. Der Rückweg durchläuft dieselben Stationen umgekehrt.

Jede Teilrampe einzeln kalibrieren, bevor sie kombiniert werden.

---

# TEIL XI — MESSEN UND TESTEN

## 1. Round-Trip-Fehler (für Teil II–VII)

```python
y   = forward(x)
xr  = inverse(y)
err = 20*log10( rms(xr - x) / rms(x) )
```

Richtwerte zur Einordnung:

| Bereich | Bedeutung |
|---|---|
| unter −250 dB | exakt, nur Float-Rundung (Allpass, XOR, Permutation, Lifting) |
| −120 bis −250 dB | praktisch perfekt, unhörbar |
| −60 bis −120 dB | brauchbar, Rauschteppich unter Signalpegel (Zeitverzerrung) |
| −20 bis −60 dB | hörbar degradiert, meist Kondition oder Interpolation |
| über −20 dB | Verfahren praktisch nicht invertierbar |

Immer zusätzlich das **Fehlersignal anhören**, nicht nur die Zahl lesen. Ein Fehler von −50 dB, der als leises Zischen breitbandig verteilt ist, ist harmlos. Derselbe Fehler als Transienten-Klicks ist es nicht.

## 2. Kohärenzmetrik (für Teil X)

Für die Kalibrierung des Makro-Reglers braucht man ein Maß für "wie weit ist es schon zerstört". Drei brauchbare Kandidaten:

**Normierte Kreuzkorrelation** zwischen Original und Ergebnis. Sinkt bei Phasenverfahren sauber von 1 gegen 0, ignoriert aber spektrale Veränderungen.

**Spektrale Flachheit** des Ergebnisses. Steigt bei Rauscherzeugung gegen 1, reagiert aber nicht auf reine Phasenzerstörung, weil das Spektrum dort unverändert bleibt.

**Transienten-Schärfe**, etwa der Crest-Faktor oder die maximale Steigung der Hüllkurve. Reagiert empfindlich auf Dispersion und ist daher für Phasenverfahren das aussagekräftigste Maß.

Da keine einzelne Metrik alle Achsen erfasst, sinnvollerweise zwei kombinieren und gewichtet mitteln. Für die reine Regler-Linearisierung reicht bereits eine grobe Näherung.

## 3. Praktische Checkliste

- Durchgehend Float64, keine Zwischenquantisierung auf dem reversiblen Pfad
- PRNG-Seeds explizit speichern, sonst ist die Rekonstruktion verloren
- Bei FFT-Verfahren lineare gegen zirkulare Faltung sauber trennen
- Latenzen des Round-Trips dokumentieren (`2N` bei Random-Phase-IR)
- Beim Makro alle Parameter sample-genau glätten, typisch 5 bis 50 ms Zeitkonstante
- Lautheit über den gesamten Sweep messen und kompensieren
- `d = 0` explizit gegen das Original testen, Bit für Bit

---

# ANHANG — MINIMALE REFERENZIMPLEMENTIERUNGEN

```python
import numpy as np

# --- A1: Potenzkennlinie -----------------------------------------
def power_fw(x, p=0.05):  return np.sign(x) * np.abs(x)**p
def power_iv(y, p=0.05):  return np.sign(y) * np.abs(y)**(1/p)

# --- B2: Zufalls-Vorzeichen (involutorisch) ----------------------
def sign_scramble(x, seed):
    rng = np.random.default_rng(seed)
    c = rng.choice([-1.0, 1.0], size=len(x))
    return x * c                      # identisch für hin und zurück

# --- C1: Random-Phase-Allpass ------------------------------------
def make_ap_ir(N, seed):
    rng = np.random.default_rng(seed)
    phi = rng.uniform(0, 2*np.pi, N//2 + 1)
    phi[0] = 0.0; phi[-1] = 0.0
    return np.fft.irfft(np.exp(1j*phi), N)

def ap_fw(x, h):  return np.convolve(x, h)
def ap_iv(y, h):  return np.convolve(y, h[::-1])   # Länge/Offset beachten

# --- D2: Permutation ---------------------------------------------
def perm_fw(x, seed):
    rng = np.random.default_rng(seed)
    idx = rng.permutation(len(x))
    return x[idx], idx
def perm_iv(y, idx):
    out = np.empty_like(y); out[idx] = y; return out

# --- E1: XOR-Stromchiffre mit Bit-Tiefe ---------------------------
def xor_bits(xi16, seed, k):
    rng  = np.random.default_rng(seed)
    mask = (1 << k) - 1
    key  = rng.integers(0, 65536, size=len(xi16), dtype=np.uint16) & mask
    return xi16.astype(np.uint16) ^ key       # involutorisch

# --- F1: Lifting mit BELIEBIGEM f ---------------------------------
def lift_fw(x, f):
    x1, x2 = x[0::2].copy(), x[1::2].copy()
    y2 = x2 + f(x1)
    y1 = x1 + f(y2)
    return y1, y2
def lift_iv(y1, y2, f):
    x1 = y1 - f(y2)
    x2 = y2 - f(x1)
    out = np.empty(len(x1) + len(x2))
    out[0::2], out[1::2] = x1, x2
    return out
# f darf hier Hard Clipping, Bitcrush, Gleichrichtung sein — beliebig.

# --- Makro-Achse: Allpass-Dispersion mit F_0 = id -------------------
def disperse(x, d, stages=64):
    a = 0.85 * d                       # d = 0  ->  a = 0  ->  Identität
    y = x.copy()
    for _ in range(stages):
        z = 0.0; out = np.empty_like(y)
        for n in range(len(y)):
            v = y[n] - a*z
            out[n] = a*v + z
            z = v
        y = out
    return y
```

---

## Zusammenfassung in drei Sätzen

Invertierbare Rauscherzeugung ist im Kern Verschlüsselung: Das Signal wird statistisch und perzeptiv zu Rauschen, behält aber seine gesamte Information, und die stärksten Werkzeuge dafür sind Phasenverfahren (exakt und klanglich überzeugend) sowie Lifting (beliebig brutal und strukturell garantiert).

Der graduelle Übergang vom Sample zum Rauschen ist eine davon unabhängige Aufgabe, die nur einen Parameter mit `F_0 = id` verlangt, und für die Invertierbarkeit weder nötig noch hinreichend ist.

Wer beides zugleich will, kombiniert eine Phasen- oder Lifting-Struktur mit einem sauber kalibrierten, mehrschichtigen Makro-Regler, und misst am Ende sowohl den Round-Trip-Fehler als auch die Linearität der wahrgenommenen Zerstörung.
