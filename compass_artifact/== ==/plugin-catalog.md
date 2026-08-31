---
tags: [claude-note, curated, claude-code]
created: 2026-08-23
topic: Alle 286 Plugins des offiziellen Marketplace, nach Anwendungsfeld sortiert — was es gibt, bevor man selbst etwas baut
verification: extern — Inhalt des Katalogs anthropics/claude-plugins-official, Stand 2026-08-23, maschinell erzeugt
---

# Der offizielle Plugin-Katalog, nach Anwendungsfeld

**286 Einträge**, Stand 2026-08-23. Sortiert nach der Frage, mit der man kommt — nicht nach den Kategorien des Katalogs. Dessen eigene Einteilung hilft wenig: 118 von 286 tragen `development`, und darunter steht ein Java-Sprachserver neben einem Zahlungsanbieter.

**Wofür diese Notiz da ist:** bevor du einen Skill schreibst, sieh nach, ob es ihn gibt. `CLAUDE.md` Regel 9 sagt, Maschinerie entsteht aus einem Lauf, der funktioniert hat — sie sagt nicht, dass die Maschinerie von dir stammen muss.

**Wie die Tabellen zu lesen sind.** Die Spalte *Wofür* zitiert die Katalogbeschreibung, gekürzt; sie ist englisch, weil sie vom jeweiligen Autor stammt und nicht von mir. Die Spalte *Quelle* sagt, was im Katalog-Repo tatsächlich liegt:

| Quelle | Anzahl | Was `~\.claude\plugins\marketplaces\claude-plugins-official\` enthält |
|---|---|---|
| `im Repo` | 38 | den vollen Inhalt — diese schreibt Anthropic selbst |
| `im Repo (MCP)` | 15 | zwei Dateien, `plugin.json` und `.mcp.json` — eine Adresse auf einen fremden Server |
| `Zip` | 150 | nur eine URL; das Archiv wird beim Installieren geholt |
| `Git-Subdir` | 83 | fremdes Repo, Unterordner, **plus ein festgenagelter Commit** |

Der festgenagelte Commit ist der Grund für die Trennung: ändert ein Autor sein Repo, bekommst du trotzdem den geprüften Stand. Mehr dazu — und wohin ein Plugin im Kontext einzahlt — in [[context-management]].

**Nichts davon ist bei dir installiert** außer `mattpocock-skills` und `skill-creator`. Ein Katalogeintrag kostet null Token; erst die Installation bringt Skills in den Kontext, und auch dann nur ihre Description.

**Installieren:** `/plugin` öffnet den Browser, oder direkt `claude plugin install <name>@claude-plugins-official --scope user`. Abschalten ohne Deinstallieren: `enabledPlugins` in `~\.claude\settings.json` auf `false`.

**Diese Notiz verfällt.** Der Katalog wächst; die Zahlen oben stammen aus einer einzigen Messung. Neu zählen:

```bash
python -c "import json;d=json.load(open(r'C:\Users\nolte\.claude\plugins\marketplaces\claude-plugins-official\.claude-plugin\marketplace.json',encoding='utf-8'));print(len(d['plugins']))"
```

Kommt eine andere Zahl als 286, ist die Einsortierung unten unvollständig.

---

## Sprachserver — Code-Intelligenz für eine Sprache — 13

| Plugin | Wofür | Quelle |
|---|---|---|
| `clangd-lsp` | C/C++ language server (clangd) for code intelligence | im Repo |
| `csharp-lsp` | C# language server for code intelligence | im Repo |
| `gopls-lsp` | Go language server for code intelligence and refactoring | im Repo |
| `jdtls-lsp` | Java language server (Eclipse JDT.LS) for code intelligence | im Repo |
| `kotlin-lsp` | Kotlin language server for code intelligence | im Repo |
| `liquid-lsp` | LSP integration for Shopify Liquid templates via the Shopify CLI theme language server. | Git-Subdir |
| `lua-lsp` | Lua language server for code intelligence | im Repo |
| `php-lsp` | PHP language server (Intelephense) for code intelligence | im Repo |
| `pyright-lsp` | Python language server (Pyright) for type checking and code intelligence | im Repo |
| `ruby-lsp` | Ruby language server for code intelligence and analysis | im Repo |
| `rust-analyzer-lsp` | Rust language server for code intelligence and analysis | im Repo |
| `swift-lsp` | Swift language server (SourceKit-LSP) for code intelligence | im Repo |
| `typescript-lsp` | TypeScript/JavaScript language server for enhanced code intelligence | im Repo |

## Claude Code selbst erweitern — 22

| Plugin                     | Wofür                                                                                                     | Quelle        |
| -------------------------- | --------------------------------------------------------------------------------------------------------- | ------------- |
| `agent-sdk-dev`            | Development kit for working with the Claude Agent SDK                                                     | im Repo       |
| `claude-code-setup`        | Analyze codebases and recommend tailored Claude Code automations such as hooks, skills, MCP servers,…     | im Repo       |
| `claude-md-management`     | ==Tools== to maintain and improve CLAUDE.md files - audit quality, capture session learnings, and keep…   | im Repo       |
| `cwc-makers`               | Onboard a Code-with-Claude Makers Cardputer with one /maker-setup command - clones the…                   | im Repo       |
| `explanatory-output-style` | ==Adds== educational insights about implementation choices and codebase patterns (mimics the deprecated…  | im Repo       |
| `fakechat`                 | Localhost web chat for testing the channel notification flow. No tokens, no access control, no…           | im Repo (MCP) |
| `hookify`                  | Easily create custom hooks to prevent unwanted behaviors by analyzing conversation patterns or from…      | im Repo       |
| `learning-output-style`    | ==Interactive== learning mode that requests meaningful code contributions at decision points (mimics the… | im Repo       |
| `mattpocock-skills`        | Matt Pocock's agent skills for real engineering - grilling, spec/ticket flows, TDD, code review, domain…  | Zip           |
| `mcp-apps`                 | Skills for creating MCP Apps with the MCP Apps SDK                                                        | Git-Subdir    |
| `mcp-server-dev`           | Skills for designing and building MCP servers that work seamlessly with Claude. Guides you through…       | im Repo       |
| `mcp-tunnels`              | Connect Claude to a private MCP server through an Anthropic MCP tunnel. The /create-docker-mcp-tunnel…    | im Repo       |
| `playground`               | Creates interactive HTML playgrounds - self-contained single-file explorers with visual controls, live…   | im Repo       |
| `plugin-dev`               | Comprehensive toolkit for developing Claude Code plugins. Includes 7 expert skills covering hooks, MCP…   | im Repo       |
| `project-artifact`         | ==Generate== and publish a living project status page - overview & success criteria, the workstream…      | im Repo       |
| `qodo`                     | Qodo Skills provides a curated library of reusable AI agent capabilities that extend Claude's…            | Zip           |
| `ralph-loop`               | Interactive self-referential AI loops for iterative development, implementing the Ralph Wiggum…           | im Repo       |
| `receipts`                 | A personal Claude Code impact report for justifying your usage to a manager or a self-review: what you…   | im Repo       |
| `remember`                 | Continuous memory for Claude Code. Extracts, summarizes, and compresses conversations into tiered daily…  | Zip           |
| `session-report`           | Generate an explorable HTML report of Claude Code session usage - tokens, cache efficiency, subagents,…   | im Repo       |
| `skill-creator`            | Create new skills, improve existing skills, and measure skill performance. Use when users want to…        | im Repo       |
| `superpowers`              | Superpowers teaches Claude brainstorming, subagent driven development with built in code review,…         | Zip           |

## Fremden Code lesen und verstehen — 9

| Plugin                | Wofür                                                                                                    | Quelle        |
| --------------------- | -------------------------------------------------------------------------------------------------------- | ------------- |
| `context7`            | Upstash Context7 MCP server for up-to-date documentation lookup. Connects to Context7's hosted remote…   | im Repo (MCP) |
| `gitkraken`           | Gives Claude access to your real Git and project context: commits, branches, pull requests, and issues…  | Zip           |
| `greptile`            | AI-powered codebase search and understanding. Query your repositories using natural language to find…    | im Repo (MCP) |
| `lumen`               | Precise local semantic code search via MCP. Indexes your codebase with Go AST parsing, embeds with…      | Zip           |
| `microsoft-docs`      | Access official Microsoft documentation, API references, and code samples for Azure, .NET, Windows, and… | Zip           |
| `mintlify`            | Build beautiful documentation sites with Mintlify. Convert non-markdown files into properly formatted…   | Zip           |
| `modern-web-guidance` | ==Keep== your coding agent up to date with the latest web best practices                                 | Zip           |
| `serena`              | Semantic code analysis MCP server providing intelligent code understanding, refactoring suggestions,…    | im Repo (MCP) |
| `sourcegraph`         | Code search and understanding across codebases. Search, read, and trace references across repositories;… | Zip           |

## Review, Qualität, Sicherheit am eigenen Code — 20

| Plugin                          | Wofür                                                                                                    | Quelle     |
| ------------------------------- | -------------------------------------------------------------------------------------------------------- | ---------- |
| `42crunch-api-security-testing` | Automate API security directly in Claude Code with 42Crunch - automatically audit OpenAPI specs, detect… | Git-Subdir |
| `ai-plugins`                    | Set up endorctl and use Endor Labs to scan, prioritize, and fix security risks across your software…     | Zip        |
| `aikido`                        | Aikido Security scanning for Claude Code - SAST, secrets, and IaC vulnerability detection powered by…    | Zip        |
| `claude-security`               | Deep vulnerability scanning of your own code, run entirely inside your Claude Code session at a chosen…  | im Repo    |
| `code-modernization`            | Modernize legacy codebases (COBOL, legacy Java/C++, monolith web apps) with a structured preflight /…    | im Repo    |
| `code-review`                   | Automated code review for pull requests using multiple specialized agents with confidence-based scoring… | im Repo    |
| `code-simplifier`               | Agent that simplifies and refines code for clarity, consistency, and maintainability while preserving…   | im Repo    |
| `coderabbit`                    | Your code review partner. CodeRabbit provides external validation using a specialized AI architecture…   | Zip        |
| `codspeed`                      | CodSpeed is the all-in-one performance testing toolkit. Dive into benchmarking results, flamegraphs,…    | Zip        |
| `commit-commands`               | Commands for git commit workflows including commit, push, and PR creation                                | im Repo    |
| `feature-dev`                   | Comprehensive feature development workflow with specialized agents for codebase exploration,…            | im Repo    |
| `jfrog`                         | ==Use== the JFrog Platform from Claude Code: Artifactory repos and artifacts, security findings and…     | Zip        |
| `nightvision`                   | Skills for working with NightVision, a DAST and API Discovery platform that finds exploitable…           | Zip        |
| `pr-review-toolkit`             | Comprehensive PR review agents specializing in comments, tests, error handling, type design, code…       | im Repo    |
| `security-guidance`             | Security review for Claude-generated code. Pattern-based warnings on edits, LLM-powered diff review on…  | im Repo    |
| `semgrep`                       | Semgrep catches security vulnerabilities in real-time and guides Claude to write secure code from the…   | Git-Subdir |
| `sonarqube`                     | Automatically enforce SonarQube code quality and security in the agent coding loop - 7,000+ rules,…      | Zip        |
| `sonatype-guide`                | Sonatype Guide MCP server for software supply chain intelligence and dependency security. Analyze…       | Zip        |
| `stackhawk-api`                 | Query the StackHawk platform API for security posture reporting, findings analysis, and app management.… | Git-Subdir |
| `stackhawk-hawkscan`            | Configure, run, and interpret HawkScan DAST results inside Claude Code. Generates stackhawk.yml…         | Git-Subdir |

## ==Datenbanken== und Data Warehouses — 42

| Plugin | Wofür | Quelle |
|---|---|---|
| `aiven` | Easily deploy managed PostgreSQL (pg), Kafka, OpenSearch, Clickhouse and other databases, streaming and… | Zip |
| `alloydb` | Create, connect, and interact with an AlloyDB for PostgreSQL database and data. | Zip |
| `alloydb-omni` | Create, connect, and interact with an AlloyDB Omni database and data. | Zip |
| `altimate-code` | Delegates dbt and warehouse work to altimate-code, a specialized CLI agent with 100+ purpose-built data… | Git-Subdir |
| `atlan` | Atlan data catalog plugin for Claude Code. Search, explore, govern, and manage your data assets through… | Zip |
| `azure-cosmos-db-assistant` | Expert assistant for Azure Cosmos DB - data modeling, query optimization, performance tuning, and best… | Zip |
| `azure-sql-developer` | Agent skills for Azure SQL Developer, the Azure SQL Database engine running locally in a container.… | Zip |
| `bigdata-com` | Official Bigdata.com plugin providing financial research, analytics, and intelligence tools powered by… | Git-Subdir |
| `bigquery-data-analytics` | Connect, query, and generate data insights for BigQuery datasets and data. | Zip |
| `clickhouse` | Connect Claude to your ClickHouse Cloud databases. Browse organizations, services, databases, and table… | Zip |
| `clickhouse-best-practices` | 28 best practice rules for ClickHouse schema design, query optimization, and data ingestion -… | Zip |
| `cloud-sql-mysql` | Connect and interact with a Cloud SQL for MySQL database and data. | Zip |
| `cloud-sql-postgresql` | Create, connect, and interact with a Cloud SQL for PostgreSQL database and data. | Zip |
| `cloud-sql-sqlserver` | Connect to Cloud SQL for SQL Server | Zip |
| `cockroachdb` | Connect Claude Code directly to your CockroachDB clusters for hands-on database work - explore schemas,… | Zip |
| `convex` | Official Convex plugin for Claude Code with bundled Convex skills, the convex-expert subagent for… | Zip |
| `databases-on-aws` | Expert database guidance for the AWS database portfolio. Design schemas, execute queries, handle… | Git-Subdir |
| `databricks` | Databricks skills for the CLI, Apps, Lakebase, Model Serving, Lakeflow Jobs, Spark Declarative… | Git-Subdir |
| `datahub-skills` | DataHub development and interaction toolkit with connector planning, PR review, catalog search,… | Zip |
| `dataproc` | Manage Dataproc clusters and jobs. | Zip |
| `dataverse` | Agent skills for building on, analyzing, and managing Microsoft Dataverse - with Dataverse MCP, PAC… | Git-Subdir |
| `duckdb-skills` | DuckDB-powered skills for Claude Code: read any data file, attach and query DuckDB databases, search… | Zip |
| `firebase` | Google Firebase MCP integration. Manage Firestore databases, authentication, cloud functions, hosting,… | im Repo (MCP) |
| `firestore-native` | Connect and interact with Firestore databases, collections, and documents. | Zip |
| `idmp-plugin` | TDengine IDMP plugin with packaged skills for discovery, schema inspection, and safe operational… | Git-Subdir |
| `knowledge-catalog` | Connect to Knowledge Catalog to discover, manage, monitor, and govern data and AI artifacts across your… | Zip |
| `looker` | Connect to Looker and interact with your data using LookML. | Zip |
| `mongodb` | Official Claude plugin for MongoDB (MCP Server + Skills). Connect to databases, explore data, manage… | Git-Subdir |
| `mongodb-atlas` | Connect to MongoDB Atlas clusters only through the Atlas Managed MCP Server. Sign in with your Atlas… | Git-Subdir |
| `neon` | Manage your Neon projects and databases with the neon-postgres agent skill and the Neon MCP Server. | Git-Subdir |
| `oracledb` | Connect, query, and interact with Oracle Databases and their data. | Zip |
| `pinecone` | Pinecone vector database integration. Streamline your Pinecone development with powerful tools for… | Zip |
| `planetscale` | An authenticated hosted MCP server that accesses your PlanetScale organizations, databases, branches,… | Zip |
| `prisma` | Prisma MCP integration for Postgres database management, schema migrations, SQL queries, and connection… | Zip |
| `qdrant-skills` | Agent skills for Qdrant vector search covering scaling, performance optimization, search quality,… | Zip |
| `redis-development` | Redis development best practices - data structures, query engine, vector search, caching, and… | Git-Subdir |
| `rill` | Skills for developing and querying projects in the Rill business intelligence platform | Zip |
| `sap-hana-cli` | 150+ SAP HANA database tools for AI assistants. Query tables, import/export data, profile data quality,… | Zip |
| `spanner` | Connect and interact with Spanner data using natural language. | Zip |
| `supabase` | Supabase MCP integration for database operations, authentication, storage, and real-time subscriptions.… | Zip |
| `vsql-extension-builder` | Builds a VillageSQL extension for MySQL end-to-end through a 7-phase persona-driven workflow. Commonly… | Zip |
| `zilliz` | Zilliz Cloud management plugin with 14 skills covering cluster lifecycle, collection schema, vector… | Zip |

## Datenpipelines und Analytics — 9

| Plugin | Wofür | Quelle |
|---|---|---|
| `astronomer-data-agents` | Data engineering for Apache Airflow and Astronomer. Author DAGs with best practices, debug pipeline… | Zip |
| `aws-data-analytics` | Data lake, analytics, and ETL workflows with S3 Tables, AWS Glue, and Athena. | Git-Subdir |
| `data` | Data engineering for Apache Airflow and Astronomer. Author DAGs with best practices, debug pipeline… | Zip |
| `data-agent-kit-starter-pack` | This plugin provides a specialized suite of skills for data engineers and database practitioners… | Zip |
| `data-engineering` | Data engineering plugin - warehouse exploration, pipeline authoring, Airflow integration | Zip |
| `pigment` | Analyze business data and build custom Pigment models, metrics, and boards through natural language. | Zip |
| `preset-cli-skills` | Preset CLI skills for explicit shell, scripting, and CI/CD workflows driven by the `sup` CLI (PyPI… | Git-Subdir |
| `streaming-skills-plugin` | Skills for streaming application developers, covering Kafka and Flink client libraries and Schema… | Zip |
| `windsor-ai` | Connect Claude Code to 325+ business data sources via Windsor.ai. Query marketing, sales, CRM,… | Zip |

## Cloud, Deployment, Migration — 23

| Plugin | Wofür | Quelle |
|---|---|---|
| `aws-agents` | Build, deploy, and operate AI agents on AWS. Skills for scaffolding agents with Amazon Bedrock… | Git-Subdir |
| `aws-agents-for-devsecops` | Investigate incidents, review code and execute UAT for release readiness, scan code for… | Git-Subdir |
| `aws-amplify` | Build full-stack apps with AWS Amplify Gen 2 using guided workflows for authentication, data models,… | Git-Subdir |
| `aws-core` | Build, deploy, and operate applications on AWS. Skills to author infrastructure-as-code, use core… | Git-Subdir |
| `aws-serverless` | Design, build, deploy, test, and debug serverless applications with AWS Serverless services. | Git-Subdir |
| `aws-startup-advisor` | Personalized architecture, cost, security, and migration guidance for startups. From day-one account… | Git-Subdir |
| `aws-transform` | Migrate, modernize, and upgrade codebases to AWS. Transforms .NET Framework to .NET 8/10, mainframe… | Git-Subdir |
| `azure` | Transform Claude into an Azure expert. This plugin integrates the Azure MCP server and specialized… | Zip |
| `base44` | Build and deploy Base44 full-stack apps with CLI project management and JavaScript/TypeScript SDK… | Zip |
| `catalyst-by-zoho` | Official Claude Code plugin for Catalyst by Zoho - full-stack serverless cloud platform. With Skills… | Zip |
| `cloudflare` | Skills for the Cloudflare developer platform: Workers, Durable Objects, Agents SDK, MCP servers,… | Zip |
| `deploy-on-aws` | Deploy applications to AWS with architecture recommendations, cost estimates, and IaC deployment. | Git-Subdir |
| `fastly-agent-toolkit` | Fastly development tools and platform skills | Zip |
| `google-cloud-storage` | Official Google Cloud Storage (GCS) plugin. Manage buckets and objects, transfer data, and configure… | Zip |
| `hostinger` | Deploy, manage and monitor Hostinger services - Websites, Domains, Ecommerce, Email Marketing,… | Zip |
| `lovable` | Build, iterate on, deploy, and manage Lovable apps from Claude Code. Bundles the official Lovable MCP… | Zip |
| `migration-to-aws` | Plan a migration from Google Cloud Platform (and OpenAI/Gemini AI workloads) to AWS. Analyzes your… | Git-Subdir |
| `netlify-skills` | Netlify platform skills for Claude Code - functions, edge functions, blobs, database, image CDN, forms,… | Zip |
| `railway` | Deploy and manage apps, databases, and infrastructure on Railway. Covers project setup, deploys,… | Git-Subdir |
| `render` | Deploy, debug, and monitor applications on Render. Includes skills, an agent, slash commands, and a… | Zip |
| `terraform` | The Terraform MCP Server provides seamless integration with Terraform ecosystem, enabling advanced… | im Repo (MCP) |
| `valtown` | Build and deploy on Val Town. Bundles the Val Town MCP server and platform skills (HTTP vals,… | Git-Subdir |
| `vercel` | Vercel deployment platform integration. Manage deployments, check build status, access logs, configure… | Zip |

## Betrieb, Observability, Incidents — 21

| Plugin                   | Wofür                                                                                                    | Quelle     |
| ------------------------ | -------------------------------------------------------------------------------------------------------- | ---------- |
| `amplitude`              | Use Amplitude as an expert analyst - instrument Amplitude, discover product opportunities, analyze…      | Git-Subdir |
| `crowdsec`               | Operational skill for installing, configuring, operating, and debugging CrowdSec (cscli, LAPI/CAPI,…     | Zip        |
| `dash0`                  | OpenTelemetry observability for Claude Code sessions. Captures tool calls, LLM invocations, token…       | Zip        |
| `datadog`                | Use Datadog directly in Claude Code through a preconfigured Datadog MCP server. Query logs, metrics,…    | Zip        |
| `fullstory`              | Connect Claude to Fullstory to query behavioral analytics, session replays, and customer experience…     | Zip        |
| `grafana-assistant`      | Skills and rules for developing and using the Grafana Assistant app and CLI.                             | Git-Subdir |
| `grafana-cloud-mcp`      | ==Hosted MCP== server for AI-assisted Grafana Cloud observability - no local installation required.      | Git-Subdir |
| `grafana-mcp`            | ==MCP== server for AI-assisted Grafana dashboard, datasource, alerting, and incident management.         | Git-Subdir |
| `honeycomb`              | Skills, agents, and workflows for Honeycomb observability - query patterns, production investigations,…  | Git-Subdir |
| `langfuse`               | Skills for working with Langfuse, the open-source LLM engineering platform for tracing, prompt…          | Zip        |
| `langfuse-observability` | Langfuse observability plugin for Claude Code - captures and exports traces, spans, and session…         | Zip        |
| `logfire`                | Add Logfire observability to Python applications with auto-instrumentation for FastAPI, httpx, asyncpg,… | Git-Subdir |
| `logrocket`              | Connect Claude Code to LogRocket to query session replays, metrics, issues, and user behavior using…     | Git-Subdir |
| `mlflow`                 | Skills for tracing, evaluating, and improving AI agents with MLflow. Supports the full agent…            | Zip        |
| `newrelic`               | New Relic observability intelligence for Claude Code. Investigate APM performance, analyze cloud costs,… | Zip        |
| `noibu`                  | Built for ecommerce, the Noibu plugin bridges the gap between customer experience and revenue by…        | Git-Subdir |
| `pagerduty`              | Enhance code quality and security through PagerDuty risk scoring and incident correlation. Score…        | Zip        |
| `posthog`                | Access PostHog analytics, feature flags, experiments, error tracking, and insights directly from Claude… | Zip        |
| `rootly`                 | Full-lifecycle incident management: deploy safety, incident response, on-call management, and…           | Zip        |
| `sentry`                 | Sentry error monitoring integration. Access error reports, analyze stack traces, search issues by…       | Zip        |
| `sentry-cli`             | Skills for using the Sentry CLI to interact with Sentry from the command line                            | Git-Subdir |

## CI/CD, Feature-Flags, Experimente — 8

| Plugin | Wofür | Quelle |
|---|---|---|
| `buildkite` | Official Buildkite skills for Claude Code, Cursor, and other AI coding agents - pipelines, migration,… | Zip |
| `confidence` | Access Confidence feature flags, experiments, and migration tools directly from Claude Code. | Zip |
| `growthbook` | A suite of agent skills for the full GrowthBook feature flag and experimentation lifecycle. | Zip |
| `mergify` | Skills for the Mergify CLI: manage merge queues, stacked pull requests, Test Insights (flaky tests,… | Zip |
| `playwright` | Browser automation and end-to-end testing MCP server by Microsoft. Enables Claude to interact with web… | im Repo (MCP) |
| `rc` | Configure RevenueCat projects, apps, products, entitlements, and offerings directly from Claude Code.… | Zip |
| `revenuecat` | Configure RevenueCat projects, apps, products, entitlements, and offerings directly from Claude Code.… | Zip |
| `teamcity-cli` | Agent skill for interacting with TeamCity CI/CD using the teamcity CLI. Enables Claude to explore… | Zip |

## Projektarbeit, Wissen, Nachrichten — 21

| Plugin              | Wofür                                                                                                        | Quelle        |
| ------------------- | ------------------------------------------------------------------------------------------------------------ | ------------- |
| `airtable`          | Airtable is the database and operations layer for your agents - whether running product, marketing,…         | Git-Subdir    |
| `asana`             | Asana project management integration. Connects Claude Code to Asana's V2 MCP server to create and…           | im Repo (MCP) |
| `atlassian`         | Connect to Atlassian products including Jira and Confluence. Search and create issues, access…               | Zip           |
| `atlassian-twg-cli` | Teamwork Graph CLI is Atlassian's agent-first interface to your entire work context: Jira issues,…           | Zip           |
| `box`               | Work with your Box content directly from Claude Code - search files, organize folders, collaborate with…     | Zip           |
| `circleback`        | ==Circleback== conversational context integration. Search and access meetings, emails, calendar events, and… | Zip           |
| `desktop-commander` | MCP server for terminal commands, process management, and file operations across text, code, PDF, DOCX,…     | Git-Subdir    |
| `discord`           | Discord messaging bridge with built-in access control. Manage pairing, allowlists, and policy via…           | im Repo (MCP) |
| `dropbox`           | The Dropbox plugin for Claude connects your Dropbox files directly to Claude, so you can search,…            | Git-Subdir    |
| `github`            | Official GitHub MCP server for repository management. Create issues, manage pull requests, review code,…     | im Repo (MCP) |
| `gitlab`            | GitLab DevOps platform integration. Manage repositories, merge requests, CI/CD pipelines, issues, and…       | im Repo (MCP) |
| `imessage`          | iMessage messaging bridge with built-in access control. Reads chat.db directly, sends via AppleScript.…      | im Repo (MCP) |
| `intercom`          | Intercom integration for Claude Code. Search conversations, analyze customer support patterns, look up…      | Zip           |
| `linear`            | Linear issue tracking integration. Create issues, manage projects, update statuses, search across…           | im Repo (MCP) |
| `monday-crm`        | Run your monday CRM in plain language. Build a pipeline from scratch, start the day with a ranked deal…      | Git-Subdir    |
| `notion`            | Notion workspace integration. Search pages, create and update documents, manage databases, and access…       | Zip           |
| `postiz`            | Social media automation CLI for scheduling posts, managing integrations, uploading media, and tracking…      | Zip           |
| `slack`             | Slack workspace integration. Search messages, access channels, read threads, and stay connected with…        | Zip           |
| `telegram`          | Telegram messaging bridge with built-in access control. Manage pairing, allowlists, and policy via…          | im Repo (MCP) |
| `zapier`            | Connect 8,000+ apps to your AI workflow. Discover, enable, and execute Zapier actions directly from…         | Git-Subdir    |
| `zoom-plugin`       | Claude plugin for planning, building, and debugging Zoom integrations across REST APIs, SDKs, webhooks,…     | Zip           |

## Vertrieb, Geld, Recht — 20

| Plugin | Wofür | Quelle |
|---|---|---|
| `airwallex-agentos` | Bring Airwallex's global financial infrastructure to Claude. Orchestrate actions across your account in… | Git-Subdir |
| `airwallex-dev` | Build Airwallex payment integrations in your own codebase. Generates the checkout, card-element,… | Git-Subdir |
| `apollo` | Prospect, enrich leads, load outreach sequences, and query sales analytics with Apollo.io - one-click… | Zip |
| `carbone-skill` | Official Carbone skill - complete templating language reference covering tags, loops, conditions,… | Zip |
| `carta-cap-table` | Carta Cap Table plugin - skills and hooks for querying cap tables, grants, SAFEs, 409A valuations,… | Git-Subdir |
| `carta-crm` | Manage the Carta CRM conversationally - search, add, update, and enrich investors, companies, contacts,… | Git-Subdir |
| `carta-investors` | Carta Investors plugin - skills for querying investor data, performance benchmarks, regulatory… | Git-Subdir |
| `circle-skills` | Ship stablecoin apps faster. Best-practice skills for USDC payments, cross-chain transfers, wallets,… | Git-Subdir |
| `hunter` | Find and verify professional email addresses, search contacts by domain, and enrich company data --… | Zip |
| `legalzoom` | Attorney guidance and legal tools for business and personal needs. AI-powered document review… | Git-Subdir |
| `lusha` | Prospect, enrich, and build call-ready lead lists using Lusha's B2B intelligence platform - verified… | Zip |
| `mercadopago` | Mercado Pago full-product integration toolkit. One agent routes to four orchestration skills… | Git-Subdir |
| `paypal` | PayPal development plugin for Claude - integrate payments, subscriptions, invoices, disputes, and more… | Zip |
| `save-to-spotify` | Create polished audio episodes with TTS narration, rich timelines, cover images, and save them to… | Git-Subdir |
| `shippo` | Shippo connects you to USPS, UPS, FedEx, DHL, and 40+ carriers, so you can handle a shipment end to end… | Git-Subdir |
| `spotify-ads-api` | Manage Spotify ad campaigns with natural language. Create campaigns, ad sets, ads, pull reports, and… | Zip |
| `stripe` | Stripe development plugin for Claude | Git-Subdir |
| `sumup` | SumUp payment integrations across terminal and online checkout flows. Build Android and iOS POS apps… | Zip |
| `vibe-prospecting` | Vibe Prospecting connects Claude to live B2B company and contact data so users can search, match,… | Zip |
| `zoominfo` | Search companies and contacts, enrich leads, find lookalikes, and get AI-ranked contact… | Zip |

## Web-Daten holen und Browser steuern — 10

| Plugin                   | Wofür                                                                                                     | Quelle     |
| ------------------------ | --------------------------------------------------------------------------------------------------------- | ---------- |
| `brightdata-plugin`      | Web scraping, Google search, structured data extraction, and MCP server integration powered by Bright…    | Zip        |
| `browser-use`            | Give Claude a real browser - your Chrome or a Browser Use Cloud browser. Use it whenever a task…          | Git-Subdir |
| `chrome-devtools-mcp`    | ==Control== and inspect a live Chrome browser from your coding agent. Record performance traces, analyze… | Zip        |
| `exa`                    | Exa AI web search, deep research, and content extraction. Provides MCP tools and research skills for…     | Zip        |
| `firecrawl`              | Web scraping and crawling powered by Firecrawl. Turn any website into clean, LLM-ready markdown or…       | Zip        |
| `nimble`                 | Nimble web data toolkit - search, extract, map, crawl the web and work with structured data agents        | Zip        |
| `synthflow`              | Connects Claude Code to the Synthflow AI voice-agent platform through its hosted MCP server, with…        | Git-Subdir |
| `tavily`                 | Build AI applications with real-time web data using Tavily's search, extract, crawl, and research APIs.   | Zip        |
| `youdotcom-agent-skills` | You.com agent skills for web search, research with citations, and content extraction. Guided…             | Zip        |
| `zyte-web-data`          | Web scraping skills for Claude Code powered by the Zyte API - scrape sites, generate and run Scrapy…      | Zip        |

## Design, Oberflächen, Medien — 12

| Plugin                 | Wofür                                                                                                       | Quelle     |
| ---------------------- | ----------------------------------------------------------------------------------------------------------- | ---------- |
| `adobe-for-creativity` | Harness Adobe's creative AI-powered tools to edit images, automate design workflows, and bring creative…    | Git-Subdir |
| `canva`                | Create, edit, review, resize, and brand-check Canva designs with the Canva MCP server.                      | Git-Subdir |
| `ckeditor`             | Install, configure, and integrate CKEditor 5 (free and premium) in any JavaScript project.                  | Zip        |
| `cloudinary`           | Use Cloudinary directly in Claude. Manage assets, apply transformations, optimize media, and more…          | Zip        |
| `figma`                | ==Figma== design platform integration. Access design files, extract component information, read design…     | Zip        |
| `frontend-design`      | ==Create== distinctive, production-grade frontend interfaces with high design quality. Generates creative,… | im Repo    |
| `hyperframes`          | HyperFrames by HeyGen. Write HTML, render video. Compositions, GSAP and runtime adapter animations,…        | Zip        |
| `miro`                 | Secure access to Miro boards. Enables AI to read board context, create diagrams, and generate code with…    | Git-Subdir |
| `runway-api`           | Video generation at scale. Generate videos, images, and audio with Runway's API - batch ad campaigns,…      | Zip        |
| `sanity`               | Sanity content platform integration with MCP server, agent skills, and slash commands. Query and author…    | Zip        |
| `superdesign`          | ==Design== or redesign frontend UI and marketing graphics on the Superdesign infinite canvas. Reads your…   | Zip        |
| `ui-theme-designer`    | Plugin for coding agents working with UI theme designer. Bundles two skills: how-to and conceptual…         | Git-Subdir |

## KI-Modelle bauen, messen, betreiben — 16

| Plugin | Wofür | Quelle |
|---|---|---|
| `amd-skills` | AMD's verified Agent Skills in one plugin: route image/audio through local AI on Ryzen AI, serve LLMs… | Git-Subdir |
| `apollo-skills` | Apollo GraphQL agent skills for Claude Code - Apollo Client, Server, Federation, Connectors, Router,… | Zip |
| `atomic-agents` | Comprehensive development workflow for building AI agents with the Atomic Agents framework. Includes… | Zip |
| `boltz` | Predict structures, screen molecules and proteins, and design binders with Boltz from Claude Code. | Git-Subdir |
| `datarobot-agent-skills` | DataRobot skills for AI/ML workflows - model training, deployment, predictions, feature engineering,… | Zip |
| `deepeval` | Skills for adding DeepEval evaluations, tracing, datasets, Confident AI reports, and iterative… | Zip |
| `dominodatalab` | Full Domino Data Lab platform support - workspaces, jobs, model deployment, experiment tracking, GenAI… | Zip |
| `fiftyone` | Build high-quality datasets and computer vision models. Visualize datasets, analyze models, find… | Zip |
| `huggingface-skills` | Build, train, evaluate, and use open source AI models, datasets, and spaces. | Zip |
| `nvidia-skills` | NVIDIA agent skills for accelerated-computing workflows - starting with cuOpt vehicle-routing… | Git-Subdir |
| `outputai` | Output.ai workflow development toolkit for Claude Code. Adds 5 specialist agents (planner, builder,… | Git-Subdir |
| `pixeltable` | Build multimodal AI applications with Pixeltable -- tables, computed columns, embedding search, UDFs,… | Zip |
| `pydantic-ai` | Write accurate Pydantic AI code from the start. Up-to-date patterns, decision trees, and common gotchas… | Git-Subdir |
| `sagemaker-ai` | Build, train, and deploy AI models with deep AWS AI/ML expertise brought directly into your coding… | Git-Subdir |
| `snowflake-cortex-code` | Automatically route Snowflake prompts from Claude Code to Cortex Code for execution. Provides slash… | Git-Subdir |
| `togetherai-skills` | Agent Skills for Together AI platform - inference, training, embeddings, audio, video, images, function… | Zip |

## Große Plattform-Ökosysteme — 36

| Plugin | Wofür | Quelle |
|---|---|---|
| `agentforce-adlc` | Agentforce Agent Development Life Cycle - author, discover, scaffold, deploy, test, and optimize .agent… | Zip |
| `appwrite` | Appwrite tools for Claude Code, including SDK skills, Appwrite MCP servers, and deployment commands. | Zip |
| `auth0` | Enterprise-grade auth, easy to implement. Add login, SSO, MFA, and access control to any app with… | Git-Subdir |
| `build-with-wordpress` | Craft production-grade WordPress sites and applications. Everything from themes and plugins to commerce… | Zip |
| `cds-mcp` | AI-assisted development of SAP Cloud Application Programming Model (CAP) projects. Search CDS models… | Zip |
| `crowdstrike-falcon-foundry` | CrowdStrike Falcon Foundry development skills for building cybersecurity applications on the Falcon… | Zip |
| `crowdstrike-falcon-fusion` | CrowdStrike Falcon Fusion skills for authoring, deploying, and executing Fusion workflows. Includes… | Zip |
| `duende-skills` | Duende development skills and agents for Claude Code - covering OAuth/OIDC protocols, IdentityServer,… | Zip |
| `expo` | Official Expo skills for building, deploying, upgrading, and debugging React Native apps with Expo.… | Git-Subdir |
| `forge-skills` | Forge-focused skills and MCP configuration for Atlassian Forge: scaffold and deploy apps (forge create,… | Zip |
| `laravel-boost` | Laravel development toolkit MCP server. Provides intelligent assistance for Laravel applications… | im Repo (MCP) |
| `liquid-skills` | Liquid language fundamentals, CSS/JS/HTML coding standards, and WCAG accessibility patterns for Shopify… | Git-Subdir |
| `netsuite-suitecloud` | NetSuite agent skills from Oracle - authoring guidance for SuiteCloud Development Framework (SDF)… | Git-Subdir |
| `oracle-ai-data-platform-workbench-databricks-migrator` | Drive the Oracle AI Data Platform (AIDP) Databricks Migration Toolkit in natural language. Plans and… | Git-Subdir |
| `oracle-ai-data-platform-workbench-engineer-agent` | Oracle AI Data Platform (AIDP) Workbench engineer agent for Claude Code - a 37-skill agent that… | Git-Subdir |
| `oracle-ai-data-platform-workbench-spark-connectors` | Oracle AI Data Platform Workbench Spark connectors for Claude Code. 18 connector skills covering every… | Git-Subdir |
| `postman` | Full API lifecycle management for Claude Code. Sync collections, generate client code, discover APIs,… | Zip |
| `qt-development-skills` | Agentic engineering skills for Qt software development - Qt C++/QML code review, QML coding, and Qt… | Zip |
| `quarkus-agent` | MCP server for AI coding agents to create, manage, and interact with Quarkus applications. Provides… | Zip |
| `resend` | Agent skills for working with Resend to send and receive emails - email API integration, agent inbox,… | Zip |
| `salesforce-development` | Build Salesforce apps and agents using these core building blocks: metadata, Apex, deploy/retrieve,… | Git-Subdir |
| `sap-cds-mcp` | AI-assisted development of SAP Cloud Application Programming Model (CAP) projects. Search CDS models… | Zip |
| `sap-fiori-mcp-server` | MCP server for SAP Fiori development tools for Claude Code. Build and modify SAP Fiori applications… | Git-Subdir |
| `sap-mdk-server` | MCP server for SAP Mobile Development Kit (MDK). Build and modify MDK applications with AI assistance -… | Zip |
| `servicenow-sdk` | Create, edit, and deploy ServiceNow applications with the Fluent SDK effortlessly through Claude AI. | Git-Subdir |
| `shopify-ai-toolkit` | Shopify's AI Toolkit provides 18 development skills for building on the Shopify platform, covering… | Zip |
| `twilio-developer-kit` | Twilio Skills provide procedural knowledge for AI coding agents - which APIs to use, in what order, and… | Zip |
| `ui5` | SAPUI5 / OpenUI5 plugin for coding agents. Create and validate UI5 projects, access API documentation,… | Git-Subdir |
| `ui5-modernization` | Complete UI5 modernization toolkit with workflow and specialized fix patterns for modernizing… | Git-Subdir |
| `ui5-typescript-conversion` | SAPUI5 / OpenUI5 plugin for coding agents. Convert JavaScript based UI5 projects to TypeScript. | Git-Subdir |
| `unreal-engine-skills-for-claude-code` | Control Unreal Editor directly from Claude Code via MCP. Hundreds of tools exposed via Unreal's… | Zip |
| `vanta` | The Vanta plugin connects Claude Code to Vanta's security and compliance platform through the Vanta MCP… | Zip |
| `vanta-mcp-plugin` | The Vanta plugin connects Claude Code to Vanta's security and compliance platform through the Vanta MCP… | Zip |
| `wix` | Build, manage, and deploy Wix sites and apps. CLI development skills for dashboard extensions, backend… | Zip |
| `workos` | WorkOS integration skills for AuthKit, SSO, Directory Sync, RBAC, Vault, Audit Logs, migrations, and… | Git-Subdir |
| `zscaler` | Manage Zscaler cloud security platform including ZPA (private access), ZIA (internet access), ZDX… | Zip |

## Ortsbezug, Lernen, Einzelstücke — 4

| Plugin | Wofür | Quelle |
|---|---|---|
| `amazon-location-service` | Guide developers through adding maps, places search, geocoding, routing, and other geospatial features… | Git-Subdir |
| `learn-with-coursera` | Turn any learning intent into a personalized Coursera experience. Asks three quick questions (topic,… | Git-Subdir |
| `mapbox` | Mapbox skills and MCP servers for building location-aware applications with AI. Includes geospatial… | Zip |
| `math-olympiad` | Solve competition math (IMO, Putnam, USAMO) with adversarial verification that catches what… | im Repo |
---

## Verwandt

[[context-management]] — wo ein installiertes Plugin im Kontext landet, was ein Marketplace von einem Plugin unterscheidet, und warum 233 der 286 nicht im Repo liegen. [[plugin-update-flow]] — wie ein Update ankommt: Version bumpen, zwei Befehle, Reload. [[skill-map]] — die eigenen und smithy-Skills, also das, was hier bewusst *nicht* steht.
