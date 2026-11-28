# Audiovisuelle Installation — Aufbau- und Betriebsdokumentation

**Prinzip:** Ein einziger externer Taster schaltet die gesamte Installation ein und aus.
Alles Weitere (Max/MSP, Webserver, Auslieferung der Webseite ins WLAN) läuft vollautomatisch.

---

## TEIL 1 — Für die Ausstellungsaufsicht

### Installation einschalten

1. Sicherstellen, dass die Steckdosenleiste eingeschaltet ist (Schalter leuchtet).
2. **Externen Taster einmal kurz drücken.**
3. Warten: Der PC bootet, meldet sich selbst an und startet alle Programme automatisch.
   → Nach ca. **60–90 Sekunden** ist die Installation vollständig betriebsbereit.
4. Kontrolle: Läuft Ton aus den Lautsprechern? Ist die Webseite auf dem Kontroll-Tablet erreichbar?

### Installation ausschalten

1. **Externen Taster einmal kurz drücken.** (nicht gedrückt halten!)
2. Der PC fährt selbstständig sauber herunter, ca. **20–40 Sekunden.**
3. Steckdosenleiste kann danach ausgeschaltet werden — muss aber nicht.

### Wichtige Regeln

| Regel | Grund |
|---|---|
| Taster immer nur **kurz** drücken (unter 1 Sekunde) | Langes Halten (4+ Sek.) erzwingt einen harten Stromabbruch |
| Nach dem Ausschalten **mindestens 10 Sekunden warten**, bevor wieder eingeschaltet wird | Sonst startet der PC evtl. nicht sauber |
| Niemals Tastatur/Maus abziehen, während die Installation läuft | Kann Max/MSP zum Absturz bringen |
| Steckdosenleiste **nicht** ausschalten, solange der PC noch läuft | Entspricht einem Stromausfall |

### Wenn etwas nicht funktioniert

**Kein Ton / keine Visuals nach 2 Minuten:**
Taster kurz drücken (Herunterfahren), 15 Sekunden warten, erneut drücken.

**Webseite auf Besuchergeräten nicht erreichbar:**
Router neu starten (Stecker ziehen, 10 Sek. warten, wieder einstecken). Danach Installation wie oben neu starten.

**Der PC reagiert gar nicht auf den Taster:**
Taster **10 Sekunden gedrückt halten** → erzwungenes Ausschalten. Danach normal neu starten.
Wenn auch das nicht hilft: Stromversorgung prüfen, dann technische Betreuung kontaktieren.

**Kontakt technische Betreuung:** _________________________

---

## TEIL 2 — Technischer Aufbau

### 2.1 Hardware: Externer Taster

Der externe Taster wird **parallel zum internen Power-Button** an den Frontpanel-Header des Mainboards angeschlossen (2-poliger Pin-Header, beschriftet `PWR_SW` / `POWER SW`).

- Es handelt sich um einen reinen Schließkontakt — keine Polarität, keine Spannung, keine Elektronik nötig.
- **Zwingend ein tastender Schalter** (Taster), kein rastender Kippschalter. Ein dauerhaft geschlossener Kontakt wird vom Mainboard als „Power-Button gehalten" interpretiert und verhindert den Betrieb.
- Empfehlung: beleuchteter Industrietaster (z. B. 19 mm Vandal-Proof) — die Beleuchtung kann an einen 5V-Header oder ein separates USB-Netzteil gehängt werden und signalisiert der Aufsicht den Betriebszustand.
- Kabelweg nach außen über eine Frontpanel-Verlängerung; Kabel im Gehäuse und im Sockel zugentlasten.
- Der interne Gehäuse-Taster kann parallel angeschlossen bleiben (beide funktionieren dann).

### 2.2 BIOS / UEFI

| Einstellung | Wert | Zweck |
|---|---|---|
| Restore on AC Power Loss / Power On After Power Failure | **Power On** | Nach Stromausfall startet der PC selbstständig wieder |
| Boot-Reihenfolge | Fest auf System-SSD | Verhindert Bootmenü-Hänger |
| Fast Boot | Deaktiviert | Stabilerer, reproduzierbarer Bootvorgang |
| Power Button Behavior | Standard / Power On | Nicht auf „Suspend" stellen |
| Secure Boot / Boot-Passwort | Kein Passwort | Sonst blockiert der Start ohne Tastatureingabe |

### 2.3 Windows-Konfiguration

**Automatische Anmeldung**
Mit Sysinternals `Autologon.exe` einrichten (zuverlässiger als `netplwiz`). Ohne Autologin bleibt der PC am Anmeldebildschirm stehen.

**Energieoptionen** (Systemsteuerung → Energieoptionen)

- Energiesparplan: Höchstleistung
- Bildschirm ausschalten nach: **Nie**
- Energiesparmodus/Ruhezustand nach: **Nie**
- Festplatte ausschalten: **Nie**
- „Beim Drücken des Netzschalters": **Herunterfahren**
  → Das ist der entscheidende Punkt: Damit löst der externe Taster im laufenden Betrieb ein sauberes Shutdown aus, ohne Rückfrage-Dialog.
- Schnellstart (Fast Startup) deaktivieren
- USB-Selektives Energiesparen: deaktiviert (verhindert Aussetzer bei Audio-Interfaces)

**Windows Update**

- Auf getaktete Verbindung stellen oder Updates für die Ausstellungsdauer pausieren
- Aktive Nutzungszeit auf 24 h setzen, automatische Neustarts unterbinden
- Andernfalls kann sich Windows mitten in der Ausstellung neu starten

**Weitere Deaktivierungen**

- Bildschirmschoner: aus
- Sperrbildschirm nach Inaktivität: aus (`Systemsteuerung → Anmeldeoptionen`)
- Benachrichtigungen / Fokusassistent: alles stumm
- OneDrive-Autostart, Antivirus-Popups: deaktivieren

### 2.4 Autostart der Anwendungen

Alle Programme werden über die **Aufgabenplanung** gestartet (zuverlässiger als der Autostart-Ordner, da Verzögerung und Rechte steuerbar).

**Aufgabe anlegen:**

- Trigger: *Bei Anmeldung*, Verzögerung **30 Sekunden** (gibt Netzwerk/Audio-Treibern Zeit)
- Ausführen mit höchsten Berechtigungen
- Bedingung „Nur starten, wenn Netzbetrieb": **deaktivieren**
- Aktion: Startskript aufrufen

**`C:\Installation\start.bat`**

```bat
@echo off
REM --- Webserver fuer Three.js / RNBO-Frontend ---
cd /d "C:\Installation\webroot"
start "" /min node server.js

REM --- kurz warten, damit der Server oben ist ---
timeout /t 5 /nobreak > nul

REM --- Max/MSP mit Installations-Patch ---
start "" "C:\Program Files\Cycling '74\Max 9\Max.exe" "C:\Installation\patch.maxpat"
```

**Absicherung gegen Abstürze (empfohlen):**
Webserver und ggf. Max über **NSSM** (Non-Sucking Service Manager) als überwachte Dienste registrieren. NSSM startet den Prozess automatisch neu, falls er abstürzt — bei mehrwöchigen Ausstellungen praktisch unverzichtbar.

```
nssm install InstallationWebserver "C:\Program Files\nodejs\node.exe" "C:\Installation\webroot\server.js"
nssm set InstallationWebserver AppDirectory "C:\Installation\webroot"
nssm set InstallationWebserver Start SERVICE_AUTO_START
```

### 2.5 Auslieferung der Webseite ins Besuchernetz

**Webserver**

- Muss an `0.0.0.0:<Port>` gebunden sein, **nicht** an `127.0.0.1` — sonst ist er nur lokal erreichbar.
- Beispiel Node/Express: `app.listen(8080, '0.0.0.0')`
- Windows-Firewall: eingehende Regel für den Port (z. B. TCP 8080) für das Profil „Privat" freigeben.

**Router**

- DHCP-Reservierung für die MAC-Adresse des PCs → feste IP, z. B. `192.168.1.50`
- WLAN-SSID und Passwort gut sichtbar am Ausstellungsort ausschildern
- Optional Captive Portal / DNS-Umleitung, damit Besucher automatisch auf der Seite landen
- Alternativ mDNS-Hostname (`installation.local`) — funktioniert auf iOS zuverlässig, auf Android nicht durchgängig

**Besucherzugang**

```
WLAN:    <SSID>
Passwort: <Passwort>
Adresse: http://192.168.1.50:8080
```

**RNBO-Hinweis**
Wenn der RNBO-Patch als **Web-Export (WebAssembly)** vorliegt, läuft die Audio-Engine direkt im Browser des Besuchers — Max/MSP muss dann nur noch die Rauminstallation (Lautsprecher vor Ort) bedienen oder kann ganz entfallen. Läuft die Klangsynthese hingegen zentral in Max und die Webseite dient als Steuerung/Visualisierung, muss die Kommunikation (z. B. WebSocket → OSC) im Startskript mitgestartet werden.

---

## TEIL 3 — Checkliste

### Vor Ausstellungsbeginn (einmalig)

- [ ] Externer Taster montiert, Kabel zugentlastet, Funktion geprüft
- [ ] BIOS-Einstellungen gesetzt (AC Power Loss = On)
- [ ] Autologin eingerichtet und getestet
- [ ] Energieoptionen gesetzt, Netzschalter = „Herunterfahren"
- [ ] Windows Update pausiert
- [ ] Startskript / Aufgabenplanung getestet
- [ ] Firewall-Regel gesetzt
- [ ] DHCP-Reservierung im Router eingetragen
- [ ] Webseite von mindestens 2 fremden Geräten (iOS + Android) getestet
- [ ] **Vollständiger Kalttest:** Strom trennen → Strom anlegen → Taster → alles läuft ohne Eingriff
- [ ] Mindestens einen 24-Stunden-Dauerlauf durchgeführt
- [ ] Aufsicht eingewiesen, Teil 1 ausgedruckt am Ort hinterlegt

### Täglich (Aufsicht)

- [ ] Öffnen: Taster drücken, nach 90 Sek. Ton und Webseite prüfen
- [ ] Schließen: Taster drücken, warten bis PC aus ist
