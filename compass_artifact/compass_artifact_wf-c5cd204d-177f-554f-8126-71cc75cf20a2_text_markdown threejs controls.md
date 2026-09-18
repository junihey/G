# three.js Controls & Interaktionsmodalitäten – Vollständige Übersicht mit Fokus auf Interaktivität und Barrierefreiheit (Stand 2026)

## TL;DR
- three.js liefert (Stand r186, 8. September 2026) **neun offizielle Addon-Controls** unter `three/addons/controls/`: OrbitControls, MapControls, TrackballControls, ArcballControls, FlyControls, FirstPersonControls, PointerLockControls, DragControls und TransformControls; alle erben inzwischen von einer gemeinsamen abstrakten `Controls`-Basisklasse (`connect`/`disconnect`/`dispose`/`update`). DeviceOrientationControls (Tilt) wurde entfernt – laut PR #22654, „because a reliable implementation across all devices was not possible", ohne offiziellen Ersatz.
- Gesten, die keine Built-in-Control abdeckt (Tap/Klick-Selektion, Hover, Long-Press, Double-Tap, Swipe, eigenes Pinch, Tilt via DeviceOrientationEvent, Gamepad, WebXR-Controller/Hand-Tracking), implementiert man selbst über Raycaster + Pointer Events bzw. die jeweiligen Web-APIs; Bibliotheken wie camera-controls (yomotsu), @react-three/drei und @use-gesture/hammer.js erweitern den Funktionsumfang.
- Barrierefreiheit ist der kritische Punkt: Das `<canvas>` ist für Screenreader ein Pixelbild. Jede Geste braucht eine **Tastatur-/Button-Alternative** (WCAG 2.1.1, 2.5.1, 2.5.7), Tilt/Motion muss abschaltbar sein (2.5.4), Auto-Rotation/Damping müssen `prefers-reduced-motion` respektieren (2.3.3) – Werkzeuge dafür sind `tabindex`, ARIA, Live-Regions, ein DOM-Overlay und `@react-three/a11y`.

## Key Findings
1. **Vollständige offizielle Liste** (Ordner `examples/jsm/controls` im mrdoob/three.js-Repo, verifiziert): OrbitControls, MapControls, TrackballControls, ArcballControls, FlyControls, FirstPersonControls, PointerLockControls, DragControls, TransformControls. Alle sind Addons und müssen explizit importiert werden.
2. **Gemeinsame Basisklasse `Controls`** (`src/extras/Controls.js`, Kern – kein Addon): abstrakte Basis („Abstract base class for controls.") mit `object`, `domElement`, `enabled` (Default `true`), `state`, `keys`, `mouseButtons`, `touches` und den Methoden `connect(element)`, `disconnect()`, `dispose()`, `update(delta)`. TransformControls ist nun davon abgeleitet – die visuelle Repräsentation wird über `scene.add(controls.getHelper())` hinzugefügt.
3. **Kamera-Controls** (OrbitControls, MapControls, TrackballControls, ArcballControls, FlyControls, FirstPersonControls, PointerLockControls) bewegen die Kamera; **Objekt-Controls** (DragControls, TransformControls) manipulieren Objekte.
4. **Entfernte/veraltete Klassen**: DeviceOrientationControls wurde entfernt (PR #22654), weil „a reliable implementation across all devices was not possible. It was also not sufficient for a XR fallback." – es gibt keinen offiziellen Ersatz (Issue #22996: „there is no alternative"); man muss DeviceOrientationEvent selbst implementieren. In der aktuellen Migration wurden zudem `DragControls.activate()/deactivate()` zu `connect()/disconnect()` umbenannt und `PointerLockControls.getObject()` entfernt (→ `controls.object`).
5. **Barrierefreiheit** ist nicht „eingebaut": WebGL rendert in ein `<canvas>`, das ohne ARIA/Fallback für Assistenztechnologie unsichtbar ist. Lösungsmuster: fokussierbares Canvas (`tabindex="0"`), ARIA-Rolle + Label, paralleles interaktives DOM-Overlay, sichtbare Buttons für Zoom/Rotate, `prefers-reduced-motion`-Handling und `@react-three/a11y` (für R3F).

---

## Details

### 1. Die offiziellen Addon-Controls im Einzelnen

Alle Beispiele nutzen ES-Module. Standard-Import-Map-Setup:

```html
<script type="importmap">
{ "imports": {
  "three": "https://unpkg.com/three@0.186.0/build/three.module.js",
  "three/addons/": "https://unpkg.com/three@0.186.0/examples/jsm/"
}}
</script>
```

#### OrbitControls
**Zweck:** Kamera umkreist ein Ziel (`target`); behält „up"-Richtung (`object.up`, per Default +Y). Standard-Kamera-Control für Modell-Viewer.
**Gesten:**
- Orbit/Rotate: linke Maustaste / Touch: 1 Finger bewegen
- Zoom (Dolly): Mausrad oder mittlere Maustaste / Touch: 2 Finger spreizen/zusammenziehen (Pinch)
- Pan: rechte Maustaste, oder linke Maustaste + Ctrl/Meta/Shift, oder Pfeiltasten / Touch: 2 Finger bewegen

**Wichtige Properties:** `enableDamping` (+ `dampingFactor`), `enablePan`, `enableZoom`, `enableRotate`, `autoRotate` (+ `autoRotateSpeed`), `zoomToCursor` (Default `false`), `minDistance`/`maxDistance`, `minPolarAngle`/`maxPolarAngle`, `minAzimuthAngle`/`maxAzimuthAngle`, `target`, `zoomSpeed`, `rotateSpeed`, `panSpeed`, `keys` (Default `{LEFT:'ArrowLeft', UP:'ArrowUp', RIGHT:'ArrowRight', BOTTOM:'ArrowDown'}`), `mouseButtons` (Default `{LEFT:ROTATE, MIDDLE:DOLLY, RIGHT:PAN}`), `touches` (Default `{ONE:ROTATE, TWO:DOLLY_PAN}`).
**Methoden:** `update()` (erforderlich bei Damping/autoRotate), `listenToKeyEvents(domElement)` (aktiviert Tastatursteuerung, standardmäßig NICHT aktiv!), `stopListenToKeyEvents()`, `saveState()`, `reset()`, `getPolarAngle()`, `getAzimuthalAngle()`, `getDistance()`.
**Events:** `change`, `start`, `end`.

```js
import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(innerWidth, innerHeight);
document.body.appendChild(renderer.domElement);

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(45, innerWidth/innerHeight, 0.1, 1000);
camera.position.set(0, 2, 8);
scene.add(new THREE.Mesh(new THREE.BoxGeometry(), new THREE.MeshNormalMaterial()));

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;          // sanftes Ausklingen
controls.zoomToCursor = true;
controls.minDistance = 2; controls.maxDistance = 20;
controls.listenToKeyEvents(window);     // WICHTIG für Tastaturnutzer: Pan per Pfeiltasten

// Auto-Rotate nur, wenn der Nutzer keine reduzierte Bewegung wünscht (WCAG 2.3.3)
const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
controls.autoRotate = !reduce;

renderer.setAnimationLoop(() => {
  controls.update();
  renderer.render(scene, camera);
});
```

#### MapControls
**Zweck:** Kamera-Bewegung über eine Karte aus der Vogelperspektive. Teilt die Implementierung mit OrbitControls, aber mit anderem Preset und deaktiviertem Screen-Space-Panning.
**Gesten:** Pan: linke Maustaste oder Pfeiltasten / Touch: 1 Finger; Orbit: rechte Maustaste bzw. linke + Ctrl/Meta/Shift / Touch: 2 Finger rotieren; Zoom: mittlere Maustaste/Mausrad / Touch: Pinch.
**Property-Unterschied:** `mouseButtons = {LEFT:PAN, MIDDLE:DOLLY, RIGHT:ROTATE}`, `screenSpacePanning = false`.

```js
import { MapControls } from 'three/addons/controls/MapControls.js';
const controls = new MapControls(camera, renderer.domElement);
controls.enableDamping = true;
// controls.update() im Animationsloop erforderlich
```

#### TrackballControls
**Zweck:** Freies Rotieren ohne feste „up"-Achse – die Kamera kann über die Pole hinausdrehen und sich „überschlagen" (kein Gimbal-Constraint wie bei OrbitControls). Gut für Inspektion von Objekten aus jedem Winkel.
**Gesten:** Rotate: linke Maustaste (oder Taste A) / Zoom: mittlere Maustaste, Mausrad (oder Taste S) / Pan: rechte Maustaste (oder Taste D).
**Properties:** `rotateSpeed` (Default `1.0`), `zoomSpeed` (Default `1.2`), `panSpeed` (Default `0.3`), `noRotate`, `noZoom`, `noPan`, `staticMoving` (Default `false`; deaktiviert Damping), `dynamicDampingFactor` (Default `0.2`), `minDistance`/`maxDistance`, `keys` (Default `KeyA, KeyS, KeyD`).
**Besonderheit:** `handleResize()` muss bei Fenstergrößenänderung aufgerufen werden; `update()` jeden Frame.

```js
import { TrackballControls } from 'three/addons/controls/TrackballControls.js';
const controls = new TrackballControls(camera, renderer.domElement);
controls.rotateSpeed = 2.0;
controls.staticMoving = false;   // Damping an
addEventListener('resize', () => controls.handleResize());
```

#### ArcballControls
**Zweck:** Präzises „Trackball"-Gefühl per virtueller Kugel (Gizmo), mit Rotation, Pan, Zoom, Fokus und Animationen. Unterstützt perspektivische und orthografische Kameras.
**Gesten:** Rotate/Pan/Zoom per Maus/Touch, Doppelklick zum Fokussieren, Gizmos zum achsenweisen Drehen.
**Properties:** `enableAnimations`, `enablePan`, `enableRotate`, `enableZoom`, `cursorZoom` (Default `false`), `adjustNearFar` (Default `false`), `scaleFactor`, `dampingFactor`, `wMax`, `setGizmosVisible()`, `setCamera()`.
**Besonderheit:** Anders als Orbit/Trackball ist bei aktivierten Animationen kein externer `update()`-Aufruf im Loop nötig.

```js
import { ArcballControls } from 'three/addons/controls/ArcballControls.js';
const controls = new ArcballControls(camera, renderer.domElement, scene);
controls.setGizmosVisible(true);
```

#### FlyControls
**Zweck:** Navigation wie im Flugmodus von DCC-Tools (Blender). Laut Doku: „You can arbitrarily transform the camera in 3D space without any limitations."
**Gesten/Tasten:** WASD (vor/zurück/seitlich), R/F (hoch/runter), Q/E (Roll), Pfeiltasten (Pitch/Yaw), Maus-Look (dauerhaft, oder nur bei Drag wenn `dragToLook = true`).
**Properties:** `movementSpeed` (Default `1`), `rollSpeed` (Default `0.005`), `dragToLook` (Default `false`), `autoForward` (Default `false`).
**Event:** `change`. **Muss** `update(delta)` mit `clock.getDelta()` pro Frame aufrufen.

```js
import { FlyControls } from 'three/addons/controls/FlyControls.js';
const clock = new THREE.Clock();
const controls = new FlyControls(camera, renderer.domElement);
controls.movementSpeed = 10;
controls.rollSpeed = Math.PI / 6;
controls.dragToLook = true;
renderer.setAnimationLoop(() => {
  controls.update(clock.getDelta());   // delta erforderlich
  renderer.render(scene, camera);
});
```

#### FirstPersonControls
**Zweck:** Alternative Implementierung von FlyControls für Ego-Perspektive (z. B. Terrain-Begehung).
**Gesten/Tasten:** WASD/Pfeiltasten zum Bewegen, Maus zum Umsehen.
**Properties:** `movementSpeed`, `lookSpeed`, `activeLook` (Default `true`), `autoForward` (Default `false`), `constrainVertical` (+ `verticalMin`/`verticalMax`), `lookAt()`, `heightSpeed`/`heightCoef`/`heightMin`/`heightMax`. `update(delta)` pro Frame.

```js
import { FirstPersonControls } from 'three/addons/controls/FirstPersonControls.js';
const controls = new FirstPersonControls(camera, renderer.domElement);
controls.movementSpeed = 5;
controls.lookSpeed = 0.05;
// controls.update(clock.getDelta()) im Loop
```

#### PointerLockControls
**Zweck:** Basiert auf der Pointer Lock API; laut Doku „a perfect choice for first person 3D games." Die Maus wird gefangen (Cursor ausgeblendet), nur Bewegungs-Deltas steuern die Blickrichtung.
**Methoden:** `lock(unadjustedMovement=false)`, `unlock()`, `moveForward(distance)`, `moveRight(distance)`, `getDirection(v)`, plus geerbte `connect/disconnect/dispose`.
**Properties:** `isLocked` (readonly, Default `false`), `pointerSpeed` (Default `1`), `minPolarAngle` (Default `0`), `maxPolarAngle` (Default `Math.PI`).
**Events:** `lock`, `unlock`, `change`.
**Wichtig:** `lock()` muss durch eine Nutzergeste (Klick) ausgelöst werden (Browser-Sicherheit der Pointer Lock API).

```js
import { PointerLockControls } from 'three/addons/controls/PointerLockControls.js';
const controls = new PointerLockControls(camera, document.body);
const startBtn = document.getElementById('start');
startBtn.addEventListener('click', () => controls.lock());
controls.addEventListener('lock',   () => startBtn.style.display = 'none');
controls.addEventListener('unlock', () => startBtn.style.display = '');

// Bewegung per WASD selbst umsetzen (Controls liefern nur die Blickrichtung/Helfer)
const keys = {};
addEventListener('keydown', e => keys[e.code] = true);
addEventListener('keyup',   e => keys[e.code] = false);
renderer.setAnimationLoop(() => {
  if (controls.isLocked) {
    const d = 0.1;
    if (keys['KeyW']) controls.moveForward(d);
    if (keys['KeyS']) controls.moveForward(-d);
    if (keys['KeyA']) controls.moveRight(-d);
    if (keys['KeyD']) controls.moveRight(d);
  }
  renderer.render(scene, camera);
});
```

#### DragControls
**Zweck:** Objekte per Maus/Touch verschieben (Drag & Drop) via Raycasting.
**Gesten:** Hover-Highlight, Drag zum Verschieben.
**Konstruktor:** `new DragControls(objects, camera, domElement)`. Properties: `objects`, `raycaster`, `recursive` (Default `true`), `transformGroup`, `rotateSpeed`, `mode` (`'translate'`/`'rotate'`).
**Events:** `dragstart`, `drag`, `dragend`, `hoveron`, `hoveroff`.
**Migration:** `activate()/deactivate()` heißen jetzt `connect()/disconnect()`; `getObjects()/setObjects()` entfernt → `controls.objects`.

```js
import { DragControls } from 'three/addons/controls/DragControls.js';
const controls = new DragControls(objects, camera, renderer.domElement);
controls.addEventListener('dragstart', e => e.object.material.emissive.set(0xaaaaaa));
controls.addEventListener('dragend',   e => e.object.material.emissive.set(0x000000));
```

#### TransformControls
**Zweck:** Gizmo zum interaktiven Verschieben/Rotieren/Skalieren eines Objekts (Editor-Handles).
**Methoden:** `attach(object)`, `detach()`, `setMode('translate'|'rotate'|'scale')`, `setSpace('world'|'local')`, `setTranslationSnap()`, `setRotationSnap()`, `setScaleSnap()`, `setSize()`, `getHelper()`, `reset()`.
**Properties:** `axis`, `dragging`, `mode`, `enabled`, `camera`.
**Events:** `change`, `dragging-changed` (nützlich um OrbitControls während des Ziehens zu deaktivieren), `objectChange`, `mouseDown`, `mouseUp`.
**Migration r170+:** Nun von `Controls` abgeleitet; statt `scene.add(controls)` jetzt `scene.add(controls.getHelper())`.

```js
import { TransformControls } from 'three/addons/controls/TransformControls.js';
const tcontrols = new TransformControls(camera, renderer.domElement);
tcontrols.attach(mesh);
scene.add(tcontrols.getHelper());     // NICHT mehr scene.add(tcontrols)
tcontrols.addEventListener('dragging-changed', e => orbit.enabled = !e.value);
```

### 2. Gesten & Eingaben, die keine Built-in-Control abdeckt

#### Tap/Klick-Selektion, Hover via Raycaster + Pointer Events
Der `Raycaster` übersetzt eine 2D-Zeigerposition in einen 3D-Strahl und liefert getroffene Objekte. Für Barrierefreiheit `pointerdown`/`click` (statt nur `mousedown`) und Pointer Events verwenden, da sie Maus, Touch und Stift vereinheitlichen.

```js
const raycaster = new THREE.Raycaster();
const pointer = new THREE.Vector2();

function toNDC(e, el) {
  const r = el.getBoundingClientRect();
  pointer.x = ((e.clientX - r.left) / r.width) * 2 - 1;
  pointer.y = -((e.clientY - r.top) / r.height) * 2 + 1;
}
renderer.domElement.addEventListener('pointerdown', (e) => {
  toNDC(e, renderer.domElement);
  raycaster.setFromCamera(pointer, camera);
  const hits = raycaster.intersectObjects(scene.children, true);
  if (hits.length) selectObject(hits[0].object);
});
```

#### Hover, Long-Press, Double-Tap, Swipe, eigenes Pinch
Diese Gesten sind nicht als API vorhanden – man leitet sie aus Pointer/Touch-Events ab:
- **Hover:** `pointermove` + Raycaster (nur auf Geräten mit `hover`-Fähigkeit, per `matchMedia('(hover: hover)')` prüfen).
- **Long-Press:** Timer bei `pointerdown` (~500 ms), Abbruch bei `pointerup`/`pointermove` über Schwellwert.
- **Double-Tap:** zwei `pointerup` innerhalb ~300 ms und geringer Distanz.
- **Swipe:** Delta zwischen `pointerdown` und `pointerup` über Schwellwert + Richtung.
- **Pinch:** zwei aktive Pointer verfolgen (`pointerId` in einer Map), Abstandsänderung → Zoom.

```js
// Beispiel Long-Press + Double-Tap
let pressTimer, lastTap = 0;
const el = renderer.domElement;
el.addEventListener('pointerdown', () => {
  pressTimer = setTimeout(() => onLongPress(), 500);
});
el.addEventListener('pointerup', (e) => {
  clearTimeout(pressTimer);
  const now = performance.now();
  if (now - lastTap < 300) onDoubleTap(e);
  lastTap = now;
});

// Eigenes Pinch mit Pointer Events
const active = new Map();
let startDist = 0;
el.addEventListener('pointerdown', e => active.set(e.pointerId, e));
el.addEventListener('pointermove', e => {
  if (!active.has(e.pointerId)) return;
  active.set(e.pointerId, e);
  if (active.size === 2) {
    const [a, b] = [...active.values()];
    const dist = Math.hypot(a.clientX-b.clientX, a.clientY-b.clientY);
    if (startDist) camera.position.z *= startDist / dist;
    startDist = dist;
  }
});
el.addEventListener('pointerup', e => { active.delete(e.pointerId); startDist = 0; });
```
Wichtig: Auf dem Canvas `touch-action: none` (CSS) setzen, damit der Browser Swipe/Pinch nicht selbst als Scroll/Zoom abfängt.

#### Tilt / Device Orientation (Neigungssteuerung)
`DeviceOrientationControls` wurde entfernt. Man nutzt `DeviceOrientationEvent` direkt. **iOS 13+ verlangt** eine explizite Berechtigung über `DeviceOrientationEvent.requestPermission()`. Laut MDN „requires transient activation, meaning that it must be triggered by a UI event such as a button click", ist „available only in secure contexts (HTTPS)" und liefert „a Promise that resolves with a string which is either 'granted' or 'denied'." (Optionaler Parameter `absolute` bezieht das Magnetometer ein.)

```js
const btn = document.getElementById('enable-tilt');
btn.addEventListener('click', async () => {
  if (typeof DeviceOrientationEvent?.requestPermission === 'function') {
    const state = await DeviceOrientationEvent.requestPermission(); // nur iOS
    if (state !== 'granted') return;
  }
  window.addEventListener('deviceorientation', (e) => {
    // alpha (Z), beta (X, vor/zurück), gamma (Y, links/rechts) in Grad
    const euler = new THREE.Euler(
      THREE.MathUtils.degToRad(e.beta ?? 0),
      THREE.MathUtils.degToRad(e.alpha ?? 0),
      -THREE.MathUtils.degToRad(e.gamma ?? 0), 'YXZ');
    camera.quaternion.setFromEuler(euler);
  });
});
```
**Barrierefreiheit (WCAG 2.5.4 Motion Actuation):** Tilt darf niemals die einzige Bedienung sein und muss abschaltbar sein – hier über den Opt-in-Button gelöst; zusätzlich müssen OrbitControls o. Ä. als Alternative bereitstehen.

#### Gamepad API
Polling-basiert im Animationsloop (kein Event pro Achse). `gamepadconnected`-Event abwarten, dann `navigator.getGamepads()` pro Frame lesen; Deadzone anwenden und für Buttons Edge-Detection nutzen.

```js
let padIndex = null;
addEventListener('gamepadconnected', e => padIndex = e.gamepad.index);
function dz(v, t=0.1){ return Math.abs(v) < t ? 0 : v; }
renderer.setAnimationLoop(() => {
  if (padIndex !== null) {
    const gp = navigator.getGamepads()[padIndex];
    if (gp) {
      camera.position.x += dz(gp.axes[0]) * 0.1;
      camera.position.z += dz(gp.axes[1]) * 0.1;
      if (gp.buttons[0].pressed) jump();
    }
  }
  renderer.render(scene, camera);
});
```

#### WebXR-Controller & Hand-Tracking
three.js abstrahiert die WebXR Device API. Controller/Grips holt man über `renderer.xr.getController(i)` und `renderer.xr.getControllerGrip(i)`; visuelle Modelle liefert `XRControllerModelFactory`, Hände `XRHandModelFactory`. Standard-Events: `selectstart`/`selectend` (Primäraktion/Trigger), `squeezestart`/`squeezeend` (Griff), sowie `connected`/`disconnected`. Für Hand-Tracking dispatcht three.js zusätzlich `pinchstart`/`pinchend` (Abstand Daumen–Zeigefinger).

```js
import { VRButton } from 'three/addons/webxr/VRButton.js';
import { XRControllerModelFactory } from 'three/addons/webxr/XRControllerModelFactory.js';
import { XRHandModelFactory } from 'three/addons/webxr/XRHandModelFactory.js';

renderer.xr.enabled = true;
document.body.appendChild(VRButton.createButton(renderer, { optionalFeatures: ['hand-tracking'] }));

const controllerModelFactory = new XRControllerModelFactory();
const handModelFactory = new XRHandModelFactory();
for (let i = 0; i < 2; i++) {
  const controller = renderer.xr.getController(i);
  controller.addEventListener('selectstart', onSelectStart);
  controller.addEventListener('selectend', onSelectEnd);
  controller.addEventListener('squeezestart', onSqueeze);
  scene.add(controller);

  const grip = renderer.xr.getControllerGrip(i);
  grip.add(controllerModelFactory.createControllerModel(grip));
  scene.add(grip);

  const hand = renderer.xr.getHand(i);
  hand.add(handModelFactory.createHandModel(hand));
  hand.addEventListener('pinchstart', onPinch);
  scene.add(hand);
}
```

#### Tastaturnavigation
Für reine Kamera-Controls: `OrbitControls.listenToKeyEvents(window)` aktiviert Pan per Pfeiltasten. Für Objekt-Selektion/-Aktion: Canvas fokussierbar machen (`tabindex="0"`) und `keydown` behandeln (Enter/Space = aktivieren, Pfeiltasten = zwischen Objekten wechseln). Siehe Abschnitt Barrierefreiheit.

### 3. Wichtige Drittanbieter-Bibliotheken

- **camera-controls (yomotsu):** Der de-facto Standard-Ersatz für OrbitControls mit weichen Übergängen/Transitions. Bietet `dolly`, `truck` (Pan), `rotateTo`, `zoomTo`, `fitToBox`, `setLookAt`, konfigurierbare `mouseButtons`/`touches` (`ACTION.ROTATE/TRUCK/DOLLY/ZOOM/...`), `smoothTime`/`draggingSmoothTime`, `colliderMeshes` (Kamerakollision), `infinityDolly`, `boundaryEnclosesCamera`. Braucht ein `install()` mit einem THREE-Subset.

```js
import * as THREE from 'three';
import CameraControls from 'camera-controls';
CameraControls.install({ THREE });
const clock = new THREE.Clock();
const controls = new CameraControls(camera, renderer.domElement);
controls.dollyToCursor = true;
renderer.setAnimationLoop(() => {
  controls.update(clock.getDelta());
  renderer.render(scene, camera);
});
```

- **@react-three/drei (für React Three Fiber):** wrappt die three.js-Controls und ergänzt eigene: `OrbitControls`, `MapControls`, `TrackballControls`, `ArcballControls`, `FlyControls`, `PointerLockControls`, `FirstPersonControls`, `CameraControls` sowie **`PresentationControls`** (rotiert den Inhalt statt der Kamera, mit Federn/Snap-Back und Limits), **`ScrollControls`** (bindet Scroll-Position an Animation; `pages`, `damping`, `horizontal`, `infinite`), **`KeyboardControls`** (deklaratives Key-Mapping über den `useKeyboardControls`-Hook), `DragControls`, `PivotControls`, `TransformControls`, `MotionPathControls`.

```jsx
<PresentationControls global polar={[0, Math.PI/2]} azimuth={[-Infinity, Infinity]}>
  <mesh>{/* ... */}</mesh>
</PresentationControls>

<KeyboardControls map={[
  { name: 'forward', keys: ['ArrowUp', 'KeyW'] },
  { name: 'jump',    keys: ['Space'] },
]}>
  <Player />
</KeyboardControls>
```

- **@react-three/a11y:** Bringt Fokus, Tab-Index, Screenreader-Support und Alt-Texte in R3F (siehe Abschnitt 4).
- **Gesten-Bibliotheken:** **@use-gesture/react** (bzw. vanilla `@use-gesture/vanilla`) und **hammer.js** liefern robuste, normalisierte Erkennung von Drag, Pinch, Swipe, Long-Press etc. und lassen sich mit Raycasting/Controls kombinieren, statt Pointer-Logik selbst zu schreiben.

### 4. Barrierefreiheit in der Tiefe

**Grundproblem:** Das `<canvas>` ist „only a image of pixels" – Screenreader sehen den 3D-Inhalt nicht. Man kann dem Canvas nur eine ARIA-Rolle + Label geben oder Fallback-Content bzw. ein paralleles DOM bereitstellen.

**a) Fokus & Tastatur (WCAG 2.1.1 Keyboard).** Canvas mit `tabindex="0"` fokussierbar machen; `tabindex` allein macht das Element „TABable", aktiviert es aber nicht – Enter/Space-Handler ergänzen. Für Kamera-Pan `controls.listenToKeyEvents(window)` setzen. Jede Maus-/Touch-Interaktion braucht ein Tastatur-Äquivalent.

**b) ARIA & Live-Regions.**
```html
<canvas id="scene" tabindex="0" role="img"
        aria-label="3D-Ansicht eines Motors. Nutze die Buttons unten zum Drehen und Zoomen.">
</canvas>
<div id="a11y-status" aria-live="polite" class="visually-hidden"></div>
```
Statusänderungen (z. B. „Objekt Zylinderkopf ausgewählt") in die Live-Region schreiben, damit Screenreader sie ansagen. Für komplexe Datenszenen eine textliche/tabellarische Alternative anbieten (role=img + `aria-describedby`).

**c) Sichtbare Bedien-Buttons (WCAG 2.5.1 Pointer Gestures, 2.5.7 Dragging Movements, 2.5.8 Target Size).** Alle Multipoint-/Pfad-Gesten (Pinch-Zoom, Zwei-Finger-Rotate, Drag-Pan) müssen sich auch mit einem einzelnen Zeiger ohne Pfad bedienen lassen – konkret über echte `<button>`-Elemente für Zoom +/−, Rotieren links/rechts/hoch/runter und „Ansicht zurücksetzen". Die Ziele sollten laut SC 2.5.8 Target Size (Minimum), Level AA (neu in WCAG 2.2) mindestens **24×24 CSS-Pixel** groß sein („The size of the target for pointer inputs is at least 24 by 24 CSS pixels…", mit Ausnahmen für Spacing/Inline/Essential); das strengere SC 2.5.5 (Level AAA) fordert **44×44 CSS-Pixel**.
```html
<div class="viewer-controls">
  <button aria-label="Hineinzoomen">＋</button>
  <button aria-label="Herauszoomen">－</button>
  <button aria-label="Nach links drehen">◀</button>
  <button aria-label="Nach rechts drehen">▶</button>
  <button aria-label="Ansicht zurücksetzen">⟳</button>
</div>
```
```js
zoomInBtn.addEventListener('click', () => { camera.position.multiplyScalar(0.9); controls.update(); });
rotateLeftBtn.addEventListener('click', () => { controls.setAzimuthalAngle?.(controls.getAzimuthalAngle() - 0.2); });
```

**d) Pointer Cancellation (WCAG 2.5.2).** Aktionen erst bei `pointerup`/`click` auslösen (nicht schon bei `pointerdown`), damit Nutzer eine begonnene Geste durch Wegziehen abbrechen können.

**e) Bewegung & Motion Sickness (WCAG 2.3.3 Animation from Interactions, 2.5.4 Motion Actuation).** `prefers-reduced-motion` respektieren: Auto-Rotate, Damping/Inertia, Kamera-Tweens und parallax-artige Effekte reduzieren oder abschalten. Das gilt auch für JS-getriebene Animationen (eine CSS-`@media`-Regel deckt three.js-Animationen NICHT ab – `matchMedia` in JS abfragen; vgl. W3C-Technik SCR40). Tilt-Steuerung immer optional und abschaltbar halten.
```js
const mq = matchMedia('(prefers-reduced-motion: reduce)');
function applyMotionPref() {
  controls.autoRotate = !mq.matches;
  controls.enableDamping = !mq.matches;
}
applyMotionPref();
mq.addEventListener('change', applyMotionPref);   // live auf Änderung reagieren
```

**f) `touch-action` CSS.** `canvas { touch-action: none; }` verhindert, dass native Browser-Gesten mit den 3D-Gesten kollidieren – aber nur setzen, wenn eigene Alternativen existieren, sonst nimmt man Nutzern das native Scrollen.

**g) Pointer-Lock-Vorbehalte.** PointerLockControls fangen die Maus und blenden den Cursor aus – für viele Nutzer (Motorik, Screenreader, Nutzer die Escape zum Verlassen brauchen) problematisch. Nur mit klarer Anleitung, Opt-in-Klick und einer Nicht-Pointer-Lock-Alternative einsetzen.

**h) @react-three/a11y (R3F).** Stellt `<A11yAnnouncer/>` (Live-Region-Div für Screenreader) und `<A11y>` bereit, das fokussierbare Objekte mit Rolle (`content`→`<p>`, `button`→`<button>`, `togglebutton`→`<button aria-pressed>`, `link`→`<a>`), Alt-Text, Tab-Index und `focusCall`/`actionCall`-Callbacks versieht; der `useA11y()`-Hook liefert Hover/Focus/Pressed-Status zum visuellen Feedback. Es synchronisiert ein unsichtbares, aber semantisches DOM mit der 3D-Szene.
```jsx
import { A11y, A11yAnnouncer } from '@react-three/a11y';
<Canvas>{/* ... */}
  <A11y role="button" description="Motor starten" actionCall={startEngine}>
    <EngineMesh />
  </A11y>
</Canvas>
<A11yAnnouncer />
```
Für Vanilla-three.js existiert das kleinere Paket **a3** (fokussierbare Meshes, Tab + Enter, Cursor-Wechsel).

### 5. Zusammenfassungstabelle: Geste → Control/Technik → barrierefreie Alternative

| Geste / Eingabe | Bereitgestellt durch | Barrierefreie Alternative |
|---|---|---|
| **Tap/Klick (Selektion)** | Raycaster + `pointerdown`/`click` | Canvas `tabindex=0` + Enter/Space; Tab zwischen Objekten |
| **Double-Tap** | eigene Erkennung (2× `pointerup`) | Button „Fokussieren/Zoomen" |
| **Long-Press** | eigener Timer auf `pointerdown` | Kontextmenü-Button |
| **Hover** | `pointermove` + Raycaster | Fokus-Zustand (`:focus`) statt Hover; `useA11y` |
| **Swipe/Pan** | OrbitControls (Pan), MapControls | Pfeiltasten (`listenToKeyEvents`) + Pan-Buttons |
| **Pinch-Zoom** | OrbitControls/MapControls (2 Finger) | Zoom +/− Buttons; Mausrad; +/-Tasten |
| **Zwei-Finger-Rotate** | OrbitControls/MapControls/Arcball | Rotier-Buttons; Pfeiltasten |
| **Drag (Kamera-Orbit)** | OrbitControls, Trackball, Arcball | Tastatur-Orbit / Buttons (WCAG 2.5.7) |
| **Drag (Objekt bewegen)** | DragControls, TransformControls | Auswahl + Pfeiltasten-Verschiebung; numerische Eingabe |
| **Wheel (Dolly/Zoom)** | OrbitControls, camera-controls | Zoom-Buttons; +/-Tasten |
| **Rotate/Move/Scale-Gizmo** | TransformControls | Modus-Buttons + Tastatureingabe der Werte |
| **Tastatur** | `listenToKeyEvents`, KeyboardControls | ist selbst die Alternative – immer bereitstellen |
| **Gamepad** | Gamepad API (Polling) | zusätzlich Tastatur/Buttons |
| **Tilt / Device Orientation** | `DeviceOrientationEvent` (selbst; iOS-Permission) | MUSS abschaltbar sein + Orbit/Buttons (WCAG 2.5.4) |
| **XR Select/Squeeze/Pinch** | `getController()`, XRHandModelFactory | mehrere Eingabequellen (Controller + Hand + Gaze) anbieten |
| **Ego-Blick (Maus gefangen)** | PointerLockControls | Nicht-Pointer-Lock-Modus + Tastaturblick |

## Recommendations

**Stufe 1 – Basis-Viewer (die meisten Projekte):** Nimm **OrbitControls** mit `enableDamping`, sinnvollen `minDistance`/`maxDistance`/`maxPolarAngle`-Limits und rufe **immer `listenToKeyEvents(window)`** auf. Setze `canvas` auf `tabindex="0"`, `role="img"` + aussagekräftiges `aria-label`, und ergänze sichtbare **Zoom-/Rotate-/Reset-Buttons** (≥24×24 px). Damit erfüllst du 2.1.1, 2.5.1, 2.5.7 und 2.5.8 ohne großen Aufwand.

**Stufe 2 – Politur & Motion-Safety:** Frage `prefers-reduced-motion` per `matchMedia` ab und deaktiviere dann `autoRotate` und `enableDamping`; registriere einen `change`-Listener für Live-Umschaltung. Setze `touch-action: none` nur zusammen mit funktionierenden Button-Alternativen. Nutze eine `aria-live="polite"`-Region für Selektions-/Statusansagen.

**Stufe 3 – Erweiterte Interaktion:** Für weiche Kamerafahrten/Framing wechsle zu **camera-controls (yomotsu)**. Für Objekt-Editing nutze **TransformControls** (via `getHelper()`, und Orbit während `dragging-changed` deaktivieren). Erkenne komplexe Gesten mit **@use-gesture** statt Handrolled-Code. In React: **drei**-Controls + **@react-three/a11y** von Anfang an einplanen.

**Stufe 4 – Spezialfälle:** Tilt/Gyro nur als optionales Opt-in (mit iOS-`requestPermission()`) und stets mit OrbitControls-Fallback. PointerLock/FlyControls/FirstPersonControls nur für Spiele/immersive Szenen und immer mit Nicht-Pointer-Lock-Alternative. WebXR: mehrere Eingabequellen (Controller + Hand-Tracking) parallel unterstützen.

**Schwellen, die die Empfehlung ändern:** Sobald du (a) Kamera-Ziele/Transitions animierst → camera-controls; (b) Objekte manipulierst → TransformControls/DragControls; (c) eine React-Codebasis hast → drei + a11y; (d) ein AA-Konformitätsziel hast → Stufe 1+2 sind Pflicht, nicht optional; (e) Motion-sensible Zielgruppe → Stufe 2 verschärfen (Animationen per Default aus).

## Caveats
- **Versionsstand:** Aktuellste Release ist r186 (laut GitHub Releases „mrdoob released this · 08 Sep 19:16 · r186"); r181 stammt vom 19. Nov. 2025. API-Details (v. a. `connect(element)`-Signatur, `getHelper()` bei TransformControls, `activate→connect` bei DragControls) wurden über die letzten Releases geändert – prüfe bei Upgrade die offizielle Migration Guide.
- **Docs-URLs:** Die live gerenderten Doku-Seiten liegen unter `threejs.org/docs/pages/<Klasse>.html`; die `#examples/en/controls/...`-Hash-Links sind nur die SPA-Index-Ansicht.
- **Nicht alle Detailangaben stehen in der offiziellen Doku:** Die genauen Tastenbelegungen von FlyControls (WASD/QE/RF) und die „Klick-nötig"-Anforderung von PointerLockControls stammen aus dem Quellcode/den Beispielen bzw. der Pointer Lock API, nicht aus der Property-Liste der Doku.
- **DeviceOrientationControls:** endgültig entfernt (PR #22654), kein gepflegter offizieller Ersatz (Issue #22996: „there is no alternative"); eigene Implementierung nötig, Browser-/Geräteverhalten (insb. `alpha`-Offset, iOS-Permission) ist uneinheitlich.
- **Barrierefreiheit ist nie „automatisch":** Selbst mit `@react-three/a11y` oder `a3` bleibt WebGL-Inhalt für Screenreader eine Blackbox; die semantische Alternative (DOM-Overlay, Textbeschreibung, Buttons) musst du bewusst gestalten und manuell testen (2.5.1/2.5.7-Verstöße sind nicht automatisiert erkennbar).
- **Gamepad/WebXR:** Gamepad-Polling bei 60 Hz kann Eingaben verpassen; WebXR-Verhalten variiert je Hardware/Browser – auf echten Geräten testen.