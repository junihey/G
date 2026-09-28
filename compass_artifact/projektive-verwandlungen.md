---
tags: [learning, threejs, projektive-geometrie]
created: 2026-09-28
topic: 'Wie die Skizze Wegkurven-Funken projektive Verwandlungen in three.js zeichnet: homogene Koordinaten, der Weg durchs Unendliche, Wegkurven, Homologie, Polarität und die vier Erweiterungen nach Ostheimer/Ziegler, Adams, Ziegler und Locher-Ernst'
verification: 'am Quelltext von zaehlen\threejs-wegkurven-funken\index.html geprueft, Stand 2026-09-28; Buchstellen aus data\scans\mathe gelesen; extern -- three.js r159, kein smithy-Bezug'
---

# Projektive Verwandlungen in three.js

Das ist die Erklärung zur Skizze **Wegkurven-Funken**. Sie zeigt einen Körper, aus dessen Ecken und Kanten mathematische Kurven wie Funken sprühen, und der Körper selbst verwandelt sich projektiv. Der Code liegt in `zaehlen\threejs-wegkurven-funken\index.html`, eine einzige Datei.

Lies von oben nach unten. Jeder Abschnitt benutzt nur, was vor ihm steht. Abschnitt 2 und 3 tragen alles Weitere: Wer sie verstanden hat, versteht jeden Modus.

**Was hier nicht steht:** keine Einführung in projektive Geometrie selbst, die steht in den Büchern unter `data\scans\mathe\`. Kein three.js-Grundlagenwissen, das steht in [[aufbau-einer-anwendung]]. Und keine Bedienungsanleitung Regler für Regler, die Seite erklärt ihre Regler selbst.

## 1 · Was die Skizze zeigt

Auf der Seite liegen drei Schichten übereinander.

**Der Körper** — im Code `B` — ist eine ebene Form (Dreieck bis Lemniskate) oder ein räumlicher Körper (die fünf platonischen Körper und der Kristall aus Abschnitt 10). **Die Funken** laufen aus seinen Ecken und aus Punkten seiner Kanten. **Die Wächter** sind die Elemente, die eine Verwandlung festhält: ein fester Punkt, eine feste Ebene, eine Kugel.

Die Reglerleiste hat zwei Teile. „Körper“ wählt die Form und ihre Verwandlung, „Funken“ wählt, wie die Funken laufen. Das Zitat unten links wechselt mit dem, was zuletzt berührt wurde, und nennt die Buchstelle.

Fünf Einstiege lassen sich direkt verlinken, indem man an den Link ein Stichwort hängt: `#ei`, `#kongruenz`, `#kristall`, `#knick`, `#polaritaet`. Die Tabelle dazu heißt im Code `PRESETS`.

## 2 · Homogene Koordinaten

Ein Punkt des Raumes wird mit **vier** Zahlen geschrieben statt mit drei: (x, y, z, w). Gemeint ist der gewöhnliche Punkt (x/w, y/w, z/w). Daraus folgen zwei Dinge.

Erstens beschreiben (x, y, z, w) und (2x, 2y, 2z, 2w) denselben Punkt. Jedes Vielfache ist dasselbe. Der Code nutzt das, um Zahlen klein zu halten: **das Normieren** — `nrm4` — teilt die vier Zahlen durch ihre Länge. Das Vorzeichen bleibt dabei erhalten, und das wird in Abschnitt 3 wichtig.

Zweitens gibt es Punkte mit w = 0. Sie sind keine gewöhnlichen Punkte, sondern **Fernpunkte**: (1, 0, 0, 0) ist der unendlich ferne Punkt in x-Richtung. Whicher nennt das die unendlich ferne Ebene des Raumes. In homogenen Koordinaten ist sie eine Ebene wie jede andere.

Eine Ebene schreibt man ebenfalls mit vier Zahlen, als **Kovektor** ω = (n_x, n_y, n_z, −d). Ein Punkt p liegt auf ihr, wenn ω·p = 0 ist. Das ist die Ebene n·x = d.

Eine projektive Verwandlung ist dann eine 4×4-Matrix M: der Punkt p geht nach M·p. Im Code heißt diese Multiplikation `mv`, der Punkt aus einem three.js-Vektor entsteht mit `h4`. Weil die Matrix auch w verändert, kann ein endlicher Punkt ins Unendliche wandern und auf der Gegenseite zurückkommen. Genau das beschreibt Whicher, wenn der Kreis über die Parabel zur Hyperbel wird.

## 3 · Durchs Unendliche zeichnen

Eine Grafikkarte zeichnet eine Kante von Punkt a nach Punkt b, indem sie zwischen den beiden Punkten **linear in homogenen Koordinaten** interpoliert. Das ist ein Glücksfall: Die Menge (1−s)·a + s·b ist genau die projektive Strecke, auch wenn sie durchs Unendliche läuft. Voraussetzung ist, dass man a und b **nicht** vorher auf w = 1 teilt. Wer teilt, bekommt immer das endliche Stück und damit bei einer Hyperbel die falsche Hälfte.

Deshalb bekommt der Shader die Punkte unnormiert. Im Vertex-Shader steht nur:

```glsl
vec4 h = uSign * position;
gl_Position = projectionMatrix * (viewMatrix * h);
```

Ein Problem bleibt. Die Grafikkarte zeichnet einen Punkt nur, wenn `gl_Position.w` positiv ist. Ein Vertreter mit dem falschen Vorzeichen verschwindet also, obwohl −h derselbe Punkt ist. Die Lösung hat zwei Teile:

1. **Jede Ebene der Zeichnung wird zweimal gezeichnet**, einmal mit `uSign = 1`, einmal mit `uSign = −1`. Die Funktion dafür heißt `hLayer`, sie legt beide Kopien mit demselben Puffer an.
2. **Der Fragment-Shader verwirft jedes Pixel mit `vH.w < 0`.** Damit zeichnet jede Kopie nur die Punkte, die wirklich vor der Kamera liegen. Punkte hinter der Kamera erscheinen nicht gespiegelt im Bild.

Dazu kommt die **Fernebene der Kamera**. Eine gewöhnliche three.js-Kamera schneidet alles jenseits von `far` ab, und Fernpunkte liegen immer jenseits. `patchInfiniteFar` setzt zwei Einträge der Projektionsmatrix so, dass `far` im Unendlichen liegt. Ab da sind Fluchtpunkte sichtbar.

Eine ganze Gerade zeichnet `line(Q, d)`: zwei Strecken von Q zum Fernpunkt (d, 0) und zu (−d, 0). Beide zusammen sind die vollständige projektive Gerade.

Tiefentest und Sortierung sind aus. Alle Ebenen liegen durchscheinend übereinander, in der Reihenfolge von `renderOrder`, wie in einer Zeichnung, die auch verdeckte Kanten zeigt.

## 4 · Wegkurven: die Funken

Ein Funke ist ein Punkt, der von einer **einparametrigen Gruppe** getragen wird: dieselbe projektive Verwandlung, immer weiter angewandt. Whicher nennt die Bahn eines solchen Punktes **Wegkurve**.

Jede solche Gruppe hat vier feste Punkte, das **invariante Tetraeder**. Der Code legt sie als Spalten E1, E2, E3, E0 an (`basis`) und rechnet den Startpunkt einmal in diese Basis um: `c = Einv · p`. Danach ist die Bahn einfach, `evalG` rechnet sie aus:

| Maß | Wirkung in der Basis | Bahn, wenn E1–E3 im Unendlichen liegen |
|---|---|---|
| Wachstum | jede Koordinate wächst mit e^(a·t), eigenes a je Achse | Potenzkurve: x₂ = x₁^(a₂/a₁), ein Funktionsgraph y = xᵏ |
| Kreisend | E1 und E2 drehen sich, dazu Wachstum mit e^(σ·t) | logarithmische Spirale |
| Schritt | Kette E0 → E1 → E2: x₁ wächst um s·t, x₂ um k·t·x₁ + ½·s·k·t² | Parabel |

Beim Wachstum sind alle vier festen Punkte reell. Beim Kreisen sind zwei davon imaginär, und die Bahn kreist um sie, statt auf sie zuzulaufen. Beim Schritt fallen feste Punkte zusammen. Das sind Whichers drei Maße: Wachstumsmaß, kreisendes Maß, Schrittmaß.

**Nähe der Wächter** — im Code `kappa` — setzt E1 bis E3 von (u, 0) auf (u, κ). Bei κ = 0 liegen sie im Unendlichen, und jede Bahn ist ein reiner Funktionsgraph. Bei κ > 0 liegen sie im Abstand 1/κ. Dann laufen manche Bahnen durchs Unendliche und kommen von der Gegenseite zurück, und Abschnitt 3 zeichnet sie richtig.

**Streuung** — `streu` — dreht das Tetraeder für jeden Funken zufällig und wackelt an den Raten. Bei 0 laufen alle Funken einer Ecke auf derselben Kurvenschar.

Wo ein Funke startet, entscheidet `emissionPoint`: an einer Ecke oder, mit dem Anteil `kanten`, an einem zufälligen Punkt einer Kante. Die Richtung wählt `outward` so, dass der Funke zuerst von der Mitte weg läuft. Der Schweif wird nicht mitgeschleppt, sondern bei jedem Bild neu aus der Formel gerechnet: 28 Punkte rückwärts entlang derselben Kurve.

Buchstelle: Whicher, Kap. VI, „Ebene Wegkurven in atmender und kreisender Involution“.

## 5 · Punktuell und linienhaft

Whicher lässt jede Kurve zweimal entstehen: **punktuell**, als Folge von Punkten, und **linienhaft**, eingehüllt von einer Folge von Geraden. Das ist ihr „Regenbogen“ in Kapitel IV.

Die Art „linienhaft“ tut das mit den Kanten. Die Gruppe aus Abschnitt 4 trägt nicht einen Punkt, sondern eine ganze Kante weiter, und die Seite zeichnet 14 Nachbilder (`NECHO`) hintereinander. In der Ebene hüllen diese Nachbilder eine Kurve ein. Im Raum fegen sie eine Regelfläche aus. Kurze Kanten, etwa beim Kreis, werden vorher zu Tangentenstücken verlängert (`ext` in `finish`).

## 6 · Homologie und Elation

Die Verwandlung des ganzen Körpers ist eine **Homologie**: ein fester Punkt O, eine feste Ebene ω, und ein Faktor μ. Die Matrix (`homology`) ist

> M = I + (μ − 1) · O ωᵀ / (ω·O)

Jeder Punkt auf ω bleibt, weil ω·p = 0 ist. O bleibt, weil M·O = μ·O derselbe Punkt ist. Alle anderen Punkte gleiten auf Strahlen durch O. Whicher: „alle Punkte in Linien eines gegebenen Punktes gleiten, während alle Linien in Punkten einer gegebenen Linie drehen“.

Der Faktor atmet: μ = e^(Atem · sin φ). Wird μ klein, ziehen die Punkte zur Ebene ω. Die Ecken, die auf der anderen Seite von O liegen, erreichen ω nur durchs Unendliche. Die Statuszeile zählt, wie viele Ecken gerade „jenseits des Unendlichen“ sind, also negatives w haben.

Liegt O selbst in ω, wird die Homologie zur **Elation** (`elation`): M = I + s · O ωᵀ. Dann läuft der Vorgang im Schrittmaß statt im Wachstumsmaß. Die Seite legt O dafür auf den Fußpunkt in ω.

Buchstelle: Whicher, Kap. VI, „Zweidimensionale projektive Kurvenverwandlungen“, Figur 40, 41 und 49.

## 7 · Polarität

Eine Kugel mit Mitte c und Radius r ordnet jeder Ebene einen Punkt zu, ihren **Pol**, und jedem Punkt eine Ebene. Für die Flächenebene n·x = d ist der Pol in homogenen Koordinaten

> d′ = d − n·c,  Pol = (d′·c + r²·n, d′)

Diese Formel ist **linear** in (n, d). Das hat eine Folge, die man leicht übersieht: Die Kante des Polarkörpers zwischen den Polen zweier Nachbarflächen ist genau die Strecke, die die Grafikkarte zwischen den beiden homogenen Polen zeichnet (Abschnitt 3). Deshalb braucht der Code keinen Sonderfall, wenn der Polarkörper sich öffnet.

Geöffnet wird er, sobald die Kugelmitte den Körper verlässt: Dann geht eine Flächenebene durch c, ihr d′ wird null, und ihr Pol liegt im Unendlichen. Aus dem Würfel wird so kein Oktaeder mehr, sondern ein Oktaeder, das durchs Unendliche aufgebrochen ist. Die Liste der Nachbarflächen heißt `polarAdj`.

Buchstelle: Whicher, Kap. VII, „Pol und Polare in bezug auf die Sphäre“.

## 8 · Wegflächen nach Ostheimer/Ziegler

Das Maß **Ei** legt das invariante Tetraeder so, wie Lawrence Edwards es für Knospen und Eier benutzt: zwei reelle Pole A = (0, h, 0, 1) und B = (0, −h, 0, 1) auf der senkrechten Achse, dazu die beiden imaginären Kreispunkte auf der Ferngeraden der waagrechten Ebenen. Im Code sind das die Spalten x∞, z∞, A, B; die Gruppe ist vom Typ „Kreisend“ (Abschnitt 4).

Die Raten sind so gewählt, dass um den Mittelwert gerechnet A mit +1 wächst, B mit −1 und die waagrechte Richtung mit β. Daraus folgt das Profil der Fläche:

> x = R · e^(βt) / cosh t,  y = h · tanh t

Bei β = 0 ist das eine Ellipse durch beide Pole, die Fläche ein Ellipsoid. Bei 0 < β < 1 wird sie ein Ei, dessen stumpfes Ende zu A zeigt. Bei β > 1 wächst x schneller, als cosh es bremsen kann: Die Fläche öffnet sich zu einem Wirbel und läuft durchs Unendliche.

Ostheimer/Ziegler nennen β das Verhältnis von Streckweite zu Drehweite und geben Edwards’ Parameter an als λ = (1 + β)/(1 − β). Die Statuszeile zeigt beide.

Die Funken selbst drehen sich zusätzlich um die Achse. Ihre Bahnen sind deshalb Spiralen, die auf solchen Flächen von B nach A laufen: die fließende Bewegung des Buches. `guardEggs` zeichnet die Fläche durch den Äquator des Körpers mit 20 Meridianen und 7 Breitenkreisen. In der Ebene zeichnet sie stattdessen eine Schar von vier Eilinien. „Nähe der Wächter“ rückt hier die Pole zusammen (`poleH`).

Buchstelle: Ostheimer/Ziegler, *Skalen und Wegkurven*, Abschnitt 2.13 (Edwards’ λ) und 3.11 (Wegflächen).

## 9 · Kongruenz nach Adams

Die Art **Kongruenz** ersetzt die Funkenbahnen durch Geraden. Adams’ Urform ist eine **elliptische lineare Linienkongruenz**: eine zweifach unendliche Schar von Geraden, bei der durch jeden Punkt des Raumes genau eine geht.

Im Code hat sie eine Achse A und eine Taillenebene senkrecht dazu (`congFrame`). Durch den Taillenpunkt (x, y) geht die Gerade mit der Richtung

> (−h·y, h·x, k)

Dabei ist k das Größenmaß und h = ±1 der Windungssinn. Die Neigung δ gegen die Achse erfüllt r = k · tan δ, wie bei Adams: Im Abstand k steht jede Gerade unter 45°.

Um die Gerade durch einen beliebigen Punkt Q = (p, q, s) zu finden, rechnet `congLine` den Taillenpunkt zurück:

> m = h·s/k,  x = (p + m·q)/(1 + m²),  y = (q − m·p)/(1 + m²)

Der Nenner 1 + m² wird nie null. Deshalb gibt es wirklich für jeden Punkt genau eine Gerade.

Was daraus entsteht:
- Eine Ecke sendet ihre eine Gerade.
- Die Punkte einer Kante senden Geraden, die die Kantengerade und beide imaginären Leitlinien treffen. Solche Geraden bilden eine Regelschar, also ein Hyperboloid oder ein hyperbolisches Paraboloid.
- Die Lemniskate in der Taillenebene sendet Adams’ lemniskatische Regelfläche. Mit k gleich der halben Länge der Lemniskate ist das bis auf den Windungssinn die Fläche (x² + y²)² = (k² − z²)(x² − y²) + 4k·xyz.

`threads` zeichnet dazu ein **Fadenmodell** wie Adams’ Holzmodelle: 48 Geraden zwischen zwei Brettern, den Ebenen s = ±1,9. Dazu kommen die Achse und der Kreis vom Radius k.

Buchstelle: Adams, *Lemniskatische Regelflächen*, Anhang 2.1 bis 2.8.

## 10 · Kristall nach Ziegler

Die Form **Kristall** entsteht nicht aus einer festen Eckenliste, sondern aus einer Symmetriegruppe und einem einzigen Punkt.

`groupMats` erzeugt die volle Würfelgruppe (48 Elemente) oder die volle Ikosaedergruppe (120 Elemente): aus zwei Drehungen alle Produkte, dazu jeweils die Punktspiegelung. Das **Lagetypendreieck** ist ein Dreieck auf der Kugel, dessen Ecken auf den drei Achsenarten liegen: 4-, 3- und 2-zählig beim Würfel, 5-, 3- und 2-zählig beim Ikosaeder (`TRI`). Die Bilder des Dreiecks unter der Gruppe pflastern die Kugel lückenlos, ohne sich zu überlappen.

Ein Punkt p im Dreieck erzeugt den Körper so:
- **Punktform:** Die Bahn von p unter der Gruppe sind die Ecken. `convexHull` baut die konvexe Hülle, `assemble` fasst gleich liegende Dreiecke zu Flächen zusammen.
- **Flächenform:** Die Tangentialebenen an die Kugel in den Bahnpunkten sind die Flächen. Ihr Körper ist das Polare der Punktform aus Abschnitt 7. Der Code nimmt deshalb die Pole der Hüllflächen und baut aus ihnen noch einmal eine Hülle.

Wo p liegt, bestimmt die Klasse. Beim Würfel gilt:

| Lage im Dreieck | Punktform | Flächenform |
|---|---|---|
| Ecke 4-zählig | Oktaeder | Würfel |
| Ecke 3-zählig | Würfel | Oktaeder |
| Ecke 2-zählig | Kuboktaeder | Rhombendodekaeder |
| Seite 4–3 | Rhombenkuboktaeder | Deltoidikositetraeder |
| Seite 4–2 | Oktaederstumpf | Tetrakishexaeder |
| Seite 3–2 | Würfelstumpf | Triakisoktaeder |
| Inneres | Kuboktaederstumpf | Disdyakisdodekaeder |

Die Ikosaedergruppe hat dieselbe Tabelle mit Ikosaeder, Dodekaeder, Ikosidodekaeder und ihren Stümpfen (`KNAMES`). Innerhalb einer Zeile bleibt die Klasse gleich, die Maße ändern sich. Archimedisch, also mit lauter gleich langen Kanten, ist ein Vertreter nur an einer einzigen Stelle der Seite oder des Inneren.

Wandert p (`wanderLage`), geht der Körper fließend in seine Nachbarformen über. Nähert sich p einer Seite, schrumpfen Kanten auf null, und der Körper wechselt die Klasse. Weil der Kristall am Ende ein gewöhnliches `B` ist, wirken Homologie, Polarität und Funken auf ihn wie auf jeden anderen Körper.

Buchstelle: Ziegler, *Morphologie von Kristallformen und symmetrischen Polyedern*, Abschnitt 5.1, 5.2 und 5.6.

## 11 · Knick-Funken nach Locher-Ernst

Locher-Ernst betrachtet an einer Kurve nicht den Punkt allein, sondern das **Element**: den Punkt zusammen mit seiner Tangente. Kehrt der Punkt beim Durchlaufen seine Richtung um, ist er singulär. Kehrt die Tangente ihren Drehsinn um, ist sie singulär. Daraus entstehen vier Sorten:

| Element | Punkt | Tangente | lokale Form im Code (`knickLocal`) |
|---|---|---|---|
| regulär | regulär | regulär | (u, c·u²) |
| Wendestelle | regulär | singulär | (u, c·((u−u_s)³ + u_s³)) |
| Dornspitze | singulär | regulär | (2(u_s² − σ²), c·(σ³ + u_s³)) mit σ = u − u_s |
| Schnabelspitze | singulär | singulär | (2(u_s² − σ²), c·(3σ⁴ + 4σ⁵ − Konstante)) |

Die Knick-Funken laufen auf solchen Bögen. Die Stelle u_s liegt zufällig in der Mitte der Bahn, die Sorte wird ausgelost. Die Bahn liegt in einer Ebene durch die Mitte und führt quer zur Mitte, leicht nach außen.

Zu jedem Funken läuft ein **Gegenfunke** (`knickElement`): der Pol der Tangente bezüglich der Kugel um die Mitte (Radius aus „Kugelradius“). Die Tangente des Gegenfunkens ist umgekehrt die Polare des Funkenpunkts. Punkt und Tangente tauschen also die Rollen. Deshalb gilt Locher-Ernsts Tafel: Durchläuft der Funke eine Wendestelle, macht der Gegenfunke eine Dornspitze, und umgekehrt. Regulär und Schnabelspitze bleiben, was sie sind. Beide Stellen markiert die Seite mit einem Wächterpunkt.

Diese Bahnen sind keine Wegkurven. Auf einer Wegkurve bringt die Gruppe jeden Punkt in jeden anderen, alle Punkte sind also gleich gebaut. Eine einzelne Wendestelle kann sie nicht tragen, höchstens an ihren festen Punkten. Die Knick-Bögen sind deshalb frei gewählte Bögen im Sinne von Locher-Ernsts „freier Geometrie“.

Buchstelle: Locher-Ernst, *Einführung in die freie Geometrie ebener Kurven*, Kapitel 3 (Singularitäten) und 6 (Form und Gegenform).

## 12 · Wo was im Code steht

Die Datei ist in 14 Abschnitte gegliedert. Jeder beginnt mit einer Kommentarzeile `── Nummer · Titel`.

| Abschnitt im Code | Inhalt | erklärt in |
|---|---|---|
| 1 · Shader | die drei Shader mit `uSign` und dem Verwerfen bei w < 0 | 3 |
| 2 · kleine Algebra | `mv`, `inv4`, `nrm4`, `homology`, `elation` | 2, 6 |
| 3 · Zufall | fester Startwert, damit jede Sitzung gleich beginnt | — |
| 4 · Formen | `buildCurve`, `assemble`, `finish` | 1 |
| 5 · Kristall | `groupMats`, `TRI`, `convexHull`, `buildKristall` | 10 |
| 6 · Zustand | `state`, der Stand aller Regler | — |
| 7 · Szene | Kamera, Drehen per Finger, `patchInfiniteFar`, `hLayer` | 3 |
| 8 · Funken | `basis`, `makeGroup`, `evalG`, `spawnPoint`, `spawnLine` | 4, 5, 8 |
| 9 · Knick-Funken | `knickLocal`, `knickElement` | 11 |
| 10 · Kongruenz | `congFrame`, `congLine` | 9 |
| 11 · Körper | `computeBody`, `guardEggs`, `threads` | 6, 7, 8, 9 |
| 12 · Lagetypendreieck | Zeichnung und Ziehen in der Reglerleiste | 10 |
| 13 · Oberfläche | `evalWhen` blendet Regler ein und aus, `QUOTES`, `PRESETS` | 1 |
| 14 · Lauf | `tick` und die Bildschleife | — |

Ein neues Maß für die Funken braucht drei Stellen: einen Knopf im HTML unter „Maß“, einen Zweig in `makeGroup`, der das Tetraeder und die Raten setzt, und, falls die Bahn eine neue Form hat, einen Zweig in `evalG`. Alles andere, auch der Weg durchs Unendliche, folgt aus Abschnitt 3.

Die Seite lädt three.js r159 als klassisches Skript von cdnjs. Sie braucht keine Import-Map und kein Modul. So läuft sie auch im Artifact-Viewer, der nur Skripte von wenigen Adressen zulässt. Wie man sie ohne Fenster in Edge testet, steht in der README des Projekts.
