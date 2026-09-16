---
tags: [learning, docker]
created: 2026-09-11
topic: Wie aus den zwölf Dateien in zaehlen\wwww\ zwei laufende Programme werden, und was sich zwischen Stage, Prod und Installation ändert
verification: extern — der Aufbau ist am 2026-09-09 bis 2026-09-11 an allen drei Orten gelaufen
---

# Wie `zaehlen\wwww\` aufgebaut ist

**Diese Datei setzt `container-und-images.md` voraus.** Image, Container,
Dockerfile, `docker compose` und der Unterschied zwischen `up -d` und
`up -d --build` werden hier benutzt, nicht mehr erklärt.

**Was hier nicht steht:** die Befehle zum Nachmachen — die stehen in
`zaehlen\wwww\README.md`. Und nichts über den Router, der steht in
`learning\openwrt\was-der-router-macht.md`.

---

## 1 · Zwei Programme, nicht eins

Wenn die Anwendung läuft, laufen zwei Container:

| Container | Aufgabe |
|---|---|
| `wwww` | **Dateiserver.** Er hat `index.html` und three.js und schickt sie an jeden, der fragt. Er kann nur das. |
| `wwww-tls` | **Vermittler davor.** Er nimmt verschlüsselte Anfragen an, entschlüsselt sie und reicht sie an `wwww` weiter. Er hat selbst keine einzige Datei der Webseite. |

Beide sind derselbe Webserver — **Caddy** —, nur anders eingestellt.

## 2 · Warum sie getrennt sind

**Weil der vordere an jedem Ort ein anderer ist.**

| Ort | Wer entschlüsselt |
|---|---|
| Stage, dein PC | niemand — `localhost` braucht keine Verschlüsselung |
| Prod, der VPS | der Nginx Proxy Manager, der dort schon für andere Dienste läuft |
| Installation | `wwww-tls`, mit den beiden Zertifikatsdateien aus `certs/live/` |

Der hintere Container ändert sich nie. Wäre die Verschlüsselung in ihm
eingebaut, müsste er an jedem Ort anders sein — und dann wären es drei
verschiedene Anwendungen statt einer.

**Das ist der ganze Grund für die Trennung.** Sie kostet einen zweiten Container
und kauft dafür, dass der Teil mit deinem Code überall identisch ist.

## 3 · Die Dateien, einzeln

Zwölf Dateien liegen im Repository. Fünf davon bauen und starten, der Rest ist
Inhalt und Dokumentation.

| Datei | Wer liest sie | Was sie bewirkt |
|---|---|---|
| `site/index.html` | der Browser | die Seite selbst |
| `site/vendor/three/*.js` | der Browser | three.js, lokal statt aus dem Internet |
| `Dockerfile` | `docker build` | baut das Image `wwww:0.1.0` |
| `Caddyfile` | der Container `wwww` | „liefere Dateien aus `/srv` auf Port 80 aus" |
| `docker-compose.yml` | `docker compose` | beschreibt den Container `wwww` |
| `compose.installation.yml` | `docker compose`, nur vor Ort | fügt den Container `wwww-tls` hinzu |
| `caddy-vorort/Caddyfile` | der Container `wwww-tls` | „entschlüssele mit diesen zwei Dateien und reiche an `wwww` weiter" |
| `.env` | `docker compose` | die drei Werte, die sich je Ort unterscheiden |
| `.env.example` | du | die Checkliste, welche Werte es gibt |
| `README.md` · `ARCHITEKTUR.md` · `router.md` | du | Befehle, Pfade, der Router |

**Zwei `Caddyfile` sind kein Versehen.** Es sind zwei verschiedene Programme mit
zwei verschiedenen Aufgaben, also zwei Konfigurationen.

## 4 · Was beim Bauen passiert

```bash
docker build -t wwww:0.1.0 .
```

Docker liest das `Dockerfile`:

```dockerfile
FROM caddy:2.10-alpine
COPY Caddyfile /etc/caddy/Caddyfile
COPY site/ /srv/
```

1. Es holt `caddy:2.10-alpine` — beim ersten Mal aus dem Internet, danach aus
   dem Lager.
2. Es legt das `Caddyfile` an die Stelle, an der Caddy es beim Start sucht.
3. Es legt `site/` nach `/srv`, wo das `Caddyfile` es erwartet.

Heraus kommt ein Image namens `wwww:0.1.0`. **Deine Seite steckt darin.** Änderst
du `index.html`, musst du neu bauen — sonst liefert der Container die alte
Fassung aus.

**`caddy:2.10-alpine` bleibt ein eigenes Image.** Es ist nicht in `wwww:0.1.0`
verschwunden, sondern dessen Unterlage. Für den Transport zählt es einzeln
(Abschnitt 8).

## 5 · Was beim Starten passiert

Auf Stage und Prod:

```bash
docker compose up -d
```

Docker liest `docker-compose.yml`, findet einen Dienst `app`, startet aus dem
Image `wwww:0.1.0` einen Container namens `wwww` und hängt ihn in ein Netz
namens `proxy`.

Vor Ort kommt eine zweite Datei dazu:

```bash
docker compose -f docker-compose.yml -f compose.installation.yml up -d
```

**Die zweite Datei ersetzt die erste nicht, sie ergänzt sie.** Docker legt beide
übereinander: Der Dienst `app` bleibt unverändert, und ein zweiter namens `tls`
kommt hinzu. Deshalb heißt sie ein *Overlay*.

Jetzt laufen zwei Container im selben Netz. `wwww-tls` erreicht `wwww` unter dem
Namen `app` — dem Dienstnamen aus der compose-Datei, nicht dem Containernamen.

## 6 · Der Weg einer Anfrage

Ein Handy ruft `https://installation.julianniklasheynert.xyz` auf:

```
Handy
 │  1. Wo ist dieser Name?        → Router antwortet: 192.168.8.10
 │  2. Verschlüsselte Anfrage an 192.168.8.10, Port 443
 ▼
wwww-tls   entschlüsselt, prüft den Namen gegen certs/live/cert.pem
 │  3. Unverschlüsselte Anfrage an app, Port 80
 ▼
wwww       sucht die Datei in /srv, schickt sie zurück
```

Auf Prod ist der Weg derselbe, nur steht statt `wwww-tls` der Nginx Proxy
Manager an Position 2 — und statt des Routers antwortet das öffentliche
Namensverzeichnis des Internets.

**Der untere Teil ist an beiden Orten bitgleich.** Das ist das Ziel des ganzen
Aufbaus.

## 7 · Was sich zwischen den Orten ändert

Genau drei Werte, und sie stehen in `.env`:

| Wert | Stage | Prod | Installation |
|---|---|---|---|
| `APP_BIND` | `127.0.0.1:8080` | `127.0.0.1:8090` | `127.0.0.1:8080` |
| `SITE_HOST` | — | — | `installation.julianniklasheynert.xyz` |
| `TLS_CERT_DIR` | — | — | `./certs/live` |

`APP_BIND` ist unterschiedlich, weil auf dem VPS der Port 8080 schon code-server
gehört.

**Die `.env` gehört nicht ins Repository.** Sie enthält ortsabhängige Werte und
später Passwörter. Stattdessen liegt `.env.example` dort — dieselben Schlüssel
mit leeren Werten, als Checkliste. Ohne sie fällt eine fehlende Variable erst
vor Ort auf.

## 8 · Was ins Transportbündel gehört

Vor Ort gibt es kein Internet. Es kann nichts gebaut und nichts geladen werden,
also muss alles mitfahren:

| Teil | Warum |
|---|---|
| `wwww-0.1.0.tar` | dein Image mit der Seite |
| `caddy-2.10-alpine.tar` | das Image für `wwww-tls` — **eigenständig, nicht im ersten enthalten** |
| das Repository | für die compose-Dateien und das `caddy-vorort/Caddyfile` |
| `.env` | die drei Werte von oben |
| `certs/live/` | `cert.pem` und `key.pem` |

Das zweite Image ist die Stelle, an der man sich irrt — auf dem eigenen Rechner
liegt es längst im Lager und fällt nicht auf. Die Liste nicht raten, sondern
fragen:

```bash
docker compose -f docker-compose.yml -f compose.installation.yml config --images
```

## 9 · Welche Ports wo belegt sind

Die häufigste Startmeldung ist `address already in use`, und sie nennt nie den
Schuldigen.

| Ort | 80 und 443 | 8080 | 8090 |
|---|---|---|---|
| dein PC | der lokale Nginx Proxy Manager, im Installationsbetrieb `wwww-tls` | `wwww` | frei |
| VPS | `proxy` | code-server | `wwww` |
| vor Ort | `wwww-tls` | `wwww` | frei |

Auf deinem PC müssen sich der lokale Proxy Manager und der Installationsaufbau
abwechseln: `docker stop proxy`, danach wieder `docker start proxy`.

## 10 · Wer die Adresse des Besuchers sieht — und wer nicht

Die Installation soll erkennen, aus welchem WLAN ein Besucher kommt, um ihn an
der richtigen Stelle der 3D-Welt starten zu lassen. Der naheliegende Weg ist die
Absenderadresse.

**Sie kommt nicht überall an.** Zwei Stellen gehen dabei verloren:

1. **Der Vermittler.** `wwww-tls` baut eine neue Verbindung zu `wwww` auf. Der
   hintere Container sieht deshalb die Adresse des vorderen. Dagegen gibt es ein
   Mittel: Der Vermittler schreibt die ursprüngliche Adresse in eine Kopfzeile
   namens `X-Forwarded-For`, die der hintere auslesen kann.
2. **Docker Desktop unter Windows.** Es schiebt einen eigenen Vermittler
   zwischen Netzwerkkarte und Container. Der verliert die Absenderadresse, bevor
   sie irgendeinen Container erreicht — gemessen am 2026-09-11: Anfragen aus drei
   verschiedenen WLANs kamen alle als `172.17.0.1` an. Unter Linux passiert das
   nicht.

**Deshalb trägt der Standort besser in der Adresszeile als in der IP.** Wie das
geht, steht in `learning\openwrt\was-der-router-macht.md`.

## Verwandt

- `container-und-images.md` — die Begriffe, auf denen diese Datei aufbaut
- `zaehlen\wwww\ARCHITEKTUR.md` — dieselbe Struktur als Nachschlagewerk, mit den Pfaden auf jedem Rechner
- `zaehlen\wwww\README.md` — die Befehle
- `claude-notes\drei-orte-einer-anwendung.md` — warum es drei Orte sind und was noch offen ist
