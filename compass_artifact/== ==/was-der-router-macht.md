---
tags: [learning, openwrt]
created: 2026-09-11
topic: Was ein Router tut, was der GL.iNet Slate AX davon kann, und was am 2026-09-11 auf ihm eingerichtet wurde
verification: extern — Standard-Netzwerktechnik und OpenWrt, kein smithy-Bezug; der Teil ab Abschnitt 10 ist der protokollierte Lauf
---

# Was der Router macht

Diese Datei baut von null auf. Abschnitt 1 setzt nichts voraus, jeder folgende
nur die davor. Am Ende verstehst du, was auf dem Slate AX eingerichtet wurde und
warum.

**Was hier nicht steht:** die Befehle zum Nachmachen — die stehen in
`zaehlen\wwww\router.md`. Und nichts über die Anwendung selbst.

---

## 1 · Eine Adresse pro Gerät

Jedes Gerät in einem Netzwerk hat eine Nummer, damit man es ansprechen kann. Sie
heißt **IP-Adresse** und sieht so aus:

```
192.168.8.10
```

Vier Zahlen, durch Punkte getrennt. Die ersten drei sagen, in welchem Netz das
Gerät steckt, die letzte, welches Gerät es ist. Alle Geräte mit `192.168.8.`
vorne sind im selben Netz und können miteinander reden.

Der Zusatz `/24` — geschrieben als `192.168.8.0/24` — heißt genau das: „die
ersten drei Zahlen bilden das Netz". Es gibt in diesem Netz 254 Plätze.

**Adressen, die mit `192.168.` anfangen, gibt es überall.** Sie sind für private
Netze reserviert. Dein Router zu Hause benutzt sie, jedes Büro, jedes Café — und
sie stören sich nicht, weil sie das Internet nie erreichen.

## 2 · Was ein Router tut

Ein **Router** ist das Gerät, an dem ein Netz hängt. Drei Dinge tut er, und sie
sind unabhängig voneinander:

1. Er **spannt das Netz auf** — per Kabel, per WLAN, oder beides.
2. Er **verteilt die Adressen** an alle, die sich anmelden (Abschnitt 3).
3. Er **übersetzt Namen in Adressen** (Abschnitt 4).

Meistens tut er noch ein viertes: Er verbindet dieses Netz mit dem Internet.
**Das muss er aber nicht**, und für unsere Installation soll er es gerade nicht.
Ein Router ohne Internet ist kein kaputter Router — er ist ein Netz für sich.

Der Router selbst hat auch eine Adresse in seinem Netz, üblicherweise die erste:
`192.168.8.1`. Unter dieser Adresse erreichst du ihn.

## 3 · Wer die Adressen vergibt: DHCP

Wenn sich ein Handy in ein WLAN einwählt, hat es noch keine Adresse. Es fragt
ins Netz: „Hat jemand eine für mich?" Der Router antwortet mit einer freien.

Dieses Frage-und-Antwort-Spiel heißt **DHCP**. Es läuft automatisch, niemand
tippt Adressen ein.

Die vergebene Adresse ist eine **Leihgabe** — sie heißt *Lease* und läuft nach
Stunden ab. Danach bekommt dasselbe Gerät vielleicht eine andere.

**Für einen Server ist das schlecht.** Wenn der Rechner, auf dem deine Seite
läuft, heute `192.168.8.204` hat und morgen `192.168.8.77`, zeigt jeder
Verweis ins Leere. Deshalb gibt es die **Reservierung**: Der Router merkt sich
„dieses eine Gerät bekommt immer dieselbe Adresse".

Erkannt wird das Gerät an seiner **MAC-Adresse** — einer Nummer, die fest in der
Netzwerkkarte steckt und sich nicht ändert:

```
60:CF:84:E6:75:38
```

Sechs Zahlenpaare. Jede Netzwerkkarte der Welt hat eine eigene. Kabel und WLAN
desselben Rechners haben verschiedene.

## 4 · Wie aus Namen Adressen werden: DNS

Niemand tippt `192.168.8.10` in einen Browser. Man tippt einen Namen.

Die Übersetzung von Namen in Adressen heißt **DNS**. Im Internet gibt es dafür
ein weltweites Verzeichnis: Wer `julianniklasheynert.xyz` eingibt, fragt einen
DNS-Server, und der antwortet mit `217.154.113.12`.

**Ohne Internet gibt es dieses Verzeichnis nicht.** Genau hier setzt unsere
Installation an: Der Router führt sein eigenes, winziges Verzeichnis. Darin
steht eine Zeile:

```
installation.julianniklasheynert.xyz  →  192.168.8.10
```

Jedes Handy in diesem WLAN fragt den Router, der Router antwortet, und das Handy
landet auf dem Rechner im Raum. Für die Handys sieht das aus wie ganz normales
DNS. Dass die Antwort aus einer selbstgeschriebenen Zeile kommt und nicht aus
dem Internet, merken sie nicht.

**Der Router bringt beides mit**, DHCP und DNS, in einem einzigen Programm
namens `dnsmasq`. Der Name ist die Abkürzung von *DNS masquerade*. Es läuft auf
jedem OpenWrt-Gerät von Haus aus.

Deshalb steht in `claude-notes\drei-orte-einer-anwendung.md`, der DNS gehöre auf
die Router und nicht auf den Rechner: Er ist dort schon.

## 5 · Warum der Name zählt und nicht die Adresse

Ein Browser gibt die Bewegungssensoren eines Handys nur frei, wenn die
Verbindung verschlüsselt ist — HTTPS mit einem Zertifikat, dem er traut.

**Ein Zertifikat wird auf einen Namen ausgestellt, nicht auf eine Adresse.**
Unseres lautet auf `installation.julianniklasheynert.xyz`. Ruft ein Handy
stattdessen `https://192.168.8.10` auf, passt das Zertifikat nicht, der Browser
warnt, und die Sensoren bleiben zu.

Darum die Zeile aus Abschnitt 4. Sie ist nicht Bequemlichkeit, sondern die
Bedingung, unter der die Anwendung überhaupt funktioniert.

## 6 · WLAN: ein Name, ein Passwort — oder mehrere

Ein WLAN hat einen Namen, den dein Handy in der Liste anzeigt. Der Name heißt
**SSID**. Dazu ein Passwort und ein Verschlüsselungsverfahren; das übliche heißt
**WPA2**, in OpenWrt geschrieben als `psk2`.

Der Slate AX hat zwei **Funkmodule**, im System `radio0` und `radio1`:

| Modul | Frequenz | Eigenschaft |
|---|---|---|
| `radio0` | 5 GHz | schneller, geringere Reichweite, kommt schlechter durch Wände |
| `radio1` | 2,4 GHz | langsamer, größere Reichweite |

Deshalb zeigt das Gerät zwei Namen an: `GL-AXT1800-0e4` und
`GL-AXT1800-0e4-5G`. Das ist **ein** Netz über zwei Funkwege, nicht zwei Netze.

**Ein Funkmodul kann mehrere Netze gleichzeitig ausstrahlen.** Jedes mit eigenem
Namen, eigenem Passwort und eigenem Adressbereich. Für ein Handy sehen sie aus
wie getrennte Router.

Im System heißt jedes ausgestrahlte Netz eine `wifi-iface`. Auf dem Slate AX
gibt es vier davon: die zwei Hauptnetze und zwei Gastnetze, die abgeschaltet
sind. Die Hardware erlaubt bis zu **16 pro Funkmodul**.

**Das ist die Antwort auf die Frage nach mehreren Standorten.** Wenn die
Installation mehrere Eintrittspunkte haben soll — Besucher an Standort A starten
an einem anderen Punkt der 3D-Welt als an Standort B —, braucht das nicht
mehrere Router. Drei Namen auf einem Gerät genügen, jeder mit eigenem
Adressbereich. Der Server sieht an der Adresse, aus welchem Netz jemand kommt.

Der einzige Unterschied zu drei Geräten ist die **Reichweite**: Ein Router
strahlt von einem Punkt. Liegen die Standorte in verschiedenen Räumen, kommt das
Signal nicht überall an. Liegen sie im selben Raum, ist ein Gerät besser —
weniger Kabel, weniger Strom, weniger, das ausfallen kann.

## 7 · Der Slate AX ist ein kleiner Computer

Das Gerät heißt vollständig **GL.iNet GL-AXT1800**, Beiname *Slate AX*. Darauf
läuft **OpenWrt** — ein Linux für Router.

Das ist der entscheidende Punkt zum Verständnis: Es ist kein Gerät mit Knöpfen,
sondern ein Computer mit Dateien und Programmen. Du kannst dich darauf anmelden,
Dateien ansehen und Befehle ausführen, genau wie auf einem Server.

GL.iNet liefert OpenWrt mit einer eigenen Oberfläche darüber aus. Deshalb gibt
es **drei Wege** auf dasselbe Gerät:

| Weg | Wie | Wofür |
|---|---|---|
| GL.iNet-Panel | `http://192.168.8.1` im Browser | WLAN-Name, Passwort, die alltäglichen Dinge |
| LuCI | im Panel unter *System → Erweiterte Einstellungen* | die volle OpenWrt-Oberfläche, alles einstellbar |
| SSH | `ssh root@192.168.8.1` im Terminal | dasselbe als Befehle, nachvollziehbar und wiederholbar |

**Alle drei ändern dieselben Dateien.** Was du im Panel klickst, siehst du per
SSH in der Konfiguration wieder.

## 8 · Wie man OpenWrt konfiguriert: `uci`

Die Einstellungen liegen in Textdateien unter `/etc/config/`. Für das Netz ist
`/etc/config/dhcp` zuständig — Name trügt, dort steht auch das DNS-Verzeichnis
aus Abschnitt 4.

Man bearbeitet diese Dateien nicht von Hand, sondern über ein Programm namens
**`uci`** (*Unified Configuration Interface*). Es liest und schreibt sie, und es
weiß, welches Programm danach neu zu starten ist.

Ansehen:

```sh
uci show dhcp
```

Eine Einstellung setzen und behalten:

```sh
uci set dhcp.@domain[0].ip='192.168.8.10'
uci commit dhcp
```

**Ohne `uci commit` ist die Änderung nach einem Neustart weg.** Bis dahin liegt
sie nur in einem Zwischenspeicher.

Und danach muss das betroffene Programm neu lesen:

```sh
/etc/init.d/dnsmasq restart
```

**Warum nicht direkt in `/etc/dnsmasq.conf` schreiben?** Weil OpenWrt diese
Datei bei jedem Start aus der `uci`-Konfiguration neu erzeugt. Eine Änderung
darin wäre beim nächsten Neustart verschwunden.

## 9 · Auf den Router kommen: zwei Stolperstellen

Der Zugang per SSH hat zwei Eigenheiten, die je eine halbe Stunde kosten, wenn
man sie nicht kennt.

**Passwörter nimmt das Gerät über SSH nicht an.** Jedes wird abgelehnt, auch das
richtige. Ein im Panel neu gesetztes Admin-Passwort ändert daran nichts. Der
Zugang läuft über einen **SSH-Schlüssel**: ein Paar aus zwei Dateien auf deinem
PC, von denen die öffentliche auf den Router kommt (über LuCI, *System →
Administration*, Feld *SSH-Keys*) und die private bei dir bleibt.

**SSH bietet von sich aus nur Schlüssel mit Standardnamen an** — `id_rsa`,
`id_ed25519` und ein paar weitere. Heißt deiner anders, wie hier `id_ionos`,
wird er nie angeboten, und die Anmeldung scheitert, obwohl der Schlüssel längst
auf dem Gerät liegt. Man muss ihn bei jedem Aufruf nennen:

```sh
ssh -o "IdentityFile ~/.ssh/id_ionos" -o IdentitiesOnly=yes root@192.168.8.1
```

## 10 · Was am 2026-09-11 eingerichtet wurde

Der Aufbau, mit allem aus den Abschnitten 1 bis 9:

```
Besucher-Handy ---WLAN---> Slate AX (192.168.8.1) ---Kabel---> PC (192.168.8.10)
                            dnsmasq: DHCP + DNS
                            WAN-Port: leer
```

Drei Änderungen am Router, mehr nicht:

| Was | Womit | Wofür |
|---|---|---|
| Der Name zeigt auf den PC | `uci add dhcp domain` | Abschnitt 4 — das eigene DNS-Verzeichnis |
| Der PC bekommt immer `192.168.8.10` | `uci add dhcp host` mit der MAC | Abschnitt 3 — die Reservierung |
| Der SSH-Schlüssel liegt auf dem Gerät | LuCI, Feld *SSH-Keys* | Abschnitt 9 |

**Am WLAN wurde nichts geändert.** Es läuft mit den Namen, die ab Werk
eingestellt waren.

**Der WAN-Port blieb leer.** Das ist die wichtigste Einstellung überhaupt, und
sie besteht darin, ein Kabel *nicht* einzustecken. Der Router hat dadurch kein
Internet — und genau dieser Zustand ist die Installation in der Halle.

## 11 · Was der Router nicht tut

Drei Dinge, die man ihm leicht zuschreibt:

**Er liefert die Seite nicht aus.** Das tut der PC. Der Router sagt den Handys
nur, wo der PC ist.

**Er macht kein HTTPS.** Das Zertifikat liegt auf dem PC, und der verschlüsselt.
Der Router sieht nur Datenpakete, die er weiterreicht.

**Er entscheidet nicht, wer durchkommt.** Auf dem Zielrechner steht eine eigene
Firewall — unter Windows blockiert sie eingehende Verbindungen aus fremden
Netzen, bis eine Regel sie erlaubt. Das ist der häufigste Grund, warum ein Handy
den Rechner nicht erreicht, obwohl am Router alles stimmt.

## 12 · Ein Router ist ein schlechter Test-Client

Beim Einrichten liegt es nahe, vom Router aus zu prüfen, ob der Rechner
erreichbar ist. Das führt in die Irre:

| Test | Was wirklich passiert |
|---|---|
| `nc -z` | Die abgespeckte Programmsammlung auf dem Router kennt diese Option nicht und meldet immer „zu" |
| `wget https://…` | Die Verbindung steht, aber der Router kennt das Zertifikat nicht — sein Vorrat an Wurzelzertifikaten ist Jahre alt |
| `ping` | Prüft ein anderes Protokoll als der Browser; eine Firewall-Regel für Webseiten erlaubt es nicht |

**Für die Frage „kommt ein Besucher durch" taugt nur ein Besucher-Gerät.** Ein
Handy im WLAN, mit dem Browser, den ein Gast auch benutzen würde.

## Verwandt

- `zaehlen\wwww\router.md` — dieselben Schritte als Befehle zum Nachmachen
- `claude-notes\drei-orte-einer-anwendung.md` — warum die Installation ein eigener Ort ist und was dort noch offen ist
- `zaehlen\wwww\ARCHITEKTUR.md` — wo welcher Teil auf welchem Rechner liegt
