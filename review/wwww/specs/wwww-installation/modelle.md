---
tags: [spec, wwww-installation, wwww-rnbo, modelle]
created: 2026-09-27
topic: 'Welche Modelle wwww nimmt, auf welchem der drei Rechner, und welches Motiv jedes traegt'
verification: 'Abschnitt "Festgelegt" vom Nutzer im Gespraech am 2026-09-27; Abschnitt "Vorgeschlagen" aus derselben Sitzung, nicht bestaetigt; jede Zeile von zaehlen\MODELLE.md gegen specs\wwww-main\raw\20260808 context infos.md gehalten; "Festgelegt" am 2026-10-15 vom Nutzer ergaenzt; Speicher von RT2 Small und SA3 Small am 2026-10-13 auf dem Mac mini gemessen (specs\wwww-main\kette-entwurf.md), Groessen der Sprachmodelle am 2026-10-15 ueber die Hugging-Face-API, mrt2~ ohne Signal-Eingang laut examples/max/mrt_tilde.mm'
---

# Modelle — was wwww auf welchem Rechner rechnet

Ausgearbeitet im Gespräch am 2026-09-27, ergänzt am 2026-10-15. **Außer dem Prototyp in `specs\wwww-rnbo\raw\rave-rnbo-web.zip`, einem RAVE-v1-Dummy im Browser, ist nichts gebaut.** Auf dem Mac mini gemessen sind RT2 Small und SA3 Small, am 2026-10-13.

> [!abstract] Wenige Modelle, jedes mit einer klaren Aufgabe
> Die Regel kommt aus den Motiven: „Keine Entscheidung darf Kraft kosten“. Auf dem Handy ist RAVE v1 das einzige Modell. Der übrige Klang des Handys, RNBO mit FFT-Patches und Loris, steht in `kommunikation.md` unter „Was wo läuft“. Der Mac mini rechnet in Max, was live auf ☉ und Raummikrofon antwortet. Was nicht in 16 GB passt, läuft vorher auf dem PC.
>
> ```mermaid
> flowchart LR
>   SUN["☉ von den Handys"] --> RT2["Magenta RT2 Small<br/>mrt2~"]
>   SUN --> SA3S["SA3 Small<br/>Music"]
>   MIC[Raummikrofon] -->|Fang| RV2["RAVE v2, AFTER<br/>nn~"]
>   MIC -->|Text| TR["Transkription,<br/>Sprachmodell"]
>   TR --> MOON[☽]
>   subgraph MM["Mac mini, 16 GB"]
>     RT2
>     SA3S
>     RV2
>     TR
>   end
>   HA["Handy:<br/>RAVE v1"]
>   PC["PC, vorab:<br/>SA3 Medium,<br/>ACE-Step"]
> ```

^blick

**Die drei Rechner:** Vorproduktion auf dem PC, Installationsrechner (Mac mini M6, 16 GB) mit Max und drei Genelec, Handy im Browser. Wo was rechnet, regelt `kommunikation.md` unter „Wo gerechnet wird“.

**Verwandt:** `specs\wwww-installation\kommunikation.md` (wer mit wem spricht, was wo läuft), `zaehlen\modelle\audio-katalog.md` (der Katalog aller Audio-Modelle mit Spalte „Rechner“), `specs\wwww-main\raw\20260808 context infos.md` (die Motive), `zaehlen\rave-training`, `zaehlen\after-training`.

---

## Festgelegt

| Rechner | Modell | Wie |
|---|---|---|
| Handy | **RAVE v1** | als ONNX in onnxruntime-web neben RNBO, kausal, `CAPACITY=16`, ohne Mikrofon: über die Regler z1 bis z4 oder mit einer Quelle aus RNBO |
| Installationsrechner | **Magenta RT2 Small** (`mrt2~`) | in Max; spielt die ☉ als Stil-Vorgaben, gewichtet nach der Zahl der Handys an jedem Punkt. Nimmt kein Audio an: `mrt2~` hat laut Quellcode keinen Signal-Eingang. |
| Installationsrechner | **SA3 Small Music** | über MLX neben Max; antwortet auf jeden ☉ mit einem Sample |
| Installationsrechner | **RAVE v2**, **AFTER** (`nn~`) | in Max; verwandeln die Fänge vom Raummikrofon (`kommunikation.md`, „Das Raummikrofon“) |
| Installationsrechner | Transkription und Sprachmodell für den ☽ | lokal, ohne Internet; welche Modelle, entscheidet der Test unter „Was offen ist“ |
| Vorproduktion | **SA3 Medium**, **ACE-Step** | nicht live; ACE-Step passt mit mindestens 6 GB nicht neben den Rest in 16 GB |

Die Zeile Handy gilt seit 2026-09-27, alle anderen seit 2026-10-15.

---

## Vorgeschlagen, nicht bestätigt

### Modelle pro Rechner

| Einstufung | Bedeutung |
|---|---|
| Kern | trägt ein Motiv allein |
| geplant | hat eine Aufgabe, noch nicht begonnen |
| kann | nur, wenn eine Bedingung eintritt |

| Rechner | Modell | Wofür | Einstufung |
|---|---|---|---|
| Handy | RAVE v1 | Timbre-Transfer | festgelegt |
| Handy | zweites RAVE v1 | der zweite Pol, hängt an der offenen Frage unten | kann |
| Handy | FluCoMa-Regression, in JS nachgerechnet | Position → RNBO-Parameter | geplant |
| Installationsrechner | **Magenta RT2 Small** (`mrt2~`) | Feedback: setzt sich selbst fort; die ☉ sind seine Stil-Vorgaben, gewichtet nach der Zahl der Handys an jedem Punkt. Feste Stil-Vorgaben sind die Namen oder Qualitäten der Tierkreiszeichen auf den 12 Punkten und der Planeten bei den 7 Bewegungen (`konzept.md`, „Das Heft als Ursprung“) | festgelegt |
| Installationsrechner | **SA3 Small Music** (MLX) | antwortet auf jeden ☉ mit einem Sample; gemessen: 30 s Audio in 1,06 s | festgelegt |
| Installationsrechner | **AFTER** (`nn~`) | „3 in 1 in 3“: Struktur aus den mit OpenUtau gesungenen Samples aus dem Heft oder aus einem Fang vom Raummikrofon, Klangfarbe vom Saxophon | festgelegt |
| Installationsrechner | **FluCoMa** | `fluid.kdtree~` wählt die Struktur für AFTER, misst den Raum-Anteil, Messungen gehen als Rückweg an die Handys | geplant |
| Installationsrechner | **RAVE v2** (`nn~`) | verwandelt die Fänge vom Raummikrofon in Saxophon. Als Autoencoder steckt es ohnehin in AFTER. | festgelegt |
| Installationsrechner | Transkription: Apple SpeechTranscriber, sonst Whisper large-v3-turbo | Raummikrofon → Text für den ☽ | festgelegt, Modell nach dem Test |
| Installationsrechner | ☽: Qwen 3.5 in 4 Bit (0.8B, 2B oder 4B), Apples Sprachmodell als Vergleich | alle 240 s zwei bis vier Sätze | festgelegt, Modell nach dem Test |
| Installationsrechner | BRAVE (`nn~`) | nur wenn im Konzert ein Instrument live durch das Modell geht | kann |
| Installationsrechner | MSPrior (`nn~`) | Feedback im Latent-Raum von RAVE; ruht seit 2023 | kann |
| Installationsrechner oder Handy | NAM A2 | „Reibung (warm)“: die Sättigung eines bestimmten Geräts | kann |
| Vorproduktion | **Stable Audio 3 Medium** | Metamorphose als Kette und als Fächer, siehe unten | Kern |
| Vorproduktion | ACE-Step, Repaint | Übergänge zwischen benachbarten der 12 Punkte | geplant |
| Vorproduktion | ACE-Step, Cover | das Gedicht verliert seine Wörter, siehe unten; ein Fächer über `audio_cover_strength` von 1,0 bis 0,1 | geplant |
| Vorproduktion | FluCoMa | Korpus, UMAP, NMF | geplant |
| Vorproduktion | Stable Audio 3 Small-SFX | Elementklänge zu „Geist der Elemente“; ob `init_audio` wirkt, ist offen | kann |
| Vorproduktion | SAM Audio, PANNs, librosa, Chromaprint | die Datensätze für RAVE und AFTER, siehe `zaehlen\rave-training` | geplant |

### Motive → Modelle

| Motiv | Klanglich heißt das | Modell oder Werkzeug | Rechner |
|---|---|---|---|
| Verwandlung, Metamorphose („Timbre Transfer“ steht dort wörtlich) | ein Klang nimmt die Gestalt eines anderen an | RAVE v1 | Handy |
| Polaritäten, Dopplung (Sonne/Mond, Luzifer/Ahriman) | zwei Pole, der Spieler steht dazwischen | zwei RAVE-v1-Modelle, überblendet nach Standpunkt; hängt an der offenen Frage | Handy |
| Vokale: die Sprache verliert das Substantiv | Sprechen ohne Wörter | RAVE v1 auf eine Sprechstimme, nur über die Regler gespielt; hängt an der offenen Frage | Handy |
| Vokale, als Reihe | das Gedicht verliert Stufe für Stufe seine Wörter: ganz, ohne Substantive, nur Verben, nur Ausrufe und Vokale | ACE-Step Cover mit dem Gedicht-Recording als Quelle und je neuen Lyrics | Vorproduktion |
| Übergänge zwischen Ideen | ein komponierter Weg von A nach B statt einer Mischung | ACE-Step Repaint zwischen zwei Aufnahmen, für benachbarte der 12 Punkte | Vorproduktion → Handy |
| 3 in 1 in 3 | zwei Ströme ergeben ein Drittes | AFTER; oder NMF mit drei Schichten | Installationsrechner; Vorproduktion |
| Feedback, Kopplung | die Ausgabe wird wieder Eingabe | Magenta RT2 als schnelle Schleife (2-s-Stücke); die Fänge vom Raummikrofon als Schleife durch den Raum | Installationsrechner |
| Metamorphose als Pflanzenwachstum | **Kette:** jede Ausgabe wird mit kleinem denoise die nächste Eingabe | Stable Audio 3 Medium | Vorproduktion |
| Auflösen / Materialisieren; „noise generation and degeneration“ | **Fächer:** vom selben Original denoise 0,1 bis 0,9; vorwärts löst es sich auf, rückwärts materialisiert es sich | Stable Audio 3 Medium | Vorproduktion |
| Polaritäten, als zwei Arten der Verfremdung | der SA3-Fächer löst die Form ins Rauschen auf; ACE-Step Cover behält die Form und tauscht den Klang | Stable Audio 3 Medium neben ACE-Step Cover | Vorproduktion |
| Analyse/Synthese; „fft manipulated samples into a corpus“ | zerlegen und neu zusammensetzen | FluCoMa | Vorproduktion |
| Transferformat: „Regression zwischen k-dimensionalen Räumen“, „Verteilungsfunktionen“ | eine Position steuert viele Parameter | FluCoMa-Regression; Gaußverteilung | Vorproduktion → Handy |
| 12 Motive als stille Kraftzentren; die Kugel | 12 feste Orte im Raum | der RAVE-Encoder setzt die Punkte; oder FluCoMa-UMAP | Vorproduktion → Handy |
| 7 Bewegungen | – | keine Modellfrage: die Gesten in `specs\wwww-threejs\steuerung.md` | – |
| Schwere: Dichte, Reibung (warm), langsam | Wärme, Sättigung | NAM A2 | Installationsrechner oder Handy |

### Nicht genommen

| Grund | Modelle |
|---|---|
| braucht Internet, die Installation hat keins | ElevenLabs Music, ElevenLabs Voice Changer, Lyria RealTime, Suno Studio, Udio, Kits.ai, Magenta RT v1 (Echtzeit nur auf einer Colab-TPU) |
| doppelt | Neutone Morpho, Neutone SDK, vschaos2 (RAVE deckt es ab); MelodyFlow, JASCO, MusicGen-Melody, Stable Audio Open 1.0 / Small (Stable Audio 3 Medium deckt es ab); magenta-rt2-nvidia (nur ohne Mac); ACE-Step Extract (SAM Audio deckt es ab) |
| kein Motiv fragt danach | RVC, Applio, DDSP-SVC (tauschen die Stimme und lassen die Wörter stehen, das Motiv Vokale will das Gegenteil); ACE-Step Lego (keine Begleitspur gesucht); ACE-Step Complete (als Gegenstück zu Extract denkbar, eine Stimme bekommt eine ganze Begleitung, Auflösen gegen Materialisieren, aber schwach) |
| nicht verfügbar | archiviert: Seed-VC, so-vits-svc, DDSP-VST. Nur Paper oder ohne Gewichte: LiveBand, StreamMusicGen, Diff-A-Riff, StemGen, MusicGen-Stem, SingSong |
| Werkzeug ohne Klangrolle | Essentia, CLAP, AudioSep, allin1; die Codecs EnCodec, Music2Latent, DAC |
| zu groß für die 16 GB des Mac mini neben dem Rest | ACE-Step live; es bleibt in der Vorproduktion |

---

## Speicher auf dem Mac mini

Der Mac mini M6 hat 16 GB (`specs\mac-mini\einrichtung.md`), CPU und GPU teilen sie sich. Die Linux-VM hält im Alltag 8 GB. Für die Ausstellung muss sie auf 3 GB, sonst passt der Rest nicht. Dieser Schalter ist offen in `specs\wwww-main\kette-entwurf.md`.

Zusammen sind es etwa 13 GB mit Qwen 2B und etwa 14 GB mit 4B, geschätzt. Die Werte pro Teil stehen seit 2026-10-16 mit RAM, GPU und CPU in `kommunikation.md` unter „Was wo läuft“, bei jedem Wert, ob er gemessen oder geschätzt ist. Die Einzelheiten der Messungen vom 2026-10-13 stehen in `specs\wwww-main\kette-entwurf.md`.

---

## Was offen ist

- **Welche zwei Pole das Handy trägt.** a · Saxophon ↔ klassische Samples. b · Saxophon ↔ Sprechstimme. c · nur die Stimme. Unbeantwortet.
- **Ob zwei RAVE-Modelle gleichzeitig auf einem Handy laufen.** Gemessen ist ein Modell mit etwa 10 % CPU auf dem Desktop, auf dem Handy nichts.
- **Ob alles in die 16 GB passt.** Die Bilanz unter „Speicher auf dem Mac mini“ ist zur Hälfte geschätzt.
- **Ob RT2 auf einzelne Wörter hörbar reagiert**, etwa auf „Widder“ oder „Saturn“, und in welcher Sprache. Das zeigt ein Test auf dem Mac mini.
- **Welche Quellen ACE-Step Cover bekommt.** Cover behält die Melodie. Ein Madonna-Sample als Quelle bliebe erkennbar, auch mit ganz anderem Klang.
- **Ob Magenta RT2 Base (2,4 Mrd. Parameter) statt Small auf dem M6 in Echtzeit läuft.** Small ist festgelegt. Der Test steht in `specs\wwww-main\kette-entwurf.md`.
- **Ob `mrt2~` die Gewichte der Stil-Vorgaben als Max-Nachricht annimmt**, und wie viele Vorgaben es zugleich mischt.
- **Wie RT2 die ☉ mischt.** Vorschlag: Jeder der 12 Punkte behält den letzten ☉, der dort geschrieben wurde. RT2 mischt diese Prompts, gewichtet nach der Zahl der Handys am Punkt.
- **Welches Modell transkribiert.** Zuerst Apple SpeechTranscriber testen: laut Apple für „long-form and distant audio, such as lectures, meetings, and conversations“ gebaut, vom System verwaltet, ohne Max-Objekt, also über ein kleines Swift-Programm. Rückfall ist Whisper large-v3-turbo (1,61 GB). Parakeet v3 (2,51 GB) rechnet schneller, braucht aber mehr Speicher.
- **Welches Sprachmodell den ☽ schreibt.** Test: ein Gespräch von 4 Minuten mit dem Einverständnis aller, die sprechen. Dasselbe Transkript und dieselben Prompts gehen an Qwen 3.5 0.8B, 2B und 4B in 4 Bit und an Apples Sprachmodell. Geprüft wird: Deutsch, zwei bis vier Sätze, zitiert niemanden, Dauer, Speicher. Das kleinste Modell, das nie zitiert, gewinnt; ein Zitat stünde öffentlich in der Historie. Qwen hat Vorrang vor Apple: Apples Filter lehnen laut Entwicklern im Apple-Forum auch Zusammenfassungen ab, ein abgelehnter ☽ fehlt in den 360 des Tages, und das Modell kann sich mit einem macOS-Update ändern. Qwen 0.8B, 2B und 4B liegen auf dem PC in `zaehlen\modelle\einzeln\`. Der Ablauf steht in `handoffs\2026-10-16-wwww-prototyp-mond.md`.
- **Ob SA3 Small einen Fang als Startpunkt nimmt.** Audio-zu-Audio geht bei SA3 grundsätzlich, mit der MLX-Laufzeit ist es ungeprüft.
- **Ob SA3 Medium statt Small live antwortet**, offen in `specs\wwww-main\kette-entwurf.md`.
