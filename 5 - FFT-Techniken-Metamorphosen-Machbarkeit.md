# FFT-Techniken für Klang-Metamorphosen – Machbarkeit in Max/MSP und RNBO

**Überarbeitete Fassung für die gewählte Umsetzung:** Live-Spektralengine in RNBO (Web-Export), hauptsächlich auf dem Handy, bis zu 7 Minuten vordefiniertes Material, gestreamt. Details zur Engine stehen in *Live-Spektralengine-RNBO-Handy.md*.

Stand: 5. Oktober 2026

## Was sich gegenüber der ersten Fassung geändert hat

Die erste Fassung hat RNBO so bewertet, als liefe jede `fft~`-Kette für sich: Vorframe N Samples zurück, eigener Zustand pro Kette, Frame-Operationen nur über eine eigene STFT-Engine in codebox~ mit `fftbuffer`. Diese eigene Engine ist für das Projekt verworfen: Bei ihr fällt eine ganze FFT plus Frame-Schleife in ein einziges Sample, und das erzeugt auf dem Handy Lastspitzen.

Grundlage ist jetzt die **Live-Spektralengine**: vier versetzte `fft~`/`ifft~`-Ketten und **eine gemeinsame codebox~**. Sie hält einen Ring der letzten Frames im Abstand H = N/4, liest in jedem Sample einen Bin von Frame g ein und gibt einen Bin von Frame g−1 aus. Damit gilt:

- **Nachbar-Bins, Frame-Statistik, Vorframes und phasenkohärente Verarbeitung gehen live**, mit gleichmäßiger Last pro Sample. Der Preis sind 1–2 Frames Verzögerung (bei N = 2048 etwa 43 ms pro Frame).
- **Viele Bewertungen steigen:** Instantanfrequenz-Morph, Hüllkurve per Glättung, Warping, Top-N, Freeze mit Phasenfortschreibung, Pitch-Shift mit Peak-Verschiebung, Phase-Locking.
- **Neu begrenzend sind das Handy und das Streaming:** CPU und Speicher sind knapp; der Ring enthält nur die Vergangenheit, nicht die Zukunft; Zeitkontrolle (Zeitstreckung, Scrubbing, Rückwärts) kommt erst später und braucht dann 8 statt 4 `fft~`; Vorab-Analysen kommen nur noch für kleine Hilfsdaten in Frage.

## Kurzfassung

- **Max/MSP bleibt die Werkstatt, RNBO ist das Ziel.** In Max stehen pfft~ (bis 1.048.576 Punkte, beliebige Overlaps), framedelta~/frameaccum~, gen~ in pfft~, Jitter, FrameLib, FluCoMa und SuperVP zur Verfügung. RNBO bietet nur streamende `fft~`/`ifft~` (64–4096 Punkte, Abstand mindestens N, keine Externals, kein Jitter). Die Live-Engine macht daraus pfft~-artige Frame-Verarbeitung.
- **Sofort in der Live-Engine:** alles pro Bin (Morph, Cross-Synthese, Gate, Masken, Arithmetik, Phasenrandomisierung), Nachbar-Bins (Glättung, Hüllkurve, Warping, Shuffle), Frame-Statistik (Top-N, Normalisieren), Blur, Freeze mit sauberer Phase, Spectral Delay.
- **Mit Aufwand:** Sortieren über Histogramm-Rang (+2 Frames), Pitch-Shift mit Peak-Verschiebung, Phase-Locking, vereinfachter Optimal-Transport-Morph, Median-HPSS (am Handy teuer), Cepstrum (zusätzliche FFTs).
- **Erst mit Zeitkontrolle (später):** Zeitstreckung, Scrubbing, Rückwärts, Morph zwischen Klängen mit unterschiedlichem Timing, Zugriff auf künftige Frames.
- **Nicht in RNBO:** NMF-Hybride, neuronale Modelle, vollständiges Partial-Tracking mit additiver Resynthese über das ganze Material.

## Bewertungsschema

Jede Technik wird einer Klasse der Live-Engine zugeordnet. Die Klasse bestimmt Verzögerung und Last.

| Klasse | Bedeutung | Verzögerung | Last pro Sample |
| --- | --- | --- | --- |
| A | pro Bin, ohne Nachbarn | keine | konstant |
| B | Nachbar-Bins des fertigen Frames g−1 | 1 Frame | wächst mit Fensterbreite |
| C | Frame-Statistik (Maximum, Summe, Schwelle, Schwerpunkt) | 1 Frame | konstant |
| D | Rang und Sortieren (Histogramm) | 2 Frames | konstant |
| E | mehrere Frames aus dem Ring | keine | wächst mit Ringlänge |
| F | phasenkohärent (Frequenz pro Bin aus zwei Ring-Frames) | keine | konstant |
| X | braucht zusätzliche FFTs pro Kette | je nach Aufbau | hoch |
| Z | braucht Zeitkontrolle (Buffer + 8 `fft~`) | – | hoch, später |

Bewertung der Machbarkeit: **sofort** (Klassen A–C, E, F ohne Sonderaufwand) · **mit Aufwand** (mehr Logik oder +2 Frames) · **teuer am Handy** (geht, CPU messen) · **später** (Klasse Z) · **nicht in RNBO**.

## Key Findings (Fakten zu RNBO)

1. **RNBO hat kein pfft~.** Cycling '74 schreibt in „Using the FFT“: „While RNBO does not currently provide pfft~, it's possible to emulate pfft~ in RNBO“. Die Emulation besteht aus parallelen `fft~`/`ifft~` mit Phasenversatz (z. B. 0 / 512 / 1024 / 1536 bei N = 2048). Das Fenster wird direkt in `fft~`/`ifft~` gesetzt (Default rectangular, außerdem Hann, Hamming, Blackman oder ein eigener Fenster-Buffer).
2. **Der Abstand zwischen zwei FFTs ist an die Größe gekoppelt.** Laut Referenz muss das zweite Argument (Abstand) „at least the number of points“ und eine Zweierpotenz sein. Overlap entsteht nur über mehrere Ketten.
3. **Maximale FFT-Größe: 4096.** Die Größe ist ein festes Attribut und lässt sich zur Laufzeit nicht ändern. Jede Fenstergröße braucht eigene Ketten.
4. **`ifft~` hat einen Sync-Ausgang** (0 bis N−1), `fft~` einen Bin-Index-Ausgang. Seit RNBO 1.4.0 sind alle FFT-Objekte am globalen Sample-Zähler ausgerichtet. Das ist die Grundlage dafür, dass die vier Ketten und die gemeinsame codebox~ im Gleichtakt laufen.
5. **codebox~ ist der Schlüssel.** Sie hat Schleifen, peek/poke auf `data`/`buffer~` und kann alle Ketten in einem Objekt bedienen. `fftbuffer` (In-place-FFT) existiert, wird in der Live-Engine aber nicht gebraucht.
6. **Die Praxis ist holprig.** Forum-Threads berichten von „lofi“ klingendem Freeze, „gritty“ 4-fach-Overlap und Phase-Vocoder-Ports mit Artefakten. Gemeinsame Ursache bei den PV-Ports: Jede Kette rechnete ihren Phasenvorschub über N Samples statt über H. Der gemeinsame Ring der Live-Engine setzt genau dort an.
7. **Belastbare CPU-Zahlen für FFT-Patches auf dem Handy gibt es nicht.** Das Web-Gerät läuft als WebAssembly in einem AudioWorklet mit 128er-Blöcken; gemessen werden muss auf echten Geräten.

## Grundlagen: pfft~ in Max gegenüber der Live-Engine in RNBO

**Max/MSP (pfft~):** pfft~ lädt einen Subpatcher und übernimmt Fensterung, Overlap und Overlap-Add. fftin~ liefert Real-, Imaginärteil und Bin-Index, fftout~ resynthetisiert. Die Latenz ist „window size minus the hop size“ – bei 1024/Overlap 4 also 768 Samples. Helfer: cartopol~/poltocar~, framedelta~, frameaccum~, phasewrap~, vectral~, fftinfo~. In gen~ innerhalb von pfft~ verzögert `delay vectorsize` jeden Bin um genau einen Frame. Jitter-Matrizen (Jean-François Charles, „A Tutorial on Spectral Sound Processing Using Max/MSP and Jitter“, Computer Music Journal 32(3), 2008) speichern Spektren als Bild für graphische Transformationen, Interpolation und Scrubbing.

**RNBO (Live-Engine):** `fft~` streamt pro Sample einen Bin. Die gemeinsame codebox~ empfängt von allen vier Ketten Real, Imaginär und Bin-Index und gibt jeder Kette Real und Imaginär zurück. Sie schreibt Frame g in den Ring und liest gleichzeitig Frame g−1, der vollständig vorliegt. Weil Kette c+1 dasselbe Signal H Samples später analysiert als Kette c, liegen die Frames im Ring im Abstand H hintereinander – wie in einem pfft~ mit Overlap 4. Daraus folgen:

- **Vorframe** = der vorige Frame im Ring (Ersatz für framedelta~).
- **Phase fortschreiben** = ein gemeinsamer Phasenspeicher für alle Ketten (Ersatz für frameaccum~).
- **Nachbar-Bins und Statistik** = Zugriff auf den fertigen Frame g−1, Statistik wird beim Einlesen nebenbei gesammelt.
- **Obere Spektrumhälfte** = konjugiert gespiegelt aus der unteren.
- **Ausgabe** = Summe der vier `ifft~` durch 1,5 (Hann × Hann bei 4-fachem Overlap).

**Was RNBO weiterhin nicht kann:** Jitter, Third-Party-Externals (kein FluCoMa, FrameLib, SuperVP, MuBu, zsa.descriptors, CNMAT, sigmund~), gizmo~, pfft~. Für Tonhöhe gibt es fzero~ und retune~. Faust kann codebox-Code erzeugen (`faust -lang codebox`); das Drittprojekt faust-rs bewirbt Frame-Rate-FFT-Bibliotheken mit codebox-Backend, ist aber experimentell.

## 1. Spektrales Morphing / Interpolation zwischen zwei Quellen

**Prinzip.** Beide Quellen werden mit identischen FFT-Parametern analysiert. Pro Bin werden Magnituden interpoliert, besser in dB als linear. Für die Phase gibt es drei Wege: (a) Phase der dominanten Quelle übernehmen, (b) per Schwellwert umschalten, (c) die *Instantanfrequenz* interpolieren und daraus eine neue Phase akkumulieren – der „echte“ Phase-Vocoder-Morph. Eine Verfeinerung trennt **Hüllkurve** (Formant, Klangfarbe) von **Feinstruktur** (Partials, Tonhöhe) und morpht beide getrennt. Optimal-Transport-Morphing (FluCoMa AudioTransport) verschiebt spektrale „Masse“ von Peak zu Peak, statt überzublenden – zwischen 220 Hz und 880 Hz entsteht eine Art Glissando statt zweier gleichzeitiger Töne; laut FluCoMa ist das Ergebnis „quantised to the resolution of the spectral bins“.

**Klangliches Ergebnis.** Lineare Magnituden-Interpolation klingt bei unähnlichen Quellen oft wie ein Crossfade mit „Phasing“; erst Hüllkurven-/Feinstruktur-Trennung oder Peak-basiertes Morphing liefert das Gefühl, dass *ein* Objekt seine Form ändert. Caetano & Rodet (IEEE TASLP 21(8), 2013) berichten: „We found that interpolation of line spectral frequencies gives the most linear spectral envelope morphs … interpolation of cepstral coefficients results in the most linear temporal envelope morph.“ Trevor Wishart betont, dass bei Transformationen der Weg wichtiger ist als die Endpunkte und ähnliche Quellen sich leichter morphen lassen.

**Max/MSP.** pfft~ mit zwei fftin~ → cartopol~ → Magnituden-Mix in gen~ → Phase von A/B oder über framedelta~/frameaccum~ → poltocar~ → fftout~. Für Morphs zwischen eingefrorenen Frames: Charles' Patch „6-interpolate-2frames“. Fertig: fluid.audiotransport~, fluid.bufaudiotransport, fluid.nmfmorph~; CDP MORPH/NEWMORPH als Offline-Referenz.

**RNBO-Live-Engine.**
- **Magnituden-Morph mit Phase von A oder B – Klasse A, sofort.** Die zweite Quelle braucht einen zweiten Satz von vier `fft~`; die vier `ifft~` bleiben. Am Handy etwa 1,5-fache FFT-Last – messen. Zwei gestreamte Audio-Elemente laufen nicht samplegenau synchron; für einen spektralen Morph ist das unkritisch, weil jede Quelle für sich analysiert wird.
- **Instantanfrequenz-Morph – Klasse F, sofort.** Die Frequenz beider Quellen kommt aus je zwei Ring-Frames im Abstand H; interpolieren, der gemeinsame Phasenspeicher schreibt fort. In der ersten Fassung war das „mit Aufwand“ – der Ring löst genau das Problem, an dem die Forum-Ports scheiterten.
- **Optimal Transport – Klassen B/C, mit Aufwand.** Eine vereinfachte 1D-Variante passt gut in die Engine: Die kumulierte Verteilung entsteht beim Einlesen nebenbei, weil die Bins in Reihenfolge ankommen. Beim Ausgeben laufen zwei Zeiger monoton durch beide Verteilungen – konstante Last, +1 Frame. AudioTransport ist ausgefeilter (Peak-Segmente); ob die Vereinfachung klanglich reicht, ist zu testen.

## 2. Cross-Synthese, spektrale Faltung, Vocoder, Hüllkurven-Übertragung

**Prinzip.** Klassische Cross-Synthese: Amplitudenspektrum von A × Phasenspektrum von B oder komplexe Multiplikation der Spektren (A spielt durch den Resonanzkörper von B). Vocoder-artig: Nur die **spektrale Hüllkurve** von A wird auf B übertragen; B wird vorher durch seine eigene Hüllkurve geteilt (Whitening). Hüllkurven-Schätzung über (a) Glättung über Nachbar-Bins, (b) Cepstrum, (c) True Envelope (iteratives Cepstrum, SuperVP), (d) LPC im Zeitbereich.

**Klangliches Ergebnis.** Hybride: „sprechende“ Synthesizer, Glocke mit Vokalfarbe, Regen mit den Formanten einer Stimme. Besonders wirkungsvoll, wenn der Hüllkurven-Anteil von 0 bis 1 eingeblendet wird (CDP COMBINE CROSS macht „a gradual transition from the amplitude of the first spectral envelope to that of the second“).

**Max/MSP.** Beispiel-Patch cross-dog.maxpat, gen~ in pfft~; Bin-Glättung mit Jitter oder FrameLib. Hochwertig: SuperVP for Max (supervp.cross~, supervp.sourcefilter~, supervp.trans~ mit Hüllkurven-Warping). FluCoMa: fluid.bufnmfcross~ (offline).

**RNBO-Live-Engine.**
- **Amp(A) × Phase(B), komplexe Multiplikation – Klasse A, sofort.**
- **Hüllkurve per symmetrischer Glättung, Whitening – Klasse B, sofort (+1 Frame).** Beim Ausgeben von Bin j sind alle Nachbarn von Frame g−1 im Ring; eine Glättung über ±w Bins kostet 2w+1 Lesezugriffe pro Sample, für w bis etwa 8 harmlos. Das ist der empfohlene Weg am Handy.
- **Cepstrum – Klasse X, teuer am Handy.** Der Log-Magnitudenframe von g−1 strömt ohnehin über N Samples aus der Engine; er lässt sich in eine zusätzliche `fft~` im gleichen Takt geben, die das Cepstrum einen Frame später liefert. Liftern und eine weitere `fft~` zurück ergeben die Hüllkurve: +2 Frames, 2 zusätzliche FFTs pro Kette (8 insgesamt). Erst Glättung probieren.
- **True Envelope – nicht praktikabel live** (iterativ).
- **LPC – mit Aufwand.** Levinson-Durbin im Zeitbereich in codebox~, unabhängig von den FFT-Ketten; Ordnung um 20 sollte am Handy tragbar sein, messen.

## 3. Spectral Sorting, Bin-Reordering, Shuffling, Swapping, Warping, Frequency Remapping

**Prinzip.** Die Bins eines Frames werden umgeordnet: nach Magnitude sortiert, zufällig permutiert, paarweise vertauscht, oder eine Warping-Funktion bestimmt, welcher Eingangs-Bin auf welchen Ausgangs-Bin fällt (Stretching, Kompression, Inversion, Faltung). Frequency Remapping mit Phasenkorrektur erhält tonale Qualität; ohne Korrektur entstehen metallische, „zerbrochene“ Klänge. CDP-Verwandte: Specnu Slice 5/Specfold 2 (Inversion), Specfold 3 (Randomisieren), Fold (Oktavfaltung), Invert (Hüllkurve kopfstehend).

**Klangliches Ergebnis.** Sorting zerstört die harmonische Struktur zugunsten eines Energieprofils – glitzernde Klangflächen mit der Hüllkurve des Originals. Ein Morph-Parameter zwischen Original-Index und Ziel-Index ergibt eine kontrollierbare Verwandlung „von Instrument zu Textur“. Langsam animierte Warping-Kurven führen von harmonisch zu inharmonisch.

**Max/MSP.** Frame in buffer~ schreiben und im nächsten Frame umgemappt lesen; Jitter-Remapping (Sortieren in Jitter ist mühsam); FrameLib (Alex Harker) mit sort, percentiles, min/max – die eleganteste Lösung für echtes Per-Frame-Sorting.

**RNBO-Live-Engine.**
- **Warping, Shuffle, Swap, Inversion, Faltung – Klasse B, sofort (+1 Frame).** Beim Ausgeben von Bin j wird Bin `map[j]` aus Frame g−1 gelesen. Die Tabelle liegt in einem `data` und wird per Parameter neu berechnet.
- **Frequency Remapping mit Phasenkorrektur – Klassen B + F, mit Aufwand.** Neue Frequenz = alte Frequenz × Faktor; der gemeinsame Phasenspeicher schreibt mit der neuen Frequenz fort.
- **Sorting – Klasse D, mit Aufwand (+2 Frames).** Statt einer Sortierschleife ein Rang per Histogramm: beim Einlesen jeden Bin einer von 128 dB-Klassen zuordnen, am Frame-Ende die Startpositionen der Klassen berechnen (Schleife über 128 Werte), im nächsten Frame pro Sample einen Bin an seinen Rang verteilen, einen Frame später ausgeben. Konstante Last, keine Spitze; innerhalb einer Klasse (unter 1 dB) bleibt die Reihenfolge erhalten. Für den Morph sortiert ↔ unsortiert zwischen Index j und Rangposition interpolieren.

## 4. Smearing, Blur, Freeze, Spectral Delay, spektrale Diffusion

**Prinzip.**
- **Blur/Smearing:** Pro Bin wird die Magnitude über die Zeit gemittelt (CDP BLUR BLUR „averages spectral amplitudes over time“).
- **Freeze:** Ein Frame wird gehalten; die Phasen werden mit der Instantanfrequenz fortgeschrieben, plus etwas Phasenrauschen, damit der Freeze lebt (Cycling '74 PV-Tutorial II: „a very small amount of phase deviation from bin to bin actually breaks the mechanical sound of the freeze“). Charles' Patches gehen weiter: stochastischer Freeze, entrauschter Freeze, „harmonic freeze“ zum Schichten von Akkorden.
- **Spectral Delay:** Jeder Bin bekommt eine eigene Verzögerung in Frames und ggf. Feedback (Kim-Boyle; jg.spectdelay~; IRCAM Chromax).
- **Diffusion:** Freeze/Blur mit langen Zeitkonstanten, Phasenrandomisierung und frequenzabhängigem Feedback ergeben halligen Nachklang.

**Klangliches Ergebnis.** Blur verwandelt Artikulation in Fläche – Sprache wird zu Chor, Perkussion zu Wolke. Freeze ist der klassische Moment, der zur Klangfläche wird. Spectral Delay zerlegt Klänge in kaskadierende Spektralschichten.

**Max/MSP.** gen~ in pfft~ mit `delay vectorsize`; Spectral-Delay-Beispiele in den gen~-Examples und „Max SpectralDelay.amxd“; vectral~; Charles' Freeze-Patches; FrameLib „stochastic phase vocoder“.

**RNBO-Live-Engine.**
- **Blur – Klasse E, sofort.** Eine geglättete Magnitude pro Bin als Zustand, `y = a·y + (1−a)·x` bei jedem Frame.
- **Freeze – Klasse F, sofort, auch beim Streaming.** Beim Einlesen die Magnituden eines Frames in einen Halte-Puffer kopieren (Bin für Bin, ohne Spitze), dann die Phase mit der gehaltenen Frequenz fortschreiben, optional mit Phasenrauschen. Die „lofi“-Berichte im Forum betreffen einfache 1-Ketten-Versionen; 4-fach-Overlap und die richtige Frequenz statt Zufallsphase sind die entscheidenden Qualitätshebel.
- **Stochastischer Freeze (Mittel oder Zufall aus n Frames) – Klasse E, sofort.**
- **Spectral Delay mit Feedback – Klasse E, sofort bis mit Aufwand.** Der Ring dient als Delay-Speicher, Verzögerungen in Vielfachen von H (bei N = 2048 und 48 kHz etwa 11 ms). 1 Sekunde Delay sind etwa 94 Frames, rund 0,8 MB – auf dem Handy unkritisch. Feedback: die Ausgabe zurück in den Ring schreiben.
- **Diffusion – Kombination aus E und A, sofort.**

## 5. Spektrale Operationen: Gating, Tracing, Masking, Arithmetik, Kompression, Tilt

**Prinzip.** Gating (Bins unter einer Schwelle auf null), Denoising mit Rauschprofil (CDP Clean), Tracing (nur die N lautesten Bins, CDP Trace; Gegenteil Suppress), Masking (ein Spektrum steuert, welche Bins des anderen durchkommen), Arithmetik zweier Spektren (Summe, Differenz, Max, Min, Mittel; CDP COMBINE), spektrale Kompression/Expansion (Exponent < 1 bzw. > 1; CDP Exaggerate), Tilt.

**Klangliches Ergebnis.** Top-N mit langsam fallendem N „skelettiert“ einen Orchesterklang zu wenigen Sinuslinien. Max/Min zwischen zwei Quellen erzeugt Hybride, in denen pro Frequenz die dominante Quelle gewinnt. Masking stanzt eine Quelle in der Form der anderen aus.

**Max/MSP.** Alles in gen~ in pfft~; Rauschprofil in buffer~; Forbidden Planet (Settel/Lippe) als Vorbild; Top-N mit FrameLib.

**RNBO-Live-Engine.**
- **Gate, Masken, Arithmetik, Kompression, Tilt – Klasse A, sofort.** Cycling '74 zeigt selbst ein Noise-Reduction-Gate und eine Forbidden-Planet-Portierung als RNBO-Beispiele.
- **Rauschprofil – Klasse A, sofort.** Live aus einer leisen Stelle mitteln oder als kleine Tabelle (1025 Werte) mitliefern.
- **Top-N – Klasse C, sofort (+1 Frame).** Histogramm des Frames beim Einlesen, am Frame-Ende die Schwelle, über der genau N Bins liegen; angewendet auf **denselben**, inzwischen fertigen Frame (in der ersten Fassung: Schwelle aus dem Vorframe).
- **Gate relativ zum Frame-Maximum, Normalisieren – Klasse C, sofort.**

## 6. Phase-Vocoder-Techniken

**Prinzip.**
- **Time-Stretching:** Frames werden mit anderer Rate gelesen als geschrieben; die Phase wird aus der Instantanfrequenz neu akkumuliert.
- **Pitch-Shifting:** resampeln oder Peaks verschieben (Laroche & Dolson: Peak-Shifting).
- **Phasenrandomisierung:** Phasen durch Zufall ersetzen – diffus, verwaschen; teilweise als Morph-Parameter von „klar“ zu „Wolke“.
- **Phase-Locking** (Laroche & Dolson, IEEE Trans. Speech and Audio Processing 7(3), 1999): Bins um einen Peak übernehmen die Phasenbeziehung des Peaks – weniger Phasiness.
- **Transient/Tonal-Trennung (HPSS):** FitzGerald (DAFx-10): Median über die Zeit betont Tonales, Median über die Frequenz betont Transienten; „The two resulting median filtered spectrograms are then used to generate masks.“ Für Metamorphosen: Anschlag und Klang getrennt morphen (die Idee steckt auch im „Transient Bypass“ von Zynaptiq MORPH 3).
- **Spektrales Stretching/Shifting der Partials:** Frequenzen verschieben oder strecken – harmonisch → inharmonisch (Wishart: zentral für *Vox 5*; CDP Stretch, Shift, Waver).

**Klangliches Ergebnis.** Extreme Zeitstreckung ist selbst eine Metamorphose. Inharmonisches Stretching verwandelt Stimme oder Saite in Glocke oder Metall.

**Max/MSP.** PV-Tutorials Teil I/II, phase-vocoder-sampler.maxpat, gizmo~, Charles' Time-Stretch-Patches, SuperVP (mit Transienten- und Hüllkurvenerhaltung), fluid.hpss~, fluid.sines~.

**RNBO-Live-Engine.**
- **Phasenrandomisierung – Klasse A, sofort.**
- **Time-Stretching, Scrubbing, Rückwärts – Klasse Z, später.** Braucht die Szene als buffer~ und eine Leseposition; jede Kette liest ihr Fenster an der gewünschten Stelle und braucht eine zweite Analyse H Samples später für die Frequenz – 8 `fft~` statt 4. Der gemeinsame Phasenspeicher bleibt gleich.
- **Pitch-Shift mit Peak-Verschiebung – Klassen B + F, mit Aufwand.** Peaks beim Einlesen markieren (ein Bin Verzögerung genügt), Regionen am Frame-Ende festlegen, beim Ausgeben jede Region verschieben und die Phase mit der neuen Frequenz fortschreiben. Am Handy messen. Einfachere Alternative: ein Zeitbereichs-Shifter vor der Engine.
- **Phase-Locking – Klassen B + F, mit Aufwand.** Die Peak-Liste von Frame g−1 liegt am Frame-Ende vor; beim Ausgeben bekommt jeder Bin die Phase seines Peaks plus die ursprüngliche Phasendifferenz.
- **HPSS per Median – Klassen E + B, teuer am Handy.** Median über die Zeit (7 Frames, Sortiernetz mit 16 Vergleichen pro Sample) ist günstig; der Median über ±8 Nachbar-Bins kostet deutlich mehr. Günstige Ersatzlösungen, beide sofort: Stabilität der Instantanfrequenz (DAFX, Klasse F) oder spektraler Flux zum Vorframe (Klasse E).
- **Partial-Stretch/Shift mit Phasenkorrektur – Klassen B + F, mit Aufwand.**

## 7. Sinusoidal-/Partial-Tracking, additive Resynthese, Sinus + Rauschen

**Prinzip.** Peaks pro Frame finden (mit quadratischer Interpolation), über Frames zu Partials verbinden (McAulay-Quatieri), Residuum als gefiltertes Rauschen (Serra: SMS). Morphing: Partials von A und B zuordnen, Frequenzen und Amplituden interpolieren, Rausch-Hüllkurven getrennt morphen (Caetano & Rodet; Kyma und Alchemy als Referenz).

**Klangliches Ergebnis.** Die überzeugendsten Morphs zwischen *tonalen* Klängen, weil Tonhöhe, Formant und Rauschanteil getrennt kontrolliert werden. Bei geräuschhaften Quellen versagt das Modell.

**Max/MSP.** sigmund~, fluid.sines~, IRCAM pm2, SPEAR (offline) → Resynthese per oscbank~/ioscbank~ oder MC-Oszillatoren; CNMAT-Tools als ältere Referenz.

**RNBO-Live-Engine.**
- **Peak-Erkennung pro Frame – Klasse B, sofort.**
- **Vereinfachtes Tracking – mit Aufwand.** Jeden Peak von Frame g−1 dem nächsten Peak von Frame g−2 innerhalb von ±k Bins zuordnen; damit lassen sich Partial-Regionen in der STFT selbst bearbeiten (verschieben, skalieren, morphen). Eine additive Resynthese ist dafür nicht nötig.
- **Vollständiges Tracking mit Geburt und Tod plus additive Resynthese – nicht praktikabel live.** RNBO hat kaum Datenstrukturen dafür (Forum: „fairly basic list support, no other data structures“).
- **Vorab analysierte Partial-Tabellen (SPEAR, FluCoMa) – nur für einzelne kurze Szenen.** 64 Partials bei Hop 512 sind etwa 48 KB pro Sekunde, 7 Minuten wären rund 20 MB. Die Oszillatorbank (32–64 Partials) am Handy messen.

## 8. Weitere transformationsrelevante Techniken

- **Spektrale Granulation – Klasse E, sofort bis mit Aufwand.** „Körner“ sind Gruppen alter Frames aus dem Ring. Die Ringlänge bestimmt, wie weit zurück gegriffen werden kann (2 Sekunden ≈ 1,5 MB). Nur Vergangenheit; Körner aus späteren Stellen erst mit Zeitkontrolle.
- **Spektrale „Drunk Walks“, Shuffle, Weave über Frames (CDP BLUR DRUNK, SHUFFLE, WEAVE) – Klasse E, mit derselben Grenze.**
- **Accumulate/Sustain (CDP Accumulate) – Klasse E, sofort.** Peak-Hold mit Abklingen pro Bin.
- **Glisten/Scatter (CDP) – Klasse A, sofort.** Zufällige Maske pro Frame.
- **NMF-Hybride (fluid.bufnmf~, fluid.bufnmfcross~, fluid.nmfmorph~) – nicht in RNBO.**
- **CDP und Wishart als Ideenkatalog:** CDP gliedert Spektralprozesse in Reshape, Filter, Pitch/Frequency, Morph, Formants, Combine, Time und Utilities. MORPH, NEWMORPH, GLIDE und SPECROSS PARTIALS sind direkte Metamorphose-Vorlagen. Laut Archer Endrich wollte Wishart mit der CDP-Spektralsuite den Morph „Stimmen → Bienen“ aus *Red Bird* (1973–77) nachbilden, für den wenige Sekunden im Tonbandstudio zwei Wochen gedauert hatten. Eine WASM-Portierung (cdp-wasm) existiert für Node und Browser – nicht für RNBO, aber als Offline-Referenz nützlich.
- **Kommerzielle Referenzpunkte:** Zynaptiq MORPH 3 (laut Pressemitteilung vom 25. April 2024 neun Algorithmen, Pro-Version elf, dazu ein Style-Transfer-Modul und „transient bypass“); IRCAM AudioSculpt/SuperVP als Qualitätsreferenz für Hüllkurvenerhaltung und Transienten; SPEAR für Partial-Editing.

## Vergleichstabelle

| Technik | Metamorphose-Potenzial | Beste Umsetzung in Max | Klasse | Verzögerung | Live-Engine |
| --- | --- | --- | --- | --- | --- |
| Magnituden-Interpolation A↔B | mittel (bei ähnlichen Quellen hoch) | pfft~ + gen~ | A | – | sofort (2. Quelle: +4 `fft~`) |
| Instantanfrequenz-Morph | hoch | pfft~ + framedelta~/frameaccum~ | F | – | sofort |
| Optimal-Transport-Morph (1D vereinfacht) | sehr hoch | fluid.audiotransport~ | B, C | 1 Frame | mit Aufwand |
| Cross-Synthese Amp×Phase / Faltung | hoch | cross-dog, gen~ in pfft~ | A | – | sofort |
| Hüllkurven-Transfer per Glättung | sehr hoch | gen~/Jitter/FrameLib, supervp.cross~ | B | 1 Frame | sofort |
| Cepstrum | sehr hoch | SuperVP | X | 2 Frames | teuer am Handy |
| True Envelope | sehr hoch | SuperVP | – | – | nicht praktikabel |
| LPC-Hüllkurve | hoch | eigene gen~ | Zeitbereich | – | mit Aufwand |
| Bin-Warping/Shuffle/Swap | hoch | buffer~-Remapping, Jitter | B | 1 Frame | sofort |
| Remapping mit Phasenkorrektur | hoch | pfft~/SuperVP/CDP | B, F | 1 Frame | mit Aufwand |
| Spectral Sorting | hoch | FrameLib | D | 2 Frames | mit Aufwand |
| Blur/Smearing | hoch | gen~ `delay vectorsize` | E | – | sofort |
| Freeze (+ Phasenrauschen) | sehr hoch | Charles-Patches, PV-Tutorial II | F | – | sofort |
| Spectral Delay + Feedback | hoch | gen~-Examples, jg.spectdelay~ | E | – | sofort bis mit Aufwand |
| Gate/Maske/Arithmetik/Tilt/Kompression | mittel bis hoch | gen~ in pfft~ | A | – | sofort |
| Top-N-Tracing | hoch | FrameLib | C | 1 Frame | sofort |
| Phasenrandomisierung | mittel | pfft~ | A | – | sofort |
| Time-Stretch / Scrubbing / Rückwärts | hoch | PV-Tutorials, SuperVP | Z | – | später |
| Pitch-Shift mit Peak-Verschiebung | hoch | gizmo~, SuperVP | B, F | 1 Frame | mit Aufwand |
| Phase-Locking | Qualität | eigene gen~/SuperVP | B, F | 1 Frame | mit Aufwand |
| HPSS per Median | hoch (getrennt morphen) | fluid.hpss~ | E, B | 1 Frame | teuer am Handy |
| Transient/Tonal über Phasenstabilität oder Flux | hoch | gen~ in pfft~ | F / E | – | sofort |
| Partial-Stretch/Shift | hoch | pfft~/SuperVP/CDP | B, F | 1 Frame | mit Aufwand |
| Peak-Erkennung, vereinfachtes Tracking | hoch | sigmund~, fluid.sines~ | B, E | 1 Frame | mit Aufwand |
| Volles Partial-Tracking + additive Resynthese | sehr hoch | pm2, SPEAR, oscbank~ | – | – | nicht praktikabel live |
| Spektral-Granulation / Drunk Walk | hoch | Jitter, FrameLib | E | – | sofort bis mit Aufwand (nur Vergangenheit) |
| NMF-Hybride | sehr hoch | FluCoMa | – | – | nicht in RNBO |

## Empfehlungen: das Metamorphose-Toolkit auf der Live-Engine aufbauen

1. **Architektur steht fest:** vier `fft~`/`ifft~`-Ketten, eine gemeinsame codebox~ mit Ring, Zwei-Pass-Prinzip, gemeinsamer Phasenspeicher. Keine eigene STFT-Engine mit `fftbuffer`.
2. **Parameter:** N = 2048 mit 4-fachem Overlap und Hann; Rückfallebene N = 1024. Mono verarbeiten, Stereo nur, wenn klanglich nötig. Summe der Ketten durch 1,5. AudioContext mit `latencyHint: "playback"`. Material per Audio-Element streamen.
3. **Aufbau in Stufen, jede mit eigenem Test:**
   1. Ketten + Ring + Nulltest (Ausgabe = Original).
   2. Klasse A: Gate, Tilt, Phasenrandomisierung, Cross-Synthese.
   3. Klassen B und C: Glättung/Hüllkurve, Warping, Top-N.
   4. Klasse F: Freeze, Instantanfrequenz-Morph.
   5. Klasse D: Sorting über Histogramm.
   6. Zweite Quelle für Morphs (CPU am Handy messen).
   7. Später Klasse Z: Zeitkontrolle für ausgewählte Szenen.
4. **Modulkette für ein Morph-Instrument (Quellen A und B):**
   - (a) Magnituden-Morph in dB mit Phasenquelle als Schalter oder Instantanfrequenz-Morph,
   - (b) Hüllkurve/Feinstruktur per Glättung getrennt – zwei Regler „Klangfarbe“ und „Körper“,
   - (c) Cross-Synthese Amp(A) × Phase(B) als dritter Weg,
   - (d) Blur und Freeze als Zeit-Dimension,
   - (e) Top-N und Max/Min-Kombination als Skelettierung,
   - (f) Warping-Tabelle (Stretch-Exponent, Shift) für harmonisch → inharmonisch,
   - (g) Phasenrandomisierung als Auflösung in eine Wolke.
   Alle Regler als `param`, damit sie automatisierbar sind – Metamorphosen entstehen durch Bewegung über die Zeit (Wishart: der Weg ist wichtiger als die Endpunkte).
5. **Morph-Qualität:** ähnliche Quellen wählen oder angleichen (Tonhöhe, Dauer, Hüllkurve); Magnituden in dB interpolieren. Für die Hüllkurve ist laut Caetano & Rodet LSF perzeptiv am linearsten (über LPC→LSF anspruchsvoll); eine gute Glättung im Log-Bereich ist der pragmatische Kompromiss.
6. **Max als Werkstatt:** Algorithmen in pfft~/gen~ oder FrameLib prototypisieren und dabei so formulieren, dass sie in die Engine passen: Alles, was beim Ausgeben von Bin j nur auf den fertigen Frame g−1, den Ring und die Statistik zugreift, lässt sich direkt übertragen.
7. **Bekannte Stolpersteine:** Fenster auf allen `fft~`/`ifft~` explizit setzen (Default rectangular); Index-Gleichlauf von `fft~` und `ifft~` prüfen; die Patcher-Objekte `fft~`/`ifft~` statt `fftstream` in codebox~ verwenden (Forum-Bericht zu `win_bufname` unter 1.4.5); Streaming über eine fremde Domain braucht CORS; iOS startet Audio erst nach einer Berührung.

## Caveats

- Die RNBO-Fakten (4096 maximal, Abstand ≥ Größe, kein pfft~, Sync-Ausgang, Ausrichtung seit 1.4.0) stammen aus der aktuellen Referenz und den Release Notes. Eine Roadmap für pfft~ in RNBO habe ich nicht gefunden.
- Die Live-Engine selbst ist ein Entwurf, kein getesteter Patch. Kritisch zu prüfen sind der Index-Gleichlauf der Ketten, die Grenzen von codebox~ (12 Eingänge, 8 Ausgänge, Speichergröße) und die CPU am Handy.
- Alle Bewertungen sind Einschätzungen aus Dokumentation, Forum-Berichten und DSP-Logik, keine Benchmarks.
- Forum-Berichte (lofi Freeze, PV-Artefakte, `win_bufname`-Fehler) sind Einzelberichte.
- Herstellerangaben zu Zynaptiq MORPH 3 und Meinungen aus Foren sind nicht unabhängig geprüft; faust-rs ist ein Drittprojekt.

## Quellen

**RNBO und Max**
- [RNBO: Using the FFT](https://rnbo.cycling74.com/learn/using-the-fft)
- [RNBO: fftstream~](https://rnbo.cycling74.com/objects/ref/fftstream~)
- [RNBO: ifftstream~](https://rnbo.cycling74.com/objects/ref/ifftstream~)
- [RNBO: list.sort (codebox)](https://rnbo.cycling74.com/codebox/ref/list.sort)
- [RNBO 1.4.0 Release Notes](https://cycling74.com/releases/rnbo/1.4.0)
- [RNBO 1.4.4 Release Notes](https://cycling74.com/releases/rnbo/1.4.4)
- [RNBO 1.3.2 Release Notes](https://cycling74.com/releases/rnbo/1.3.2)
- [RNBO: Resources](https://rnbo.cycling74.com/resources)
- [RNBO JS: WorkletDevice](https://rnbo.cycling74.com/js/ref/js/WorkletDevice)
- [rnbo_fzero~](https://docs.cycling74.com/legacy/max8/refpages/rnbo_fzero~)
- [Max: pfft~](https://docs.cycling74.com/reference/pfft~/)
- [Max 7: Spectral Processing](https://docs.cycling74.com/max7/vignettes/spectral-processing_topic)
- [Cycling '74: The Phase Vocoder, Teil I](https://cycling74.com/tutorials/the-phase-vocoder-%E2%80%93-part-i)
- [Cycling '74: The Phase Vocoder, Teil II](https://cycling74.com/tutorials/the-phase-vocoder-part-ii)

**Forum**
- [Phase vocoder in RNBO – Hop kleiner als FFT-Größe?](https://cycling74.com/forums/phase-vocoder-in-rnbo-is-a-hop-size-smaller-than-the-fft-size-possible)
- [Quad overlap in RNBO fft hann window](https://cycling74.com/forums/quad-overlap-in-rnbo-fft-hann-window)
- [Maximum FFT size](https://cycling74.com/forums/maximum-fft-size)
- [FFT freeze in RNBO](https://cycling74.com/forums/fft-freeze-in-rnbo)
- [2x FFT overlap in RNBO](https://cycling74.com/forums/2x-fft-overlap-in-rnbo)
- [RNBO Phase Vocoder Troubleshooting](https://cycling74.com/forums/rnbo-phase-vocoder-troubleshooting)
- [fft~ in RNBO](https://cycling74.com/forums/fft~-in-rnbo)
- [Spectral Delay Gen](https://cycling74.com/forums/spectral-delay-gen)
- [Spectral Delay Example (Feedback)](https://cycling74.com/forums/spectral-delay-example-trying-to-add-feedback)
- [Sorting in jit.gen](https://cycling74.com/forums/sorting-in-jit-gen)
- [Insert-sort in gen codebox](https://cycling74.com/forums/insert-sort-of-a-buffer-in-gen-codebox)
- [HISE: FFT based processing](https://forum.hise.audio/topic/9970/fft-based-processing)

**Tutorials, Pakete, Werkzeuge**
- [Charles: A Tutorial on Spectral Sound Processing Using Max/MSP and Jitter (CMJ 32:3)](https://direct.mit.edu/comj/article-pdf/32/3/87/1855215/comj.2008.32.3.87.pdf)
- [Charles: Max-Patches Phase Vocoder & Freeze](https://www.jeanfrancoischarles.com/2010/01/max-patches-phase-vocoder-audio-freeze.html)
- [Charles: Spectral Audio Freeze, Teil 1](https://www.jeanfrancoischarles.com/2019/11/max-patches-for-spectral-audio-freeze.html)
- [FluCoMa: AudioTransport](https://learn.flucoma.org/reference/audiotransport/)
- [FluCoMa: Harker, Exploring the Oboe](https://learn.flucoma.org/explore/harker/)
- [FrameLib (ICMC 2017)](https://quod.lib.umich.edu/cgi/p/pod/dod-idx/framelib-audio-dsp-using-frames-of-arbitrary-length.pdf?c=icmc;idno=bbp2372.2017.045;format=pdf)
- [SuperVP for Max (Referenz)](https://forum.ircam.fr/media/uploads/software/SuperVP%20for%20Max/supervp-for-max.pdf)
- [SuperVP (IRCAM)](http://anasynth.ircam.fr/home/english/software/supervp)
- [Faust in RNBO mit codebox~](https://faustdoc.grame.fr/tutorials/rnbo/)
- [faust-rs](https://github.com/shakfu/faust-rs)
- [CDP Spectral Guide](https://www.composersdesktop.com/docs/guide/cdpspect.html)
- [CDP MORPH: Additional Information](https://www.composersdesktop.com/docs/demo/cdpexamples/exmph1mo.htm)
- [CDP WASM Suite](https://cdp-wasm-suite.github.io/)
- [Gibson: Spectral Delay as a Compositional Resource (eContact! 11.4)](https://econtact.ca/11_4/gibson_spectraldelay.html)
- [Wishart: Computer Sound Transformation](https://www.trevorwishart.co.uk/transformation.html)
- [Landy: Sound Transformations in Electroacoustic Music](https://www.composersdesktop.com/landyeam.html)

**Forschung**
- [Caetano & Rodet: Sound morphing by feature interpolation](https://www.researchgate.net/publication/224245822_Sound_morphing_by_feature_interpolation)
- [KVR-Forum: Zynaptiq Morph 3](https://www.kvraudio.com/forum/viewtopic.php?t=608593&start=60)
