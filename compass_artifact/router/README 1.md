# wwww — die Seite, an drei Orten

Dieses Verzeichnis liefert `site\` aus, an drei Orten mit demselben Image: auf diesem PC, auf dem IONOS-VPS und auf dem Installationsrechner ohne Internet.

**Warum drei und nicht zwei**, und woran der dritte scheitert, wenn man ihn wie den zweiten behandelt, steht im Vault: `C\claude-notes\drei-orte-einer-anwendung.md`. Hier stehen nur die Befehle.

## Was hier liegt

| Datei | Tut was |
|---|---|
| `site/` | Die Seite. `index.html` und `vendor/three/` — three.js liegt lokal, nicht auf unpkg. |
| `Dockerfile` · `Caddyfile` | Bauen das Image: ein Dateiserver auf Port 80, ohne TLS. |
| `docker-compose.yml` | An allen drei Orten identisch. |
| `compose.installation.yml` | Overlay, nur vor Ort: ein TLS-Terminator davor. |
| `caddy-vorort/Caddyfile` | Dessen Konfiguration — drei Zeilen, im git, diffbar. |
| `.env.example` | Die vollstaendige Liste der Unterschiede zwischen den Orten. |
| `ARCHITEKTUR.md` | Was wo liegt: die drei Orte, die Pfade auf jedem Rechner, wer welchen Port haelt. |
| `router.md` | Der Slate AX vor Ort -- Zugang, DNS, feste Adresse, Firewall, Captive Portal. Aus dem Lauf vom 2026-09-11. |
| `OFFEN.md` | Was an diesem Projekt fehlt -- Anwendung, Aufbau, Transport, Erklaerungen. |
| `werkzeug/qr.py` | QR-Codes ohne Bibliothek und ohne Internet. `python werkzeug/qr.py "<adresse>" ziel.svg` |
| `qr/` | Die Standort-Codes und `standorte.html` zum Drucken -- ein Blatt je Ort. |

## Einmal pro Maschine

```bash
docker network create proxy
cp .env.example .env    # und ausfuellen
```

Das Netz `proxy` heisst auf dem VPS genauso und existiert dort schon — der Nginx Proxy Manager haengt darin.

## Stage — dieser PC

```bash
docker compose up -d --build
```

Dann `http://localhost:8080`. Der Kreisel bleibt hier stumm: `localhost` ist zwar ein Secure Context, aber der PC hat keine Sensoren. Zum Testen der Gestensteuerung braucht es ein Handy, und damit HTTPS unter einem Namen — siehe *Vor Ort*.

## Prod — der IONOS-VPS

Laeuft seit dem 2026-09-10 unter `julianniklasheynert.xyz` und `www.` dort.

```bash
ssh ionos
cd /opt/dienste/wwww && git pull && docker compose up -d --build
```

**Der Klon braucht einen Deploy Key.** Das Repo ist privat, also liest der Server
es ueber SSH: der Schluessel liegt in `~/.ssh/github_wwww`, sein oeffentlicher
Teil steht bei GitHub unter *Settings -> Deploy keys*, nur mit Lesezugriff. Die
Remote-URL ist deshalb `git@github.com:junihey/wwww.git`, nicht die https-Form.

**`APP_BIND` ist dort ein anderer Wert.** Port 8080 gehoert auf dem VPS
code-server; in der `.env` steht `127.0.0.1:8090`.

Im Nginx Proxy Manager zeigt der Host auf **`wwww`** Port **80** -- der
Containername, keine Adresse. Beide haengen im Docker-Netz `proxy`, darin loest
Docker den Namen auf. Ein `w` zu wenig ergibt eine 502, sonst nichts.

**Force SSL muss an sein.** Sonst antwortet der Proxy auch auf `http`, und dort
ist die Seite kein Secure Context: `DeviceOrientationEvent.requestPermission()`
existiert nicht, der Knopf tut nichts, und der Browser meldet keinen Fehler.
Pruefen laesst es sich in einer Zeile -- 301 ist richtig, 200 ist der Fehler:

```bash
curl -s -o /dev/null -w "%{http_code} -> %{redirect_url}
" http://julianniklasheynert.xyz/
```

**Der Befehl oben gilt, solange es nur zwei Orte gibt.** Er baut auf dem Server neu, und ein Bau ist nie bitgenau derselbe: `FROM caddy:2.10-alpine` zeigt in drei Wochen auf ein anderes Image. Bei zwei Orten kostet das nichts, weil du beim Ausrollen zusiehst. Sobald das erste Buendel gepackt wird, gilt der Abschnitt darunter statt dieses hier.

## Der Weg an die drei Orte, sobald die Installation dazukommt

**Einmal bauen, ueberall dasselbe Image laden.** Zwei Bauten aus demselben Commit ergeben zwei verschiedene Images; vor Ort merkst du das zum ersten Mal in der Halle.

Version festnageln, auf diesem PC:

```bash
docker build -t wwww:0.2.0 .
git tag v0.2.0 && git push --tags
sed -i 's/wwww:0.1.0/wwww:0.2.0/' docker-compose.yml
```

Ausliefern — an beide Orte dieselbe Datei:

```bash
docker save wwww:0.2.0 -o wwww-0.2.0.tar
scp wwww-0.2.0.tar ionos:~/           # nach Prod
cp  wwww-0.2.0.tar buendel/           # ins Buendel
```

**Ein Image reicht nicht.** Vor Ort laeuft neben dem Anwendungscontainer ein
zweiter: der TLS-Terminator aus `caddy:2.10-alpine`. Der steckt nicht im eigenen
Image und wuerde nachgeladen -- ohne Internet ein Abbruch. Die Liste nicht von
Hand pflegen, sondern compose fragen:

```bash
docker compose -f docker-compose.yml -f compose.installation.yml config --images
```

Jede Zeile daraus bekommt ein eigenes `docker save`. **Auf einem Rechner, der
schon einmal gebaut hat, faellt das Fehlen nie auf** -- das Image liegt dort
laengst. Es fehlt nur dort, wo nichts ist, und genau dagegen wird ein Buendel
getestet.

Auf dem Ziel:

```bash
docker load -i wwww-0.2.0.tar
docker compose up -d                  # ohne --build
```

Pruefen, dass wirklich dasselbe laeuft — die Zahl muss auf jeder Maschine gleich sein:

```bash
docker image inspect --format '{{.Id}}' wwww:0.2.0
```

## Das Zertifikat holen

Die Installation braucht ein echtes Zertifikat, aber vor Ort ist kein Internet. Die **DNS-Challenge** loest das: Let's Encrypt prueft einen TXT-Eintrag in der Zone statt einen erreichbaren Server. Internet nur zum Ausstellen, nicht zum Betrieb.

Die Domain liegt bei IONOS, und `lego` spricht dessen DNS-API. Der Schluessel kommt aus dem IONOS Developer Portal und steht in einer Datei ausserhalb dieses Repos:

```bash
# ~/.config/ionos/credentials, Rechte 600
IONOS_API_KEY=<publicprefix>.<secret>
```

Holen -- unter Windows in Git Bash, deshalb MSYS_NO_PATHCONV und Windows-Pfade:

```bash
MSYS_NO_PATHCONV=1 docker run --rm   --env-file "C:/Users/nolte/.config/ionos/credentials"   -v "C:/Users/nolte/Desktop/zaehlen/wwww/certs:/data"   goacme/lego run     --dns ionos     --dns.resolvers 8.8.8.8:53,1.1.1.1:53     --domains installation.julianniklasheynert.xyz     --email DEINE@ADRESSE     --path /data --accept-tos

mkdir -p certs/live
cp certs/certificates/installation.julianniklasheynert.xyz.crt certs/live/cert.pem
cp certs/certificates/installation.julianniklasheynert.xyz.key certs/live/key.pem
```

**`--dns.resolvers` ist nicht Zierrat, sondern der Unterschied zwischen einer
Minute und einem Abbruch nach 15.** Docker Desktop unter Windows haengt seinen
eigenen DNS-Weiterleiter unter 192.168.65.7 in den Container, und der
beantwortet keine Anfragen, die ein Programm direkt stellt. lego wartet dann auf
eine Verbreitung, die es nie zu sehen bekommt, und bricht mit `i/o timeout` ab.
8.8.8.8 und 1.1.1.1 erreicht derselbe Container ohne Umstand. Gemessen am
2026-09-09, zwei Fehlversuche und eine Viertelstunde teuer.

**Das Zertifikat liegt getrennt vom lego-Zustand.** Unter `certs/accounts/` steht
der private Schluessel des ACME-Kontos; er hat im Container nichts zu suchen.
Deshalb zeigt `TLS_CERT_DIR` auf `certs/live` und nicht auf `certs`. Denselben
Ordner `certs/accounts/` sichern -- ohne ihn entsteht beim naechsten Mal ein
neues Konto.

**Alle 90 Tage neu, vor jedem Aufbau.** Der Installationsrechner muss dafuer nicht eingeschaltet werden — es sind zwei Dateien, die ins Buendel wandern.

## Vor Ort

**Was im Buendel liegt**, einmal von Hand gepackt am 2026-09-11, zusammen 44 MB:

| Teil | Womit | Groesse |
|---|---|---|
| `wwww-0.1.0.tar` | `docker save wwww:0.1.0` | 22 MB |
| `caddy-2.10-alpine.tar` | `docker save caddy:2.10-alpine` | 22 MB |
| `wwww-repo.bundle` | `git bundle create … --all` -- eine Datei mit der ganzen Historie | 280 KB |
| `.env` | kopiert, mit `SITE_HOST` und `TLS_CERT_DIR` | |
| `certs/live/` | `cert.pem` und `key.pem` | |
| `LIESMICH.txt` | damit vor Ort niemand raten muss | |

```bash
docker load -i wwww-0.1.0.tar
docker load -i caddy-2.10-alpine.tar
git clone wwww-repo.bundle wwww && cd wwww
cp ../.env . && cp -r ../certs .
docker network create proxy
docker compose -f docker-compose.yml -f compose.installation.yml up -d
```

Kein `--build`, kein `git pull`, kein `docker pull`. Braeuchte es eines davon,
haette das Buendel gefehlt.

**Die Handys muessen den Namen aufloesen.** Ohne Internet gibt es keinen oeffentlichen DNS; das uebernimmt `dnsmasq` auf dem Router. Wie, steht in `router.md` -- dort auch die zwei Stellen, die sonst eine halbe Stunde kosten: die SSH-Anmeldung am Router und die Windows-Firewall.

Ruft ein Handy die IP statt des Namens auf, passt das Zertifikat nicht und die Sensoren bleiben gesperrt.

## Was gemessen ist

Am 2026-09-09 in einem Docker-Netz mit `--internal`, also nachweislich ohne
Internet -- ein Container darin erreichte Let's Encrypt nicht:

| Was | Ergebnis |
|---|---|
| Zertifikat | `CN=installation.julianniklasheynert.xyz`, Let's Encrypt, gueltig bis 2026-12-08 |
| Caddy-Start ohne Netz | nach 4 Sekunden bereit -- kein Timeout durch OCSP |
| ACME-Zeilen im Caddy-Log | keine. Die `tls`-Zeile mit expliziten Pfaden haelt, was sie soll. |
| Abruf im isolierten Netz | `HTTP 200` unter dem echten Namen, Zertifikatskette vom Client akzeptiert |
| three.js aus dem Container | 1.272.972 Bytes, ohne Internet |

**Und am 2026-09-11 der ganze Aufbau vor Ort**, mit dem Slate AX: ein Handy im WLAN ohne Uplink hat die Seite unter `installation.julianniklasheynert.xyz` geladen, das Zertifikat wurde ohne Warnung akzeptiert, und die Sensoren lieferten Daten. Einzelheiten in `router.md`.

**Und am 2026-09-10 auf einem echten Handy**, ueber Prod unter `julianniklasheynert.xyz`: die Seite laedt, der Knopf *Enable Gyroscope* gibt die Sensoren frei, und die Ansicht folgt der Bewegung. Damit ist die Annahme gemessen, auf der die ganze Zertifikatsarbeit steht -- ein echtes Zertifikat unter einem echten Namen genuegt dem Browser.

**Und am 2026-09-14 die kurzen Adressen auf den QR-Codes**: ein iPhone im WLAN des Routers hat einen Code mit `HTTP://W/1` gescannt und landete ohne Warnung auf `installation.julianniklasheynert.xyz/?entry=a`, im Caddy-Protokoll standen beide Anfragen. Die gedruckten Codes sind danach neu erzeugt, 21x21 Module bei Fehlerkorrektur H, und von zxing-cpp gelesen -- von einer Handykamera noch nicht. Einzelheiten in `router.md`.

## Was hier ungeprueft ist

- **Ob `dnsmasq` auf dem Slate AX so mitspielt.** Die GL.iNet-Oberflaeche schreibt eigene Abschnitte in die Konfiguration.
- **Das Captive-Portal-Fenster ist kein Browser.** Auf iOS ist es der Captive Network Assistant, auf Android eine eingeschraenkte WebView; `DeviceOrientationEvent.requestPermission()` gibt es dort nicht. Das Portal darf nur einen Link zeigen, nicht die Anwendung sein.
- **Ein Handy hat die Seite noch nie ohne Internet geladen.** Der Sensor-Test lief ueber Prod; vor Ort kommt der Router zwischen Handy und Rechner.
