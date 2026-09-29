---
tags: [learning, max-msp, gen, fdn]
created: 2026-09-29
topic: 'FDN Teil 2 -- Echodichte, Allpaesse, der mehrkanalige Allpass, der Diffusionsschritt nach Signalsmith mit seinen Varianten, fruehe Reflexionen, Heruntermischen und die Hallfahne'
verification: 'aus specs\wwww-installation\fdn.md (Stand 2026-09-28) umgeschrieben. Signalsmith "Let s Write A Reverb" (PDF in data\scans\mathe\) gelesen; Schroeder, Gardner, Gerzon und Dattorro aus dem Gedaechtnis genannt, nicht nachgelesen; nichts in Max ausprobiert'
---

# FDN 2 — Allpass und Diffusion

Teil 2 von 7 über Feedback Delay Networks. Lies von oben nach unten.

**Setzt Teil 1 voraus:** Delay, Länge `L`, Schleife, Umlauf, Leitung, `N`, Matrix, orthogonal, Energie, Hadamard, Householder, Nachhallzeit `T60`, Echodichte.

**Antwort zuerst:** Ein Hall braucht zwei Dinge: viele Echos und eine lange Fahne. Signalsmith trennt die beiden. Ein **Diffusor** macht aus jedem Echo viele, hat aber keine Fahne. Die Schleife aus Teil 1 macht den Klang lang. Der Diffusor besteht aus Allpässen.

**Was hier nicht steht:** wie man die Mischung stufenlos regelt, das kommt in Teil 3.

## 1 · Wann Echos zu einem Klang verschmelzen

Ab etwa 2000 bis 4000 Echos pro Sekunde hört man keine einzelnen Echos mehr, sondern einen durchgehenden Klang (Signalsmith). Eine Schleife allein erreicht das erst nach vielen Umläufen. Vier Leitungen um 40 ms geben am Anfang nur etwa 100 Echos pro Sekunde, und der Beginn des Halls klingt rau.

## 2 · Der Allpass

Ein gewöhnliches Filter macht manche Frequenzen leiser, ein Tiefpass etwa die Höhen. Ein **Allpass** lässt jede Frequenz gleich laut durch. Er verschiebt die Frequenzen nur verschieden weit in der Zeit. Diese Verschiebung heißt **Phase**.

Ein Klick enthält alle Frequenzen im selben Moment. Nach einem Allpass kommen sie zu verschiedenen Zeiten an, und der Klick verschmiert. Weil jede Frequenz gleich laut bleibt, bleibt die Klangfarbe erhalten.

## 3 · Der Allpass 1. Ordnung

Der einfachste Allpass merkt sich einen einzigen Wert `z`. Pro Sample rechnet er mit dem Koeffizienten `a`, einer Zahl zwischen −1 und 1:

```
v = x − a·z
y = a·v + z
z = v
```

`x` ist das Sample, das hineingeht, `y` das Sample, das herauskommt.

- Bei `a` = 0 ist er eine Verzögerung um ein Sample, sonst nichts.
- Je näher `a` an 1 oder −1 liegt, desto stärker verzögert er die tiefen Frequenzen gegenüber den hohen oder umgekehrt.

Eine Kette von 50 bis 200 solchen Allpässen zieht einen Klick zu einem Pfeifen auseinander, dem „Laserstrahl“ oder „Sproing“. Das heißt **Dispersion**.

## 4 · Schroeder-Allpass, verschachtelt, 2. Ordnung

Der **Schroeder-Allpass** hat innen ein Delay von einigen Millisekunden mit Rückführung, dazu einen Weg ohne Umweg mit umgedrehtem Vorzeichen. Er erzeugt Echos im Abstand seines Delays, und trotzdem bleibt jede Frequenz gleich laut.

- **Zehn in Serie**, mit Delays von 1 bis 15 ms und dem Gain 0,4, klingen dicht, aber mit metallischer Kante. Das ist der klassische „Digital Plate“ (Signalsmith).
- **Verschachtelt** (Gardner): Das innere Delay eines Allpasses ist wieder ein Allpass. Die Phase wird unregelmäßiger, der Klang weniger metallisch.
- **Allpass 2. Ordnung:** Er dreht die Phase um eine gewählte Frequenz `f` herum, in einer Breite `Q`.

## 5 · Der mehrkanalige Allpass

Ein **Kanal** ist eines der `N` parallelen Signale. In der Schleife heißt ein Kanal Leitung, im Diffusor heißt er Kanal.

Signalsmith erweitert den Allpass auf mehrere Kanäle: Die Energie aller Kanäle zusammen bleibt gleich. Sie darf aber in einem anderen Kanal oder später wieder erscheinen. Das erfüllen:

| Baustein | Was er tut |
|---|---|
| **Mehrkanal-Delay** | jeder Kanal hat eine eigene Länge; gleichzeitige Echos werden zeitlich getrennt |
| **orthogonale Matrix** (Teil 1 §4) | verteilt ein Echo auf alle Kanäle |
| **Vertauschen** | Kanäle wechseln den Platz |
| **Vorzeichen umdrehen** | ein Kanal wird mit −1 malgenommen |
| **ein Allpass pro Kanal** | Abschnitte 3 und 4, auf jeden Kanal einzeln |
| **Allpass auf einer Gruppe** | etwa Hadamard nur auf je 4 von 16 Kanälen |
| **Gerzon-Allpass** | ein Schroeder-Allpass über alle Kanäle, mit einer orthogonalen Matrix in der Rückführung (Gerzon 1976) |
| **Random-Phase-FIR** | ein Filter von etwa 4096 Samples, das jeder Frequenz eine zufällige Phase gibt; ein Klick wird zu einer Wolke dieser Länge. Es rechnet blockweise und hat deshalb Latenz. |

Eine Kette aus mehrkanaligen Allpässen ist wieder einer.

## 6 · Der Diffusionsschritt

Zuerst wird das Eingangssignal auf `N` Kanäle **aufgeteilt**: jeder Kanal bekommt dasselbe Signal, mit eigenem Vorzeichen.

Ein **Diffusionsschritt** nach Signalsmith hat drei Teile:

1. **Delay**, pro Kanal eine andere Länge. Es trennt Echos, die gleichzeitig in allen Kanälen liegen.
2. **Vertauschen und einige Vorzeichen umdrehen**, in jedem Schritt anders.
3. **Hadamard.** Jedes der nun getrennten Echos landet in jedem Kanal.

Jeder Schritt vervielfacht die Zahl der Echos mit `N`:

| `N` | nach 1 Schritt | nach 2 | nach 3 |
|---|---|---|---|
| 4 | 4 | 16 | 64 |
| 16 | 16 | 256 | 4096 |

Mit 4 Kanälen braucht es sechs Schritte für 4096 Echos.

Ein **Diffusor** ist eine Folge solcher Schritte.

## 7 · Varianten des Diffusionsschritts

| Stelle | Möglichkeiten | Wirkung |
|---|---|---|
| **Delay-Längen** | ganz zufällig im Bereich · Bereich in `N` gleiche Abschnitte teilen und in jedem einen Zufallswert wählen · Primzahlen · feste Verhältnisse | Die Abschnitte verteilen die Längen gleichmäßig und lassen sie trotzdem zufällig. Beispiel: Bereich 0–40 ms, `N` = 4, Abschnitte 0–10, 10–20, 20–30, 30–40 ms. So wählt auch Velvet Noise seine Zeiten. |
| **Bereich pro Schritt** | alle gleich, etwa 5 × 300 ms · verdoppelnd: 48, 96, 192, 384, 768 ms · halbierend · kurze und lange gemischt | Gleiche Bereiche geben einen rauen Anfang und ein raues Ende, mit einer Spitze in der Mitte. Verdoppelnde klingen weicher. |
| **Kanäle und Schritte** | 4 Kanäle × 3 Schritte mit 0–60 ms · 8 × 4 · 16 × 2–3 | Mehr Kanäle brauchen weniger Schritte. |
| **Matrix** | Hadamard · Householder · eine Matrix mit Regler (Teil 3) · nur ein Teil der Matrix | Hadamard mischt am meisten, Householder weniger. Mit Regler wird die Diffusion stufenlos. |
| **Vertauschen und Vorzeichen** | pro Schritt aus einem Startwert für den Zufall · weglassen | Ohne sie gleichen sich die Schritte, und Muster werden hörbar. |
| **statt des Delays** | Schroeder-Allpass pro Kanal · Kette von Allpässen 1. Ordnung · Random-Phase-FIR | Echos auch innerhalb des Schritts · Dispersion statt Echos · eine Wolke fester Länge |

## 8 · Andere Diffusoren

| Diffusor | Aufbau | Klang |
|---|---|---|
| **Schroeder-Kette** | 10 Allpässe in Serie, 1–15 ms, Gain 0,4 | dicht, metallisch |
| **Dattorro-Eingang** | vier Allpässe in Serie vor der Schleife | kurz und dicht |
| **verschachtelte Allpässe** | Gardner, Abschnitt 4 | unregelmäßige Phase |
| **Allpässe 2. Ordnung** in Serie | Abschnitt 4 | unregelmäßige Phase |
| **Gerzon-Netz** | Abschnitt 5 | dicht über alle Kanäle |
| **Kette von Allpässen 1. Ordnung** | 50–200 Stufen | Dispersion, „Sproing“ |
| **Random-Phase-Faltung** | Abschnitt 5 | eine Wolke, mit Latenz |

## 9 · Wo der Diffusor sitzt

| Ort | Wirkung | Vorbild |
|---|---|---|
| vor der Schleife | dicht von Anfang an; die Schleife macht nur die Länge | Signalsmith |
| in der Schleife | die Dichte wächst mit jedem Umlauf | Dattorro |
| hinter der Schleife | glättet oder färbt die Fahne | `gen~.gigaverb` (Teil 1 §9) |
| im Weg der frühen Reflexionen | die Reflexionen werden dichter, je später sie kommen | — |
| allein, ohne Schleife | dicht, aber ohne Fahne | — |

## 10 · Frühe Reflexionen

Die Delays der Schleife lassen eine Lücke zwischen dem Direktklang und den ersten Echos der Fahne. In einem Raum füllen diese Lücke die ersten Reflexionen von den Wänden, die **frühen Reflexionen**. Vier Wege, sie zu bauen:

| Weg | Aufbau | Wirkung |
|---|---|---|
| **eigener Delay-Weg** | eine gewichtete Summe verschiedener Kanäle des Diffusors, verzögert (Signalsmith) | überbrückt die Lücke bis zur Fahne |
| **Abgriff im Diffusor** | der Ausgang eines frühen, kurzen Diffusionsschritts | scharfer Beginn |
| **Mehrfach-Abgriff** | ein Delay mit mehreren Leseköpfen, wie `delay 48000 4` in `gen~.gigaverb`; Zeiten nach der Abschnitt-Methode aus Abschnitt 7; eigene Köpfe pro Lautsprecher | einzelne hörbare Reflexionen, im Raum verteilt |
| **wachsende Diffusion** | die ersten Diffusionsschritte mischen wenig, die späteren viel | erst einzelne Reflexionen, dann der Übergang in die dichte Fahne |

## 11 · Heruntermischen

Am Ende müssen `N` Kanäle auf wenige Lautsprecher. Danach ist das Ganze kein Allpass mehr. Das stört nicht, solange die Phase unregelmäßig ist.

- **Der Diffusor** gibt seine Echos in allen Kanälen gleichzeitig aus, weil die letzte Hadamard-Matrix jedes Echo überall hinlegt. Signalsmith nimmt davon nur die ersten ein oder zwei Kanäle.
- **Die Schleife** gibt ihre Echos in jeder Leitung zu anderen Zeiten aus. Verschiedene Zeilen einer Hadamard-Matrix geben dann Ausgänge, die voneinander unabhängig klingen: **dekorreliert**.

## 12 · Die Hallfahne

| Ansatz | Delays der Schleife | Matrix | Wofür |
|---|---|---|---|
| **Diffusor davor** (Signalsmith) | 100–200 ms, mindestens 8 Leitungen | wenig Mischung, etwa Householder | lange, farbneutrale Fahne |
| **Schleife allein** | 700–3000 Samples, teilerfremd | viel Mischung, etwa Hadamard | die Schleife baut die Dichte selbst |
| **Resonator** | gestimmt auf die Töne eines Akkords: `L = fs / f` | wenig Mischung | ein gehaltener Akkord |

Signalsmiths Beispiel: 8 Kanäle, 4 Diffusionsschritte mit 20, 40, 80 und 160 ms, Schleife mit 100–200 ms, Gain 0,85 pro Umlauf. Das gibt etwa 6 s Fahne. Gerechnet: 0,85 sind −1,4 dB pro Umlauf. 60 dB brauchen 42 Umläufe, bei 150 ms je Umlauf also etwa 6 s.

## 13 · Modulation

In einem echten Raum bewegt sich immer etwas, und die Wege ändern sich minimal. Im Netz bewegen sich dafür die Delaylängen leicht. Das löst stehende Resonanzen auf. Es reicht, einige Leitungen zu bewegen; die Matrix verteilt die Verstimmung auf die anderen.

Eine bewegte Länge fällt zwischen zwei Samples. Das Delay muss dann zwischen Samples **interpolieren**, also einen Wert zwischen zwei gespeicherten schätzen. Dattorro bewegt so die Allpässe in seiner Schleife.
