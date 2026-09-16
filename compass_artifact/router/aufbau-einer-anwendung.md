---
tags: [learning, threejs]
created: 2026-09-02
topic: Wie eine Three.js-Anwendung aufgebaut wird — die drei Formen des Codes, der Mechanismus dahinter, die drei vergessenen Pflichten und die Grenze zwischen WebGL und WebGPU
verification: 'aus specs\wwww-threejs\raw\three.js-journey\CONVENTIONS.md, Stand 2026-09-02; Aussagen am Quelltext von Lektion 26 nachgeprueft; extern — Three.js-Verhalten, kein smithy-Bezug'
---

# Wie eine Three.js-Anwendung aufgebaut wird

Das ist der Teil aus dem Kurs *Three.js Journey*, der in **jedem** Projekt gilt, in dem du Three.js anfasst — nicht der Teil, der von diesem Kurs handelt.

Lies von oben nach unten. Jeder Abschnitt benutzt nur, was vor ihm steht.

**Was hier nicht steht:** keine API-Referenz — was `MeshStandardMaterial` alles kann, steht in der Three.js-Dokumentation. Keine Versionsnummern, weil sie in einem halben Jahr falsch wären. Und kein Verweis auf eine einzelne Lektion, weil dieser Text den Kurs überleben soll.

## 1 · Die vier Teile und die Schleife

Jede Szene, egal wie groß, besteht aus vier Dingen.

**Die Bühne** — im Code `Scene` — hält alles, was gezeigt werden soll. **Ein sichtbares Ding** — `Mesh` — hat immer zwei Hälften: eine Form (`Geometry`, etwa `BoxGeometry`) und eine Oberfläche (`Material`, etwa `MeshStandardMaterial`). **Das Auge** — `PerspectiveCamera` — legt fest, von wo aus und mit welchem Öffnungswinkel geschaut wird. **Der Zeichner** — `WebGLRenderer` — malt aus Bühne und Auge ein Bild auf ein `canvas`-Element:

```js
renderer.render(scene, camera)
```

Ein einzelnes Bild bewegt sich nicht. Für Bewegung ruft der Browser vor jedem Bild eine Funktion auf:

```js
const tick = () =>
{
    renderer.render(scene, camera)
    window.requestAnimationFrame(tick)
}
tick()
```

Alles Weitere in dieser Datei ist die Frage, wo diese vier Teile und diese Schleife wohnen, sobald es mehr wird als ein Würfel.

## 2 · Die drei Formen, in denen der Code liegen kann

| Form | Wann |
|---|---|
| Flaches `src/script.js` | Eine Szene, ein Effekt, keine geladenen Modelle, unter etwa 150 Zeilen. Prototypen und Versuche. |
| `script.js` plus `src/shaders/` | Sobald eigene Shader dazukommen. GLSL gehört in `.glsl`-Dateien, nicht in Template-Strings im JavaScript. |
| `src/Experience/` | Mehrere Objekte, geladene Modelle, ein Debug-Menü — oder das Ding soll länger leben als einen Nachmittag. |

**Im Zweifel die dritte.** Der Umbau von flach nach `Experience/` im Nachhinein kostet mehr als der Aufbau von Anfang an, weil bis dahin jede Funktion `scene`, `sizes` und `camera` als freie Variablen benutzt — sie müssen dann alle gleichzeitig umziehen.

Lehrmaterial zeigt fast immer die erste Form. Das ist kein Vorbild, sondern eine Auslassung: wer eine einzelne Sache erklärt, lässt die Struktur weg, weil sie ablenken würde.

## 3 · Der Aufbau von `Experience/`

```
src/
├── script.js                  drei Zeilen, sonst nichts
└── Experience/
    ├── Experience.js          hält alles zusammen
    ├── Camera.js
    ├── Renderer.js
    ├── sources.js             Liste der zu ladenden Dateien
    ├── Utils/
    │   ├── EventEmitter.js    Basisklasse, nicht aus Three.js
    │   ├── Sizes.js           feuert 'resize'
    │   ├── Time.js            feuert 'tick'
    │   ├── Resources.js       feuert 'ready'
    │   └── Debug.js
    └── World/
        ├── World.js           hält die Objekte der Szene
        ├── Environment.js
        └── eine Datei je Objekt
```

`src/script.js` in voller Länge:

```js
import Experience from './Experience/Experience.js'

const experience = new Experience(document.querySelector('canvas.webgl'))
```

Die Trennung von `Utils/` und `World/` ist die eigentliche Aussage. In `Utils/` liegt, was jede Anwendung braucht und was du ins nächste Projekt unverändert mitnimmst. In `World/` liegt, was diese eine Szene ausmacht.

## 4 · Der Singleton — wie jede Klasse an alles kommt

Ein Problem entsteht sofort, wenn der Code auf dreizehn Dateien liegt: `Floor.js` braucht die Bühne, `Fox.js` braucht die geladenen Modelle, `Camera.js` braucht die Fenstergröße. Reicht man das als Parameter durch, hat am Ende jeder Konstruktor fünf Argumente.

**Die einzige Instanz** — im Code der `Singleton` — löst das. `Experience` merkt sich seine erste Instanz in einer Modulvariablen und gibt bei jedem weiteren `new Experience()` dieselbe zurück:

```js
let instance = null

export default class Experience
{
    constructor(_canvas)
    {
        if(instance)
        {
            return instance
        }
        instance = this
        // ...
    }
}
```

Deshalb kommt jede Klasse ohne ein einziges Argument an alles:

```js
export default class Floor
{
    constructor()
    {
        this.experience = new Experience()   // dieselbe Instanz
        this.scene = this.experience.scene
        this.resources = this.experience.resources
    }
}
```

Der Preis ist, dass es genau **eine** Anwendung pro Seite geben kann. Zwei Canvas-Elemente nebeneinander gehen so nicht.

## 5 · Ereignisse statt Aufrufketten

`Sizes` und `Time` erben von einer **eigenen Ereignisklasse** — im Code `EventEmitter`, eine Datei in `Utils/`, nichts aus Three.js. Wer davon erbt, kann `trigger('name')` rufen, und wer will, hört mit `on('name', …)` zu.

Drei Ereignisse tragen die ganze Anwendung:

| Wer feuert | Was | Wann |
|---|---|---|
| `Time` | `tick` | vor jedem Bild |
| `Sizes` | `resize` | wenn sich die Fenstergröße ändert |
| `Resources` | `ready` | wenn alle Dateien aus `sources.js` geladen sind |

`Experience` hört auf `tick` und `resize` und reicht beide in einer festen Reihenfolge weiter:

```js
update()
{
    this.camera.update()
    this.world.update()
    this.renderer.update()
}
```

Die Reihenfolge ist keine Willkür. Das Auge zuerst, weil seine Steuerung die Position ändert. Dann die Welt, weil Objekte sich relativ zum Auge verhalten. Der Zeichner zuletzt, weil er den fertigen Stand malt.

**Auf `ready` warten.** Objekte, die ein Modell brauchen, entstehen nicht im Konstruktor von `World`, sondern in dessen Rückruf:

```js
this.resources.on('ready', () =>
{
    this.floor = new Floor()
    this.fox = new Fox()
})
```

Daraus folgt eine Zeile, die sonst wie Angst aussieht:

```js
update()
{
    if(this.fox)
        this.fox.update()
}
```

Vor `ready` gibt es das Objekt noch nicht, `update()` läuft aber schon.

## 6 · Die drei Pflichten, die man vergisst

**Aufräumen im Grafikspeicher** — im Code `dispose()`. Geometrien, Materialien und Texturen liegen auf der Grafikkarte und verschwinden nicht, wenn das JavaScript-Objekt verschwindet. Wer eine Geometrie ersetzt, weil ein Regler die Unterteilung ändert, muss die alte vorher entsorgen. Die vollständige Form läuft durch die Bühne und prüft bei jedem Material jede Eigenschaft, ob sie selbst ein `dispose()` hat:

```js
this.scene.traverse((child) =>
{
    if(child instanceof THREE.Mesh)
    {
        child.geometry.dispose()

        for(const key in child.material)
        {
            const value = child.material[key]
            if(value && typeof value.dispose === 'function')
                value.dispose()
        }
    }
})
```

**Resize sind drei Dinge, nie zwei.** `camera.aspect` setzen, `camera.updateProjectionMatrix()` rufen, `renderer.setSize()` rufen. Vergisst man das mittlere, bleibt das Bild verzerrt. Dazu gehört `renderer.setPixelRatio()`, gedeckelt auf 2 — darüber kostet jedes weitere Pixel Leistung, die niemand sieht. Läuft eine **Nachbearbeitung** — im Code `EffectComposer` —, kommt `composer.setSize()` dazu.

**Mit der verstrichenen Zeit rechnen, nicht mit Bildern.** Jede Bewegung wird mit `deltaTime` multipliziert. Ein fester Wert pro Bild läuft auf einem 144-Hz-Monitor doppelt so schnell wie auf einem 72-Hz-Monitor. In der flachen Form liefert `THREE.Clock` diese Zeit; in `Experience/` rechnet `Time` sie selbst aus `Date.now()` und legt sie als `this.delta` in Millisekunden ab.

## 7 · React Three Fiber: Komponenten statt Klassen

Schreibst du die Anwendung in React, ersetzen Komponenten die Klassen aus Abschnitt 3 — die Aufteilung bleibt dieselbe. `Experience.jsx` hält die Bühne, eine Datei je Objekt (`Player.jsx`, `Level.jsx`, `Lights.jsx`), und der Zustand, den mehrere Objekte teilen, liegt in einem Store unter `stores/`.

Der Singleton aus Abschnitt 4 entfällt dabei. An Bühne und Zeit kommt man in React über einen Hook, nicht über eine Instanz.

## 8 · WebGL oder WebGPU — nie mischen

Three.js hat zwei APIs, und die Wahl fängt bei der Import-Zeile an. Beispiele aus beiden Hälften lassen sich nicht kombinieren.

| | WebGL | WebGPU |
|---|---|---|
| Import | `from 'three'` | `from 'three/webgpu'` |
| Zeichner | `WebGLRenderer` | `WebGPURenderer` |
| Material | `MeshStandardMaterial` | `MeshStandardNodeMaterial` |
| Shader | `.glsl`-Dateien, `ShaderMaterial` | `from 'three/tsl'`, `material.colorNode` |
| Nachbearbeitung | `EffectComposer` mit Passes | `PostProcessing` mit `pass()` |

WebGPU läuft nur in einem sicheren Kontext — also über HTTPS oder auf `localhost`.

Zwei Eigenheiten der Knotensprache **TSL**, die man beim ersten Mal falsch schreibt. Knoten haben keine Rechenoperatoren, es heißt `a.add(b)` statt `a + b`. Und ein Wert, dem mehrfach etwas zugewiesen wird, braucht `.toVar()` — sonst entsteht bei jeder Zuweisung ein neuer Knoten, statt dass sich einer ändert:

```js
const newPosition = positionLocal.toVar()
```
