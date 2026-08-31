# Datenbanken und Backend-Plattformen für moderne Web-Anwendungen — Ein Lerndokument von Null bis zum fundierten Verständnis

*Stand: August 2026. Alle Preise und Limits können sich ändern — prüfe immer die offizielle Preisseite des jeweiligen Anbieters, bevor du dich festlegst.*

## Inhaltsverzeichnis

1. Grundlagen
2. SQL vs. TypeScript-native Backends
3. Convex im Detail
4. Die Alternativen im Vergleich
5. Object Storage und Asset-Auslieferung
6. Spezifisch für Three.js / 3D + Audio
7. Entscheidungshilfe und Lernpfad
8. Tooling-Kontext
9. Glossar

-----

## TEIL 1 — GRUNDLAGEN

### Was ist eine Datenbank?

Eine **Datenbank** ist ein System, das Daten strukturiert speichert, sodass man sie zuverlässig schreiben, lesen, ändern und durchsuchen kann. Statt Daten in einzelnen Dateien zu verwalten, kümmert sich die Datenbank um Konsistenz (die Daten widersprechen sich nicht), Nebenläufigkeit (mehrere Nutzer gleichzeitig) und Dauerhaftigkeit (nichts geht bei einem Absturz verloren).

**Datenbank-Typen:**

- **Relationale Datenbank** (z.B. PostgreSQL, MySQL): Daten liegen in Tabellen mit Zeilen und Spalten, wie in einer Tabellenkalkulation. Tabellen können über Schlüssel miteinander verknüpft werden (z.B. Tabelle „Nutzer” und Tabelle „Bestellungen”). Man fragt sie mit **SQL** ab. Stärke: komplexe Abfragen, Konsistenz, Verknüpfungen (Joins).
- **Dokument-Datenbank** (z.B. MongoDB, Firestore): Daten liegen als flexible Dokumente (im Grunde JSON-Objekte). Kein festes Tabellenschema nötig. Stärke: flexible, verschachtelte Daten, schnelle Entwicklung.
- **Key-Value-Datenbank** (z.B. Redis): Speichert einfach Schlüssel→Wert-Paare, extrem schnell. Stärke: Caching, Sessions, Zähler.
- **Vektor-Datenbank** (z.B. Pinecone, pgvector): Speichert „Embeddings” (numerische Vektoren, die die Bedeutung von Text/Bildern repräsentieren) und findet ähnliche Einträge. Stärke: KI-Anwendungen, semantische Suche.

### ACID, Transaktionen, Isolation Levels

Eine **Transaktion** ist eine Gruppe von Datenbankoperationen, die als eine Einheit ausgeführt werden — entweder alle oder keine. Beispiel: Geld von Konto A abbuchen UND auf Konto B gutschreiben. Beides muss zusammen passieren.

**ACID** ist das Qualitätsversprechen einer Transaktion:

- **A**tomicity (Atomarität): Alles oder nichts.
- **C**onsistency (Konsistenz): Die Datenbank bleibt in einem gültigen Zustand.
- **I**solation (Isolation): Gleichzeitige Transaktionen stören sich nicht.
- **D**urability (Dauerhaftigkeit): Nach Bestätigung ist die Änderung dauerhaft, auch bei Stromausfall.

**Isolation Levels** legen fest, wie stark parallele Transaktionen voneinander abgeschirmt sind. Von schwach nach stark: Read Uncommitted → Read Committed → Repeatable Read → **Serializable**. „Serializable” ist die stärkste Stufe: Das Ergebnis ist so, als wären alle Transaktionen nacheinander (seriell) ausgeführt worden — die höchste Garantie gegen subtile Nebenläufigkeitsfehler, aber potenziell langsamer.

**Optimistic Concurrency Control (OCC)** ist eine Technik, um Serializability effizient umzusetzen: Statt Daten zu sperren (pessimistisch), lässt man Transaktionen einfach laufen und prüft am Ende, ob sich etwas überschnitten hat. Falls ja, wird eine Transaktion zurückgerollt und automatisch wiederholt. Das ist effizient, wenn Konflikte selten sind. Convex nutzt genau diesen Ansatz.

### Indizes — und warum sie wichtig sind

Ein **Index** ist eine zusätzliche Datenstruktur, die das Suchen beschleunigt — wie das Stichwortverzeichnis am Ende eines Buchs. Ohne Index muss die Datenbank jede Zeile durchgehen („Full Table Scan”); mit Index findet sie den Eintrag direkt.

**Kosten von Indizes:** Sie sind nicht gratis. Jeder Index (a) belegt zusätzlichen Speicher und (b) muss bei jedem Schreibvorgang (Insert/Update) mit aktualisiert werden, was Schreiboperationen verlangsamt. Bei Convex etwa wird jeder Index preislich „wie eine weitere Kopie der Tabelle” behandelt. Faustregel: Indiziere Felder, nach denen du oft suchst oder sortierst — aber nicht wahllos alles.

### Schema und Migrationen

Ein **Schema** ist der Bauplan deiner Daten: welche Tabellen/Sammlungen es gibt, welche Felder sie haben und welchen Typ (Text, Zahl, Datum). Relationale Datenbanken erzwingen ein Schema; Dokument-Datenbanken sind oft „schemalos” oder „schema-flexibel”.

Eine **Migration** ist eine kontrollierte Änderung am Schema — z.B. eine neue Spalte hinzufügen. Migrationen werden als versionierte Schritte gespeichert, damit man dieselbe Änderung reproduzierbar auf Entwicklung, Test und Produktion anwenden kann.

### OLTP vs. OLAP

- **OLTP** (Online Transaction Processing): Das Tagesgeschäft deiner App — viele kleine, schnelle Lese-/Schreibvorgänge (Nutzer legt Produkt in den Warenkorb). Deine Produktionsdatenbank ist dafür optimiert.
- **OLAP** (Online Analytical Processing): Analytische Auswertungen über riesige Datenmengen (z.B. „Umsatz pro Region pro Monat der letzten 3 Jahre”).

**Warum fährt man Analytics nicht gegen die Produktionsdatenbank?** Große Analyse-Abfragen sind ressourcenhungrig und können die schnellen OLTP-Abfragen ausbremsen oder die Datenbank blockieren — deine App würde für echte Nutzer langsam. Deshalb exportiert man Daten in ein separates Analyse-System (Data Warehouse wie BigQuery, Snowflake, ClickHouse).

### Normalisierung / Denormalisierung

- **Normalisierung**: Daten so aufteilen, dass jede Information nur einmal existiert (keine Redundanz). Beispiel: Adresse eines Kunden nur in der Kunden-Tabelle, nicht in jeder Bestellung wiederholt. Vorteil: Konsistenz. Nachteil: Man braucht Joins, um Daten wieder zusammenzuführen.
- **Denormalisierung**: Bewusstes Duplizieren von Daten, um Lesevorgänge zu beschleunigen (weniger Joins). Vorteil: schnelles Lesen. Nachteil: Man muss Duplikate synchron halten. Dokument-Datenbanken tendieren zur Denormalisierung.

### Backend, API, Serverless, BaaS, Edge

- **Backend**: Der Teil deiner Anwendung, der auf einem Server läuft (nicht im Browser) — Datenbank, Geschäftslogik, Authentifizierung.
- **API** (Application Programming Interface): Die definierte Schnittstelle, über die dein Frontend (Browser) mit dem Backend spricht. Meist über HTTP.
- **Serverless**: Du schreibst nur Funktionen; der Cloud-Anbieter kümmert sich um Server, Skalierung und Bereitstellung. Du zahlst nur für tatsächliche Ausführungen. „Serverless” heißt nicht „keine Server”, sondern „keine Server, die DU verwaltest”.
- **Backend-as-a-Service (BaaS)**: Ein fertiges Backend-Paket (Datenbank + Auth + Storage + Funktionen), das du direkt nutzt, statt es selbst zusammenzubauen. Beispiele: Firebase, Supabase, Convex, Appwrite.
- **Edge**: Code, der nicht in einem zentralen Rechenzentrum läuft, sondern an vielen Standorten weltweit nahe am Nutzer — für geringe Latenz (Verzögerung).

### Realtime / reaktive Datenhaltung

Wie erfährt das Frontend, dass sich Daten geändert haben?

- **Polling**: Der Browser fragt in Intervallen „Gibt’s was Neues?” (z.B. alle 5 Sekunden). Einfach, aber ineffizient und verzögert.
- **WebSockets**: Eine dauerhafte, bidirektionale Verbindung zwischen Browser und Server. Der Server kann jederzeit Daten aktiv „pushen”. Ideal für Echtzeit.
- **Server-Sent Events (SSE)**: Eine einseitige Verbindung, über die der Server dem Browser Updates schickt (nur Server→Client). Leichter als WebSockets, aber nur eine Richtung.
- **Sync-Engines**: Eine höhere Abstraktionsebene. Statt selbst Nachrichten zu verwalten, synchronisiert die Engine automatisch Datenzustand zwischen Server und Client. Der Entwickler schreibt eine Abfrage; die Engine hält das Ergebnis live aktuell (z.B. Convex, Zero, ElectricSQL).

### Local-first und CRDTs

**Local-first** ist eine Architektur, bei der die App zuerst mit einer lokalen Kopie der Daten auf dem Gerät arbeitet (sofortige Reaktion, funktioniert offline) und im Hintergrund mit dem Server synchronisiert. Der Client ist quasi die primäre Datenquelle, die Cloud dient Backup und Kollaboration.

**CRDTs** (Conflict-free Replicated Data Types) sind spezielle Datenstrukturen, die automatisch Konflikte auflösen, wenn mehrere Nutzer dieselben Daten gleichzeitig offline ändern. Beim Wiederverbinden „verschmelzen” die Änderungen deterministisch ohne zentrale Instanz. Bekannteste Bibliotheken: **Yjs** und **Automerge**. Einsatz vor allem bei kollaborativer Textbearbeitung (Google-Docs-Stil).

-----

## TEIL 2 — SQL vs. TypeScript-native Backends

### Was ist SQL?

**SQL** (Structured Query Language) ist die Standardsprache, um mit relationalen Datenbanken zu sprechen. Ein paar Grundbausteine:

```sql
-- Alle Spalten aus einer Tabelle lesen
SELECT * FROM assets;

-- Bestimmte Spalten mit Bedingung
SELECT name, file_size FROM assets WHERE type = 'audio';

-- JOIN: zwei Tabellen verknüpfen
SELECT assets.name, users.email
FROM assets
JOIN users ON assets.owner_id = users.id;

-- GROUP BY + Aggregation: zählen, summieren, mitteln
SELECT type, COUNT(*) AS anzahl, AVG(file_size) AS schnitt
FROM assets
GROUP BY type;
```

- **SELECT** wählt Daten aus.
- **JOIN** verknüpft Tabellen anhand gemeinsamer Schlüssel.
- **GROUP BY** fasst Zeilen zu Gruppen zusammen.
- **Aggregationen** (COUNT, SUM, AVG, MIN, MAX) berechnen Werte über Gruppen.

Stärke von SQL: Man kann **Ad-hoc-Queries** stellen — beliebige neue Fragen an die Daten, ohne vorher Code zu schreiben.

### Was ist ein ORM?

Ein **ORM** (Object-Relational Mapper) ist eine Bibliothek, die SQL-Tabellen als Objekte in deiner Programmiersprache abbildet. Statt SQL-Strings schreibst du typsicheren Code. Es löst das Problem, dass rohe SQL-Strings fehleranfällig sind (Tippfehler, keine Autovervollständigung, SQL-Injection-Risiken).

- **==Prisma==**: Populäres ORM mit eigener Schema-Sprache und generiertem Typ-sicheren Client. Sehr ausgereift, große Community.
- **==Drizzle==**: Leichtgewichtiges, „SQL-nahes” ORM komplett in TypeScript. Schema wird in TypeScript definiert, sehr gute Typsicherheit, näher an SQL als Prisma.

```typescript
// Drizzle-Beispiel
const audioAssets = await db
  .select()
  .from(assets)
  .where(eq(assets.type, 'audio'));
```

### TypeScript-native Ansätze (z.B. Convex)

Ein **TypeScript-natives Backend** wie **Convex** dreht das Modell um: Es gibt keine separate SQL-Datenbank, mit der du über ein ORM sprichst. Stattdessen schreibst du dein Schema, deine Abfragen und deine Geschäftslogik komplett in TypeScript, und die Plattform ist die Datenbank + der Funktions-Runtime + die Sync-Engine in einem.

Kennzeichen:

- **==End-to-end Typsicherheit**: Die Typen fließen vom Datenbank-Schema über die Backend-Funktionen bis in den Frontend-Code — ohne manuelle Synchronisation.== Ändert sich das Schema, meckert der Compiler an allen betroffenen Stellen.
- **Keine Joins**: Man modelliert Beziehungen über Referenzen und lädt verknüpfte Daten explizit in Code nach.
- **Keine Ad-hoc-Queries**: Jede Abfrage ist eine vordefinierte Funktion im Code. Man kann nicht spontan eine beliebige neue SQL-Abfrage über ein Dashboard laufen lassen.

### Ehrliche Gegenüberstellung

| Kriterium                            | SQL + ORM (z.B. Postgres + Drizzle)         | TypeScript-native (z.B. Convex)    |
| ------------------------------------ | ------------------------------------------- | ---------------------------------- |
| Ad-hoc-Abfragen                      | Ja, volle SQL-Flexibilität                  | Nein, nur vordefinierte Funktionen |
| Komplexe Joins/Analytics             | Stärke                                      | Schwäche (kein SQL, keine Joins)   |
| Typsicherheit end-to-end             | Gut (mit Drizzle/Prisma), aber Bruchstellen | Sehr stark, durchgängig            |
| ==Realtime eingebaut==               | Nein (extra Aufwand)                        | Ja, im Kern                        |
| Einrichtungsaufwand                  | Höher (DB + API-Layer + Auth zusammenbauen) | Niedrig (alles integriert)         |
| Portierbarkeit / kein Lock-in        | Hoch (Postgres ist Standard)                | Geringer (proprietäres Modell)     |
| Reifegrad / Ökosystem                | Sehr hoch (Jahrzehnte)                      | Jünger, wächst schnell             |
| Analytics / Data-Warehouse-Anbindung | Direkt                                      | Nur über Export                    |

### Welcher Ansatz ist „KI-freundlicher”?

Das ist für dich relevant, weil du mit **Claude Code** (KI-Coding-Agent) entwickelst. Zwei Faktoren machen einen Ansatz KI-freundlich:

1. **Backend-State im Repository vs. verstreut.** Bei einem SQL-BaaS wie Supabase liegt der „Wahrheitszustand” deines Backends oft an mehreren Orten: SQL-Migrationsdateien, Row-Level-Security-Policies (RLS — Zugriffsregeln, die in der Datenbank definiert werden), Dashboard-Einstellungen, Storage-Regeln. Ein KI-Agent sieht nur den Code im Repository — was im Dashboard oder in RLS-Policies steckt, ist für ihn unsichtbar. Bei einem TypeScript-nativen Ansatz wie Convex liegt praktisch der gesamte Backend-Zustand (Schema, Funktionen, Zugriffslogik) als Code im Repo — der Agent sieht alles und kann alles ändern.
2. **==Typsicherheit als Feedback-Schleife==.** Wenn Typen durchgängig fließen, erzeugt eine falsche Änderung sofort einen Compiler-Fehler. Der KI-Agent bekommt dieses Feedback und korrigiert sich selbst, bevor Code überhaupt läuft. Convex bewirbt zudem, dass Queries schreibgeschützt und Mutations transaktional sind — das macht es schwerer, dass KI-generierter Code Daten korrumpiert oder inkonsistente Zustände hinterlässt.

**Fazit Teil 2:** Für ein KI-gestütztes, realtime-lastiges Projekt mit überschaubarer Analytik ist ein TypeScript-natives Backend wie Convex sehr attraktiv. Braucht man dagegen komplexe relationale Abfragen, Ad-hoc-Analytics oder ==maximale Portierbarkeit==, ist Postgres + ORM die solidere Wahl. Beides ist legitim — es hängt vom Anwendungsfall ab.

-----

## TEIL 3 — CONVEX IM DETAIL

### Grundidee

**Convex** ist eine reaktive Backend-Plattform, die sechs normalerweise getrennte Dienste bündelt: eine Dokument-Datenbank mit ACID-Transaktionen und indizierten Abfragen, Server-Funktionen in TypeScript, eine reaktive Sync-Engine, einen Scheduler/Cron, Volltextsuche/Vektorsuche und Datei-Storage. Convex wurde Ende 2020 von den Ex-Dropbox-Ingenieuren **Jamie Turner** (CEO), **James Cowling** (CTO) und **Sujay Jayakar** (Chief Scientist) gegründet.

Das Datenmodell nennt Convex **„document-relational”**: Man speichert flexible Dokumente (wie in einer Dokument-DB), kann sie aber über Referenzen und Indizes relational verknüpfen und hat ACID-Transaktionen wie in einer relationalen DB.

### Die drei Funktionstypen

Convex erzwingt eine strikte Trennung von drei Funktionsarten — das ist das Herzstück der Architektur:

- **Queries** (Abfragen): **Nur-Lesen.** Sie lesen Daten aus der Datenbank und sind **reaktiv** — die Sync-Engine hält ihr Ergebnis im Frontend automatisch aktuell. Sie dürfen keine externen APIs aufrufen und nichts schreiben. Weil sie deterministisch und rein sind, kann Convex ihre Ergebnisse cachen und Abhängigkeiten verfolgen.
- **Mutations** (Änderungen): **Schreiben** in die Datenbank, laufen als **Transaktion** (ACID). Bei einem Fehler wird alles zurückgerollt. Auch sie dürfen keine externen APIs direkt aufrufen.
- **Actions**: Der **Fluchtweg** zur Außenwelt. Sie dürfen externe APIs aufrufen (z.B. Stripe, OpenAI), sind aber **nicht** Teil der Sync-Engine und geben keine Transaktionsgarantien. Um die Datenbank anzufassen, müssen sie über Queries/Mutations gehen.

**Warum diese Trennung?** Sie erlaubt Convex, für Queries/Mutations strenge Garantien (Determinismus, Transaktionen, Reaktivität) durchzusetzen, während die „unsaubere” Außenwelt in Actions isoliert bleibt. Ein KI-Agent kann dadurch schwer etwas kaputt machen: Eine Query kann per Definition keine Daten überschreiben.

```typescript
// convex/assets.ts
import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

// Query: nur lesen, reaktiv
export const listByType = query({
  args: { type: v.string() },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("assets")
      .withIndex("by_type", (q) => q.eq("type", args.type))
      .collect();
  },
});

// Mutation: schreiben, transaktional
export const addAsset = mutation({
  args: { name: v.string(), type: v.string(), storageKey: v.string() },
  handler: async (ctx, args) => {
    return await ctx.db.insert("assets", args);
  },
});
```

### Die reaktive Sync-Engine

Der `ConvexReactClient` baut eine **WebSocket**-Verbindung auf. Im Frontend nutzt man den `useQuery`-Hook:

```typescript
const assets = useQuery(api.assets.listByType, { type: "audio" });
```

Ablauf:

1. Die Engine verfolgt automatisch, welche Dokumente eine Query beim Ausführen liest (Dependency Tracking).
2. Ändert eine Mutation eines dieser Dokumente, markiert die Engine die Query als „dirty” und führt sie neu aus (**Query-Invalidierung**).
3. Nur die geänderten Daten (Deltas) werden über WebSocket an den Client gepusht.
4. Alle betroffenen Queries werden **konsistent zum selben Zeitpunkt** aktualisiert — man sieht nie einen Zwischenzustand, in dem zwei Zahlen nicht zusammenpassen.

Es gibt auch **Optimistic Updates**: temporäre lokale Änderungen, die die UI sofort aktualisieren, bevor die Mutation server-seitig bestätigt ist.

### Schema-Definition und Indizes

```typescript
// convex/schema.ts
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  assets: defineTable({
    name: v.string(),
    type: v.string(),        // "model" | "audio"
    storageKey: v.string(),  // Verweis auf Object Storage
    fileSize: v.number(),
    tags: v.array(v.string()),
  })
    .index("by_type", ["type"])
    .index("by_type_and_name", ["type", "name"]),
});
```

### Weitere Bausteine

- **Scheduler**: Funktionen zeitversetzt ausführen („in 5 Minuten diese Mutation”). Das Scheduling selbst ist ein Datenbank-Schreibvorgang — wirft die Mutation einen Fehler, wird nichts geplant.
- **Cron Jobs**: Wiederkehrende Aufgaben nach Zeitplan.
- **File Storage**: Dateien speichern und ausliefern (dazu unten mehr — für große 3D/Audio-Assets aber ==besser externen Object Storage== nutzen).
- **Auth**: Entweder **Convex Auth** (eingebaut, im Code) oder **Clerk** (externe, ausgereiftere Auth-Plattform mit fertigen UI-Komponenten). Clerk nimmt mehr Arbeit ab, ==Convex Auth hält alles im Repo.==
- **Volltextsuche**: Textsuche über Felder, ohne externe Suchmaschine.
- **Vector Search**: Ähnlichkeitssuche über Embeddings (für KI-Features), eingebaut.
- **HTTP Actions**: Eigene HTTP-Endpunkte (z.B. für Webhooks von Stripe).

### ==Convex Components==

**Components** sind vorgefertigte, gekapselte Module mit **eigener, isolierter Datenbank** — sie können nicht versehentlich deine Haupttabellen anfassen. Beispiele:

- **Rate Limiter**: Anwendungsseitige Ratenbegrenzung, transaktional, mit „Sharding” (Aufteilen der Zähler auf mehrere Buckets), um bei hohem Andrang OCC-Konflikte zu vermeiden.
- **Aggregate**: Effiziente Summen/Zählungen/Durchschnitte, ohne jedes Mal alle Zeilen zu scannen.
- **Workflow**: Langlaufende, mehrstufige Prozesse robust orchestrieren.
- **Agent**: Bausteine für KI-Agenten (mit Rate-Limiting für Token-Budgets).

### Performance und Limits (Stand August 2026)

Quelle: offizielle Convex-Limits-Dokumentation. Alle Zahlen für US-Regionen; EU-Preise 1,3×.

**Deployment-Klassen (Rechenleistung):**

- Free/Starter: **S16** (Team-Deployment-Limit 40)
- Professional: **S256** (Team-Deployment-Limit 300)
- Business/Enterprise: wählbar (S16/S256/D1024/D2048)

Convex nutzt **V8-Isolates** (leichtgewichtige JavaScript-Ausführungsumgebungen, wie im Chrome-Browser) statt schwergewichtiger Container — dadurch praktisch keine „Cold Starts” (Verzögerung beim ersten Aufruf nach Inaktivität).

**Concurrency-Limits (gleichzeitig laufende Funktionen):**

| Funktionstyp                          | S16 (Free/Starter) | S256 (Professional) |
| ------------------------------------- | ------------------ | ------------------- |
| Queries                               | 16                 | 256                 |
| Mutations                             | 16                 | 256                 |
| Mutation-Schreibdurchsatz             | 4 MiB              | 8 MiB               |
| Convex-Runtime-Actions + HTTP-Actions | 64                 | 512                 |
| Node-Actions                          | 64                 | 256                 |
| Scheduled Jobs                        | 8                  | 256                 |

Gleichzeitige Sessions: S16 = 1.000, S256 = 10.000.

**Transaktionslimits (pro Query/Mutation, planübergreifend gleich):**

- Gelesene Daten: **16 MiB** (auch weggefilterte Daten zählen als gescannt)
- Geschriebene Daten: **16 MiB**
- Gescannte Dokumente: **32.000**
- Geschriebene Dokumente: **16.000**
- Rückgabewert einer Funktion: **16 MiB**
- Funktionsargument-Größe: **16 MiB** (Node-Actions: 5 MiB)
- Ausführungszeit Query/Mutation: **1 Sekunde** (nur Nutzer-Code)
- Ausführungszeit Actions: **10 Minuten** (Node-Runtime), **30 Minuten** (Convex-Runtime)
- Dokumentgröße: **1 MiB**, max. 1024 Felder, max. 8192 Array-Elemente
- Max. 32 Indizes pro Tabelle, 16 Felder pro Index

Es gibt **kein** dokumentiertes „X Aufrufe pro Sekunde”-Limit; der Durchsatz wird über Concurrency-Limits und monatliche Kontingente gesteuert.

### Limitierungen (ehrlich benannt)

- **Kein SQL, keine Joins, keine Ad-hoc-Analytics.** Für komplexe relationale Auswertungen ungeeignet.
- **Vendor Lock-in.** Das Datenmodell und die Funktions-API sind proprietär. Eine Migration zu Postgres wäre eine komplette Neumodellierung. (Self-Hosting mildert das — siehe unten.)
- ==**1-Sekunden-Limit** für Queries/Mutations zwingt zu effizientem Datenzugriff.==

### Analytics-Ausweg

Da Convex kein OLAP kann, exportiert man Daten für Analytik nach außen:

- **Fivetran** und **Airbyte** bieten Streaming-Export von Convex in ein Data Warehouse (BigQuery, Snowflake etc.).
- **Backups** / Snapshot-Export sind eingebaut.

### Preise 2026

Quelle: convex.dev/pricing und offizielle Limits-Doku (verifiziert Mitte 2026). **Preise können sich ändern — prüfe convex.dev/pricing.**

|Plan                   |Preis                                    |Function Calls/Monat          |DB-Speicher                 |File-Storage|
|-----------------------|-----------------------------------------|------------------------------|----------------------------|------------|
|**Free**               |0 $                                      |1 Mio. (harte Grenze)         |0,5 GB                      |1 GB        |
|**Starter**            |0 $ (Nutzungsgebühren bei Überschreitung)|1 Mio. inkl., dann 2,20 $/Mio.|0,5 GB inkl., dann 0,22 $/GB|1 GB inkl.  |
|**Professional**       |25 $/Entwickler/Monat                    |25 Mio. inkl., dann 2 $/Mio.  |50 GB inkl., dann 0,20 $/GB |100 GB inkl.|
|**Business/Enterprise**|ab ca. 2.500 $/Monat Minimum             |individuell                   |individuell                 |individuell |

Weitere Details: DB-I/O bei Free 1 GB/Monat, bei Professional 50 GB/Monat inkl. File-Egress: Free 1 GB/Monat, Professional 50 GB/Monat inkl. (dann 0,12 $/GB). Der Starter-Plan erlaubt bis zu 6 Team-Mitglieder kostenlos. Compliance: SOC 2 Type II, HIPAA mit BAA, GDPR.

### Self-Hosting

Seit Februar 2025 ist Convex vollständig **Open Source** unter der **FSL-Lizenz** (Functional Source License, konkret FSL-1.1-Apache-2.0). Der Convex-Blog formuliert es so: „Our particular take on the FSL converts all convex-backend source code to Apache 2.0 two years after its release.” „Fair Source” heißt: Du darfst fast alles wie unter Apache 2.0 — außer ein Konkurrenzprodukt zum gehosteten Convex Cloud bauen. Jede Version wird nach zwei Jahren automatisch zu Apache 2.0.

- **Deployment**: per **Docker** (empfohlen) oder vorgefertigtem Binary; auch auf Fly.io, Coolify, Dokploy.
- **Storage-Layer**: standardmäßig **SQLite**; für Produktion **PostgreSQL** oder **MySQL** (auch Neon). Achtung: Das ist die *interne* Persistenzschicht, nicht deine App-Tabellen.
- **Single-Node-Limitierung**: Das Open-Source-Backend läuft als einzelner Knoten — kein automatisches horizontales Skalieren, kein Load-Balancing, keine automatische Wiederherstellung wie in der Cloud.
- **Was „kostenlos” hier wirklich bedeutet**: Die Software ist gratis, aber DU trägst den Betriebsaufwand: Server bereitstellen, Backups/Replikation einrichten, Monitoring, Datenbank-Migrationen bei jedem Backend-Update selbst durchführen, bei Ausfall selbst neu starten. Realistisch braucht man dafür einen VPS (Entwicklung ab 2 GB RAM mit SQLite; Produktion ~4 GB RAM mit Postgres, z.B. bei Hetzner/DigitalOcean) plus Zeit und Ops-Wissen. „Kostenlos” ≠ „aufwandsfrei”.

### Kann man eine bestehende MySQL-Datenbank an Convex anschließen?

**Nein — nicht so, wie man vielleicht denkt.** Man kann eine bestehende MySQL-Datenbank *nicht* als Datenquelle mit vorhandenen Tabellen an Convex „anklemmen”. MySQL (oder Postgres/SQLite) dient beim Self-Hosting nur als **Persistenzschicht *unter* Convex**: Convex legt dort seine *eigenen internen* Tabellen an und verwaltet sie exklusiv. Deine bestehenden MySQL-Tabellen bleiben für Convex unsichtbar/unbenutzbar. Willst du bestehende relationale Daten mit vorhandenen Tabellen nutzen, ist Convex das falsche Werkzeug — dann eher Supabase, Drizzle/Prisma auf Postgres, oder eine Sync-Engine wie PowerSync/ElectricSQL.

-----

## TEIL 4 — DIE ALTERNATIVEN IM VERGLEICH

*Alle Preise/Limits Stand 2026, können sich ändern — jeweils auf der Anbieter-Preisseite prüfen.*

### Supabase

Open-Source-„Firebase-Alternative” auf **PostgreSQL**-Basis. Bietet Postgres-DB, Realtime (lauscht auf DB-Änderungen), Auth, Storage, **RLS** (Row-Level-Security-Zugriffsregeln), Edge Functions. Self-hostbar (aber schwergewichtiger Docker-Stack: Postgres, GoTrue, PostgREST, Realtime, Storage, Kong-Gateway).

- **Free**: 500 MB DB, 1 GB File-Storage, 5 GB Egress, 50.000 monatlich aktive Nutzer (MAU), 2 aktive Projekte; **Projekte pausieren nach 1 Woche Inaktivität** und es gibt keine Backups.
- **Pro**: 25 $/Monat pro Organisation (+ 10 $ Compute-Credit, deckt eine Micro-Instanz); Überschreitungen nutzungsbasiert. Team: 599 $/Monat.
- Stärke: echtes SQL, pgvector eingebaut, kein Lock-in (Standard-Postgres). Schwäche: keine „Scale-to-Zero” im Pro-Plan (24/7-Compute), Self-Hosting aufwändig.

### Firebase / Firestore

Googles BaaS mit **Firestore** (NoSQL-Dokument-DB), Realtime, Auth, Hosting, Functions. Nur gehostet (nicht self-hostbar).

- **Spark (gratis)**: 1 GiB Firestore-Speicher, 50.000 Reads/Tag, 20.000 Writes/Tag, 20.000 Deletes/Tag, 2 Mio. Function-Invocations/Monat.
- **Blaze (Pay-as-you-go)**: behält Free-Kontingente, dann z.B. Firestore-Reads 0,06 $/100.000 (2026), Speicher ca. 0,26 $/GB. **Wichtig seit 3. Februar 2026**: Google hat Cloud Storage for Firebase an die Standard-Google-Cloud-Storage-Regeln angeglichen — das Erstellen/Betreiben eines Buckets erfordert ein verknüpftes Abrechnungskonto (also den Blaze-Plan), unabhängig vom Volumen. Innerhalb des „Always Free”-Kontingents (5 GB-Monate Speicher, 100 GB Egress nach Nordamerika) bleibt es aber kostenlos.
- Stärke: riesiges Ökosystem, mobile-first. Schwäche: NoSQL-Grenzen, Kosten explodieren bei unbedachten Massen-Reads, Lock-in.

### Appwrite

Open-Source-BaaS (Dokument-DB, Auth mit 30+ OAuth-Providern, Storage, Functions, Messaging, Sites). Self-hostbar (Docker-Microservices-Stack) oder Appwrite Cloud.

- **Free (Cloud)**: 75.000 MAU, 5 GB Bandbreite, 2 GB Storage, 750.000 Function-Executions, 2 Projekte; pausiert nicht.
- **Pro**: 15 $/Monat pro Mitglied. Scale: 599 $/Monat (SOC 2).
- Stärke: batteries-included, volle Datenhoheit self-hosted. Schwäche: kein relationales SQL, Realtime bei Hochfrequenz etwas langsamer.

### PocketBase

Ultraleichtes Open-Source-Backend als **eine einzige ausführbare Datei** (Go-Binary) mit eingebettetem SQLite. Enthält Auth, DB, File-Storage, Admin-UI, Realtime.

- **Kosten**: komplett kostenlos, nur eigene Server-Infrastruktur. Kein Cloud-Angebot mit Tiers.
- Stärke: einfachste Einrichtung überhaupt (kopieren, starten). Schwäche: Single-Writer-SQLite, skaliert nur begrenzt, für kleine bis mittlere Projekte.

### Nhost

Open-Source-BaaS: **PostgreSQL + Hasura** (automatisch generierte GraphQL-APIs), Auth, Storage, Functions. GraphQL-first.

- **Starter (gratis)**: 1 GB DB, 1 GB Storage, 5 GB Bandbreite; pausiert nach 1 Woche Inaktivität.
- **Pro**: 25 $/Monat (+ 15 $ Compute-Credit), 10 GB DB, 50 GB Storage. Team: 599 $/Monat.
- Stärke: GraphQL + echtes Postgres. Schwäche: kleineres Ökosystem.

### Sync-Engines für bestehende Datenbanken

Diese synchronisieren Daten zwischen Server-DB und lokalem Client-Store (local-first):

- **Zero (Rocicorp)**: Query-zentrierte Sync-Engine, erreichte am **8. Juni 2026** Version 1.0 — laut Rocicorp-Release-Notes „After nearly two years of development, 50+ releases, thousands of commits, and hundreds of bugfixes, we are declaring Zero stable” (funktional ein kleines Update von 0.26.2). Server-autoritativ, sehr schnelle wahrgenommene Performance durch optimistische Mutations. Paart Client-Library mit einem read-only Postgres-Cache. Offline-Reads aus IndexedDB (hunderte MB Grenze). Vom Replicache-Team.
- **ElectricSQL**: Synchronisiert Postgres in lokales SQLite/PGlite. Nach „clean rebuild” (electric-next, Juli 2024) ein „shape”-basiertes Read-Path-Modell; die App besitzt weiterhin den Write-Path. Open Source.
- **PowerSync**: Reifste, „battle-tested” Lösung, besonders für Mobile. Synchronisiert Postgres UND MongoDB in lokales SQLite; Upload über selbst definierten Endpunkt (volle Konfliktkontrolle). Managed Cloud-Sync-Layer.
- **InstantDB**: „Firebase für die relationale Ära”, local-first mit Echtzeit-Sync, GraphQL-artige verschachtelte Abfragen, eingebaute „Ephemeral Presence” (Cursor/„tippt gerade”). Kostenloser Tier ohne Projekt-Pausierung und ohne Beschränkung für kommerzielle Nutzung.
- **Triplit**: Open-Source local-first DB + Sync, TypeScript-Schema, Live-Queries. **Wurde am 8. Oktober 2025 von Supabase übernommen**; Mitgründer Matt Linkous wechselte ins Supabase-Team (CEO Paul Copplestone: „With this acquisition, we’re bringing Matt’s deep expertise in the offline-first domain into our ecosystem”). Das kann die künftige Ausrichtung beeinflussen.

### Realtime-Transport-Dienste

Diese liefern reine Nachrichten-/Präsenz-Infrastruktur (kein Datenbank-Zustand):

- **Liveblocks**: Managed-Plattform für Kollaboration (Cursors, Presence, Kommentare, CRDT-basiert mit Yjs-Integration). Kostenloser Tier (etwa bis 100 MAU), dann Preise nach monatlich aktiven Räumen — bei Hochlast wird das schnell zum echten Kostenfaktor.
- **PartyKit**: Läuft Room-basierte Server-Logik am Edge (auf Cloudflare Durable Objects). Anders als reine Relays führt es serverseitige Logik pro Raum aus — ideal für Multiplayer-Spiele, Live-Umfragen, Canvas. Kommerzielle Nutzung erfordert Deployment im eigenen Cloudflare-Account.
- **Ably**: Managed Pub/Sub (publish/subscribe). Kein CRDT, „last message wins”. Freier Tier: 6 Mio. Nachrichten/Monat; ab 29 $/Monat. Gut für Feeds, Benachrichtigungen, einfache Presence.
- **Pusher**: Klassisches Pub/Sub. Freier Tier: 200 gleichzeitige Verbindungen, 200.000 Nachrichten/Tag. Breite Sprachunterstützung.

### CRDT-Bibliotheken

- **Yjs**: De-facto-Standard für CRDTs im Web, sehr performant, ausgereift, riesiges Ökosystem (Editoren, Zeichentools). Paart gut mit Liveblocks/PartyKit/Hocuspocus.
- **Automerge**: CRDT-Bibliothek mit Fokus auf einfaches Datenmodell (JSON-artig), Version 3.0 erschienen. Etwas anderer Trade-off als Yjs.

Grundsatz: **CRDTs niemals selbst implementieren** — die Korrektheitsanforderungen sind subtil; nutze die erprobten Bibliotheken.

### Baukasten-Ansatz

Statt eines integrierten BaaS kombiniert man Einzelteile selbst:

- **Neon**: Serverless Postgres mit „Scale-to-Zero” (schläft bei Inaktivität) und Branching (DB-Kopien in Sekunden). Free: 0,5 GB Speicher, 100 Compute-Stunden/Monat pro Projekt. Bezahlt: rein nutzungsbasiert, seit Dezember 2025 kein Monatsminimum (Compute ~0,106 $/CU-Stunde auf Launch, Speicher 0,35 $/GB-Monat). Am **14. Mai 2025 für rund 1 Mrd. $ von Databricks übernommen**. Ideal für spikey/idle-lastige Workloads, unvorhersehbar bei Dauerlast.
- **PlanetScale**: Serverless MySQL (Vitess) mit Branching und Zero-Downtime-Schema-Änderungen. **Free-Tier abgeschafft**; Pläne ab 39 $/Monat (Einstieg teils ab 5 $ genannt). Für produktive MySQL-Workloads mit hoher Verfügbarkeit.
- Kombination: z.B. **Neon/Supabase + Drizzle/Prisma + eigenes API-Layer** (z.B. mit Next.js oder Hono). Maximale Kontrolle und kein Lock-in, aber du baust und wartest mehr selbst.

### Große Vergleichstabelle

|Plattform      |Datenmodell                 |Realtime-Ansatz                 |Auth eingebaut           |File Storage  |Self-Hosting         |Free-Tier                  |Preis-Einstieg            |Lock-in-Risiko                        |Eignung KI-Entwicklung                  |
|---------------|----------------------------|--------------------------------|-------------------------|--------------|---------------------|---------------------------|--------------------------|--------------------------------------|----------------------------------------|
|**Convex**     |Document-relational         |Sync-Engine (WebSocket), im Kern|Ja (Convex Auth / Clerk) |Ja            |Ja (FSL, Single-Node)|1 Mio. Calls, 0,5 GB DB    |25 $/Entw./Mon.           |Mittel-hoch (Export/Self-Host mildert)|Sehr hoch (State im Repo, Typsicherheit)|
|**Supabase**   |Relational (Postgres)       |Postgres-Changes-Stream         |Ja                       |Ja            |Ja (schwer)          |500 MB DB, 50k MAU         |25 $/Mon.                 |Niedrig (Std-Postgres)                |Mittel (RLS/Dashboard verstreut)        |
|**Firebase**   |NoSQL (Firestore)           |Eingebaut (Listener)            |Ja                       |Ja (nur Blaze)|Nein                 |1 GiB, 50k Reads/Tag       |Pay-as-you-go             |Hoch                                  |Mittel                                  |
|**Appwrite**   |Dokument                    |Eingebaut (Subscriptions)       |Ja                       |Ja            |Ja (Docker)          |75k MAU                    |15 $/Mon.                 |Niedrig-mittel                        |Mittel                                  |
|**PocketBase** |SQLite                      |Eingebaut                       |Ja                       |Ja            |Ja (1 Binary)        |Voll (self-host)           |Gratis (nur Server)       |Niedrig                               |Mittel                                  |
|**Nhost**      |Relational (Postgres+Hasura)|GraphQL-Subscriptions           |Ja                       |Ja            |Ja                   |1 GB DB                    |25 $/Mon.                 |Niedrig-mittel                        |Mittel                                  |
|**Zero**       |Sync-Layer auf Postgres     |Sync-Engine                     |Nein (backend-agnostisch)|Nein          |—                    |—                          |—                         |Mittel                                |Mittel                                  |
|**ElectricSQL**|Sync Postgres→SQLite        |Sync-Engine (Shapes)            |Nein                     |Nein          |Ja (OSS)             |OSS                        |—                         |Niedrig                               |Mittel                                  |
|**PowerSync**  |Sync Postgres/Mongo→SQLite  |Sync-Engine                     |Nein                     |Nein          |Teilweise            |Ja                         |Nutzungsbasiert           |Niedrig                               |Mittel                                  |
|**InstantDB**  |Relational, local-first     |Sync-Engine + Presence          |Ja                       |Begrenzt      |Nein                 |Großzügig, keine Pausierung|Nutzungsbasiert           |Mittel                                |Hoch (TS-nah)                           |
|**Triplit**    |Local-first DB              |Sync-Engine                     |Ja                       |Begrenzt      |Ja (OSS)             |Ja                         |—                         |Mittel (Supabase-Übernahme)           |Hoch (TS-Schema)                        |
|**Liveblocks** |Nur Realtime-State (CRDT)   |WebSocket/CRDT                  |Nein                     |Nein          |Nein (managed)       |Ja (bis ~100 MAU)          |99 $/Mon. (bezahlt)       |Mittel                                |Niedrig (nur Transport)                 |
|**PartyKit**   |Nur Realtime (pro Raum)     |WebSocket am Edge               |Nein                     |Nein          |Cloudflare           |Ja (24h Storage)           |Cloudflare-Kosten         |Niedrig                               |Niedrig (nur Transport)                 |
|**Ably**       |Nur Pub/Sub                 |WebSocket Pub/Sub               |Nein                     |Nein          |Nein                 |6 Mio. Nachr./Mon.         |29 $/Mon.                 |Niedrig                               |Niedrig                                 |
|**Pusher**     |Nur Pub/Sub                 |WebSocket Pub/Sub               |Nein                     |Nein          |Nein                 |200 Verb./200k Nachr./Tag  |Nutzungsbasiert           |Niedrig                               |Niedrig                                 |
|**Neon**       |Relational (Postgres)       |Nein (reine DB)                 |Nein                     |Nein          |Nein (managed)       |0,5 GB, 100 CU-h           |Nutzungsbasiert, kein Min.|Niedrig                               |Mittel                                  |
|**PlanetScale**|Relational (MySQL/PG)       |Nein                            |Nein                     |Nein          |Nein                 |Kein Free-Tier mehr        |ab 39 $/Mon.              |Niedrig                               |Mittel                                  |

-----

## TEIL 5 — OBJECT STORAGE UND ASSET-AUSLIEFERUNG

### Grundbegriffe

- **Object Storage**: Ein Speichersystem für „Objekte” (Dateien beliebiger Größe) mit einem Schlüssel (Pfad). Kein Dateisystem im klassischen Sinn, sondern über HTTP-API ansprechbar. Prototyp: Amazon S3. Skaliert praktisch unbegrenzt und ist günstig pro GB.
- **CDN** (Content Delivery Network): Ein Netz aus Servern weltweit, das Kopien deiner Dateien nah am Nutzer zwischenspeichert (cached). Ergebnis: schnellere Downloads, weniger Last am Ursprung.
- **Egress**: Der ausgehende Datenverkehr — die Bytes, die aus dem Speicher zu den Nutzern fließen. **Das ist bei vielen Anbietern der versteckte Hauptkostentreiber**, nicht die Speicherung selbst.

### Warum große Dateien NICHT in die Datenbank/BaaS-Storage?

3D-Modelle und Audio sind groß (Megabytes bis Hunderte MB). Wenn du sie in eine Datenbank oder in teuren BaaS-Storage legst:

- Datenbanken sind für kleine, strukturierte Datensätze optimiert, nicht für große Binärblobs — das bläht Backups auf und verlangsamt Abfragen. (Convex hat sogar ein hartes Dokumentgrößen-Limit von 1 MiB — ein einzelnes 3D-Modell passt gar nicht als Dokument.)
- BaaS-Storage und Function-Egress sind oft teuer (Convex-Free hat z.B. nur 1 GB File-Egress/Monat).
- Auslieferung großer Dateien über Backend-Funktionen kostet Function Calls und Bandbreite.

**Best Practice:** Lege die eigentliche Datei in **Object Storage** (idealerweise mit CDN davor) und speichere in der Datenbank nur die **Metadaten** (Name, Typ, Größe, Tags, den Storage-Schlüssel/URL). Die Datenbank verwaltet die Bibliothek; der Object Storage liefert die Bytes.

### Vergleich Object-Storage-Anbieter (Stand 2026)

*Preise ändern sich — auf den offiziellen Preisseiten prüfen.*

|Anbieter            |Speicher/GB-Monat    |Egress                                                                            |Free-Tier                         |Class-A (Writes)     |Class-B (Reads)      |Besonderheit                                  |
|--------------------|---------------------|----------------------------------------------------------------------------------|----------------------------------|---------------------|---------------------|----------------------------------------------|
|**Cloudflare R2**   |0,015 $              |**0 $ (immer gratis)**                                                            |10 GB Speicher, 10 Mio. Reads/Mon.|4,50 $/Mio.          |0,36 $/Mio.          |Kein Egress, S3-kompatibel, CDN-integriert    |
|**AWS S3**          |~0,023 $ (Standard)  |~0,09 $/GB                                                                        |begrenzt                          |0,005 $/1.000 PUT    |0,0004 $/1.000 GET   |Größtes Ökosystem, braucht CloudFront-CDN     |
|**Backblaze B2**    |0,006 $              |3× Speicher gratis, dann 0,01 $/GB; **gratis via Cloudflare (Bandwidth Alliance)**|10 GB gratis                      |in Pay-as-you-go frei|in Pay-as-you-go frei|Billigster Speicher, ideal für Backups/Archive|
|**Supabase Storage**|im Plan (Pro: 100 GB)|zählt gegen Egress-Kontingent                                                     |1 GB (Free)                       |—                    |—                    |Nur sinnvoll, wenn ohnehin Supabase-Nutzer    |

**Begriffserklärung Class A/B:** Objektspeicher berechnen nicht nur Speicherplatz, sondern auch **Operationen**. „Class A” sind teurere schreibende/auflistende Operationen (PUT, LIST); „Class B” sind billigere lesende (GET). Bei vielen kleinen Dateien mit hohem Zugriff können diese Operationskosten relevant werden.

**Empfehlung für dein Projekt:** **Cloudflare R2** ist 2026 die risikoärmste Standardwahl für 3D-/Audio-Auslieferung — null Egress-Kosten (entscheidend, da 3D/Audio bandbreitenhungrig sind), S3-kompatibel (Standard-Tools/SDKs funktionieren) und integriertes CDN. Backblaze B2 + Cloudflare ist noch billiger im reinen Speicher, aber R2 ist einfacher. S3 nur, wenn du ohnehin tief im AWS-Ökosystem steckst.

### Presigned URLs / sicherer Upload-Flow

Eine **Presigned URL** (vorsignierte URL) ist ein zeitlich befristeter, kryptografisch signierter Link, der genau eine Operation (z.B. „diese eine Datei hochladen”) erlaubt — ohne dass der Browser deine geheimen Storage-Zugangsdaten kennt.

**Upload-Ablauf (sicher):**

1. Browser fragt dein Backend: „Ich will Datei X (Typ, Größe) hochladen.”
2. Backend prüft Nutzer/Berechtigung/Dateityp, wählt einen Objektschlüssel (z.B. `uploads/{userId}/{datum}-{uuid}.glb`) und erzeugt eine **Presigned PUT-URL** (kurze Gültigkeit, z.B. 60 Sekunden).
3. Browser lädt die Datei **direkt** zum Object Storage per PUT hoch (die Bytes gehen nie durch dein Backend — spart Ressourcen).
4. Nach Erfolg meldet der Browser dem Backend den Objektschlüssel; das Backend speichert die Metadaten in der Datenbank.

```typescript
// Backend: Presigned URL für R2/S3 erzeugen (AWS SDK v3)
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

const s3 = new S3Client({ region: "auto", endpoint: R2_ENDPOINT });
const key = `uploads/${userId}/${Date.now()}-${crypto.randomUUID()}.glb`;
const url = await getSignedUrl(
  s3,
  new PutObjectCommand({ Bucket: "assets", Key: key, ContentType: "model/gltf-binary" }),
  { expiresIn: 60 }
);
// url an den Browser zurückgeben
```

Für große Dateien (>100 MB) nutzt man **Multipart Upload** (Datei in Teile zerlegen, parallel/wiederaufnehmbar hochladen). Wichtig: **CORS** am Bucket konfigurieren, sonst scheitern Browser-Uploads. Der `Content-Type`-Header beim Upload muss zu dem passen, mit dem signiert wurde — sonst gibt es `SignatureDoesNotMatch`-Fehler.

### Signierte URLs für private Assets

Für **private** Dateien (nur für berechtigte Nutzer) hältst du den Bucket privat und erzeugst zum Lesen ebenfalls **signierte GET-URLs** mit kurzer Gültigkeit. Nach Ablauf ist der Link ungültig. So bleibt die Datei geschützt, ohne den ganzen Bucket öffentlich zu machen. Für öffentliche Showcase-Assets kann man dagegen den Bucket/CDN-Pfad einfach öffentlich cachen lassen.

-----

## TEIL 6 — SPEZIFISCH FÜR THREE.JS / 3D + AUDIO

### GLTF vs. GLB

**glTF** (GL Transmission Format) ist der Standard für 3D-Assets im Web (vom Khronos-Konsortium). Zwei Varianten:

- **.gltf**: JSON-Datei, die auf externe Ressourcen (Geometrie-`.bin`, Texturen) verweist — mehrere Dateien.
- **.glb**: Alles (JSON + Geometrie + Texturen) in **einer einzigen binären Datei** gebündelt. Kompakter, ein Request, für Web meist die bessere Wahl.

Inhaltlich identisch — GLB ist nur die verpackte Binärform.

### Mesh-Kompression: Draco vs. Meshopt

Die **Geometrie** (Vertices/Meshes) kann komprimiert werden:

- **Draco** (Google): Sehr hohe Kompression — bei Modellen, wo Geometrie dominiert (>1 MB), oft **~95 % Größenreduktion**. Trade-off: Der WASM-Decoder muss geladen und die Geometrie **vor** dem GPU-Upload dekomprimiert werden — das kostet CPU-Zeit beim Laden. Bei kleiner Geometrie (<1 MB) kann der Decoder-Overhead die Ersparnis auffressen. Draco ist verlustbehaftet (Quantisierung) — daher immer die Originale behalten und Kompression als letzten Schritt der Pipeline anwenden.
- **Meshopt** (meshoptimizer): Etwas geringere Kompression als Draco, aber **deutlich schnellere Dekompression**. Braucht zusätzlich gzip/brotli auf dem Server für vollen Effekt; dann ähnliche Ratios wie Draco bei viel schnellerem Decoding.

**Wichtig:** Weder Draco noch Meshopt verbessern die **Laufzeit-Framerate** — sie verkleinern nur die Download-Größe. Die Dekompression passiert vor dem GPU-Upload. Für bessere FPS musst du die Geometrie *vereinfachen* (weniger Vertices/Draw-Calls), nicht nur komprimieren.

```typescript
// Three.js GLTFLoader mit Draco
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import { DRACOLoader } from "three/addons/loaders/DRACOLoader.js";

const dracoLoader = new DRACOLoader();
dracoLoader.setDecoderPath("/draco/"); // Pfad zu decoder-Dateien
const loader = new GLTFLoader();
loader.setDRACOLoader(dracoLoader);
loader.load("/models/asset.glb", (gltf) => {
  scene.add(gltf.scene);
});
```

### Texturen: KTX2 / Basis Universal

Normale Bildformate (**PNG/JPG/WebP**) müssen beim Laden vollständig dekodiert und als **unkomprimierte** Pixel in den Grafikspeicher (**VRAM**) geladen werden. Eine 2048×2048-RGBA-Textur belegt so **16 MB VRAM**, egal wie klein die PNG war.

**KTX2** ist ein Container-Format für GPU-Texturen; kombiniert mit **Basis Universal**-Supercompression bleibt die Textur **komprimiert bis in den VRAM**, indem sie beim Laden in ein GPU-natives Format transkodiert wird (BC auf Desktop, ASTC/ETC2 auf Mobile). Das **spart typischerweise das 4- bis 8-fache an Texturspeicher**. Beispiel aus der Praxis: 4 Bilder = 128 MB VRAM als JPG vs. 32 MB als KTX2, bei ähnlicher Qualität.

- **UASTC**: höhere Qualität (für Hero-Art, Normal-Maps), größere Dateien.
- **ETC1S**: kleiner, für die Masse der Texturen.

```typescript
// Three.js KTX2Loader
import { KTX2Loader } from "three/addons/loaders/KTX2Loader.js";
const ktx2Loader = new KTX2Loader()
  .setTranscoderPath("/basis/")
  .detectSupport(renderer); // muss vor dem Laden aufgerufen werden
loader.setKTX2Loader(ktx2Loader); // an GLTFLoader hängen
```

### Audio: WAV vs. Opus vs. MP3

- **WAV**: Unkomprimiert, verlustfrei, ~10 MB/Minute (CD-Qualität). Ideal für die **Quelldateien**/Bearbeitung, zu groß für die Auslieferung.
- **MP3**: Universell kompatibel (jedes Gerät, Autoradio), ~2,4 MB/Minute bei 320 kbps. Guter Fallback für maximale Kompatibilität.
- **Opus**: Moderner, offener, lizenzfreier Codec (IETF RFC 6716, standardisiert 2012). **Bei gleicher Qualität etwa halb so groß wie MP3**: Opus bei 64 kbps klingt wie MP3 bei 128 kbps; bei 96 kbps praktisch nicht vom Original unterscheidbar. Sehr niedrige Latenz (5–20 ms), Standard für WebRTC/Discord/WhatsApp. Von allen modernen Browsern unterstützt. Nachteil: nicht auf allen dedizierten Hardware-Playern (Autoradios).

**Empfehlung:** Originale als WAV behalten, für die Web-Auslieferung **Opus** ausliefern (kleinste Dateien bei bester Qualität), optional MP3 als Fallback für exotische Clients.

**Audio-Sprites** sind mehrere kurze Sounds in **einer** Audiodatei zusammengefasst; per Zeit-Offset spielt man einzelne Segmente ab. Vorteil: weniger HTTP-Requests, weniger Latenz beim Abspielen kurzer Samples (z.B. UI-Sounds).

**Web Audio API** ist die Browser-Schnittstelle für präzise Audio-Steuerung (Laden in einen `AudioBuffer`, Abspielen mit exaktem Timing, Effekte, Mischen) — mächtiger als ein simples `<audio>`-Element und die Grundlage für 3D-Positional-Audio in Three.js (`THREE.PositionalAudio`).

### Lade-Strategien

- **Lazy Loading**: Assets erst laden, wenn sie gebraucht werden (z.B. beim Scrollen/Betreten eines Bereichs), nicht alles vorab.
- **LOD** (Level of Detail): Mehrere Detailstufen eines Modells; entfernte Objekte nutzen die niedrig aufgelöste Version — spart GPU-Leistung.
- **Progressive Loading**: Erst eine grobe Version zeigen, dann Details nachladen.
- **Caching-Header**: HTTP-Header (`Cache-Control`, `ETag`), die dem Browser/CDN sagen, wie lange eine Datei zwischengespeichert werden darf. Für unveränderliche Assets (mit Hash im Dateinamen) lange Cache-Zeiten setzen → Nutzer lädt sie nur einmal.

### Typisches Metadaten-Schema für eine Asset-Bibliothek

```typescript
// Convex-Schema-Beispiel für 3D + Audio Assets
export default defineSchema({
  assets: defineTable({
    name: v.string(),
    type: v.union(v.literal("model"), v.literal("audio")),
    format: v.string(),          // "glb", "gltf", "opus", "wav"
    storageKey: v.string(),      // Schlüssel im Object Storage (R2)
    url: v.optional(v.string()), // öffentliche CDN-URL (falls public)
    fileSize: v.number(),        // Bytes
    // Gemeinsame Felder
    tags: v.array(v.string()),
    ownerId: v.id("users"),
    isPublic: v.boolean(),
    createdAt: v.number(),
    // 3D-spezifisch
    vertexCount: v.optional(v.number()),
    boundingBox: v.optional(v.object({ x: v.number(), y: v.number(), z: v.number() })),
    hasDraco: v.optional(v.boolean()),
    hasKTX2: v.optional(v.boolean()),
    thumbnailKey: v.optional(v.string()),
    // Audio-spezifisch
    durationSec: v.optional(v.number()),
    sampleRate: v.optional(v.number()),
    channels: v.optional(v.number()),
    bpm: v.optional(v.number()),
  })
    .index("by_type", ["type"])
    .index("by_owner", ["ownerId"])
    .index("by_type_and_public", ["type", "isPublic"]),
});
```

Kernfelder für beide: eindeutige ID, Name, Typ, Format, Storage-Schlüssel, Größe, Tags, Besitzer, Sichtbarkeit, Erstellungszeit, Thumbnail/Vorschau. Dazu typ-spezifische Felder (Vertex-Count/Bounding-Box für 3D; Dauer/Sample-Rate/BPM für Audio).

### Multiplayer / kollaborative 3D-Szenen: Positions-Updates NICHT über die DB

Wenn mehrere Nutzer sich in einer 3D-Szene bewegen, entstehen **sehr viele, sehr schnelle** Positions-Updates (z.B. 20–60 pro Sekunde pro Nutzer). Diese durch eine Datenbank oder Convex-Mutations zu schleusen wäre fatal:

- Jede Mutation ist ein **Function Call** — bei 30 Updates/Sekunde × vielen Nutzern sprengst du Kontingente und Kosten sofort (Convex Free = 1 Mio. Calls/Monat, das wäre in Minuten aufgebraucht).
- Positions-Daten sind **flüchtig** — sie müssen nicht dauerhaft gespeichert werden; nur der aktuelle Zustand zählt.

**Richtige Architektur:** Positions-/Cursor-/Presence-Updates laufen über einen **Realtime-Transport** (PartyKit, Liveblocks, Ably oder ein eigener WebSocket-Server), der Nachrichten nur weiterleitet, ohne sie zu persistieren. Nur *dauerhafter* Zustand (wer ist im Raum, welche Objekte wurden platziert/gespeichert) geht in die Datenbank. Diese Trennung — flüchtiger Echtzeit-Transport vs. persistente DB — ist der Standard für Multiplayer.

-----

## TEIL 7 — ENTSCHEIDUNGSHILFE UND LERNPFAD

### Entscheidungsbaum

**Szenario A — Reines Showcase / Portfolio (keine Nutzerkonten, keine Uploads):**
Du zeigst deine eigenen 3D-Modelle und spielst Audio ab. Keine Datenbank nötig!
→ Statische Website (Vite/Next.js) auf **Vercel/Cloudflare Pages** + Assets auf **Cloudflare R2** (mit CDN). Optional eine kleine JSON-Datei oder ein einfaches CMS als „Katalog”.

**Szenario B — Mit Uploads / Nutzerkonten (Asset-Verwaltung):**
Nutzer melden sich an, laden Assets hoch, verwalten ihre Bibliothek.
→ **Convex** (Metadaten, Auth, reaktive UI) + **Cloudflare R2** (die eigentlichen Dateien via Presigned URLs). Alternativ **Supabase** (wenn du SQL/Portierbarkeit willst) + R2.

**Szenario C — Echter Multiplayer (kollaborative 3D-Szenen):**
Mehrere Nutzer bewegen sich/bearbeiten gemeinsam eine Szene in Echtzeit.
→ **Convex/Supabase** (persistenter Zustand + Auth) + **R2** (Assets) + **PartyKit oder Liveblocks** (flüchtige Positions-/Presence-Updates). Für kollaborative Bearbeitung mit Konfliktauflösung zusätzlich **Yjs**.

### Konkrete Architekturvorschläge mit geschätzten Monatskosten

*Schätzungen für ein kleines Projekt (hunderte bis wenige tausend Nutzer). Preise können sich ändern — beim Anbieter prüfen.*

**Szenario A (Showcase):**

- Vercel/Cloudflare Pages (Hobby/Free): 0 $
- Cloudflare R2: 10 GB Speicher gratis, danach 0,015 $/GB, Egress 0 $
- **Gesamt: ~0 $/Monat** (bei moderatem Volumen)

**Szenario B (Uploads/Konten):**

- Convex Free/Starter: 0 $ (bis 1 Mio. Calls, 0,5 GB DB) — oder Professional 25 $ bei Wachstum
- Cloudflare R2: ~0–5 $ (je nach Speichervolumen, Egress gratis)
- Clerk Auth (optional): kostenloser Tier für kleine Nutzerzahlen
- **Gesamt: ~0–30 $/Monat**

**Szenario C (Multiplayer):**

- Convex Professional: 25 $
- Cloudflare R2: ~5 $
- PartyKit: Cloudflare-Kosten (gering bei moderatem Traffic) / Liveblocks ab ~0 $ (Free bis ~100 MAU), dann 99 $
- **Gesamt: ~30–130 $/Monat** (stark abhängig von aktiver Nutzerzahl)

### Strukturierter Lernpfad (Reihenfolge für Anfänger)

1. **Web-Grundlagen**: HTML/CSS/JavaScript, dann TypeScript. Ressource: *MDN Web Docs* (developer.mozilla.org), *TypeScript Handbook* (typescriptlang.org/docs).
2. **Three.js-Grundlagen**: Szene, Kamera, Renderer, Geometrie, Material, Licht. Ressource: offizielle *Three.js Docs & Examples* (threejs.org), kostenlos: *Three.js Manual/Fundamentals* (threejs.org/manual). *Three.js Journey* (kostenpflichtig) gilt als beste strukturierte Referenz.
3. **Datenbank-Grundlagen & SQL**: Ressource: *SQLBolt* (sqlbolt.com, kostenlos, interaktiv), *PostgreSQL Tutorial* (postgresqltutorial.com).
4. **Ein Backend/BaaS praktisch lernen**: Convex-Tutorial (docs.convex.dev/tutorial) ODER Supabase-Docs (supabase.com/docs). Baue eine kleine CRUD-App.
5. **Object Storage & Uploads**: Cloudflare R2-Docs (developers.cloudflare.com/r2), Presigned-URL-Konzept verstehen und einen Upload-Flow bauen.
6. **Asset-Optimierung**: *glTF-Transform* (gltf-transform.dev) für Draco/Meshopt/KTX2, *Don McCurdy’s Blog* zu Texturformaten. `gltf-pipeline` und `gltfpack` als CLI-Werkzeuge.
7. **Realtime & Multiplayer** (nur bei Bedarf): Convex-Sync verstehen, dann PartyKit-Docs (docs.partykit.io) oder Liveblocks-Docs. CRDTs/Yjs (docs.yjs.dev) zuletzt.
8. **Deployment & CI/CD**: Vercel/Cloudflare-Docs, GitHub-Actions-Grundlagen.

### Typische Anfängerfehler und wie man sie vermeidet

- **Große Dateien in die Datenbank/BaaS-Storage legen.** → Immer Object Storage + nur Metadaten in der DB.
- **Positions-Updates über die Datenbank schicken.** → Realtime-Transport nutzen, DB nur für persistenten Zustand.
- **Unkomprimierte Assets ausliefern** (PNG-Texturen, WAV-Audio, rohe Meshes). → KTX2, Opus, Draco/Meshopt einsetzen.
- **Egress-Kosten ignorieren.** → R2 (0 $ Egress) statt S3 wählen; Caching-Header setzen.
- **`getDocs()`/SELECT * ohne Limit** über große Sammlungen. → Immer paginieren und indizieren; bei Firebase treiben unbedachte Reads die Kosten hoch.
- **Fehlende Indizes** → langsame Queries. Indiziere Felder, nach denen du filterst/sortierst.
- **Geheime Storage-Keys im Frontend.** → Immer Presigned URLs vom Backend; Keys nur server-seitig.
- **CORS am Bucket vergessen** → Browser-Uploads scheitern. Vorher konfigurieren.
- **Lock-in unterschätzen.** → Vor der Wahl fragen: Wie komme ich wieder raus? (Export, Standard-Formate, Self-Hosting-Option.)
- **Free-Tier-Pausierung übersehen** (Supabase/Nhost pausieren nach 1 Woche Inaktivität). → Bei Demos/Portfolios einplanen.
- **Denken, „Self-Hosting = kostenlos”.** → Software gratis, aber Betrieb/Wartung kostet Zeit und Server.

-----

## TEIL 8 — TOOLING-KONTEXT (Claude Code Plugins)

Für deine KI-gestützte Entwicklung mit **Claude Code** sind diese Integrationen relevant:

- **Vercel**: Hosting-Plattform für Frontends (Next.js etc.). Automatische Deployments aus Git, Preview-Deployments pro Branch, Edge-Netzwerk. Das Plugin erlaubt, Deployments zu verwalten/auszulösen.
- **GitHub**: Code-Hosting mit Git-Versionierung, Pull Requests, Code-Reviews, CI/CD (GitHub Actions). Das Fundament — hier lebt dein Code.
- **Linear**: Werkzeug für Issue-Tracking und Projektplanung (Tickets, Sprints, Roadmaps) mit sehr schneller, aufgeräumter Oberfläche. Beliebt bei Produktteams.
- **Convex**: Das Backend selbst; das Plugin/MCP-Server erlaubt dem Agenten, Daten abzufragen, Funktionen zu inspizieren und mit dem Deployment zu interagieren.

### Linear vs. GitHub Issues — wann was?

- **GitHub Issues**: Direkt am Code-Repository, kostenlos, gut für kleine Teams/Solo-Projekte und technische Bug-Reports nah am Code. Einfach, aber begrenzt bei Planung.
- **Linear**: Dediziertes Projektmanagement — bessere Ansichten für Roadmaps, Zyklen, Priorisierung, teamübergreifende Planung. Lohnt sich, wenn du strukturierte Produktplanung über reines Bug-Tracking hinaus brauchst.
- **Faustregel**: Solo/klein und codenah → GitHub Issues reicht. Wächst das Projekt oder willst du Features/Roadmap systematisch planen → Linear (lässt sich mit GitHub verknüpfen).

-----

## TEIL 9 — GLOSSAR

- **ACID**: Atomicity, Consistency, Isolation, Durability — Garantien einer Datenbank-Transaktion.
- **Action (Convex)**: Funktion, die externe APIs aufrufen darf, aber nicht transaktional/reaktiv ist.
- **API**: Schnittstelle zwischen Frontend und Backend.
- **BaaS**: Backend-as-a-Service — fertiges Backend-Paket.
- **CDN**: Content Delivery Network — weltweites Cache-Netz für schnelle Auslieferung.
- **CRDT**: Conflict-free Replicated Data Type — Datenstruktur zur automatischen Konfliktauflösung.
- **Class A/B Operationen**: Teurere schreibende (A) vs. billigere lesende (B) Storage-Operationen.
- **Draco**: Mesh-Kompression von Google (~95 % kleiner, langsamere Dekompression).
- **Edge**: Ausführung nahe am Nutzer (verteilt).
- **Egress**: Ausgehender Datenverkehr — oft der Hauptkostentreiber.
- **Embedding**: Numerischer Vektor, der die Bedeutung von Daten repräsentiert.
- **FSL**: Functional Source License — „Fair Source”-Lizenz (Convex), nach 2 Jahren Apache 2.0.
- **glTF/GLB**: Standard-3D-Format; GLB ist die gebündelte Binärvariante.
- **Index**: Zusatzstruktur zum schnellen Suchen; kostet Speicher und Schreibleistung.
- **Isolation Level**: Grad der Abschirmung paralleler Transaktionen; „Serializable” ist am stärksten.
- **KTX2 / Basis Universal**: GPU-Texturformat, das komprimiert im VRAM bleibt (4–8× Ersparnis).
- **Lazy Loading**: Daten/Assets erst bei Bedarf laden.
- **Local-first**: Architektur mit lokaler Datenkopie als primäre Quelle.
- **LOD**: Level of Detail — verschiedene Detailstufen je nach Entfernung.
- **Meshopt**: Mesh-Kompression mit schneller Dekompression (braucht gzip/brotli).
- **Migration**: Kontrollierte, versionierte Schema-Änderung.
- **Mutation (Convex)**: Transaktionale Schreibfunktion.
- **Normalisierung/Denormalisierung**: Redundanz vermeiden vs. bewusst duplizieren.
- **OCC**: Optimistic Concurrency Control — Konflikte am Ende prüfen statt sperren.
- **OLTP/OLAP**: Transaktions- vs. Analyse-Verarbeitung.
- **Opus**: Moderner Audio-Codec (halb so groß wie MP3 bei gleicher Qualität).
- **ORM**: Object-Relational Mapper — bildet DB-Tabellen als typsichere Objekte ab.
- **Object Storage**: Speicher für beliebig große Dateien via HTTP-API (z.B. S3, R2).
- **Polling**: Wiederholtes Abfragen „Gibt’s was Neues?”.
- **Presigned URL**: Zeitlich befristeter, signierter Link für eine bestimmte Storage-Operation.
- **Query (Convex)**: Reaktive Nur-Lese-Funktion.
- **RLS**: Row-Level Security — Zugriffsregeln auf Zeilenebene (in Postgres/Supabase).
- **Serverless**: Funktionen ohne selbst verwaltete Server.
- **Schema**: Bauplan der Datenstruktur.
- **SSE**: Server-Sent Events — einseitiger Server→Client-Push.
- **Sync-Engine**: Hält Client-Daten automatisch mit dem Server synchron.
- **Transaktion**: Gruppe von Operationen, die als Einheit ausgeführt werden.
- **V8-Isolate**: Leichtgewichtige JS-Ausführungsumgebung ohne Cold Starts.
- **Vektor-Datenbank**: Speichert Embeddings für Ähnlichkeitssuche.
- **VRAM**: Grafikspeicher der GPU.
- **WebSocket**: Dauerhafte, bidirektionale Browser-Server-Verbindung.
- **Yjs / Automerge**: CRDT-Bibliotheken.

-----

## ZUSAMMENFASSUNG / TL;DR

- **Beste Architektur für dein Projekt (Three.js-Asset-Management, KI-gestützt):** **Convex** für Metadaten/Auth/reaktive UI + **Cloudflare R2** für die eigentlichen 3D-/Audio-Dateien (via Presigned URLs) — und bei echtem Multiplayer zusätzlich **PartyKit/Liveblocks** für flüchtige Positions-Updates. Diese Kombination ist KI-freundlich (gesamter Backend-State als Code im Repo, durchgängige Typsicherheit als Selbstkorrektur-Schleife für Claude Code) und kostengünstig (R2 ohne Egress-Kosten, Convex-Free bis 1 Mio. Calls/Monat).
- **Die wichtigste Grundregel:** Große Dateien gehören NIE in die Datenbank, sondern in Object Storage — in der DB nur Metadaten. Und Echtzeit-Positionsdaten laufen über einen Realtime-Transport, nicht über Function Calls/Mutations, sonst explodieren Kosten und Kontingente.
- **Ehrlicher Trade-off:** Convex bedeutet ein mittleres bis hohes Vendor-Lock-in-Risiko (proprietäres Modell, kein SQL/Joins/Ad-hoc-Analytics), abgemildert durch Self-Hosting (Open Source unter FSL, aber Single-Node und mit echtem Betriebsaufwand) und Datenexport via Fivetran/Airbyte. Wer maximale Portierbarkeit und echtes SQL braucht, fährt mit **Supabase** (oder **Neon + Drizzle**) besser. **Alle Preise und Limits ändern sich häufig — vor Projektstart immer auf den offiziellen Anbieterseiten (convex.dev/pricing, supabase.com/pricing, developers.cloudflare.com/r2 usw.) verifizieren.**