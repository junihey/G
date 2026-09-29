---
tags: [learning, max-msp, gen, fdn]
created: 2026-09-29
topic: 'FDN Teil 3 -- warum man Matrizen nicht ueberblendet, die Givens-Drehung, Hadamard als Butterfly aus Drehungen, der Regler d, Winkelsaetze, gekoppelte Gruppen, bewegte Winkel, Householder und Cayley, die frequenzabhaengige Drehung und die Frequenzverschiebung als Drehung'
verification: 'aus specs\wwww-installation\fdn.md (Stand 2026-09-28) umgeschrieben. Ueberblendung, Butterfly, Lagen, frequenzabhaengige Drehung und das Zahlenbeispiel von Hand nachgerechnet; Cayley-Transformation aus dem Gedaechtnis; arXiv 2210.14015 nur im Abstract gelesen; nichts in Max ausprobiert'
---

# FDN 3 — Drehen statt überblenden

Teil 3 von 7 über Feedback Delay Networks. Lies von oben nach unten.

**Setzt Teil 1 und 2 voraus:** Leitung, Umlauf, Matrix, orthogonal, Energie, verlustfrei, Hadamard, Householder, Eigentöne, Allpass 1. Ordnung, Kanal, Diffusionsschritt.

**Antwort zuerst:** Wer stufenlos von „keine Mischung“ zu „Hadamard“ regeln will, darf die zwei Matrizen nicht überblenden. In der Mitte verliert die Schleife sonst Energie. Man baut Hadamard stattdessen aus Drehungen und dreht deren Winkel von 0 bis 45°. So bleibt die Matrix bei jedem Reglerwert orthogonal.

**Was hier nicht steht:** Freeze und Rückwärtslauf, die kommen in Teil 4.

**Eine Quelle vorab:** `data\noise-invertierbarkeit.md` beschreibt Verfahren, die Klang in Rauschen verwandeln und dabei umkehrbar bleiben. Verweise wie „Teil X.6“ zeigen auf ihre Abschnitte.

## 1 · Die Matrix, die nichts tut

Die **Identität**, geschrieben `I`, hat 1 auf der Diagonale und sonst überall 0. Jede Leitung bekommt genau ihren eigenen Wert zurück. Mit `I` in der Schleife laufen `N` getrennte Kammfilter wie in Teil 1 §2.

## 2 · Warum Überblenden die Schleife bricht

Der naheliegende Regler wäre: `(1 − d) · I + d · H`, also die Identität und die Hadamard-Matrix `H` mischen. Bei `d` = 0 ist das `I`, bei `d` = 1 ist es `H`.

Ein Beispiel mit zwei Leitungen. Die Hadamard-Matrix für zwei Leitungen ist

```
0,707   0,707
0,707  −0,707
```

Bei `d` = 0,5 wird daraus

```
0,854   0,354
0,354   0,146
```

Schick das Paar `a` = 0,383, `b` = −0,924 hinein. Seine Energie ist 0,147 + 0,854 = 1.

- Leitung 1 bekommt 0,854 · 0,383 + 0,354 · (−0,924) = 0.
- Leitung 2 bekommt 0,354 · 0,383 + 0,146 · (−0,924) = 0.

Die Energie ist in einem Umlauf verschwunden.

**Der Grund:** Manche Signale mischt eine Matrix nicht, sie nimmt sie nur mit einer Zahl mal. Diese Zahl heißt **Eigenwert**. Die Hadamard-Matrix hat die Eigenwerte +1 und −1. Die Überblendung hat dann die Eigenwerte 1 und `1 − 2d`. Bei `d` = 0,5 ist der zweite null. Jedes Signal mit dem Eigenwert −1 verschwindet dann bei jedem Umlauf, und das ist die Hälfte aller möglichen Signale. Das passiert genau in der Mitte des Reglers.

## 3 · Die Drehung

Eine Drehung verbindet zwei Leitungen `x` und `y` mit einem Winkel `θ`:

```
x' = cos θ · x − sin θ · y
y' = sin θ · x + cos θ · y
```

- Bei `θ` = 0° ändert sich nichts.
- Bei `θ` = 45° bekommt jede der zwei Leitungen die Hälfte von beiden, mal 0,707.
- Für jeden Winkel gilt `x'² + y'² = x² + y²`. Die Energie bleibt.

Beispiel: `x` = 1, `y` = 0, `θ` = 30°. Heraus kommen `x'` = 0,866 und `y'` = 0,5. Die Energie ist 0,75 + 0,25 = 1.

Diese Drehung heißt **Givens-Rotation**.

## 4 · Hadamard aus Drehungen: der Butterfly

Die Hadamard-Matrix lässt sich aus Drehungen um 45° zusammensetzen. Die Leitungen werden dafür ab 0 gezählt. Jede **Lage** dreht Paare, die sich in genau einer Stelle ihrer Nummer im Zweiersystem unterscheiden:

| Lage | Paare bei `N` = 16 |
|---|---|
| 1 | 0–1, 2–3, 4–5, … 14–15 |
| 2 | 0–2, 1–3, 4–6, 5–7, … |
| 3 | 0–4, 1–5, 2–6, 3–7, 8–12, … |
| 4 | 0–8, 1–9, … 7–15 |

`N` = 16 braucht 4 Lagen mit je 8 Paaren, also 32 Drehungen. Stehen alle auf 45°, ist das Ergebnis die Hadamard-Matrix, bis auf ein festes Muster von Vorzeichen. Das stört nicht, weil Vorzeichen ohnehin frei wählbar sind (Teil 2 §5).

Der Name kommt aus den Diagrammen der FFT: Die sich kreuzenden Linien jeder Lage sehen aus wie Schmetterlingsflügel. Englisch heißt die Anordnung **Butterfly**.

## 5 · Der Regler `d`

Alle Winkel sind `d` · 45°.

- Bei `d` = 0 ist jeder Winkel 0. `cos 0` ist genau 1, `sin 0` genau 0. Die Matrix ist bitgenau die Identität.
- Bei `d` = 1 ist sie Hadamard.
- Bei jedem `d` dazwischen ist sie orthogonal, weil jede einzelne Drehung die Energie erhält.

Das kostet bei `N` = 16 pro Sample 32 Drehungen mit je 4 Multiplikationen, also 128.

**Ein Regler, mehrere Wirkungen.** `d` kann weitere Dinge steuern, jedes mit einem eigenen Bereich, damit sie nacheinander einsetzen (`noise-invertierbarkeit.md` Teil X.6):

```
d von 0,0 bis 0,5   Winkel der Drehungen        0° → 45°
d von 0,3 bis 0,8   Allpass-Koeffizient a      0 → 0,85
d von 0,7 bis 1,0   Vorzeichen-Wechsel         aus → alle 500 Samples → jedes Sample
```

Erst verschmelzen die Echos zu Hall, dann verschmiert der Transient, zuletzt bleibt nur die Hüllkurve. Was der Vorzeichen-Wechsel klanglich tut, kommt in Teil 6.

**Kalibrieren:** Der Regler soll sich gleichmäßig anfühlen. Dafür misst man an 20 Stellen von `d` den **Crest-Faktor**, das Verhältnis von Spitze zu Mittelwert, also wie spitz das Signal ist. Die gemessene Kurve wird umgekehrt und als Tabelle zwischen Regler und Parameter gelegt (`noise-invertierbarkeit.md` Teil X.5).

## 6 · Andere Winkelsätze

Die Drehungen stehen als Liste in einem Puffer: je ein Paar und ein Winkel. Eine andere Liste ist eine andere Matrix, ohne neuen Patch. Eine solche Liste heißt hier **Winkelsatz**.

| Winkelsatz | Liste | bei `d` = 1 |
|---|---|---|
| **Hadamard** | Butterfly, alle 45° | Hadamard |
| **Zufall** | Butterfly, Winkel aus einem Startwert für den Zufall | eine Zufallsmatrix, pro Startwert immer dieselbe |
| **Ring** | `N` − 1 Drehungen um 90° über Nachbarn: 0–1, 1–2, 2–3, … | jede Leitung gibt ihren Inhalt an die nächste weiter; ein Echo wandert von Leitung zu Leitung |
| **Streuung** | zwischen den Lagen kurze Delays pro Leitung | die Echodichte wächst schneller; das ist ein Diffusionsschritt in der Schleife (Schlecht und Habets) |

Zwischen zwei Winkelsätzen werden die Winkel überblendet, nie die Matrizen.

## 7 · Die Lagen getrennt regeln: gekoppelte Gruppen

Bei `N` = 16 bilden die Leitungen vier Vierergruppen: 0–3, 4–7, 8–11, 12–15.

- Die Lagen 1 und 2 drehen nur innerhalb einer Gruppe.
- Die Lagen 3 und 4 drehen zwischen den Gruppen.

Mit einem Regler für die Lagen 1–2 und einem für die Lagen 3–4 wird aus einem Netz ein Satz gekoppelter Netze. Der erste Regler bestimmt die Mischung in jeder Gruppe, der zweite die Kopplung zwischen ihnen. Bei Kopplung 0 laufen vier getrennte Netze.

Jedes Paar darf sogar seinen eigenen Winkel haben. So lässt sich etwa nur Gruppe 0 mit Gruppe 1 koppeln.

## 8 · Bewegte Winkel

Eine Matrix, deren Winkel sich bewegen, ist in jedem einzelnen Sample orthogonal. Ein langsamer LFO auf den Winkeln macht die Fahne lebendig, ohne Energie zu kosten. Die bewegten Delaylängen aus Teil 2 §13 brauchen dagegen Interpolation.

## 9 · Householder passt nicht auf den Weg

Householder aus Teil 1 §5 spiegelt, statt zu drehen. Eine Zahl namens **Determinante** unterscheidet beides: +1 bei einer Drehung, −1 bei einer Spiegelung. Householder hat −1. Von der Identität aus ist er durch Drehen nicht erreichbar. Er lässt sich nur umschalten.

## 10 · Cayley: ein zweiter Weg zu jeder Matrix

Eine Matrix `S` heißt **schiefsymmetrisch**, wenn ihr Spiegelbild an der Diagonale `−S` ist. Aus ihr macht die **Cayley-Transformation** eine orthogonale Matrix:

```
Q = (I − S) · (I + S)⁻¹
```

`S` = 0 ergibt die Identität. Mit `d · S` führt ein Regler stufenlos zu jeder orthogonalen Matrix, die keinen Eigenwert −1 hat. Hadamard selbst hat einen und ist so nicht erreichbar.

Das `⁻¹` ist eine Matrixinversion. Sie kostet etwa `N³` Rechenschritte. Deshalb rechnet man sie nur neu, wenn sich der Regler bewegt, nicht in jedem Sample.

## 11 · Die frequenzabhängige Drehung

Eine Drehung darf für jede Frequenz anders ausfallen. Für zwei Leitungen:

1. Hadamard auf beide Leitungen.
2. Ein Allpass 1. Ordnung (Teil 2 §3) auf eine der beiden.
3. Wieder Hadamard.

Dann bleiben die tiefen Frequenzen in ihrer Leitung, und die hohen wechseln die Leitung. Die Grenze setzt der Allpass-Koeffizient `a`:

| `a` | was wechselt |
|---|---|
| nahe 1 | nichts, die Grenze liegt bei Nyquist |
| 0 | die obere Hälfte, die Grenze liegt bei einem Viertel der Abtastrate |
| nahe −1 | alles, die Grenze liegt bei 0 Hz |

**Nyquist** ist die halbe Abtastrate, bei 48 kHz also 24 kHz. Höher kann ein digitales Signal nicht klingen.

Das Ganze besteht nur aus Drehungen und einem Allpass, die Energie bleibt also. Solche frequenzabhängigen orthogonalen Matrizen heißen **paraunitär**. Aus ihnen bestehen auch die orthogonalen Filterbänke. Das Paper arXiv 2210.14015 entwirft sie mit vorgegebener Phase bei gewählten Frequenzen.

Wofür: eine Kopplung, die erst die Höhen hinüberlässt, und eine Frequenzweiche ohne Verlust.

## 12 · Die laufende Drehung: Frequenzverschiebung

Ein **Frequenzshifter** verschiebt alle Frequenzen um dieselbe Zahl Hertz: 100 Hz werden 105 Hz, 1000 Hz werden 1005 Hz. Obertöne passen danach nicht mehr zusammen. Harmonisches wird unharmonisch, bei großer Verschiebung klingt es nach Glocke und dann nach Rauschen.

Gebaut wird er mit `hilbert~`. Das Objekt macht aus einem Signal zwei Fassungen, die um 90° gegeneinander verschoben sind. Die eine heißt **Realteil**, die andere **Imaginärteil**, das Paar **analytisches Signal**.

Ein Frequenzshifter ist genau eine Drehung zwischen Realteil und Imaginärteil, deren Winkel mit jedem Sample wächst:

```
φ(n) = 2π · f · n / fs
```

`f` ist die Verschiebung in Hertz, `n` die Nummer des Samples. Weil es eine Drehung ist, geht keine Energie verloren.

**Das komplexe Netz:** 16 reelle Leitungen tragen 8 komplexe. Leitung `i` ist der Realteil, Leitung `i + 8` der Imaginärteil.

- Der Butterfly läuft über 3 Lagen, auf Real- und Imaginärteil gleich.
- Der Eingang geht vorher durch `hilbert~`. Dessen Ungenauigkeit bleibt außerhalb der Schleife.
- Ausgegeben wird der Realteil.
- Die laufende Drehung zwischen `i` und `i + 8` verschiebt bei jedem Umlauf um `f`.

Im Freeze aus Teil 4 geht dabei nichts verloren. Der Klang steigt bis Nyquist, kehrt dort um, sinkt bis 0 Hz, kehrt wieder um: Er pendelt zwischen beiden. Mit `hilbert~` und `freqshift~` in einer reellen Schleife ist das anders. `hilbert~` rechnet nahe 0 Hz und nahe Nyquist ungenau, und bei jedem Umlauf geht dort etwas verloren.
