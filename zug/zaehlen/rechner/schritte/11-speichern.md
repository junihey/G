# Schritt 11 – Speichern und Öffnen: das Rechenblatt als Datei

Datum 2026-11-16. Form: Werkzeug, Brücke, Quellen, Messung, Aussortiert, Offen.

## Werkzeug

**Kein neues Werkzeug.** Im Kopf des Rechenblatts stehen zwei neue Knöpfe, **Speichern** und **Öffnen**, dazu die Tasten Strg+S und Strg+O. Beide Tasten gelten auch, wenn eine Zeile den Fokus hat; sonst speichert der Browser die ganze Seite. Der Kopf bricht jetzt um, weil sonst „Leeren“ abgeschnitten wurde.

**Die Datei** heißt `rechenblatt-JJJJ-MM-TT-hhmm.rechenraum.json` (`NB.toFile` in `src/61-notebook.js`):

```json
{"format":"rechenraum","version":1,"saved":"…",
 "rows":[{"src":"f(x) = a*x^2 - 2","color":2,"on":true}, …],
 "layout":{"groups":[["m2-a","kz-dreh"],["befehle"]],"active":0,"dim":3,"left":true,"right":true},
 "settings":{"deg":true,"complex":true},
 "raum3d":{"x":[-5,5],"y":[-4.52,4.52],"res":30,"wire":true,"contour":true}}
```

Die Datei enthält nicht, was ein Werkzeug nur anzeigt, etwa N bei Folgen oder das Häkchen „Schar“ eines Reglers. Alles Gerechnete steht seit Schritt 8 in Zeilen.

**Öffnen** (`NB.fromFile`) liest dieses Format. Es liest auch eine Textdatei mit einer Rechenzeile pro Zeile und ein JSON-Array aus Texten. Eine fremde JSON-Datei meldet „Das ist keine Rechenraum-Datei.“, und das Blatt bleibt, wie es war. Eine Datei mit höherer Version öffnet sich mit einem Hinweis. Strg+Z nach dem Öffnen holt die vorigen Zeilen zurück, aber nicht die Reiter und Schalter.

**Reihenfolge beim Öffnen:** erst die Reiter und 2D/3D (`applyLayout(layout, true)`, aus `setupRooms` in `src/60-ui.js` herausgelöst), danach die Felder x ∈ und y ∈. Andersherum überschrieb das Kippen nach 3D die Felder aus der Datei mit dem 2D-Ausschnitt. Der erste Prüflauf hat das gefunden.

**Auf claude.ai** startet eine Seite keinen Download selbst. Dort fragt `saveFile` über die Fähigkeit `downloads` (`claude.use('downloads')`), und der Betrachter bestätigt jede Datei. Lokal bleibt es der Download über einen Link. Öffnen geht in beiden Fällen über das Dateifeld.

Nebenbei korrigiert: Der Hinweis im Phasenporträt sagte noch „auch als → Phasenporträt“. Jetzt sagt er „öffnen in → Phasenporträt“ (`src/86-komplex.js`). „auch als“ steht nirgends mehr im Code.

## Brücke

Keine neue. Die Datei ist das Rechenblatt, also wirkt die Regel „Das Rechenblatt ist die einzige Quelle“ jetzt auch über eine Sitzung hinaus.

## Quellen

Keine.

## Messung

`node bench/ansicht.mjs 11`, alles mit echten Ereignissen über die DevTools-Schnittstelle:

| Prüfung | Ergebnis |
|---|---|
| Blatt mit 6 Zeilen (eine verborgen), DEG, ℂ, zwei Reiter zusammengelegt, 3D, x ∈ [−5, 5], Gitternetz; Knopf Speichern | Datei geschrieben, Inhalt gleich dem Zustand |
| Leeren, alles zurücksetzen, Öffnen über das echte Dateifeld (`DOM.setFileInputFiles`) | Zustand gleich wie vorher, auch die Felder der 3D-Bühne |
| Strg+Z mit echter Taste, dann Strg+Y | 0 Zeilen, dann wieder 6 |
| Strg+S, während eine Zeile den Fokus hat | `saveFile` einmal aufgerufen, Speichern des Browsers verhindert, Download beginnt |
| Textdatei `h(x) = x^3`, `h(2)` | zwei Zeilen, h(2) = 8 |
| fremde JSON-Datei | Meldung, Blatt unverändert |
| alle 26 Werkzeuge in 2D und 3D | keine Konsolenfehler, keins mit eigener Grafik |

`node bench/messen.mjs 11`: Tippen bis zum Graphen 34,8 ms (Median), Reglerbild 16,6 ms, kein Block über 50 ms.

Fotos: `logs/ansicht-11/01-vorher.png`, `02-geleert.png`, `03-geoeffnet.png`.

## Aussortiert

Nichts.

## Offen

- Ob der Web Worker auf claude.ai rechnet, zeigt sich erst beim ersten Öffnen dort. Ein Rückfall auf den Hauptfaden existiert.
- Strg+Z nach dem Öffnen stellt die Reiter und Schalter nicht zurück, nur die Zeilen.
- Die Grenzen eines Reglers (min, max) und das Häkchen „Schar“ fehlen in der Datei. Sie fehlen auch im Browser-Speicher.

## Nachtrag 2026-11-16: die Seite auf claude.ai

Die Seite hat eine neue Adresse: `https://claude.ai/artifact/7KKVsY6xKaP39BzSJZThvw`. Die alte (`XNJaZnxSZWdACj14Zyee77`, Version 1 vom 2026-10-16) ist gelöscht, der Nutzer brauchte ihren Link nicht. Sie zu überschreiben hätte verlangt, alle 4803 Zeilen der alten Fassung zu lesen.

Die Datei zum Hochladen entsteht aus `rechner.html`: Die eigenen Tags doctype, html, head und body fallen weg, weil claude.ai sie selbst um die Seite legt. Angemeldet ist die Fähigkeit `downloads`. Eine neue Fassung geht an dieselbe Adresse, wenn man beim Veröffentlichen `url` mitgibt.

## Nachtrag 2026-11-16: Beispiele als Dateien

**Die Beispielblätter stehen nicht mehr im Code.** Sie liegen als `beispiele/NN Titel.rechenraum.json` im Projekt. `src/build.py` liest sie sortiert ein und fügt sie als `BEISPIELE` in die Seite ein, denn eine lokal geöffnete Seite darf keine Nachbardateien lesen. Die Nummer bestimmt die Reihenfolge, der Rest des Namens ist der Titel im Menü. Ein Doppelpunkt ist unter Windows im Dateinamen verboten, deshalb heißt ein Beispiel jetzt „Folgen – Zyklus und Chaos“.

Ein Klick im Menü öffnet das Beispiel über `NB.fromFile`, also genau wie Strg+O. Eine Beispieldatei darf deshalb Reiter, 2D/3D und Schalter enthalten. Die zwölf umgewandelten Beispiele enthalten nur Zeilen, so wie vorher. Beim ersten Besuch lädt der Rechner die Zeilen des ersten Beispiels.

**Ein eigenes Beispiel:**
1. Das Blatt im Rechner bauen.
2. Strg+S drücken.
3. Die Datei als `beispiele/13 Name.rechenraum.json` ablegen.
4. `python src/build.py rechner.html` ausführen.

Eine Datei, die kein gültiges JSON oder keine Rechenraum-Datei ist, bricht den Bau mit ihrem Namen ab. Geprüft an einer Kopie in einem Testordner: kaputtes JSON und fremdes JSON, beide Male Exit-Code 1.

`node bench/ansicht.mjs 11b`: Alle zwölf Beispiele öffnen sich über das Menü ohne Zeilenfehler und ohne Konsolenfehler. Alle 26 Werkzeuge öffnen sich in 2D und 3D ohne Fehler. `node bench/messen.mjs 11b`: Tippen bis zum Graphen 43,4 ms, Reglerbild 16,6 ms, kein Block über 50 ms.

Offen:
- Ein offenes Werkzeug legt beim Öffnen eines Beispiels seine Zeile an, wenn das Blatt keine passende hat. Im Prüflauf schrieb das Phasenporträt in jedes Beispiel `f(z) = (z - 1)/(z^2 + z + 1)`. So war es auch schon vor diesem Schritt. Ein Beispiel ohne Reiter in der Datei lässt die offenen Werkzeuge stehen.
- Das Menü zeigt nur Namen. Die Fotos aus `ansicht.mjs` könnten Vorschaubilder werden.
