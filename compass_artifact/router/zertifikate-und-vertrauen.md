---
tags: [learning, https]
created: 2026-09-11
topic: Was ein Zertifikat ist, wer es ausstellt, warum ein Browser dem einen traut und dem anderen nicht — und warum die Installation nur über die DNS-Challenge an eines kommt
verification: extern — Standard-TLS und ACME, kein smithy-Bezug; der Teil ab Abschnitt 10 ist der Lauf vom 2026-09-09
---

# Zertifikate und Vertrauen

Diese Datei baut von null auf. Abschnitt 1 setzt nichts voraus, jeder folgende
nur die davor.

**Was hier nicht steht:** was ein Reverse Proxy damit tut — das steht in
`reverse-proxy.md` daneben. Und die Befehle, die stehen in
`zaehlen\wwww\README.md`.

---

## 1 · Zwei verschiedene Fragen

Wenn dein Handy eine Webseite lädt, stellen sich zwei Fragen, und man verwechselt
sie leicht:

1. **Kann jemand mitlesen?** Das löst Verschlüsselung.
2. **Ist am anderen Ende wirklich der, der behauptet, es zu sein?** Das löst ein
   Zertifikat.

Die zweite Frage ist die schwierigere. Verschlüsselung ohne Antwort darauf ist
wertlos: Du hättest eine perfekt gesicherte Verbindung — zu irgendwem.

## 2 · Das Zertifikat ist eine unterschriebene Behauptung

Ein **Zertifikat** ist eine Datei mit zwei Dingen darin:

- **Für welchen Namen es gilt**, zum Beispiel `installation.julianniklasheynert.xyz`
- **Die Unterschrift einer Stelle**, die bestätigt: „Wer diese Datei benutzt,
  ist der rechtmäßige Inhaber dieses Namens"

Dazu gehört eine zweite Datei, der **private Schlüssel**. Er wird nie
weitergegeben. Nur wer ihn hat, kann beweisen, dass das Zertifikat zu ihm
gehört. Deshalb nützt ein kopiertes Zertifikat allein nichts.

**Das Zertifikat gilt für einen Namen, nicht für einen Rechner.** Du kannst es
auf eine andere Maschine kopieren, und es funktioniert dort — solange der
private Schlüssel mitkommt und die Besucher denselben Namen aufrufen. Das ist
der Grund, warum die Installation überhaupt möglich ist.

Und umgekehrt: Ruft jemand `https://192.168.8.10` auf, passt das Zertifikat
nicht, weil es auf einen Namen lautet und nicht auf eine Adresse.

## 3 · Wer unterschreibt: die Zertifizierungsstelle

Eine **Zertifizierungsstelle** ist eine Organisation, die solche Unterschriften
leistet. Sie prüft vorher, ob der Antragsteller den Namen wirklich kontrolliert
(Abschnitt 7), und unterschreibt dann.

Die bekannteste kostenlose heißt **Let's Encrypt**.

## 4 · Der Vertrauensspeicher: die Liste im Gerät

Jetzt der Punkt, an dem alles hängt.

**In jedem Betriebssystem und in jedem Browser liegt eine Liste.** Darin stehen
etwa hundert Zertifizierungsstellen, deren Unterschriften akzeptiert werden. Sie
heißt **Vertrauensspeicher**, und sie kommt mit dem Gerät.

Wenn dein iPhone ein Zertifikat sieht, prüft es: Ist die Unterschrift von einer
Stelle aus dieser Liste? Ja → grünes Schloss. Nein → Warnung.

**Das ist der ganze Mechanismus.** Es gibt keine zentrale Prüfstelle im Internet,
die gefragt wird. Es gibt nur die Liste, die Apple und Google und Microsoft in
ihre Geräte legen.

Daraus folgt der entscheidende Satz für dieses Projekt: **Ein Besucher-Handy
vertraut genau dem, was in seiner Liste steht — und du kannst daran nichts
ändern.**

## 5 · Warum ein selbstgebautes Zertifikat nicht geht

Jeder kann sich in zwei Minuten ein Zertifikat ausstellen. Es ist technisch
einwandfrei und verschlüsselt genauso gut.

Es steht nur in keiner Liste. Also warnt jeder Browser.

Man *kann* eine eigene Stelle in die Liste eines Geräts eintragen — auf dem
eigenen Rechner ist das üblich. Für fremde Besucher taugt es nicht: Niemand
installiert ein Wurzelzertifikat auf seinem Telefon, um eine Kunstinstallation
anzusehen, und auf iOS ist es mehrstufig und abschreckend.

**Deshalb braucht die Installation ein echtes Zertifikat** — von einer Stelle,
die ohnehin in jeder Liste steht.

## 6 · ACME: die Ausstellung ohne Menschen

Früher kaufte man Zertifikate bei Händlern, mit Formularen und Wartezeit. Let's
Encrypt hat das durch ein Verfahren ersetzt, bei dem zwei Programme miteinander
reden. Das Verfahren heißt **ACME**.

Der Ablauf hat immer dieselbe Form:

1. Dein Programm sagt: „Ich möchte ein Zertifikat für diesen Namen."
2. Let's Encrypt antwortet: „Beweise, dass der Name dir gehört. Hier ist eine
   Aufgabe."
3. Dein Programm löst die Aufgabe.
4. Let's Encrypt prüft und schickt das Zertifikat.

Die Aufgabe heißt **Challenge**, und es gibt zwei Arten.

## 7 · Die zwei Challenges

**Die HTTP-Challenge.** Let's Encrypt sagt: „Leg eine Datei mit diesem Inhalt
auf deinen Webserver." Dann ruft es `http://dein-name/…` auf und sieht nach.

Der Beweis lautet: *Ich betreibe den Server, auf den dieser Name zeigt.*

Voraussetzungen: eine öffentliche Adresse, ein offener Port 80, Erreichbarkeit
aus dem Internet. Auf einem VPS ist das alles gegeben — deshalb ist es der
Normalfall, und der Nginx Proxy Manager macht es mit einem Klick.

**Die DNS-Challenge.** Let's Encrypt sagt: „Trag diesen Text als Eintrag in die
Namenszone deiner Domain." Diesen Eintrag setzt nicht dein Server, sondern die
Stelle, bei der die Domain registriert ist.

Der Beweis lautet: *Mir gehört diese Domain.*

**Und hier liegt der Unterschied, der alles entscheidet: Es muss überhaupt kein
Server erreichbar sein.**

## 8 · Warum nur die DNS-Challenge in die Halle führt

Die Installation soll ohne Internet laufen. Damit fällt die HTTP-Challenge aus —
es gibt keinen erreichbaren Server und keinen offenen Port.

Mit der DNS-Challenge kannst du **auf deinem eigenen Rechner** ein Zertifikat
für `installation.julianniklasheynert.xyz` ausstellen lassen, ohne dass unter
diesem Namen irgendwo ein Server steht. Heraus fallen zwei Dateien. Die kopierst
du auf den Installationsrechner.

**Internet nur zum Ausstellen, nicht zum Betrieb.** Das ist der Satz, an dem der
ganze dritte Ort hängt.

## 9 · Die 90 Tage

Ein Let's-Encrypt-Zertifikat gilt **90 Tage**. Danach warnt jeder Browser wieder.

Das ist Absicht: Kurze Laufzeiten zwingen zur Automatisierung, und ein
gestohlener Schlüssel wird schneller wertlos.

Für einen Server mit Internet ist das unsichtbar — ein Programm erneuert von
selbst. Für die Installation ist es ein Termin: **vor jedem Aufbau erneuern**,
an einem Ort mit Internet.

Der Installationsrechner muss dafür nicht einmal eingeschaltet werden. Es sind
zwei Dateien.

## 10 · Was in den beiden Dateien steht

Nach dem Lauf liegen zwei Dateien vor:

| Datei | Inhalt | Geheim |
|---|---|---|
| `cert.pem` | das Zertifikat: der Name und die Unterschriften | nein — es wird an jeden Besucher geschickt |
| `key.pem` | der private Schlüssel | **ja** — wer ihn hat, kann sich als dieser Name ausgeben |

`cert.pem` enthält meist **zwei** Zertifikate hintereinander: deines und das der
Zwischenstelle, die es unterschrieben hat. Der Grund ist eine Kette: In der
Liste des Geräts steht nur das Wurzelzertifikat von Let's Encrypt. Die
Zwischenstelle muss der Server mitschicken, sonst kann das Handy die Verbindung
nicht schließen.

**Daher kommt ein Fehler, der oft verwirrt:** Auf dem einen Gerät funktioniert
eine Seite, auf dem anderen nicht. Meist ist der Grund ein alter
Vertrauensspeicher — das Gerät kennt eine neuere Zwischenstelle noch nicht. Am
2026-09-11 ist genau das dem Router passiert: Sein Speicher ist Jahre alt, und
er verweigerte eine Verbindung, die jedes Handy problemlos aufbaut.

## 11 · Wo das Zertifikat benutzt wird — und wo nicht

Ein Zertifikat wird nicht von der Anwendung benutzt, sondern von dem Programm,
das die Verbindung annimmt. An den drei Orten dieses Projekts ist das jeweils
ein anderes:

| Ort | Wer hält das Zertifikat |
|---|---|
| Stage, dein PC | niemand — `localhost` ist die Ausnahme, die der Browser ohne Zertifikat gelten lässt |
| Prod, der VPS | der Nginx Proxy Manager, mit einem selbst geholten per HTTP-Challenge |
| Installation | ein Caddy-Container, mit den zwei Dateien aus Abschnitt 10 |

**Und ein Detail, das man leicht übersieht:** Caddy holt sich normalerweise von
selbst Zertifikate. Vor Ort ist das genau das, was man abschalten muss — ohne
Internet fragte es beim Start vergeblich an. Die Angabe zweier fester Pfade
schaltet es für diesen Namen ab.

## 12 · Die Falle, die kein Zertifikat löst

Ein gültiges Zertifikat nützt nichts, wenn der Server **daneben** weiterhin
unverschlüsselt antwortet.

Wer einen Namen in die Adresszeile tippt, landet oft zuerst auf `http`.
Antwortet der Server dort mit der Seite statt mit einer Weiterleitung, ist die
Verbindung ungesichert — einen Klick neben dem gültigen Zertifikat. Und dann
sperrt der Browser die Bewegungssensoren, ohne einen Fehler zu melden.

Geprüft ist das in einer Zeile. **301 ist richtig, 200 ist der Fehler:**

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://installation.julianniklasheynert.xyz/
```

## Verwandt

- `reverse-proxy.md` — was zwischen Browser und Anwendung steht und das Zertifikat hält
- `..\openwrt\was-der-router-macht.md` — warum der Name zählt und nicht die Adresse (Abschnitt 5)
- `zaehlen\wwww\README.md` — der Befehl, mit dem das Zertifikat geholt wird
- `claude-notes\drei-orte-einer-anwendung.md` — warum ohne all das die halbe Anwendung nicht startet
