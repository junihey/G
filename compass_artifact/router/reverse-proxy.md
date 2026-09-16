---
tags: [learning, https]
created: 2026-09-11
topic: Was ein VPS ist, warum vor mehreren Diensten ein Reverse Proxy steht, wie er sie auseinanderhält — und warum hier der Nginx Proxy Manager und Caddy gleichzeitig richtig sind
verification: extern — Standard-Verhalten von nginx und Caddy; die Angaben zum eigenen VPS sind aus dem Aufbau vom 2026-09-08 belegt
---

# Der Reverse Proxy

**Diese Datei setzt `zertifikate-und-vertrauen.md` voraus.** Zertifikat,
Zertifizierungsstelle und die zwei Challenges werden hier benutzt, nicht mehr
erklärt.

---

## 1 · Was ein VPS ist

Ein **VPS** — *virtueller privater Server* — ist ein Computer, der in einem
Rechenzentrum steht und dir allein gehört. Nicht als Blech: Auf einer großen
Maschine laufen viele davon nebeneinander, jeder mit eigenem Betriebssystem und
eigener Adresse.

Für dich verhält er sich wie ein eigener Rechner mit drei Unterschieden: Er hat
eine **feste öffentliche Adresse**, er ist **immer an**, und du erreichst ihn nur
über das Netz — es gibt keinen Bildschirm.

Deiner steht bei IONOS unter `217.154.113.12`.

## 2 · Ein Rechner, mehrere Dienste, ein Port

Auf diesem einen Rechner laufen mehrere Dinge, die aus dem Internet erreichbar
sein sollen: eine Dateiablage, eine Entwicklungsumgebung im Browser, deine
Webseite.

Jedes davon ist ein eigener Webserver mit eigenem Port. Aber:

**Ein Browser fragt immer auf Port 443** — er hängt keine Portnummer an, wenn
keine in der Adresse steht. Niemand tippt `https://seafile.beispiel.de:8081`.

Und: **Nur ein Programm kann Port 443 belegen.** Also können die Dienste ihn
nicht unter sich aufteilen.

## 3 · Der Reverse Proxy löst das

Ein **Reverse Proxy** ist ein Programm, das als einziges auf Port 443 lauscht.
Jede Anfrage kommt bei ihm an, und er reicht sie an den richtigen Dienst weiter.

```
Browser --443--> Reverse Proxy --8081--> Dateiablage
                       |
                       +-----80-------> deine Webseite
```

„Reverse" heißt es, weil ein gewöhnlicher Proxy für den *Client* vermittelt —
dieser hier steht auf der Seite des *Servers*.

## 4 · Woran er erkennt, wer gemeint ist

Nicht an der Adresse — die ist bei allen dieselbe.

**Am Namen, den der Browser mitschickt.** Jede HTTP-Anfrage trägt eine Zeile, in
der steht, welcher Name gemeint war:

```
Host: seafile.julianniklasheynert.xyz
```

Der Proxy liest sie und sucht in seiner Liste nach einer passenden Regel. Steht
dort „dieser Name → Dateiablage auf Port 8081", reicht er weiter.

Bei verschlüsselten Verbindungen ist das ein Henne-Ei-Problem: Der Name steckt
*in* der verschlüsselten Anfrage, aber zum Entschlüsseln braucht der Proxy schon
das richtige Zertifikat. Gelöst wird es dadurch, dass der Browser den Namen
**vor** der Verschlüsselung nennt, im Klartext.

Deshalb können mehrere Namen mit verschiedenen Zertifikaten auf einer Adresse
liegen.

## 5 · Was er sonst noch tut

**Er hält die Zertifikate.** Die Dienste dahinter sprechen unverschlüsselt — sie
laufen auf demselben Rechner oder in einem geschlossenen Netz daneben. Nur der
Proxy braucht ein Zertifikat, und zwar eines pro Name.

Das ist der Grund für die Aufteilung in zwei Container in diesem Projekt: Der
Dateiserver mit deiner Seite kennt keine Verschlüsselung und ist deshalb an
allen drei Orten identisch.

**Er erzwingt HTTPS.** Kommt jemand über `http`, schickt er eine Weiterleitung
statt der Seite. Ohne das wäre die Verbindung ungesichert, und der Browser
sperrt die Bewegungssensoren — die Falle aus `zertifikate-und-vertrauen.md`,
Abschnitt 12.

**Er verdeckt den Absender.** Er baut eine *neue* Verbindung zum Dienst
dahinter auf. Der sieht deshalb die Adresse des Proxys, nicht die des Besuchers.
Dagegen gibt es eine Kopfzeile namens `X-Forwarded-For`, in die der Proxy die
ursprüngliche Adresse schreibt — aber der Dienst muss sie auch lesen.

## 6 · Zwei Werkzeuge, und worin sie sich unterscheiden

**Nginx Proxy Manager** ist eine Weboberfläche über nginx. Du klickst einen Host
zusammen, er schreibt eine Zeile in eine Datenbank und erzeugt daraus eine
nginx-Konfiguration. Zertifikate holt er auf Knopfdruck per HTTP-Challenge und
erneuert sie selbst.

**Caddy** liest eine Textdatei. Die vollständige Konfiguration für einen Dienst
sind drei Zeilen:

```
installation.julianniklasheynert.xyz {
    tls /etc/caddy/certs/cert.pem /etc/caddy/certs/key.pem
    reverse_proxy app:80
}
```

**Der Gegensatz ist nicht nginx gegen Caddy, sondern Konfiguration als Datei
gegen Konfiguration als Datenbankzustand.** Reines nginx täte es auch — nur
schreibst du dann dreißig Zeilen statt drei.

## 7 · Warum hier beide richtig sind

| | Auf dem VPS | Vor Ort |
|---|---|---|
| Wie oft läuft die Maschine | dauerhaft | wird hingestellt, eingeschaltet, eingepackt |
| Erneuerung alle 90 Tage | automatisch, unsichtbar | von Hand, ohne Internet nicht möglich |
| Stirbt die Festplatte | Backup der Datenbank nötig | `git clone`, `docker compose up` |
| „Was war letztes Mal anders?" | ein Klumpen Binärdaten | ein Diff |

Auf dem VPS ist Bequemlichkeit die richtige Währung: Der Proxy Manager läuft
seit Monaten, erneuert selbst und bedient drei Dienste. Ihn zu ersetzen kostet
Arbeit ohne Gewinn.

**Vor Ort ist Vorhersagbarkeit die Währung.** Der Rechner hat keinen
Dauerbetrieb, keine automatische Erneuerung, und am Aufbautag debuggst du unter
Zeitdruck. Drei Zeilen im Repository sind dort mehr wert als eine Oberfläche mit
einer Datenbank dahinter.

**Der Proxy Manager könnte es auch.** Er beherrscht die DNS-Challenge, und das
Zertifikat läge danach als Datei vor. Der Grund gegen ihn ist nicht ein
fehlendes Merkmal, sondern der Aufwand alle 90 Tage.

## 8 · Ein Detail, das in die falsche Richtung wirkt

Caddys bekanntestes Merkmal ist, dass es Zertifikate von selbst holt und
erneuert. Auf dem Installationsrechner ist das genau das, was man **abschalten**
muss: Ohne Internet fragte es beim Start vergeblich an.

Die Angabe zweier fester Pfade in der `tls`-Zeile erledigt das — für diesen
Namen rührt Caddy die automatische Ausstellung nicht an und nimmt die Dateien.

**Du benutzt Caddy hier also nicht wegen der Automatik, sondern trotz ihr —
wegen der kurzen Datei.**

## 9 · Der Proxy als Ort, an dem etwas verlorengeht

Abschnitt 5 nennt es beiläufig, aber es hat dieses Projekt eine Entscheidung
gekostet: Der Proxy verdeckt den Absender.

Für die Installation war geplant, am Absender zu erkennen, aus welchem WLAN ein
Besucher kommt. Gemessen am 2026-09-11: Anfragen aus drei getrennten Netzen
kamen alle mit derselben Adresse an. Zwei Stellen verlieren sie — der Proxy
selbst und, davor, Docker Desktop unter Windows.

**Deshalb trägt der Standort in der Adresszeile statt in der Absenderadresse.**
Wie das eingerichtet ist, steht in `..\openwrt\was-der-router-macht.md`,
Abschnitt 14.

## Verwandt

- `zertifikate-und-vertrauen.md` — die Grundlage dieser Datei
- `..\docker\wie-wwww-aufgebaut-ist.md` — warum der Dateiserver und der Proxy zwei Container sind
- `zaehlen\vps\README.md` — welche Dienste auf dem VPS liegen und wie er entsteht
- `claude-notes\drei-orte-einer-anwendung.md` — die Entscheidung für beide Werkzeuge im Zusammenhang
