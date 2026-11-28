---
tags: [spec, wwww-threejs, typografie, katalog]
created: 2026-10-03
topic: 'Welche Schrift-Animation in three.js es schon gibt, eine Zeile pro Animation'
verification: 'aus dem Quelltext der vier Dateien gelesen am 2026-10-03, keine davon im Browser angesehen'
---

# Typo-Katalog — Schrift-Animationen für wwww

> [!abstract] Eine Animation für einen Ort, nie eine ganze Serie
> In wwww wählst du eine einzelne Animation für einen Ort aus, nie eine ganze Serie. Vier Dateien in `raw\typo\` enthalten zusammen 31 Schrift-Animationen in three.js. Die Dekonstruktion zerlegt das Netz der Buchstaben, die Struktur-Serie baut es sichtbar um. „Passt zu“ und „Urteil“ füllst du, wenn du eine Animation gesehen hast. Gelesen ist bisher nur der Quelltext.
>
> ```mermaid
> flowchart LR
>   L["Typo-Labor · 9<br/>3D-Buchstaben und Shader"] --> O["eine Animation<br/>für einen Ort"]
>   D["Dekonstruktion · 7<br/>das Netz zerfällt"] --> O
>   S["Struktur-Serie · 7<br/>das Netz wird umgebaut"] --> O
>   V["Schriftvarianten · 8<br/>jede folgt aus ihrer Schrift"] --> O
> ```

^blick

Eine Zeile pro **Animation**, nicht pro Datei.

**Die Dateien liegen in `raw\typo\` und damit nicht in git.** Nach einem Klon fehlen sie. Dieser Katalog überlebt das.

Die Spalte „Was passiert“ steht so im Quelltext jeder Animation (`desc`), gekürzt. „Eingabe“ ist der Bedienhinweis (`hint`). **„Passt zu“ und „Urteil“ füllst du**, nachdem du die Animation gesehen hast.

---

## Was alle vier Dateien gemeinsam haben

- three.js r128 von cdnjs, sonst keine Abhängigkeit. Jede Datei öffnet sich direkt im Browser.
- Oben rechts `Aa`: eigenes Wort eintippen, `Übernehmen`. `Standardtexte` setzt zurück.
- Die Schriften stecken als three.js-Typeface in der Datei, reduziert auf ASCII plus `ÄÖÜäöüß`. Ein Wort mit `€`, `–` oder `„“` fehlt an diesen Stellen.
- `fonts.sans` ist Helvetiker, `fonts.serif` Gentilis, `fonts.round` Optimer.

---

## Typo-Labor — `raw\typo\threejs-typografie.html`

Die erste Serie. Mischt echte 3D-Buchstaben mit Shadern, die nur eine flache Schrift-Textur verzerren.

| Animation | Schrift | Was passiert | Eingabe | Grund | Passt zu | Urteil |
| --- | --- | --- | --- | --- | --- | --- |
| Monolith | Helvetiker | Extrudierte Gips-Buchstaben im Streiflicht, Schatten auf einer unsichtbaren Wand dahinter. | Bewegen zum Drehen | hell | | |
| Fließen | Iowan Old Style kursiv (Systemschrift) | Simplex-Noise verzerrt die Schrift, eine versetzte Kobalt-Ebene wirkt wie ein Fehldruck. | Bewegen erzeugt Wellen | hell | | |
| Atelier | Gentilis | Serifen-Lettern klappen nacheinander auf und drehen sich alle paar Sekunden in einer Welle, darunter eine Messinglinie. | Bewegen zum Neigen | dunkel | | |
| Gummi | Optimer | Aufgeblasene Lettern mit Klarlack, jeder Buchstabe hüpft und federt einzeln. | Tippen auf einen Buchstaben | hell | | |
| Torsion | Helvetiker | Das Wort verdreht sich um seine Längsachse. | Links und rechts verdreht stärker | dunkel | | |
| Seide | Iowan Old Style kursiv (Systemschrift) | Die Schrift liegt auf einem Tuch, das sich wellt und Falten wirft. | Bewegen zum Kippen | hell | | |
| Echo | Helvetiker | 26 Konturebenen folgen dem Wort verzögert und ziehen eine Spur in die Tiefe. | Bewegen lenkt das Echo | hell | | |
| Schmelze | Arial Black (Systemschrift) | Die Schrift tropft nach unten, die Tropfenlänge folgt einem Noise entlang der Breite. | Bewegen lässt es tropfen | hell | | |
| Raster | Iowan Old Style fett (Systemschrift) | Zweifarbiger Risograph-Druck aus Punkten in zwei Rasterwinkeln. | Bewegen sendet eine Welle | hell | | |

## Dekonstruktion — `raw\typo\threejs-dekonstruktion.html`

Das Netz der Schrift wird zerlegt: Dreiecke fallen, splittern, schmelzen.

| Animation | Schrift | Was passiert | Eingabe | Grund | Passt zu | Urteil |
| --- | --- | --- | --- | --- | --- | --- |
| Zerfall | Helvetiker | Jedes Dreieck fällt verzögert, dreht sich und bleibt am Boden liegen, danach läuft alles rückwärts. | Bewegen zum Drehen | hell | | |
| Splitter | Helvetiker | Dreiecke nahe dem Finger springen auf und kippen nach vorn, ohne Berührung läuft eine Welle durch. | Mit dem Finger hineinfahren | dunkel | | |
| Gitter | Helvetiker | Eine Front wandert durch das Wort, dahinter bleibt nur das Drahtgitter. | Bewegen zum Drehen | dunkel | | |
| Wachs | Optimer | Das Netz sackt ab, läuft in Tropfen aus und wird am Boden zur Pfütze. | Bewegen zum Drehen | hell | | |
| Schnitt | Helvetiker | Sieben Ebenen schneiden das Wort in Scheiben, die auseinandergleiten und das hohle Innere zeigen. | Bewegen zum Drehen | dunkel | | |
| Erosion | Gentilis | Ein Noise-Feld frisst die Oberfläche von links nach rechts, an der Kante wehen Punkte davon. | Bewegen zum Drehen | dunkel | | |
| Struktur | Gentilis | Die Schrift zeigt ihre Triangulierung, dann löst sich jede Kante und verteilt sich in der Tiefe. | Bewegen zum Drehen | hell | | |

## Struktur-Serie — `raw\typo\threejs-struktur-serie.html`

Das Netz bleibt sichtbar und wird umgebaut: aufgeklappt, aufgefächert, sortiert.

| Animation | Schrift | Was passiert | Eingabe | Grund | Passt zu | Urteil |
| --- | --- | --- | --- | --- | --- | --- |
| Bauplan | Helvetiker | Explosionszeichnung: Vorderseite, Rückseite und Wände gleiten auseinander, gestrichelte Hilfslinien zeigen die Herkunft. | Bewegen zum Drehen | hell | | |
| Origami | Gentilis | Jedes Dreieck klappt um seine kürzeste Kante auf wie ein Papierfalz, Rückseiten safrangelb. | Bewegen zum Drehen | dunkel | | |
| Wirbel | Helvetiker | Die Kanten werden in einen Wirbel um die senkrechte Achse gezogen, innen schneller, dabei aufsteigend. | Bewegen zum Neigen | dunkel | | |
| Fächer | Gentilis | Zwölf Kopien des Netzes fächern auf wie Buchseiten, um wechselnde Achsen. | Bewegen zum Drehen | hell | | |
| Netz | Helvetiker | Die Ecken treiben durch ein Noise-Feld, Vorder- und Rückseite ziehen auseinander, Kanten spannen sich wie Fäden. | Mit dem Finger hineindrücken | dunkel | | |
| Schwebe | Optimer | Grobe Dreiecke lösen sich von der Mitte nach außen und taumeln schwerelos, das Drahtgitter bleibt als Geisterbild. | Bewegen zum Drehen | dunkel | | |
| Teile | Helvetiker | Jedes Dreieck fliegt auf ein Raster am Boden, sortiert nach Größe, Farbe zeigt die Größenklasse. | Bewegen zum Drehen | hell | | |

## Schriftvarianten — `raw\typo\threejs-schriftvarianten.html`

Jede Animation folgt aus einer Eigenschaft ihrer Schriftart. Hier steckt die Auswahl an Schriften, die anderen drei Dateien nutzen nur drei.

| Animation | Schrift | Was passiert | Eingabe | Grund | Passt zu | Urteil |
| --- | --- | --- | --- | --- | --- | --- |
| Gebrochen | UnifrakturMaguntia (Fraktur) | Jede Letter reißt entlang einer Bruchlinie, die Hälften klappen auseinander, Splitter fliegen. | Bewegen zum Drehen | dunkel | | |
| Kontrast | Playfair Display Black (Didone) | Die Strichstärke wird zur Höhe: fette Striche werden Grate, Haarstriche bleiben flach, dann lösen sich die Facetten. | Bewegen zum Kippen | hell | | |
| Fallblatt | Space Mono | Die Dreiecke eines Buchstabens taumeln und setzen sich in derselben Zelle zum nächsten Wort zusammen. | Bewegen zum Drehen | dunkel | | |
| Lamellen | Bebas Neue (Condensed) | Senkrechte Streifen drehen sich wie Jalousien und zeigen eine orange Rückseite. | Mit dem Finger drüberfahren | dunkel | | |
| Faden | Pacifico (Schreibschrift) | Die Schrift wickelt sich in Schreibrichtung zu einer Spirale auf und rollt zurück. | Bewegen zum Drehen | hell | | |
| Globus | Unbounded Black (Extended) | Die Lettern wickeln sich um eine Kugel, die sich einmal dreht und wieder flach ausrollt. | Bewegen zum Drehen | hell | | |
| Gewicht | Fraunces Light, Black, beide kursiv | Die Dreiecke wandern von Light zu Black, in die Kursive und zurück, goldene Flanken zeigen die zusätzliche Masse. | — | hell | | |
| Mischsatz | alle sieben dieser Datei | Jeder Buchstabe wechselt reihum durch alle Schriften, jede mit eigener Farbe. | Bewegen zum Drehen | hell | | |

---

## Wenn neue Dateien dazukommen

1. Die Datei nach `raw\typo\` legen, nicht nach `zaehlen\quellen\`.
2. Eine neue Serie bekommt einen eigenen Abschnitt mit Tabelle in derselben Spaltenordnung.
3. Folgt die Datei demselben Bau wie diese vier (`SCENES`-Liste mit `title`, `hint`, `desc`), lassen sich die Zeilen aus dem Quelltext auslesen statt abzutippen.
4. Steht der Katalog in `raw-index.md` schon als weitester Stand, muss dort nichts nachgetragen werden.
