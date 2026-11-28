---
tags: [spec, wwww-main, wwww-threejs, webmcp, barrierefreiheit, agenten]
created: 2026-10-14
topic: 'Wie die wwww-Webseite für Agenten lesbar wird und ihre Szene über WebMCP als Werkzeuge anbietet'
verification: 'Konzept vom 2026-10-14, von Claude vorgeschlagen, nichts davon vom Nutzer bestätigt, nichts gebaut. Der Stand von WebMCP kommt aus developer.chrome.com, gelesen am 2026-10-14. Ablauf und Verlängerung des Origin Trials stammen nur aus GitHub-Issues und blink-dev.'
---

# WebMCP — wwww für Agenten öffnen

Stand 2026-10-14. **Nichts davon ist gebaut, nichts davon ist festgelegt.** Jede Zeile ist ein Vorschlag. Am 2026-11-12 an die neue Startseite angepasst (`startseite.md`).

> [!abstract] Ein Agent bekommt nichts, was ein Screenreader nicht auch bekommt
> Jedes Werkzeug ist eine Taste aus `steuerung.md`, und jede Antwort ist eine Ansage von dort. Der Inhalt steht im HTML, das ohne three.js lädt. WebMCP legt nur eine Schicht darüber, für Agenten in Chrome auf Prod.
>
> ```mermaid
> flowchart TD
>   T["Taste und Ansage<br/>aus steuerung.md"] --> W["Werkzeug<br/>WebMCP"]
>   T --> G["Guide und<br/>Screenreader"]
>   H["HTML ohne three.js<br/>Werkseiten, Schild"] --> AG[Agent]
>   W --> AG
> ```

^blick

**Grundlage:** die vier Web-Grundlagen aus dem Gespräch am 2026-10-14 (HTML, Accessibility, Performance, User Experience), `specs\wwww-threejs\steuerung.md` (Tasten, Ansagen, der Guide), `specs\wwww-main\originale.md` (Schild und Bildbeschreibung) und `zaehlen\wwww\ARCHITEKTUR.md` (drei Orte, Caddy).

---

## Der Ausgangspunkt

- **Es gibt noch keine Anwendung.** `site/index.html` ist ein roter Würfel, siehe `zaehlen\wwww\OFFEN.md`. Dieses Konzept beschreibt also, wie die Anwendung von Anfang an gebaut wird, nicht einen Umbau.
- **Für einen Agenten ist die Seite heute leer.** Der ganze Inhalt steckt im Canvas. Im HTML stehen ein Knopf „Enable Gyroscope", `lang="en"` und ein englischer Titel.
- **`steuerung.md` trägt schon das meiste.** Echte Buttons, ein `aria-live`-Feld, Regler als `<input type="range">`, das Schild als HTML. Was einem Screenreader hilft, hilft einem Browser-Agenten genauso.
- **`specs\wwww-threejs\raw\scene-tools.js` ist schon für zwei Abnehmer gebaut:** WebMCP und den eigenen Guide. Seine fünf Werkzeuge (`list_objects`, `set_color` und andere) stammen aus einer Demo und passen nicht zur Steuerung.

## Wo WebMCP überhaupt wirkt

| Ort | Wer kommt | WebMCP |
|---|---|---|
| Prod, `julianniklasheynert.xyz` | Menschen am Rechner, manche mit Chrome und einem Agenten | ja, mit Origin-Trial-Token |
| Stage, `localhost:8080` | du | ja, über `chrome://flags/#enable-webmcp-testing`, ohne Token |
| Installation, `installation.julianniklasheynert.xyz` | Handys im eigenen WLAN, ohne Internet | nein |

**An der Installation läuft kein Agent.** Ohne Internet fehlt ihm das Sprachmodell, und die Handys sind oft Safari. Die Installation profitiert nur von Teil 1 und vom Guide.

## Stand von WebMCP am 2026-10-14

| Punkt | Stand | Quelle |
|---|---|---|
| Status | vorgeschlagener Standard, Origin Trial in Chrome ab Version 149 | Chrome-Doku, Übersicht |
| Ende in Chrome | Chrome 156. Die Tokens laufen am 2026-11-17 ab. | zwei GitHub-Issues, kein Chrome-Dokument |
| Verlängerung | bis Chrome 162 beantragt am 2026-09-28, ein bedingtes LGTM, nicht bestätigt | blink-dev |
| Edge | eigener Trial bis 2027-03-30, eigener Token | Microsoft Edge Origin Trials |
| Namensraum | `document.modelContext`. `navigator.modelContext` gilt als veraltet. | Chrome-Doku; das Alias nur aus einem Blog |
| Imperativ | `registerTool(tool, { signal })`, abmelden mit `controller.abort()`. Felder: `name`, `description`, `inputSchema`, `execute`, `annotations`. | Chrome-Doku, Imperative API |
| Annotationen | `readOnlyHint`, `untrustedContentHint`, `consequentialHint` | Chrome-Doku, Imperative API und Tool Security |
| Deklarativ | `<form toolname tooldescription toolautosubmit>`, am Feld `toolparamdescription`. Im Submit-Ereignis `agentInvoked` und `respondWith()`. | Chrome-Doku, Declarative API |
| Grenzen pro Werkzeug | Name 30 Zeichen, Beschreibung 500, Parameterbeschreibung 150, Antwort 1500. Eine Empfehlung, kein Limit. | Chrome-Doku, Tool Security |
| Wer aufruft | vor allem Test-Erweiterungen: der Model Context Tool Inspector und die Beispiel-Erweiterung von Chrome. Gemini in Chrome nennt die Doku nicht. | Chrome-Doku, Übersicht |
| Gedacht für | einen Menschen, der dabeisitzt. Nicht für Crawler ohne Fenster. | Chrome-Doku, Übersicht |

**Heute ruft fast niemand die Werkzeuge auf.** Der Aufwand lohnt trotzdem, weil dieselbe Werkzeugliste den eigenen Guide trägt. Die Namen der API können sich bis zum Standard noch ändern.

---

## Teil 1 · Die Grundlagen

Diese vier gelten an allen drei Orten, auch ohne WebMCP.

### HTML

- **Der Inhalt steht im ausgelieferten HTML.** `/wwww/index.html` bekommt ein `<main>` mit `<h1>`, zwei Sätzen, was wwww ist, dem Knopf „Eintreten" und einem `<nav>`. Das Canvas kommt danach dazu.
- **Die Startseite an der Wurzel ist die Navigation aus `startseite.md`.** Ihre drei Symbole O, E und Wurst sind echte Links mit Namen. Die Ausstellung liegt seit dem 2026-11-12 unter `/wwww/`.
- **Jedes Werk bekommt eine eigene Seite `/werke/<name>/`**, als statisches HTML. Darin steht das Galerie-Schild als `<article>`, mit allen Zeilen aus `steuerung.md`, auch Bildbeschreibung und digitaler Erweiterung.
- **Von Hand geschrieben, solange es wenige Werke sind.** Ein Bauschritt kommt erst beim zweiten Mal, vor Ort wird ohnehin nicht gebaut.
- **JSON-LD auf jeder Werkseite:** `VisualArtwork` mit `creator`, `dateCreated`, `artMedium`, `width` und `height`. Dazu einmal `Person` für dich und `ExhibitionEvent` für die Installation mit Ort und Zeitraum.
- **Die Bildbeschreibung steht als Text im `<article>`**, nicht nur im JSON-LD. Sonst liest sie ein Screenreader nicht.
- `lang="de"` und ein Titel, der sagt, was die Seite ist.

### Accessibility

- **Das Canvas ist für einen Agenten eine Wand.** Mit `role="application"` steht im Accessibility-Tree nur ein leeres Element. Alles, was ein Agent ohne WebMCP erreichen soll, braucht einen Button oder Link außerhalb: „Wo bin ich?", die Regler, die Werkseiten.
- **Die Ansagen werden die Antworten der Werkzeuge.** Eine Liste von Texten, drei Abnehmer: Screenreader, Guide und Agent. Die Tabelle der Ansagen in `steuerung.md` ist damit zugleich die Liste der Werkzeug-Antworten.
- Sonst gilt `steuerung.md` unverändert.

### Performance

- **Die Auslieferung ist schon richtig.** Statische Dateien aus Caddy, `gzip`, `vendor/` mit `immutable`. Das bleibt.
- **Das HTML aus dem Abschnitt „HTML" lädt ohne three.js.** Ein Agent, der nur lesen will, wartet nicht auf `szene.glb`.
- **`robots.txt` und `sitemap.xml` nur für Prod.** Die `sitemap.xml` nennt die Werkseiten. Die Quittungen unter `/q/` nennt sie nicht.
- **Jede Quittungsseite trägt `noindex`, als Header aus dem `Caddyfile`:** `header /q/* X-Robots-Tag "noindex"`. Dort stehen Prompts eines Besuchers, die nur der Inhaber des Codes sehen soll.
- **`/q/` bleibt in `robots.txt` offen.** Sperrt `robots.txt` die Seite, liest die Suchmaschine sie nie und sieht das `noindex` nicht. Über einen Link von anderswo landet die Adresse dann trotzdem in der Suche.

### User Experience

- **Der Zustand steht in der Adresse.** `?entry=a` gibt es schon. Dazu kommen `?feld=5` und `?werk=<name>`: Die Szene startet dort, mit einem Fokusflug.
- **Jede Werkseite verlinkt „Im Raum ansehen" auf `/wwww/?werk=<name>`.** So führt ein Link von der lesbaren Seite in die Szene, für Menschen und Agenten.
- **Die Szene lädt schon vor „Eintreten".** Der Knopf startet nur Klang, Gyroskop und das Einfangen der Maus. So antworten die lesenden Werkzeuge, bevor jemand klickt.
- **Kein Cookie-Banner.** Die Seite zählt nichts und speichert nichts. Das bleibt so. Das Textfeld für Discord (`discord.md`) schickt nur ab, wenn man klickt, und setzt kein Cookie.
- „Eintreten" ist die einzige Hauptaktion der Ausstellung unter `/wwww/`. Die Startseite an der Wurzel hat drei: O, E und Wurst.

---

## Teil 2 · Die Werkzeuge

### Stufe 1 — lesen: dieselben drei wie der Guide

| Werkzeug | entspricht | Antwort | Annotation |
|---|---|---|---|
| `where_am_i` | Taste `I` | „In Feld 3 und 5, Blick auf Feld 5, Hörweite eng" | `readOnlyHint` |
| `list_fields` | Taste `N` | alle Felder mit Nummer, Abstand und Richtung | `readOnlyHint` |
| `show_sign` | Taste `O` | die Zeilen des Galerie-Schilds, mit Bildbeschreibung | `readOnlyHint`, nur wenn es das Schild nicht öffnet, siehe „Was offen ist" |

`show_sign` nimmt den Namen des Werks als `enum`, gefüllt aus den geladenen Werken. Ein lesbarer Name statt einer Nummer, sonst rät das Modell.

Die drei werden beim Laden angemeldet, in beiden Versionen, an Stage und Prod:

```js
const mc = document.modelContext ?? navigator.modelContext;    // navigator: ältere Chrome-Versionen
if (mc?.registerTool) {
  const abmelden = new AbortController();
  await mc.registerTool({
    name: 'where_am_i',
    description: 'Sagt, in welchen Klangfeldern der Besucher steht, auf welches er schaut und wie weit er hört. Vor jeder Aussage über den Standort aufrufen.',
    inputSchema: { type: 'object', properties: {} },
    annotations: { readOnlyHint: true },
    execute: async () => ansageWoBinIch(),                     // dieselbe Funktion wie Taste I
  }, { signal: abmelden.signal });
}
```

Ohne WebMCP greift die Bedingung nicht, und nichts bricht.

### Stufe 2 — schreiben: nur in Version 2

`steuerung.md` schließt schreibende Werkzeuge für den Guide aus. Die Kamerafahrt stört den Finger, und die Mischung pro Frame überschreibt jeden Wert. **Für WebMCP am Rechner trägt keiner der beiden Gründe ganz:**

- Am Rechner führt kein Finger. Wer einen Agenten fragt, fliegt nicht gleichzeitig.
- Der Modus „fest" aus `steuerung.md` löst den zweiten Grund. Ein fester Wert wird vom Fliegen nicht mehr überschrieben.

| Werkzeug | entspricht | Antwort |
|---|---|---|
| `fly_to_field` | `N`, dann `Enter` | „Bei Feld 5" |
| `send_echo` | `E` | „Echo von Feld 2" oder „Kein Echo" |
| `set_bookmark` | `B` | „Lesezeichen 2 gesetzt" |
| `set_listening_range` | `+` und `−` | „Hörweite eng" bis „Hörweite weit" |
| `set_parameter` | `1`/`2`/`3` und `F` | „Filter fest, 40 %", setzt immer „fest" |

Drei Bedingungen:

1. **Angemeldet nur in Version 2**, also mit freier Maus. `pointerlockchange` meldet die fünf an und ab. Version 1 ist barrierebeschränkt und bleibt es.
2. **Ohne gestarteten Klang antwortet jedes Werkzeug mit einem Fehler,** den das Modell weitergeben kann: „Erst ‚Eintreten' klicken. Der Klang braucht einen Klick von dir." Ein klarer Fehler lässt das Modell sich selbst korrigieren.
3. **Nacheinander, nie zwei Kamerafahrten zugleich.** `page-agent.js` macht das schon so.

`set_parameter` wartet auf die drei Parameter, offen in `steuerung.md`.

### Stufe 3 — deklarativ: erst, wenn es ein Formular gibt

Bald gibt es eins: das Textfeld für Discord. Es löst etwas aus und trägt deshalb kein `toolautosubmit`. Ein Formular mit `method="get"` darf `toolautosubmit` tragen, weil es nichts verändert. Ein Formular, das etwas auslöst, trägt es nicht. Dann klickt der Mensch selbst auf Senden.

---

## Teil 3 · Der Weg nach Prod

- **Der Token kommt aus der Anmeldung** auf `developer.chrome.com/origintrials`, für `julianniklasheynert.xyz`.
- **Er geht als HTTP-Header `Origin-Trial` aus dem `Caddyfile`, nicht ins HTML.** Der Wert steht in der `.env` als `WEBMCP_OT_TOKEN` und im `Caddyfile` als `{$WEBMCP_OT_TOKEN}`.
- **Grund:** Laut `ARCHITEKTUR.md` ist die `.env` der einzige Unterschied zwischen den Orten. Ein neuer Token ist dann eine Zeile in der `.env`, kein neues Image.
- **`docker-compose.yml` muss die Variable an den Container weiterreichen,** heute reicht sie nur `APP_BIND` an Docker selbst.
- **Edge ist optional:** ein eigener Token, ein zweiter Header.
- **Läuft der Token ab, verhält sich die Seite wie ohne WebMCP.** Die Erkennung aus Stufe 1 greift nicht, sonst ändert sich nichts.

---

## Teil 4 · Durchsetzen beim Bauen

Agenten halten sich an harte Prüfungen, an vage Prinzipien nicht. Für `zaehlen\wwww` heißt das:

| Prüfung | Werkzeug | Was es bei wwww prüft |
|---|---|---|
| Regeln in einer Datei | `zaehlen\wwww\CLAUDE.md`, neu | Keine klickbaren `div`. Jedes Feld hat ein `label`. Jede Taste aus `steuerung.md` ist ein Werkzeug oder steht in „Bewusst nicht drin". Jede Werkzeug-Antwort ist eine Ansage aus `steuerung.md`. |
| HTML | `html-validate` 11.16.2, 8,0 MB entpackt | das statische HTML aus Teil 1 |
| Rollen | `@playwright/test` 1.64.1 samt `playwright-core` 13,7 MB, dazu ein Browser, dessen Größe erst beim Installieren messbar ist | `getByRole('button', { name: 'Wo bin ich?' })`, `getByLabel('Filter')`. Findet der Test den Knopf nicht, findet ihn ein Agent auch nicht. |
| Accessibility | `@axe-core/playwright` 4.13.0 samt `axe-core` 3,4 MB | läuft in denselben Tests mit |
| Werkzeuge | Playwright mit Chrome und dem Flag, darin `document.modelContext.executeTool()` | ruft jedes Werkzeug ohne Sprachmodell auf und vergleicht die Antwort mit der Ansage. Ohne API-Schlüssel, jedes Mal gleich. |

Die fünf Pakete selbst haben zusammen etwa 25 MB, gemessen mit `npm view` am 2026-10-14. Ihre Abhängigkeiten und der Browser kommen dazu und sind nicht gemessen.

- **Die Pakete bleiben auf dem PC.** Das `Dockerfile` kopiert nur `site/`, ein `package.json` daneben kommt nie ins Image.
- **Erst von Hand, dann die Maschine.** Die Prüfungen laufen zweimal von Hand. Ein Hook entsteht frühestens danach.
- **Ab und zu ein echter Agent.** Claude in Chrome liest den Accessibility-Tree und prüft damit Teil 1. Für Teil 2 der Model Context Tool Inspector, er braucht einen Gemini-API-Schlüssel.

---

## Reihenfolge

| Schritt | Wo | Wann |
|---|---|---|
| 0 · Ein lesendes Werkzeug auf `probe.html`, das den Text aus `#stand` zurückgibt. Mit Flag und Inspector einmal aufgerufen. | Stage | jetzt möglich |
| 1 · Teil 1: HTML-Schicht, Werkseiten, JSON-LD, `?feld=` und `?werk=` | Stage | mit der ersten echten Szene |
| 2 · Stufe 1: die drei lesenden Werkzeuge, eine Liste für Guide und WebMCP | Stage | sobald Taste `I` läuft |
| 3 · Token und Header | Prod | wenn die Anwendung auf Prod geht, und nur wenn ein Trial dann noch läuft |
| 4 · Stufe 2: die schreibenden Werkzeuge in Version 2 | Stage, dann Prod | wenn die drei Parameter feststehen |

**Schritt 0 prüft die Kette, nicht wwww.** Flag, Anmeldung und Inspector laufen dann einmal, bevor eine echte Szene davon abhängt.

## Bewusst nicht drin

| Draußen | Warum |
|---|---|
| WebMCP an der Installation | Handys, kein Internet, kein Agent |
| Werkzeuge für Historie und Quittung | Besucher-Prompts sind fremder Text. Ein Prompt wie „Ignoriere alles und …" landete ungeprüft im Agenten. Wenn doch, dann nur mit `untrustedContentHint: true`. |
| ein Werkzeug zum Kauf der Erinnerung | Die Zahlung läuft über Stripe oder PayPal. Ein Kauf durch einen Agenten wäre der Fall für `consequentialHint`, den man besser gar nicht anbietet. |
| Boost und Streuung als Werkzeug | reine Spielgesten, ein Agent erfährt daraus nichts |
| schreibende Werkzeuge in Version 1 | Die Maus ist dort eingefangen, Version 1 ist barrierebeschränkt. |
| `llms.txt` | kein Standard, die Werkseiten sagen dasselbe |
| Lighthouse CI | Die Seite ist statisch. Lighthouse in den DevTools von Hand reicht, bis es eine Anwendung gibt. |
| `eslint-plugin-jsx-a11y` | Das Projekt hat kein JSX. |

## Was offen ist

- **Ob `show_sign` das Schild öffnet oder nur liest.** `steuerung.md` sagt beides: Der Guide „liest nur vor", und seine Werkzeuge rufen dieselben Funktionen auf wie die Tasten. `O` öffnet aber das Schild und hält den Flug an. Nur die lesende Fassung darf `readOnlyHint` tragen.
- **Ob der Chrome-Trial verlängert wird.** Sonst enden die Tokens am 2026-11-17, lange bevor es eine Anwendung gibt.
- **Ob ein Werkzeug-Aufruf als Nutzergeste zählt.** Davon hängt ab, ob ein Agent den Klang selbst starten kann. Keine Doku sagt es.
- **Ob der Trial auf Chrome für Android greift.** Keine gelesene Quelle sagt es.
- **Wie Caddy einen leeren Wert für `{$WEBMCP_OT_TOKEN}` behandelt,** an Stage und Installation. Dort steht kein Token.
- **Wie Playwright das Flag `enable-webmcp-testing` setzt.** Ungeprüft.
- **Ob Claude in Chrome WebMCP-Werkzeuge aufruft.** Ungeprüft.
- **Die drei Parameter,** offen in `steuerung.md`. Sie blockieren `set_parameter`.
- **Ob der Guide offline über die Prompt API laufen kann.** Chrome bietet `chrome://flags/#prompt-api-tool-use`: ein Modell im Browser ruft Werkzeuge auf. Das ginge nur in Chrome am Rechner, nicht auf den Handys. Berührt die offene Frage aus `steuerung.md`, ob der Guide ohne Internet laufen muss.

## Quellen

| Quelle | Was | gelesen |
|---|---|---|
| `developer.chrome.com/docs/ai/webmcp` | Status, Flag, Permissions Policy `tools`, Test-Erweiterungen; aktualisiert 2026-10-07 | 2026-10-14 |
| `developer.chrome.com/docs/ai/webmcp/imperative-api` | `registerTool`, Annotationen, `getTools`, `executeTool`; aktualisiert 2026-09-21 | 2026-10-14 |
| `developer.chrome.com/docs/ai/webmcp/declarative-api` | Formular-Attribute, `agentInvoked`, `respondWith`; aktualisiert 2026-09-25 | 2026-10-14 |
| `developer.chrome.com/docs/ai/webmcp/secure-tools` | Annotationen, Prompt Injection, Zeichengrenzen; aktualisiert 2026-09-01 | 2026-10-14 |
| `developer.chrome.com/docs/ai/webmcp/best-practices` | ein Zweck pro Werkzeug, an- und abmelden nach Zustand, klare Fehler | 2026-10-14 |
| `github.com/assistant-ui/assistant-ui/issues/7652` | Token läuft am 2026-11-17 ab | 2026-10-14, nur Suchergebnis |
| `mail-archive.com/blink-dev@chromium.org/msg17572.html` | Intent to Extend bis Chrome 162, bedingtes LGTM vom 2026-09-28 | 2026-10-14 |
| `developer.microsoft.com/en-us/microsoft-edge/origin-trials` | Edge-Trial bis 2027-03-30 | 2026-10-14, nur Suchergebnis |
| `modelpiper.com/blog/webmcp-chrome-api-migration-mocked-tests` | `navigator.modelContext` als veraltetes Alias | 2026-10-14, nur Suchergebnis |
| `developers.google.com/search/docs/crawling-indexing/block-indexing` | `noindex` wirkt nur, wenn `robots.txt` die Seite nicht sperrt; `X-Robots-Tag` als Header | 2026-10-14 |
