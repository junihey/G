---
tags: [spec, wwww-installation, wwww-rnbo, artefakte, aliasing]
created: 2026-11-04
topic: 'Wie wwww die Artefakte digitaler Klangverarbeitung zum Gestaltungsmittel macht -- Aliasing zuerst, jede Methode mit einem Regler zwischen sauber und kaputt, und wie sie in Max/MSP, RNBO und Python umgesetzt wird'
verification: 'Ziel und Schwerpunkt Aliasing vom Nutzer im Gespraech am 2026-11-04. Artefakte, acht Methoden und Startwerte aus der vom Nutzer eingefuegten Recherche vom 2026-11-02 (raw\20261102 artefakte-digital recherche.md), diese Werte nicht bestaetigt. Biscuit-Angaben aus dem Handbuch von Oto Machines (Copyright 2009, PDF unter otomachines.com, gelesen am 2026-11-04). Buch-Angaben aus 18 Fotos in specs\wwww-installation\raw\subsample, Generating Sound & Organizing Time von Graham Wakefield und Gregory Taylor; Patchnamen im Paket Documents\Max 9\Packages\GeneratingSoundAndOrganizingTime nachgesehen, Patches nicht geoeffnet. Max-Objekte sah~, degrade~, downsamp~ in den Refpages von Max 9 nachgesehen, samphold~ gibt es dort nicht. Alle dB-Zahlen am 2026-11-04 mit raw\artefakte-digital-messung.py gerechnet (48 kHz oder 44,1 kHz, FFT 32768 Punkte, Hann-Fenster), Ergebnis in logs\artefakte-digital-messung.log. Regler, Rueckwaerts-Leiter und Zuordnung zu wwww am selben Tag vorgeschlagen, nicht bestaetigt. Nichts gebaut, nichts gehoert.'
updated: 2026-11-04
---

# Artefakte des Digitalen — Aliasing als Gestaltungsmittel

Stand 2026-11-04. **Nichts davon ist gebaut oder gehört.** Die Zahlen sind gerechnet.

> [!abstract] Jede Methode macht aus einer Grenze des Rasters einen Regler
> Digitaler Klang hat zwei Raster: die Samplerate für die Zeit und die Bits für die Amplitude. Was über die halbe Samplerate reicht, faltet zurück, und dieses Aliasing ist hier das Hauptmaterial. Unten stehen zehn Artefakte und elf Methoden, jede mit einem Regler, dessen eines Ende sauber klingt. Festgelegt sind das Ziel, der Schwerpunkt und die Umgebungen, alles andere ist ein Vorschlag.
>
> ```mermaid
> flowchart TD
>   Z["Zeitraster<br/>Samplerate"] --> T["Takt<br/>senken"]
>   Z --> R["Reset ohne<br/>Versatz"]
>   W["Wertraster<br/>Bits"] --> B["Bits<br/>schalten"]
>   W --> V["Verzerrung,<br/>Überlauf"]
>   T --> F["Aliasing<br/>Faltung an der<br/>halben Samplerate"]
>   R --> F
>   B --> F
>   V --> F
>   F --> G["Jeder Eingriff<br/>hat einen Regler"]
> ```

^blick

**Was hier steht:** welche Artefakte aus den Grenzen der digitalen Verarbeitung selbst kommen, mit welchen Methoden man sie zum Material macht und mit welchen Werten man anfängt.

**Was hier nicht steht:** die Artefakte der Audio-to-Audio-Modelle. Sie stehen in `artefakte.md`. Dort ist ein Bitcrusher ausdrücklich draußen, weil er keine Schwäche eines Modells hörbar macht. Hier gehört er dazu, weil er die Grenze des Rasters hörbar macht.

**Verwandt:** `artefakte.md` (das Gegenstück zu den Modellen), `teppich.md` (wohin die Antworten der Modelle gehen), `schnitte.md` (harte Schnitte im Audio), `katalog\capabilities\Pulsarsynthese.md` (dieselbe Klangfamilie wie der Fenster-Sync), `specs\wwww-installation\raw\subsample\` (die Buchseiten), `raw\20261102 artefakte-digital recherche.md` (die Recherche im Wortlaut), `raw\artefakte-digital-messung.py` (rechnet die Zahlen nach).

---

## Festgelegt

| Was | Wie | Seit |
|---|---|---|
| Ziel | Die Artefakte digitaler Klangverarbeitung werden hervorgehoben und zum Gestaltungsmittel. | 2026-11-04 |
| Schwerpunkt | Aliasing, also die Faltung von Frequenzen an der halben Samplerate. | 2026-11-04 |
| Umgebungen | Max/MSP, RNBO und Python. | 2026-11-02 |

---

## Vorgeschlagen, nicht bestätigt

### Die drei Quellen

| Quelle | Was sie beiträgt |
|---|---|
| Recherche vom 2026-11-02 | Die Liste der Artefakte, acht Methoden, die Testsignale. Vier ihrer Angaben sind unten korrigiert: der Jitter, das Halten, die Stufenzahl und das Objekt `samphold~`. |
| Biscuit von Oto Machines | Eine gebaute Kette: 8-Bit-Wandler mit Takt von 250 Hz bis 30 kHz, jedes der 8 Bits einzeln stumm oder umgekehrt, danach ein analoges Filter. Daher kommen die Methode „Bits schalten“ und die Mischung aus Trocken und Bearbeitet. |
| Buch *Generating Sound & Organizing Time* | Wie Aliasing am Reset eines Phasors entsteht und wie man es Schritt für Schritt entfernt. Hier läuft dieselbe Leiter rückwärts. |

### Die Artefakte

| Artefakt | Woher es kommt | Woran messbar |
|---|---|---|
| Frequenzfaltung | Eine Frequenz liegt über der halben Samplerate und erscheint gespiegelt darunter. | Spektrogramm |
| Spiegelbilder | Ein gehaltener Wert ist eine Treppe, und die Treppe trägt Kopien des Spektrums um den Takt herum. | Spektrum über der halben Taktrate |
| Nichtlineares Aliasing | Verzerrung erzeugt Obertöne über der halben Samplerate, die zurückfalten. | Energie neben den Harmonischen |
| Zweites Raster | Der Takt teilt die Samplerate der Engine nicht glatt, also springt die Haltedauer zwischen zwei Längen. | Fremde Linien im Spektrum |
| Reset-Fehler | Ein Phasor springt am ganzen Sample auf null, obwohl der wahre Sprung zwischen zwei Samples liegt. | Energie neben den Harmonischen |
| Quantisierungsstufen | Die Amplitude kennt nur feste Zahlenwerte. | Quantisierungsfehler, Histogramm |
| Bitbruch | Ein einzelnes Bit wird stumm oder umgekehrt, und die Kennlinie bekommt Sprünge. | Kennlinie, Pegel |
| Numerischer Überlauf | Ein Wert verlässt den Zahlenbereich und läuft auf der anderen Seite weiter. | Signalverlauf, Spektrum |
| Zeitbasisfehler (Jitter) | Die Abstände der Abtastung schwanken. | Rauschen neben dem Ton |
| Block- und Fensterartefakte | Die Verarbeitung arbeitet in Stücken fester Länge. | Transienten, Tonhöhe der Wiederholung |

### Die Methoden im Überblick

| Methode | Macht hörbar | Regler | Quelle |
|---|---|---|---|
| Ungefiltertes Downsampling | Frequenzfaltung | Takt | Recherche, Biscuit |
| Halten und Filter | Spiegelbilder | Grenzfrequenz nach dem Halten | Recherche, Biscuit |
| Takt gegen Engine | Zweites Raster | Takt frei oder als glatter Teiler | gerechnet |
| Bewegtes Aliasing | Frequenzfaltung in Bewegung | Takt als Tonhöhe | Recherche, Biscuit |
| Aliasing durch Waveshaping | Nichtlineares Aliasing | Drive, Oversampling | Recherche, Biscuit |
| Subsample-Regler | Reset-Fehler | Menge von 0 bis 1 | Buch |
| Bit-Reduktion | Quantisierungsstufen | Zahl der Stufen, Dither | Recherche, Biscuit |
| Bits schalten | Bitbruch | Muster aus 8 Bits | Biscuit |
| Numerischer Überlauf | Überlauf | Verstärkung, Clip oder Wrap | Recherche, Biscuit |
| Jitter | Zeitbasisfehler | Streuung pro Sample | Recherche, korrigiert |
| Block-Grenzen | Block- und Fensterartefakte | Blocklänge | Recherche, Buch |

### Umsetzung

**Max/MSP** heißt: lokal, live, fast alles in `gen~`, weil dort jedes Sample einzeln zugänglich ist. **RNBO** heißt: als Export, etwa im Browser. **Python** heißt: offline, Datei rein, Datei raus.

`sah~`, `degrade~` und `downsamp~` stehen in den Refpages von Max 9. `samphold~` aus der Recherche gibt es dort nicht, das Objekt heißt `sah~`. Die `go.*`-Bausteine liegen im Paket `GeneratingSoundAndOrganizingTime`. Keiner dieser Patches ist geöffnet, und ob die `go.*`-Bausteine in RNBO laufen, ist nicht geprüft. Die übrigen Objektnamen stammen aus den Buchseiten oder aus dem Gedächtnis.

| Methode | Max/MSP | RNBO | Python |
|---|---|---|---|
| Ungefiltertes Downsampling | `gen~`: `phasor` als Takt, `latch` hält; schnell: `sah~`, `downsamp~` | gen wie in Max | jedes N-te Sample, wiederholt |
| Halten und Filter | `svf~` oder `biquad~` nach dem Halten | Filter in gen | `scipy.signal` |
| Takt gegen Engine | `samplerate` in `gen~` lesen, Takt daraus rechnen | Rate des Audio-Kontexts lesen | Index mit Rundung |
| Bewegtes Aliasing | Takt als Signal, `gen~` | dasselbe, Parameter aus JS | veränderlicher Index |
| Aliasing durch Waveshaping | `gen~`: `tanh`, `clip`, `fold`; 2x und 4x über `poly~` zum Vergleich | gen | `numpy.tanh`, `numpy.clip` |
| Subsample-Regler | `go.ramp.subsample`, `go.ramp.aa`, `windowed_sync.maxpat`, `poly_granulation3.maxpat`, `granola_buffer.maxpat` | Bausteine nachbauen, falls sie nicht laufen | Phasor von Hand |
| Bit-Reduktion | `gen~`: `floor`; fertig: `degrade~` | gen | `numpy.round` |
| Bits schalten | `gen~` mit `floor` und `%`, Formel unten | gen | `numpy.bitwise_xor`, `numpy.bitwise_and` |
| Numerischer Überlauf | `gen~`: `clip` gegen `wrap` | gen | Integer-Rechnung in NumPy |
| Jitter | `gen~`: Fractional Delay, Position pro Sample aus `noise` | Delay in gen | Interpolation an versetzten Zeiten |
| Block-Grenzen | `buffer~`, `groove~`, `peek` in `gen~` | Buffer und Granulator in gen | Audio in Blöcke schneiden |

### Wie gerechnet wurde

Testton ist ein Sinus mit 997 Hz, Engine 48 kHz, sofern nichts anderes dabeisteht. „Unharmonisch“ heißt: die Energie neben den Harmonischen des Tons, relativ zur Gesamtenergie. Unverändertes 8-Bit liegt so bei −44 dB. Unter etwa −45 dB zählt die Analyse selbst mit, die Werte sind dort kaum noch aussagekräftig. Die Werte sagen, wie viel neues Material entsteht, nicht ob es gut klingt.

### Ungefiltertes Downsampling

**Das zentrale Artefakt.** Eine Frequenz `f` erscheint bei einem Takt `T` als `|f − k·T|`, mit der ganzen Zahl `k`, die das Ergebnis am kleinsten macht. Der Takt wird gesenkt, ohne Tiefpass davor, und das Signal bleibt gleich lang.

Der neue Ton ist nicht nur eine Beigabe. Bei einem Takt von 8 kHz wird aus 6 kHz der lauteste Ton bei 2 kHz, die 6 kHz selbst folgen erst mit −8,7 dB. Aus 6,1 kHz werden 1,9 kHz: Der Eingang steigt, die Faltung fällt.

**Startwerte:** Takt 8–16 kHz, Extrembereich bis 2 kHz. Biscuit geht bis 250 Hz hinunter, dort bleibt die Faltung unter 125 Hz.

### Halten und Filter

Das Halten macht aus dem Signal eine Treppe. Aus 1 kHz bei einem Takt von 8 kHz werden Linien bei 7 kHz (−16,6 dB) und 9 kHz (−18 dB). Das sind Spiegelbilder, keine Faltung.

**Beide lassen sich trennen.** Ein Tiefpass nach dem Halten, knapp unter der halben Taktrate, nimmt die Spiegelbilder weg. Die Faltung bleibt, denn sie liegt schon im Durchlassbereich. Ein Hochpass an derselben Stelle lässt nur die Spiegelbilder übrig. Biscuit hat genau diese Stelle: Nach dem Wandler kommt ein analoges Filter mit Tiefpass, Bandpass und Hochpass von 20 Hz bis 15 kHz.

**Korrektur zur Recherche:** Sie nennt drei Verfahren mit unterschiedlichem Spektrum. Zero-Order Hold und Nearest Neighbour unterscheiden sich aber nur um eine halbe Haltedauer. Hörbar wird das erst, wenn das Signal mit dem Original gemischt wird. Bleiben zwei Verfahren: Halten und lineare Interpolation.

### Takt gegen Engine

Ein Takt in `gen~` kann nur auf ganzen Samples der Engine wechseln. Teilt er die Samplerate nicht glatt, entsteht ein zweites Raster:

| Engine | Takt | Teilt glatt | Raster wiederholt sich mit | Stärkste fremde Linie |
|---|---|---|---|---|
| 48 kHz | 8 kHz | ja | 8 kHz | −65 dB |
| 48 kHz | 7 kHz | nein | 1 kHz | −27,9 dB |
| 44,1 kHz | 8 kHz | nein | 100 Hz | −27,2 dB |
| 44,1 kHz | 7,35 kHz | ja | 7,35 kHz | −69,4 dB |

Das Raster wiederholt sich mit dem größten gemeinsamen Teiler von Engine und Takt. Die fremden Linien liegen auf diesem Raster, Werte unter −60 dB heißen: praktisch keine. Der Takt von 7 kHz gibt also ein 1-kHz-Raster, das nirgends im Patch steht. Mischen am Wechsel-Sample nach dem Vorbild von `go.ramp.aa` nimmt nur 4–5 dB davon weg.

**Folge:** Derselbe Patch mit 8 kHz klingt auf einem Rechner mit 48 kHz sauber und auf einem mit 44,1 kHz nicht. Das ist auf den Handys eine Entscheidung: entweder die Rate lesen und den Takt daraus rechnen, oder den Unterschied zwischen den Geräten als Material nehmen.

### Bewegtes Aliasing

Der Takt wird zur Tonhöhe. Ein fester Sinus mit 6 kHz und ein Takt von 6440 Hz geben 440 Hz, denn `|6000 − 6440| = 440`. Allgemein: `T = (f + Zielton) / k`. Eine Melodie auf dem Takt spielt also die Faltung, ohne dass der Eingang sich bewegt.

Ein Sägezahn statt des Sinus bringt ganze Gruppen gefalteter Obertöne, die gegeneinander wandern. Wird der Eingang bewegt und der Takt bleibt fest, läuft die Faltung als Gegenbewegung: Der Eingang steigt, die Faltung fällt, bis sie am Rand umkehrt.

Biscuit koppelt das an die Zeit. Sein Delay ändert die Delayzeit über die Samplerate, also wird es umso rauer, je länger es ist. Das Handbuch nennt das Aliasing ausdrücklich.

**Startwerte:** Takt 8–16 kHz, LFO 0,05–8 Hz, Tiefe 10–80 % des Bereichs.

### Aliasing durch Waveshaping

Die Verzerrung erzeugt Obertöne, und die Samplerate faltet sie zurück. Sie läuft absichtlich ohne Oversampling. Clip mit 8-facher Verstärkung gibt −35,6 dB Unharmonisches.

Biscuit hat drei passende Kennlinien: Gleichrichtung (Oktave hoch), Spiegelung ab einer Schwelle (`Bat Fuzz`) und den Tausch der Bits 1–4 mit 5–8 (`Swap`). Der Vergleich von 1x, 2x und 4x Oversampling zeigt, was davon wirklich Faltung ist.

**Startwerte:** `tanh` oder Clip, Drive schrittweise, Oversampling 1x.

### Subsample-Regler

Das Buch zeigt: Bei hohen Tonraten ist „auf das Sample genau“ nicht genau genug. Der wahre Sprung eines Phasors liegt zwischen zwei Samples. Wer dort auf exakt null zurücksetzt, hört Aliasing. Das Buch entfernt es in Schritten. Hier wird jeder Schritt ein Regler:

| Was das Buch fordert | Regler hier |
|---|---|
| Der Träger springt nicht auf null, sondern auf den Subsample-Versatz. | `Menge` von 0 bis 1 multipliziert den Versatz. |
| Ein Korn startet bei `step = subsample`. | `step = Menge * subsample` |
| Das Fenster endet bei null, und Fenster oder Träger beginnt bei null. | Das Fensterende anheben, dann knackt jeder Durchlauf. |
| Eine Form zwischen `mix` und `switch` in `go.ramp.aa` hat keine harten Schnitte. | Eine Form mit Schnitt einsetzen. |

Das Buch nennt den Zustand ohne Korrektur selbst *raw (aliasing) synced phasor*.

Gerechnet für den Fenster-Sync aus dem Buch: Träger das 4-Fache des Takts, Fenster `(1 − Phase)²`. Unharmonisch:

| Tonrate | Menge 0 | Menge 0,5 | Menge 1 |
|---|---|---|---|
| 100,3 Hz | −36,1 dB | −41,6 dB | −49,6 dB |
| 997 Hz | −16,3 dB | −22,5 dB | −36,7 dB |
| 3001 Hz | −6,9 dB | −13,4 dB | −20,2 dB |

Der Regler hat überall 13–20 dB Hub. Hörbar dürfte er erst bei hohen Tonraten sein, wie das Buch sagt: Bei 100 Hz bleibt das Unharmonische auch mit Menge 0 leise, bei 3 kHz ist es mit Menge 0 ein Fünftel der Energie.

Dazu kommt der Formant: Das Verhältnis von Träger zu Takt ist ein Formant-Multiplikator. Je enger das Fenster, desto mehr Stille liegt zwischen den Stößen und desto deutlicher der Formant. Sehr kurze Körner bei hoher Rate werden zum Ton, und dort wird der Versatz wichtig.

### Bit-Reduktion

Die Amplitude wird auf weniger Stufen gerundet: 8 Bit sind 256 Stufen, 6 Bit 64, 4 Bit 16.

**Korrektur zur Recherche:** `round(signal * levels) / levels` gibt bei `levels = 128` genau 257 Stufen, bei `levels = 8` 17. Das ist die Variante, in der Stille still bleibt und ein leises Signal unter der halben Stufe verschwindet. Die Variante `(floor(signal * levels) + 0,5) / levels` macht aus jedem noch so leisen Signal ein Rechteck. Die Wahl ist also ein Gestaltungsmittel: Gate oder Rechteck.

**Startwerte:** 12, 8 und 4 Bit im Wechsel, mit und ohne Dither. Die Stufenzahl lässt sich auch stetig bewegen, dann gibt es keine Sprünge zwischen den Bittiefen.

### Bits schalten

Biscuit schaltet jedes der 8 Bits einzeln stumm oder um. Das Handbuch sagt: Die Bits 6–8 verzerren stark, die Bits 1–3 wirken subtil und taugen zur Bit-Reduktion oder als Rauschen. Das ist etwas anderes als eine geringere Bittiefe, denn die Kennlinie bekommt Sprünge. Sie steigt nicht mehr durchgehend.

| Eingriff | Was mathematisch passiert | Unharmonisch bei Pegel 0,9 | Effektivpegel bei Pegel 0,1 |
|---|---|---|---|
| normal | – | −44,5 dB | −23 dB |
| Bit 1–4 aus | abgerundet auf 16 Stufen | −26,2 dB | −24 dB |
| Bit 4 um | kleine Sprünge in der Kennlinie | −21,8 dB | −23,5 dB |
| Bit 6 um | größere Sprünge | −16,6 dB | −10 dB |
| Bit 7 um | größere Sprünge | −13 dB | −4,9 dB |
| Bit 8 aus | Rest modulo 128 | −12,8 dB | −7,1 dB |
| Bit 8 um | Überlauf: plus 128, modulo 256 | −11,9 dB | −0,5 dB |
| alle um | Polarität gedreht: `−x − 1` | −44,5 dB | −23 dB |
| Bits 1–4 mit 5–8 getauscht | fast Rauschen, wie das Handbuch sagt | −1,8 dB | −6,2 dB |

Der Gleichanteil ist aus den Pegeln herausgerechnet. Drei Dinge folgen daraus:

- **Die Lautstärke dreht sich um.** Mit Bit 8 um wird ein leiser Ton um 22,5 dB lauter. Das Signal springt an jedem Nulldurchgang von Rand zu Rand. Das ist ein Instrument und zugleich die Gefahr vor den Genelec.
- **Bit 8 um ist Überlauf.** Nur liegt der Sprung am Nulldurchgang statt am Rand des Zahlenbereichs.
- **Alle um und Trocken ergeben den Fehler.** Gemischt mit dem Original bleibt nur der Quantisierungsfehler übrig, das ist das Residuum aus `artefakte.md`, angewandt auf das Raster. Am Gerät trifft das vermutlich nur ungefähr, weil der analoge Weg dazwischenliegt. In `gen~` trifft es genau.

**In `gen~`,** wo die Bit-Operatoren nicht zu den gemeinsamen Gen-Operatoren gehören. Für das Bit `k` von 0 bis 7, mit `u` als ganzer Zahl von 0 bis 255: `b = floor(u / 2^k) % 2`. Umkehren ist `u + (1 − 2b) · 2^k`, stumm ist `u − b · 2^k`. Für alle 256 Werte und alle 8 Bits nachgerechnet. Ob der Wandler mit Vorzeichen oder ohne zählt, ändert nur den Gleichanteil.

**Muster:** Biscuit speichert 8 Muster als Snapshots und nimmt jeden Regler per MIDI an. Ein Bitmuster lässt sich also wie eine Stufe in einem Sequencer behandeln.

### Numerischer Überlauf

Zwei Varianten: Clip begrenzt, Wrap läuft auf der anderen Seite weiter. Der Unterschied ist groß: Wrap mit 3-facher Verstärkung gibt −9,2 dB Unharmonisches, Clip mit 8-facher nur −35,6 dB. Wrap erzeugt also weit mehr Faltung.

**Startwerte:** 8 oder 16 Bit Festkomma, Verstärkung schrittweise, Clip und Wrap im Vergleich.

### Jitter

**Korrektur zur Recherche:** Sie nennt 0,02–0,2 Samples bei 0,1–10 Hz. Langsam moduliert ist das nicht hörbar: 0,2 Samples bei 10 Hz sind ±0,45 Cent, bei 0,1 Hz ±0,005 Cent. Für ±45 Cent braucht es 20 Samples bei 10 Hz, und das ist dann ein Vibrato.

Jitter im eigentlichen Sinn ist eine neue Abweichung für jedes einzelne Sample. Gerechnet mit gaußscher Streuung:

| Streuung | Ton 1 kHz | Ton 10 kHz |
|---|---|---|
| 0,02 Samples | unter −45 dB | −31,6 dB |
| 0,2 Samples | −31,5 dB | −11,9 dB |

Das Rauschen wächst mit der Frequenz, also zerfallen die Höhen, während der Bass steht. Das unterscheidet Jitter vom Vibrato.

**Startwerte:** Streuung 0,02–0,2 Samples pro Sample. Das Rauschen ist hier mit einem idealen Sinus gerechnet. Ein Fractional Delay mit linearer Interpolation dämpft zusätzlich die Höhen, und das kommt im Patch dazu.

### Block-Grenzen

Ein wiederholter Block hat eine Tonhöhe, nämlich Samplerate geteilt durch Blocklänge:

| Blocklänge | bei 48 kHz | bei 44,1 kHz |
|---|---:|---:|
| 32 Samples | 1500 Hz | 1378,1 Hz |
| 64 Samples | 750 Hz | 689,1 Hz |
| 128 Samples | 375 Hz | 344,5 Hz |
| 256 Samples | 187,5 Hz | 172,3 Hz |

Ganze Blocklängen geben also nur eine Untertonreihe der Samplerate. Das Buch beschreibt dasselbe von der anderen Seite: Je kleiner und schneller die Körner, desto mehr wird der Klang zum Ton. Erst der Subsample-Versatz gibt jede beliebige Tonhöhe.

**Startwerte:** 32–256 Samples, einzelne Blöcke oder zufällige Auswahl, Überblendung keine bis kurz, Position fest oder moduliert.

### Testsignale

**Der Testton darf die Samplerate nicht teilen.** Bei 1000 Hz hat eine Periode exakt 48 Samples, also fällt jede Faltung auf eine Harmonische und bleibt unsichtbar. Wrap mit 3-facher Verstärkung: bei 1000 Hz −50,5 dB, bei 997 Hz −9,2 dB. Dasselbe Verfahren, 41 dB Unterschied im Messwert.

| Testsignal | Was hörbar wird |
|---|---|
| Sinus 997 Hz | Faltung, Jitter, Bits |
| Sinus-Sweep | die Bewegung der Faltung über den ganzen Bereich, das wichtigste Testsignal |
| Sägezahn | gefaltete Obertonreihen |
| Rechteck | das Verhalten bei vielen hohen Obertönen |
| Impuls | zeitliche Auflösung und Block-Grenzen |
| Weißes Rauschen | Quantisierung und Downsampling im ganzen Spektrum |
| Stille | was das System selbst tut; mit Bit 8 um eine Gleichspannung am Rand des Bereichs |

---

## Was für den Bau gilt

- **Jede Methode nennt ihr Artefakt und ihren Regler.** Ein Ende des Reglers klingt sauber, das ist zugleich der Vergleich mit dem Original.
- **Der Takt wird aus der Samplerate der Engine gerechnet**, oder das zweite Raster ist eine bewusste Entscheidung.
- **Gemessen wird mit 997 Hz, nie mit 1000 Hz.** Sonst sieht man das Aliasing nicht.
- **Vor den Lautsprechern stehen `dcblock` und ein Limiter.** Stille mit Bit 8 um ist eine Gleichspannung, und ein leiser Ton wird um 22,5 dB lauter. Das Handbuch warnt selbst vor dem Pegel.
- **Zwischenschritte werden gespeichert**, wenn Verfahren wiederholt oder verkettet werden.
- **Messung und Hören gehören zusammen.** Das Spektrogramm zeigt, wo gefaltet wird. Das Hören entscheidet, ob es verwendet wird.

## Bewusst nicht drin

| Draußen | Warum |
|---|---|
| Aliasing entfernen | Das wäre das Gegenteil des Ziels. `go.ramp.aa` steht hier nur als Regler. |
| Analoge Wärme, analoge Sättigung nachahmen | Das ist ein anderes Projekt. Der Diodenclip von Biscuit gehört deshalb nicht zu den Methoden. |
| Verzerrung ohne digitale Ursache | Jedes Artefakt braucht eine technische Grenze, von der es kommt. |
| Fertiger Bitcrusher als einziger Eingriff, etwa `degrade~` allein | Er erreicht weder einzelne Bits noch das zweite Raster. |
| Oszillatoren und Step Filter von Biscuit | Sie erzeugen Klang oder bewegen ein Filter, ohne eine Grenze des Rasters hörbar zu machen. |
| Artefakte der Modelle | Sie stehen in `artefakte.md`. |

## Was offen ist

- **Welche Methoden live laufen und welche nur offline.** Auf dem Installationsrechner, auf den Handys oder in der Vorproduktion.
- **Ob Aliasing Effekt oder eigene Klangquelle ist.** Bewegtes Aliasing auf einem festen Sinus wäre eine Klangquelle. `teppich.md` sagt: Der Teppich hat keinen eigenen Rauschgenerator. Danach dürfte dort nur der Effekt laufen.
- **In welcher Reihenfolge die Artefakte verkettet werden.** Biscuit nimmt Takt, dann Bits, dann Filter. Ob auch die andere Reihenfolge trägt, ist nicht gehört.
- **Wie weit der Takt sinken darf**, bevor das Material zusammenbricht.
- **Welche Rolle die Bits neben dem Aliasing spielen.** Bit 8 um und der Tausch der Bits erzeugen rechnerisch viel Unharmonisches, ein Hörtest fehlt.
- **Ob einzelne Instrumente oder ein System entstehen.**
- **Ob die Unterschiede der Handys Material werden.** Dazu muss man wissen, welche Samplerate die Browser wirklich liefern.
- **Ob die `go.*`-Bausteine in RNBO laufen.** Sonst werden sie nachgebaut.
- **Welche Methoden sich für die Steuerung aus dem Eurorack eignen.**
- **Ob Biscuit gekauft wird oder nur Vorbild bleibt.** Es steht weder im Katalog noch in `aufbau.json`.
- **Welche Methode zu welchem Motiv gehört.** Die Motive stehen in `specs\wwww-main\motive.md`.
