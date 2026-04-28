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




[Firecrawl - Search, Scrape, and Interact with the Web for AI](https://www.firecrawl.dev/)
[Zero-Config Linting for Biome, ESLint, and Oxlint | Ultracite](https://www.ultracite.ai/)
[DeepWiki MCP - Devin Docs](https://docs.devin.ai/work-with-devin/deepwiki-mcp)
[Web Search MCP - Exa](https://exa.ai/docs/reference/exa-mcp)
[Inngest Dashboard](https://app.inngest.com/env/production/onboarding/create-app)

erster pc
obsidian: vault erstellen
github: repository erstellen
terminal:
- cd C:\Users\nolte\Desktop\G
- git init
- git remote add G https://github.com/junihey/G
- git push --set-upstream G master

anderer pc
terminal: 
- cd C:\Users\junih\Desktop\zählen
- git clone https://github.com/junihey/G


- [Node.js — Run JavaScript Everywhere](https://nodejs.org/en
	- Lade die `nvm-setup.exe` von [nvm-windows](https://github.com/coreybutler/nvm-windows/releases) herunter.
	- Bei der Installation setzt NVM die Pfade automatisch für dein Benutzerprofil.
    - Danach tippst du im Terminal einfach: 
    `nvm install lts` 
    `nvm use lts`
	- Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
- npm install -g @google/gemini-cli
- terminal: gemini
- [CLI commands | Gemini CLI](https://geminicli.com/docs/reference/commands/)