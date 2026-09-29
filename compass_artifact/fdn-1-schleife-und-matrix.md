---
tags: [learning, max-msp, gen, fdn]
created: 2026-09-29
topic: 'FDN Teil 1 -- ein Delay mit Rueckfuehrung, mehrere Leitungen, die Mischmatrix, warum orthogonal die Energie erhaelt, Hadamard und Householder, die Nachhallzeit pro Leitung, und gen~.gigaverb als Beispiel'
verification: 'aus specs\wwww-installation\fdn.md (Stand 2026-09-28) umgeschrieben. Signalsmith "Let s Write A Reverb" (PDF in data\scans\mathe\) und gen~.gigaverb.maxpat aus Max 9 gelesen; die Formel der Nachhallzeit nach Jot aus dem Gedaechtnis; Rechenbeispiele von Hand nachgerechnet; nichts in Max ausprobiert'
---

# FDN 1 — Schleife und Matrix

Teil 1 von 7 über **Feedback Delay Networks**, kurz **FDN**. Lies von oben nach unten; jeder Abschnitt benutzt nur, was vor ihm steht. Diese Datei setzt nichts voraus.

**Antwort zuerst:** Ein FDN ist ein Satz von Delays, deren Ausgänge über eine Mischmatrix wieder in ihre Eingänge laufen. Ist die Matrix orthogonal, geht beim Mischen keine Energie verloren. Wie lange der Klang nachhallt, bestimmt dann allein ein Gain pro Delay.

**Was hier nicht steht:** Allpässe und Diffusion kommen in Teil 2. Wie man die Matrix stufenlos regelt, steht in Teil 3. Freeze und Rückwärtslauf in Teil 4, der Katalog der Netze in Teil 5, Rauschen in Teil 6, der Bau in `gen~` in Teil 7.

## 1 · Ein Delay mit Rückführung

Ein **Delay** verzögert ein Signal um eine feste Zahl von Samples. Diese Zahl heißt seine **Länge**, geschrieben `L`. Bei 48 kHz sind 4800 Samples 100 ms.

Führt man den Ausgang des Delays zurück in seinen Eingang, entsteht eine **Schleife**. Auf dem Rückweg sitzt ein **Gain** `g`, ein Faktor kleiner als 1. Ein Durchlauf durch die Schleife heißt **Umlauf**.

Ein Klick in einer Schleife mit `L` = 4800 und `g` = 0,8:

| Zeit | Pegel |
|---|---|
| 100 ms | 1,0 |
| 200 ms | 0,8 |
| 300 ms | 0,64 |
| 400 ms | 0,51 |

Das ist ein **Kammfilter**. Ist `L` kurz, folgen die Echos so dicht, dass man sie als Ton hört. Bei `L` = 48 kommen 1000 Echos pro Sekunde, man hört 1000 Hz.

Der Ausgang lässt sich vor oder hinter dem Gain abgreifen. Das ändert nur den Pegel des ersten Echos.

## 2 · Mehrere Leitungen

Echos im immer gleichen Abstand klingen nach Maschine, nicht nach Raum. Deshalb nimmt man mehrere Schleifen nebeneinander, jede mit eigener Länge. Eine Schleife in einem solchen Netz heißt **Leitung**. Die Zahl der Leitungen heißt `N`.

Jede Leitung wiederholt ihr eigenes Muster, und zusammen klingt es dichter. Die Längen sollen **teilerfremd** sein: Sie haben keinen gemeinsamen Teiler außer 1. Primzahlen sind immer teilerfremd, etwa 1117, 1543, 1987 und 2311 Samples. Hätten zwei Längen einen gemeinsamen Teiler, träfen sich ihre Echos immer wieder im selben Moment, und das Muster würde hörbar.

So baute Schroeder 1962 den ersten künstlichen Hall: vier Kammfilter nebeneinander.

## 3 · Die Mischmatrix

Bisher hört jede Leitung nur ihr eigenes Echo. Mischt man die Leitungen auf dem Rückweg, wechselt jedes Echo bei jedem Umlauf die Leitung. Aus einem Echo werden so mit jedem Umlauf mehr.

Diese Mischung macht eine **Matrix**, eine Tabelle von Faktoren. Zeile `i` sagt, wie viel von jeder Leitung in Leitung `i` zurückläuft.

Ein Beispiel mit vier Leitungen `a`, `b`, `c`, `d`:

```
Zeile 1:  +1  +1  +1  +1
Zeile 2:  +1  −1  +1  −1
Zeile 3:  +1  +1  −1  −1
Zeile 4:  +1  −1  −1  +1
```

- Leitung 1 bekommt `a + b + c + d`.
- Leitung 2 bekommt `a − b + c − d`.
- Leitung 3 bekommt `a + b − c − d`.
- Leitung 4 bekommt `a − b − c + d`.

Danach wird alles mit ½ malgenommen. Warum genau ½, zeigt Abschnitt 4. Diese Matrix heißt **Hadamard-Matrix**.

Ein Klick in Leitung 1 steckt nach dem ersten Umlauf in allen vier Leitungen. Weil die vier verschieden lang sind, kommen seine Kopien zu verschiedenen Zeiten zurück, und jede wird wieder auf alle vier verteilt. Die Zahl der Echos pro Sekunde, die **Echodichte**, wächst mit jedem Umlauf. So bauten Stautner und Puckette 1982 und Jot 1991 ihre Netze.

## 4 · Warum orthogonal: die Energie bleibt

Die **Energie** eines Satzes von Samples ist die Summe ihrer Quadrate.

Ein Klick nur in Leitung 1: `a` = 1, alle anderen 0. Die Energie ist 1.

| Faktor nach der Hadamard-Matrix | jede Leitung bekommt | Energie danach |
|---|---|---|
| ½ | ½ | 4 × ¼ = **1** |
| 1 | 1 | 4 × 1 = 4, der Klang explodiert |
| 0,4 | 0,4 | 4 × 0,16 = 0,64, der Klang verliert 36 % pro Umlauf |

Nur mit ½ bleibt die Energie gleich, für jeden Klick in jeder Leitung. Eine Matrix mit dieser Eigenschaft heißt **orthogonal**. Bei komplexen Zahlen heißt dasselbe **unitär**.

Man erkennt eine orthogonale Matrix an zwei Proben:

1. In jeder Zeile ist die Summe der Quadrate 1. Bei Hadamard: 4 × (½)² = 1.
2. Zwei verschiedene Zeilen, Stelle für Stelle malgenommen und addiert, ergeben 0. Zeile 1 und 2: ¼ · (1 − 1 + 1 − 1) = 0.

**Was daraus folgt:** Die Matrix nimmt keine Energie und gibt keine dazu. Abklingen kommt nur vom Gain `g`. Ein Netz mit orthogonaler Matrix und `g` = 1 heißt **verlustfrei**. Jot baute zuerst das verlustfreie Netz und fügte die Dämpfung dann gezielt hinzu. Diese Trennung trägt alles Weitere.

## 5 · Hadamard und Householder

Zwei orthogonale Matrizen sind gebräuchlich:

| | Hadamard | Householder |
|---|---|---|
| Rechnung | Muster aus +1 und −1, mal `1/√N` | jede Leitung: ihr eigener Wert minus `2/N` mal die Summe aller Leitungen |
| Aufwand | `N·log₂N` Additionen | etwa `2N` Additionen und eine Multiplikation |
| für welches `N` | nur Zweierpotenzen: 4, 8, 16 | jedes `N` |
| Mischung bei `N` = 16 | maximal: jede Leitung bekommt von jeder gleich viel | wenig: jede Leitung behält den Faktor 0,875 von sich und bekommt −0,125 von jeder anderen |

Bei `N` = 4 mischt Householder so stark wie Hadamard. Ihr Vorteil zeigt sich erst ab etwa 8 Leitungen.

Bei Householder lässt sich der eigene Wert durch den einer anderen Leitung ersetzen: Leitung `i` nimmt den Wert von Leitung `P(i)` statt ihren eigenen, wobei `P` jede Leitung genau einmal vergibt. Das kostet dasselbe und mischt anders.

## 6 · Zu viel Mischung färbt

Mischt die Matrix maximal, verhalten sich die Leitungen bald wie eine einzige. Ein Netz hat Frequenzen, bei denen es besonders lange klingt, seine **Eigentöne**. Bei starker Mischung rücken sie zusammen, und dazwischen bleiben Lücken. Eine lange Fahne klingt dann gefärbt.

Signalsmith nimmt deshalb Householder in die Schleife und Hadamard nur in den Diffusor. Was ein Diffusor ist, kommt in Teil 2. Wie man die Menge der Mischung zu einem Regler macht, kommt in Teil 3.

## 7 · Die Nachhallzeit

Die **Nachhallzeit** `T60` ist die Zeit, bis ein Klang um 60 dB leiser geworden ist, also auf ein Tausendstel seiner Amplitude.

Eine kurze Leitung macht in dieser Zeit mehr Umläufe als eine lange. Hätten alle dasselbe `g`, klängen die kurzen schneller ab. Deshalb bekommt jede Leitung ihr eigenes `g`:

```
g_i = 10 ^ ( −3 · L_i / (fs · T60) )
```

`fs` ist die Abtastrate. Ein Beispiel mit `fs` = 48000 und `T60` = 2 s:

| Leitung | `L` | Umläufe in 2 s | `g` | nach 2 s |
|---|---|---|---|---|
| kurz | 2400 (50 ms) | 40 | 0,841 | 0,841⁴⁰ = 0,001 |
| lang | 4800 (100 ms) | 20 | 0,708 | 0,708²⁰ = 0,001 |

Beide sind nach 2 s um 60 dB leiser.

## 8 · Höhen klingen schneller ab

In einem echten Raum schlucken Wände und Luft die Höhen stärker. Im Netz macht das ein Filter pro Leitung, im Kreis:

- Ein **Shelf-Filter** senkt nur die Höhen ab.
- Ein **Tiefpass** lässt nur die Tiefen durch.

Wirkt `g` mit −1,5 dB pro Umlauf und ein Shelf zusätzlich mit −1,5 dB auf die Höhen, klingen die Höhen doppelt so schnell ab (Signalsmith).

Ein Filter **außerhalb** der Schleife wirkt nur einmal. Er schneidet Höhen oder Tiefen ab, ändert aber nicht, wie schnell sie abklingen.

## 9 · Ein vollständiges Beispiel: `gen~.gigaverb`

Max liefert ein fertiges FDN mit: `C:\Program Files\Cycling '74\Max 9\examples\gen\gen~.gigaverb.maxpat`. In der Reihenfolge des Signals:

1. **Eingangsfilter:** ein Tiefpass, Regler `bandwidth`.
2. **Die Schleife:** vier Leitungen aus dem Operator `delay`, gemischt mit der Hadamard-Matrix aus Abschnitt 3 mal 0,5.
    - Pro Leitung ein Tiefpass aus `history`, das den vorigen Wert behält, und `mix`, das zwischen neuem und vorigem Wert mischt. Regler `damping`.
    - Pro Leitung ein Gain aus der Nachhallzeit wie in Abschnitt 7. Regler `revtime`.
    - Die Längen folgen aus der Raumgröße in Metern, geteilt durch 340 m/s, die Schallgeschwindigkeit. Regler `roomsize`.
3. **Frühe Reflexionen:** ein `delay` mit vier Leseköpfen, `delay 48000 4`. Regler `early`.
4. **Diffusion hinter der Schleife:** je Ausgang eine Kette von Allpässen. Was ein Allpass ist, kommt in Teil 2.
5. **Mischung** aus `dry`, `early` und `tail`.

Zwei Dinge hat `gen~.gigaverb` nicht: eine Matrix mit Regler (Teil 3) und einen Rückwärtslauf (Teil 4).
