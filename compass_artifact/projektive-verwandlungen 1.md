---
tags: [learning, threejs]
created: 2026-09-28
topic: 'Die Mathematik hinter der Skizze Wegkurven-Funken, von Koordinaten und Fernpunkten bis zu Wegflächen, Linienkongruenz, Kristallformen und Knick-Funken, für einen Leser ohne Vorwissen in projektiver Geometrie'
verification: 'extern -- projektive Geometrie und three.js gibt es ohne diesen Vault; per Hand gegen den Quelltext von zaehlen\threejs-wegkurven-funken\index.html (Commit 0729097) und gegen die Buecher in data\scans\mathe geprueft'
---

# Projektive Verwandlungen in three.js

Diese Datei erklärt die Mathematik hinter der Skizze **Wegkurven-Funken**. Die Skizze zeigt einen Körper, der sich verwandelt, und aus seinen Ecken und Kanten sprühen Kurven wie Funken. Ihr Code liegt in einer einzigen Datei, `zaehlen\threejs-wegkurven-funken\index.html`.

**Wie du sie liest:** von oben nach unten. Jeder Abschnitt benutzt nur, was vor ihm steht. Du brauchst nur Schulrechnen: addieren, malnehmen, einen Bruch kürzen. Die Abschnitte haben drei Teile:

- **1 bis 10** bauen die Mathematik auf. Dort kommt fast kein Code vor.
- **11 und 12** erklären, wie die Grafikkarte das Ergebnis zeichnet.
- **13 bis 20** erklären die Modi der Skizze, jeden mit seiner Buchstelle.
- **21** sagt, wo was im Code steht.

Jede Formel hat ein Beispiel mit Zahlen. Rechne die Beispiele mit, sie sind kurz.

**Was hier nicht steht:** keine Beweise. Keine three.js-Grundlagen, die stehen in [[aufbau-einer-anwendung]]. Keine Anleitung Regler für Regler, die Seite erklärt ihre Regler selbst. Und die Bücher ersetzt diese Datei nicht. Sie liegen unter `data\scans\mathe\`, und jeder Abschnitt nennt die Stelle, an der es dort weitergeht.

---

## 1 · Punkte als Zahlen

Ein Punkt in der Ebene ist ein Paar von Zahlen, zum Beispiel $(3, 2)$: drei nach rechts, zwei nach oben. Ein Punkt im Raum hat drei Zahlen, $(x, y, z)$.

Mit solchen Zahlenpaaren kann man rechnen wie mit Pfeilen:

- **Addieren** heißt: Zahl für Zahl zusammenzählen. $(3, 2) + (1, 5) = (4, 7)$.
- **Malnehmen mit einer Zahl** heißt: jede Zahl einzeln malnehmen. $2 \cdot (3, 2) = (6, 4)$. Der Pfeil wird doppelt so lang und zeigt in dieselbe Richtung. Mit $-1$ zeigt er in die Gegenrichtung.

Eine dritte Rechnung braucht man ständig, das **Skalarprodukt**. Man nimmt zwei Zahlenpaare Stelle für Stelle mal und zählt alles zusammen:

$$(a_1, a_2) \cdot (b_1, b_2) = a_1 b_1 + a_2 b_2$$

Beispiel: $(1, 2) \cdot (3, 4) = 1 \cdot 3 + 2 \cdot 4 = 11$. Im Raum kommt ein dritter Summand dazu.

Das Skalarprodukt sagt zwei Dinge. Ist es **null**, stehen die beiden Pfeile senkrecht aufeinander: $(1, 0) \cdot (0, 1) = 0$. Und das Skalarprodukt eines Pfeils mit sich selbst ist seine Länge im Quadrat: $(3, 4) \cdot (3, 4) = 25$, die Länge ist also 5.

## 2 · Geraden und Ebenen als Gleichungen

Eine Gerade in der Ebene lässt sich als Gleichung schreiben:

$$a x + b y = c$$

Zum Beispiel $x + y = 2$. Auf ihr liegen alle Punkte, deren beide Zahlen zusammen 2 ergeben: $(2, 0)$, $(0, 2)$, $(1, 1)$.

Die beiden Zahlen $(a, b)$ vor $x$ und $y$ bilden einen Pfeil, der **senkrecht auf der Geraden** steht. Man nennt ihn die **Normale**. Bei $x + y = 2$ ist das $(1, 1)$, und die Gerade läuft tatsächlich schräg von links oben nach rechts unten, quer zu $(1, 1)$.

Die Gleichung ist ein Skalarprodukt aus Abschnitt 1: $(a, b) \cdot (x, y) = c$. Hat die Normale die Länge 1, ist $c$ der Abstand der Geraden vom Nullpunkt.

Im Raum ist es genauso, nur mit drei Zahlen. Eine **Ebene** ist

$$n \cdot x = d$$

mit einer Normalen $n$ aus drei Zahlen. Die Skizze speichert jede Fläche eines Körpers genau so, als Paar aus Normale und Zahl: im Code `{ n, d }`. Die Normale zeigt dabei immer nach außen.

## 3 · Das Unendliche: Fernpunkte

Zwei parallele Geraden treffen sich nicht. Das ist eine lästige Ausnahme: Alle anderen Paare von Geraden in einer Ebene haben genau einen gemeinsamen Punkt.

Die projektive Geometrie beseitigt die Ausnahme. Sie gibt jeder Geraden einen zusätzlichen Punkt, ihren **Fernpunkt**. Parallele Geraden haben denselben Fernpunkt, und dort treffen sie sich. Du kennst das aus jedem Foto von Bahngleisen: Die Schienen laufen am Horizont in einem Punkt zusammen.

Drei Dinge folgen daraus:

- Jede Gerade hat **genau einen** Fernpunkt, nicht zwei. Wer auf einer Geraden nach rechts ins Unendliche geht, kommt am selben Punkt an wie wer nach links geht. Die Gerade ist dadurch geschlossen, wie ein Kreis.
- Alle Fernpunkte einer Ebene zusammen bilden eine Gerade, die **Ferngerade**. Auf einem Foto ist sie der Horizont.
- Im Raum bilden alle Fernpunkte eine Ebene, die **Fernebene**.

Whicher widmet dem ein ganzes Kapitel. Für diese Datei zählt vor allem die letzte Folgerung: Eine Verwandlung kann einen gewöhnlichen Punkt zum Fernpunkt machen, und ein Punkt kann durchs Unendliche wandern und von der Gegenseite zurückkommen. Die nächsten Abschnitte machen das rechenbar.

Buchstelle: Whicher, Kap. III, „Der unendlich ferne Punkt einer Linie“ bis „Die unendlich ferne Ebene des Raumes“.

## 4 · Homogene Koordinaten in der Ebene

Fernpunkte lassen sich nicht mit zwei Zahlen schreiben, es gibt keine Zahl „unendlich“. Der Trick ist eine **dritte Zahl**. Den Punkt $(x, y)$ schreibt man als

$$(x, y, 1)$$

und vereinbart: **Jedes Vielfache bezeichnet denselben Punkt.** $(3, 2, 1)$, $(6, 4, 2)$ und $(-3, -2, -1)$ sind alle der Punkt $(3, 2)$. Um von drei Zahlen zurück zum gewohnten Punkt zu kommen, teilt man die ersten beiden durch die dritte: $(6, 4, 2) \to (6/2,\ 4/2) = (3, 2)$. Die dritte Zahl heißt $w$. Man nennt diese Schreibweise **homogene Koordinaten**.

Jetzt passiert das Entscheidende. Geh auf der $x$-Achse nach rechts, immer weiter: $(t, 0, 1)$ mit großem $t$. Weil jedes Vielfache erlaubt ist, darf man durch $t$ teilen:

$$(t, 0, 1) = (1,\ 0,\ 1/t)$$

Je größer $t$, desto näher liegt $1/t$ an null. Am Ende steht $(1, 0, 0)$. Das ist der Fernpunkt der $x$-Achse, und er hat eine ganz gewöhnliche Schreibweise. **Ein Punkt mit $w = 0$ ist ein Fernpunkt.**

Geh jetzt nach links: $(-t, 0, 1)$. Mit $-1$ malgenommen ist das $(t, 0, -1)$, geteilt durch $t$ also $(1, 0, -1/t)$. Auch das endet bei $(1, 0, 0)$. Beide Richtungen führen zum selben Fernpunkt, genau wie Abschnitt 3 sagt.

**Auch eine Gerade bekommt drei Zahlen.** Die Gerade $a x + b y = c$ aus Abschnitt 2 wird zu $(a, b, -c)$. Ein Punkt $(x, y, w)$ liegt auf ihr, wenn das Skalarprodukt null ist:

$$a x + b y - c w = 0$$

Beispiel: Die Gerade $x + y = 2$ ist $(1, 1, -2)$. Der Punkt $(1, 1, 1)$ liegt auf ihr, denn $1 + 1 - 2 = 0$.

Nimm die Parallele $x + y = 5$, also $(1, 1, -5)$. Welcher Punkt liegt auf beiden? $(1, -1, 0)$: Für die erste Gerade gilt $1 - 1 + 0 = 0$, für die zweite ebenso. Das ist ein Fernpunkt, und seine Richtung $(1, -1)$ ist die Richtung, in die beide Geraden laufen. Die Parallelen treffen sich tatsächlich, im Unendlichen.

Die Ferngerade selbst ist $(0, 0, 1)$. Auf ihr liegt jeder Punkt mit $0 \cdot x + 0 \cdot y + 1 \cdot w = 0$, also jeder Punkt mit $w = 0$.

Beachte die Gleichberechtigung: **Ein Punkt ist drei Zahlen, eine Gerade ist drei Zahlen.** Whicher nennt das Dualität. In Abschnitt 16 wird sie zu einer Rechenvorschrift.

## 5 · Homogene Koordinaten im Raum

Im Raum ist alles eine Zahl länger. Der Punkt $(x, y, z)$ wird zu $(x, y, z, 1)$, jedes Vielfache ist derselbe Punkt, und $w = 0$ bedeutet Fernpunkt.

Eine Ebene $n \cdot x = d$ aus Abschnitt 2 wird zu vier Zahlen $(n_x, n_y, n_z, -d)$. Ein Punkt liegt auf ihr, wenn das Skalarprodukt der vier Zahlen null ist. Die Fernebene ist $(0, 0, 0, 1)$.

Zwei Hilfen aus dem Code kommen hier zum ersten Mal vor:

- **Einen Punkt in vier Zahlen umschreiben** — im Code `h4` — hängt an einen gewöhnlichen Punkt die 1 an.
- **Normieren** — im Code `nrm4` — teilt alle vier Zahlen durch ihre gemeinsame Länge. Das ist nach Abschnitt 4 erlaubt, der Punkt bleibt derselbe. Es hält nur die Zahlen klein. `nrm4` teilt durch eine positive Zahl, **das Vorzeichen bleibt also erhalten.** Warum das wichtig ist, zeigt Abschnitt 11.

## 6 · Verwandlungen als Matrizen

Eine Verwandlung schiebt jeden Punkt an eine neue Stelle. In homogenen Koordinaten geht das mit einer **Matrix**, einer Tabelle aus Zahlen. In der Ebene hat sie drei Zeilen und drei Spalten.

**Matrix mal Punkt** geht so: Jede Zeile der Matrix bildet mit dem Punkt ein Skalarprodukt aus Abschnitt 1. Das Ergebnis der ersten Zeile ist die neue erste Zahl, und so weiter. Ein Beispiel:

$$\begin{pmatrix} 2 & 0 & 0 \\ 0 & 2 & 0 \\ 0 & 0 & 1 \end{pmatrix} \begin{pmatrix} 3 \\ 2 \\ 1 \end{pmatrix} = \begin{pmatrix} 2 \cdot 3 + 0 \cdot 2 + 0 \cdot 1 \\ 0 \cdot 3 + 2 \cdot 2 + 0 \cdot 1 \\ 0 \cdot 3 + 0 \cdot 2 + 1 \cdot 1 \end{pmatrix} = \begin{pmatrix} 6 \\ 4 \\ 1 \end{pmatrix}$$

Der Punkt $(3, 2)$ geht nach $(6, 4)$. Diese Matrix ist eine **Streckung** auf das Doppelte.

Die dritte Zahl macht auch das **Verschieben** zu einer Matrix, was mit zwei Zahlen nicht ginge:

$$\begin{pmatrix} 1 & 0 & 5 \\ 0 & 1 & 0 \\ 0 & 0 & 1 \end{pmatrix} \begin{pmatrix} x \\ y \\ 1 \end{pmatrix} = \begin{pmatrix} x + 5 \\ y \\ 1 \end{pmatrix}$$

Jeder Punkt rückt um 5 nach rechts.

Interessant wird es, wenn die Matrix die **dritte Zahl verändert**. Diese Matrix setzt $w$ neu auf $x + w$:

$$\begin{pmatrix} 1 & 0 & 0 \\ 0 & 1 & 0 \\ 1 & 0 & 1 \end{pmatrix} \begin{pmatrix} x \\ y \\ w \end{pmatrix} = \begin{pmatrix} x \\ y \\ x + w \end{pmatrix}$$

Folge vier Punkten auf der $x$-Achse:

| Punkt vorher | homogen vorher | homogen nachher | Punkt nachher |
|---|---|---|---|
| $(1, 0)$ | $(1, 0, 1)$ | $(1, 0, 2)$ | $(0{,}5;\ 0)$ |
| $(-0{,}5;\ 0)$ | $(-0{,}5;\ 0;\ 1)$ | $(-0{,}5;\ 0;\ 0{,}5)$ | $(-1, 0)$ |
| $(-1, 0)$ | $(-1, 0, 1)$ | $(-1, 0, 0)$ | Fernpunkt |
| $(-2, 0)$ | $(-2, 0, 1)$ | $(-2, 0, -1)$ | $(2, 0)$ |

Der Punkt bei $-1$ wird zum Fernpunkt. Der Punkt bei $-2$ landet auf der **rechten** Seite bei $+2$: Er ist durchs Unendliche gewandert und von der Gegenseite zurückgekommen. Genau das beschreibt Whicher, wenn ein Kreis durch eine Perspektive zur Hyperbel wird.

Zwei Eigenschaften machen Matrizen zum richtigen Werkzeug:

- **Vielfache bleiben Vielfache.** $M \cdot (2p) = 2 \cdot (M \cdot p)$. Es ist also gleich, welches Vielfache man einsetzt. Der Bildpunkt ist immer derselbe.
- **Geraden bleiben Geraden.** Auch $M \cdot (p + q) = M \cdot p + M \cdot q$ gilt. Die Punkte einer Geraden sind Mischungen $\alpha p + \beta q$ aus zwei ihrer Punkte, und die Matrix macht daraus Mischungen der zwei Bildpunkte. Das sind wieder die Punkte einer Geraden.

Eine Verwandlung mit dieser Eigenschaft heißt **projektiv**. Zwei Verwandlungen nacheinander sind wieder eine Matrix, das Produkt der beiden. Die Verwandlung rückgängig machen heißt, die **Umkehrmatrix** zu nehmen.

Im Raum sind die Matrizen $4 \times 4$ groß, sonst ändert sich nichts. Im Code heißt Matrix mal Punkt `mv`, die Umkehrmatrix `inv4`.

## 7 · Feste Punkte und die drei Maße

Die meisten Punkte bewegen sich bei einer Verwandlung. Manche bleiben stehen, die **festen Punkte**. Whicher nennt sie Doppelpunkte oder Wächter. Sie bestimmen, wie die Verwandlung aussieht.

Am einfachsten sieht man das auf einer einzigen Geraden. Ein Punkt der Geraden ist $(x, w)$, zwei Zahlen, und eine Verwandlung ist eine $2 \times 2$-Matrix. Es gibt genau drei Arten.

**Wachstum.** Die Verwandlung $x \to 2x$. Fest bleiben die 0 und der Fernpunkt. Alle anderen Punkte fliehen von der 0 zum Fernpunkt. Wer bei 1 anfängt und den Schritt wiederholt, kommt nach 2, 4, 8, 16. Rückwärts geht es nach $\tfrac12, \tfrac14, \tfrac18$ auf die 0 zu. Jeder Schritt nimmt mit derselben Zahl mal. Whicher nennt das **Wachstumsmaß**. Es spannt sich zwischen **zwei** festen Punkten.

**Schritt.** Die Verwandlung $x \to x + 1$. Fest bleibt nur der Fernpunkt. Die Folge heißt 0, 1, 2, 3, jeder Schritt zählt dieselbe Zahl dazu. Das ist das **Schrittmaß**. Die zwei festen Punkte des Wachstums sind hier zu einem zusammengefallen.

**Kreisend.** Nach Abschnitt 3 ist die Gerade geschlossen wie ein Kreis. Denk sie dir als Kreis, und die Verwandlung dreht diesen Kreis jedes Mal um dasselbe Stück weiter. Kein reeller Punkt bleibt stehen, alle wandern immer weiter um die geschlossene Gerade herum und kommen wieder. Das ist das **kreisende Maß**. Die Rechnung sagt, auch hier gibt es zwei feste Punkte, aber sie sind **imaginär**, also keine Punkte, die man zeichnen könnte. Whicher beschreibt sie als die kreisende Bewegung selbst.

Mehr Arten gibt es nicht. Ob die Verwandlung zwei reelle, einen doppelten oder zwei imaginäre feste Punkte hat, entscheidet alles. Ostheimer/Ziegler nennen die drei Fälle hyperbolisch, parabolisch und elliptisch.

Buchstelle: Whicher, Kap. VI, „Projektivität und Involution in einer Linie“ bis „Kreisende Involution“.

## 8 · Die Exponentialfunktion

Abschnitt 7 geht in Sprüngen: 1, 2, 4, 8. Für Funken braucht man eine fließende Bewegung. Das leistet die **Exponentialfunktion**.

Es gibt eine besondere Zahl $e \approx 2{,}718$. Die Funktion $e^t$ wächst so, dass jede gleich lange Zeitspanne mit demselben Faktor malnimmt. Die Grundregel:

$$e^{s + t} = e^s \cdot e^t$$

Erst eine Zeitspanne $s$, dann $t$ zu wachsen, ist dasselbe wie $s + t$ auf einmal. Das macht aus den Sprüngen von Abschnitt 7 einen Fluss. Mit einer Rate $a$ davor, also $e^{a t}$, wächst es schneller oder langsamer. Bei negativem $a$ schrumpft es.

Der **Logarithmus** $\ln$ macht $e$ rückgängig: $\ln(e^u) = u$. Mit ihm kann man jede Potenz umschreiben:

$$x^k = e^{k \cdot \ln x}$$

Für die kreisende Bewegung braucht man **Kosinus und Sinus**. Der Punkt auf dem Kreis mit Radius 1 beim Winkel $\varphi$ ist $(\cos \varphi, \sin \varphi)$. Wächst der Winkel gleichmäßig, $\varphi = \omega t$, läuft der Punkt gleichmäßig im Kreis.

Die drei Maße fließend:

| Maß | Sprung (Abschnitt 7) | Fluss |
|---|---|---|
| Wachstum | $x \to 2x$ | $x(t) = x_0 \cdot e^{a t}$ |
| Schritt | $x \to x + 1$ | $x(t) = x_0 + t$ |
| Kreisend | Winkel $+\alpha$ | Winkel $\varphi_0 + \omega t$ |

## 9 · Wegkurven: aus festen Punkten werden Funktionsgraphen

Jetzt in die Ebene. Eine Verwandlung, die von einer Zeit $t$ abhängt und die Grundregel aus Abschnitt 8 erfüllt, heißt **einparametrige Gruppe**: $t$ lang und danach $s$ lang zu verwandeln ist dasselbe wie $s + t$ lang. Der Weg, den ein einzelner Punkt dabei zurücklegt, ist seine **Wegkurve**.

**Das Beispiel, auf dem alles aufbaut.** Jede Zahl eines Punktes wächst mit ihrer eigenen Rate:

$$(x,\ y,\ w) \to (e^{a t} x,\ e^{b t} y,\ w)$$

Fest bleiben drei Punkte: der Nullpunkt $(0, 0, 1)$, der Fernpunkt der $x$-Achse $(1, 0, 0)$ und der Fernpunkt der $y$-Achse $(0, 1, 0)$. Sie bilden ein Dreieck, das **Wächterdreieck**.

Verfolge den Punkt, der bei $(1, 1)$ startet. Er ist zur Zeit $t$ bei

$$x = e^{a t}, \qquad y = e^{b t}$$

Die Zeit lässt sich herausrechnen. Aus der ersten Gleichung folgt $t = \ln(x) / a$. Eingesetzt in die zweite und mit der Potenzregel aus Abschnitt 8:

$$y = e^{b \ln(x) / a} = x^{b/a}$$

**Die Wegkurve ist ein Funktionsgraph.** Welcher, hängt nur vom Verhältnis der Raten ab:

| Raten | Verhältnis $b/a$ | Wegkurve |
|---|---|---|
| $a = 1,\ b = 2$ | 2 | $y = x^2$, eine Parabel |
| $a = 1,\ b = -1$ | $-1$ | $y = 1/x$, eine Hyperbel |
| $a = 2,\ b = 1$ | $\tfrac12$ | $y = \sqrt{x}$ |
| $a = 1,\ b = 3$ | 3 | $y = x^3$ |

Ein anderer Startpunkt $(x_0, y_0)$ gibt dieselbe Kurvenart, nur gestreckt: $y / y_0 = (x / x_0)^{b/a}$. Alle Wegkurven zusammen füllen die ganze Ebene. Durch jeden Punkt geht genau eine.

**Kreisend.** Der Punkt $(x, y)$ dreht sich mit dem Winkel $\omega t$ um den Nullpunkt, und sein Abstand wächst mit $e^{\sigma t}$. In Winkel und Abstand geschrieben:

$$r = r_0\, e^{\sigma t}, \qquad \varphi = \varphi_0 + \omega t \quad\Longrightarrow\quad r = r_0\, e^{(\sigma / \omega)(\varphi - \varphi_0)}$$

Das ist eine **logarithmische Spirale**. Fest bleibt der Nullpunkt, dazu zwei imaginäre Punkte auf der Ferngeraden.

**Schritt.** Die Kette aus Abschnitt 7, zweimal hintereinander: $x$ wächst gleichmäßig, und $y$ wächst um das, was $x$ gerade ist. Vom Nullpunkt aus gibt das

$$x = s\,t, \qquad y = \tfrac12\, s\,k\,t^2 \quad\Longrightarrow\quad y = \frac{k}{2s}\,x^2$$

eine **Parabel**. Hier sind feste Punkte zusammengefallen.

Im Raum kommt eine dritte Zahl $z$ mit ihrer eigenen Rate dazu. Das Wächterdreieck wird zum **Wächtertetraeder** mit vier festen Punkten.

Buchstelle: Whicher, Kap. VI, „Ebene Wegkurven“ und „Spiral-Matrix“. Die Herleitung aller Wegkurven steht bei Ostheimer/Ziegler, *Skalen und Wegkurven*, Teil „Wegkurven und Wegflächen“.

## 10 · Wächter an beliebiger Stelle

In Abschnitt 9 lagen die Wächter bequem: der Nullpunkt und zwei Fernpunkte auf den Achsen. Die festen Punkte können aber überall liegen. Dann hilft ein Umweg.

Jeder Punkt $p$ lässt sich als **Mischung** der drei Wächter schreiben:

$$p = c_1 E_1 + c_2 E_2 + c_0 E_0$$

Die drei Mengen $c_1, c_2, c_0$ sagen, wie viel von jedem Wächter drinsteckt. Die Verwandlung nimmt dann jede Menge mit ihrem eigenen Faktor mal und mischt neu:

$$p(t) = c_1\, e^{a t} E_1 + c_2\, e^{b t} E_2 + c_0\, E_0$$

Liegen die Wächter wie in Abschnitt 9, sind die Mengen einfach die Koordinaten des Punktes. Abschnitt 9 ist also ein Sonderfall dieser Rechnung.

Die Mengen findet man mit der Umkehrmatrix aus Abschnitt 6. Man schreibt die Wächter als Spalten in eine Matrix $E$. Dann ist $p = E \cdot c$, also $c = E^{-1} \cdot p$.

Im Code baut **das Wächtertetraeder** — `basis` — die Matrix aus den vier Spalten $E_1, E_2, E_3, E_0$ und ihre Umkehrung `Einv`. **Die Wegkurve** — `evalG` — rechnet: Mengen mal Faktoren, dann neu mischen.

Ein Wächter muss nicht im Unendlichen liegen. Der Fernpunkt $(1, 0, 0, 0)$ wird zu $(1, 0, 0, \kappa)$, und das ist für $\kappa > 0$ der gewöhnliche Punkt $(1/\kappa, 0, 0)$. Im Code heißt diese Zahl `kappa`, auf der Seite „Nähe der Wächter“. Sobald die Wächter im Endlichen liegen, laufen die Wegkurven von einem Wächter zum anderen. Manche davon führen durch die Fernebene, wie der Punkt in der Tabelle von Abschnitt 6.

---

## 11 · Wie die Grafikkarte eine Strecke zeichnet

Ab hier geht es ums Zeichnen. Die Grafikkarte zeichnet eine Strecke von $a$ nach $b$, indem sie alle Mischungen bildet:

$$(1 - s)\, a + s\, b, \qquad s \text{ von } 0 \text{ bis } 1$$

Sie tut das mit den **homogenen Zahlen, so wie sie übergeben werden**. Das ist ein Glücksfall, und zugleich eine Falle.

Nach Abschnitt 3 ist eine Gerade geschlossen wie ein Kreis. Zwei Punkte teilen sie also in **zwei** Stücke, wie zwei Punkte einen Kreis in zwei Bögen teilen. Eines der Stücke enthält den Fernpunkt. Welches Stück die Grafikkarte zeichnet, entscheiden die Vorzeichen der übergebenen Zahlen. Ein Beispiel in der Ebene:

- $a = (1, 0, 1)$ und $b = (-1, 0, 1)$. Die Mischung ist $(1 - 2s,\ 0,\ 1)$. Das $x$ läuft von 1 über 0 nach $-1$: das **endliche** Stück.
- Derselbe Punkt $b$, aber mit $-1$ malgenommen: $b' = (1, 0, -1)$. Jetzt ist die Mischung $(1,\ 0,\ 1 - 2s)$, also $x = 1 / (1 - 2s)$. Das $x$ läuft von 1 nach $+\infty$, springt bei $s = \tfrac12$ durch den Fernpunkt und kommt von $-\infty$ nach $-1$ zurück: das Stück **durchs Unendliche**.

Daraus folgt die wichtigste Regel des Codes: **Die Punkte werden nie auf $w = 1$ geteilt.** Wer teilt, macht jedes $w$ positiv und bekommt immer das endliche Stück. Bei einer Hyperbel wäre das die falsche Hälfte.

Die Verwandlung liefert die Vorzeichen von selbst richtig. Mischt man zwei Punkte und verwandelt dann, kommt dasselbe heraus wie umgekehrt, das ist die zweite Eigenschaft aus Abschnitt 6. Die Grafikkarte zeichnet also genau das Bild der ursprünglichen Kante, auch wenn es durchs Unendliche führt.

## 12 · Zwei Kopien und eine Kamera ohne Horizont

Ein Hindernis bleibt. Die Kamera rechnet jeden Punkt mit einer eigenen Matrix aus Abschnitt 6 in vier neue Zahlen um, der **Kameramatrix**. Die vierte ist, grob gesagt, **die Tiefe vor der Kamera**, und die Grafikkarte zeichnet nur, was eine positive Tiefe hat. Ein Punkt, dessen Zahlen gerade das falsche Vorzeichen tragen, verschwindet, obwohl $-h$ derselbe Punkt wäre.

Die Lösung hat drei Teile:

1. **Jede Zeichenebene wird zweimal gezeichnet**, einmal mit den Zahlen $h$ und einmal mit $-h$. So hat jeder Punkt in einer der beiden Kopien die richtige Tiefe. Im Code legt `hLayer` beide Kopien an, der Schalter zwischen ihnen heißt `uSign`.
2. **Jede Kopie verwirft Bildpunkte mit $w < 0$.** Ohne diese Regel erschiene ein Punkt, der hinter der Kamera liegt, gespiegelt vor ihr. Mit ihr zeichnet jede Kopie nur, was wirklich vor der Kamera liegt. Fernpunkte mit $w = 0$ kommen durch.
3. **Die Kamera schneidet nichts in der Ferne ab.** Eine gewöhnliche three.js-Kamera zeichnet nur bis zu einer größten Entfernung, und Fernpunkte liegen immer dahinter. `patchInfiniteFar` ändert zwei Zahlen der Kameramatrix so, dass diese Grenze im Unendlichen liegt. Ab da sind Fluchtpunkte sichtbar.

Eine ganze Gerade zeichnet `line(Q, d)` als zwei Strecken, von $Q$ zum Fernpunkt $(d, 0)$ und zum Fernpunkt $(-d, 0)$. Das sind nach Abschnitt 11 die zwei Hälften der Geraden, zusammen die ganze.

Alles liegt durchscheinend übereinander, auch verdeckte Kanten sind sichtbar, wie in einer Zeichnung aus Whichers Buch. Die Reihenfolge legt `renderOrder` fest.

---

## 13 · Die Funken

Ab hier die Modi der Skizze. Ein Funke ist ein Punkt, der auf seiner Wegkurve aus Abschnitt 9 davonläuft. Die Rechnung dafür stand schon in Abschnitt 10.

**Die Gruppe des Funkens** — im Code `makeGroup` — legt für jeden Funken ein Wächtertetraeder und die Raten fest. Die drei Maße „Wachstum“, „Kreisend“ und „Schritt“ auf der Seite sind die drei Fälle aus Abschnitt 9. Die Tabelle dort sagt, welche Kurve entsteht: Potenzkurven, Spiralen, Parabeln.

Zwei Regler verändern die Gruppe:

- **Streuung** — `streu` — dreht das Tetraeder für jeden Funken ein wenig zufällig und wackelt an den Raten. Bei 0 laufen alle Funken einer Ecke auf Wegkurven derselben Gruppe. Dann sieht man Whichers geordnete Kurvenfamilien, wie in der Tabelle von Abschnitt 9.
- **Nähe der Wächter** — `kappa` aus Abschnitt 10 — holt die Wächter aus dem Unendlichen. Dann laufen manche Funken durchs Unendliche und kommen von der anderen Seite des Bildes zurück.

**Der Startpunkt** — `emissionPoint` — ist eine Ecke oder ein zufälliger Punkt auf einer Kante. Den Anteil der Kanten stellt der Regler „Anteil aus Kanten“ ein. **Die Richtung** — `outward` — wählt die Zeitrichtung so, dass der Funke zuerst von der Mitte weg läuft.

Den Schweif schleppt der Funke nicht mit. Die Skizze rechnet ihn in jedem Bild neu: 28 Punkte rückwärts entlang derselben Wegkurve, zum Ende hin blasser.

## 14 · Punktuell und linienhaft

Eine Kurve kann auf zwei Arten entstehen. **Punktuell** als Spur eines wandernden Punktes, so wie in Abschnitt 13. Oder **linienhaft**, als Kurve, die von vielen Geraden berührt wird. Diese Kurve heißt **Hüllkurve**.

Du kennst eine Hüllkurve aus Fadenbildern. Verbinde auf zwei Achsen den Punkt $(t, 0)$ mit dem Punkt $(0, 1 - t)$, für viele $t$ zwischen 0 und 1. Keine einzige der Strecken ist gebogen. Trotzdem erscheint zwischen ihnen ein Parabelbogen, die Kurve $\sqrt{x} + \sqrt{y} = 1$. Whicher nennt das den Regenbogen: Die Kurve ersteht zwischen den Strahlen.

Die Funken-Art „linienhaft“ macht das mit den Kanten. Nicht ein Punkt, sondern eine **ganze Kante** wird von der Gruppe weitergetragen. Die Skizze zeichnet 14 Nachbilder der Kante hintereinander, im Code `NECHO`. In der Ebene hüllen sie eine Kurve ein. Im Raum fegen sie eine Fläche aus Geraden aus. Sehr kurze Kanten, etwa beim Kreis mit seinen 120 Stücken, verlängert die Skizze vorher zu längeren Geradenstücken, im Code `ext`.

Buchstelle: Whicher, Kap. IV, „Projektive Erzeugung von Kurven – Der Regenbogen“.

## 15 · Homologie und Elation: der Körper verwandelt sich

Bisher liefen nur die Funken. Jetzt verwandelt sich der Körper selbst. Die Verwandlung heißt **Homologie**. Sie hat einen festen Punkt $O$ und eine feste Ebene $\omega$ (in der Ebene: eine feste Gerade).

**Zwei vertraute Beispiele zuerst.** Beide stehen in der Ebene, mit $\omega$ = Ferngerade $(0, 0, 1)$ aus Abschnitt 4.

- $O$ ist der Nullpunkt. Dann ist die Homologie eine **Streckung** um den Nullpunkt. Alle Punkte gleiten auf Strahlen durch $O$, und nichts im Endlichen bleibt stehen außer $O$.
- $O$ ist ein Fernpunkt, der selbst auf $\omega$ liegt, etwa $(1, 0, 0)$. Dann ist sie eine **Verschiebung** nach rechts. Diese Sonderform, bei der $O$ auf $\omega$ liegt, heißt **Elation**.

Streckung und Verschiebung sind also Homologie und Elation, deren Wächter im Unendlichen liegen. Holt man $O$ und $\omega$ ins Endliche, wird aus derselben Verwandlung eine perspektivische Verzerrung.

**Die Formel.** Mit einem Faktor $\mu$ lautet die Homologie im Code (`homology`):

$$M \cdot p = p + (\mu - 1) \cdot \frac{\omega \cdot p}{\omega \cdot O} \cdot O$$

Sie ist leichter zu lesen, als sie aussieht:

- $\omega \cdot p$ ist das Skalarprodukt aus Abschnitt 4. Es ist null, wenn $p$ auf $\omega$ liegt. **Punkte auf $\omega$ bleiben also stehen.**
- Für $p = O$ ergibt sich $O + (\mu - 1) O = \mu O$, nach Abschnitt 4 derselbe Punkt. **$O$ bleibt stehen.**
- Jeder andere Punkt bekommt ein Stück $O$ dazugemischt. Mischungen aus $p$ und $O$ liegen auf der Geraden durch beide. **Jeder Punkt gleitet also auf seinem Strahl durch $O$.**

Probier die Streckung aus: $O = (0, 0, 1)$ und $\omega = (0, 0, 1)$ geben $\omega \cdot O = 1$ und $\omega \cdot p = w$. Die Formel liefert $(x,\ y,\ \mu w)$, und das ist der Punkt $(x/\mu,\ y/\mu)$.

**Ein Beispiel durchs Unendliche.** $O$ ist der Nullpunkt, $\omega$ die Gerade $y = -1$, als drei Zahlen $(0, 1, 1)$. Dann ist $\omega \cdot O = 1$. Mit $\mu = \tfrac12$ wird jeder Punkt $(x, y, w)$ zu $(x,\ y,\ \tfrac12 w - \tfrac12 y)$:

| Punkt | nachher homogen | nachher |
|---|---|---|
| $(0, -1)$, auf $\omega$ | $(0, -1, 1)$ | bleibt $(0, -1)$ |
| $(0; -0{,}5)$, zwischen $O$ und $\omega$ | $(0;\ -0{,}5;\ 0{,}75)$ | $(0;\ -0{,}67)$, näher an $\omega$ |
| $(0, 1)$, über $O$ | $(0, 1, 0)$ | Fernpunkt |
| $(0, 2)$ | $(0;\ 2;\ -0{,}5)$ | $(0, -4)$, jenseits von $\omega$ |

Die Punkte ziehen zu $\omega$ hin. Wer oberhalb von $O$ liegt, erreicht $\omega$ nur, indem er nach oben ins Unendliche läuft und von unten zurückkommt.

**Auf der Seite** atmet der Faktor: $\mu = e^{A \sin \varphi}$, mit $A$ vom Regler „Atem“. Wird $\mu$ klein, ziehen die Punkte zu $\omega$, wird er groß, ziehen sie zu $O$. Die Statuszeile zählt, wie viele Ecken gerade „jenseits des Unendlichen“ liegen, also ein negatives $w$ haben, im Code `beyond`.

Die Elation — im Code `elation` — ist dieselbe Formel ohne den Bruch, mit einem Schritt $s$: $M \cdot p = p + s\,(\omega \cdot p)\, O$. Sie läuft im Schrittmaß aus Abschnitt 7, die Homologie im Wachstumsmaß.

Buchstelle: Whicher, Kap. VI, „Zweidimensionale projektive Kurvenverwandlungen – Homologie und Elation“, Figur 40 und 41, und „Verwandlungen im Raum“, Figur 49.

## 16 · Polarität: Punkt und Ebene tauschen die Rollen

Abschnitt 4 hat gezeigt: Punkt und Gerade sind beide drei Zahlen. Ein Kreis macht daraus eine feste Zuordnung. Er ordnet jedem Punkt eine Gerade zu und jeder Geraden einen Punkt.

**Die Zeichnung.** Eine **Tangente** an einen Kreis ist eine Gerade, die ihn in genau einem Punkt berührt, ohne ihn zu schneiden. Nimm einen Kreis und einen Punkt $P$ außerhalb. Von $P$ aus gibt es zwei Tangenten an den Kreis. Die Gerade durch ihre beiden Berührpunkte ist die **Polare** von $P$. Umgekehrt heißt $P$ der **Pol** dieser Geraden.

**Die Formel.** Für den Kreis mit Radius $r$ um den Nullpunkt hat der Punkt $P = (p, q)$ die Polare

$$p\,x + q\,y = r^2$$

Probe mit dem Kreis vom Radius 1 und $P = (2, 0)$. Die Polare ist $2x = 1$, also die senkrechte Gerade $x = \tfrac12$. Und tatsächlich berühren die Tangenten von $(2, 0)$ den Kreis bei $(\tfrac12, \pm\tfrac{\sqrt3}{2})$, genau auf dieser Geraden.

Was die Formel zeigt:

- Ein Punkt **außerhalb** hat eine Polare, die den Kreis schneidet.
- Ein Punkt **auf** dem Kreis hat seine Tangente als Polare.
- Ein Punkt **innerhalb** hat eine Polare außerhalb des Kreises. Je näher er der Mitte kommt, desto weiter weg liegt sie.
- **Die Mitte selbst** hat die Polare $0 \cdot x + 0 \cdot y = r^2$. Auf ihr liegt kein gewöhnlicher Punkt: Sie ist die Ferngerade.

**Im Raum** tritt eine Kugel an die Stelle des Kreises und eine Ebene an die Stelle der Geraden. Der Punkt $P$ hat die Polarebene $P \cdot x = r^2$.

Die Skizze braucht die umgekehrte Richtung: Zu einer Fläche $n \cdot x = d$ des Körpers sucht sie den **Pol**. Er ist

$$P = \frac{r^2}{d}\, n$$

Probe: Die Polarebene von diesem $P$ ist $\tfrac{r^2}{d}\, n \cdot x = r^2$, gekürzt $n \cdot x = d$. In homogenen Zahlen schreibt man den Pol ohne Bruch als $(r^2 n,\ d)$. Geht die Ebene durch die Mitte, ist $d = 0$, und der Pol ist ein Fernpunkt. Liegt die Kugelmitte bei $c$ statt im Nullpunkt, rechnet der Code alles von $c$ aus:

$$d' = d - n \cdot c, \qquad \text{Pol} = (d'\,c + r^2\,n,\ \ d')$$

**Der Polarkörper.** Nimm von jeder Fläche eines Körpers den Pol. Diese Pole sind die Ecken eines neuen Körpers. Aus jeder Ecke des alten wird eine Fläche des neuen, und Kanten werden zu Kanten. Aus dem Würfel mit 6 Flächen und 8 Ecken wird so das Oktaeder mit 6 Ecken und 8 Flächen. Im Code sind die Flächen `B.faces`, und welche Flächen an einer Kante zusammenstoßen, steht in `polarAdj`.

**Warum der Polarkörper richtig durchs Unendliche aufbricht.** Die Formel für den Pol ist eine Mischungsregel wie in Abschnitt 6: Der Pol einer Mischung zweier Ebenen ist die Mischung ihrer Pole. Die Kante des Polarkörpers gehört zu den Ebenen, die sich um die alte Kante von einer Fläche zur Nachbarfläche drehen. Die Pole dieser Ebenen sind genau die Mischungen, die die Grafikkarte nach Abschnitt 11 zeichnet.

Auf der Seite wandert die Kugelmitte. Verlässt sie den Körper, geht eine Flächenebene durch sie, deren $d'$ wird null, und ihr Pol springt ins Unendliche. Die Statuszeile meldet dann: „Polarkörper öffnet sich durchs Unendliche“.

Buchstelle: Whicher, Kap. VII, „Polarreziproke Verwandlungen“ und „Pol und Polare in bezug auf die Sphäre“.

## 17 · Wegflächen und Eier nach Ostheimer/Ziegler

Das Maß **Ei** legt die Wächter so, wie Lawrence Edwards es für Knospen und Eier tut. Man braucht dafür drei Funktionen, die aus $e^t$ gebaut sind:

$$\cosh t = \frac{e^t + e^{-t}}{2}, \qquad \sinh t = \frac{e^t - e^{-t}}{2}, \qquad \tanh t = \frac{\sinh t}{\cosh t}$$

$\tanh t$ läuft von $-1$ bis $1$, wenn $t$ von $-\infty$ nach $+\infty$ läuft. Und es gilt $\dfrac{1}{\cosh^2 t} + \tanh^2 t = 1$.

**Der Schnitt durch das Ei.** Zuerst in einer senkrechten Ebene. Die Wächter sind drei Punkte:

- der obere Pol $A = (0, h, 1)$,
- der untere Pol $B = (0, -h, 1)$,
- der Fernpunkt der waagrechten Richtung $X_\infty = (1, 0, 0)$.

Nach Abschnitt 10 mischt man diese drei, jede Menge mit ihrem eigenen Wachstum. $A$ wächst mit $e^{t}$, $B$ mit $e^{-t}$ und $X_\infty$ mit $e^{\beta t}$. Wer zur Zeit 0 am Äquator bei $(R, 0)$ steht, ist zur Zeit $t$ hier:

$$R\,e^{\beta t} \cdot X_\infty + \tfrac12 e^{t} \cdot A + \tfrac12 e^{-t} \cdot B = \big(R\,e^{\beta t},\ \ h \sinh t,\ \ \cosh t\big)$$

Geteilt durch die dritte Zahl ergibt das die **Profilkurve**:

$$x = \frac{R\, e^{\beta t}}{\cosh t}, \qquad y = h \tanh t$$

Was $\beta$ bewirkt:

- **$\beta = 0$:** $(x/R)^2 + (y/h)^2 = \tfrac{1}{\cosh^2 t} + \tanh^2 t = 1$. Das ist eine Ellipse durch beide Pole.
- **$0 < \beta < 1$:** Für positive $t$ ist $x$ größer als für negative. Die Kurve wird oben breiter, ein **Ei** mit dem stumpfen Ende bei $A$.
- **$\beta > 1$:** $e^{\beta t}$ wächst schneller, als $\cosh t$ bremsen kann. Die Kurve erreicht $A$ nicht mehr, sondern läuft ins Unendliche: ein **Wirbel**.
- Negatives $\beta$ spiegelt alles von oben nach unten.

Der Code verwendet andere Raten: $X_\infty$ wächst mit $\beta + 1$, $A$ mit $2$ und $B$ mit $0$. Das ist dasselbe, denn alle Raten um dieselbe Zahl zu verschieben nimmt alle Mengen mit demselben Faktor mal. Nach Abschnitt 4 bleibt der Punkt derselbe.

**Die Fläche.** Dreht man die Profilkurve um die senkrechte Achse, entsteht eine Fläche. Aus der Ellipse wird ein **Ellipsoid**, eine in die Länge gezogene Kugel. Aus dem Ei-Profil wird ein Ei, aus dem Wirbel-Profil ein Wirbel. Ostheimer/Ziegler nennen sie **Wegfläche**. Der vierte Wächter kommt im Raum dazu: Zu den waagrechten Ebenen gehört ein Paar imaginärer Punkte auf ihrer Ferngeraden, und sie sorgen für die kreisende Bewegung um die Achse wie in Abschnitt 7. Die Funken drehen sich deshalb zusätzlich um die Achse. Ihre Wegkurven sind Spiralen, die auf solchen Flächen von $B$ nach $A$ laufen. Ostheimer/Ziegler nennen das die fließende Bewegung.

Ostheimer/Ziegler nennen $\beta$ das Verhältnis von Streckweite zu Drehweite. Edwards beschreibt dieselbe Form mit $\lambda = (1 + \beta) / (1 - \beta)$. Die Statuszeile zeigt beide Zahlen.

Im Code: `eiform` ist $\beta$, `poleH` ist $h$, und `guardEggs` zeichnet die Wegfläche durch den Äquator des Körpers, mit 20 Meridianen und 7 Breitenkreisen. In der Ebene zeichnet es statt einer Fläche vier ineinanderliegende Eilinien. Der Regler „Nähe der Wächter“ rückt hier die beiden Pole zusammen.

Buchstelle: Ostheimer/Ziegler, *Skalen und Wegkurven*, Abschnitt 2.13 („Der Edwardsche λ-Parameter“) und 3.11 („Wegflächen“).

## 18 · Die Linienkongruenz nach Adams

Die Funken-Art **Kongruenz** zeichnet keine Kurven, sondern Geraden.

**Zwei Wörter vorab.** Zwei Geraden im Raum heißen **windschief**, wenn sie sich weder treffen noch parallel sind. Eine Fläche, die ganz aus geraden Linien besteht, heißt **Regelfläche**. Ein bekanntes Beispiel ist der Kühlturm, ein Hyperboloid: Man kann ihn aus lauter geraden Fäden spannen, die schräg zwischen zwei Ringen laufen.

**Die Regel.** Adams’ Urform ist eine **elliptische lineare Linienkongruenz**, eine Schar von Geraden mit einer besonderen Eigenschaft: **Durch jeden Punkt des Raumes geht genau eine ihrer Geraden.** Sie ist so gebaut:

- Es gibt eine senkrechte **Achse** und eine waagrechte **Taillenebene** durch die Mitte. Im Code legt `congFrame` beide fest. In der Ebene steht die Achse senkrecht auf der Zeichenfläche.
- Durch jeden Punkt der Taillenebene geht eine Gerade. Sie neigt sich **quer zur Richtung nach außen**, und zwar umso stärker, je weiter der Punkt von der Achse entfernt ist.
- Genauer: Liegt der Taillenpunkt im Abstand $r$ von der Achse, bildet seine Gerade mit der Achse den Winkel $\delta$ mit $\tan \delta = r / k$. Die Zahl $k$ ist das **Größenmaß**. Im Abstand $k$ steht jede Gerade unter 45°.
- Die Achse selbst gehört zur Kongruenz. Weit draußen liegen die Geraden fast waagrecht.

Als Richtung geschrieben, für den Taillenpunkt $(x, y)$:

$$\big(-h\,y,\ \ h\,x,\ \ k\big)$$

Der waagrechte Teil $(-h y,\ h x)$ steht senkrecht auf $(x, y)$, zeigt also quer. Er hat die Länge $r$, der senkrechte Teil die Länge $k$, das gibt $\tan \delta = r/k$. Die Zahl $h$ ist $+1$ oder $-1$ und legt den **Windungssinn** fest, rechts oder links.

**Warum durch jeden Punkt genau eine Gerade geht.** Nimm einen Punkt $Q$ in der Höhe $s$ über der Taillenebene, waagrecht bei $(p, q)$. Welcher Taillenpunkt $(x, y)$ schickt seine Gerade durch $Q$? Die Gerade steigt um $s$, wenn sie sich um $s/k$ ihres waagrechten Teils zur Seite bewegt. Mit $m = h\,s/k$ muss also gelten:

$$p = x - m\,y, \qquad q = y + m\,x$$

Das lässt sich nach $x$ und $y$ auflösen, im Code `congLine`:

$$x = \frac{p + m\,q}{1 + m^2}, \qquad y = \frac{q - m\,p}{1 + m^2}$$

Der Nenner $1 + m^2$ ist nie null. Es gibt also für jeden Punkt eine Lösung, und nur eine.

**Was daraus auf der Seite wird:**

- Jede Ecke sendet ihre eine Gerade.
- Die Punkte einer Kante senden ihre Geraden. Adams definiert die Kongruenz als alle Geraden, die zwei feste, imaginäre Leitlinien treffen. Die Geraden durch eine Kante treffen also drei feste Geraden: die Kante und die zwei Leitlinien. Solche Geraden bilden eine Regelfläche, ein Hyperboloid oder ein Sattel (hyperbolisches Paraboloid).
- Die **Lemniskate** ist die liegende Acht $(x^2 + y^2)^2 = a^2 (x^2 - y^2)$. Liegt sie in der Taillenebene, bilden die Geraden durch ihre Punkte Adams’ lemniskatische Regelfläche. Mit $k = a$, wie auf der Seite voreingestellt, ist das bis auf den Windungssinn die Fläche $(x^2 + y^2)^2 = (k^2 - z^2)(x^2 - y^2) + 4k\,xyz$.

`threads` zeichnet dazu ein **Fadenmodell** wie Adams’ Holzmodelle: 48 Geraden, gespannt zwischen zwei waagrechten Brettern in der Höhe $\pm 1{,}9$. Dazu kommen die Achse und der Kreis vom Radius $k$ in der Taillenebene.

Buchstelle: Adams, *Lemniskatische Regelflächen*, Anhang zu den mathematischen Modellen, Abschnitte 2.1 bis 2.8 („Skizze der mathematischen Grundlagen“).

## 19 · Kristallformen nach Ziegler

Die Form **Kristall** hat keine feste Liste von Ecken. Sie entsteht aus einer Symmetrie und einem einzigen Punkt.

**Die Symmetrien des Würfels.** Eine Symmetrie ist eine Drehung oder Spiegelung, nach der der Würfel wieder genauso daliegt. Es gibt drei Sorten von Drehachsen:

| Achse | Anzahl | Drehungen je Achse | Zähligkeit |
|---|---|---|---|
| durch zwei gegenüberliegende Flächenmitten | 3 | um 90°, 180°, 270° | 4-zählig |
| durch zwei gegenüberliegende Ecken | 4 | um 120°, 240° | 3-zählig |
| durch zwei gegenüberliegende Kantenmitten | 6 | um 180° | 2-zählig |

Das sind $3 \cdot 3 + 4 \cdot 2 + 6 \cdot 1 = 23$ Drehungen, mit dem Stillstehen 24. Nimmt man zu jeder Drehung noch ihr Spiegelbild durch die Mitte, sind es **48 Symmetrien**. Das Ikosaeder hat auf dieselbe Weise 5-, 3- und 2-zählige Achsen und **120 Symmetrien**. Im Code erzeugt `groupMats` alle Symmetrien als Matrizen aus Abschnitt 6.

**Die Bahn eines Punktes.** Nimm einen Punkt auf einer Kugel um die Mitte und wende alle 48 Symmetrien auf ihn an. Heraus kommen bis zu 48 Punkte, seine **Bahn**. Liegt der Punkt auf einer Achse oder einer Spiegelebene, fallen einige davon zusammen, und die Bahn hat weniger Punkte. Ein Punkt genau auf einer 4-zähligen Achse hat nur 6 Bildpunkte, die Ecken eines Oktaeders.

**Das Lagetypendreieck.** Die 48 Symmetrien zerlegen die Kugel in 48 gleiche Dreiecke. Jedes davon hat eine Ecke auf einer 4-zähligen, eine auf einer 3-zähligen und eine auf einer 2-zähligen Achse. Ein solches Dreieck genügt: Jeder Punkt der Kugel ist das Bild eines Punktes darin. Ziegler nennt es das **Lagetypendreieck**. Im Code stehen seine Ecken in `TRI`: $(0, 0, 1)$, $(1, 1, 1)$ und $(1, 0, 1)$, jeweils auf Länge 1 gebracht.

**Aus der Bahn wird ein Körper.** Es gibt zwei Wege:

- **Punktform:** Die Bahnpunkte sind die Ecken. Der Körper ist ihre **konvexe Hülle**, die Haut, die sich straff um alle Punkte spannt. `convexHull` baut sie Punkt für Punkt: Jeder neue Punkt entfernt die Flächen, die er von außen sehen kann, und verbindet sich mit ihrem Rand.
- **Flächenform:** In jedem Bahnpunkt legt man die Ebene, die die Kugel dort berührt. Diese Ebenen sind die Flächen. Nach Abschnitt 16 ist die Tangentialebene im Kugelpunkt $P$ genau die Polarebene von $P$. Die Flächenform ist also der Polarkörper der Punktform. Der Code nimmt deshalb die Pole der Hüllflächen und baut aus ihnen noch einmal eine Hülle.

**Wo der Punkt liegt, bestimmt die Klasse.** Beim Würfel:

| Lage im Dreieck | Punktform | Flächenform |
|---|---|---|
| Ecke, 4-zählig | Oktaeder | Würfel |
| Ecke, 3-zählig | Würfel | Oktaeder |
| Ecke, 2-zählig | Kuboktaeder | Rhombendodekaeder |
| Seite 4–3 | Rhombenkuboktaeder | Deltoidikositetraeder |
| Seite 4–2 | Oktaederstumpf | Tetrakishexaeder |
| Seite 3–2 | Würfelstumpf | Triakisoktaeder |
| Inneres | Kuboktaederstumpf | Disdyakisdodekaeder |

Beim Ikosaeder ist es dieselbe Tabelle mit Ikosaeder, Dodekaeder, Ikosidodekaeder und ihren Verwandten, im Code `KNAMES`.

Innerhalb einer Zeile bleibt die Klasse gleich, nur die Maße ändern sich. Ein **archimedischer** Vertreter, mit lauter gleich langen Kanten, liegt jeweils nur an einer einzigen Stelle der Seite oder des Inneren. Wandert der Punkt — im Code `wanderLage` —, geht der Körper fließend in seine Nachbarn über. Nähert er sich einer Seite des Dreiecks, schrumpfen Kanten auf null, und der Körper wechselt die Klasse. Weil der Kristall am Ende ein gewöhnlicher Körper ist, wirken Homologie, Polarität und Funken auf ihn wie auf jeden anderen.

Buchstelle: Ziegler, *Morphologie von Kristallformen und symmetrischen Polyedern*, Abschnitte 5.1, 5.2 und 5.6.

## 20 · Knick-Funken nach Locher-Ernst

Beim Kreis war die **Tangente** in Abschnitt 16 die Gerade, die ihn in einem Punkt berührt. Jede Kurve hat an jeder Stelle so eine Gerade. Sie zeigt, wohin die Kurve dort gerade läuft. Locher-Ernst betrachtet an jeder Stelle beides zusammen, den Punkt und seine Tangente, und nennt das Paar ein **Element**.

Fährt man eine Kurve entlang, tun Punkt und Tangente je eines von zwei Dingen: Sie laufen in ihrem Sinn weiter, oder sie kehren um. Der Punkt kehrt um, wenn er stehen bleibt und zurückläuft. Die Tangente kehrt um, wenn sie sich erst in die eine Richtung dreht und dann in die andere. Daraus entstehen vier Sorten:

| Element | Punkt | Tangente | Bild | Beispielkurve |
|---|---|---|---|---|
| regulär | läuft weiter | dreht weiter | ein gewöhnlicher Bogen | $y = x^2$ bei 0 |
| Wendestelle | läuft weiter | kehrt um | ein S: die Kurve wechselt die Seite, zu der sie sich biegt | $y = x^3$ bei 0 |
| Dornspitze | kehrt um | dreht weiter | ein Dorn: der Punkt läuft in die Spitze und zurück | $(t^2,\ t^3)$ bei $t = 0$ |
| Schnabelspitze | kehrt um | kehrt um | ein Schnabel: beide Äste liegen auf derselben Seite der Tangente | $(t^2,\ t^4 + t^5)$ bei $t = 0$ |

Die Knick-Funken laufen auf solchen Bögen. `knickLocal` enthält die Beispielkurven, verschoben und gestreckt, damit die besondere Stelle in der Mitte der Bahn liegt. Jeder Funke lost seine Sorte aus. Seine Bahn liegt in einer Ebene durch die Mitte und führt quer zur Mitte, leicht nach außen.

**Der Gegenfunke.** Zu jedem Funken läuft ein zweiter, der Pol seiner Tangente bezüglich der Kugel um die Mitte, nach Abschnitt 16. Die Kugel hat den Radius vom Regler „Kugelradius“. Der Gegenfunke ist also der Punkt, der zur Tangente gehört. Umgekehrt ist die Tangente des Gegenfunkens die Polare des Funkenpunkts. **Punkt und Tangente tauschen die Rollen.**

Daraus folgt Locher-Ernsts Tafel. Kehrt beim Funken der Punkt um (Dornspitze), kehrt beim Gegenfunken die Tangente um (Wendestelle), und umgekehrt. Bei der Schnabelspitze kehren beide um, sie bleibt Schnabelspitze. Regulär bleibt regulär. Die Seite markiert beide Stellen mit einem Wächterpunkt. `knickElement` rechnet für jede Stelle Punkt, Tangente, Pol und Polare.

**Warum die Bahn quer zur Mitte führt.** Der Pol einer Geraden im Abstand $a$ von der Mitte liegt im Abstand $r^2 / a$, das folgt aus der Formel in Abschnitt 16. Liefe der Funke nach außen, ginge seine Tangente fast durch die Mitte, $a$ wäre klein, und der Gegenfunke säße fast im Unendlichen. Läuft er quer, bleibt $a$ ungefähr so groß wie der Körper, und der Gegenfunke bleibt innerhalb der Kugel sichtbar.

**Warum das keine Wegkurven sind.** Auf einer Wegkurve bringt die Gruppe jeden Punkt in jeden anderen. Alle Stellen sind also gleich gebaut, und eine einzelne Wendestelle kann es nicht geben, höchstens an den festen Punkten selbst. Die Knick-Bögen sind deshalb frei gewählt, im Sinne von Locher-Ernsts „freier Geometrie“.

Buchstelle: Locher-Ernst, *Einführung in die freie Geometrie ebener Kurven*, Kapitel 3 („Die Singularitäten eines elementaren Bogens“) und 6 („Form und Gegenform“).

---

## 21 · Wo was im Code steht

`index.html` hat oben HTML und CSS, darunter ein Skript in 14 Abschnitten. Jeder beginnt mit einer Kommentarzeile `── Nummer · Titel`.

| Abschnitt im Code | Inhalt | erklärt in |
|---|---|---|
| 1 · Shader | Zeichnen mit `uSign`, Verwerfen bei $w < 0$ | 11, 12 |
| 2 · kleine Algebra | `mv`, `inv4`, `nrm4`, `homology`, `elation` | 5, 6, 15 |
| 3 · Zufall | ein fester Startwert, damit jede Sitzung gleich beginnt | — |
| 4 · Formen | ebene Formen, platonische Körper, Flächen als `{ n, d }` | 2 |
| 5 · Kristall | `groupMats`, `TRI`, `convexHull`, `KNAMES` | 19 |
| 6 · Zustand | `state`, der Stand aller Regler | — |
| 7 · Szene | Kamera, `patchInfiniteFar`, `hLayer`, `line` | 12 |
| 8 · Funken | `basis`, `makeGroup`, `evalG`, `emissionPoint`, `outward` | 10, 13, 14, 17 |
| 9 · Knick-Funken | `knickLocal`, `knickElement` | 20 |
| 10 · Kongruenz | `congFrame`, `congLine` | 18 |
| 11 · Körper | Homologie, Polarität, `guardEggs`, `threads` | 15 bis 18 |
| 12 · Lagetypendreieck | das Ziehfeld in der Reglerleiste | 19 |
| 13 · Oberfläche | Regler ein- und ausblenden, Zitate, Einstiege über den Link | — |
| 14 · Lauf | die Bildschleife | — |

**Ein neues Maß für die Funken** braucht drei Stellen. Ein Knopf im HTML unter „Maß“. Ein Zweig in `makeGroup`, der die Wächter und die Raten setzt. Und, falls die Bahn eine neue Form hat, ein Zweig in `evalG`. Der Weg durchs Unendliche kommt von selbst, aus Abschnitt 11 und 12.

**Einstiege über den Link:** Hängt man `#ei`, `#kongruenz`, `#kristall`, `#knick` oder `#polaritaet` an die Adresse, öffnet die Seite gleich im passenden Modus.

**Laden:** Die Seite holt three.js als gewöhnliches Skript von cdnjs, ohne Import-Map und ohne Module. So läuft sie auch in Umgebungen, die nur Skripte von wenigen Adressen erlauben. Wie man sie ohne Fenster in Edge testet, steht in der README des Projekts.
