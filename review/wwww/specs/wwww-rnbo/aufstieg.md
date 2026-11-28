---
tags: [spec, wwww-rnbo, aufstieg]
created: 2026-11-12
topic: 'Wie der Aufstieg durch die Ebenen klingt -- Stille auf der Ebene, die Felder im verschachtelten Allpass-Netz, Saeulen ueber den Arbeiten, der Spalt und der Ort des Schnatz-Klangs'
verification: 'Vom Nutzer am 2026-11-11 und 2026-11-12 Frage fuer Frage entschieden, ausgehend von handoffs\2026-11-10-wwww-ideen-weiter.md, jede Antwort nach einer Hoerprobe (review\hoerproben\aufstieg.html in wwww-main). Die Werte der Hoerprobe sind Startwerte, nicht gestimmt. Nichts davon ist in RNBO gebaut oder auf einem Handy gemessen.'
---

# Aufstieg — wie die Ebenen klingen

Stand 2026-11-12. **Nichts davon ist gebaut.**

> [!abstract] Auf der Ebene schweigt alles, an den Arbeiten klingt alles pur
> Die Felder der Arbeiten laufen durch ein verschachteltes Allpass-Netz. Auf einer Ebene ist es still, an den Arbeiten ist das Netz umgangen, dazwischen klingt es metallisch. Jedes Stockwerk darüber hat eine Stufe mehr, kürzere Verzögerungen und eine weitere, langsamere Modulation. Nur im Spalt einer geteilten Ebene hört man den Wechsel.
>
> ```mermaid
> flowchart TD
>   A["Arbeiten<br/>pur"] -->|Kamm wächst| E1["Ebene 1<br/>still"]
>   E1 --> S2["Stockwerk 2<br/>2 Stufen"]
>   S2 --> E2["Ebene 2<br/>still"]
>   S2 -.->|Spalt| SP["kein Halt<br/>Gleiten +1 Stufe"]
>   SP -.-> S3
>   E2 --> S3["Stockwerk 3<br/>3 Stufen"]
>   S3 --> E3["Ebene 3<br/>still"]
> ```

^blick

**Was hier steht:** was man hört, wenn man durch die Ebenen aus `specs\wwww-threejs\welt.md` steigt, mit den Startwerten der Hörprobe.

**Was hier nicht steht:** wie die Ebenen aussehen, das steht in `welt.md`. Gesten, Felder und ihre Mischung stehen in `specs\wwww-threejs\steuerung.md`. Der Schnatz klingt nach `welt.md`, „Sein Klang“; hier steht nur, wo er läuft.

**Verwandt:** `archive\handoffs\2026-11-05-wwww-ideen-moeglichkeiten.md`, Abschnitt 10 (alle Möglichkeiten, aus denen hier gewählt ist), `learning\max-msp\fdn-2-allpass-und-diffusion.md` (der Allpass und seine Verschachtelung), `specs\wwww-main\review\hoerproben\aufstieg.html` (die Hörprobe).

**Zwei Wörter:**

- **Stockwerk** heißt der Raum zwischen zwei Ebenen, und der unterste zwischen den Arbeiten und Ebene 1.
- **Zwischenraum-Preset** bleibt, was es in `steuerung.md` ist: der Klang zwischen den Feldern. Mit den Stockwerken hat es nichts zu tun.

---

## Der Wortlaut

Aus der Liste des Nutzers vom 2026-11-05: „Bewegung des Aufsteigens, in dessen Ebenen sich auch nochmal der Ton ändert (nested-feedback-feedforward-allpass-network). Auf den Ebenen kein Ton, dazwischen Ton.“

**Das Netz bearbeitet die Felder, es erzeugt keinen eigenen Klang.** Die Windschicht aus `steuerung.md` hängt an der Geschwindigkeit, nicht an der Höhe, und gehört nicht hierher.

## Der Aufbau

| Punkt | Festgelegt |
|---|---|
| **Wo die Arbeiten stehen** | alle zwölf auf einer Höhe, im untersten Stockwerk |
| **Ebenen** | 3, alle über den Arbeiten |
| **Felder über den Arbeiten** | Jede Kugel aus `steuerung.md` setzt sich nach oben als Säule mit demselben Radius fort. Man hört die Arbeit, über der man schwebt. |
| **Leiser nach oben** | je Stockwerk ein Viertel, wie das Licht in `welt.md` nach oben schwächer wird |
| **Höhe gemessen** | von der gewölbten Ebene aus, nicht vom Boden. Die Stille liegt genau auf den Fäden. Wer geradeaus fliegt, kreuzt die Bögen und hört Klang, Stille, Klang. |

## Die Höhe im Klang

`h` zählt in Ebenen: Die Arbeiten stehen bei `h` = 0,5, Ebene `n` liegt bei `h` = `n`. Gemessen wird senkrecht zur Ebene unter dem eigenen Standort, also mit ihrer Wölbung.

```
Lautstärke = sin²(π·h) · (1 − 0,25·s)        s = 0, 1, 2 für Stockwerk 1, 2, 3
Kamm       = sin²(2π·h)   im Stockwerk 1     0 an Ebene und Arbeiten, 1 auf halbem Weg
           = sin²(π·h)    darüber            1 in der Mitte des Stockwerks
b          = −g + 2g·Kamm, g = 0,7           Kamm 0: Allpass, flach. Kamm 1: Kamm, Spitze +15 dB
```

| Ort | Was man hört |
|---|---|
| **Auf einer Ebene** | nichts, auch die Felder schweigen |
| **An den Arbeiten** | die Felder ganz pur. Das Netz ist umgangen, nicht nur flach gestellt: Eine flache Stufe gäbe Klicks leise Echos. |
| **Auf halbem Weg zwischen Arbeiten und Ebene 1** | am metallischsten |
| **In der Mitte von Stockwerk 2 und 3** | am metallischsten, es steht dort keine Arbeit |

Die Regel aus `steuerung.md`, dass der Standpunkt die Felder hörbar macht, gilt damit nur zwischen den Ebenen. Die Spitze von +15 dB braucht einen Pegelausgleich, die Hörprobe teilt durch `1 + 1,8·Kamm`.

## Was jedes Stockwerk anders macht

| Regler | Festgelegt | Startwert der Hörprobe |
|---|---|---|
| **Tiefe der Verschachtelung** | eine Stufe mehr pro Stockwerk | Stockwerk 1: eine Stufe innen, 2: zwei, 3: drei. Eine neue Stufe beginnt bei `g` = 0 und geht langsam auf, so knackt nichts. |
| **Verzögerungen** | jedes Stockwerk eigene, nach oben kürzer, also höher | außen 4,5 ms (Kamm bei 220 Hz), innen 67, 43, 29 Samples bei 48 kHz, alle mit `g` = 0,7. Faktor je Stockwerk 1 · 0,75 · 0,5, also eine Quarte und eine Oktave höher. |
| **Modulation** | Jede Verzögerung wandert langsam hin und her, jede Stufe in eigenem Tempo. Nach oben weiter und langsamer. | Weite ±2 % unten bis ±10 % oben. Tempo unten 0,21 bis 0,87 Hz, oben 30 % davon. |

**Die Verzögerungen wechseln auf der Ebene, also in der Stille.** Deshalb knackt der Wechsel nicht, und man hört ihn nicht.

## Aufstieg und Abstieg

**Sie klingen gleich.** Die Unterschiede durch Tiefe, Verzögerungen und Modulation reichen (Nutzer, 2026-11-11). Das Motiv „Auf- und Absteigendes (Bruckner)“ in `specs\wwww-main\motive.md` bekommt deshalb hier keinen Ort.

Zurückgestellt, ausdrücklich festzuhalten:

| Möglichkeit | Aufstieg | Abstieg | Was dazukäme |
|---|---|---|---|
| **Doppler auf den Verzögerungen** | alle Verzögerungen kürzer, der Kamm steigt | länger, der Kamm fällt | nichts, nur die Steiggeschwindigkeit greift auf die Verzögerungen. Im Stehen verschwindet es. In der Hörprobe als „Auf und ab“ eingebaut. |
| **Reihenfolge der Verschachtelung** | die neue Stufe kommt ganz innen dazu | die äußerste innere Stufe geht zuerst | nichts. Sagt nur „anders“, nicht „hoch“ oder „runter“. |
| **Barberpole-Phaser** | Kerben im Spektrum wandern endlos nach oben | endlos nach unten | ein zweites Netz aus etwa 16 Allpässen erster Ordnung |

## Der Spalt

Sinkt der Regler „Figur“ einer Ebene unter 1, öffnet sich in ihrer Mitte ein Spalt (`welt.md`).

- **Im Spalt gibt es keine Stille.** Wer hindurchsteigt, hört den Klang weiterlaufen.
- **Die Verzögerungen gleiten hörbar** vom Stockwerk darunter zum Stockwerk darüber. Der Spalt ist die einzige Stelle, an der man den Wechsel hört.
- **Eine Stufe mehr öffnet sich**, als die beiden Stockwerke daneben haben: die „Ebene in der Ebene“ aus `welt.md`.

## Wo es läuft

**Netz, Felder und Schnatz laufen im selben RNBO-Patch auf dem Handy.** JS schickt Höhe, Kamm, Tiefe und Faktor, für den Schnatz die Nummern der Scheiben aus der Karte (`welt.md`, „Der Korpus“). Die OpenUtau-Samples müssen als Puffer in den RNBO-Export. Ihre Größe ist unbekannt, solange es die Samples nicht gibt. Die erste Stufe aus `welt.md`, die Kugel ohne Samples, braucht keine Puffer.

## Offen

- Läuft der Schnatz durch das Netz des Stockwerks, oder klingt er daran vorbei?
- Klingen die frühen Reflexionen im Mikroraum durch das Netz?
- Was fünf verschachtelte Stufen mit gleitenden Verzögerungen auf einem Handy kosten, ist nicht gemessen.
- Die Startwerte sind auf einem Platzhalter-Akkord gehört, nicht auf den echten Presets.
