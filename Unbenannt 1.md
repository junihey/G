Für deinen Fall kippt die Empfehlung deutlich — aus einem Grund, den wir bisher gar nicht besprochen haben: Bandbreite.

Die entscheidende Erkenntnis

3D-Modelle (GLB) und Audio-Samples sind groß. Ein einzelnes detailliertes Modell kann 20–100 MB haben, eine WAV-Sammlung schnell mehrere Hundert MB. Dein Kostentreiber ist nicht die Datenbank — es ist der Traffic beim Ausliefern.

Und genau da wird es interessant: Cloudflare R2 verlangt $0,00/GB für Egress, bei jedem Volumen. AWS nimmt $0,09, GCP $0,12. Der Free-Tier umfasst 10 GB Speicher, 1 Mio. Class-A- und 10 Mio. Class-B-Operationen pro Monat — und das ist ein monatlich wiederkehrender Free-Tier, kein 12-Monats-Trial.

Zum Vergleich: Convex' Free-Tier gibt dir 1 GB Dateien. Das ist für 3D-Assets nichts.

Die Architektur, die ich empfehlen würde

Trenne Bytes von Metadaten.

|   |   |
|---|---|
|Ebene|Womit|
|Die eigentlichen Dateien (GLB, WAV, Texturen)|Cloudflare R2|
|Metadaten (Name, Tags, Kategorie, Autor, Version)|Datenbank — winzig, ein paar MB|
|Frontend|Vercel, Netlify oder Cloudflare Pages|

Die Datenbank speichert nur Zeilen wie { name: "kick_808.wav", key: "audio/kick_808.wav", bpm: 120, tags: [...] }. Das ist so klein, dass die DB-Wahl fast egal wird — jeder Free-Tier reicht.

Brauchst du überhaupt Realtime?

Ehrliche Frage. Wenn deine Seite ein Showcase/Portfolio ist, bei dem Besucher Modelle anschauen und Samples abspielen: nein. Dann brauchst du gar kein reaktives Backend. R2 + statisches Hosting reicht, und du zahlst praktisch nichts.

Realtime lohnt sich erst, wenn:

- Mehrere Nutzer sich gleichzeitig in derselben 3D-Szene bewegen (Avatare, Cursor)
- Nutzer Assets hochladen und andere sollen sie sofort sehen
- Kollaboratives Bearbeiten stattfindet

Konkrete Empfehlung

Showcase/Portfolio: R2 + Astro/Next auf Cloudflare Pages. Kosten: ~0 €. Kein Backend nötig.

Mit Upload/Nutzerkonten, aber ohne Multiplayer: R2 + Supabase (Auth, Metadaten-Tabelle). Dessen Storage-Egress ist teuer — deshalb R2 für die Dateien.

Mit echtem Multiplayer in der Szene: R2 für Assets + Convex für State. Aber Vorsicht: Positions-Updates von Avataren sind Hochfrequenz-Traffic. Convex Free hat 1 Mio. Function Calls/Monat — bei 20 Updates/Sekunde pro Nutzer ist das in Minuten weg. Für Bewegungsdaten nimmt man besser einen reinen Realtime-Transport (Liveblocks, PartyKit, oder ein eigener WebSocket-Server) und die DB nur für persistenten State.

Drei Three.js-spezifische Tipps

1. Draco- oder Meshopt-Kompression für GLB — reduziert Modelle oft um 70–90 %.
2. KTX2/Basis für Texturen statt PNG/JPG — wird direkt auf der GPU dekomprimiert, spart RAM und Ladezeit.
3. Audio-Sprites oder Opus statt WAV — falls die Samples nicht in Studioqualität gebraucht werden.

Diese drei Maßnahmen können deine Storage- und Traffic-Kosten stärker senken als jede Plattformwahl.

Sag mir, ob die Seite eher Showcase oder kollaborativ ist — dann kann ich konkreter werden.