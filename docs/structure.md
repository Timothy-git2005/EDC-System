
Structure · MD
# LibreClinica Project – File Structure
 
Local EDC stack: LibreClinica + PostgreSQL + Mailpit, monitored with Grafana, Loki and Alloy.
 
**Location:** `~/projects/libreclinica` (inside WSL, never under `/mnt/c` or OneDrive)
 
## Legend
 
| Symbol | Meaning |
|---|---|
| ✅ | tracked in Git |
| ❌ | never in Git (secret, large binary, or generated) |
| ⚠️ | in Git only as a template; decided in Lesson 6 |
| `(L4)` | lesson where the file is created |
 
## Project folder
 
```
~/projects/libreclinica/                    ← Git repo
│
├── README.md                               ✅  what this is, how to start it
├── .gitignore                              ✅  what Git must skip                    (L4)
├── .env.example                            ✅  variable template, fake values         (L4)
├── .env                                    ❌  real passwords                         (L4)
├── docker-compose.yml                      ✅  starts the whole stack                 (L8)
│
├── scripts/
│   └── get-war.sh                          ✅  downloads the pinned war version       (L5)
│
├── postgres/
│   └── init/
│       └── 01-create-libreclinica.sh       ✅  creates libcl_user + libcl_db          (L4)
│
├── webapps/
│   └── libreclinica.war                    ❌  ~100 MB, downloaded by script          (L5)
│
├── config/
│   └── datainfo.properties                 ⚠️  extracted from the war; holds DB password (L6)
│
├── alloy/
│   └── config.alloy                        ✅  log collection                         (L13)
│
├── grafana/
│   └── provisioning/
│       └── datasources/
│           └── datasources.yml             ✅  Grafana → Loki + Postgres               (L14)
│
├── analytics/                              ✅  uv Python project                      (L11)
│   ├── pyproject.toml                      ✅
│   ├── uv.lock                             ✅
│   ├── .env                                ❌  analyst password
│   ├── ingestion/
│   ├── transform/
│   └── tests/
│
└── docs/
    ├── decisions.md                        ✅  why Postgres 14, port 5433, Alloy, ...
    └── lineage.md                          ✅  where the test data comes from
```
 
## Docker volumes (managed by Docker, outside the project folder)
 
| Volume | Holds | Mounted at (inside container) |
|---|---|---|
| `pgdata` | the LibreClinica database | `/var/lib/postgresql/data` |
| `lcdata` | uploaded files | `/usr/local/tomcat/libreclinica.data` |
| `lclogs` | LibreClinica's own log files | `/usr/local/tomcat/libreclinica/logs` |
| `loki-data` | stored logs | `/loki` |
| `alloy-data` | Alloy's progress state | `/var/lib/alloy/data` |
| `grafana-data` | dashboards, users | `/var/lib/grafana` |
 
Mailpit needs no files and no volume: it keeps the fake emails in memory only.
 
⚠️ Volumes are the data. Never run `docker system prune --volumes` or `docker compose down -v` without a fresh backup.
 
## Current names (from `.env`)
 
| Variable | Value | Used for |
|---|---|---|
| `POSTGRES_PASSWORD` | *(secret)* | `postgres` superuser, maintenance only |
| `LIBCL_DB_USER` | `libcl_user` | restricted app user (no superuser, no createdb, no createrole, no inherit) |
| `LIBCL_DB_PASSWORD` | *(secret)* | password of `libcl_user` |
| `LIBCL_DB_NAME` | `libcl_db` | the LibreClinica database, owned by `libcl_user` |
 
Postgres names are always **lowercase**: unquoted names are folded to lowercase, and JDBC uses the name exactly as written.
 
## Ports
 
| Port (Windows side) | Service | Note |
|---|---|---|
| 5432 | shared Postgres 16 (`pg`) | already in use, separate stack |
| 5433 | LibreClinica Postgres 14 | inside Docker it is still 5432 |
| 8080 | LibreClinica (Tomcat) | `http://localhost:8080/libreclinica` |
| 8025 | Mailpit inbox | fake mail server |
| 3000 | Grafana | |
| 3100 | Loki | |
| 12345 | Alloy debug UI | |
 
**Inside vs. outside:** containers talk to each other by service name and internal port (`db:5432`). Windows tools (DataGrip, Python scripts) use `localhost` and the left-hand port (`localhost:5433`).
 
## The rule behind the split
 
- **Files in the folder** = *how* the system is set up. Written by you, tracked by Git, enough to rebuild the setup anywhere.
- **Volumes** = *what* the system has stored. Created at runtime, never in Git, protected by backups.
- **❌ files in the folder** = secrets or re-downloadable binaries, kept out of Git by `.gitignore`.
 
