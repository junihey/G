---
tags: [claude-note, curated]
created: 2026-09-08
topic: Warum eine Anwendung mit three.js, RNBO und Besucher-Handys drei Orte braucht statt zwei — und woran der dritte scheitert, wenn man ihn wie den zweiten behandelt
verification: extern, in Teilen gemessen — Stage, Prod und der Aufbau mit dem Slate AX sind am Gerät geprüft (2026-09-09 bis 2026-09-11); offen bleiben mehrere Router nebeneinander, das Captive-Portal-Fenster und RNBO
---

# Drei Orte, nicht zwei

**Stage und Prod sind die falsche Zweiteilung für dieses Projekt.** Es gibt einen dritten Ort, und er hat die härtesten Bedingungen von allen: die Installation vor Ort, ohne Internet, mit fremden Handys als Endgeräten.

| Ort | Läuft wo | Wer greift zu | Netz |
|---|---|---|---|
| **Stage** | dieser PC, Docker Desktop | du | egal |
| **Prod** | IONOS-VPS | das Internet | öffentlich, HTTPS über den Proxy |
| **Installation** | Rechner vor Ort | Besucher-Handys | mehrere GL.iNet-Router am Switch, **kein Internet** |

Wer nur Stage und Prod denkt, baut die Installation als „Prod ohne Domain" — und stellt am Aufbautag fest, dass die halbe Anwendung nicht startet.

## Was auf jedem Ort gleich bleibt

**Dieselbe `docker-compose.yml`, dasselbe Image, dieselbe Datenbank-Version.** Das ist die einzige Regel, die verhindert, dass drei Orte drei Anwendungen werden.

Was sich unterscheiden darf, sind genau drei Dinge, und sie stehen in einer `.env`:

- der Hostname, unter dem die App erreichbar ist
- die Zugangsdaten der Datenbank
- der Weg zum Zertifikat

Alles andere ist gleich, oder die Installation ist kein Abbild von Prod mehr.

**Die `.env` gehört nicht ins Git, die `.env.example` schon.** Sie trägt alle Schlüssel mit leeren Werten und ist damit die Checkliste. Ohne sie suchst du vor Publikum nach einer Variable, die auf dem PC gesetzt war und im Bündel fehlt.

## Die Bedingung, an der der dritte Ort hängt

**Ohne HTTPS sperrt der Browser die Sensoren.** Das Rohmaterial verlangt „Reaktion auf Handy- und Kamera-Sensorik" und eine Gestensteuerung mit sechs bis acht Achsen. Dahinter stehen `DeviceMotionEvent` und `DeviceOrientationEvent`, auf iOS zusätzlich `requestPermission()` — das gibt es **nur im Secure Context**.

Dieselbe Sperre trifft Kamera und Mikrofon, Service Worker und damit jede Offline-Fähigkeit. `http://localhost` ist die Ausnahme, die der Browser gelten lässt; eine Adresse wie `http://192.168.1.50:3000` ist es **nicht** — Einzelheiten in [[remote-dev-stack]].

**Ein Proxy, der `http` weiterhin bedient, hebelt das Zertifikat aus.** Wer den Namen in die Adresszeile tippt, landet oft zuerst auf `http`; antwortet der Proxy dort mit der Seite statt mit einer Weiterleitung, ist sie kein Secure Context — trotz gültigem Zertifikat einen Klick daneben. Im Nginx Proxy Manager heißt der Schalter *Force SSL*, bei Caddy erledigt es der `redir`-Block. Geprüft ist es in einer Zeile: `curl -o /dev/null -w "%{http_code}" http://<name>/` muss 301 sagen, nicht 200.

**Der teure Teil ist nicht die Sperre, sondern ihre Form.** `DeviceMotionEvent` ist im unsicheren Kontext schlicht nicht da. Der Browser meldet keinen Fehler. Es sieht aus wie ein Bug im eigenen Code, und man sucht ihn dort — am Aufbautag, mit Publikum in zwei Stunden.

### Was daraus folgt

**Die Installation braucht ein echtes Zertifikat, und zwar ohne Internet zur Laufzeit.** Drei Wege, zwei davon Sackgassen:

| Weg | Trägt er? |
|---|---|
| Eigene CA, Wurzelzertifikat auf jedem Gerät | **Nein.** Fremde Besucher installieren so etwas nicht, und auf iOS ist es mehrstufig. |
| `.local` per mDNS | **Nein.** Kein Secure Context, die Sperre bleibt. |
| Echtes Zertifikat per DNS-Challenge, lokal ausgeliefert | **Ja**, mit zwei Bedingungen. |

Der dritte Weg im Einzelnen:

1. Ein Zertifikat für einen eigenen Namen, etwa `installation.julianniklasheynert.xyz`, per **DNS-Challenge** ausgestellt. Die braucht keinen offenen Port und keinen erreichbaren Server, nur einen TXT-Eintrag beim Registrar. **Internet nur zum Ausstellen, nicht zum Betrieb.**
2. Der Rechner vor Ort liefert dieses Zertifikat aus.
3. **Erste Bedingung:** Die Handys müssen den Namen auf die lokale Adresse auflösen. Ohne Internet gibt es keinen öffentlichen DNS.
4. **Zweite Bedingung:** Die Besucher müssen die Seite in ihrem richtigen Browser öffnen, nicht im Captive-Portal-Fenster. Dazu unten mehr.
5. Das Zertifikat gilt 90 Tage. **Vor jedem Aufbau erneuern**, an einem Ort mit Internet.

Punkt 3 ist der, den man vergisst. Punkt 5 ist der, der beim zweiten Mal weh tut.

**Und Punkt 1 hat eine Falle, die nichts mit DNS zu tun hat.** Läuft der ACME-Client in Docker Desktop unter Windows, wartet er auf eine Verbreitung, die er nie zu sehen bekommt — der Befehl mit dem Flag dagegen steht in `zaehlen\wwww\README.md`.

### Der DNS gehört auf die Router, nicht auf den PC

**Das ist die bequemste Stelle der ganzen Installation, und man übersieht sie leicht.** Die Hotspots sind GL.iNet-Router mit OpenWrt, und OpenWrt hat `dnsmasq` als DHCP- **und** DNS-Server bereits an Bord. Eine Zeile pro Router genügt:

```
address=/installation.julianniklasheynert.xyz/192.168.8.2
```

Damit verschwindet die Sorge, ob ein Router einen fremden DNS-Server per DHCP verteilt — der Router *ist* der DNS-Server. Ein eigener `dnsmasq` auf dem Installationsrechner wird überflüssig.

### Das Captive-Portal-Fenster ist kein Browser

**Hier liegt der Blocker, den das Hotspot-Konzept noch nicht kennt.** Der Bildschirm, der nach dem WLAN-Beitritt aufspringt, ist auf iOS der *Captive Network Assistant* und auf Android eine eingeschränkte WebView. Es ist nicht Safari und nicht Chrome. `DeviceOrientationEvent.requestPermission()` gibt es dort nicht, WebGL ist nicht zugesichert, und die Sitzung endet, sobald das Fenster schließt.

Daraus folgen zwei Regeln:

- **Das Portal zeigt einen Satz und einen Link, nicht die Anwendung.** Der Besucher tippt den Link an, das Handy öffnet den richtigen Browser, dort läuft alles.
- **Der Link trägt den Namen, nicht die IP.** `https://installation.julianniklasheynert.xyz/?entry=a`, niemals `http://192.168.1.50/?entry=a` — sonst greift genau die Sperre von oben.

**Und die Absenderadresse trägt die Zuordnung nicht.** Am 2026-09-11 gemessen: Anfragen aus drei getrennten WLANs kamen beim Server alle als dieselbe Adresse an. Docker Desktop unter Windows schiebt einen eigenen Vermittler zwischen Netzwerkkarte und Container und verliert dabei den Absender — vor jedem `X-Forwarded-For`, das ein Reverse Proxy setzen könnte. Unter Linux bliebe sie erhalten, aber eine Lösung, die am Betriebssystem des Installationsrechners hängt, ist keine.

**Der Standort gehört deshalb in die Adresszeile.** Der Router weiß, aus welchem seiner Netze eine Anfrage kam, und beantwortet die Erreichbarkeitsprüfung des Handys pro Netz mit einer anderen Weiterleitung — `…/?entry=a`, `…/?entry=b`, `…/?entry=c`. Die Seite liest den Wert aus der Adresse, und kein Vermittler dazwischen kann ihn verlieren.

**Das fällt mit dem Portal-Problem zusammen, statt es zu verschärfen.** Ein Wegweiser ist ohnehin nötig, weil die Anwendung im Portal-Fenster nicht laufen kann — und ein Wegweiser kann sagen, wo er steht. Wie das eingerichtet wird: `learning\openwrt\was-der-router-macht.md`, Abschnitt 14.

## Was die Gleichheit der drei Orte garantiert

**Zwei Mechanismen, nicht einer, und sie sichern Verschiedenes.**

**Git sichert den Quellcode.** Eine Wahrheit, drei Kopien. Auf dem VPS wird keine Datei bearbeitet — wer das tut, hat still vier Orte statt drei.

**Das Image sichert das Ergebnis.** Denn `--build` ist kein Kopieren, sondern ein Kochen: `FROM caddy:2.10-alpine` zeigt in drei Wochen auf ein anderes Image, `apk add` liest einen Paketindex, der sich täglich bewegt. Gleicher Commit, zwei Rechner, zwei Tage — zwei Images.

Ob wirklich dasselbe läuft, sagt eine Zahl, auf jeder Maschine dieselbe:

```bash
docker image inspect --format '{{.Id}}' wwww:0.2.0
```

Ungleicher Hash bei gleichem Tag heißt: irgendwo wurde nachgebaut, und du hast zwei Anwendungen.

**Symlinks lösen das nicht.** Sie funktionieren innerhalb eines Dateisystems, und die drei Orte sind drei Rechner. Dazu folgt Docker keinen Symlinks aus dem Build-Kontext heraus, und unter Windows sind Git-Symlinks Sonderarbeit. Selbst wenn es ginge, garantierte ein Symlink nur, dass zwei *Pfade* gleich sind — nicht, dass zwei *Rechner* dasselbe ausführen.

## Der Weg von Stage nach Prod — zwei Stufen

**Stufe 1, solange es zwei Orte gibt.** Der VPS holt den Quellcode und baut.

```bash
cd /opt/dienste/<app> && git pull && docker compose up -d --build
```

Das ist der erste Weg, und er soll der erste bleiben. Der Bau ist nicht bitgenau derselbe wie deiner, aber das kostet nichts: du siehst beim Ausrollen zu, und ein Fehlschlag ist ein `git push` entfernt.

**Stufe 2, sobald das erste Bündel gepackt wird.** Ab hier bricht Stufe 1 die Gleichheit, denn das Bündel entsteht Tage vor dem Aufbau, und vor Ort gibt es keinen zweiten Versuch.

```bash
docker build -t wwww:0.2.0 .        # einmal, auf dem PC
docker save wwww:0.2.0 -o wwww-0.2.0.tar
scp wwww-0.2.0.tar ionos:~/         # dieselbe Datei nach Prod
cp  wwww-0.2.0.tar buendel/         # dieselbe Datei ins Bündel
```

Auf beiden Zielen dann `docker load -i` und `docker compose up -d` **ohne** `--build`.

**Der Wechsel kostet später fast nichts, wenn eine Zeile heute schon steht.** In der compose-Datei steht `image: wwww:0.1.0` neben `build: .`. Damit nimmt Compose ohne `--build` das vorhandene Image — der Umstieg ist ein weggelassenes Flag, kein Umbau.

**Warum nicht sofort Stufe 2.** Nicht wegen der Megabyte. Der Grund ist, dass Stufe 2 einen Vorbereitungsschritt hat, den heute niemand prüft: Bei Stufe 1 ist der Beweis die laufende Prod-Seite. Bei Stufe 2 baust du ein Artefakt und musst glauben, dass es das richtige ist — der Beweis kommt erst beim Laden auf der zweiten Maschine. Solange es die zweite Maschine nicht gibt, testest du den Transport gegen niemanden. Dazu kommt eine zweite Buchhaltung: welches Tag liegt auf Prod, welches im Bündel, welches hier. Bei einem Entwickler und einem Server beantwortet `git log` das heute allein.

Und der ehrlichste Grund: **Du weißt noch nicht, was ins Bündel muss.** Es gibt kein RNBO, keine Datenbank, keinen Anwendungsserver. Ein Bündelverfahren, das jetzt festgeschrieben wird, ist für eine Anwendung geschrieben, die es nicht gibt. Beim ersten Bündel von Hand merkst du, was fehlt — und genau dafür steht die Vault-Regel *erst der Lauf von Hand, dann die Maschine*.

**Was nicht über git geht:** die `.env` mit den Zugangsdaten und der Inhalt der Datenbank. Erstere wird einmal von Hand hinterlegt, letzterer gehört ins Backup und nicht ins Deployment.

## Der Weg von Prod zur Installation

Hier trägt git **nicht**, weil vor Ort kein Internet ist: kein `git pull`, kein `docker pull`, kein `npm install`.

**Was mitfährt, ist ein Bündel:**

| Teil | Womit |
|---|---|
| Die Images | `docker save`, vor Ort `docker load` |
| Die compose-Datei und die `.env` | mitkopiert |
| Der Datenbestand | ein Dump, wie im Backup |
| Das Zertifikat | vorher geholt, siehe oben |

**Das ist derselbe Mechanismus wie die Sicherung.** `/cast` packt genau diese Teile, und `docker save` steckt schon darin, weil eine gepinnte Version aus einer Registry verschwinden kann. Ein Bündel für den Notfall und ein Bündel für den Aufbau sind dasselbe Bündel — kein Zufall, sondern der Grund, warum es sich lohnt, den Transport einmal richtig zu bauen.

**Auch fremde Bibliotheken fahren mit.** `threejs.html` lud three.js von `unpkg.com`; ohne Internet bleibt der Bildschirm schwarz. Alles, was der Browser nachlädt, liegt im Image.

## Claude Code auf dem VPS

Er läuft dort seit dem 2026-09-08. Drei Aufgaben rechtfertigen ihn, und keine davon ist Entwicklung:

- **Lange Läufe**, die den PC nicht brauchen. In `tmux` gestartet, überleben sie das Schließen der Verbindung.
- **Fehlersuche in Prod**, wo die Logs und die Datenbank liegen.
- **Zugriff von unterwegs**, über Remote Control — ohne SSH-Client, ohne offenen Port.

**Entwickelt wird trotzdem lokal.** Der VPS trägt keine Stage: Ein Fehlversuch dort trifft die laufende Anwendung, und die Rückmeldung ist langsamer als ein `docker compose up` auf dem eigenen Rechner.

## Was nicht gebraucht wird

Nur die Fälle, in denen wirklich eine Entscheidung fällt.

**Tailscale — nein, vorerst.** Es löst zwei Probleme: Erreichbarkeit hinter einem Router und ein privates Netz zwischen Geräten. Der VPS hat eine öffentliche Adresse, SSH ist per Schlüssel gehärtet. Die Installation soll ausdrücklich **ohne** Internet laufen, dort wäre es sogar hinderlich. Es bleibt Kandidat für genau einen Fall: Fernwartung des Installationsrechners, wenn er zwischen zwei Aufbauten am Netz hängt.

**Mosh — nein.** Es hält eine Terminalsitzung über Netzwechsel hinweg. Auf Windows gibt es keinen nativen Client, nur den Umweg über WSL. Und das Problem, das es löst, löst Remote Control besser: Der Prozess läuft in `tmux` weiter, und das Fenster kommt aus der App statt aus einem Terminal.

**Zed — nein.** Ein guter Editor, aber du arbeitest mit VS Code und Obsidian. Ein Wechsel ohne Anlass kostet Einarbeitung und bringt nichts, was VS Code Remote-SSH nicht kann.

**herdr auf dem VPS — nein, lokal ja.** herdr betreibt mehrere Agenten-Sitzungen nebeneinander; das ist Entwicklungsarbeit und findet auf dem PC statt. Auf dem VPS läuft eine Sitzung für lange Läufe, und dafür ist `tmux` das kleinere Werkzeug.

**systemd für die Anwendung — nein.** Docker startet Container nach einem Neustart selbst, wenn `restart: unless-stopped` gesetzt ist. Eine Unit-Datei daneben wäre ein zweiter Ort, an dem steht, was laufen soll. systemd bleibt für das, was nicht in Docker läuft — code-server ist so ein Fall.

**Caddy statt Nginx Proxy Manager — auf dem VPS nein, für die Installation ja.** Die einzige Stelle, an der beide gleichzeitig richtig sind.

Der Proxy Manager **kann** DNS-Challenge: In der Oberfläche wählt man einen Provider, hinterlegt die API-Zugangsdaten, und certbot legt den TXT-Eintrag. Das Zertifikat liegt danach als Datei unter `/etc/letsencrypt/live/`, nicht in der Datenbank. Vor Ort würde er also laufen. Der Grund gegen ihn ist ein anderer:

| | Nginx Proxy Manager | Caddy |
|---|---|---|
| Erneuern alle 90 Tage | Rechner ans Netz bringen, hochfahren, Oberfläche öffnen, einloggen, Host suchen, Renew klicken, Volumes neu sichern | zwei Dateien an irgendeinem Rechner holen, ins Bündel legen, vor Ort `docker compose restart` |
| Die SSD stirbt vorm Aufbau | Backup einer SQLite-Datei nötig; fehlt es, klickst du unter Zeitdruck neu zusammen | `git clone`, `docker compose up` |
| „Was war letztes Mal anders?" | ein Klumpen Binärdaten | ein Diff |

**Der Gegensatz ist nicht Caddy gegen NPM, sondern Konfiguration als Datei im Git gegen Konfiguration als Datenbankzustand.** Reines nginx täte es auch — nur schreibst du dann dreißig Zeilen statt drei.

**Und Caddys ACME wird vor Ort abgeschaltet, nicht genutzt.** Ohne Internet fragte Caddy beim Start vergeblich bei Let's Encrypt an. Die `tls`-Zeile mit zwei expliziten Pfaden verhindert das — für diesen Host rührt Caddy ACME nicht an und nimmt die Dateien. Du benutzt Caddy hier also nicht wegen ACME, sondern trotz ACME.

## Was gemessen ist, und was nicht

**Gemessen am 2026-09-09**, in einem Docker-Netz ohne Internet — ein Container darin erreichte Let's Encrypt nachweislich nicht:

| Was | Ergebnis |
|---|---|
| Zertifikat per DNS-Challenge bei IONOS | da, gültig bis 2026-12-08 |
| Caddy-Start ohne Netz | nach 4 Sekunden bereit — die Sorge um OCSP-Timeouts trifft nicht zu |
| ACME im Caddy-Log | keine Zeile. Die `tls`-Zeile mit expliziten Pfaden hält, was sie soll. |
| Abruf unter dem echten Namen, ohne Internet | `HTTP 200`, Zertifikatskette vom Client akzeptiert |
| Standort → Eintrittspunkt, über das Portal | drei WLANs, drei Buchstaben, jeder kam richtig an (2026-09-11) |

Damit steht der Kern der Installation: **echtes Zertifikat, lokal ausgeliefert, ohne Internet zur Laufzeit.**

**Und am 2026-09-11 der dritte Ort selbst.** Ein GL.iNet Slate AX ohne WAN-Kabel, `dnsmasq` darauf als DNS, der Rechner unter einer festen Adresse, Caddy mit dem geholten Zertifikat. Ein Handy im WLAN dieses Routers hat `https://installation.julianniklasheynert.xyz` geladen — ohne Warnung, ohne installiertes Wurzelzertifikat, mit funktionierenden Sensoren. Der Router erreicht dabei nachweislich kein Internet. Damit ist die Kette vollständig: **Secure Context ohne Internet, auf einem fremden Gerät.**

**Und am 2026-09-10 die Sensorik selbst**, auf einem echten Handy über Prod unter `julianniklasheynert.xyz`: die Seite lädt, `DeviceOrientationEvent.requestPermission()` fragt, und die Ansicht folgt der Bewegung. Das ist die Annahme, auf der diese ganze Notiz steht — sie war bis dahin gelesen, nicht gemessen.

**Noch ungeprüft**, ehrlich benannt, weil der Rest jetzt belastbar ist:

- **Nur ein Router, nicht mehrere.** Für die Zuordnung Hotspot → Eintrittspunkt braucht jeder ein eigenes Subnetz; das ist nie gebaut worden.
- **Ob RNBO im Browser ohne Secure Context läuft**, ist nicht gemessen. Web Audio braucht keinen, `AudioWorklet` in der Regel auch nicht. Die Sperre trifft sicher die Sensorik — ob sie auch den Klang trifft, gehört geprüft, bevor jemand darauf baut.
- **Das Portal führt noch direkt auf die Anwendung.** Es müsste einen Satz und einen Link zeigen, damit der Besucher in seinen richtigen Browser wechselt — im Portal-Fenster laufen die Sensoren nicht.
- **Die Datenbanken sind nicht benannt.** Welche Anwendung welche braucht, entscheidet, ob ein Dump reicht.

## Verwandt

- `zaehlen\wwww\ARCHITEKTUR.md` — was wo liegt: die Pfade auf jedem der vier Rechner, und wer welchen Port hält
- `zaehlen\wwww\README.md` — die Befehle zu dieser Notiz: bauen, Zertifikat holen, Bündel packen, vor Ort starten
- `zaehlen\wwww
outer.md` — der Slate AX im Einzelnen, aus dem Lauf vom 2026-09-11
- [[remote-dev-stack]] — warum HTTPS auch lokal nötig ist, und die drei Wege dorthin
- [[remote-session-access]] — wie du an eine laufende Sitzung kommst, ohne davor zu sitzen
- `zaehlen\vps\README.md` — wie der Server entsteht und wiederhergestellt wird
- `skills\cast\SKILL.md` — die Sicherung, die zugleich das Transportbündel ist
