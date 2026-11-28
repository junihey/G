---
tags: [spec, wwww-rnbo, netz]
created: 2026-11-27
topic: 'Wie die OpenUtau-Samples auf dem Handy durch Schnatz, Loris, RAVE und FFT laufen -- die Mitte eines Felds bearbeitet, der Rand faerbt, die Grenze verbindet, mit einer Obergrenze fuer die Rechenlast'
verification: 'Vom Nutzer am 2026-11-27 im Gespraech festgelegt: der Schnatz spielt die Samples unbearbeitet, jedes Feld hat Loris, RAVE oder beide, FFT-Effekte am Rand, FFT-Verbinder zwischen zwei Feldern. Die drei Regeln, die Zerlegung in Feldern mit beiden und der Verbinder nach Flugrichtung kommen von Claude; der Nutzer nahm sie mit "genau so" an. Nichts davon ist gebaut oder auf einem Handy gemessen.'
---

# Netz — wie die Samples durch die Felder laufen

Stand 2026-11-27. **Nichts davon ist gebaut.**

> [!abstract] Die Mitte bearbeitet, der Rand färbt, die Grenze verbindet
> Die OpenUtau-Samples sind die Grundlage. Der Schnatz spielt sie unbearbeitet, jedes Feld schickt sie durch Loris, durch RAVE oder durch beide. Am freien Rand eines Felds färbt ein FFT-Effekt, wo sich zwei Felder überlappen, verbindet sie ein FFT-Verbinder. Auf dem Handy läuft nie mehr als ein RAVE und eine FFT zugleich.
>
> ```mermaid
> flowchart TD
>   S["OpenUtau-Samples<br/>und Multiverb"] --> SN["Schnatz<br/>unbearbeitet"]
>   S --> L["Feld<br/>Loris"]
>   S --> R["Feld<br/>RAVE oder beide"]
>   L -->|Überlappen| V["FFT-Verbinder"]
>   R -->|Überlappen| V
>   L -.->|freier Rand| E["FFT-Effekt"]
>   R -.->|freier Rand| E
> ```

^blick

**Was hier steht:** woher der Klang der Handys M1 und M2 kommt, welcher Baustein an welchem Ort rechnet, wie sich zwei Felder verbinden und was höchstens gleichzeitig läuft.

**Was hier nicht steht:** wie die Felder liegen und gemischt werden, das steht in `specs\wwww-threejs\steuerung.md`. Das Allpass-Netz der Stockwerke steht in `aufstieg.md`; es liegt hinter allem, was hier steht. Wie die Samples entstehen, steht in `zaehlen\max-bausteine\gesang\` und im Handoff `handoffs\2026-11-27-gesang-regeln.md`.

**Verwandt:** `specs\wwww-installation\kommunikation.md`, „Was wo läuft“ (die Bausteine des Handys einzeln), `specs\wwww-installation\modelle.md` (RAVE v1 auf dem Handy), `specs\wwww-installation\artefakte.md` (Kreuzsynthese, Residuum), `specs\wwww-threejs\welt.md`, „Sein Klang“ (die Körner des Schnatzes).

---

## Woraus gebaut wird

| Quelle | Was übernommen wird |
|---|---|
| Gespräch mit dem Nutzer, 2026-11-27 | die Samples als Grundlage, der Schnatz unbearbeitet, Felder mit Loris, RAVE oder beiden, Effekte am Rand, Verbinder an der Grenze |
| `specs\wwww-threejs\steuerung.md` | Felder als Kugeln mit Radius, die Gewichte, das Zwischenraum-Preset |
| `aufstieg.md` | das Allpass-Netz am Ende der Kette, die Säulen über den Arbeiten |
| `specs\wwww-threejs\welt.md`, „Sein Klang“ | die Körner des Schnatzes und die Karte, aus der sie kommen |
| `specs\wwww-installation\kommunikation.md`, `modelle.md` | RAVE v1 in onnxruntime-web neben RNBO, Loris spielt Teiltöne aus einer Analyse am PC |
| `specs\wwww-installation\artefakte.md` | Kreuzsynthese und Residuum als Verbinder |
| `raw\20260808 infos allgemein.md`, „fft“ | Bins nach Amplitude sortieren, Phasen für umkehrbares Rauschen, Logik zweier Spektren, Latent Generation |
| `handoffs\2026-11-27-gesang-regeln.md` | die Aufnahmen über den umgebauten Multiverb |

**Was die Vorlagen falsch machten:**

- `kommunikation.md` zählt Loris, RAVE und die FFT-Patches nebeneinander auf. Wie ihre Ströme sich treffen, sagt es nicht.
- `steuerung.md` mischt Presets, also Parameter. Zwei Verarbeitungswege lassen sich nicht als gewichtetes Mittel mischen, dafür braucht es einen Verbinder.
- Die Rechenlast steht dort pro Baustein. Was zählt, ist, was an einem Ort gleichzeitig läuft.

## Die Quelle

**Alles beginnt bei den OpenUtau-Samples aus dem Heft.** Dazu kommen ihre Aufnahmen über den umgebauten Multiverb: Effekte PTR, R-DDL-L, T-DDL und GAT, je drei Stellungen des Potis. Schnatz und Felder greifen auf dieselben Samples zu.

## Die Orte

| Ort | Was klingt |
|---|---|
| **Schnatz** | die Samples unbearbeitet, als Körner. Er ist das klare Original zwischen den verwandelten Feldern, so wie sein Spiegel die fernen Arbeiten klar zeigt (`welt.md`). |
| **Mitte eines Felds** | die Samples durch Loris, durch RAVE oder durch beide |
| **Freier Rand eines Felds** | dazu ein FFT-Effekt |
| **Überlappen zweier Felder** | ein FFT-Verbinder aus beiden Feldern |
| **Zwischenraum, keine Kugel** | das Zwischenraum-Preset aus `steuerung.md`, etwa ein Drone |
| **darüber, je nach Höhe** | das Allpass-Netz aus `aufstieg.md` |

## Die Felder

| Art | Was rechnet |
|---|---|
| **Loris** | Die Teiltöne der Samples sind vorab am PC analysiert. Das Handy spielt sie mit einer Oszillatorbank in RNBO. Loris kann selbst zwischen zwei Analysen morphen. |
| **RAVE** | RAVE v1 als ONNX in onnxruntime-web. Der Weg geht RNBO → JS → RAVE → RNBO. |
| **beide** | Die Zerlegung: Loris trennt jedes Sample am PC in einen Sinus-Teil und einen Rausch-Teil. Der Sinus-Teil spielt in der Oszillatorbank, der Rausch-Teil geht durch RAVE. Ein Feld mit beiden zählt als RAVE-Feld. |

## Drei Regeln

**1. Zwei RAVE-Felder liegen nie nebeneinander.** Felder mit RAVE und Felder nur mit Loris wechseln sich ab. So trifft an jeder Grenze höchstens ein RAVE-Strom auf einen Loris-Strom, und der Verbinder hat immer dasselbe Paar. Ob zwei RAVE-Modelle auf einem Handy laufen, ist ohnehin offen (`modelle.md`). Bei zwölf Punkten passt der Tierkreis dazu: Feuer und Luft wechseln sich mit Erde und Wasser ab.

**2. Höchstens eine FFT zugleich.** Der FFT-Effekt gilt nur am freien Rand, an der Seite ohne Nachbarfeld. Zum Nachbarn hin blendet er aus, und der Verbinder übernimmt.

**3. Der Verbinder klingt nur, wo sich zwei Kugeln überlappen.** Nur dort laufen beide Felder ohnehin. Wo keine Kugel ist, bleibt das Zwischenraum-Preset.

## Die Verbinder

**Die Flugrichtung wählt den Verbinder.** JS kennt sie ohnehin, es kostet also nichts.

| Richtung | Verbinder | Was übrig bleibt |
|---|---|---|
| von Loris zu RAVE | AND | nur, worin beide Spektren übereinstimmen |
| von RAVE zu Loris | XOR | nur, worin sie sich widersprechen |

Dieselbe Grenze klingt hin und zurück anders. Weitere Verbinder für einzelne Grenzen: die Kreuzsynthese, also der Betrag des einen Felds mit der Phase des anderen, und das Residuum, also das Original minus RAVE.

**RAVE ist etwa 2048 Samples zu spät.** Der Verbinder verzögert den Loris-Strom um dieselbe Zeit. Sonst vergleicht er zwei gegeneinander verschobene Spektren.

## Die Effekte am Rand

| Effekt | Was er tut |
|---|---|
| **Bins nach Amplitude sortieren** | die lautesten Bins rücken nach unten, in den Sub-Bereich |
| **Phasen streuen** | macht den Klang zu Rauschen, das sich wieder zurückdrehen lässt |

**Latent Generation ist kein Effekt, sondern die Karte.** Jeder Frame der Samples liegt nach Helligkeit und Energie auf einer xy-Fläche, `fluid.mlpregressor~` füllt die Lücken. Sie wird am PC berechnet. Der Schnatz liest daraus seine Körner (`welt.md`).

## Was höchstens gleichzeitig läuft

Schnatz-Körner, zwei Felder, ein RAVE, eine FFT und das Allpass-Netz. Diese Obergrenze wird auf einem echten Handy neben three.js gemessen, bevor ein Klang gestimmt wird.

## Offen

- **Die Reihenfolge der zwölf Arbeiten im Raum.** Sie entscheidet, welche Felder Nachbarn sind, und muss vor den Verbindern feststehen. Regel 1 verlangt, dass sich RAVE- und Loris-Felder abwechseln.
- Welches Feld welche Art bekommt.
- Wie AND und XOR auf Beträgen genau rechnen: mit einer Schwelle pro Bin oder mit Minimum und Differenz.
- Wie viele Teiltöne die Oszillatorbank auf dem Handy tragen kann.
- Worauf RAVE v1 für das Handy trainiert wird (`modelle.md`).
- Ob der Schnatz durch das Allpass-Netz läuft, offen in `aufstieg.md`.
