# discord
# ==01.01.2026 - 15.03.2026==
## 20260501
- timestretching [[DAFx26_tmpl.pdf]]
	- there are other shapes that could be used in reconstruction, some that might be interesting and still pretty antialiased. The use of OLA for time stretching surprised me, I imagine you could take a (subsample accurate) concatenative approach here with decent results too. I think it could be interesting to expand this technique with transient detection.
	- keyframes individually adapts to complexity of waveform, therefore variable length (WSOLA with fixed length) 
	- analysis turns a sample-based signal stream into a series of splines, and the resynthesis turns splines back into samples
		- something like data compression, because there are less keyframes than sample series
	- [[timestretch with extrema sampling.maxpat]]
	- K is the number of keyframes to crossfade over, but keyframes are variably-sized according to the content -- transients are going to have very short segments, sustained tones will have long segments, and so the cross-fade is adaptive to the content.
> [!NOTE]- additional tweaks!!! https://discord.com/channels/289378508247924738/1486514488256761926
>
> 1. A couple of things I spotted: `t_temp += temprate * pitchrate;` Shouldn't this just be `t_temp += temprate;` ? I figure that both playheads should be advancing at the same rate; the 2nd playhead shouldn't be speeding up? I do see that they have the equivalent of `t_temp += temprate * pitchrate;` in the paper, but I can't understand why; maybe it is a typo? It's hard to hear a difference, but I think it sounds slightly clearer without this temprate multiplier. I simplified the logic slightly to reduce duplication, looks like this:
>     
>     `// not crossfading, just output the normal playhead: y, play_m = interpolate(keyframes, play, M, m = play_m); // advance it: play += pitchrate; ref += timerate; // if we are crossfadeing: if (splicing) {     // get & advance temporary playhead:     y_temp, temp_m = interpolate(keyframes, temp, M, m = temp_m);     temp += pitchrate;     //t_temp += temprate * pitchrate;     t_temp += temprate;          // crossfade over to it:     y = mix(y, y_temp, t_temp);          // is the crossfade done?     if (t_temp >= 1) {         play = temp;         play_m = temp_m;         splicing = 0;     } }  out1 = y;` 
>     
>     In `analyze()` you are getting the slope by comparing the next and previous samples (a 2 sample period); but I think it would be fine to compare current and previous (as they do in the paper). I.e. `deltas.poke((x.peek(i) - x.peek(i-1)), i);` rather than `deltas.poke((x.peek(i+1) - x.peek(i-1))/2, i);` -- again, I can't hear any difference, but this should make it easier to translate the analysis into a real-time process with no dependency on the future ![🙂](https://discord.com/assets/0424e06a82d250e2.svg) I think that in place of `v_m = B(x, n_m);` you could also use `v_m = x.peek(n_m, interp="cubic");`, meaning you don't need function `B` anymore.
>     
> 2. Also wasn't sure that it was necessary to dcblock the output.
>     
> 3. ### Graham Wakefield _—_ 05.04.2026 21:44
>     
>     And now I play with this more, and more and more convinced that the real value here is not the resynthesis, but rather the analysis-driven adaptive crossfade duration.  
>     The two things are really quite separate. There's a resynthesis method here, using cubic splines between keyframes, which has a kind of "tape saturation" effect. And there's a time-stretching method, which is essentially a crossfade over N samples, where N is the length of K keyframes, i.e. the next K peaks & troughs. Both of them use the same analysis method (peak/trough detection) but you don't have to use the resynthesis method for the crossfade stretching. Actually you can just trigger a crossfade between the raw input buffer content over N samples, and it does the same adaptive timestretching, without the saturation compression. Maybe the resynthesis can help avoid aliasing a little when pitching up, but other resampling AA methods here would be better, and with fewer artefacts. On the other hand, the artefacts may be desirable, but they are not tied to applications of time stretching in particular -- they could be used for many different purposes.
>     
> 4. ### exitdevice _—_ 05.04.2026 23:39
>     
>     Regarding `t_temp += temprate * pitchrate;` vs `t_temp += temprate;`: I believe this _is_ making them advance at the same rate. The playhead will traverse L samples in `L / pitchrate` ticks - we are speeding/slowing the temp head so it does the same. At least I think that's correct..the paper talks about it right after equation (12) in section 2.7. Though my head is spinning a bit, I must admit ![😅](https://discord.com/assets/5134d215343b97ef.svg)
>     
> 1. In `analyze()` - I'm following the paper on that actually! It is storing the delta as B'(x, n), which should simplify to the 2 sample period difference. But maybe switching it so it's real-time friendly is a good idea..
>     
> 2. I like the refactoring you did! Much cleaner. Also, good call on that switch to `interp=cubic` to get rid of the `B` function. Cut the fat!
>     
> 3. If I'm learning anything from this discussion, it's that the finer points don't matter lol
>     
> 4. ### exitdevice _—_ 05.04.2026 23:50
>     
>     Oh and I did this because I had a constant non-zero value going to my live.gain~ when I had it in one-shot mode. But of course now I can't replicate that behavior...maybe that was fixed by your cleanup
>     
> 5. ### Graham Wakefield _—_ 06.04.2026 00:00
>     
>     Hmm, yes I suppose it is correct to scale temprate by pitchrate, so that crossfades go faster when the pitch is higher. Not sure what I was thinking there!
>     
> 6. ### exitdevice _—_ 06.04.2026 01:25
>     
>     You're totally right. Making a change to the interpolation like:
>     
>     `//y, play_m = interpolate(keyframes, play, M, m = play_m); y = peek(buf, play, interp="spline6");`
>     
>     cleans it up quite a bit (as long as you aren't pitching up, of course) (and changing the corresponding lines for the temp read)
>     
> 1. Or even with linear interpolation
- fft visual jitter manipulation [jackhwalters/The-Fast-Fourier-Transform-and-Spectral-Manipulation-in-Max-MSP-and-Jitter-beta: This project explores the mathematics of the Fast Fourier Transform (FFT) and their application in the programming environment Max, and the subsequent spectral effects that are possible in Max’s openGL extension Jitter.](https://github.com/jackhwalters/The-Fast-Fourier-Transform-and-Spectral-Manipulation-in-Max-MSP-and-Jitter-beta/tree/master)
- buffer based [spectrogram~ - Interactive Spectral Analyzer for Max](https://www.zacharyseldess.com/spectrogram/) 
- rnbo -> vst with codex https://www.youtube.com/watch?v=JF0r8S50i9U
- sound visualizations demonstrations [McDermott Lab](https://mcdermottlab.mit.edu/sounds.html)
- The way delay currently works, it will only ever be able to write one sample frame per sample of passing time (i.e. it does not allow random write access).  The workaround here is to use the Data directly to implement the delay.  In order to do this, you'll also need to implement the delay's write & read position indices.
	- ![[Pasted image 20260501150117.png]]
---
# [Claude Code und Codex für Software Entwickler - Sauberer Code | deutsch - YouTube](https://www.youtube.com/watch?v=6tS_mfSrh1M)
- Superset: [https://superset.sh/](https://www.youtube.com/redirect?event=comments&redir_token=QUFFLUhqbTZqRlRPYXZJZmlhR1ZCazlEcGdTdGhhWUVBQXxBQ3Jtc0trblVRV09jV1hMZ0NCUXRqWF93Ymk4VGtnMHY4QXRtQm1TbExPOENQb0ROb1RwWncybW56ZUFzcWlhaV9ValpSb09sWC1CcVlXV0NwUUMzV3lMVWs4djhCR3ZIdzZjajd0VHVtOUc2WDlMb2NNLXNnWQ&q=https%3A%2F%2Fsuperset.sh%2F) 
	- mehrere Worktrees (Kopieren des Codes) zum parallelen Arbeiten mehrerer Agents 
	- Alternative 1: manuelle Vervielfältigung des Codes und Arbeiten mit Continue Extension in VS Code möglich; 
	- Alternative 2: Du kannst in VS Code die Sidebar splitten oder die "Auxiliary Bar" (rechts) nutzen. So kannst du in der linken Sidebar den Continue-Chat offen haben und in der rechten ein Terminal mit **Claude Code** (via MCP) laufen lassen.
		- Vorteile Continue
			- Inline-Edits: Mal eben Cmd+I drücken, um einen Absatz in deiner Notiz umzuformulieren.
			- Kontext-Referenz: Du kannst mit @ direkt Dateien, offene Tabs oder Dokumentationen referenzieren, während du tippst.
			- Autocomplete: Das schnelle Vorschlagen von Sätzen oder Code-Snippets während des Schreibens.
			- Chat: Kurze Fragen zwischendurch, ohne das Fenster zu wechseln.
	- Unterscheidung Claude CLI / Continue
		- Continue (vorsichtiger): Arbeitet primär mit dem, was du ihm fütterst. Du markierst Text, drückst Cmd+L oder @file. Es ist ein "Top-Down"-Ansatz: Du führst die KI an die Hand.
		- Claude Code (mutiger): Hat eine eigene "Shell". Wenn du sagst: "Finde alle Notizen, die das Tag #unfertig haben, aber Informationen über 'Quantenphysik' enthalten, und fasse sie zusammen", scannt Claude selbstständig das Verzeichnis, liest die Dateien und entscheidet, welche relevant sind. Er braucht deine manuelle Auswahl nicht mehr. 
			- neue Dateien erstellen, bearbeiten und Ordnerstrukturen anlegen
			- Selbstkorrektur über Unit-Test, Linter, Validierungsskript (selbst schreiben lassen)
- Conductor: [https://conductor.build/](https://www.youtube.com/redirect?event=comments&redir_token=QUFFLUhqbEpiQnR2TElhazd3MGh1N2ZkUGZUWkVLOUUyZ3xBQ3Jtc0ttLThCUXZxa2FIYV9Za1ZtLWdMSXRVUmxNdm9NYkVmNzU5Z3RRMkoxc2VsMVRhWlVuMTNSNDhDRGp1WXM5SE5Fd2lGX2FjQmNEa3hQYU1MbDc2MVRqS0RCNlQyb19YLU9zQXhVNEoyZDFHNUR2SDA0UQ&q=https%3A%2F%2Fconductor.build%2F) 
- Paper: [https://paper.design/](https://www.youtube.com/redirect?event=comments&redir_token=QUFFLUhqbmoxUENJMkJ6NEVwMUd0ZTM5N1ZHbTRhOTJXUXxBQ3Jtc0tsemFlclEzclNEOXdKN2RQbnRGMzJ1aU9lVVJGNnhwRVU1V1VLS3RrY2Z2blRRUi1GeTMzX2ZqbF9MNVVkR1IyNC1aVDgyRHdkTXJ5dmtZcnVYNTk5ZmdMNTZEYm5FUmxVRGhEOWdsZnVwTWlvdUVwNA&q=https%3A%2F%2Fpaper.design%2F) 
- Ruler: [https://github.com/intellectronica/ruler](https://www.youtube.com/redirect?event=comments&redir_token=QUFFLUhqbm9XYkZMbDRXUHFfNGhfbGZtT09jYUFXVDB0QXxBQ3Jtc0trdGlkZElRbV9kYTA4TjZqQ194dlNRRXFqY3NwZkxKT0ZUZXdpdVR1X2t5RFpSYmtrX2J3TExBUE15QlBUejNYclIwWlBreEFQZXJldC1uMVd3dTZaODF6Vnk4SEFORGduYm5SbU1IZm5jUl9oTWhrZw&q=https%3A%2F%2Fgithub.com%2Fintellectronica%2Fruler)
	- agents.md global für alle Agents synchronisieren
	- Vergleich Skills
		- Kontextabhängige Informationsbündel
		- zusätzliches Wissen für bestimmtes, weiterführendes Knowledge
		- wird getriggert
		- Capability
		- Rules bei Cursor
		- Skill Creator Skill
		- gut für schmale Kontexte 
		- [The Agent Skills Directory](https://skills.sh/)
- Deepwiki: [DeepWiki MCP - Devin Docs](https://docs.devin.ai/work-with-devin/deepwiki-mcp); [DeepWiki | AI documentation you can talk to, for every repo](https://deepwiki.com/) 
	- aktualisierte Versionen von sämtlichen Libraries, wenn sie öffentlich auf github liegen
	- Verstehen und Befragen der Libraries
	- wenn es nicht bei github liegt: [Exa MCP - The Web Search MCP - Exa](https://exa.ai/docs/reference/exa-mcp); [Use exa-code: Fast, efficient web context for coding agents | Exa Blog](https://exa.ai/blog/exa-code)
	- "Always prefer deepwiki to research up-to-date information about a library. This only weeks for public codebases that are hosted on Github. Fall back to exa if the repo is not available on deepwiki."
- Auto-Compacting: LLM schreibt sich ab bestimmter Kontextgröße automatisch eine Zusammenfassung der Historie
	- lieber clear mit manual refactored context
- e.g. "Always take inspiration from existing code in this codebase to follow the established patterns." 
	- wie Templates e.g. "For new components: @components/button.tsx"
	- noch striktere Conventions mit typescript anstelle javascript 
		- strict flag in tsconfig aktivieren https://www.typescriptlang.org/tsconfig/#strict
- Linter mit strikten Regeln um Conventions einzuhalten
	- https://www.ultracite.ai/
## Ghosty Terminal for multiple Agents (mac)
---
# code-server für VS Code auf VPS (mobiles Coding)
- code-server installieren
```bash
wget -O install.sh https://code-server.dev/install.sh
sh install.sh
systemctl enable --now code-server@roott
```
- nano ~/.config/code-server/config.yaml
```bash
nano ~/.config/code-server/config.yaml
```
```bash
bind-addr: 0.0.0.1:8080
auth: password
password: DEIN_PASSWORT_HIER
cert: false
```
- code-server neu starten
```bash
systemctl restart code-server@root
```
- Node.js + Claude Code installieren
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install nodejs -y
npm install -g @anthropic-ai/claude-code
```
- Obsidian Vault auf den Server bringen
```bash
git config --global user.email "du@email.com"
git config --global user.name "Dein Name"
```
```bash
apt install git -y
git clone https://DEIN_TOKEN@github.com/DEIN_USERNAME/DEIN_VAULT.git /root/vault
```
- http://DEINE_IP:8080
	- port in cloud server freischalten
---
# christoph magnussen 20260415
[Das ULTIMATIVE Claude Code Tutorial 2026 | Alles was DU wissen musst in 35 Minuten! - YouTube](https://www.youtube.com/watch?v=vLwfguLz_qQ)
- Planungsmodus stellt Fragen zum weiteren Update des Plans
  - Auto-Compact wenn Initialprompt zu lang ist
  - "Yes, manually accept edits" auswählen, um die Schritte einzeln anzuzeigen
  - Screenshot von Schritten in Claude Code einfügen um zu lernen
---
# jamal bosch 20260417
- [OpenCode | Der Open-Source AI-Coding-Agent](https://opencode.ai/de)
---
# peter steinberger
## [Peter Steinberger — You Can Just Do Things - YouTube](https://www.youtube.com/watch?v=68BS5GCRcBo)
- https://context7.com/ ähnlich deepwiki und exa? - wird von ihm nicht benutzt
- [Fast and reliable end-to-end testing for modern web apps | Playwright](https://playwright.dev/)- manchmal genutzt, es füllt den Kontext, weshalb ein guter Test manchmal schwer wird
- [GLM Coding Plan — AI Coding Powered by GLM-5.1 & GLM-5-Turbo for Agents & IDEs](https://z.ai/subscribe) -recommended chinese
- [AI and backend workflows, orchestrated at any scale](https://www.inngest.com/) - lets you define “functions” (or “step functions”) in your code that respond to events (like `user/created` or `payment/succeeded`). Instead of wiring up your own message queues or workers, Inngest receives those events, schedules the right functions, and then executes them with automatic retries, delays, and observability. combines event streams, job queues, and state management into a single “reliability layer” for modern apps. That means you can stop running separate queue workers, cron‑job schedulers, or complex state‑machines, and instead write your workflows as plain functions in Node.js/TypeScript (or other supported runtimes) that Inngest orchestrates for you.
- bs log
	- custom logging tool
	- Instead of Peter manually checking a dashboard for errors and pasting them into the chat, he provides the agent with instructions on how to use `bs log`. (CLAUDE.md)
- [Firecrawl - Search, Scrape, and Interact with the Web for AI](https://www.firecrawl.dev/)
	-  "scrape" the documentation for the specific services his background server uses (like the Twitter API or database drivers).
	- Firecrawl's Role: It converts complex HTML/JS documentation into clean Markdown in real-time.
- CLAUDE.md
	- Claude extrahiert beim Sitzungsstart den `name` und die `description` aus jeder `SKILL.md`-Datei und lädt sie in den System-Prompt als `available_skills`-Liste. Bei jeder Nutzeranfrage wendet das Modell Sprachverständnis an (kein Keyword-Matching oder Regex), um passende Skills auszuwählen und automatisch aufzurufen.
	- füge `disable-model-invocation: true` hinzu, wenn nur manuelle `/skill`-Aufrufe gewünscht sind.
	- skills.md für ein indexing anlegen?
- starting a fresh stack/session to build the feature based on a previously generated plan is actually a **bad idea** for the following reasons:
	- **Loss of Contextual Priming:** As the model works through the planning phase, it naturally "loads" the context with all the necessary code bits and architectural understanding it needs to build. 
    - **Time Inefficiency:** If you move to a new session, the agent has to crawl and read all the files all over again, which can "almost double the time" it takes to build the feature. 
    - **Coherence:** Keeping the planning and building in the same session ensures that the code remains coherent with the original idea discussed in the context.
- plan the feature and its testing, that it fits within one token context
- Wenn ein bug auftritt, ein kleines example anfertigen, llm sagen dass es wie dieses arbeiten soll
- "Write the intent of what we wanted to do in code commands + documentation"
- environments: **Dev** is for the "chaos" of multiple AI agents writing code at once, while **Prod** is the stable, manual-tested destination where features are finally shipped to users.
- llms.txt 55:00 for indexinf of external resources
### CLAUDE.md
[[Peter Steinberger Claude.rtf]]
[[Peter Steinberger CLAUDE.pdf]]
[[Peter_Steinberger_CLAUDE]]
### inngest
- functions that respond to events, with automatic retries, delays and observability
- combines event streams, job queues, and state management
## eigener LLM-Vergleich
### Claude
- Design-first-workflows, Refactoring, pair-programming
- Claude Opus 4.6
- Claude Sonnet 4.6
### OpenAI
- GPT-5.3-Codex
	- token-effizient, straight forward, lesser prompts, shot-gun-implementation
	- Erklärungen und Dokumentation sind kürzer
### Gemini 2.5 Pro
---
# niklas steenfatt 20260420
- [Cloud-Speichermanager – Mehrere Cloud-Dienste verwalten | CloudMounter für Mac & Win](https://cloudmounter.net/de/)
---
# Emulation analoger Frequency Shifter 20260425
Gute Frage – es gibt mehrere Ansätze, die sich auch kombinieren lassen:
Phasenfehler emulieren
Der charakteristische Klang analoger Dome-Filter kommt partly vom leichten Phasenfehler über den Frequenzbereich. Du kannst das nachbilden durch:
 • Allpass-Filter-Ketten vor oder nach dem Shifter – mehrere Allpässe mit leicht “falsch” dimensionierten Frequenzen erzeugen ähnliche subtile Phasenverzerrungen
 • Manche Plugins erlauben es, den Hilbert-Filter durch eine Allpass-Approximation zu ersetzen statt der “perfekten” Berechnung
Thermisches Rauschen & Drift
 • Sehr leises Rosa Rauschen auf den Shift-Betrag modulieren (LFO mit sehr tiefer, irregulärer Frequenz ~0,01–0,1 Hz, minimale Tiefe)
 • Das simuliert die Temperaturdrift des analogen VCOs
 • In Eurorack: ein Slew-Limiter mit leichtem Rauschen auf dem FCV-Eingang
Sättigungscharakter
 • Leichte Röhren- oder Transistorsättigung vor und nach dem Shifter – analoge Schaltungen färben das Signal minimal durch nichtlineare Verzerrung
 • Ideal: ein Waveshaper mit sehr subtiler Soft-Clipping-Kurve (kaum hörbar, aber es verändert die Obertonstruktur)
Bandbreite begrenzen
Analoge Schaltungen rollen natürlich bei hohen Frequenzen ab. Ein leichtes High-Shelf-EQ-Roll-off ab ~14–16 kHz und ein subtiler High-Pass um 30–50 Hz imitiert das analoge Frequenzverhalten des A-126-2.
Latenz & Wandlercharakter
 • Minimale Pre-Delay von 0,3–1 ms kann den Eindruck “analoger Trägheit” erzeugen
 • Ein analoges Summierstadium oder eine Hardware-DI-Box im Signal kann den Rest erledigen
- Pragmatischer Tipp: Der größte Unterschied kommt oft gar nicht vom Shifter selbst, sondern vom Kontext. Ein analoges Eingangsstadium (Preamp, Transformer) vor einem digitalen Shifter bringt oft mehr Charakter als jede Software-Emulation der Schaltung selbst.​​​​​​​​​​​​​​​​
---
# [Claude Code + n8n: Komplette Apps & Workflows in Minuten bauen lassen - YouTube](https://www.youtube.com/watch?v=omWxyhPK7o4) 20260425
- Claude Ergänzung
  - Workflow bauen lassen
  - Fehler beheben
  - Frontend / Webapp bauen
  - Anwendung auf Server deployen
- n8n MCP [GitHub - czlonkowski/n8n-mcp: A MCP for Claude Desktop / Claude Code / Windsurf / Cursor to build n8n workflows for you · GitHub](https://github.com/czlonkowski/n8n-mcp)
  - n8n skills zum effizienten Nutzen des MCP Handbuchs [GitHub - czlonkowski/n8n-skills: n8n skillset for Claude Code to build flawless n8n workflows · GitHub](https://github.com/czlonkowski/n8n-skills)
  - per Prompt mit Claude integrieren 
- n8n mir URL und API per prompt in Claude integrieren
- /init zum Erstellen einer CLAUDE.md Datei
- ![[Pasted image 20260425162824.png]]
---
# git extension obsidian 20260429
## setup
### erster pc
obsidian: vault erstellen
github: repository erstellen
terminal:
- cd C:\Users\nolte\Desktop\G
- git init
- git remote add G https://github.com/junihey/G
- git push --set-upstream G master
### anderer pc
terminal: 
- cd C:\Users\junih\Desktop\zählen
- git clone https://github.com/junihey/G
## vergessen von commit -> zurucksetzen auf letzten remote stand (überschreibt alles auf lokal)
- git fetch --all
- git reset --hard G/master
## letzten commit verwerfen
- git reset --hard HEAD~1
## gitignore
```
# to exclude Obsidian's settings (including plugin and hotkey configurations)
.obsidian/
```
---
# gemini cli 20260429
## setup
- [Node.js — Run JavaScript Everywhere](https://nodejs.org/en
	- Lade die `nvm-setup.exe` von [nvm-windows](https://github.com/coreybutler/nvm-windows/releases) herunter.
	- Bei der Installation setzt NVM die Pfade automatisch für dein Benutzerprofil.
    - Danach tippst du im Terminal einfach: 
    `nvm install lts` 
    `nvm use lts`
	- Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
- npm install -g @google/gemini-cli
- terminal: gemini
## [CLI commands | Gemini CLI](https://geminicli.com/docs/reference/commands/)
## mcps 20260501
- Figma [Gemini CLI and Figma: Set up the MCP server – Figma Learn - Help Center](https://help.figma.com/hc/en-us/articles/39889246888855-Gemini-CLI-and-Figma-Set-up-the-MCP-server)
- **Step 1: Locate or create your settings file** You can configure MCP servers globally for your user profile or locally for a specific project:
	- **Global:** `~/.gemini/settings.json` (in your home directory)
	- **Local:** `.gemini/settings.json` (at the root of your project)
- **Step 2: Add the MCP Server configuration** Open the `settings.json` file and add an `"mcpServers"` block. You will need to provide the command to start the specific MCP server you want to use.
	- Here is an example of adding a generic Node-based MCP server (like Firebase or Snyk):
```json
{
  "mcpServers": {
    "my-mcp-tool": {
      "command": "npx",
      "args": [
        "-y",
        "some-mcp-server-package@latest",
        "mcp"
      ],
      "env": {
        "OPTIONAL_API_KEY": "your_key_here"
      }
    }
  }
}
```
_(Note: Replace `some-mcp-server-package@latest` with the actual MCP tool you want to run, such as `firebase-tools@latest` or a custom Python/Go executable)._
- **Step 3: Verify the installation** Open your terminal and launch the Gemini CLI interactive mode:
```bash
gemini
```
Once inside the chat, type the following slash command to see your connected MCP servers and their available tools:
```
/mcp list
```
If configured correctly, you'll see a green indicator showing the server is connected and a list of the tools the Gemini CLI can now autonomously use.
_(Shortcut: Some official Google extensions can do this automatically. For example, running `gemini extensions install [https://github.com/firebase/agent-skills/](https://github.com/firebase/agent-skills/)` automatically writes the Firebase MCP config to your file)._
# seafile 20260429
```bash
mkdir -p /opt/seafile && cd /opt/seafile
```
- `nano docker-compose.yml`
```yaml
services:
  db:
    image: mariadb:10.11
    container_name: seafile-mysql
    environment:
      - MYSQL_ROOT_PASSWORD=Gynnys987654321!
      - MYSQL_LOG_CONSOLE=true
    volumes:
      - ./mysql:/var/lib/mysql
    restart: always

  memcached:
    image: memcached:1.6
    container_name: seafile-memcached
    restart: always

  seafile:
    image: seafileltd/seafile-mc:latest
    container_name: seafile
    ports:
      - "8081:80"
    volumes:
      - ./seafile-data:/shared
    environment:
      - DB_HOST=db
      - DB_ROOT_PASSWD=Gynnys987654321!
      - TIME_ZONE=Europe/Berlin
      - SEAFILE_ADMIN_EMAIL=contact@julianniklasheynert.xyz
      - SEAFILE_ADMIN_PASSWORD=Gynnys987654321!
      - SEAFILE_SERVER_LETSENCRYPT=false
      - SEAFILE_SERVER_HOSTNAME=seafile.deinedomain.de
    depends_on:
      - db
      - memcached
    restart: always
```
- `docker compose up -d
- http://217.154.113.12:8081
	- Systemadministration - Einstellungen
		- https://seafile.julianniklasheynert.xyz
		- https://seafile.julianniklasheynert.xyz/seafhttp
- Logs anschauen, falls was hängt `docker compose logs -f seafile`
	- Beenden mit STRG + C
- wenn Logs Errors zeigen
```
# 1. Container stoppen
docker compose down

# 2. Bestehende (fehlerhafte) Daten löschen
# VORSICHT: Das löscht die bisherige DB-Struktur in diesem Ordner
rm -rf mysql/ seafile-data/

# 3. Docker-Compose Datei final prüfen
nano docker-compose.yml
# Stelle sicher, dass die Passwörter bei 'db' und 'seafile' gleich sind!

# 4. Alles neu starten
docker compose up -d
```
## nginx http://217.154.113.12:81
- Tab "Details":
    Domain Names: seafile.julianniklasheynert.xyz
    Scheme: http
    Forward Hostname / IP: 217.154.113.12
    Forward Port: 8081
    Websockets Support: AN (Wichtig für Seafile!).
    Block Common Exploits: AN.
- Tab "SSL":
    SSL Certificate: Wähle "Request a new SSL Certificate".
    Force SSL: AN.
- bei Problemen in Ordner gehen wo nginx liegt `cd /root/nginx-proxy` und `docker compose restart`
- DNS: A; seafile; 217.154.113.12
- Fehler: Verboten (403) CSRF-Verifizierung fehlgeschlagen. Anfrage abgebrochen.
	- `cd /opt/seafile/seafile-data/seafile/conf`
	- `nano seahub_settings.py`
	- `CSRF_TRUSTED_ORIGINS = ["https://seafile.julianniklasheynert.xyz"]` unten hinzufügen
	- Seafile neustarten `cd /opt/seafile` `docker compose restart seafile`
	- Cookies löschen Strg + F5
	- 
# figma 20260501
## [Claude Code + Figma Design System - YouTube](https://www.youtube.com/watch?v=mqGvJ_g2GME)
- build design system in figma
- create skills for claude
1.  styles - the output table is within the figma file
```
"copied figma share-link"
Write a specification for using figma tokens (typography, color and spacing) and paste it in a table to this page
table should have 4 columns:
1. variable name
2. value
3. description when to use it in design
4. description when to avoid (optional)
```
- next prompt
```
"copied figma share-link"
Review all design tokens and Figma variables provided in this document. 
Use Design Token Specification to know more about how to use the tokens
Build a Claude Code skill that will inform Claude how to use each tokens when biuilding UI design
```
- add the skill to claude
2. components
- add all components to categories in figma (controls, buttons...)
- add description to the categories
```
"copied figma share-link"
Review all components in this design system (navigation, content sections, controls) and understand when and how to use them. If you son't know when and how individual component should be used, ask me.
After that create a skill that helps you understand when and how to use the component.
```
- Claude Code prompt
```
Use design-tokes and design-system-components skill to build HTML page with a sign up form for SaaS service called Roxy. The form should have 3 fields: user name as text input, size of organization as a dropdown, and personal preferences as text input. And it will be used a second step in the sign up process when user already provided email and phone number on the previous step.
```
## [The new way to use Figma? - YouTube](https://www.youtube.com/watch?v=XftHdIqqgNM)
- bidirectional way with mcp from claude into figma, not just from figma - claude - html
	- search inside "Connectors" menu
- additional skills
	- [nafiurrahmanniloy/figma-skill: Universal Figma-to-code skill for Claude Code. Browse, extract tokens, and generate code for 7 frameworks.](https://github.com/nafiurrahmanniloy/figma-skill)
	- [claude-code/plugins/frontend-design/skills/frontend-design/SKILL.md at main · anthropics/claude-code](https://github.com/anthropics/claude-code/blob/main/plugins/frontend-design/skills/frontend-design/SKILL.md)
- Gemini CLI MCP [Gemini CLI and Figma: Set up the MCP server – Figma Learn - Help Center](https://help.figma.com/hc/en-us/articles/39889246888855-Gemini-CLI-and-Figma-Set-up-the-MCP-server)
- prompt `Let's improve this. Reference /frontend-design and the design I attached as a picture as inspiration.`
- creating a design system - prompt `Based on the three app screens in this file, generate a design system page. Include: a color palette with all styles used (background, surface, text, accent), a typography scale with the font sizes and wights applied in the UI, and a component library with reusable versions of the card, button and list item component. Organize everything clearly on a new page called Design System. Once you've created all of the color and text styles, make sure everything in the UI has those applied (not hard-coded hex values and pixel values)"
- gut für
	- scaffolding screens fast
	- extracting a design system
	- repetetive component generation
	- applying design tokens consistently
	- renaming and organising layers
- struggle with
	- complex auto layout logic
	- micro ineraction and animation
## [How to Build a Design System with Claude + Figma MCP | Vibe to Vector Tutorial - YouTube](https://www.youtube.com/watch?v=WbUhThNIyUQ)
- "Variables" on the right panel as integrated Design system with variable groups and tokens (like css framework)                    
- MCP connection, CLAUDE.md, Figma File (link), Skills
	- CLAUDE.md and Skills should be in the project folder on computer
	- you can add figma links of categories into claude, not just the whole figma project
- good at 
	- creating variants of components
## [Claude Code for Designers (Full Overview) - YouTube](https://www.youtube.com/watch?v=mwq70TpWQkA&t=31s)
- 
## [How to Build a Design System with Claude + Figma MCP | Vibe to Vector Tutorial - YouTube](https://www.youtube.com/watch?v=WbUhThNIyUQ)
- 


[Firecrawl - Search, Scrape, and Interact with the Web for AI](https://www.firecrawl.dev/)
[Zero-Config Linting for Biome, ESLint, and Oxlint | Ultracite](https://www.ultracite.ai/)
[DeepWiki MCP - Devin Docs](https://docs.devin.ai/work-with-devin/deepwiki-mcp)
[Web Search MCP - Exa](https://exa.ai/docs/reference/exa-mcp)
[Inngest Dashboard](https://app.inngest.com/env/production/onboarding/create-app)
