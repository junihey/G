---
tags: [learning, max-msp, gen, fdn]
created: 2026-09-29
topic: 'FDN Teil 4 -- verlustfrei gegen bijektiv, der Freeze und seine Bedingungen, Flaeche wird Ton, Senke, Lifting, Clipping mit Residuum, Koerner-Tausch, der Rueckwaertsschritt jedes Bausteins, was man beim Rueckwaertslauf hoert, wie weit er reicht, und das Integer-Netz'
verification: 'aus specs\wwww-installation\fdn.md und teppich.md (Stand 2026-09-28) umgeschrieben. Umkehr von Allpass und Tiefpass, Drehung als drei Lifting-Schritte und die Genauigkeit von Float64 von Hand nachgerechnet; Grenzzyklen und Totzone aus dem Chat vom 20.09.2026 in specs\wwww-rnbo\raw\; nichts in Max ausprobiert oder gemessen'
---

# FDN 4 — Freeze und Rückwärtslauf

Teil 4 von 7 über Feedback Delay Networks. Lies von oben nach unten.

**Setzt Teil 1 bis 3 voraus:** Leitung, Umlauf, Gain `g`, Energie, orthogonal, verlustfrei, Shelf, Tiefpass, Allpass 1. Ordnung, Vorzeichen, Givens-Rotation, Regler `d`, Eigenwert, frequenzabhängige Drehung, Nyquist.

**Antwort zuerst:** Zwei Dinge werden leicht verwechselt. Beim **Freeze** steht der Klang für immer, dafür muss das Netz verlustfrei sein. Beim **Rückwärtslauf** rechnet das Netz Sample für Sample zu einem früheren Zustand zurück, dafür muss jeder Schritt eindeutig umkehrbar sein. Jeder verlustfreie Schritt ist umkehrbar, aber nicht umgekehrt: Dämpfung ist umkehrbar und nie verlustfrei.

**Was hier nicht steht:** wie man mit dem Netz Rauschen erzeugt, das kommt in Teil 6. Der Bau in `gen~` kommt in Teil 7.

**Eine Quelle vorab:** `data\noise-invertierbarkeit.md` beschreibt Verfahren, die Klang in Rauschen verwandeln und dabei umkehrbar bleiben. Verweise wie „Teil VII.2“ zeigen auf ihre Abschnitte.

## 1 · Der Zustand

Der **Zustand** des Netzes sind alle Samples, die gerade in allen Leitungen liegen, dazu die gemerkten Werte der Allpässe. Bei 16 Leitungen mit je 3000 Samples sind das etwa 48.000 Zahlen.

Kommt nichts Neues hinein, folgt alles, was das Netz künftig spielt, aus seinem Zustand.

## 2 · Verlustfrei

**Verlustfrei** heißt: Die Energie des Zustands bleibt bei jedem Schritt gleich. Das gilt mit orthogonaler Matrix, Allpässen und `g` = 1.

## 3 · Bijektiv

**Bijektiv** heißt: Aus dem Zustand nach einem Schritt lässt sich der Zustand davor eindeutig ausrechnen.

| Rechnung | bijektiv? | verlustfrei? |
|---|---|---|
| `y = 0,8 · x` | ja, `x = y / 0,8` | nein, die Energie sinkt |
| `y = x²` | nein, 2 und −2 ergeben beide 4 | — |
| Clipping bei 1 | nein, alles über 1 wird zu 1 | — |
| Drehung | ja, zurückdrehen | ja |

## 4 · Der Freeze

Vier Bedingungen, alle exakt:

1. `g` = 1, nicht 0,9999.
2. Shelf und Tiefpass sind umgangen, nicht auf eine Grenze nahe Nyquist gestellt.
3. Im Kreis sitzt nur, was die Energie erhält: bewegte Winkel (Teil 3 §8), die laufende Drehung (Teil 3 §12) und der Körner-Tausch, der in Abschnitt 10 kommt.
4. Der Eingang ist zu. Ein offener Eingang füllt ein verlustfreies Netz ohne Grenze.

**Wie lange er hält:** Max rechnet Signale in **Float64**, Zahlen mit 64 Bit und etwa 16 Stellen Genauigkeit. Eine Drehung weicht durch Rundung um etwa 10⁻¹⁶ von der Orthogonalität ab. Nach einer Stunde bei 48 kHz und Längen um 1000 Samples sind das rund 170.000 Umläufe. Selbst wenn sich jeder Fehler addiert, bleibt die Abweichung unter 10⁻⁹. Speichern die Delays nur 32 Bit, sind es etwa 10⁻⁵. Beides ist unhörbar.

## 5 · Gefrorene Drehung

Im Freeze darf sich `d` bewegen. Die Matrix bleibt bei jedem `d` orthogonal (Teil 3 §5). Die stehende Fläche verwandelt sich dann zwischen Echomuster und Rauschen, ohne Energie zu verlieren.

## 6 · Fläche wird Ton

Absichtlich nicht verlustfrei: Im Freeze wird die Matrix leicht zur Identität überblendet, `(1 − ε) · M + ε · I` mit `ε` zwischen 0,01 und 0,1. Die Energie kann dabei nur fallen, nie steigen.

Verschiedene Anteile verlieren verschieden schnell (Teil 3 §2). Über 10 bis 20 Sekunden fällt die Fläche auf einen oder wenige Töne zusammen, die am langsamsten verlieren.

## 7 · Umlagern statt verlieren: die Senke

Ein Gain `g` < 1 nimmt Energie weg. Sie muss aber nicht verschwinden. Eine Drehung zwischen einer Leitung und einer **Senken-Leitung**, einer zusätzlichen Leitung, die nur sammelt, mit `cos θ = g`:

- Die Leitung behält den Faktor `g`.
- Den Rest, `√(1 − g²)`, bekommt die Senke.

Bei `g` = 0,8 bekommt die Senke 0,6, und 0,64 + 0,36 = 1. Die Leitung klingt ab, Leitung und Senke zusammen bleiben verlustfrei und bijektiv.

Mit der frequenzabhängigen Drehung aus Teil 3 §11 wandern nur die Höhen in die Senke. Das ist ein Shelf ohne Verlust.

Dahinter steht Teil VII.2: Wer Dämpfung und Umkehrbarkeit will, muss das Entfernte irgendwo ablegen.

## 8 · Lifting

Zwischen zwei Leitungen `x₁` und `x₂`:

```
vorwärts:   x₂ = x₂ + f(x₁)
rückwärts:  x₂ = x₂ − f(x₁)
```

`f` darf jede Funktion sein: Sättigung mit `tanh`, Clipping, irgendetwas. Rückwärts geht es trotzdem, weil `x₁` im Schritt unverändert bleibt und `f(x₁)` sich deshalb neu ausrechnen lässt (Teil VII.1).

Lifting ist bijektiv, aber nicht verlustfrei: Es fügt Energie hinzu. Ohne Dämpfung steigt der Pegel.

## 9 · Clipping mit Residuum

Clipping schneidet alles über der Schwelle `T` ab. Das Abgeschnittene, das **Residuum** `r = x − clip(x)`, wird Sample für Sample in einen eigenen Puffer geschrieben. Rückwärts gilt `x = clip(x) + r`. Der Puffer ist eine Aufnahme dessen, was abgeschnitten wurde, meistens Nullen.

## 10 · Körner-Tausch im Puffer

Normalerweise liest und schreibt eine Leitung ihre Speicherstellen der Reihe nach. Beim **Körner-Tausch** besucht sie sie in jedem Umlauf in einer anderen Reihenfolge. Gelesen und geschrieben wird immer dieselbe Stelle.

- Stücke von 20 bis 200 Samples, die **Körner**, wechseln so ihre Zeitstelle.
- Der **Radius** sagt, wie weit ein Korn wandern darf. Radius 0 ist ein normales Delay.
- Nichts kommt hinzu, nichts geht weg, es wird nur umsortiert: verlustfrei.
- Rückwärts besucht die Leitung dieselben Stellen in umgekehrter Reihenfolge: bijektiv.

Der Körner-Tausch ersetzt die bewegten Delaylängen aus Teil 2 §13. Die brauchen Interpolation, und eine Interpolation lässt sich nicht exakt umkehren (Teil V.2).

## 11 · Der Rückwärtsschritt jedes Bausteins

Die Leitung ist ein **Ringpuffer** der Länge `L` mit einem Zeiger: eine Speicherstelle nach der anderen, und am Ende geht es vorn weiter.

| Baustein | vorwärts | rückwärts |
|---|---|---|
| **Leitung** | ältesten Wert lesen, neuen an dieselbe Stelle schreiben, Zeiger vor | Zeiger zurück, neuesten Wert lesen, den zurückgerechneten ältesten an dieselbe Stelle schreiben |
| **Matrix** | die Drehungen der Reihe nach | dieselben Drehungen in umgekehrter Reihenfolge, mit `−θ` |
| **Allpass 1. Ordnung** | `v = x − a·z_alt`, `y = a·v + z_alt`, `z_neu = v` | `v = z_neu`, `z_alt = y − a·v`, `x = v + a·z_alt` |
| **Vorzeichen** | aus einem Hash des Sample-Zählers | derselbe Hash, der Zähler läuft rückwärts |
| **Dämpfung** | `g` | `1/g` |
| **Shelf, Tiefpass** | `y = (1−p)·x + p·y_alt` | `y_alt` steht eine Stelle davor im Puffer; dann `x = (y − p·y_alt) / (1−p)` |
| **Senke, frequenzabhängige Drehung** | Drehungen und Allpass | dieselben Schritte in umgekehrter Reihenfolge |
| **Körner-Tausch** | Stellen in der Reihenfolge des Umlaufs | dieselben Stellen umgekehrt |
| **Lifting** | `x₂ + f(x₁)` | `x₂ − f(x₁)` |

Ein **Hash** ist eine Rechnung, die aus einer Zahl eine zufällig aussehende macht, aber für dieselbe Zahl immer dasselbe Ergebnis liefert. Ein freier Zufallsgenerator wie `noise` in `gen~` kann nicht zurück.

**Eine Falle beim Allpass:** Man findet auch die Umkehrung `v = (y − z) / a`. Sie teilt durch `a` und versagt bei `a` = 0. Die Zeile in der Tabelle kommt ohne Division aus.

**Beim Tiefpass** wächst rückwärts der Rundungsfehler, und zwar um so viele dB, wie die Höhen vorwärts stärker gedämpft wurden. In Float64 bleibt das unhörbar.

## 12 · Was man beim Rückwärtslauf hört

Rückwärts durchläuft das Netz dieselben Zustände in umgekehrter Reihenfolge. Man hört deshalb die Ausgabe des Vorwärtslaufs, rückwärts abgespielt. Klanglich ist das ein Reverse-Hall: Die Wolke verdichtet sich zum Klick zurück. Diese Geste heißt hier **Kollaps**.

Eine Aufnahme in `buffer~`, rückwärts abgespielt, klänge gleich. Der Gewinn liegt woanders:

- Es läuft keine Aufnahme mit. Der Zustand von etwa 48.000 Samples trägt die ganze Geschichte.
- Die Richtung lässt sich jederzeit wechseln, mehrfach, auch mitten im Freeze.
- Die **Auskopplung**, also welche Leitung wie laut auf welchen Lautsprecher geht, berührt den Zustand nicht. Sie darf sich im Rückwärtslauf ändern. Eine Leitung, die vorwärts stumm war, kann rückwärts hörbar sein. Teil 6 nutzt das.

## 13 · Bedingungen für den Rückwärtslauf

1. Der Eingang ist zu. Sonst muss er aufgezeichnet und abgezogen werden, siehe Abschnitt 15.
2. Die Parameter im Kreis stehen fest, vom Hineingehen des Klangs bis zum Ende des Kollapses. Sonst läuft das Netz zurück, aber nicht zum Klick.
3. Im Kreis sitzt nur, was bijektiv ist. Draußen bleiben bewegte Delaylängen mit Interpolation, `tanh` ohne Lifting und freier Zufall.
4. Shelf und Tiefpass sind erlaubt (Abschnitt 11).

## 14 · Wie weit zurück

Float64 rechnet auf etwa 313 dB genau. Mit Dämpfung reicht der Rückweg, bis das Älteste um diesen Betrag unter den Rest gefallen ist. Das sind gut fünf Nachhallzeiten, bei `T60` = 60 s also rund fünf Minuten. Ohne Dämpfung reicht er beliebig weit.

## 15 · Rückwärts, während Klänge hineinkommen

| Art | Wie | Was man hört |
|---|---|---|
| **mit Abzug** | Alles, was ins Netz geht, wird aufgezeichnet und rückwärts wieder abgezogen. | Das Netz läuft exakt zurück. Die Klänge treten rückwärts aus der Wolke und verschwinden an ihrem Einsatz. |
| **ohne Abzug** | Rückwärts wird kein Eingang angenommen. | Jeder Klang verdichtet sich zu seinem Einsatz und zerfließt dahinter wieder. |

## 16 · Übersicht: welcher Baustein wofür taugt

| Baustein | Rückwärtslauf | Freeze |
|---|---|---|
| orthogonale Matrix, Drehungen, bewegte Winkel | ja | ja |
| Allpass | ja | ja |
| Vorzeichen aus Hash | ja | ja |
| laufende Drehung (Frequenzshift im komplexen Netz) | ja | ja |
| Körner-Tausch | ja | ja |
| Senke | ja | ja, Leitung und Senke zusammen |
| Dämpfung `g` | ja | nein |
| Shelf, Tiefpass | ja | nein |
| Lifting | ja | nein |
| Clipping mit Residuum | ja | nein |
| `hilbert~` und `freqshift~` im reellen Kreis | nein | nein |
| bewegte Delaylängen mit Interpolation | nein | nein |
| `tanh` ohne Lifting | nein | nein |
| freier Zufall (`noise`) | nein | — |

## 17 · Das Integer-Netz

Alles wird in ganzen Zahlen gerechnet, mit **Überlauf**: 32767 + 1 wird bei 16 Bit zu −32768 (Teil II.4).

Eine Drehung wird als drei Lifting-Schritte mit Rundung gebaut:

```
x = x + round(p · y)
y = y + round(s · x)
x = x + round(p · y)

p = −tan(θ/2),  s = sin θ
```

Jeder Schritt ist Lifting und deshalb trotz Rundung exakt umkehrbar. Beispiel ohne Rundung mit `θ` = 45°, `x` = 1, `y` = 0: Aus `p` = −0,414 und `s` = 0,707 wird `x` = 1, dann `y` = 0,707, dann `x` = 0,707. Das ist die Drehung um 45°.

Damit dürfen auch diese Verfahren in den Kreis:

- XOR, ein bitweises Verknüpfen mit einem Schlüssel (Teil VI),
- der Überlauf selbst,
- die Multiplikation mit einer ungeraden Zahl (Teil II.4).

Das Netz bleibt bitgenau umkehrbar. Weil der Zustand aus endlich vielen ganzen Zahlen besteht, kann ein bijektives Integer-Netz weder explodieren noch ganz verstummen.

Zwei Preise:

1. Es klingt digital hart.
2. Jede Dämpfung erzeugt entweder **Grenzzyklen**, ein leises Dauerbrummen, oder eine **Totzone**, in der die Fahne plötzlich abbricht.

XOR braucht in `gen~` bitweise Operatoren.
