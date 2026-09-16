---
tags: [claude-note, curated]
created: 2026-08-11
topic: Wenn die Arbeit auf einem anderen Rechner liegt — Netz, HTTPS, Terminal-Transport und Editor als vier getrennte Fragen
verification: extern — Fremd-Tools (Tailscale, Caddy, Mosh, Zed) und Browser-Verhalten, kein smithy-Bezug, per Hand
---

# Der Remote-Dev-Stack: fünf Fragen, fünf Werkzeuge

**Jedes Werkzeug in diesem Stack beantwortet genau eine Frage, und keins kann für ein anderes einspringen.** Das ist der ganze Trick. Wer Tailscale installiert und sich wundert, dass die Kamera im Browser weiterhin fehlt, hat zwei Fragen zusammengeworfen.

| Frage | Werkzeug | Was ohne es passiert |
|---|---|---|
| Wie finden sich die Geräte? | Tailscale | Du brauchst Port-Forwarding im Router, oder es geht gar nicht. |
| Wie überlebt das Terminal einen Netzwechsel? | Mosh | Verbindung reißt beim Zuklappen ab, du tippst `ssh` neu. |
| Wie überlebt der **Prozess** die Trennung? | tmux / herdr | Der Agent stirbt mit der Verbindung, egal welcher Transport. |
| Wie kommt der Browser mit HTTPS an die App? | Tailscale Serve **oder** Caddy | Halbe Web-Plattform fehlt, siehe unten. |
| Wie bearbeitest du die Dateien? | Zed Remote / VS Code Remote-SSH | Terminal-Editor, oder Dateien hin- und herkopieren. |

**Für diesen Vault gilt vorweg die Einordnung:** wer nur *Claude* von unterwegs erreichen will, braucht von diesem Stack **nichts**. Remote Control arbeitet ausgehend und kommt hinter jedem Router durch — Details in [[remote-session-access]]. Der Stack hier lohnt ab dem Moment, in dem du die **gebaute Anwendung** im Browser testen willst, besonders vom Handy.

## Warum HTTPS auch lokal — und warum der Fehler nicht wie einer aussieht

Browser teilen jeden Zugriff in **Secure Context** und **Insecure Context**. In einem unsicheren Kontext sperren sie einen großen Teil der Web-Plattform.

`http://localhost` ist die Ausnahme: der Browser behandelt es als sicher, obwohl kein TLS beteiligt ist. Dieselbe Ausnahme gilt für `127.0.0.1` und `[::1]` — **nicht** für die LAN-IP desselben Rechners.

Genau daran zerbricht Remote-Entwicklung. Sobald der Code auf einem anderen Rechner läuft oder du vom Handy zugreifst, tippst du nicht mehr `localhost`, sondern `http://192.168.1.50:3000` oder `http://mini.local:3000`. Die Ausnahme greift nicht mehr, und der Browser schaltet ab:

- **Kamera und Mikrofon** — `navigator.mediaDevices`
- **Standort** — `navigator.geolocation`
- **Hardware** — Web Bluetooth, WebUSB, WebHID, Web Serial
- **Service Worker** — damit jede PWA und jede Offline-Funktion
- **Cookies** — `Secure`-Cookies lassen sich nicht setzen, `SameSite=None` wird verworfen (Safari am striktesten)

**Der teure Teil ist nicht die Sperre, sondern ihre Form.** Der Browser wirft keinen Netzwerkfehler und keine Warnung in die Konsole. `navigator.mediaDevices` ist schlicht `undefined`. Das liest sich wie ein Bug im eigenen Code, und man sucht ihn dort — stundenlang. Dieselbe Falle wie überall in diesem Vault: **eine Abwesenheit, die nicht als Abwesenheit lesbar ist, sieht von unten aus wie ein eigener Fehler.**

Praktische Folge: Wenn eine App auf dem Entwicklungsrechner geht und auf dem Handy nicht, ist HTTPS die **erste** Hypothese, nicht die fünfte.

## Die drei Wege zu HTTPS — der einfachste zuerst

### Weg A — `tailscale serve`, kein Caddy, keine eigene Domain

Tailscale stellt selbst gültige Zertifikate aus, auf dem Tailnet-Namen des Geräts (`<gerät>.<tailnet>.ts.net`). Ein Befehl pro App, kein Reverse Proxy, kein DNS-Anbieter, keine Konfigurationsdatei.

**Nimm diesen Weg, solange du eine oder zwei Apps hast.** Er löst das Secure-Context-Problem vollständig, und alles, was Weg B und C zusätzlich können, brauchst du in dem Fall nicht.

Bedingungen: HTTPS-Zertifikate müssen im Tailnet einmalig freigeschaltet sein, und die App ist nur **innerhalb** deines Tailnets erreichbar. Öffentlich wäre `tailscale funnel` — derselbe Port kann nie beides gleichzeitig sein.

Die genaue Syntax gegen `tailscale serve --help` prüfen, nicht aus einer Notiz übernehmen. Sie hat sich zwischen Versionen bereits geändert.

### Weg B — Caddy mit Tailscale-Zertifikaten

Caddy als **Reverse Proxy** davor, aber die Zertifikate kommen weiter von Tailscale. Für `*.ts.net`-Namen tut Caddy das von allein: es verwaltet diese Domains nicht per ACME, sondern holt das Zertifikat beim Handshake vom lokalen Tailscale-Dienst. Trägt der Site-Block nicht den vollen Namen, sagt man es explizit mit `get_certificate tailscale`.

**Nimm diesen Weg, wenn mehrere Apps auf einen Namen sollen** — Pfad-Routing, gemeinsame Header, ein Einstiegspunkt.

Eine Stolperstelle: Caddy braucht Zugriff auf den Tailscale-Socket. Entweder läuft es als `root`, oder der Caddy-Benutzer bekommt den Socket freigegeben. Letzteres ist das richtige.

### Weg C — Caddy mit eigener Domain

Das ist der Weg aus dem Ausgangsmaterial (`ai.robo.online` → `localhost:3000`). Er funktioniert, hat aber eine Bedingung, die dort fehlt.

```caddy
ai.robo.online {
    reverse_proxy localhost:3000
}
```

**Caddys Standard-Weg zum Zertifikat scheitert hier.** Die HTTP- und die TLS-ALPN-Challenge verlangen beide, dass Let's Encrypt den Server von außen auf Port 80 bzw. 443 erreicht. Genau das verhindert Tailscale ja — kein Port-Forwarding ist der halbe Zweck der Übung. Es bleibt die **DNS-Challenge**: Caddy setzt einen TXT-Eintrag bei deinem DNS-Anbieter, wofür es dessen API-Zugangsdaten und ein passendes Caddy-Plugin braucht. Kein Port muss offen sein.

Nimm Weg C nur, wenn du die eigene Domain wirklich brauchst — etwa weil ein OAuth-Rückruf oder ein Webhook auf einen festen Namen zeigt.

**Die dritte Möglichkeit ist eine Falle:** Caddy stellt für interne Namen auch Zertifikate aus seiner eigenen CA aus. Die kennt kein Gerät, und der Zertifikatsspeicher eines iPhones lässt sich nicht mal eben erweitern. Für Handy-Tests unbrauchbar.

## Die Werkzeuge einzeln

### Tailscale — das Netz

Ein **Mesh-VPN** auf WireGuard-Basis. Statt allen Verkehr über einen zentralen Server zu leiten, verbindet es deine Geräte direkt miteinander. Stehen Laptop und Server im selben Raum, fließen die Daten lokal.

- **Kein offener Port am Router.** Beide Seiten bauen ausgehend auf, das Loch im Router entsteht nie.
- **MagicDNS** vergibt feste Namen (`mini`, `laptop`, `vps`) statt wechselnder IP-Adressen.
- **Was extern bleibt:** der Koordinationsdienst von Tailscale. Er authentifiziert die Geräte und vermittelt, wie sie einander finden. Deine Nutzdaten laufen nicht darüber — außer wenn keine direkte Verbindung zustande kommt, dann fällt Tailscale auf einen Relay zurück.

### Mosh — der Terminal-Transport

SSH bricht ab, wenn die TCP-Verbindung stirbt: Netzwechsel, Deckel zu, Funkloch. Mosh setzt stattdessen auf UDP und synchronisiert den Terminal-Zustand statt eines Byte-Stroms.

- **Roaming**: WLAN → Mobilfunk → aufgeklappt nach vier Stunden. Die Sitzung ist sofort wieder da.
- **Local Echo**: Mosh sagt deine Tastenanschläge voraus und zeigt sie, bevor der Server antwortet. Bei hoher Latenz ist das der Unterschied zwischen erträglich und unbenutzbar.

**Mosh ersetzt tmux nicht — es braucht tmux.** Zwei unabhängige Gründe:

1. **Mosh synchronisiert nur den sichtbaren Bildschirm.** Es gibt kein Scrollback. Ohne Multiplexer ist alles, was aus dem Bild gelaufen ist, weg.
2. **Mosh hält die Verbindung, nicht den Prozess.** Ein Server-Neustart oder ein beendeter Mosh-Client nimmt die Shell mit. Was `tmux` und `herdr` leisten, leistet Mosh an keiner Stelle.

Betriebsdaten: Der Server braucht `mosh-server` installiert; der Login läuft weiterhin über SSH. Mosh belegt danach einen UDP-Port aus dem Bereich 60000–61000. Innerhalb eines Tailnets ist der ohne weiteres offen, in einer Cloud-Firewall muss er freigegeben werden.

### Caddy — der Reverse Proxy

Ein Entwicklungsserver trägt selten eine App. Vite auf 3000, ein API-Server auf 4000, eine Datenbank-Oberfläche auf 8080. Caddy nimmt 80 und 443 entgegen und verteilt nach Subdomain oder Pfad an den richtigen internen Port.

Der eigentliche Grund für Caddy statt nginx ist die Kürze der Konfiguration. Drei Zeilen pro Dienst, und weil die Syntax so regelmäßig ist, schreiben Sprachmodelle sie zuverlässig — was bei nginx-Konfigurationen erkennbar nicht der Fall ist.

### Zed — der Editor

Nativ in Rust, GPU-beschleunigt, nicht auf Electron. Stabil seit 1.0 (2026-04-29), Windows-Version seit Oktober 2025 stabil.

Beim Remote-Editing installiert Zed einen kleinen Hintergrundprozess auf dem Server. Der liest das Dateisystem und betreibt die Sprachserver; dein Gerät rendert nur. Es gibt Remoting über SSH, in WSL und in Dev-Container.

Wichtig für die Einordnung: **Zed Remote läuft über SSH, nicht über Mosh.** Der Editor gewinnt von Mosh nichts. Mosh ist ausschließlich für die Terminal-Hälfte da.

## Wer trägt was

**Lokales Gerät** — Laptop, Tablet, Handy. Nur Anzeige: Editor-Oberfläche, Terminal-Programm, Browser, Tailscale-Client. Kein `node_modules`, keine Datenbank, kein Compiler. Deshalb bleibt der Akku am Leben.

**Remote-Server** — VPS oder ein Rechner zu Hause. Hier liegt alles: Quellcode, Git-Repositories, `.env`-Dateien, Build-Artefakte. Hier laufen `mosh-server`, der Multiplexer, die KI-Agenten, Zeds Hintergrundprozess, Caddy, die Entwicklungsserver, und die kopflosen Browser für Playwright oder Puppeteer.

**Extern** — drei Abhängigkeiten bleiben, auch wenn das Setup auf Eigenbesitz zielt: Tailscales Koordinationsdienst (Authentifizierung und Vermittlung), die KI-APIs, die deine Agenten anrufen, und dein DNS-Registrar, falls du Weg C nimmst.

## Was auf dieser Maschine anders ist

Das Ausgangsmaterial denkt einen Mac Mini als Server und einen Mac als Client. Dieser Vault liegt auf Windows 11, und der geplante Server ist ein Linux-VPS ([[remote-session-access]], Weg 2). Drei Unterschiede:

| Werkzeug | Auf Windows |
|---|---|
| **Mosh** | **Kein nativer Client.** Es gibt ihn nur über WSL (`wsl mosh nutzer@server`) oder Cygwin. Die früher empfohlene Chrome-Erweiterung ist mit Chrome Apps gestorben. |
| **Zed** | Läuft nativ, stabil seit Oktober 2025. Der Funktionsumfang liegt weiter etwas hinter der Mac-Version. |
| **Tailscale, Caddy** | Laufen beide nativ. Auf dem Server sowieso, dort ist es Linux. |

**Prüfe vor dem Aufbau, ob dich der Mosh-Umweg stört.** Am 2026-08-11 ist keins der vier Werkzeuge auf dieser Maschine installiert — geprüft über `Get-Command`. Auf der Client-Seite ist Mosh der einzige, der Reibung macht; wenn der WSL-Umweg nervt, ist ein SSH-Client mit `tmux` dahinter der billigere Anfang, und Mosh kommt später dazu.

## Verhältnis zu [[remote-session-access]]

Die beiden Notizen überschneiden sich, aber die Trennlinie ist scharf:

| | [[remote-session-access]] | diese Notiz |
|---|---|---|
| Frage | Wie erreiche ich den laufenden **Claude-Prozess**? | Wie erreiche ich die **gebaute Anwendung** und die Dateien? |
| Antwort ohne Stack | Remote Control genügt, ausgehend, kein Port | geht nicht, HTTPS fehlt |
| Neu hier | — | Browser-Zugriff, Editor, Secure Contexts |

**Zwei Kollisionen aus der anderen Notiz gelten hier weiter.** Remote Control verlangt, dass `ANTHROPIC_BASE_URL` auf `api.anthropic.com` zeigt — der lokale Proxy aus [[codex-subscription-via-cliproxyapi]] schließt es aus. Und ein Token aus `claude setup-token` trägt Remote Control nicht. An diesem Stack ändert sich dadurch nichts: Tailscale, Caddy und Mosh sind von beidem unberührt.

## Was übernommen und was geprüft ist

Am 2026-08-11 gegen die Herstellerdokumentation geprüft und **korrigiert** gegenüber der Vorlage:

| Vorlage sagte | Tatsächlich |
|---|---|
| Caddy kümmert sich „völlig selbstständig" um Zertifikate | Nur bei öffentlich erreichbarem Server. Hinter Tailscale braucht es die DNS-Challenge oder Tailscales eigene Zertifikate. |
| Caddy + Tailscale sind für HTTPS beide nötig | `tailscale serve` reicht allein, wenn eine Domain genügt. |
| Mosh schützt laufende Skripte und `tmux` | Mosh schützt die **Verbindung**. Der Prozess überlebt durch `tmux`, nicht durch Mosh. Ohne Multiplexer gibt es zusätzlich kein Scrollback. |

Nicht selbst gemessen, weil weder Server noch Tailnet existieren: der tatsächliche Aufbau, die Latenz und die Frage, ob `tailscale serve` mit Vite-Hot-Reload über WebSockets reibungslos läuft. Der erste Aufbau ist der Test.
