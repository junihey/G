# FFT-Techniken für Klang-Metamorphosen – und was davon in Max/MSP und RNBO realistisch machbar ist

Fast jede spektrale Metamorphose-Technik lässt sich in Max/MSP komfortabel umsetzen, in RNBO dagegen nur ein Teil: Alles, was **pro Bin und ohne Blick auf andere Bins oder Frames** arbeitet (Cross-Synthese, Magnituden-Morphing, Gating, Masken, Spektral-Arithmetik, Blur, Freeze), ist in RNBO einfach. Alles, was **Zugriff auf den ganzen Frame oder auf mehrere Frames** braucht (Sorting, Bin-Warping, Top-N-Tracing, Median-HPSS, sauberer Phase-Vocoder, Partial-Tracking), erfordert in RNBO eine selbstgebaute Frame-Puffer-Architektur in codebox~ oder ist auf Embedded-Zielen schlicht nicht praktikabel. Der Grund ist strukturell: RNBO hat kein pfft~, sondern nur streamende fft~/ifft~-Objekte, deren Hop an die FFT-Größe gekoppelt ist.

## TL;DR

- **Max/MSP ist die Werkstatt, RNBO das Exportformat:** In Max stehen pfft~ (bis 1.048.576 Punkte, beliebige Overlaps), framedelta~/frameaccum~, gen~ in pfft~, Jitter-Matrizen, FrameLib, FluCoMa (fluid.audiotransport~, fluid.hpss~, fluid.sines~, fluid.nmfmorph~) und SuperVP zur Verfügung; RNBO bietet nur fft~/ifft~ (= fftstream~/ifftstream~) mit 64–4096 Punkten, Framesize ≥ FFT-Größe, Overlap nur über parallele, phasenversetzte Ketten, kein framedelta~/frameaccum~/fftinfo~, kein Jitter, keine Externals.
- **Für Metamorphosen in RNBO sind die "Kronjuwelen" gut erreichbar:** Magnituden-Interpolation zwischen zwei Quellen, Cross-Synthese (Amplitude von A, Phase von B), spektrale Hüllkurven-Übertragung per Glättung, Freeze mit Phasenrandomisierung, Blur und Spectral Delay mit Feedback sind in RNBO "einfach" bis "mit Aufwand" umsetzbar; Sorting, Warping und Frame-Granulation werden "mit Aufwand" machbar, sobald man Frames in data/buffer~ schreibt und in codebox~ mit Schleifen verarbeitet.
- **Schwierig bis unpraktikabel in RNBO:** hochwertiges Time-Stretching/Pitch-Shifting per Phase-Vocoder (Forum-Berichte bis 2026 zeigen ungelöste Artefaktprobleme), Phase-Locking, Median-HPSS und echtes Partial-Tracking; hier empfiehlt sich ein Hybrid: Analyse in Max (FluCoMa, SPEAR, IRCAM pm2), Ergebnis als Tabellen in Buffer exportieren, in RNBO nur noch resynthetisieren und morphen – oder eine eigene STFT-Engine in codebox~ mit fftbuffer.

## Key Findings

1. **RNBO hat offiziell kein pfft~.** Cycling '74 schreibt in "Using the FFT": "While RNBO does not currently provide pfft~, it's possible to emulate pfft~ in RNBO". Die Emulation besteht aus parallelen fft~/ifft~-Abstraktionen mit Phasenversatz (z. B. 512 0 / 512 128 / 512 256 / 512 384 für 4-fach-Overlap). Das Fenster wird direkt in fft~/ifft~ angewandt (rectangular als Default, dazu Hann, Hamming, Blackman oder ein eigener Fenster-Buffer).
2. **Der Hop ist an die FFT-Größe gekoppelt.** Die RNBO-Referenz zu fftstream~ (rnbo.cycling74.com) sagt zum zweiten Argument: "The second argument specifies the number of samples between successive FFTs. This must be at least the number of points, and must also be a power of two"; ein Nutzer bestätigt 2026, dass `fft~ 2048 512 0` keine Änderung bewirkt. Overlap entsteht nur durch mehrere Ketten. Jede Kette analysiert dabei weiterhin ein volles Fenster, und aufeinanderfolgende Frames einer Kette liegen N Samples auseinander.
3. **Maximale FFT-Größe in RNBO: 4096** (Enum fft64 … fft4096); Max' pfft~ geht bis 1.048.576. Für extreme Zeitstreckung/Freeze tiefer Klänge (hohe Frequenzauflösung) ist RNBO damit begrenzt.
4. **codebox~ ist der Schlüssel.** RNBO-FFTs sind "stateful operators which can be used in codebox~", als gepufferte Variante (fftbuffer, in-place, interleaved real/imag) und als streamende (fftstream/ifftstream). Mit codebox~ hat man Schleifen, peek/poke auf data/buffer~ und sogar `list.sort` (sortierte Werte plus Indizes) – also alles, was Frame-Operationen brauchen.
5. **Die Praxis ist holprig.** Forum-Threads berichten von "lofi" klingendem Spectral Freeze im Vergleich zu pfft~ (Raspberry Pi mit Pisound), von "gritty, amplitude modulated" 4-fach-Overlap, von Phase-Vocoder-Ports mit starken Artefakten beim Timestretching (fehlendes framedelta~/frameaccum~), und von einem Fehler "No option of name: win_bufname" bei fftstream in codebox~ unter RNBO 1.4.5, obwohl die Release Notes 1.4.4 genau diesen Fix nennen. Eine offizielle, gut klingende Phase-Vocoder-Referenz für RNBO existiert nach meiner Recherche nicht.
6. **Es gibt keine verlässlichen CPU-Zahlen für FFT-Patches auf dem Raspberry Pi.** Es existieren nur qualitative Aussagen ("pretty cpu intensive"; ein HISE-Nutzer berichtet, RNBO-FFT "performs worse compared to doing the same stuff with max pfft~ or pure data"). Seit RNBO 1.3.0 wird der Pi 5 unterstützt, seit 1.3.2 hat das Runner-Webinterface einen DSP-CPU-Meter – man muss selbst messen.

## Grundlagen: Wie Spektralverarbeitung in Max vs. RNBO strukturell funktioniert

**Max/MSP (pfft~):** pfft~ lädt einen Subpatcher und übernimmt Fensterung, Overlap und Overlap-Add. Innerhalb liefern fftin~ Real-, Imaginärteil und Bin-Index; fftout~ resynthetisiert. Die I/O-Latenz ist "window size minus the hop size" – bei 1024/Overlap 4 also 768 Samples. Wichtige Helfer: cartopol~/poltocar~ (Amplitude/Phase), framedelta~ (Phasendifferenz zwischen Frames), frameaccum~ (laufende Phase), phasewrap~, vectral~ (Frame-Glättung), fftinfo~. In gen~ innerhalb von pfft~ entspricht `vectorsize` der Anzahl der Bins; `delay vectorsize` verzögert also jeden Bin um genau einen Frame – das ist der Standardbaustein für Spectral Delay, Blur und Feedback. Jitter-Matrizen (Jean-François Charles, "A Tutorial on Spectral Sound Processing Using Max/MSP and Jitter", Computer Music Journal 32(3), 2008, S. 87–102) speichern Spektren als 2-D-Bild (Magnitude/Phasendifferenz × Frames), was graphische Transformationen, Interpolation zwischen eingefrorenen Frames und Scrubbing erlaubt.

**RNBO:** fft~/ifft~ streamen pro Sample einen Bin (dritter Ausgang = Bin-Index, irreführend "phase" genannt). Was in pfft~ ein Subpatch ist, wird in RNBO eine Abstraktion, die mit Patcher-Argumenten für FFT-Größe und Phasenversatz mehrfach instanziiert wird. Die entscheidende Konsequenz: **Innerhalb des Streams sehen Sie immer nur den aktuellen Bin.** Operationen, die Nachbar-Bins oder den ganzen Frame brauchen, müssen den Frame erst in einen data/buffer~ schreiben und können ihn frühestens im nächsten Frame lesen (+1 Frame Latenz). Die Alternative ist eine eigene STFT-Engine in codebox~: Eingang in einen Ringpuffer schreiben, alle H Samples (z. B. N/4) einen Frame kopieren, fenstern, per fftbuffer transformieren, den kompletten Frame mit Schleifen verarbeiten, zurücktransformieren (falls kein separater inverser Operator verfügbar ist, über den Konjugations-Trick: konjugieren → FFT → konjugieren → durch N teilen) und per Overlap-Add in einen Ausgangsring schreiben. Das liefert echten pfft~-artigen Hop und wahlfreien Zugriff auf den Frame – erzeugt aber CPU-Spitzen pro Hop, die auf kleinen Vektorgrößen (Pi, Daisy) Dropouts riskieren.

**Was RNBO grundsätzlich nicht kann:** Jitter, Third-Party-Externals (also kein FluCoMa, FrameLib, SuperVP, MuBu, zsa.descriptors, CNMAT, sigmund~), gizmo~, pfft~, framedelta~, frameaccum~, fftinfo~. Wo es um Pitch geht, gibt es in RNBO immerhin fzero~ (f0-Schätzung) und retune~. Externe Faust-Werkzeuge können codebox-Code erzeugen (`faust -lang codebox`); das Drittprojekt faust-rs bewirbt zusätzlich Frame-Rate-FFT-Bibliotheken (interleave.lib) mit codebox-Backend – vielversprechend, aber experimentell und laut eigener Doku nur manuell gegen RNBO validiert.

## 1. Spektrales Morphing / Interpolation zwischen zwei Quellen

**Prinzip.** Beide Quellen werden mit identischen FFT-Parametern analysiert. Pro Bin werden Magnituden interpoliert (linear, besser in dB/log, damit der Übergang perzeptiv gleichmäßiger wirkt). Für die Phase gibt es drei Wege: (a) Phase der dominanten Quelle übernehmen, (b) Phase per Schwellwert umschalten, (c) die *Instantanfrequenz* (Phasendifferenz zwischen Frames) interpolieren und daraus eine neue Phase akkumulieren – das ist der "echte" Phase-Vocoder-Morph. Eine Verfeinerung trennt **Hüllkurve (Formant/Klangfarbe)** von **Feinstruktur (Partials/Tonhöhe)** und morpht beide unabhängig. Partial-basiertes Morphing interpoliert Frequenzen und Amplituden zugeordneter Partials (siehe Abschnitt 7). Optimal-Transport-Morphing (FluCoMa AudioTransport) verschiebt spektrale "Masse" von Peak zu Peak, statt überzublenden – zwischen 220 Hz und 880 Hz entsteht so eine Art Glissando statt zweier gleichzeitiger Töne. Laut FluCoMa ist das Ergebnis "quantised to the resolution of the spectral bins".

**Klangliches Ergebnis.** Lineare Magnituden-Interpolation klingt bei unähnlichen Quellen oft wie ein Crossfade mit "Phasing"; erst Hüllkurven-/Feinstruktur-Trennung oder Peak-basiertes Morphing liefert das Gefühl, dass *ein* Objekt seine Form ändert. Caetano & Rodet ("Musical Instrument Sound Morphing Guided by Perceptually Motivated Features", IEEE TASLP 21(8), Aug. 2013, S. 1666–1675) berichten: "We found that interpolation of line spectral frequencies gives the most linear spectral envelope morphs... interpolation of cepstral coefficients results in the most linear temporal envelope morph." Trevor Wishart betont, dass bei Transformationen der Weg (das ">" zwischen A und B) wichtiger ist als die Endpunkte und dass sich ähnliche Quellen leichter morphen lassen.

**Max/MSP.** pfft~ mit zwei fftin~ → cartopol~ → Magnituden-Mix (z. B. in gen~) → Phase von A/B oder via framedelta~/frameaccum~ → poltocar~ → fftout~. Für Morphing zwischen eingefrorenen Frames: Charles' Patch "6-interpolate-2frames" (Jitter). Fertige Alternativen: fluid.audiotransport~ (Echtzeit), fluid.bufaudiotransport, fluid.nmfmorph~ (Morph zwischen NMF-Basen), CDP MORPH/NEWMORPH offline als Referenz.

**RNBO – Bewertung: einfach (Magnituden-Morph) / mit Aufwand (Instantanfrequenz-Morph) / schwierig (Optimal Transport).**
- Magnituden-Interpolation mit Phase von A oder B: zwei fft~-Ketten pro Overlap-Phase, cartopol~/poltocar~ bzw. Mathematik in codebox~, ein param für den Morph-Faktor. Problemlos.
- Instantanfrequenz-Morph: framedelta~/frameaccum~ fehlen. Nachbau in codebox~: pro Bin die vorherige Phase in einem data-Array (Index = Bin) speichern, Differenz bilden, wrappen, interpolieren, akkumulieren. Wichtig: Bei parallelen Ketten braucht **jede Kette ihren eigenen** Phasenspeicher, und der Phasenvorschub muss mit dem tatsächlichen Abstand der Frames dieser Kette (N Samples) gerechnet werden. Genau hier scheitern laut Forum viele Ports.
- Optimal Transport: braucht pro Frame kumulative Verteilungen über alle Bins und eine Neuabbildung → nur über eine eigene STFT-Engine mit Frame-Schleifen in codebox~ sinnvoll. Ich habe dafür kein veröffentlichtes RNBO-Beispiel gefunden.

## 2. Cross-Synthese, spektrale Faltung, Vocoder, Hüllkurven-Übertragung

**Prinzip.** Klassische Cross-Synthese: Amplitudenspektrum von A × Phasenspektrum von B (CDP "Cross") oder komplexe Multiplikation der Spektren (spektrale Faltung → "A spielt durch den Resonanzkörper von B"). Vocoder-artig: Nur die **spektrale Hüllkurve** von A (geglättete Amplitude) wird auf B übertragen; B wird vorher "flachgemacht" (durch seine eigene Hüllkurve geteilt = Whitening). Hüllkurven-Schätzung: (a) Glättung über Nachbar-Bins, (b) Cepstrum (log-Magnitude → FFT → Liftering → zurück), (c) True Envelope (iteratives Cepstrum, SuperVP), (d) LPC (Allpol-Modell im Zeitbereich). Spektrale Hüllkurven-Erhaltung ist zugleich die Grundlage formantkorrekter Tonhöhenverschiebung.

**Klangliches Ergebnis.** Hybride: "sprechende" Synthesizer, Glocke mit Vokalfarbe, Regen, der die Formanten einer Stimme trägt. Für Metamorphosen besonders wirkungsvoll, wenn der Hüllkurven-Anteil mit einem Parameter von 0→1 eingeblendet wird (CDP COMBINE CROSS macht "a gradual transition from the amplitude of the first spectral envelope to that of the second").

**Max/MSP.** Beispiel-Patch cross-dog.maxpat (Help → Examples), gen~ in pfft~ für die Mathematik; für Bin-Glättung mit Nachbarn eignen sich Jitter oder FrameLib (Frames als Vektoren). Hochwertig: SuperVP for Max (supervp.cross~ – "generalized cross-synthesis", supervp.sourcefilter~ – Source-Filter-Cross-Synthese; supervp.trans~ kann seit v2.18.1 "apply a frequency warping function to the envelope"); kostenpflichtig über das IRCAM Forum. FluCoMa: fluid.bufnmfcross~ (NMF-basierte Hybridisierung, offline).

**RNBO – Bewertung: einfach (Cross Amp/Phase, komplexe Multiplikation) / mit Aufwand (Hüllkurve per Bin-Glättung) / schwierig (Cepstrum, True Envelope).**
- Amp(A) × Phase(B) und komplexe Multiplikation sind reine Pro-Bin-Operationen → einfach.
- Hüllkurven-Glättung: Eine *einseitige* Glättung über die Bins (rekursiver Tiefpass entlang des Bin-Index, Reset bei Bin 0) geht direkt im Stream, ist aber zu hohen Frequenzen hin verschoben. Eine *symmetrische* Glättung braucht den Frame im Puffer (+1 Frame Latenz) oder läuft vorwärts und rückwärts in einer codebox~-Schleife.
- Cepstrum: pro Frame eine zweite FFT des log-Spektrums → mit fftbuffer in codebox~ machbar, aber nur sinnvoll in einer eigenen STFT-Engine; CPU-intensiv, auf dem Pi eher mit N=1024 testen.
- LPC: Levinson-Durbin in codebox~ im Zeitbereich ist machbar (mit Aufwand) und unabhängig von FFT-Einschränkungen – eine gute Alternative für die Vocoder-Hüllkurve.

## 3. Spectral Sorting, Bin-Reordering, Shuffling, Swapping, Warping, Frequency Remapping

**Prinzip.** Die Bins eines Frames werden umgeordnet: nach Magnitude sortiert (lauteste nach unten/oben), zufällig permutiert (Shuffle), paarweise vertauscht (Swap), oder es wird über eine Warping-Funktion bestimmt, welcher Eingangs-Bin auf welchen Ausgangs-Bin abgebildet wird (Spektral-Stretching, -Kompression, -Inversion um eine Achse, -Faltung). Frequency Remapping mit Phasenkorrektur (Instantanfrequenz mitskalieren) erhält tonale Qualität; ohne Korrektur entstehen metallische, "zerbrochene" Klänge. CDP nennt verwandte Prozesse: Specnu Slice 5/Specfold 2 (Inversion), Specfold 3 (Randomisieren der Frequenzen), Fold (Oktavfaltung), Invert (Hüllkurve kopfstehend).

**Klangliches Ergebnis.** Sorting zerstört die harmonische Struktur zugunsten eines "Energieprofils" – Klänge werden zu glitzernden, unnatürlichen Klangflächen, die aber die Hüllkurve des Originals behalten. Ein Morph-Parameter (Anteil sortiert/unsortiert, oder Interpolation zwischen Original-Index und Ziel-Index) ergibt eine sehr kontrollierbare Verwandlung "von Instrument zu Textur". Warping-Kurven, die langsam animiert werden, erzeugen Übergänge von harmonisch zu inharmonisch.

**Max/MSP.** Sorting im Signalbereich von pfft~ ist unbequem, weil Bins sequentiell kommen. Übliche Wege: (a) Frame in buffer~ schreiben, im nächsten Frame mit index~/peek~ an berechneter Stelle lesen (Warping, Shuffle mit Permutationstabelle); (b) Jitter: Spektrum als Matrix, Remapping per jit.gen/jit.repos, Sortieren ist aber auch in Jitter mühsam (Forum: "Sorting in jit.gen" mit Pseudo-Sortier-Workarounds); (c) FrameLib (Alex Harker) – frame-basierte DSP mit Operatoren wie sort, percentiles, min/max; die eleganteste Lösung für echtes Per-Frame-Sorting in Max.

**RNBO – Bewertung: mit Aufwand (Warping, Shuffle, Swap) / mit Aufwand bis schwierig (Sorting).**
- Warping/Shuffle/Swap: Frame k in ein data-Array schreiben (Index = Bin-Ausgang von fft~), Frame k+1 liest Bin `map[k]` aus dem Array. Permutations- und Warping-Tabellen liegen in einem zweiten data/buffer~, der per Message oder Parameter neu berechnet wird. Kostet einen Frame Latenz, ist aber CPU-billig.
- Sorting: Beim letzten Bin des Frames (Bin-Index = N/2−1) in codebox~ eine Sortierschleife über das Magnituden-Array laufen lassen (eigener Sortieralgorithmus über data, oder `list.sort`, das sortierte Werte **und Indizes** liefert – letzteres ist für Remapping ideal). Achtung: Die gesamte Sortierung passiert in einem Sample → CPU-Spitze. Bei 1024 Bins ist ein O(n log n)-Verfahren unkritisch auf dem Desktop, auf dem Pi testen. Ein Gen-Forum-Thread warnt, dass Insertion-Sort über große Buffer "millions of iterations" verursacht, und empfiehlt, die Arbeit über die Zeit zu verteilen – in RNBO entsprechend: über die N Samples des nächsten Frames verteilt sortieren (inkrementell), dann +2 Frames Latenz.
- Bei Overlap muss jede Kette ihr eigenes Frame-Array besitzen.

## 4. Smearing, Blur, Freeze, zeitliche Mittelung, Spectral Delay, spektrale "Reverb"-Diffusion

**Prinzip.**
- **Blur/Smearing:** Pro Bin wird die Magnitude über die Zeit gemittelt (rekursiver Tiefpass oder gleitender Mittelwert über M Frames; CDP BLUR BLUR "averages spectral amplitudes over time").
- **Freeze:** Ein Frame (oder ein Mittel mehrerer Frames) wird gehalten; die Phasen werden pro Bin mit der Instantanfrequenz fortgeschrieben, plus etwas Phasenrauschen, damit der Freeze "lebt" (Cycling '74 Phase-Vocoder-Tutorial Teil II: "a very small amount of phase deviation from bin to bin actually breaks the mechanical sound of the freeze"). Charles' Freeze-Patches gehen weiter: stochastischer Freeze aus n aufeinanderfolgenden Spektren, entrauschter Freeze, Attack/Release-Glättung, "harmonic freeze" zum Aufschichten von Akkorden.
- **Spectral Delay:** Jeder Bin bekommt eine eigene Verzögerung (in Frames) und ggf. Feedback (Kim-Boyle; John Gibsons jg.spectdelay~; IRCAMs Chromax mit gen~ in pfft~). Feedback-Schleifen haben mindestens einen Frame Verzögerung. Ein Versatz der Delay-Zeit im Feedback-Pfad lässt Energie in Nachbar-Bins wandern (spektrales Glissando).
- **Diffusion/Reverb-artig:** Freeze/Blur mit langen Zeitkonstanten + Phasenrandomisierung + frequenzabhängigem Feedback ergibt halligen Nachklang ohne Hall-Algorithmus.

**Klangliches Ergebnis.** Blur verwandelt Artikulation in Fläche – Sprache wird zu Chor, Perkussion zu Wolke; mit animiertem Blur-Faktor entsteht eine Metamorphose "vom Ereignis zur Textur" und zurück. Freeze ist der klassische "Moment, der zur Klangfläche wird". Spectral Delay mit frequenzabhängigen Zeiten zerlegt Klänge in kaskadierende Spektralschichten (aufsteigende/absteigende Glissandi bei kurvenförmigen Delay-Verteilungen).

**Max/MSP.** gen~ in pfft~ mit `delay vectorsize` (= 1 Frame) für Blur/Feedback; Spectral-Delay-Beispiele in den gen~-Examples und als Max-for-Live-Device "Max SpectralDelay.amxd"; vectral~ für Frame-Glättung; Charles' Freeze-Patches (Jitter); FrameLib-Beispiel "stochastic phase vocoder" (von Harker für seinen Spectral Freeze genutzt).

**RNBO – Bewertung: einfach (Blur, Freeze ohne Phasenkorrektur) / mit Aufwand (Freeze mit Instantanfrequenz, Spectral Delay mit Feedback).**
- Blur: Pro Kette `delay~` um genau N Samples (= ein Frame dieser Kette) als History pro Bin, dann `y = a·y_prev + (1−a)·x`. Einfach.
- Freeze: Magnituden bei Trigger in data schreiben und halten; Phase entweder randomisieren (sehr einfach, klingt "rauschig-lebendig") oder per eigener Phasenakkumulation fortschreiben (mit Aufwand). Berichte über "lofi"-Freeze in RNBO beziehen sich auf einfache 1-Ketten-Versionen; 4-fach-Overlap mit Hann-Fenster plus Phasenrauschen ist der wichtigste Qualitätshebel. Ein Ringpuffer von Spektralframes (Magnituden pro Frame in einem großen data) erlaubt Scrubbing durch die "Spektral-Aufnahme".
- Spectral Delay: Pro Bin eine Delay-Zeit aus einer Tabelle lesen (peek mit Bin-Index), Verzögerung = d·N Samples in einem großen Delay-Buffer (Speicherbedarf: Max-Frames × N pro Kette). Feedback ist zulässig, weil die Schleife ≥ ein Frame lang ist. Mit Aufwand, CPU moderat.

## 5. Spektrale Operationen: Gating, Tracing, Masking, Arithmetik, Kompression, Tilt

**Prinzip.**
- **Gating/Thresholding:** Bins unter einer Schwelle → 0 (rauscharm, "blubbernd" bei hoher Schwelle); invertiert ergibt es "nur das Rauschen".
- **Denoising/Clean:** Schwelle pro Bin aus einem Rauschprofil (CDP Clean).
- **Tracing (Top-N):** Nur die N lautesten Bins behalten (CDP Trace), das Gegenteil ist Suppress.
- **Masking:** Ein Spektrum steuert, welche Bins des anderen durchkommen (binäre oder weiche Maske).
- **Arithmetik:** Summe, Differenz, Max, Min, Mittel zweier Spektren (CDP COMBINE: Sum, Diff, Max, Mean, Interleave).
- **Spektrale Kompression/Expansion:** Magnituden mit Exponent <1 bzw. >1 (dynamische Ebnung bzw. Betonung der Peaks; CDP Exaggerate).
- **Tilt:** frequenzabhängige Gewichtung (Bin-Index × Steigung).

**Klangliches Ergebnis.** Top-N-Tracing mit langsam fallendem N ist eine der eindrücklichsten Metamorphosen: ein Orchesterklang "skelettiert" sich zu wenigen Sinus-Linien. Max/Min zwischen zwei Quellen erzeugt Hybride, in denen jeweils die dominante Quelle pro Frequenz gewinnt – ein guter "dritter Weg" zwischen Crossfade und Cross-Synthese. Masking erlaubt "Ausstanzen" einer Quelle in der Form der anderen.

**Max/MSP.** Alles in gen~ in pfft~ trivial; Rauschprofil in buffer~; Forbidden Planet (Settel/Lippe) als EQ/Masken-Vorbild; Top-N am elegantesten mit FrameLib (Sortieren/Perzentile pro Frame).

**RNBO – Bewertung: einfach (Gate, Masken, Arithmetik, Kompression, Tilt, Rauschprofil) / mit Aufwand (Top-N).**
- Alle zustandslosen Pro-Bin-Operationen sind die Stärke von RNBO-FFT; Cycling '74 zeigt selbst ein Noise-Reduction-Gate und eine Forbidden-Planet-Portierung (Spektral-EQ aus einem Buffer) als offizielle Beispiele.
- Top-N braucht eine Rangfolge: Workaround ohne Sortieren – im Frame k ein Histogramm der Magnituden (z. B. 64 log-Klassen) aufbauen, am Frame-Ende den Schwellwert für "N Bins darüber" bestimmen und im Frame k+1 anwenden (+1 Frame Latenz, O(N) statt O(N log N)). Alternativ `list.sort`.

## 6. Phase-Vocoder-Techniken

**Prinzip.**
- **Time-Stretching:** Frames werden mit anderer Rate gelesen als geschrieben; Phasen werden aus der Instantanfrequenz neu akkumuliert. Beim Pitch-Shifting wird zusätzlich resampelt oder die Bins werden verschoben (Laroche & Dolson: Peak-Shifting).
- **Phasenrandomisierung/Scrambling:** Phasen werden durch Zufall ersetzt → Klang wird diffus, rauschig, "verwaschen"; teilweise Randomisierung ist ein sanfter Morph-Parameter von "klar" zu "Wolke".
- **Phase-Locking (J. Laroche & M. Dolson, "Improved Phase Vocoder Time-Scale Modification of Audio", IEEE Transactions on Speech and Audio Processing, Bd. 7, Nr. 3, S. 323–332, Mai 1999):** Bins um einen Peak übernehmen die Phasenbeziehung des Peaks → weniger "Phasiness".
- **Transient/Tonal-Trennung (HPSS):** Derry FitzGerald (TU Dublin), "Harmonic/Percussive Separation Using Median Filtering", Proc. DAFx-10, Graz, 6.–10. Sept. 2010, S. 246–253: Median-Filter horizontal (über Zeit) betont Tonales, vertikal (über Frequenz) betont Transienten; "The two resulting median filtered spectrograms are then used to generate masks." Für Metamorphosen: Tonal- und Perkussivanteil getrennt morphen (z. B. Transienten von A behalten, Tonalität von B einblenden) – genau diese Idee steckt auch im "Transient Bypass"-Modul von Zynaptiq MORPH 3.
- **Spektrales Stretching/Shifting der Partials:** Frequenzen werden um einen Offset verschoben (harmonisch → inharmonisch) oder mit einem Exponenten gestreckt (Wishart nennt Spectral Stretching als einen seiner zentralen Prozesse für *Vox 5*; CDP Stretch, Shift, Waver).

**Klangliches Ergebnis.** Extreme Zeitstreckung ist selbst eine Metamorphose (Mikrostruktur wird zur Form). Inharmonisches Stretching verwandelt Stimme oder Saite in Glocke/Metall; langsam animiert entsteht ein kontinuierlicher Übergang von harmonisch zu inharmonisch.

**Max/MSP.** Cycling '74-Tutorials "The Phase Vocoder" Teil I/II (Wiedergabe aus buffer~ pro Overlap, fft~ im full-spectrum-pfft~, Freeze mit Zufall), phase-vocoder-sampler.maxpat, gizmo~ (Pitch-Shift in pfft~), Charles' Time-Stretch-Patches, SuperVP (supervp.scrub~/play~/trans~ mit Transientenerhaltung, Hüllkurvenerhaltung), fluid.hpss~ (Echtzeit-HPSS), fluid.sines~ (Sinus/Residuum).

**RNBO – Bewertung: einfach (Phasenrandomisierung, Frequenz-Shift ohne Phasenkorrektur) / schwierig (Time-Stretch/Pitch-Shift in guter Qualität, Phase-Locking, Median-HPSS) / mit Aufwand (Partial-Stretching mit Phasenkorrektur).**
- Phasenrandomisierung: pro Bin `phase = mix(phase, random, amount)` → trivial.
- Time-Stretch/Pitch-Shift: In RNBO fehlen framedelta~/frameaccum~ und gizmo~; das Forum dokumentiert 2024–2026 mehrere gescheiterte oder unbefriedigende Ports ("unexpected pitch/formant/phase artifacts when timestretched even a little bit"; konstantes "fluttering" bei einem Laroche-Dolson-Pitchshifter in codebox~ auf dem Pi). Eine einfache Sample-basierte Variante (Wiedergabe aus buffer~ mit eigener Leseposition pro Kette, Phasenakkumulation in codebox~) ist machbar, verlangt aber sorgfältiges Phasen-Bookkeeping pro Kette. Realistischer Weg: eigene STFT-Engine in codebox~ mit echtem Hop (N/4) und fftbuffer. Für reines Pitch-Shifting ohne Spektralzwang: in RNBO lieber granulare/zeitbereichsbasierte Shifter.
- Median-HPSS: horizontaler Median braucht pro Bin L Frames Historie (Ringpuffer L × N/2), vertikaler Median braucht den ganzen Frame → nur mit Frame-Pufferung; kleine Mediane (L≈9–17) sind in codebox~ per Partial-Sort machbar, aber CPU-intensiv. Auf Desktop/Plugin "mit Aufwand", auf dem Pi eher "schwierig". Einfacher Ersatz: Transientendetektion per spektralem Flux (Pro-Bin-Differenz zum Vorframe) und weiche Maske.

## 7. Sinusoidal-/Partial-Tracking, additive Resynthese, Sinus+Rausch-Modelle

**Prinzip.** Peaks pro Frame finden (mit quadratischer Interpolation für genaue Frequenz), über Frames zu Partials verbinden (McAulay-Quatieri), Residuum als gefiltertes Rauschen modellieren (Serra: SMS). Morphing: Partials von A und B einander zuordnen (z. B. über Harmonischen-Nummer), Frequenzen und Amplituden interpolieren, Rausch-Hüllkurven separat morphen. Caetano & Rodet kombinieren genau das: Sinus+Rauschen, Partial-Frequenzen interpolieren, spektrale Hüllkurve separat (LSF). Kyma und Alchemy (Logic) gelten als Referenz für dieses "echte" additive Morphing.

**Klangliches Ergebnis.** Die perzeptiv überzeugendsten Morphs zwischen *tonalen* Klängen (Instrument → Instrument, Stimme → Instrument), weil Tonhöhe, Formant und Rauschanteil getrennt kontrolliert werden. Bei geräuschhaften Quellen versagt das Modell (zu viele, zu kurze Tracks).

**Max/MSP.** sigmund~ (Peaks/Tracks in Echtzeit), fluid.sines~ (Echtzeit-Zerlegung in Sinus + Residuum, inklusive Mindestdauer eines Tracks), IRCAM pm2 (über OpenMusic/Kommandozeile; kostenpflichtige Forum-Lizenz), SPEAR (offline, Export von Partials als Text/SDIF) → Resynthese in Max per oscbank~/ioscbank~ oder MC-Oszillatoren; CNMAT-Tools (SDIF, sinusoids~) als ältere Referenz.

**RNBO – Bewertung: nicht praktikabel (vollständiges Echtzeit-Tracking mit dynamischen Track-Listen) / einfach bis mit Aufwand (Resynthese und Morph vorab analysierter Partials).**
- Echtes Tracking verlangt dynamische Datenstrukturen (Track-Geburt/-Tod, Zuordnung), die RNBO nur rudimentär hat (ein Nutzer im Forum: "RNBO has only appears to have fairly basic list support, no other data structures"). Eine Peak-Detektion pro Frame (lokale Maxima über Schwelle) ist in codebox~ dagegen machbar.
- Empfohlener Hybrid: Partials offline in Max/SPEAR/FluCoMa analysieren, als Matrix (Frames × Partials × {Freq, Amp}) in einen mehrkanaligen buffer~ schreiben; RNBO liest beide Tabellen, interpoliert und speist eine Oszillatorbank in codebox~ (Schleife über 32–128 Partials). Buffer werden bei VST/AU-Export mit "Copy Sample Dependencies" bzw. über externe Datarefs mitgeliefert (das Forum dokumentiert dabei frühere Bugs, also testen). fzero~ kann in RNBO für eine einfache harmonische Live-Analyse dienen (Partial k = k·f0, Amplituden aus FFT-Bins abgelesen).

## 8. Weitere transformationsrelevante Techniken

- **Spektrale Granulation:** Kurze Gruppen gespeicherter Spektralframes werden als "Körner" mit eigener Position, Dichte und Transposition resynthetisiert. RNBO: mit Aufwand (Spektral-Ringpuffer + mehrere Leseköpfe; Leseköpfe teilen sich die Ketten-Struktur). Max: Jitter-Matrizen oder FrameLib.
- **Spektrale "Drunk Walks" / Shuffle / Weave (CDP BLUR DRUNK, SHUFFLE, WEAVE, Specnu Rand):** Zufallswege oder Muster durch die Folge der Analysefenster. RNBO: mit Aufwand, aber konzeptionell einfach, sobald ein Spektral-Ringpuffer existiert (Leseindex = Zufallsweg).
- **Accumulate/Sustain (CDP Accumulate/Superaccu):** Pro Bin wird die Magnitude als Maximum gehalten und langsam abklingen gelassen – ein "spektraler Peak-Hold-Hall". RNBO: einfach (Max-Operation mit Decay pro Kette).
- **Glisten/Scatter (CDP):** zufällige Teilmengen von Bins pro Fenster → "glitzernd/blubbernd". RNBO: einfach (zufällige Maske pro Frame).
- **NMF-basierte Hybride (FluCoMa fluid.bufnmf~, fluid.bufnmfcross~, fluid.nmfmorph~):** Zerlegen in Spektral-Templates und Aktivierungen, Rekombination über Quellen hinweg. RNBO: nicht praktikabel (iterativ, offline-lastig) – Ergebnisse aber als Buffer vorbereitbar.
- **CDP/Wishart als Ideenkatalog:** CDP gliedert Spektralprozesse in Reshape, Filter, Pitch/Frequency, Morph, Formants, Combine, Time und Utilities; MORPH, NEWMORPH (Peak-Morph, auch zwischen unähnlichen Klängen), GLIDE (Glissando zwischen zwei Einzelspektren), SPECROSS PARTIALS sind unmittelbare Metamorphose-Vorlagen. Laut Archer Endrich (CDP-Doku zu MORPH) wollte Wishart mit der CDP-Spektralsuite den Morph "Stimmen → Bienen" vom Beginn von *Red Bird* (1973–77) nachbilden, für den wenige Sekunden im analogen Tonbandstudio zwei Wochen gedauert hatten; die digitalen Werkzeuge, die "zz"-Laute in "a swarm of bees" morphen, entstanden nach Wisharts eigener Darstellung (eContact! 15.2) in den 1980er-Jahren am IRCAM (*Vox 5*). Eine WASM-Portierung von CDP (cdp-wasm) existiert für Node/Browser – nicht für RNBO, aber als Offline-Referenz nützlich.
- **Kommerzielle Referenzpunkte:** Zynaptiq MORPH 3 (laut Zynaptiq-Pressemitteilung vom 25. April 2024 vier neue Algorithmen – "INTERWEAVE V3, IMPRINT SMOOTH, IMPRINT CRYSTAL, and ENHARMONIC" – "for a total of 9 algorithms"; die Pro-Version ergänzt "FUSION and SONANCE, for a total of 11 algorithms", dazu ein "patent-pending real-time style transfer module" und einen "transient bypass"); ein Nutzer im KVR-Forum hält solche Plugins für "fancy cross-synthesis/vocoder transformation plugins" und Kyma/Alchemy für "echtes" Morphing – das ist eine Einzelmeinung, trifft aber die oben beschriebene Trennung zwischen STFT-Hybridisierung und partial-basiertem Morphing. IRCAM AudioSculpt/SuperVP ist die Qualitätsreferenz für Hüllkurvenerhaltung und Transienten; SPEAR für Partial-Editing.

## Vergleichstabelle

| Technik | Metamorphose-Potenzial | Beste Umsetzung in Max | RNBO-Machbarkeit | Bester RNBO-Ansatz |
|---|---|---|---|---|
| Magnituden-Interpolation A↔B | mittel (bei ähnlichen Quellen hoch) | pfft~ + gen~ | einfach | parallele fft~-Ketten, Mix in codebox~ |
| Instantanfrequenz-Morph | hoch | pfft~ + framedelta~/frameaccum~ | mit Aufwand | Phasenspeicher pro Kette in data |
| Optimal-Transport-Morph | sehr hoch | fluid.audiotransport~ | schwierig | eigene STFT-Engine, Frame-Schleifen |
| Cross-Synthese Amp×Phase / Faltung | hoch | cross-dog, gen~ in pfft~ | einfach | Pro-Bin-Mathematik |
| Hüllkurven-Transfer (Glättung) | sehr hoch | gen~/Jitter/FrameLib, supervp.cross~ | mit Aufwand | Frame puffern, symmetrisch glätten |
| Cepstrum/True Envelope | sehr hoch | SuperVP | schwierig | fftbuffer pro Frame; alternativ LPC |
| Bin-Warping/Shuffle/Swap | hoch | buffer~-Remapping, Jitter | mit Aufwand | Frame k schreiben, Frame k+1 umgemappt lesen |
| Spectral Sorting | hoch | FrameLib | mit Aufwand bis schwierig | list.sort/Sortierschleife am Frame-Ende, ggf. verteilt |
| Blur/Smearing | hoch | gen~ `delay vectorsize` | einfach | `delay~` N pro Kette |
| Freeze (+Phasenrauschen) | sehr hoch | Charles-Patches, PV-Tutorial II | einfach bis mit Aufwand | Magnituden halten, Phase randomisieren/akkumulieren |
| Spectral Delay + Feedback | hoch | gen~-Examples, jg.spectdelay~ | mit Aufwand | Delay-Tabelle per Bin, großer Delay-Buffer |
| Gate/Maske/Arithmetik/Tilt/Kompression | mittel bis hoch | gen~ in pfft~ | einfach | Pro-Bin |
| Top-N-Tracing | hoch | FrameLib | mit Aufwand | Histogramm-Schwelle aus Vorframe |
| Phasenrandomisierung | mittel | pfft~ | einfach | Pro-Bin |
| Time-Stretch / Pitch-Shift (PV) | hoch | PV-Tutorials, gizmo~, SuperVP | schwierig | eigene STFT-Engine; sonst Zeitbereichs-Shifter |
| Phase-Locking | Qualität | eigene gen~/SuperVP | schwierig | Peak-Suche pro Frame in Engine |
| HPSS (Median) | hoch (getrennt morphen) | fluid.hpss~ | schwierig | kleine Mediane, Flux-Maske als Ersatz |
| Partial-Stretch/Shift (Inharmonizität) | hoch | pfft~/SuperVP/CDP | mit Aufwand | Bin-Remapping + Phasenkorrektur |
| Partial-Tracking live | sehr hoch | sigmund~, fluid.sines~, pm2 | nicht praktikabel | – |
| Resynthese/Morph vorab analysierter Partials | sehr hoch | oscbank~, SPEAR-Import | einfach bis mit Aufwand | Tabellen-Buffer + Oszillatorbank in codebox~ |
| Spektral-Granulation / Drunk Walk | hoch | Jitter, FrameLib | mit Aufwand | Spektral-Ringpuffer + Leseköpfe |
| NMF-Hybride | sehr hoch | FluCoMa | nicht praktikabel | offline vorbereiten |

## Recommendations: Ein Metamorphose-Toolkit in RNBO bauen

1. **Architektur-Entscheidung zuerst.** Für Plugin/Web/Desktop: Baue einen **"Spektralkern"** als RNBO-Abstraktion (fft~/ifft~ mit Hann, Patcher-Argumente für N und Phasenversatz, 4 Instanzen für 4-fach-Overlap) – das ist der offiziell dokumentierte Weg und reicht für alle Pro-Bin-Module. Brauchst du Frame-Operationen (Sorting, Warping, Top-N, Cepstrum, PV), ergänze **pro Kette** ein data-Array für den letzten Frame. Erst wenn das nicht reicht (echter Hop, Time-Stretch), lohnt sich die **eigene STFT-Engine in codebox~** mit fftbuffer.
2. **Standardparameter:** N=2048, 4 Ketten (Hann auf fft~ und ifft~; Ausgangssumme normalisieren). Auf Raspberry Pi mit N=1024 und 2 Quellen starten und im Runner-CPU-Meter messen, bevor du Module stapelst. Latenz ist strukturell höher als bei pfft~ (pfft~: N−H; RNBO-Ketten: mindestens ein volles Fenster, plus je einen Frame für jede Frame-Pufferung) – für Live-Morphing einkalkulieren.
3. **Modul-Reihenfolge für ein Morph-Instrument (2 Eingänge A/B):**
   - (a) Magnituden-Morph in log-Domäne mit Phase-Quelle-Schalter,
   - (b) Hüllkurven-/Feinstruktur-Trennung per Bin-Glättung → zwei Morph-Regler ("Klangfarbe" und "Körper"),
   - (c) Cross-Synthese Amp(A)×Phase(B) als dritter Weg,
   - (d) Blur und Freeze als Zeit-Dimension,
   - (e) Top-N-Trace und Max/Min-Kombination als "Skelettierung",
   - (f) Bin-Warping-Tabelle (Stretch-Exponent, Shift) für harmonisch→inharmonisch,
   - (g) Phasenrandomisierung als "Auflösung in Wolke".
   Alle Regler als param, damit sie als VST/AU-Parameter automatisierbar sind – Metamorphosen entstehen durch Automation über Zeit, nicht durch statische Settings (Wishart: der Weg ist wichtiger als die Endpunkte).
4. **Morph-Qualität:** Wähle ähnliche Quellen oder gleiche sie vorher an (Tonhöhe, Dauer, Hüllkurve) – sowohl CDP als auch Wishart betonen, dass Morphs bei ähnlichen Quellen am besten gelingen. Interpoliere Magnituden in dB, nicht linear. Für die Hüllkurve gilt laut Caetano & Rodet LSF als perzeptiv linearste Repräsentation – in RNBO über LPC→LSF in codebox~ umsetzbar, aber anspruchsvoll; eine gute Bin-Glättung im log-Bereich ist der pragmatische Kompromiss.
5. **Hybrid-Workflow für das, was RNBO nicht kann:** Partial-Analyse (SPEAR, fluid.sines~, pm2), NMF-Zerlegung und HPSS offline in Max/FluCoMa; Ergebnisse als Buffer ins RNBO-Patch einbetten; RNBO übernimmt die Echtzeit-Interpolation und Resynthese. In Max selbst kannst du FrameLib als Prototyping-Umgebung für Frame-Algorithmen nutzen und sie dann als codebox~-Schleifen nach RNBO übertragen.
6. **Bekannte Stolpersteine:** fft~ kontrollieren (Fenster explizit setzen; Default ist rectangular); fftstream in codebox~ ist unter 1.4.5 möglicherweise noch fehlerhaft (win_bufname) – Patcher-fft~ ist der robustere Weg; FFT-Zustände bei Bedarf durch DSP-Neustart synchronisieren (seit 1.4.0 sind alle fft-Instanzen am globalen Samplecount ausgerichtet); Buffer-Abhängigkeiten im Export prüfen.

## Caveats

- Die RNBO-Einschränkungen (4096 Max-Größe, framesize ≥ fftsize, kein pfft~) stammen aus der aktuellen Referenz und den Release Notes bis 1.4.5; Cycling '74 kann pfft~-artiges Framing nachrüsten – eine Roadmap-Zusage habe ich nicht gefunden.
- Die Machbarkeits-Bewertungen sind meine Einschätzung aus Dokumentation, Forum-Erfahrungen und DSP-Logik, nicht aus Benchmarks; insbesondere CPU-Aussagen für den Raspberry Pi sind unbelegt und müssen gemessen werden.
- Forum-Berichte (lofi Freeze, PV-Artefakte, win_bufname-Fehler) sind Einzelberichte von Nutzern, teils unbeantwortet; sie können an individuellen Patches liegen.
- Die Inverse-FFT per Konjugations-Trick in codebox~ ist ein Standard-DSP-Verfahren; ob fftbuffer zusätzlich einen inversen Modus bietet, sollte in der aktuellen codebox-Referenz geprüft werden.
- Herstellerangaben zu Zynaptiq MORPH 3 und Einschätzungen aus KVR-Foren sind Marketing bzw. Meinung, nicht unabhängig geprüft. faust-rs ist ein Drittprojekt mit eigener, nicht verifizierter Leistungsbeschreibung.