# Ergänzung: Fehlende FFT-Metamorphose-Techniken und RNBO-Machbarkeit

Stand: 5. Oktober 2026

Der erste Bericht hat rund 30 Techniken übersehen; die wichtigsten sind Spectral Mutation (Polansky & Erbe) und der Sieb-Crossfade aus FFTease – beides echte Morphs, die in RNBO einfach umzusetzen sind. Dazu kommen zeitliche Hüllkurven pro Bin (SoundMagic), spektrale Spatialisierung, Zeitausrichtung per DTW, Phasenrekonstruktion per RTPGHI, Robotisierung, Stabil/Transient-Trennung über die Phase, Frequenz-Warping nach Evangelista, adaptive Steuerung, Morphs zwischen drei und mehr Quellen (Kyma) sowie Constant-Q und neuronale Morphs als Grenzfälle.

Methode: Ich habe die Liste gegen sechs etablierte Sammlungen abgeglichen – FFTease (38 Objekte), SoundHack, SoundMagic Spectral (23 Plugins), Ableton Live 11, das Lehrbuch *DAFX* (Zölzer) und Kyma – und gezielt nach den in der Chat-Antwort genannten Lücken gesucht. Bei *DAFX* kenne ich die Unterkapitel nur aus der 1. Auflage. Vollständig ist das bei einem so offenen Feld nie, aber die bekannten Kataloge sind jetzt abgedeckt. Die RNBO-Bewertungen sind meine Einschätzung, keine Tests.

## FFTease: der größte fehlende Baukasten

FFTease (Eric Lyon, Christopher Penrose, seit 1999) umfasst laut aktuellem README 38 Spektral-Objekte für Max und Pd; der Quellcode steht unter MIT-artiger Lizenz und darf portiert werden, solange der Copyright-Hinweis erhalten bleibt. Für RNBO heißt das: Die Externals selbst laufen dort nicht, aber jeder Algorithmus kann als codebox~-Port nachgebaut werden. Default ist FFT 1024 mit Overlap 8 – mehr Overlap, als RNBO-Ketten bequem liefern.

Für Metamorphosen relevant (Beschreibungen nach README, RNBO-Bewertung von mir):

| Objekt | Was es tut | Metamorphose-Nutzen | RNBO-Port |
| --- | --- | --- | --- |
| leaker~ | Sieb-basierter Crossfade: Bins wechseln in zufälliger Reihenfolge von A nach B | Morph, der wie ein „Durchsickern" klingt statt wie ein Crossfade | einfach (feste Zufallspermutation als Schwellwert pro Bin) |
| morphine~ | als Morph-Objekt beschrieben | direkter A→B-Morph | Algorithmus im C-Code prüfen, vermutlich pro Bin → einfach bis mit Aufwand |
| schmear~ | spektrales Verschmieren | Ereignis → Fläche | mit Aufwand, falls über Nachbar-Bins verschmiert wird |
| disarray~ / disarrain~ | Umverteilung der Spektralenergie; disarrain~ interpoliert dabei | Klang → glitzernde Textur, stufenlos | mit Aufwand (Frame puffern, Remapping-Tabelle) |
| reanimator~ | Textur-Mapper: ein Klang treibt gespeicherte Frames eines anderen | Streichquartett „spricht" durch Stimmaufnahme | schwierig (Frame-Suche über Datenbank pro Frame) |
| pileup~ | spektrale Akkumulation | Klang baut sich zur Wolke auf | einfach (Peak-Hold mit Decay) |
| loopsea~ | spektral geschichtetes, unabhängiges Looping | Bänder laufen auseinander | mit Aufwand (Spektral-Ringpuffer) |
| resent~ / residency~ | Spektral-Sampler; resent~ mit Geschwindigkeit pro Bin-Block | Teile des Spektrums bewegen sich verschieden schnell | mit Aufwand (Speicher: Frames × Bins) |
| ether~ / vacancy~ | spektrales Compositing zweier Quellen | eine Quelle füllt Lücken der anderen | einfach (pro Bin) |
| swinger~ | Phasentausch zwischen zwei Quellen | Cross-Synthese-Variante | einfach |
| mindwarp~ | Formant-Warping | Formantverschiebung ohne Tonhöhe | mit Aufwand (Hüllkurve nötig) |
| pvwarp~ / pvwarpb~ | nichtlinearer Frequenz-Warper, b-Version mit editierbarer Warp-Tabelle | harmonisch → inharmonisch | mit Aufwand |
| pvtuner~ | Spektrum auf beliebige Skala quantisieren | Geräusch → gestimmter Klang | mit Aufwand (Partial-Frequenz pro Bin nötig) |
| cavoc~ / cavoc27~ | zelluläre Automaten erzeugen Spektren | selbst-evolvierende Spektren | mit Aufwand (Regel pro Bin, Nachbarn aus Vorframe) |
| burrow~ | gegenseitig referenzierte Filterung | eine Quelle filtert die andere | einfach |
| xsyn~ / taint~ / cross~ | Cross-Synthese-Varianten (mit Kompression bzw. Gating) | Hybride | einfach |
| dentist~ | Partials gezielt entfernen | Skelettierung | einfach |

Eine CCRMA-Studienarbeit von Jennifer Hsu vergleicht verwandte Bin-Ersetzungs-Morphs: zufällige Bin-Ersetzung, Ersetzung nach Magnitude und Ersetzung von hohen zu tiefen Bins (oder umgekehrt). Alle drei sind in RNBO pro Bin mit einer Ordnungstabelle machbar.

Quellen: [FFTease README und Lizenz (GitHub)](https://github.com/ericlyon/FFTease3.0-MaxMSP), [FFTease-Paket bei Cycling '74](https://cycling74.com/packages/fftease), [FFTease-Klangbeispiele](https://disis.music.vt.edu/eric/LyonSoftware/MaxMSP/FFTease/Sound_Examples/index.html), [Jennifer Hsu, „It's Morphin' Time" (CCRMA)](https://ccrma.stanford.edu/~jhsu/421b).

## Spectral Mutation (Polansky & Erbe, SoundHack)

Spectral Mutation ist die wichtigste fehlende Morph-Familie – und sie passt fast perfekt zu RNBO, weil jede Funktion pro Bin arbeitet und nur den Vorframe braucht. Polansky und Erbe übertrugen 1996 Polanskys „Mutation Functions" aus der Melodik auf FFT-Frames (Computer Music Journal 20(1)).

Das Prinzip: Statt Amplituden zu mischen, werden die **Intervalle** gemischt – die Änderung einer Bin-Amplitude vom vorigen zum aktuellen Frame, getrennt in Richtung (Vorzeichen) und Betrag. Ω (0 = Quelle, 1 = Ziel) steuert den Grad; bei „uniformen" Mutationen ist Ω ein Interpolationswert, bei „irregulären" die Wahrscheinlichkeit, dass ein Bin ersetzt wird.

| Funktion | Was übertragen wird | Erreicht bei Ω=1 das Ziel? |
| --- | --- | --- |
| USIM (uniform signed) | Intervalle interpoliert – spektraler Crossfade | ja |
| ISIM (irregular signed) | zufällig gewählte Bins übernehmen Ziel-Intervall | ja |
| UUIM (uniform unsigned) | Betrag vom Ziel, Richtung von der Quelle | nein – „Abbild" des Ziels |
| IUIM (irregular unsigned) | wie UUIM, aber stochastisch pro Bin | nein |
| LCM (linear contour) | Richtung vom Ziel, Betrag von der Quelle | nein – laut Autoren oft unkenntlich, aber klanglich interessant |

Zusatzparameter: LCM lässt sich mit IUIM oder UUIM verketten (eigener, „zackiger" Morph-Weg). „Absolute Interval" misst gegen eine feste Amplitude statt gegen den Vorframe und zentriert so die Mutation; relative Intervalle driften dagegen und kommen teils nie am Ziel an. „Delta Emphasis" (−1 bis 1) glättet oder betont Frame-Änderungen, „Band Persist" hält einmal mutierte Bins stabil statt sie bei jedem Frame neu zu würfeln.

**RNBO: einfach bis mit Aufwand.** Pro Bin braucht man nur die eigenen Amplituden des Vorframes (Quelle, Ziel, Ausgang) – in jeder Overlap-Kette ein `delay~` um N Samples. Die irregulären Varianten brauchen pro Bin einen Zufallswert und für Band Persist einen Merker pro Bin (data-Array). Phase: die Formeln betreffen nur Amplituden; die Phase muss man selbst wählen (z. B. von der Quelle). Ich habe keine fertige Max- oder RNBO-Umsetzung gefunden.

Quellen: [Polansky & Erbe, „Spectral Mutation in Soundhack" (Volltext, Dartmouth)](https://eamusic.dartmouth.edu/~larry/SHPaper/soundhack.article.html), [Erbe, „SoundHack: A Brief Overview" (CMJ 21:1)](https://www.academia.edu/833007/SoundHack_A_Brief_Overview).

## Weitere Kataloge: SoundMagic Spectral und Ableton

SoundMagic Spectral (Michael Norris, 23 freie AU-Plugins, v1.5) liefert die meisten neuen Techniken – vor allem zeitliche Hüllkurven pro Bin, die der erste Bericht kaum behandelt hat. Norris nennt Wisharts *Audible Design* und CDP ausdrücklich als Vorbild.

| Technik (SoundMagic) | Was sie tut | RNBO |
| --- | --- | --- |
| Gate and Hold | Bin überschreitet Schwelle → wird eingefroren und bekommt eine eigene Hüllkurve (Fade-in, Hold, Fade-out), optional frequenzabhängig verzögert, gepulst, verschoben | mit Aufwand (Zustandsautomat pro Bin in data-Arrays) |
| Weave | wartet auf stabile, gehaltene Klangstellen, speichert sie als Schnappschuss („Thread") und blendet mehrere Threads wellenförmig ineinander | mit Aufwand (Stabilitätserkennung + mehrere Frame-Speicher) |
| DroneMaker | interpoliert jeden Bin zwischen weit auseinanderliegenden Abtastzeitpunkten, optional Peak-Werte; plus Kammfilterbank | einfach bis mit Aufwand |
| Shimmer | zufälliges Amplituden-Jitter pro Bin, Pulswelle, die durchs Spektrum wandert, Delay pro Bin | einfach |
| Pulsing | Bins schalten an/aus, Dauer abhängig von Frequenz und Zeit | einfach (Zähler pro Bin) |
| Filterbank / Gliding Filters | extrem schmale FFT-Bandpässe auf Skalen bzw. gleitende Filter | einfach (Maske aus Tabelle) |
| Bin Shift mit „instantaneous feedback" | Verschiebung wird innerhalb desselben Frames mehrfach zurückgeführt | mit Aufwand (Frame-Schleife) |
| Stretch | Peaks werden nach β·ω + α·ω² verschoben – kontinuierlich harmonisch → inharmonisch | mit Aufwand |
| Emergence / Partial Glide | erkannte Partials bekommen eigene Hüllkurven bzw. gleiten einzeln in der Tonhöhe | schwierig (Partial-Tracking) |
| Granulation | Blöcke aus Bins × Frames werden verzögert und verschoben | mit Aufwand |

Zwei Praxishinweise von Norris betreffen RNBO direkt: Er spart sich das Phase-Unwrapping aus CPU-Gründen und randomisiert stattdessen die Phasen, um Kammfilter-Klingeln bei Amplituden-Interpolation zu vermeiden. Und: Die interessantesten Ergebnisse liegen oft knapp neben der Neutralstellung, nicht im Extrem.

DroneMaker ist inspiriert von **Mammut** (Øyvind Hammer, NOTAM), das statt normaler Fenster eine riesige FFT über die ganze Datei rechnet. Das ist eine eigene Technik – in RNBO wegen der 4096-Grenze nicht möglich, in Max nur offline sinnvoll.

**Ableton Live** (seit Live 11) ergänzt zwei Ideen: Spectral Time kombiniert Freezer und Spectral Delay; die Delay-Zeiten lassen sich übers Spektrum verteilen (Spray, Tilt, Shift, Mask). Spectral Resonator zerlegt den Klang in Partials, streckt, verschiebt und verwischt sie und kann von MIDI-Noten gestimmt werden – so wird Geräusch zu Tonhöhe. In RNBO: Spray/Tilt = Delay-Tabelle pro Bin (mit Aufwand); MIDI-Resonanz = Verstärkung harmonischer Bin-Positionen mit Feedback (mit Aufwand).

*DAFX* und Kyma folgen in eigenen Abschnitten weiter unten.

Quellen: [SoundMagic Spectral Guide](https://michaelnorris.info/software/soundmagic-spectral/guide/), [SoundMagic Spectral Download/Liste](https://www.michaelnorris.info/software/soundmagicspectral), [Ableton: Spectral Time Video-Artikel](https://www.ableton.com/en/blog/freeze-delay-and-deconstruct-sound-design-with-spectral-time/), [Ableton: Spektralklänge in Live 11](https://www.ableton.com/de/blog/spectral-sound-a-look-at-live-11s-new-spectral-devices/).

## Spektrale Spatialisierung

Jeder Bin (oder jedes Band) bekommt eine eigene Position im Raum – der Klang zerfällt räumlich in seine Bestandteile und kann sich wieder sammeln. Für Metamorphosen ist das eine eigene Dimension: Ein Klang kann sich „auflösen", ohne dass sich sein Spektrum ändert.

- **Statische oder animierte Pan-Tabellen:** Torchia & Lippe (NIME 2004) speichern pro Bin einen Panwert in Buffern und multiplizieren in pfft~ jeden Kanal damit; sie gehen von Stereo auf vier und mehr Kanäle, mit kreisförmiger Verteilung und 64–128 Bändern. Sie benennen auch das ästhetische Problem: Bei zu starker Zerstreuung zerfällt der Klang perzeptiv.
- **Spectral Delay + Panning:** Kim-Boyle (DAFx 2004) kombiniert Delay pro Bin mit unterschiedlichen Delays pro Kanal und erzeugt so Raumbilder und spektrale Bahnen; er weist darauf hin, dass die kleinste Verzögerung durch die FFT-Größe festgelegt ist (1024 Punkte ≈ 23 ms).
- **Algorithmische Steuerung:** Tommy Martinez (CCRMA 2019) bewegt Bins per Schwarmalgorithmus (Flocking) und VBAP über Mehrkanal-Systeme.
- **Gesteuert durch Analyse:** Ein Max-Beispiel (Cycling-'74-Artikel „Spatialization in Max") pannt Bins abhängig von einem Rauigkeitsmaß pro Bin – die Position folgt einer Klangeigenschaft.

**RNBO: einfach.** Pro Bin eine Gain-Tabelle je Ausgangskanal lesen und mit dem Bin multiplizieren; RNBO kann mehrere Ausgänge. Der Preis: pro Kanal und pro Overlap-Kette ein eigenes ifft~ – bei 8 Kanälen und 4-fach-Overlap also 32 inverse FFTs. Auf dem Raspberry Pi früh messen.

Quellen: [Torchia & Lippe, NIME 2004](https://nime.org/proc/torchia2004), [Kim-Boyle, „Spectral Delays with Frequency Domain Processing", DAFx 2004](https://dafx.de/paper-archive/2004/P_042.PDF), [CCRMA: IMSYS Spectral Panning via Flocking](https://ccrma.stanford.edu/events/imsys-spectral-panning-flocking-algorithms-in-multichannel-sound-environment), [Cycling '74: Spatialization in Max](https://cycling74.com/articles/spatialization-in-max).

## Morph-Qualität: Zeitausrichtung und Phasenrekonstruktion

Zwei Werkzeuge fehlten im ersten Bericht, obwohl sie über die Qualität fast jedes Morphs entscheiden: die zeitliche Zuordnung der Quellen und eine Phase, die zu frei erzeugten Magnituden passt.

### Zeitausrichtung (Dynamic Time Warping)

Wer zwei Klänge Frame für Frame morpht, mischt sonst schnell den Anschlag des einen mit dem Ausklang des anderen. Ein älteres US-Patent zum automatischen Audio-Morphing beschreibt genau diese Reihenfolge: zuerst Anschlag, harmonische Phase und Ausklang per DTW zeitlich aufeinander legen, dann Merkmale zuordnen, dann interpolieren. Lysaght & Timoney (DAFx 2002) richten zumindest den Spitzenpunkt des Anschlags aufeinander aus; eine McGill-Arbeit („Morphing of Musical Sound Objects") widmet DTW, Hüllkurven-Warping und Partial-Einsatzzeiten eigene Kapitel. DTW lässt sich auch kompositorisch nutzen: Ein Artikel auf Sounding Future verwendet den Ausrichtungspfad selbst, um schrittweise Übergänge zwischen Klangsequenzen zu bauen.

**RNBO: mit Aufwand, als Hybrid.** DTW braucht beide Klänge vollständig und rechnet eine Kostenmatrix – das ist Offline-Arbeit für Max (js, Python, FluCoMa-Deskriptoren). Den Ausrichtungspfad speichert man als Buffer; RNBO liest Quelle B dann an der verzogenen Position. Live machbar ist nur die einfache Variante: Anschläge per Onset-Erkennung synchronisieren.

### Phasenrekonstruktion (PGHI / RTPGHI)

Viele Metamorphose-Techniken erzeugen nur Magnituden – Sorting, Freeze, Magnituden-Morph, Spectral Mutation. Die Phase wird dann übernommen oder zufällig gesetzt, was Phasigkeit oder Verschmieren bringt. Phase Gradient Heap Integration (Průša et al.) schätzt die Phase aus den Magnituden selbst: Sie leitet Phasengradienten in Zeit- und Frequenzrichtung aus Log-Magnitudenunterschieden ab und integriert sie, beginnend beim lautesten Bin. Die Echtzeitvariante RTPGHI nutzt nur vergangene Frames. Průša & Holighaus („Phase Vocoder Done Right") bauen darauf einen Phase-Vocoder, der laut den Autoren auch bei extremer Zeitstreckung die typischen PV-Artefakte vermeidet.

**RNBO: schwierig, aber der lohnendste Qualitätshebel.** RTPGHI braucht pro Frame eine Bearbeitungsreihenfolge nach Magnitude (Heap, ersetzbar durch `list.sort`) und Zugriff auf Nachbar-Bins – also die eigene STFT-Engine in codebox~. Eine kompakte Referenz-Implementierung in Rust (Crate math-dsp, Datei rtpghi.rs) kann als Vorlage für einen Port dienen. Die Methode setzt laut Paper ein Gauß-artiges Fenster voraus; welche Overlap-Redundanz in der Praxis nötig ist, habe ich nicht geprüft.

Quellen: [US-Patent 5749073 (Audio-Morphing mit DTW)](https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/5749073), [Lysaght & Timoney, DAFx 2002](https://mural.maynoothuniversity.ie/id/eprint/4110/1/DAFX02_Lysaght_Timoney_timbre_morphing.pdf), [McGill: Morphing of Musical Sound Objects](https://escholarship.mcgill.ca/downloads/5712m694n), [Sounding Future: Tonale Übergänge mit DTW](https://soundingfuture.com/en/article/creating-tonal-transitions-using-dynamic-time-warping), [Průša & Holighaus, „Phase Vocoder Done Right"](https://arxiv.org/pdf/2202.07382), [rtpghi.rs (math-dsp)](https://docs.rs/math-dsp/latest/src/math_audio_dsp/rtpghi.rs.html).

## Jenseits der STFT: Constant-Q und neuronale Morphs

Beide Ansätze sind für Metamorphosen relevant, laufen aber in Max – in RNBO ist Constant-Q nur als Annäherung möglich, neuronale Modelle gar nicht.

### Constant-Q (CQ-NSGT / sliCQ)

Die STFT verteilt ihre Bins linear: Im Bass ist sie zu grob, in der Höhe zu fein. Eine Constant-Q-Transformation teilt das Spektrum logarithmisch, wie das Gehör. Holighaus, Dörfler, Velasco & Grill zeigen, wie man sie über nichtstationäre Gabor-Frames perfekt invertierbar macht und durch Zerschneiden in Abschnitte („sliCQ") echtzeitfähig. Ein neueres Projekt, CiCueTea, liefert dafür eine Echtzeit-C++-Bibliothek unter MIT-Lizenz. Für Morphs heißt das: Tonhöhenbezogene Operationen (Verschieben um Intervalle, Morphen von Partials im Bass) werden sauberer.

**RNBO: schwierig.** sliCQ braucht FFTs unterschiedlicher Länge pro Band; RNBO bietet nur feste Zweierpotenzen bis 4096 und keine fertige Implementierung. Pragmatischer Ersatz: STFT-Bins zu logarithmischen Bändern (Oktaven, Terzen, ERB) gruppieren und Parameter pro Band steuern – das ist einfach, verbessert aber nur die Steuerung, nicht die Auflösung.

### Neuronale Ansätze (RAVE über nn~)

RAVE (IRCAM/ACIDS) ist ein Autoencoder, der Klang in einen kompakten latenten Raum übersetzt; nn~ lädt die Modelle in Max und Pd. Timbre-Transfer (Mikrofon klingt wie das Trainingsmaterial) und das direkte Steuern der latenten Dimensionen ergeben Metamorphosen, die mit FFT-Techniken nicht erreichbar sind. Isaac Io Schankler zeigt in einem Cycling-'74-Artikel 16 latente Steuerparameter; ein Kommentator berichtet von rund 72 Stunden und etwa 150 € GPU-Miete für ein brauchbares eigenes Modell. RAVE v3 ergänzt Stiltransfer per Adaptive Instance Normalization, steuerbar über nn~-Attribute. Ein neueres Paket, neural~, führt nn~ auf ExecuTorch fort.

**RNBO: nicht möglich.** RNBO kann keine Torch- oder ExecuTorch-Modelle laden. nn~ steht zudem unter CC BY-NC 4.0 – für kommerzielle Plugins relevant.

Quellen: [Holighaus et al., Invertible real-time constant-Q transforms](https://arxiv.org/abs/1210.0084), [CiCueTea (PyPI)](https://pypi.org/project/cicuetea/), [RAVE (GitHub)](https://github.com/acids-ircam/RAVE), [Cycling '74: Timbre Transfer with Machine Learning](https://cycling74.com/ja/articles/timbre-transfer-with-machine-learning-by-isaac-io-schankler), [neural~ (PyPI)](https://pypi.org/project/neural-tilde/).

## DAFX (Zölzer): Lehrbuch-Abgleich

DAFX bestätigt die meisten bisherigen Techniken und ergänzt fünf: Robotisierung, Dispersion, Stabil/Transient-Trennung über die Phase, Frequenz-Warping per Laguerre-Transformation und adaptive Effekte, deren Parameter aus Klangmerkmalen kommen.

Geprüft habe ich die Kapitelgliederung der 2. Auflage (Wiley 2011, Kapitel 7–11 und 14) und die Unterkapitel der 1. Auflage auf dafx.de. Die Unterkapitel der 2. Auflage und die MATLAB-Dateien konnte ich nicht einsehen (Download aus dieser Umgebung gesperrt).

| Kapitel | Techniken | Neu gegenüber Bericht + Ergänzung? | RNBO |
| --- | --- | --- | --- |
| Zeit-Frequenz (Phase-Vocoder-Effekte) | Zeit-Frequenz-Filter, Time-Stretch, Pitch-Shift, Mutation zweier Klänge, Entrauschen | nein | wie im Bericht |
| ebenda | **Robotisierung:** Phase jedes Bins wird pro Frame auf null gesetzt; die Tonhöhe ergibt sich aus dem Frame-Abstand | ja | einfach |
| ebenda | **Whisperization:** zufällige Phasen, meist mit kleinem Fenster – Stimme wird zu Flüstern | teils (Phasenrandomisierung) | einfach |
| ebenda | **Dispersion:** frequenzabhängige Laufzeit innerhalb des Phase-Vocoders | ja | einfach bis mit Aufwand (Mechanismus nicht nachgelesen) |
| ebenda | **Stabil/Transient-Trennung:** Bins mit stabiler Momentanfrequenz gelten als tonal, der Rest als Transient | ja (Alternative zu Median-HPSS) | einfach bis mit Aufwand – braucht nur die Phase des Vorframes pro Bin |
| Quelle-Filter | Kanalvocoder, LPC, Cepstrum; Cross-Synthese, Formantverschiebung, spektrale Interpolation, formanterhaltendes Pitch-Shifting | nein | wie im Bericht |
| Spektralmodelle (Sinus + Residuum) | partialabhängige Frequenzskalierung, Spectral Shape Shift, Geschlechtswechsel, Harmonizer, Heiserkeit, Morphing, Stimmkonversion | teils – Heiserkeit (Residuum anheben) und Geschlechtswechsel (Tonhöhe + Formant gekoppelt) als Rezepte | schwierig (Partial-Tracking); Hybrid |
| Zeit- und Frequenz-Warping (Evangelista) | Frequenzachse per Allpass-Kette (Laguerre) kontinuierlich verbiegen; Inharmonizer, Pitch-Shift inharmonischer Klänge, Morphing | ja – nicht an Bins gebunden, anders als Bin-Remapping | mit Aufwand bis schwierig |
| Adaptive Effekte (Verfaille & Arfib) | Klangmerkmale steuern Effektparameter: selektives Time-Stretching, adaptive Robotisierung und Whisperization | ja | einfach bis mit Aufwand (Merkmale wie Schwerpunkt oder Flux pro Frame aus den Bins) |
| Quellentrennung (2. Aufl.) | Trennung aus Einkanal- und Binauralsignalen | nein (NMF im Bericht) | wie im Bericht |

Zwei Ideen davon sind für Metamorphosen besonders brauchbar. **Frequenz-Warping** nach Evangelista verbiegt die Frequenzachse stufenlos statt in Bin-Schritten; die Kurzzeit-Laguerre-Transformation macht das echtzeitfähig, und der Warping-Parameter darf sich pro Frame oder sogar innerhalb eines Frames ändern. **Adaptive Steuerung** macht aus jeder Technik einen gesteuerten Morph: Statt eines Reglers bestimmt etwa der spektrale Schwerpunkt von Klang B, wie stark Klang A verwandelt wird. Das Verfaille/Arfib-Paper behandelt nur die Selbststeuerung; die Steuerung durch eine zweite Quelle ist meine Ableitung.

Quellen: [DAFX 2. Auflage, Inhaltsverzeichnis](https://download.e-bookshelf.de/download/0000/5827/76/L-X-0000582776-0007906813.XHTML/index.xhtml), [DAFX 1. Aufl., Kapitel Zeit-Frequenz](https://dafx.de/DAFX_Book_Page/chapter8.html), [Kapitel Quelle-Filter](https://dafx.de/DAFX_Book_Page/chapter9.html), [Kapitel Spektralverarbeitung](https://dafx.de/DAFX_Book_Page/chapter10.html), [Kapitel Warping](https://dafx.de/DAFX_Book_Page/chapter11.html), [Bela: Phase Vocoder Teil 3 (Robotisierung)](https://learn.bela.io/tutorials/c-plus-plus-for-real-time-audio-programming/phase-vocoder-part-3/), [Verfaille & Arfib, A-DAFx (DAFx 2001)](https://dafx.de/paper-archive/details/FqRAzWApN4UH8tS7tN1kYA), [Evangelista, Short-Time Laguerre Transform (DAFx 2000)](https://dafx.de/paper-archive/details/OolnYb3v2w7SYL1D27Tm7Q).

## Kyma: Morphen über Analyse-Daten

Kyma bringt kaum neue FFT-Operationen, aber zwei Morph-Ideen, die im Bericht fehlten: Morphs zwischen drei und mehr Quellen und Partials mit eigenem Rauschanteil. Kymas Stärke liegt in der Analyse-Resynthese, nicht im STFT-Effekt.

- **Tau (Time Alignment Utility):** richtet mehrere Aufnahmen zeitlich aufeinander aus und morpht dann zwischen ihren Amplituden-, Frequenz-, Formant- und Bandbreiten-Hüllkurven – laut Symbolic Sound zwischen zwei, drei oder mehr Klängen, ohne zeitliches Verschmieren oder Kammfilter-Effekte. „Galleries" erzeugen aus Quellkombinationen automatisch ganze Bibliotheken von Varianten. Das bestätigt den Hybrid-Weg aus dem Abschnitt Zeitausrichtung.
- **Bandbreiten-erweiterte Partials (Fitz & Haken, Loris):** Jedes Partial trägt neben Amplitude und Frequenz eine Rausch-Hüllkurve. Quellklänge liegen an den Ecken von Würfeln in einem 3D-Klangfarbenraum; die Spielposition ergibt einen gewichteten Mittelwert der umliegenden Ecken. Loris ist Open Source, die Echtzeit-Synthese lief in Kyma und steckt reduziert im Continuum Fingerboard.
- **Aggregate Synthesis:** Dieselben Spektraldaten, die sonst Sinusoszillatoren steuern, treiben auch Grain-Wolken (CloudBank), Bandpässe mit Bandbreite (FilterBank) und Formant-Impulse mit getrenntem Grundton und Formant (FormantBank). Daraus ergeben sich zusätzliche Morph-Achsen: „Unschärfe" über die Bandbreite, „Größe" über den Formant, „Pixelung" über Grain-Dichte.
- **Bereits abgedeckt:** Live-Spektralanalyse und -Resynthese, Spektrum-Editor zum Zeichnen von Harmonischen, Cross-Synthese, Vocoder mit 22–88 Bändern (etwa Mann zu Frau), Group Additive Synthesis als sparsame Additivsynthese.

**RNBO:** Ein Magnituden-Morph zwischen drei oder vier Quellen ist einfach – gewichtete Summe pro Bin, Gewichte aus einem XY-Feld oder baryzentrisch. Der Loris-Ansatz geht als Hybrid: Analyse offline mit Loris, Partial-Tabellen (Frequenz, Amplitude, Rauschanteil) in Buffern, Resynthese in RNBO als Oszillatorbank mit rauschmodulierten Sinus – mit Aufwand. Aggregate-Synthese mit Filterbänken ist möglich, aber CPU-teuer.

Quellen: [Synthtopia: Kyma X.3 und Tau](https://synthtopia.com/content/2006/02/18/symbolic-sound), [Indiana CMtext: Kyma](https://cmtext.indiana.edu/synthesis/chapter4_synth_languages14.php), [Symbolic Sound: Aggregate Synthesis](https://archive.symbolicsound.com/press-aggregateSynthesis.html), [Symbolic Sound: Sound Algorithms (Archiv)](https://archive.symbolicsound.com/cgi-bin/bin/view/Kyma/SoundAlgorithms.html), [Symbolic Sound: Pressemitteilung AES 97](https://archive.symbolicsound.com/press-AES97.html), [Haken Audio: Real-time Sound Morphing](https://www.hakenaudio.com/addsoundmorph).

## Übersicht: neue Techniken nach RNBO-Aufwand

Sortiert vom einfachsten zum schwierigsten RNBO-Port. „Einfach" heißt: pro Bin, höchstens mit Gedächtnis für den Vorframe.

| Technik | Herkunft | RNBO | Kernidee für den Port |
| --- | --- | --- | --- |
| Sieb-Crossfade (leaker~) | FFTease | einfach | feste Zufallszahl pro Bin als Umschaltschwelle |
| Spectral Mutation USIM/ISIM | Polansky & Erbe | einfach | Intervall zum Vorframe pro Bin mischen bzw. ersetzen |
| Spectral Mutation UUIM/IUIM/LCM | Polansky & Erbe | einfach bis mit Aufwand | Vorzeichen und Betrag trennen; Band Persist als Merker pro Bin |
| Morph zwischen 3+ Quellen | Kyma (Tau, Loris) | einfach | gewichtete Summe pro Bin, Gewichte aus XY-Feld |
| Robotisierung | DAFX | einfach | Phase pro Frame auf null |
| Whisperization | DAFX | einfach | Zufallsphasen, kleines Fenster |
| Spektrale Akkumulation (pileup~, Freezing) | FFTease, SoundMagic | einfach | Peak-Hold mit Decay pro Bin |
| Shimmer / Pulsing | SoundMagic | einfach | Zufall bzw. Zähler pro Bin |
| Spektrale Spatialisierung | Torchia & Lippe, Kim-Boyle | einfach (CPU skaliert mit Kanälen) | Gain-Tabelle pro Bin und Kanal |
| Log-Band-Steuerung | Ersatz für Constant-Q | einfach | Bins zu Oktav-/ERB-Bändern gruppieren |
| Stabil/Transient-Trennung über die Phase | DAFX | einfach bis mit Aufwand | Momentanfrequenz pro Bin aus Vorframe-Phase, Stabilität als Maske |
| Adaptive Steuerung (Klang B steuert Effekt auf A) | DAFX (Verfaille & Arfib) | einfach bis mit Aufwand | Schwerpunkt/Flux pro Frame berechnen, auf Parameter abbilden |
| Dispersion | DAFX | einfach bis mit Aufwand | frequenzabhängige Laufzeit pro Bin |
| Gate and Hold | SoundMagic | mit Aufwand | Hüllkurven-Zustandsautomat pro Bin |
| Weave | SoundMagic | mit Aufwand | Stabilitätserkennung + mehrere Frame-Schnappschüsse |
| Bandgeschwindigkeiten (resent~, loopsea~) | FFTease | mit Aufwand | Spektral-Ringpuffer, Lesekopf pro Bin-Block |
| Zelluläre Automaten (cavoc~) | FFTease | mit Aufwand | Regel pro Bin aus Nachbarn des Vorframes |
| Spectral Resonator mit MIDI | Ableton | mit Aufwand | harmonische Bin-Positionen verstärken + Feedback |
| DTW-Zeitausrichtung | Morphing-Literatur, Kyma Tau | mit Aufwand (Hybrid) | Pfad offline in Max, RNBO liest verzogen |
| Bandbreiten-erweiterte Partials | Fitz & Haken (Loris) | mit Aufwand (Hybrid) | Analyse offline, rauschmodulierte Oszillatorbank in RNBO |
| Aggregate Synthesis | Kyma | mit Aufwand (CPU) | Spektraldaten steuern Bandpass- und Formant-Bänke |
| Frequenz-Warping (Laguerre) | DAFX (Evangelista) | mit Aufwand bis schwierig | Allpass-Kette pro Frame, Warping-Parameter animierbar |
| RTPGHI-Phasenrekonstruktion | Průša et al. | schwierig | eigene STFT-Engine, Bins nach Magnitude abarbeiten |
| Textur-Mapping (reanimator~) | FFTease | schwierig | Frame-Suche in Datenbank pro Frame |
| Partial-Hüllkurven (Emergence, Partial Glide), SMS-Effekte | SoundMagic, DAFX | schwierig | braucht Partial-Tracking |
| Echtes Constant-Q (sliCQ) | Holighaus et al. | schwierig | FFTs variabler Länge pro Band |
| Ganzdatei-FFT (Mammut) | NOTAM | nicht möglich | über 4096-Grenze; nur offline in Max |
| Neuronaler Morph (RAVE) | IRCAM/ACIDS | nicht möglich | nur Max/Pd über nn~ |

Für ein RNBO-Toolkit wären die besten nächsten Schritte Spectral Mutation und der Sieb-Crossfade: Beide sind echte A→B-Morphs, passen in die bestehende Ketten-Architektur und brauchen keine Frame-Pufferung.
