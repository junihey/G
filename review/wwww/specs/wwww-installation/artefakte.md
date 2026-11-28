---
tags: [spec, wwww-installation, wwww-rnbo, modelle, artefakte]
created: 2026-10-03
topic: 'Wie wwww die Artefakte der Audio-to-Audio-Modelle hoerbarer macht -- welches Artefakt, welche Methode, und wie sie in Max/MSP, RNBO und Python umgesetzt wird'
verification: 'Ziel vom Nutzer im Gespraech am 2026-09-30 und 2026-10-03. Artefakte und die ersten sieben Methoden aus specs\wwww-rnbo\raw\20260808 infos allgemein.md, Abschnitt "ki qualitaet idee". Parameterwerte und die Methoden ab "Weitere Methoden" aus denselben Sitzungen vorgeschlagen, nicht bestaetigt. FFT im Browser mit RNBO vom Nutzer am 2026-10-03 bestaetigt. Werte zu RAVE v1 aus specs\wwww-rnbo\raw\rave-rnbo-web.zip, web\model\dummy.json und README.md. Umsetzung in Max/MSP am 2026-10-03 auf Wunsch des Nutzers ergaenzt, Objektnamen aus dem Gedaechtnis, nicht in Max geprueft. Am 2026-10-03 aus specs\wwww-rnbo nach specs\wwww-installation verschoben. Nichts gebaut, nichts gehoert.'
updated: 2026-11-04
---

# Artefakte — die Fehler der Modelle hörbar machen

Stand 2026-11-04. **Nichts davon ist gebaut oder gehört.**

> [!abstract] Jede Methode nimmt eine bestimmte Schwäche eines Modells und verstärkt sie, bis man sie hört
> Eine Methode, die nur „verzerrt“, ohne eine Schwäche zu treffen, gehört nicht hierher. Unten stehen sieben Artefakte, vier Modellarten und 16 Methoden. Das Bild zeigt sechs Artefakte mit ihrer Methode, dazu das Residuum, das alles hörbar macht. Festgelegt sind nur das Ziel und die Umgebungen, alles andere ist ein Vorschlag.
>
> ```mermaid
> flowchart LR
>   A0["alles, was das Modell<br/>verändert hat"] --> M0[Residuum]
>   A1[Codec-Schmieren] --> M1[Codec-Rundreisen]
>   A2["harter<br/>Frequenzschnitt"] --> M2["Exciter an der<br/>Frequenzkante"]
>   A3["verwaschene<br/>Transienten"] --> M3["Transienten und<br/>Töne trennen"]
>   A4[Pseudo-Stereo] --> M4["Mid/Side-Spreizung"]
>   A5[Tonhöhen-Eiern] --> M5["Tonhöhendifferenz<br/>verstärken"]
>   A6["Brüche an<br/>Chunk-Grenzen"] --> M6["Chunk-Grenzen<br/>loopen"]
> ```

^blick

**Was hier steht:** welche Artefakte Audio-to-Audio-Modelle erzeugen, mit welchen Methoden man sie verstärkt und mit welchen Werten man anfängt. Die Methoden sind allgemein beschrieben. Wie jede in Max/MSP, in RNBO und in Python aussieht, steht in der Tabelle „Umsetzung“.

**Was hier nicht steht:** welches Modell auf welchem Rechner von wwww rechnet. Das regelt `modelle.md`. Wie die Artefakte gemessen werden, steht als Rohmaterial in `specs\wwww-rnbo\raw\20260808 infos allgemein.md` unter „ki qualität idee“.

**Verwandt:** `modelle.md` (die Modelle und ihre Rechner), `artefakte-digital.md` (die Artefakte des Digitalen, Aliasing zuerst), `teppich.md` (wohin die Antworten der Modelle gehen), `katalog\patches\` (Eingangsmaterial für RAVE), `specs\wwww-rnbo\raw\rave-rnbo-web.zip` (RAVE v1 im Browser).

---

## Festgelegt

| Was | Wie | Seit |
|---|---|---|
| Ziel | Die Artefakte der Audio-to-Audio-Modelle sollen hörbarer werden, nicht verschwinden. | 2026-09-30 |
| Umgebungen | Die Methoden gelten allgemein, nicht nur für RNBO. Max/MSP lokal ist gleichberechtigt. | 2026-10-03 |
| FFT in RNBO | geht, auch im Browser | 2026-10-03 |

---

## Vorgeschlagen, nicht bestätigt

### Die Artefakte

| Artefakt | Woher es kommt | Woran messbar |
|---|---|---|
| Codec-Schmieren, metallisch und „unter Wasser“ | Der Codec oder der Autoencoder kann feine Details nicht beschreiben. | Spektrale Distanz, FAD |
| Harter Frequenzschnitt | Die Samplerate des Modells: Ein 32-kHz-Modell hat nichts über 16 kHz. | Spektrogramm |
| Verwaschene Transienten | Ein Latent-Frame umfasst viele Samples. Ein Anschlag wird über den ganzen Frame verteilt. | Onset-Abweichung |
| Pseudo-Stereo | Das Modell rechnet Mono oder erfindet die Unterschiede zwischen den Kanälen. | Korrelation L/R |
| Tonhöhen-Eiern | Das Modell trifft die Grundfrequenz nur ungefähr. | F0-Abweichung in Cent |
| Halluzinierte, stimmähnliche Texturen | Das Modell füllt Lücken mit Mustern aus seinen Trainingsdaten. | Hörtest |
| Brüche an Chunk-Grenzen, Drift | Lange Stücke entstehen aus Fenstern fester Länge. Das Modell vergisst, was vor dem Fenster lag. | Chroma und Lautheit über die Zeit |

### Die Modellarten

Die Methoden passen zu verschiedenen Arten von Modellen. Die Beispiele stammen aus `modelle.md`.

| Art | Beispiele | Was man daran greifen kann |
|---|---|---|
| Autoencoder | RAVE, AFTER | den Latent zwischen Encoder und Decoder, Frame für Frame |
| Diffusion | Stable Audio 3, ACE-Step | Schritte, Guidance, denoise, Seed, Prompt |
| Streaming-Generator | Magenta RT2 | den Kontext, die Stil-Vorgabe, das zurückgeführte Audio |
| Codec | EnCodec, DAC | die Zahl der RVQ-Stufen |

### Die Methoden im Überblick

| Methode | Macht hörbar | Modellart |
|---|---|---|
| Residuum | alles, was das Modell verändert hat | alle |
| Feedback-Schleife | die Eigenheiten des Modells, aufgeschaukelt | alle |
| Modell ausreizen | die Rohform und die Ränder des Modells | Diffusion, Autoencoder |
| Codec-Rundreisen | Codec-Schmieren | Codec, Autoencoder |
| Exciter an der Frequenzkante | Frequenzschnitt | alle |
| Mid/Side-Spreizung | Pseudo-Stereo | alle mit Stereo-Ausgabe |
| Tonhöhendifferenz verstärken | Tonhöhen-Eiern | alle |
| Chunk-Grenzen loopen | Brüche an Chunk-Grenzen | Diffusion, Streaming |
| Seeds übereinander | die Unentschlossenheit des Modells | Diffusion |
| Kreuzsynthese | den Zwischenzustand zwischen Original und Modell | alle |
| Testsignale statt Musik | wie das Modell auf etwas reagiert, das es nie gesehen hat | Autoencoder, Streaming |
| Latent-Eingriffe | die Ordnung im Latent-Raum | Autoencoder |
| Fremder Decoder | dass Encoder und Decoder nur zueinander passen | Autoencoder |
| Zeitlupe | das Frame-Raster | alle |
| Leise Anteile hochziehen | Artefakte, die in den Pausen liegen | alle |
| Transienten und Töne trennen | verwaschene Transienten | alle |

### Umsetzung

**Max/MSP** heißt: lokal, live, Modelle über `nn~` (RAVE, AFTER) und `mrt2~` (Magenta RT2), Analyse über FluCoMa. **RNBO** heißt: als Export, etwa im Browser. RNBO kann kein `nn~`, im Browser läuft RAVE daneben in onnxruntime-web. **Python** heißt: offline, Datei rein, Datei raus.

Die Objektnamen sind nicht in Max geprüft.

| Methode | Max/MSP | RNBO | Python |
|---|---|---|---|
| Residuum | `delay~` für die Latenz; `pfft~` mit `cartopol~`, Beträge abziehen | FFT von RNBO, sonst wie in Max | `librosa.stft`, `scipy.signal.correlate` für die Latenz |
| Feedback-Schleife | `tapin~`/`tapout~` vom Ausgang von `nn~` oder `mrt2~` zurück an den Eingang | Ausgang des Decoders zurück in den Encoder, in JS | Schleife über Dateien, jede Runde gespeichert |
| Modell ausreizen | bei `nn~`: Latent-Kanäle mit `*~` skalieren; Diffusion nicht | Latent-Regler über den Bereich hinaus | Schritte, CFG, denoise, slerp in `stable-audio-tools` oder ACE-Step |
| Codec-Rundreisen | nur, wenn es einen TorchScript-Export für `nn~` gibt, offen | – | `encodec`, `descript-audio-codec` |
| Exciter an der Frequenzkante | `svf~` als Hochpass, `overdrive~` oder `tanh` in `gen~` | Filter und `tanh` in gen | `scipy.signal`, `numpy.tanh` |
| Mid/Side-Spreizung | `+~`, `-~`, `*~` oder `gen~` | dasselbe | `numpy` |
| Tonhöhendifferenz verstärken | `fluid.pitch~` auf beiden Signalen, Differenz in `gen~`, `pitchshift~` oder `retune~` | Tonhöhe schätzen in gen, aufwendig | `librosa.pyin` oder CREPE, `pyrubberband` oder `parselmouth` |
| Chunk-Grenzen loopen | `groove~` mit Loop-Punkten, Granulator in `gen~` oder mit `mc.play~` | Buffer und Granulator in gen | Ausschnitt schneiden und loopen |
| Seeds übereinander | Dateien aus Python in `mc.play~` übereinander | Dateien abspielen | Generieren mit 8–16 Seeds |
| Kreuzsynthese | `pfft~`: Betrag von A, Phase von B; `fluid.audiotransport~` zum Morphen; `fluid.bufnmfcross~` | FFT von RNBO | `librosa`, SPEAR, Zynaptiq Morph |
| Testsignale statt Musik | `noise~`, `click~`, `cycle~` mit `line~` als Sweep, in `nn~` | dieselben Quellen in RNBO, in den Encoder | Testsignale erzeugen und durchschicken |
| Latent-Eingriffe | `nn~ encode` gibt jeden Latent als eigenen Kanal aus: `sah~`, `round~`, `noise~`, Kanäle tauschen, dann `nn~ decode` | nur die Regler, siehe „RAVE im Browser-Prototyp“ | `model.encode`, Tensor ändern, `model.decode` |
| Fremder Decoder | `nn~ A encode` in `nn~ B decode` | zwei Modelle im Worker | wie in Max |
| Zeitlupe | `groove~` mit `@timestretch 1` oder ein Granulator mit festen Kornpositionen | Granulator in gen | `librosa.effects.time_stretch` oder Paulstretch |
| Leise Anteile hochziehen | `omx.comp~` mit Aufwärts-Kompression, `fluid.ampgate~` invertiert | Kompressor in gen | `numpy`, Hüllkurve und Gain |
| Transienten und Töne trennen | `fluid.hpss~` live, `fluid.bufhpss~` auf Buffern | – | `librosa.decompose.hpss` |

### Residuum

Das Original wird zeitlich auf den Output ausgerichtet und davon abgezogen. Übrig bleibt nur, was das Modell verändert hat.

**Ausrichten:** Die Latenz des Modells wird per Kreuzkorrelation gemessen, das Original um genau diese Zeit verzögert. Schon ein Versatz von wenigen Samples lässt Kammfilter statt Residuum übrig.

**Phasenfrei:** Die meisten Modelle erzeugen die Phase neu. Eine Subtraktion im Zeitbereich löscht dann kaum etwas aus. Stattdessen werden die Beträge im Spektrum abgezogen: STFT von beiden, Betrag Output minus Betrag Original pro Band, mit der Phase des Outputs zurückgerechnet. Positive Werte zeigen, was das Modell hinzugefügt hat. Negative Werte zeigen, was es weggelassen hat. Beides lässt sich als eigene Spur ausgeben.

**Als Steuersignal:** Die Energie des Residuums pro Frame ist eine Kurve. Sie kann jede andere Methode hier steuern, zum Beispiel die Stärke der Mid/Side-Spreizung.

### Feedback-Schleife

Der Output geht immer wieder als Input ins Modell, wie in Luciers „I am sitting in a room“. Nach einigen Runden bleibt fast nur noch übrig, was das Modell selbst mitbringt.

Bei einem Autoencoder wie RAVE geht das live mit einer Verzögerung zwischen Ausgang und Eingang. Ein Gain knapp unter 1 verhindert, dass die Schleife explodiert. Bei Magenta RT2 hängt es daran, ob RT2 Audio Injection kann, offen in `modelle.md`. Bei Diffusion ist es die Kette aus `modelle.md`: jede Ausgabe mit kleinem denoise als nächste Eingabe. Jede Runde wird gespeichert, damit sich der Verlauf abspielen lässt.

### Modell ausreizen

**Wenige Sampling-Schritte.** Ein Diffusionsmodell entrauscht in vielen Schritten. Bei 1–2 Schritten bricht es mitten im Entrauschen ab: verschmierte Anschläge, metallischer, körniger Klang. Eine Reihe 1, 2, 4, 8 zeigt, wie der Klang entsteht.

**Extreme Guidance.** Die CFG bestimmt, wie stark das Modell dem Prompt folgt. Üblich sind 3–7. Bei 15–30 übersteuert der Output, alles Typische am Prompt wird übertrieben. Negative Werte schieben vom Prompt weg.

**Latents skalieren.** Der Latent wird vor dem Decoder mit 1,5–3 multipliziert. Solche Werte hat der Decoder nie gesehen. Er antwortet mit Brummen, Pfeiftönen und einer Verzerrung, die für ihn typisch ist.

**Weit entfernte Prompts interpolieren.** Zwei Embeddings wie „Streichquartett“ und „Presslufthammer“ werden per slerp gemischt. In der Mitte liegen kaum Trainingsdaten, dort rät das Modell.

**strength oder denoise.** Bei 0,1 bleibt das Original fast unverändert, bei 0,95 bleibt nur der Umriss. Das ist der Fächer aus `modelle.md`. Bei ACE-Step Cover heißt der Regler `audio_cover_strength`.

### Codec-Rundreisen

EnCodec und DAC beschreiben Audio in mehreren RVQ-Stufen. Jede Stufe beschreibt den Fehler der vorherigen feiner.

| Codec | Einstellung für grobe Artefakte |
|---|---|
| EnCodec 24 kHz | `bandwidth=1.5`, das sind 2 Codebooks |
| DAC | `n_quantizers=1` oder `2` |

Eine Rundreise klingt nur etwas dumpf. Der Effekt entsteht durch Wiederholung, 10 bis 50 Durchgänge. Jeder verliert etwas anderes, wie beim Kopieren einer Kassette von einer Kopie. Jede Generation wird einzeln gespeichert.

Ein RAVE-Modell ist selbst ein Codec. Die Rundreise durch `nn~` in einer Schleife ist dieselbe Methode, live.

### Gezielte Nachbearbeitung

**Exciter an der Frequenzkante.** Die Kante liegt bei der halben Samplerate des Modells: 8 kHz bei 16 kHz, 16 kHz bei 32 kHz. Ein Hochpass knapp darunter, etwa bei 7 kHz für ein 16-kHz-Modell, schneidet den Bereich heraus. Er wird gesättigt und laut zurückgemischt. Die Obertöne entstehen genau dort, wo der Klang abbricht.

**Mid/Side-Spreizung.** Mid = (L+R)/2, Side = (L−R)/2. Side wird um 6–12 dB angehoben. Deutlicher noch: Side solo. Dann klingt nur, was das Modell zwischen den Kanälen erfunden hat.

**Tonhöhendifferenz verstärken.** Die Grundfrequenz von Input und Output wird pro Frame geschätzt. Die Differenz in Cent wird mit 5–10 multipliziert und als zeitlich veränderliche Tonhöhenverschiebung auf den Output gelegt. Aus 3 Cent Drift werden 30 Cent hörbares Eiern.

### Nähte und Varianz ausstellen

**Chunk-Grenzen.** Die Grenzen folgen aus der Fensterlänge des Modells. 50–200 ms um eine Grenze werden geloopt oder granuliert, mit Körnern von 20–80 ms an zufälligen Positionen. Bei Magenta RT2 sind das die 2-s-Stücke aus `modelle.md`.

**Seeds übereinander.** Derselbe Input, derselbe Prompt, 8–16 Seeds. Leise übereinandergelegt verstärkt sich, worin alle übereinstimmen. Wo sie auseinandergehen, entsteht ein Chor. Jeder Seed bekommt eine eigene Position im Stereofeld. Zwei Seeds, einer phaseninvertiert, lassen nur ihren Unterschied übrig.

### Kreuzsynthese

**Vocoder.** Das Original ist der Modulator und liefert die spektrale Hüllkurve, die KI-Version der Träger. Umgekehrt geht es auch.

**Spektrales Morphen.** STFT von beiden, die Beträge werden im Lauf der Zeit von 0 auf 1 übergeblendet.

### Weitere Methoden

**Testsignale statt Musik.** Das Modell bekommt, was es nie gesehen hat: Stille, einen Sinus-Sweep von 20 Hz bis 20 kHz, eine Klickfolge, weißes Rauschen. Aus Stille macht ein Autoencoder oft einen eigenen Ruheklang. Das ist das, was das Modell für „nichts“ hält. Der Sweep zeigt die Frequenzkante. Die Klickfolge zeigt, wie stark ein Anschlag verschmiert. Für den Eurorack-Weg sind die Testsignale eigene Patches in `katalog\patches\`.

**Latent-Eingriffe.** Ein Autoencoder rechnet pro Frame einen Vektor aus mehreren Latent-Dimensionen. Wie viele, legt das Modell fest. In Max gibt `nn~` mit der Methode `encode` jede Dimension als eigenen Signalkanal aus, `decode` nimmt sie wieder an. Dazwischen ist jeder Eingriff ein MSP-Objekt:
- **Einfrieren:** einen Latent-Frame halten. Der Decoder erzeugt dann einen stehenden Klang aus genau diesem Zustand.
- **Quantisieren:** die Werte auf wenige Stufen runden, etwa 4 pro Dimension. Der Klang springt zwischen Zuständen, statt zu gleiten.
- **Dimensionen tauschen:** zwei Kanäle vertauschen. Was vorher Lautheit steuerte, steuert dann vielleicht Helligkeit.
- **Rauschen addieren:** kleines Rauschen auf jede Dimension. Es zeigt, wie empfindlich jede ist.
- **Modulieren:** ein LFO auf eine einzelne Dimension. Er zeigt, was diese Dimension bedeutet.

**Fremder Decoder.** Encoder von Modell A, Decoder von Modell B. Das geht nur, wenn beide gleich viele Latent-Dimensionen haben. Die Dimensionen bedeuten in den beiden Modellen etwas anderes, das Ergebnis klingt nach keinem der zwei. Passt zur offenen Frage nach den zwei Polen in `modelle.md`.

**Zeitlupe.** Der Output wird 4- bis 8-fach verlangsamt, mit einem Verfahren ohne eigene Glättung, etwa einem Granulator mit festen Kornpositionen. Das Frame-Raster des Modells wird hörbar. Ein Frame umfasst bei RAVE die Kompressionsrate in Samples, oft 2048. Bei 48 kHz sind das 42,7 ms, also etwa 23 Frames pro Sekunde.

**Leise Anteile hochziehen.** Viele Artefakte liegen in den Pausen und im Ausklang, unter dem Pegel der Musik. Eine Aufwärts-Kompression um 30–40 dB oder ein invertiertes Gate, das nur Anteile unter etwa −40 dBFS durchlässt, holt sie nach vorn.

**Transienten und Töne trennen.** HPSS zerlegt Original und Output in einen harmonischen und einen perkussiven Teil. Der perkussive Teil des Outputs neben dem des Originals zeigt am deutlichsten, wie viel vom Anschlag verloren ging.

### RAVE im Browser-Prototyp

Werte aus `specs\wwww-rnbo\raw\rave-rnbo-web.zip`, Datei `web\model\dummy.json` und `README.md`:

| Was | Wert |
|---|---|
| Latent-Dimensionen | 16 |
| Regler | 4, z1 bis z4: die vier stärksten PCA-Achsen des Latent-Raums |
| Bereich je Regler | ±3 |
| Frame | 2048 Samples bei 48 kHz, 42,7 ms |

Bei Klangübertragung addieren sich die Regler als Offset auf die kodierten Latents. Ohne Quelle setzen sie die Latent-Werte direkt. Latents skalieren heißt hier: den Reglerbereich über ±3 hinaus öffnen, etwa auf ±9. Dimensionen tauschen geht über die Regler nur unter den vier PCA-Achsen. Die übrigen 12 Dimensionen sind nur in `rave-worker.js` vor dem Decoder erreichbar. Jedes Modell rechnet seine PCA-Achsen für sich, also bedeutet z1 in zwei Modellen etwas anderes.

---

## Was für den Bau gilt

- **Jede Methode nennt ihr Artefakt.** Eine neue Zeile in der Übersicht braucht einen Eintrag in „Macht hörbar“ und eine Zeile in „Umsetzung“.
- **Jeder Zwischenschritt wird gespeichert** bei Methoden mit Wiederholung: Feedback-Schleife, Codec-Rundreisen, Kette. Der Verlauf ist das Material.
- **Residuum und Tonhöhendifferenz brauchen das ausgerichtete Original.** Die Latenz jedes Modells wird einmal gemessen und festgehalten.

## Bewusst nicht drin

| Draußen | Warum |
|---|---|
| Artefakte entfernen oder glätten | Das Ziel ist das Gegenteil. |
| Verzerrung ohne Bezug zu einem Modell, etwa Bitcrusher | Sie macht keine Schwäche des Modells hörbar, sondern erzeugt eine eigene. Als Grenze des Rasters steht der Bitcrusher in `artefakte-digital.md`. |

## Was offen ist

- **Welche Methoden live laufen und welche nur offline.** Die Tabelle „Umsetzung“ zeigt, was wo möglich ist, nicht was wwww nimmt.
- **Ob es EnCodec oder DAC als TorchScript für `nn~` gibt.** Dann liefen die Codec-Rundreisen live in Max.
- **Ob die Eingriffe im Browser auch die 12 Dimensionen ohne Regler erreichen sollen.** Das hieße, `rave-worker.js` zu ändern. In Max über `nn~` sind ohnehin alle Dimensionen da.
- **Die Latenz jedes Modells**, für Residuum und Tonhöhendifferenz.
- **Ob Magenta RT2 Audio Injection kann**, offen in `modelle.md`. Davon hängt die Feedback-Schleife mit RT2 ab.
- **Welche Methode zu welchem Motiv gehört.** Die Motive stehen in `modelle.md`, die Zuordnung fehlt.
