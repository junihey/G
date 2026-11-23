# Backend-Grundlagen — von null bis zur Entscheidung

Dieses Dokument erklärt alle Begriffe, die in der Diskussion um Convex, Postgres und PocketBase vorkamen — aber von ganz vorne. Wenn du an einer Stelle denkst „das weiß ich schon", überspring sie. Wenn du irgendwo hängenbleibst, ist das ein Zeichen, dass ein früheres Kapitel noch nicht sitzt.

**Lesezeit:** ca. 45 Minuten. Nicht in einem Rutsch. Teil 1–3 sind Pflicht, Teil 6 ist der schwierigste.

---

## Inhalt

1. [Was überhaupt passiert, wenn du eine App benutzt](#teil-1)
2. [Zwei Arten, Daten zu speichern](#teil-2)
3. [Typsicherheit — was das ist und warum alle davon reden](#teil-3)
4. [Migrationen — wenn sich das Schema ändert](#teil-4)
5. [Transaktionen — alles oder nichts](#teil-5)
6. [Realtime — das schwierigste Kapitel](#teil-6)
7. [Die drei Optionen im Vergleich](#teil-7)
8. [Glossar](#teil-8)

---

<a name="teil-1"></a>
## Teil 1 — Was überhaupt passiert, wenn du eine App benutzt

### Die drei Teile

Jede Web-App besteht aus drei Dingen:

```
[ BROWSER ]  ←→  [ SERVER ]  ←→  [ DATENBANK ]
  Frontend        Backend
```

**Frontend** — das, was du siehst. HTML, CSS, JavaScript, bei dir: React und Three.js. Läuft im Browser des Nutzers, auf dessen Computer.

**Backend** — ein Programm, das irgendwo im Internet auf einem Server läuft und rund um die Uhr wartet. Es nimmt Anfragen entgegen („gib mir alle Assets von Nutzer 42"), prüft ob der Anfragende das darf, holt die Daten und schickt sie zurück.

**Datenbank** — ein spezialisiertes Programm, das Daten dauerhaft speichert und schnell wiederfinden kann. Sie ist *nicht* einfach eine Datei; sie kümmert sich um Sortierung, Suche, gleichzeitige Zugriffe und darum, dass nichts kaputtgeht, wenn der Strom ausfällt.

### Warum nicht direkt vom Browser in die Datenbank?

Weil der Browser dem Nutzer gehört. Jeder kann in die Entwicklerkonsole schauen, den JavaScript-Code lesen und ihn verändern. Stünde dort dein Datenbank-Passwort, könnte jeder alles löschen. Das Backend ist die vertrauenswürdige Zwischenschicht: Es steht auf *deinem* Server, sein Code ist unsichtbar, und es entscheidet, was erlaubt ist.

> **Merksatz:** Alles, was im Browser läuft, ist öffentlich und manipulierbar. Sicherheitsregeln gehören immer ins Backend.

### Was ist eine „Query"?

Eine **Query** (Abfrage) ist eine Frage an die Datenbank. „Gib mir alle Assets, deren Typ 'audio' ist, sortiert nach Datum, die neuesten 20."

Eine **Mutation** ist das Gegenstück: eine Änderung. Anlegen, ändern, löschen.

Diese Unterscheidung — lesen vs. schreiben — zieht sich durch das ganze Dokument. Merk sie dir.

### Was ist ein Index?

Stell dir ein Telefonbuch vor, das nach Nachnamen sortiert ist. „Finde Müller" geht in Sekunden. „Finde alle, die in der Bahnhofstraße wohnen" bedeutet: jede Seite durchblättern.

Ein **Index** ist ein zweites, anders sortiertes Verzeichnis. Legst du einen Index auf „Straße" an, ist auch diese Frage schnell — dafür braucht der Index Platz und muss bei jeder Änderung mitgepflegt werden.

Ohne passenden Index muss die Datenbank alles durchsehen („Full Scan"). Bei 100 Einträgen egal. Bei 100.000 wird deine App langsam. **Das ist die häufigste Ursache für „meine App war anfangs schnell und ist jetzt lahm".**

---

<a name="teil-2"></a>
## Teil 2 — Zwei Arten, Daten zu speichern

### Variante A: Tabellen (relational / SQL)

Wie eine Excel-Tabelle. Spalten sind fest definiert, jede Zeile hat dieselben Spalten.

**Tabelle `users`**

| id | name  | email          |
|----|-------|----------------|
| 1  | Anna  | anna@mail.de   |
| 2  | Ben   | ben@mail.de    |

**Tabelle `assets`**

| id  | title        | typ   | owner_id |
|-----|--------------|-------|----------|
| 101 | Stuhl.glb    | model | 1        |
| 102 | Regen.mp3    | audio | 1        |
| 103 | Lampe.glb    | model | 2        |

Die Spalte `owner_id` verweist auf die `id` in `users`. Das ist eine **Beziehung** (Relation) — daher der Name „relationale Datenbank".

Abgefragt wird mit **SQL**, einer eigenen Sprache:

```sql
SELECT assets.title, users.name
FROM assets
JOIN users ON assets.owner_id = users.id
WHERE assets.typ = 'model';
```

Der **JOIN** ist das Entscheidende: Die Datenbank verbindet beide Tabellen selbst und gibt dir Titel und Besitzername in *einem* Ergebnis, in *einer* Anfrage.

**Bekannte Vertreter:** PostgreSQL („Postgres"), MySQL, SQLite.

### Variante B: Dokumente

Statt Zeilen mit festen Spalten speicherst du JSON-Objekte:

```json
{
  "_id": "abc123",
  "title": "Stuhl.glb",
  "typ": "model",
  "ownerId": "user_xyz",
  "tags": ["möbel", "holz"],
  "metadata": { "polycount": 4200, "hasTextures": true }
}
```

Vorteil: Verschachtelung und Listen sind natürlich. `tags` ist einfach ein Array. In einer Tabelle bräuchtest du dafür eine dritte Tabelle.

Nachteil: **Es gibt keinen JOIN.** Willst du den Besitzernamen, musst du zwei Anfragen stellen:

```javascript
const asset = await ctx.db.get(assetId);        // erst das Asset
const owner = await ctx.db.get(asset.ownerId);  // dann den Besitzer
```

Bei einer Liste mit 50 Assets werden daraus 51 Anfragen. Das nennt man **N+1-Problem** und ist der klassische Performance-Killer in Dokument-Datenbanken.

**Bekannte Vertreter:** MongoDB, Firebase Firestore, **Convex**.

### Was ist ein „Schema"?

Der Bauplan deiner Daten: Welche Tabellen/Sammlungen gibt es, welche Felder haben sie, welchen Typ hat jedes Feld, was ist Pflicht.

In Convex sieht das so aus:

```typescript
// convex/schema.ts
export default defineSchema({
  assets: defineTable({
    title: v.string(),
    typ: v.union(v.literal("model"), v.literal("audio")),
    ownerId: v.id("users"),
    tags: v.array(v.string()),
  }).index("by_owner", ["ownerId"]),
});
```

In Drizzle (für Postgres) so:

```typescript
// schema.ts
export const assets = pgTable("assets", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  typ: text("typ", { enum: ["model", "audio"] }).notNull(),
  ownerId: integer("owner_id").references(() => users.id),
});
```

Sieht ähnlich aus. Der Unterschied kommt in Teil 4.

### Postgres kann beides

Wichtig, weil oft missverstanden: Postgres hat einen Spaltentyp `jsonb`. Du kannst in derselben Tabelle feste Spalten *und* ein flexibles JSON-Feld haben. Die Wahl ist also nicht „entweder Struktur oder Flexibilität".

---

<a name="teil-3"></a>
## Teil 3 — Typsicherheit

### Was ist ein Typ?

In JavaScript kannst du das hier schreiben:

```javascript
let x = 5;
x = "hallo";
x = { foo: true };
```

Alles erlaubt. JavaScript ist **dynamisch typisiert** — es interessiert sich nicht dafür, was in einer Variablen steckt, bis es zu spät ist.

TypeScript fügt Typen hinzu:

```typescript
let x: number = 5;
x = "hallo";  // ✗ Fehler, schon beim Schreiben
```

Ein **Typ** ist eine Aussage darüber, welche Form ein Wert hat. `number`, `string`, oder komplexer:

```typescript
type Asset = {
  title: string;
  typ: "model" | "audio";
  tags: string[];
};
```

### Was macht der Compiler?

TypeScript-Code läuft nicht direkt. Er wird vorher in JavaScript übersetzt — das macht der **Compiler**. Und bei dieser Übersetzung prüft er alle Typen.

**Das ist der zentrale Punkt für alles Weitere:** Der Compiler findet Fehler, *bevor* dein Programm läuft. Kein Nutzer, kein Absturz, keine kaputten Daten. Nur eine rote Wellenlinie im Editor.

```typescript
const asset: Asset = { title: "Stuhl", typ: "modell", tags: [] };
//                                            ^^^^^^^
// Fehler: "modell" ist nicht zuweisbar zu "model" | "audio"
```

Tippfehler, gefunden in einer Millisekunde.

### Was heißt „end-to-end typsicher"?

Deine Daten machen eine Reise:

```
Datenbank  →  Backend-Funktion  →  Netzwerk  →  React-Komponente
```

An jedem Übergang könnte die Information über die Form der Daten verlorengehen. Klassisch passiert genau das:

```typescript
// Ohne Typsicherheit
const res = await fetch("/api/assets");
const data = await res.json();   // Typ: any — TypeScript weiß nichts mehr
data.titel;                       // Tippfehler (titel statt title): kein Fehler!
```

`any` heißt „könnte alles sein" — TypeScript gibt auf und lässt alles durch. Der Fehler taucht später als `undefined` in der Oberfläche auf.

**End-to-end typsicher** bedeutet: Die Typinformation überlebt die gesamte Reise. Du definierst die Form *einmal* im Schema, und React kennt sie automatisch.

```typescript
// Convex
const assets = useQuery(api.assets.list);
assets[0].titel;  // ✗ Fehler. Der Typ kommt aus schema.ts.
```

### Warum das mit KI zu tun hat

Das ist der Punkt, um den sich unsere ganze Diskussion drehte.

Wenn Claude Code Backend-Code für dich schreibt, braucht es **Rückmeldung**, ob der Code richtig ist. Ein Mensch würde die App starten und klicken. Ein Agent kann das nur eingeschränkt.

Aber: **Der Agent kann den Compiler laufen lassen.** Und der Compiler antwortet in Sekunden, präzise, mit Zeilennummer.

```
Agent schreibt Code
   → Compiler meckert
   → Agent liest den Fehler
   → Agent korrigiert
   → Compiler ist zufrieden
```

Diese Schleife läuft ohne dich. Je mehr Fehler der Compiler abfängt, desto mehr kann der Agent allein reparieren. Wo Typen fehlen, produziert er Code, der *aussieht* als würde er funktionieren, und der erst beim Nutzer scheitert.

> **Das war gemeint mit „Typsicherheit als Feedback-Schleife".**

### Der Haken — und das ist die Stelle, die du nicht verstanden hast

Ein Typ ist eine **Behauptung über Daten**, keine Messung.

Wenn in deiner `schema.ts` steht, dass `assets` ein Feld `license` hat, dann *glaubt* TypeScript das. Es schaut nicht in der Datenbank nach.

Angenommen, du (oder der Agent) fügst das Feld hinzu:

```typescript
export const assets = pgTable("assets", {
  title: text("title").notNull(),
  license: text("license").notNull(),   // ← neu hinzugefügt
});
```

Jetzt gilt:

| | Zustand |
|---|---|
| Deine `schema.ts` | kennt `license` ✓ |
| TypeScript | kennt `license` ✓ |
| Der Agent | hält die Aufgabe für erledigt ✓ |
| **Die echte Datenbank** | **kennt `license` nicht** ✗ |

Der Code kompiliert fehlerfrei. Er startet fehlerfrei. Und beim ersten Zugriff wirft Postgres: `column "license" does not exist`.

**Das ist gemeint mit „Typen beschreiben Absicht, nicht Realität."** Die Typsicherheit ist echt und vollständig — aber sie prüft nur, ob dein Code zu deiner *Beschreibung* passt, nicht ob deine Beschreibung zur *Wirklichkeit* passt.

Warum das fehlt: Zwischen `schema.ts` und der echten Datenbank steht ein Schritt, den jemand ausführen muss. Der heißt Migration — nächstes Kapitel.

---

<a name="teil-4"></a>
## Teil 4 — Migrationen

### Das Problem

Deine App läuft. In der Datenbank stehen 5.000 Assets. Jetzt willst du ein Feld hinzufügen.

Du kannst die Tabelle nicht einfach neu bauen — die Daten würden verschwinden. Du brauchst eine **Änderung am lebenden Objekt**:

```sql
ALTER TABLE assets ADD COLUMN license TEXT;
```

Diese Anweisung heißt **Migration**. Ein Skript, das die Datenbank von Zustand A nach Zustand B bringt, ohne die Daten zu verlieren.

### Wie es bei Drizzle/Postgres läuft

Drei Schritte, alle manuell:

```bash
# 1. Du änderst schema.ts von Hand
# 2. Drizzle vergleicht Schema mit DB und schreibt die SQL-Datei
npx drizzle-kit generate
# → erzeugt: drizzle/0003_add_license.sql
# 3. Du wendest sie an
npx drizzle-kit migrate
```

Zwischen Schritt 1 und 3 ist dein Code **inkonsistent mit der Datenbank**. Genau das Loch aus Teil 3.

### Warum das mit einem KI-Agenten heikel ist

Drei konkrete Gefahren:

**a) Umbenennungen kann Drizzle nicht erraten.** Änderst du `titel` zu `title`, sieht Drizzle nur: eine Spalte weg, eine neu. Es **fragt dich interaktiv**: „Umbenennung oder Löschen+Neuanlegen?" Ein Agent kann auf eine interaktive Frage nicht sinnvoll antworten. Wählt er falsch, enthält die Migration `DROP COLUMN` — und alle Titel sind weg.

**b) Kein Sicherheitsnetz.** `migrate` gegen die Produktionsdatenbank ist sofort und endgültig. Kein „bist du sicher?".

**c) Der Agent sieht den DB-Zustand nicht.** Er kann die Migrationsdateien im Repo lesen, aber nicht wissen, welche davon auf welchem Server schon gelaufen sind.

> **Regel, die du dir merken solltest:** Migrationen darf ein Agent *generieren*, aber nie *anwenden*. Du liest die `.sql`-Datei, dann führst du sie aus. Immer mit Backup davor.

### Wie es bei Convex läuft

```bash
npx convex deploy
```

Ein Befehl. Convex vergleicht das Schema im Code mit dem deployten Zustand, ändert es an, und **prüft dabei alle vorhandenen Dokumente gegen das neue Schema**. Passen sie nicht, wird der Deploy abgelehnt statt halb ausgeführt.

Der Zustand „Code sagt A, Datenbank sagt B" kann nicht entstehen, weil Code und Schema in derselben Operation deployt werden.

**Der Preis:** Du siehst nicht, was intern passiert. Bei Drizzle liegt eine SQL-Datei vor dir, die du prüfen kannst. Bei Convex vertraust du.

---

<a name="teil-5"></a>
## Teil 5 — Transaktionen

### Das Problem

Ein Asset löschen bedeutet oft mehrere Schritte:

```
1. Asset-Datensatz löschen
2. Zähler beim Besitzer um 1 verringern
3. Verweise in Sammlungen entfernen
```

Was, wenn zwischen Schritt 1 und 2 der Server abstürzt? Dann ist das Asset weg, aber der Zähler sagt weiterhin „12 Assets". Deine Daten sind kaputt — und niemand merkt es sofort.

### Die Lösung

Eine **Transaktion** klammert mehrere Schritte zu einer Einheit: **Entweder alle oder keiner.** Geht irgendwo etwas schief, wird alles zurückgerollt, als wäre nie etwas passiert.

Das ist das „A" in **ACID**:

- **A**tomicity — alles oder nichts
- **C**onsistency — Regeln bleiben eingehalten
- **I**solation — parallele Vorgänge stören sich nicht
- **D**urability — was bestätigt ist, überlebt einen Stromausfall

### Bei Drizzle: freiwillig

```typescript
await db.transaction(async (tx) => {
  await tx.delete(assets).where(...);
  await tx.update(users).set(...);   // tx, nicht db!
});
```

Und hier der Fehler, der KI-Code besonders oft trifft:

```typescript
await db.transaction(async (tx) => {
  await tx.delete(assets).where(...);
  await db.update(users).set(...);   // ✗ db statt tx
});
```

**Das kompiliert.** Es läuft. Es sieht richtig aus. Aber das Update steht außerhalb der Transaktion und wird bei einem Rollback nicht rückgängig gemacht. Ein Buchstabe Unterschied, kein Compiler-Fehler, stille Datenkorruption.

### Bei Convex: automatisch

```typescript
export const deleteAsset = mutation({
  handler: async (ctx, args) => {
    await ctx.db.delete(args.id);
    await ctx.db.patch(userId, { count: c - 1 });
    // beides automatisch in einer Transaktion
  },
});
```

Es gibt keine Möglichkeit, das zu vergessen, weil es kein Opt-out gibt. **Das meinte ich mit „strukturelle Garantie": Der Agent kann diesen Fehler nicht machen, weil die API ihn nicht zulässt.**

Dasselbe Prinzip bei Lesen/Schreiben: Eine Convex-`query` hat schlicht keine Schreibfunktionen. Ein Hono-Endpunkt kann immer alles.

---

<a name="teil-6"></a>
## Teil 6 — Realtime

Das schwierigste Kapitel. Nimm dir Zeit.

### Das Grundproblem

HTTP funktioniert nach dem Frage-Antwort-Prinzip: Der Browser fragt, der Server antwortet, die Verbindung ist zu Ende. **Der Server kann von sich aus nichts schicken.**

Wenn also jemand anders ein Asset hochlädt, erfährt dein Browser nichts davon. Deine Liste ist veraltet, und du merkst es erst beim Neuladen.

### Die Treppe — vier Stufen

#### Stufe 1: Polling

Alle 5 Sekunden neu fragen.

```javascript
setInterval(() => refetch(), 5000);
```

Funktioniert, ist simpel, ist verschwenderisch: 99 % der Anfragen liefern „nichts Neues". Und Änderungen kommen bis zu 5 Sekunden zu spät.

#### Stufe 2: Eine offene Leitung

Statt immer neu zu fragen, hält man **eine Verbindung dauerhaft offen**, durch die der Server jederzeit etwas schicken kann.

- **SSE** (Server-Sent Events) — einseitig, nur Server→Browser. Einfach, reicht meistens.
- **WebSocket** — beidseitig. Mächtiger, aufwändiger.

> Wichtig für dein VPS-Setup: Beides braucht einen **dauerhaft laufenden Serverprozess**. Auf Serverless-Plattformen (Vercel Functions) funktioniert es nicht, weil dort jede Anfrage einen Prozess startet und wieder beendet.

Jetzt kann der Server melden: „Es hat sich was getan." Aber woher weiß er das?

#### Stufe 3: Der Server erfährt von Änderungen

Drei Wege, wie dein Backend mitbekommt, dass sich Daten geändert haben:

**a) Du sagst es ihm selbst.** Nach jeder Mutation ruft dein Code auf: „sende an alle: `assets` hat sich geändert". Einfach, funktioniert, du musst nur daran denken. Vergisst du es an einer Stelle, ist die Oberfläche dort still veraltet.

**b) `LISTEN`/`NOTIFY`.** Postgres hat ein eingebautes Benachrichtigungssystem. Ein Trigger auf der Tabelle feuert automatisch. Vorteil: Du kannst es nicht vergessen. Nachteile: max. ~8 KB pro Nachricht, und **nicht dauerhaft** — was während einer Verbindungsunterbrechung passiert, ist verloren.

**c) Logical Replication (WAL).** Postgres schreibt jede Änderung zuerst in ein Protokoll (Write-Ahead Log), bevor sie ausgeführt wird. Dieses Protokoll kann man mitlesen. Lückenlos, geordnet, dauerhaft. Das nutzen Supabase Realtime, ElectricSQL und Zero.

> ⚠️ **Betriebs-Falle bei (c):** Stirbt der Mitleser, sammelt Postgres die WAL-Dateien weiter an, weil es annimmt, sie würden noch gebraucht. Die Festplatte läuft voll, und Postgres bleibt stehen. Auf einem eigenen VPS ein realer Ausfallgrund.

#### Stufe 4: Von Events zu Ergebnissen

**Hier liegt der Unterschied, der die ganze Diskussion trägt.**

Die Stufen 1–3 geben dir alle dasselbe: **Zeilen-Events.**

```javascript
{ action: "create", record: { id: 998, title: "Neu.glb", typ: "model" } }
```

Das ist die Information „Datensatz 998 wurde angelegt". Und jetzt musst *du* beantworten:

- Zeigt die aktuelle Ansicht überhaupt Assets vom Typ `model`? Wenn nein: ignorieren.
- Gehört er dem eingeloggten Nutzer? Wenn nein: ignorieren.
- Die Liste ist nach Datum sortiert — an welche Position gehört er?
- Auf Seite 3 einer Paginierung: verschiebt sich jetzt alles?
- Es kommen 50 Events in 100 ms — 50 mal neu rendern?
- Meine Anzeige zeigt „Anzahl Assets: 12". Wo kommt die neue Zahl her? Das Event sagt nichts über Aggregate.

Jede dieser Fragen ist Code, den jemand schreiben muss. Für jede Liste in deiner App aufs Neue.

**Eine reaktive Sync-Engine** (das, was Convex hat) beantwortet sie für dich. Du bekommst keine Events, sondern **das aktualisierte Ergebnis deiner Abfrage**:

```typescript
const assets = useQuery(api.assets.list, { typ: "model" });
```

Das war's. Kein `useEffect`, kein Loading-State, kein Cache-Invalidieren, kein Merge-Code. Ändert jemand irgendwo etwas, das dieses Ergebnis beeinflusst, ändert sich die Variable `assets`, und React rendert neu.

Wie es das kann: Convex protokolliert bei jeder Query mit, **welche Daten sie gelesen hat**. Kommt ein Write, weiß es exakt, welche Queries betroffen sind, rechnet nur die neu und schickt die neuen Ergebnisse. Das nennt man Dependency-Tracking.

### Die Übersicht

| | Was du bekommst | Was du selbst bauen musst |
|---|---|---|
| **Convex** | Query-Ergebnisse | nichts |
| **PocketBase** | Zeilen-Events (SSE) | Filterung, Sortierung, Merge, Aggregate |
| **Supabase Realtime** | Zeilen-Events | dasselbe |
| **Postgres + Hono** | gar nichts | alles, inkl. Transportweg |
| **Zero / PowerSync** | Query-Ergebnisse | zusätzlicher Dienst zu betreiben |

> **Das war der Kernsatz der letzten Antwort:** „Alle geben dir Zeilen-Events. Convex gibt dir Query-Ergebnisse. Zwischen beidem liegt die Arbeit einer Sync-Engine."

Und der Grund, warum das für dich mit KI relevant ist: Diese Merge-Logik ist genau die Sorte Code, die **kein Compiler prüfen kann**. Ein Agent schreibt sie plausibel und falsch, und du merkst es erst, wenn die Oberfläche flackert oder falsche Zahlen zeigt.

---

<a name="teil-7"></a>
## Teil 7 — Die drei Optionen

### Convex

Ein Paket aus Datenbank, Backend-Funktionen, Sync-Engine, Scheduler, Suche und Datei-Storage. Alles in TypeScript, alles im Repo.

**Stark:** Reaktivität geschenkt. Transaktionen unumgehbar. Schema und Code immer synchron. Für Agenten-Arbeit strukturell am sichersten.

**Schwach:** Keine JOINs, keine Ad-hoc-Auswertungen. Junge Technologie — weniger im Training von KI-Modellen, also mehr Halluzinationen bei spezifischen APIs. Ein Wechsel weg bedeutet Neuschreiben, nicht Umziehen.

### PostgreSQL + Hono + Drizzle

Selbst zusammengesetzt: Postgres als Datenbank, Drizzle als typsichere Zugriffsschicht, Hono als Webserver für deine Endpunkte.

**Stark:** Echtes SQL mit JOINs und Aggregaten. Riesiges Ökosystem — KI-Modelle schreiben Postgres nahezu fehlerfrei. Der Agent kann die Datenbank direkt inspizieren und seine Arbeit überprüfen. Volltextsuche und Vektorsuche (pgvector) sind eingebaut. Läuft überall.

**Schwach:** Realtime musst du bauen. Transaktionen sind vergessbar. Migrationen sind ein manueller, gefährlicher Schritt. Für jedes Teilproblem gibt es fünf Bibliotheken und keine kanonische Wahl.

**Und um deine ursprüngliche Frage zu beantworten:** Ja, das ist mit Hono RPC oder tRPC vollständig end-to-end typsicher. Der Unterschied ist nicht *weniger* Typsicherheit, sondern dass die Typen nicht garantiert zur echten Datenbank passen (Teil 3) und dass sie bestimmte Fehlerklassen nicht abdecken (Teil 5).

### PocketBase

Eine einzige ausführbare Datei. SQLite darin, dazu Auth, Datei-Storage, Realtime und ein Admin-Interface.

**Stark:** In 15 Minuten produktiv. Backup = Ordner kopieren. Leistung reicht viel weiter als man denkt (Benchmarks des Autors: 10.000+ gleichzeitige Verbindungen auf einem 4-GB-VPS, ~50.000 Schreibvorgänge pro Minute).

**Schwach:** Realtime nur als Zeilen-Events. Keine Vektorsuche. Server-Logik in Go oder in einer eingebetteten JS-Engine ohne npm. Typen kommen aus einem separaten Generator und können veralten. Und: Das Schema wird üblicherweise im Admin-UI geklickt — **damit ist es für Claude Code unsichtbar**, was dem ganzen KI-Argument widerspricht.

**Grenze:** Nicht die Nutzerzahl, sondern das Schreibprofil. SQLite erlaubt beliebig viele gleichzeitige Leser, aber nur **einen Schreiber** — Schreibvorgänge stellen sich in eine Warteschlange. Lese-lastige Apps: unproblematisch. Dauerhafte Schreiblast (Multiplayer-Positionen, Event-Logging im Sekundentakt): falsches Werkzeug.

### Entscheidungshilfe

```
Brauchst du echtes SQL (JOINs, Auswertungen, Reports)?
├─ JA  → Postgres + Hono + Drizzle
└─ NEIN
   │
   Brauchst du live aktualisierende Listen ohne Eigenbau?
   ├─ JA  → Convex
   └─ NEIN
      │
      Soll ein KI-Agent das Backend selbstständig umbauen?
      ├─ JA  → Convex (Schema als Code)
      └─ NEIN → PocketBase
```

---

<a name="teil-8"></a>
## Teil 8 — Glossar

| Begriff | Bedeutung |
|---|---|
| **ACID** | Vier Garantien für zuverlässige Datenbanken (siehe Teil 5) |
| **Aggregat** | Ein berechneter Wert über viele Zeilen: Summe, Anzahl, Durchschnitt |
| **Backend** | Programm auf dem Server, das Anfragen bearbeitet |
| **Compiler** | Übersetzt TypeScript nach JavaScript und prüft dabei die Typen |
| **CRUD** | Create, Read, Update, Delete — die vier Grundoperationen |
| **Deploy** | Code auf den Server bringen und dort aktivieren |
| **Drizzle** | TypeScript-Bibliothek für typsicheren SQL-Zugriff |
| **End-to-end typsicher** | Typinformation überlebt von der DB bis in die React-Komponente |
| **FTS** | Full Text Search — Volltextsuche |
| **Hono** | Schlankes Web-Framework zum Bau von HTTP-Endpunkten |
| **Index** | Zusätzliches Verzeichnis für schnelles Suchen (siehe Teil 1) |
| **JOIN** | SQL-Operation, die zwei Tabellen verbindet |
| **jsonb** | Postgres-Spaltentyp für JSON-Daten |
| **LISTEN/NOTIFY** | Postgres-eigenes Benachrichtigungssystem |
| **Migration** | Skript, das ein Datenbankschema ändert, ohne Daten zu verlieren |
| **Mutation** | Schreibende Operation |
| **N+1-Problem** | 1 Anfrage für die Liste + je 1 pro Element = zu viele Anfragen |
| **ORM** | Bibliothek, die Datenbankzeilen auf Objekte im Code abbildet |
| **pgvector** | Postgres-Erweiterung für Vektor-/Ähnlichkeitssuche |
| **Polling** | Regelmäßiges Nachfragen statt Benachrichtigung |
| **Query** | Lesende Abfrage |
| **Reaktive Sync-Engine** | System, das Query-*Ergebnisse* automatisch aktuell hält |
| **Schema** | Bauplan der Daten |
| **Serverless** | Code läuft nur während einer Anfrage; kein Dauerprozess |
| **SSE** | Server-Sent Events — offene Einbahn-Leitung Server→Browser |
| **SQL** | Abfragesprache relationaler Datenbanken |
| **SQLite** | Datenbank, die als einzelne Datei lebt, ohne eigenen Server |
| **Transaktion** | Mehrere Schritte als Einheit — alles oder nichts |
| **Vektorsuche** | Suche nach Bedeutungsähnlichkeit statt exakten Wörtern |
| **WAL** | Write-Ahead Log — Änderungsprotokoll der Datenbank |
| **WebSocket** | Dauerhaft offene Zweiwege-Verbindung |

---

## Nächste Schritte

Wenn du das hier verstanden hast, kannst du die eigentliche Entscheidung selbst treffen. Ein Vorschlag, um es nicht nur theoretisch zu wissen:

1. Bau dieselbe winzige App zweimal — eine Liste, die man ergänzen kann. Einmal mit Convex, einmal mit Postgres + Drizzle + Hono.
2. Öffne beide in zwei Browser-Tabs. Füge in Tab 1 etwas hinzu.
3. Beobachte, was in Tab 2 passiert — und was du tun musstest, damit es passiert.

Dieser eine Nachmittag erklärt Teil 6 besser als jeder Text.
