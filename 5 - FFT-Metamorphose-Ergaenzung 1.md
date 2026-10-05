# Ergänzung: Fehlende FFT-Metamorphose-Techniken und ihre Machbarkeit in der Live-Engine

**Überarbeitete Fassung für die gewählte Umsetzung:** Live-Spektralengine in RNBO (Web-Export), hauptsächlich auf dem Handy, bis zu 7 Minuten vordefiniertes Material, gestreamt. Die Klassen A–F, X und Z sind in *FFT-Techniken-Metamorphosen-Machbarkeit.md* erklärt; die Engine selbst in *Live-Spektralengine-RNBO-Handy.md*.

Stand: 5. Oktober 2026

Der erste Bericht hat rund 30 Techniken übersehen. Die wichtigsten sind Spectral Mutation (Polansky & Erbe) und der Sieb-Crossfade aus FFTease – beides echte Morphs, die in der Live-Engine sofort umsetzbar sind. Dazu kommen zeitliche Hüllkurven pro Bin (SoundMagic), spektrale Spatialisierung, Robotisierung, Stabil/Transient-Trennung über die Phase, adaptive Steuerung und Morphs zwischen mehreren Quellen. Zeitausrichtung per DTW, Frequenz-Warping nach Evangelista, Constant-Q und neuronale Morphs sind Grenzfälle.

**Was sich in dieser Fassung geändert hat:** Die RNBO-Bewertungen gingen bisher von unabhängigen Ketten oder einer eigenen STFT-Engine aus. Jetzt gelten die Klassen der Live-Engine: Ring der Frames im Abstand H, Zwei-Pass (Frame g einlesen, g−1 ausgeben), gleichmäßige Last. Spectral Mutation, Sieb-Crossfade, Robotisierung und die Phasenstabilität werden damit noch einfacher. Teurer werden alles, was mehrere Quellen oder viele Ausgangskanäle braucht (mehr FFT-Ketten am Handy). Alles, was Zeitkontrolle oder Zugriff auf künftige Frames voraussetzt, rückt auf „später“.

**Methode:** Abgleich gegen sechs etablierte Sammlungen – FFTease (38 Objekte), SoundHack, SoundMagic Spectral (23 Plugins), Ableton Live 11, das Lehrbuch *DAFX* (Zölzer) und Kyma – plus gezielte Suche nach den im Chat genannten Lücken. Bei *DAFX* kenne ich die Unterkapitel nur aus der 1. Auflage. Vollständig ist das bei einem so offenen Feld nie. Die Bewertungen sind Einschätzungen, keine Tests.

## FFTease: der größte fehlende Baukasten

FFTease (Eric Lyon, Christopher Penrose, seit 1999) umfasst laut aktuellem README 38 Spektral-Objekte für Max und Pd. Der Quellcode steht unter MIT-artiger Lizenz und darf portiert werden, solange der Copyright-Hinweis erhalten bleibt. Die Externals laufen in RNBO nicht, aber die Algorithmen lassen sich in die Frame-Engine übertragen. Default ist FFT 1024 mit Overlap 8; die Live-Engine arbeitet mit Overlap 4.

| Objekt | Was es tut | Metamorphose-Nutzen | Klasse | Live-Engine |
| --- | --- | --- | --- | --- |
| leaker~ | Sieb-Crossfade: Bins wechseln in zufälliger Reihenfolge von A nach B | Morph, der „durchsickert“ statt überblendet | A | sofort (2. Quelle) |
| morphine~ | als Morph-Objekt beschrieben | direkter A→B-Morph | vermutlich A | Algorithmus im C-Code prüfen |
| schmear~ | spektrales Verschmieren | Ereignis → Fläche | B | sofort |
| disarray~ / disarrain~ | Umverteilung der Spektralenergie; disarrain~ interpoliert | Klang → glitzernde Textur | B | sofort |
| reanimator~ | Textur-Mapper: ein Klang treibt gespeicherte Frames eines anderen | Streichquartett „spricht“ durch Stimme | Z | später, schwierig (Frame-Suche in einer Datenbank) |
| pileup~ | spektrale Akkumulation | Klang baut sich zur Wolke auf | E | sofort |
| loopsea~ | spektral geschichtetes, unabhängiges Looping | Bänder laufen auseinander | E | sofort bis mit Aufwand (Loops nur aus der Ring-Vergangenheit) |
| resent~ / residency~ | Spektral-Sampler, resent~ mit Geschwindigkeit pro Bin-Block | Teile des Spektrums bewegen sich verschieden schnell | E / Z | langsamer: aus dem Ring; schneller als Original: später |
| ether~ / vacancy~ | spektrales Compositing zweier Quellen | eine Quelle füllt Lücken der anderen | A | sofort (2. Quelle) |
| swinger~ | Phasentausch zwischen zwei Quellen | Cross-Synthese-Variante | A | sofort (2. Quelle) |
| mindwarp~ | Formant-Warping | Formantverschiebung ohne Tonhöhe | B | mit Aufwand (Hüllkurve per Glättung, dann verschoben anwenden) |
| pvwarp~ / pvwarpb~ | nichtlinearer Frequenz-Warper, b-Version mit Warp-Tabelle | harmonisch → inharmonisch | B, F | mit Aufwand |
| pvtuner~ | Spektrum auf beliebige Skala quantisieren | Geräusch → gestimmter Klang | B, F | mit Aufwand (Frequenz pro Bin aus dem Ring) |
| cavoc~ / cavoc27~ | zelluläre Automaten erzeugen Spektren | selbst-evolvierende Spektren | B, E | sofort (Regel pro Bin aus Nachbarn des Vorframes) |
| burrow~ | gegenseitig referenzierte Filterung | eine Quelle filtert die andere | A | sofort (2. Quelle) |
| xsyn~ / taint~ / cross~ | Cross-Synthese-Varianten | Hybride | A | sofort (2. Quelle) |
| dentist~ | Partials gezielt entfernen | Skelettierung | A | sofort |

„2. Quelle“ heißt: ein zweiter Satz aus vier `fft~` für das zweite Audio-Element. Die beiden Streams laufen nicht samplegenau synchron; für spektrale Morphs ist das unkritisch.

Eine CCRMA-Studienarbeit von Jennifer Hsu vergleicht verwandte Bin-Ersetzungs-Morphs: zufällige Ersetzung, Ersetzung nach Magnitude und Ersetzung von hohen zu tiefen Bins. Zufällig und von hoch nach tief sind Klasse A; nach Magnitude braucht den Rang aus dem Histogramm (Klasse D, +2 Frames).

Quellen: [FFTease README und Lizenz](https://github.com/ericlyon/FFTease3.0-MaxMSP), [FFTease-Paket bei Cycling '74](https://cycling74.com/packages/fftease), [FFTease-Klangbeispiele](https://disis.music.vt.edu/eric/LyonSoftware/MaxMSP/FFTease/Sound_Examples/index.html), [Jennifer Hsu, „It's Morphin' Time“](https://ccrma.stanford.edu/~jhsu/421b).

## Spectral Mutation (Polansky & Erbe, SoundHack)

Spectral Mutation ist die wichtigste fehlende Morph-Familie und passt besonders gut zur Live-Engine, weil jede Funktion pro Bin arbeitet und nur den Vorframe braucht – genau das, was der Ring liefert. Polansky und Erbe übertrugen 1996 Polanskys „Mutation Functions“ aus der Melodik auf FFT-Frames (Computer Music Journal 20(1)).

Das Prinzip: Statt Amplituden zu mischen, werden die **Intervalle** gemischt – die Änderung einer Bin-Amplitude vom vorigen zum aktuellen Frame, getrennt in Richtung und Betrag. Ω (0 = Quelle, 1 = Ziel) steuert den Grad; bei „uniformen“ Mutationen ist Ω ein Interpolationswert, bei „irregulären“ die Wahrscheinlichkeit, dass ein Bin ersetzt wird.

| Funktion | Was übertragen wird | Erreicht bei Ω = 1 das Ziel? |
| --- | --- | --- |
| USIM (uniform signed) | Intervalle interpoliert – spektraler Crossfade | ja |
| ISIM (irregular signed) | zufällig gewählte Bins übernehmen das Ziel-Intervall | ja |
| UUIM (uniform unsigned) | Betrag vom Ziel, Richtung von der Quelle | nein – „Abbild“ des Ziels |
| IUIM (irregular unsigned) | wie UUIM, stochastisch pro Bin | nein |
| LCM (linear contour) | Richtung vom Ziel, Betrag von der Quelle | nein – laut Autoren oft unkenntlich, aber klanglich interessant |

Zusatzparameter: LCM lässt sich mit IUIM oder UUIM verketten. „Absolute Interval“ misst gegen eine feste Amplitude statt gegen den Vorframe und zentriert die Mutation; relative Intervalle driften und kommen teils nie am Ziel an. „Delta Emphasis“ (−1 bis 1) glättet oder betont Frame-Änderungen, „Band Persist“ hält einmal mutierte Bins stabil.

**Live-Engine: Klassen A + E, sofort.** Die Amplituden des Vorframes von Quelle und Ziel liegen im Ring; die Ausgabe-Amplitude des Vorframes (für die relativen Varianten) ist ein Zustand pro Bin. Die irregulären Varianten brauchen pro Bin einen Zufallswert und für Band Persist einen Merker pro Bin. Die Formeln betreffen nur Amplituden; als Phase eignet sich die der Quelle oder eine aus der Frequenz fortgeschriebene (Klasse F). Eine fertige Max- oder RNBO-Umsetzung habe ich nicht gefunden.

Quellen: [Polansky & Erbe, „Spectral Mutation in Soundhack“](https://eamusic.dartmouth.edu/~larry/SHPaper/soundhack.article.html), [Erbe, „SoundHack: A Brief Overview“](https://www.academia.edu/833007/SoundHack_A_Brief_Overview).

## Weitere Kataloge: SoundMagic Spectral und Ableton

SoundMagic Spectral (Michael Norris, 23 freie AU-Plugins, v1.5) liefert vor allem zeitliche Hüllkurven pro Bin. Norris nennt Wisharts *Audible Design* und CDP als Vorbild.

| Technik (SoundMagic) | Was sie tut | Klasse | Live-Engine |
| --- | --- | --- | --- |
| Gate and Hold | Bin über der Schwelle wird eingefroren und bekommt eine eigene Hüllkurve (Fade-in, Hold, Fade-out), optional frequenzabhängig verzögert, gepulst, verschoben | A, E | mit Aufwand (Zustandsautomat pro Bin) |
| Weave | wartet auf stabile Klangstellen, speichert Schnappschüsse („Threads“) und blendet mehrere wellenförmig ineinander | C, E | mit Aufwand (Stabilität aus der Frame-Statistik, Schnappschüsse beim Einlesen kopieren) |
| DroneMaker | interpoliert jeden Bin zwischen weit auseinanderliegenden Zeitpunkten, optional Peak-Werte; Kammfilterbank | E | sofort bis mit Aufwand |
| Shimmer | Amplituden-Jitter pro Bin, wandernde Pulswelle, Delay pro Bin | A, E | sofort |
| Pulsing | Bins schalten an/aus, Dauer abhängig von Frequenz und Zeit | A | sofort (Zähler pro Bin) |
| Filterbank / Gliding Filters | sehr schmale FFT-Bandpässe auf Skalen bzw. gleitende Filter | A | sofort |
| Bin Shift mit „instantaneous feedback“ | Verschiebung wird im selben Frame mehrfach zurückgeführt | B | sofort (mehrere versetzte Lesezugriffe auf Frame g−1) |
| Stretch | Peaks nach β·ω + α·ω² verschoben – harmonisch → inharmonisch | B, F | mit Aufwand |
| Emergence / Partial Glide | erkannte Partials bekommen eigene Hüllkurven bzw. gleiten einzeln | B, E | schwierig (braucht Tracking über Frames) |
| Granulation | Blöcke aus Bins × Frames verzögert und verschoben | E | sofort bis mit Aufwand (nur Vergangenheit) |

Zwei Praxishinweise von Norris betreffen die Engine direkt: Er verzichtet aus CPU-Gründen auf Phase-Unwrapping und randomisiert stattdessen die Phasen, um Kammfilter-Klingeln bei Amplituden-Interpolation zu vermeiden. In der Live-Engine ist die Frequenz pro Bin dagegen ohnehin verfügbar; Phasenrandomisierung bleibt als klangliche Option. Außerdem: Die interessantesten Ergebnisse liegen oft knapp neben der Neutralstellung.

DroneMaker ist inspiriert von **Mammut** (Øyvind Hammer, NOTAM), das eine riesige FFT über die ganze Datei rechnet. Das ist in RNBO wegen der 4096-Grenze nicht möglich und in Max nur offline sinnvoll.

**Ableton Live** (seit Live 11) ergänzt zwei Ideen. Spectral Time kombiniert Freezer und Spectral Delay; die Delay-Zeiten lassen sich übers Spektrum verteilen (Spray, Tilt, Shift, Mask) – in der Engine Klasse E mit einer Delay-Tabelle pro Bin, sofort. Spectral Resonator zerlegt den Klang in Partials, streckt, verschiebt und verwischt sie und lässt sich per MIDI stimmen – Verstärkung harmonischer Bin-Positionen mit Feedback über den Ring, mit Aufwand.

Quellen: [SoundMagic Spectral Guide](https://michaelnorris.info/software/soundmagic-spectral/guide/), [SoundMagic Spectral Download/Liste](https://www.michaelnorris.info/software/soundmagicspectral), [Ableton: Spectral Time](https://www.ableton.com/en/blog/freeze-delay-and-deconstruct-sound-design-with-spectral-time/), [Ableton: Spektralklänge in Live 11](https://www.ableton.com/de/blog/spectral-sound-a-look-at-live-11s-new-spectral-devices/).

## Spektrale Spatialisierung

Jeder Bin oder jedes Band bekommt eine eigene Position im Raum – der Klang zerfällt räumlich in seine Bestandteile und kann sich wieder sammeln, ohne dass sich sein Spektrum ändert.

- **Statische oder animierte Pan-Tabellen:** Torchia & Lippe (NIME 2004) speichern pro Bin einen Panwert und multiplizieren in pfft~ jeden Kanal damit; sie gehen bis zu vier und mehr Kanälen mit 64–128 Bändern und benennen das ästhetische Problem: Bei zu starker Zerstreuung zerfällt der Klang perzeptiv.
- **Spectral Delay + Panning:** Kim-Boyle (DAFx 2004) kombiniert Delay pro Bin mit unterschiedlichen Delays pro Kanal; die kleinste Verzögerung ist durch die FFT-Größe festgelegt.
- **Algorithmische Steuerung:** Tommy Martinez (CCRMA 2019) bewegt Bins per Schwarmalgorithmus und VBAP über Mehrkanal-Systeme.
- **Gesteuert durch Analyse:** Ein Max-Beispiel pannt Bins abhängig von einem Rauigkeitsmaß pro Bin.

**Live-Engine: Klasse A, sofort – aber auf dem Handy nur in Stereo sinnvoll.** Jeder Ausgangskanal braucht pro Kette ein eigenes `ifft~`; Stereo heißt 8 statt 4 `ifft~`. Mehrkanal-Setups spielen am Handy keine Rolle. Für Kopfhörer wäre eine binaurale Variante denkbar (Laufzeit- und Pegeldifferenz pro Bin), das habe ich nicht weiter geprüft.

Quellen: [Torchia & Lippe, NIME 2004](https://nime.org/proc/torchia2004), [Kim-Boyle, DAFx 2004](https://dafx.de/paper-archive/2004/P_042.PDF), [CCRMA: IMSYS Spectral Panning via Flocking](https://ccrma.stanford.edu/events/imsys-spectral-panning-flocking-algorithms-in-multichannel-sound-environment), [Cycling '74: Spatialization in Max](https://cycling74.com/articles/spatialization-in-max).

## Morph-Qualität: Zeitausrichtung und Phasenrekonstruktion

### Zeitausrichtung (Dynamic Time Warping)

Wer zwei Klänge Frame für Frame morpht, mischt sonst schnell den Anschlag des einen mit dem Ausklang des anderen. Ein US-Patent zum Audio-Morphing beschreibt die Reihenfolge: erst Anschlag, harmonische Phase und Ausklang per DTW aufeinanderlegen, dann Merkmale zuordnen, dann interpolieren. Lysaght & Timoney (DAFx 2002) richten den Spitzenpunkt des Anschlags aus; eine McGill-Arbeit („Morphing of Musical Sound Objects“) widmet DTW, Hüllkurven-Warping und Partial-Einsatzzeiten eigene Kapitel. Ein Artikel auf Sounding Future nutzt den Ausrichtungspfad selbst kompositorisch.

**Live-Engine: Klasse Z, später.** Beim Streaming laufen beide Klänge im Originaltempo; eine Ausrichtung verlangt, dass eine Quelle schneller oder langsamer gelesen wird. Das geht erst mit Zeitkontrolle. Den Pfad würde man dann offline in Max berechnen und als kleine Tabelle mitliefern. Bis dahin: Klänge im Schnitt aufeinander abstimmen und Anschläge per Onset-Erkennung nur grob synchron starten.

### Phasenrekonstruktion (PGHI / RTPGHI)

Viele Metamorphose-Techniken erzeugen nur Magnituden – Sorting, Magnituden-Morph, Spectral Mutation. Phase Gradient Heap Integration (Průša et al.) schätzt die Phase aus den Magnituden selbst: Phasengradienten in Zeit- und Frequenzrichtung aus Log-Magnitudenunterschieden, integriert beginnend beim lautesten Bin. Die Echtzeitvariante RTPGHI nutzt nur vergangene Frames. Průša & Holighaus („Phase Vocoder Done Right“) bauen darauf einen Phase-Vocoder, der laut den Autoren auch bei extremer Zeitstreckung die typischen PV-Artefakte vermeidet.

**Live-Engine: mit Aufwand, aber weniger dringend als gedacht.** In der Live-Engine liegen Originalphase und Frequenz pro Bin vor; für die meisten Effekte reicht es, die Phase mit dieser Frequenz fortzuschreiben (Klasse F). RTPGHI lohnt sich für stark umgebaute Spektren (Sorting, LCM-Mutation). Die nötige Reihenfolge nach Magnitude liefert der Histogramm-Rang, der ohnehin fürs Sorting entsteht: Die Integration läuft dann Bin für Bin in Rangreihenfolge über einen Frame, ohne Heap und ohne Spitze, mit +1 Frame Verzögerung. Die Methode setzt laut Paper ein Gauß-artiges Fenster voraus; ob Hann bei Overlap 4 genügt, habe ich nicht geprüft. Eine Referenz-Implementierung in Rust (Crate math-dsp, rtpghi.rs) kann als Vorlage dienen.

Quellen: [US-Patent 5749073](https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/5749073), [Lysaght & Timoney, DAFx 2002](https://mural.maynoothuniversity.ie/id/eprint/4110/1/DAFX02_Lysaght_Timoney_timbre_morphing.pdf), [McGill: Morphing of Musical Sound Objects](https://escholarship.mcgill.ca/downloads/5712m694n), [Sounding Future: Übergänge mit DTW](https://soundingfuture.com/en/article/creating-tonal-transitions-using-dynamic-time-warping), [Průša & Holighaus, „Phase Vocoder Done Right“](https://arxiv.org/pdf/2202.07382), [rtpghi.rs (math-dsp)](https://docs.rs/math-dsp/latest/src/math_audio_dsp/rtpghi.rs.html).

## Jenseits der STFT: Constant-Q und neuronale Morphs

### Constant-Q (CQ-NSGT / sliCQ)

Die STFT verteilt ihre Bins linear: im Bass zu grob, in der Höhe zu fein. Eine Constant-Q-Transformation teilt das Spektrum logarithmisch. Holighaus, Dörfler, Velasco & Grill zeigen, wie man sie über nichtstationäre Gabor-Frames perfekt invertierbar und durch Zerschneiden („sliCQ“) echtzeitfähig macht; CiCueTea liefert dafür eine C++-Bibliothek unter MIT-Lizenz.

**Live-Engine: schwierig.** sliCQ braucht FFTs unterschiedlicher Länge pro Band; RNBO bietet nur feste Größen bis 4096. Pragmatischer Ersatz, sofort: Bins zu logarithmischen Bändern (Oktaven, Terzen, ERB) gruppieren und Parameter pro Band steuern – verbessert die Steuerung, nicht die Auflösung.

### Neuronale Ansätze (RAVE über nn~)

RAVE (IRCAM/ACIDS) übersetzt Klang in einen kompakten latenten Raum; nn~ lädt die Modelle in Max und Pd. Timbre-Transfer und das Steuern der latenten Dimensionen ergeben Metamorphosen, die mit FFT-Techniken nicht erreichbar sind. Isaac Io Schankler zeigt in einem Cycling-'74-Artikel 16 latente Parameter; ein Kommentator berichtet von rund 72 Stunden und etwa 150 € GPU-Miete für ein eigenes Modell. neural~ führt nn~ auf ExecuTorch fort.

**Live-Engine: nicht möglich.** RNBO lädt keine Torch- oder ExecuTorch-Modelle, und am Handy wären solche Modelle ohnehin eine eigene Frage. nn~ steht unter CC BY-NC 4.0.

Quellen: [Holighaus et al.](https://arxiv.org/abs/1210.0084), [CiCueTea](https://pypi.org/project/cicuetea/), [RAVE](https://github.com/acids-ircam/RAVE), [Cycling '74: Timbre Transfer with Machine Learning](https://cycling74.com/ja/articles/timbre-transfer-with-machine-learning-by-isaac-io-schankler), [neural~](https://pypi.org/project/neural-tilde/).

## DAFX (Zölzer): Lehrbuch-Abgleich

DAFX bestätigt die meisten bisherigen Techniken und ergänzt fünf: Robotisierung, Dispersion, Stabil/Transient-Trennung über die Phase, Frequenz-Warping per Laguerre-Transformation und adaptive Effekte. Geprüft habe ich die Kapitelgliederung der 2. Auflage (Wiley 2011) und die Unterkapitel der 1. Auflage; die MATLAB-Dateien konnte ich nicht einsehen.

| Kapitel | Techniken | Neu? | Klasse | Live-Engine |
| --- | --- | --- | --- | --- |
| Zeit-Frequenz | Zeit-Frequenz-Filter, Mutation zweier Klänge, Entrauschen | nein | A | sofort |
| ebenda | Time-Stretch, Pitch-Shift | nein | Z / B, F | später / mit Aufwand |
| ebenda | **Robotisierung:** Phase jedes Bins pro Frame auf null; die Tonhöhe ergibt sich aus dem Frame-Abstand | ja | A | sofort |
| ebenda | **Whisperization:** Zufallsphasen, meist mit kleinem Fenster | teils | A | sofort (mit N = 512 oder 1024 als eigener Satz Ketten) |
| ebenda | **Dispersion:** frequenzabhängige Laufzeit | ja | E | sofort bis mit Aufwand (Mechanismus nicht nachgelesen) |
| ebenda | **Stabil/Transient-Trennung:** stabile Momentanfrequenz = tonal, der Rest = Transient | ja | F | sofort – günstige Alternative zu Median-HPSS am Handy |
| Quelle-Filter | Kanalvocoder, LPC, Cepstrum; Cross-Synthese, Formantverschiebung, formanterhaltendes Pitch-Shifting | nein | A, B, X | wie im Hauptbericht |
| Spektralmodelle (Sinus + Residuum) | Spectral Shape Shift, Geschlechtswechsel, Harmonizer, Heiserkeit, Morphing | teils | B, E | mit Aufwand bis schwierig (vereinfachtes Tracking) |
| Frequenz-Warping (Evangelista) | Frequenzachse per Allpass-Kette (Laguerre) stufenlos verbiegen; Inharmonizer, Morphing | ja | – | schwierig am Handy (zusätzliche Verarbeitung neben der Engine) |
| Adaptive Effekte (Verfaille & Arfib) | Klangmerkmale steuern Effektparameter | ja | C | sofort |
| Quellentrennung | Einkanal- und Binauraltrennung | nein | – | nicht live |

Zwei Ideen davon sind für Metamorphosen besonders brauchbar. **Adaptive Steuerung** passt perfekt zur Engine: Schwerpunkt, Flux oder Lautheit entstehen als Frame-Statistik ohnehin (Klasse C) und können jeden Parameter steuern – etwa bestimmt die Helligkeit von Klang B, wie stark Klang A verwandelt wird. Das Verfaille/Arfib-Paper behandelt nur die Selbststeuerung; die Steuerung durch eine zweite Quelle ist meine Ableitung. **Frequenz-Warping** nach Evangelista verbiegt die Frequenzachse stufenlos, aber außerhalb der Bin-Logik; als Ersatz in der Engine dient Bin-Remapping mit Phasenkorrektur (Klassen B + F).

Quellen: [DAFX 2. Auflage, Inhaltsverzeichnis](https://download.e-bookshelf.de/download/0000/5827/76/L-X-0000582776-0007906813.XHTML/index.xhtml), [DAFX 1. Aufl.: Zeit-Frequenz](https://dafx.de/DAFX_Book_Page/chapter8.html), [Quelle-Filter](https://dafx.de/DAFX_Book_Page/chapter9.html), [Spektralverarbeitung](https://dafx.de/DAFX_Book_Page/chapter10.html), [Warping](https://dafx.de/DAFX_Book_Page/chapter11.html), [Bela: Phase Vocoder Teil 3](https://learn.bela.io/tutorials/c-plus-plus-for-real-time-audio-programming/phase-vocoder-part-3/), [Verfaille & Arfib, A-DAFx](https://dafx.de/paper-archive/details/FqRAzWApN4UH8tS7tN1kYA), [Evangelista, Short-Time Laguerre Transform](https://dafx.de/paper-archive/details/OolnYb3v2w7SYL1D27Tm7Q).

## Kyma: Morphen über Analyse-Daten

Kyma bringt kaum neue FFT-Operationen, aber zwei Morph-Ideen: Morphs zwischen drei und mehr Quellen und Partials mit eigenem Rauschanteil.

- **Tau (Time Alignment Utility):** richtet mehrere Aufnahmen zeitlich aus und morpht zwischen ihren Amplituden-, Frequenz-, Formant- und Bandbreiten-Hüllkurven – laut Symbolic Sound zwischen zwei, drei oder mehr Klängen. „Galleries“ erzeugen automatisch Bibliotheken von Varianten.
- **Bandbreiten-erweiterte Partials (Fitz & Haken, Loris):** Jedes Partial trägt eine Rausch-Hüllkurve; Quellklänge liegen an den Ecken von Würfeln in einem 3D-Klangfarbenraum, die Spielposition ergibt einen gewichteten Mittelwert. Loris ist Open Source.
- **Aggregate Synthesis:** Dieselben Spektraldaten treiben Grain-Wolken, Bandpässe mit Bandbreite und Formant-Impulse – zusätzliche Morph-Achsen „Unschärfe“, „Größe“, „Pixelung“.
- **Bereits abgedeckt:** Live-Analyse und -Resynthese, Spektrum-Editor, Cross-Synthese, Vocoder, Group Additive Synthesis.

**Live-Engine:**
- **Morph zwischen drei oder vier Quellen – Klasse A, teuer am Handy.** Die Rechnung ist einfach (gewichtete Summe pro Bin, Gewichte aus einem XY-Feld), aber jede Quelle braucht vier eigene `fft~`. Drei Quellen sind 12 `fft~` plus 4 `ifft~`; zuerst mit N = 1024 messen.
- **Zeitausrichtung wie in Tau – später** (siehe DTW).
- **Loris-Partials – nur für kurze Szenen** (Tabellen offline, Oszillatorbank in RNBO).
- **Aggregate Synthesis – am Handy nicht empfehlenswert** (Filter- und Grain-Bänke zusätzlich zur Engine).

Quellen: [Synthtopia: Kyma X.3 und Tau](https://synthtopia.com/content/2006/02/18/symbolic-sound), [Indiana CMtext: Kyma](https://cmtext.indiana.edu/synthesis/chapter4_synth_languages14.php), [Symbolic Sound: Aggregate Synthesis](https://archive.symbolicsound.com/press-aggregateSynthesis.html), [Symbolic Sound: Sound Algorithms](https://archive.symbolicsound.com/cgi-bin/bin/view/Kyma/SoundAlgorithms.html), [Symbolic Sound: AES 97](https://archive.symbolicsound.com/press-AES97.html), [Haken Audio: Real-time Sound Morphing](https://www.hakenaudio.com/addsoundmorph).

## Übersicht: neue Techniken in der Live-Engine

Sortiert von „sofort“ zu „nicht möglich“.

| Technik | Herkunft | Klasse | Verzögerung | Live-Engine | Kernidee |
| --- | --- | --- | --- | --- | --- |
| Robotisierung | DAFX | A | – | sofort | Phase pro Frame auf null |
| Whisperization | DAFX | A | – | sofort | Zufallsphasen, kleines Fenster |
| Shimmer / Pulsing / Glisten | SoundMagic, CDP | A | – | sofort | Zufall bzw. Zähler pro Bin |
| Log-Band-Steuerung | Ersatz für Constant-Q | A | – | sofort | Bins zu Oktav-/ERB-Bändern gruppieren |
| Spektrale Akkumulation (pileup~, Freezing) | FFTease, SoundMagic | E | – | sofort | Peak-Hold mit Decay pro Bin |
| Spectral Mutation (alle fünf) | Polansky & Erbe | A, E | – | sofort | Intervall zum Vorframe aus dem Ring |
| Stabil/Transient über die Phase | DAFX | F | – | sofort | Stabilität der Frequenz als Maske |
| Adaptive Steuerung | DAFX | C | 1 Frame | sofort | Frame-Statistik steuert Parameter |
| Verschmieren, Umverteilen (schmear~, disarray~) | FFTease | B | 1 Frame | sofort | Nachbarn bzw. Remapping aus Frame g−1 |
| Zelluläre Automaten (cavoc~) | FFTease | B, E | 1 Frame | sofort | Regel pro Bin aus Nachbarn des Vorframes |
| Bin Shift mit Rückführung | SoundMagic | B | 1 Frame | sofort | mehrere versetzte Lesezugriffe |
| Spray/Tilt-Delay pro Bin | Ableton | E | – | sofort | Delay-Tabelle pro Bin im Ring |
| Sieb-Crossfade, Compositing, Phasentausch | FFTease | A | – | sofort (2. Quelle) | Zufallsschwelle bzw. Auswahl pro Bin |
| Stereo-Spatialisierung | Torchia & Lippe, Kim-Boyle | A | – | sofort (8 `ifft~`) | Gain-Tabelle pro Bin und Kanal |
| Dispersion | DAFX | E | – | sofort bis mit Aufwand | frequenzabhängige Laufzeit |
| Gate and Hold | SoundMagic | A, E | – | mit Aufwand | Zustandsautomat pro Bin |
| Weave | SoundMagic | C, E | 1 Frame | mit Aufwand | Stabilität erkennen, Schnappschüsse kopieren |
| Formant-Warping (mindwarp~) | FFTease | B | 1 Frame | mit Aufwand | Hüllkurve glätten, verschoben anwenden |
| Frequenz-Warper, Skalen-Quantisierung | FFTease, SoundMagic | B, F | 1 Frame | mit Aufwand | Remapping mit Phasenkorrektur |
| Spectral Resonator mit MIDI | Ableton | A, E | – | mit Aufwand | harmonische Bins verstärken + Feedback |
| RTPGHI-Phasenrekonstruktion | Průša et al. | D, F | 1 Frame | mit Aufwand | Integration in Histogramm-Rangfolge |
| Morph zwischen 3+ Quellen | Kyma | A | – | teuer am Handy | gewichtete Summe, aber 4 `fft~` pro Quelle |
| Bandgeschwindigkeiten (resent~) | FFTease | E / Z | – | langsamer sofort, schneller später | Lesekopf pro Bin-Block im Ring |
| Partial-Hüllkurven (Emergence, Partial Glide), SMS-Effekte | SoundMagic, DAFX | B, E | 1 Frame | schwierig | vereinfachtes Tracking über Frames |
| Frequenz-Warping (Laguerre) | DAFX (Evangelista) | – | – | schwierig am Handy | Allpass-Kette neben der Engine |
| Echtes Constant-Q (sliCQ) | Holighaus et al. | – | – | schwierig | FFTs variabler Länge pro Band |
| DTW-Zeitausrichtung, Tau-Ausrichtung | Literatur, Kyma | Z | – | später | Pfad offline, Lesen mit Zeitkontrolle |
| Textur-Mapping (reanimator~) | FFTease | Z | – | später, schwierig | Frame-Suche in einer Datenbank |
| Loris-Partials, Aggregate Synthesis | Kyma | – | – | nur kurze Szenen bzw. nicht empfehlenswert | Tabellen offline, Bänke zu teuer |
| Ganzdatei-FFT (Mammut) | NOTAM | – | – | nicht möglich | über 4096-Grenze |
| Neuronaler Morph (RAVE) | IRCAM/ACIDS | – | – | nicht möglich | nur Max/Pd über nn~ |

Für die nächsten Schritte bieten sich Spectral Mutation und der Sieb-Crossfade an: Beide sind echte A→B-Morphs und brauchen nur den Ring und eine zweite Quelle. Robotisierung, die Stabil/Transient-Trennung über die Phase und die adaptive Steuerung kosten fast nichts und erweitern die Palette sofort.
