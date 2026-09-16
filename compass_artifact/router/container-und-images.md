---
tags: [learning, docker]
created: 2026-09-11
topic: Was ein Image ist, was ein Container ist, worin sie sich unterscheiden — und warum ein Programm auf dem eigenen Rechner läuft und auf einem leeren nicht
verification: extern — Standard-Docker-Verhalten, kein smithy-Bezug, per Hand
---

# Container und Images

Diese Datei baut von null auf. Abschnitt 1 setzt nichts voraus, jeder folgende
nur die davor.

**Was hier nicht steht:** wie deine Anwendung aufgebaut ist — das steht in
`wie-wwww-aufgebaut-ist.md` daneben und setzt diese Datei voraus.

---

## 1 · Ein Programm braucht mehr als sich selbst

Ein Webserver ist eine Datei von vielleicht 20 Megabyte. Damit sie läuft, muss
auf dem Rechner noch einiges andere liegen: Systembibliotheken, ein Satz
Wurzelzertifikate, bestimmte Verzeichnisse, manchmal eine passende Version einer
Programmiersprache.

**Deshalb läuft ein Programm auf einem Rechner und auf dem nächsten nicht.**
Nicht weil das Programm anders wäre, sondern weil um es herum etwas fehlt.

Docker löst das, indem es das Programm **mit allem drumherum** zusammenpackt.

## 2 · Das Image ist die Packung

Ein **Image** ist diese Packung: das Programm plus alles, was es zum Laufen
braucht, bis hinunter zu einem halben Betriebssystem.

Wichtig: **Ein Image läuft nicht.** Es liegt herum. Es ist wie eine
Installations-CD — vollständig, aber untätig.

Ein Image hat einen Namen, und der besteht aus zwei Teilen:

```
caddy:2.10-alpine
└─┬─┘ └────┬────┘
  │        └── Version, hier "Tag" genannt
  └── Name des Programms
```

Steht kein Tag da, ergänzt Docker `:latest`. Das ist kein fester Stand, sondern
„das Neueste" — deshalb schreibt man in ernsten Fällen den Tag immer aus.

## 3 · Der Container ist das laufende Programm

Ein **Container** entsteht, wenn Docker ein Image startet. Er ist das Programm
im Betrieb: Er verbraucht Arbeitsspeicher, hört auf einem Port, schreibt Logs.

Aus **einem** Image kannst du beliebig viele Container starten. Sie stören sich
nicht — jeder bekommt seine eigene Kopie der Dateien.

| | Image | Container |
|---|---|---|
| Was es ist | eine Datei-Sammlung | ein laufendes Programm |
| Verbraucht | Platz | Platz, Arbeitsspeicher, Rechenzeit |
| Anzahl | eines | beliebig viele aus demselben Image |
| Verschwindet | nur wenn du es löschst | wenn du es stoppst und entfernst |

**Die Verwechslung dieser beiden ist die häufigste Quelle von Missverständnissen
mit Docker.** Ein Satz wie „das Image läuft nicht" heißt fast immer: Der
Container ist abgestürzt. Und „Docker findet das Image nicht" heißt: Die Packung
fehlt, nicht das Programm.

## 4 · Woher Images kommen

Es gibt öffentliche Lager im Internet, aus denen jeder Images beziehen kann. Das
größte heißt **Docker Hub**. Dort liegen fertige Images für fast alles: Datenbanken,
Webserver, Programmiersprachen.

Wenn Docker ein Image braucht, das es nicht hat, lädt es dort herunter. Das
passiert **automatisch und stillschweigend**, bei jedem `docker run` und jedem
`docker compose up`.

Merke dir diesen Satz, Abschnitt 10 kommt darauf zurück: **Fehlt ein Image, holt
Docker es aus dem Internet.**

## 5 · Das Lager auf deinem Rechner

Jedes heruntergeladene oder selbst gebaute Image bleibt auf deinem Rechner
liegen. Diesen Vorrat kannst du ansehen:

```bash
docker images
```

Jede Zeile ist ein Image mit Name, Tag und Größe.

**Dieses Lager wächst, ohne dass du es merkst.** Was einmal gebraucht wurde,
bleibt. Deshalb funktioniert auf einem Rechner, mit dem lange gearbeitet wurde,
oft etwas, das auf einem frischen scheitert — nicht weil dort etwas kaputt ist,
sondern weil das Lager leer ist.

Das laufende Gegenstück siehst du mit:

```bash
docker ps
```

Jede Zeile ist ein Container.

## 6 · Ein eigenes Image bauen: das Dockerfile

Für eigene Anwendungen baut man ein eigenes Image. Die Bauanleitung heißt
**Dockerfile** und ist eine Textdatei mit wenigen Zeilen:

```dockerfile
FROM caddy:2.10-alpine
COPY site/ /srv/
```

`FROM` sagt: Fang mit einem fertigen Image an. `COPY` sagt: Leg diese Dateien
hinein. Fertig ist ein neues Image, das den Webserver **und** deine Seite
enthält.

Gebaut wird mit:

```bash
docker build -t wwww:0.1.0 .
```

`-t` vergibt den Namen, der Punkt sagt „die Bauanleitung liegt hier".

**Ein Bau ist kein Kopieren.** `FROM caddy:2.10-alpine` ist ein *Name*, kein
Inhalt. Wer dasselbe Dockerfile in drei Wochen baut, bekommt vielleicht ein
anderes Ergebnis — weil hinter dem Namen inzwischen eine neuere Fassung steht.
Gleiche Anleitung, anderes Ergebnis.

Darum verteilt man zwischen Rechnern, die identisch sein müssen, nicht die
Anleitung, sondern das fertige Image (Abschnitt 9).

## 7 · Mehrere Container zusammen: `docker compose`

Eine Anwendung besteht selten aus einem Programm. Meist sind es mehrere, die
zusammenarbeiten — ein Webserver, eine Datenbank, ein Vermittler davor.

Statt jeden einzeln zu starten, schreibt man sie in eine Datei namens
`docker-compose.yml`:

```yaml
services:
  app:
    image: wwww:0.1.0
    build: .
```

Jeder Eintrag unter `services:` ist ein Container. Dann:

```bash
docker compose up -d
```

Das startet alle auf einmal. `-d` heißt: im Hintergrund, das Terminal bleibt
frei.

**Der Zusatz `--build` ändert die Bedeutung grundlegend.** Ohne ihn nimmt
Docker das fertige Image aus dem Lager. Mit ihm baut es vorher neu nach dem
Dockerfile. Steht in der Datei sowohl `image:` als auch `build:`, hast du beide
Wege offen — und das ist Absicht.

## 8 · Container reden miteinander über ihren Namen

Container in derselben compose-Datei erreichen sich über den Namen, der links
steht. Aus einem Container heraus zeigt `http://app:80` auf den Container
namens `app`. Docker führt dafür ein eigenes kleines Namensverzeichnis.

**Von außen gilt das nicht.** Dein Browser kennt diese Namen nicht — für ihn
braucht es eine Zeile, die einen Port des Rechners mit einem Port im Container
verbindet:

```yaml
ports:
  - "8080:80"
```

Links der Port auf deinem Rechner, rechts der im Container. `localhost:8080`
landet dann bei Port 80 des Containers.

**Ist der linke Port schon belegt, startet der Container nicht.** Die Meldung
lautet `address already in use` und sagt nicht, wer ihn hält.

## 9 · Ein Image transportieren: `save` und `load`

Ein Image aus dem Lager in eine Datei schreiben:

```bash
docker save wwww:0.1.0 -o wwww-0.1.0.tar
```

Diese Datei kannst du kopieren — auf einen Stick, über das Netz. Auf dem
Zielrechner:

```bash
docker load -i wwww-0.1.0.tar
```

Danach liegt dasselbe Image dort im Lager.

**`docker save` nimmt genau ein Image.** Brauchst du drei, tippst du den Befehl
dreimal. Das ist der Punkt, an dem in Abschnitt 10 etwas schiefgeht.

Ob zwei Rechner wirklich dasselbe Image haben, sagt eine Zahl:

```bash
docker image inspect --format '{{.Id}}' wwww:0.1.0
```

Gleiche Zahl heißt bitgenau dasselbe. Gleicher Name bei verschiedenen Zahlen
heißt: Irgendwo wurde nachgebaut, und du hast zwei verschiedene Anwendungen
unter einem Namen.

## 10 · Der Fehler, den man auf dem eigenen Rechner nicht sehen kann

Nimm an, eine Anwendung besteht aus zwei Containern: einem eigenen und einem
fertigen aus dem Internet. Du packst ein Bündel für einen Rechner ohne Internet
und speicherst — wie es in der Anleitung steht — **ein** Image.

Auf dem Zielrechner:

1. `docker load` legt dein Image ins leere Lager.
2. `docker compose up` sucht beide Images.
3. Deines findet es. Das zweite nicht.
4. Also tut Docker, was es immer tut (Abschnitt 4): Es lädt aus dem Internet.
5. Es gibt kein Internet. Abbruch.

**Auf deinem eigenen Rechner ist dieser Fehler unsichtbar.** Das zweite Image
kam beim ersten `docker build` automatisch mit und liegt seitdem im Lager
(Abschnitt 5). Alles funktioniert — nicht weil die Anleitung stimmt, sondern
weil hier ohnehin schon alles da ist.

**Der Fehler existiert nur auf einem leeren Rechner.** Und genau gegen so einen
wird ein Transportbündel getestet.

Deshalb fragt man nicht sich selbst, welche Images gebraucht werden, sondern
die Konfiguration:

```bash
docker compose config --images
```

Jede Zeile der Antwort bekommt ein eigenes `docker save`.

## 11 · Die vier Befehle zum Nachsehen

Wenn etwas unklar ist, beantworten diese vier fast jede Frage:

| Befehl | Antwortet auf |
|---|---|
| `docker ps` | Was läuft gerade, auf welchen Ports |
| `docker images` | Was liegt im Lager |
| `docker logs <name>` | Was hat dieser Container gesagt |
| `docker compose config --images` | Welche Images braucht dieser Aufbau |

`docker ps -a` zeigt zusätzlich die gestoppten Container — dort steht, warum
einer nicht mehr läuft.

## Verwandt

- `wie-wwww-aufgebaut-ist.md` — dieselben Begriffe an deinem konkreten Aufbau
- `zaehlen\wwww\ARCHITEKTUR.md` — welche Datei auf welchem Rechner liegt
- `claude-notes\drei-orte-einer-anwendung.md` — warum die Gleichheit dreier Orte am Image hängt
