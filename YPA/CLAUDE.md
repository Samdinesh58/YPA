# CLAUDE.md

This file guides Claude Code (claude.ai/code) when working in this repository.

## Project Overview

**YPA** is a web application built with **Lucee CFML** and the **FW/1 (Framework One)** MVC framework.

- **Language:** CFML, using script syntax (`component { }`) for all CFCs
- **Engine:** Lucee 6.x
- **Framework:** FW/1 4.x, with its built-in DI/1 for dependency injection
- **Server / tooling:** CommandBox (`box`)
- **Testing:** TestBox
- **Database:** MySQL 8.x, using the MySQL Connector/J JDBC driver bundled with Lucee

## Database

- **Datasource:** defined in `Application.cfc` as `this.datasources["ypa"]` and set as the default with `this.datasource = "ypa"`. Credentials come from environment variables (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`), never hard-coded:
  ```cfml
  variables.env = server.system.environment;   // in the Application.cfc component body
  this.datasources["ypa"] = {
      class: "com.mysql.cj.jdbc.Driver",
      bundleName: "com.mysql.cj",
      connectionString: "jdbc:mysql://#env.DB_HOST#:#env.DB_PORT#/#env.DB_NAME#?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&useSSL=false&allowPublicKeyRetrieval=true",
      username: env.DB_USER,
      password: env.DB_PASSWORD
  };
  this.datasource = "ypa";
  ```
- **Charset:** use `utf8mb4` / `utf8mb4_unicode_ci` for the database and every table.
- **Engine:** InnoDB for every table (it gives transactions and foreign keys).
- **Table naming:** plural `snake_case` table names (`users`, `order_items`), `snake_case` columns, primary key `id INT UNSIGNED AUTO_INCREMENT`, plus `created_at` / `updated_at` `DATETIME` columns.
- **Schema changes:** keep versioned SQL scripts in `db/migrations/` (`001_create_users.sql`, `002_...`). Never change an existing migration; add a new one instead.
- **cfsqltype mapping:** `INT` → `cf_sql_integer`, `VARCHAR`/`TEXT` → `cf_sql_varchar`, `DATETIME` → `cf_sql_timestamp`, `DECIMAL` → `cf_sql_decimal`, `TINYINT(1)` → `cf_sql_bit`.
- **Transactions:** wrap writes that span several tables in `transaction { }`.
- **Getting the new id after an insert:** use `result.generatedKey` from `queryExecute( sql, params, { result: "result" } )`.

## Common Commands

```bash
box install                 # install dependencies listed in box.json (fw1, testbox, ...)
box server start            # start the Lucee server (settings in server.json)
box server stop
box server restart
box server log --follow     # tail the server log
box testbox run             # run all tests
box testbox run bundles=tests.specs.services.UserServiceTest   # run one test bundle
```

Reload the FW/1 framework after changing config, services, or DI wiring:
`http://127.0.0.1:<port>/index.cfm?reload=true` (the key is set by `reloadApplicationOnRequest` / `reload` in the FW/1 settings).

## Directory Structure

```
/
├── Application.cfc        # extends framework.one; app settings and FW/1 config
├── index.cfm              # empty; every request goes through Application.cfc
├── box.json               # CommandBox dependencies
├── server.json            # CommandBox server config (Lucee version, port, rewrites)
├── framework/             # FW/1 core (installed via box, do not edit)
├── controllers/           # FW/1 controllers, one CFC per section
├── model/
│   ├── services/          # business logic (singletons, wired by DI/1)
│   ├── beans/             # transient domain objects
│   └── gateways/          # database access (queryExecute)
├── views/
│   └── <section>/<item>.cfm
├── layouts/
│   ├── default.cfm        # site-wide layout
│   └── <section>.cfm      # optional per-section layout
├── assets/                # css, js, images
├── config/                # environment-specific settings
├── db/
│   └── migrations/        # versioned MySQL schema scripts
├── .env                   # local DB credentials (not committed)
└── tests/
    ├── Application.cfc
    ├── runner.cfm
    └── specs/
```

## FW/1 Conventions

- **Actions** have the form `section.item`. `?action=user.list` runs `controllers/user.cfc` → `list(rc)`, then renders `views/user/list.cfm` inside `layouts/user.cfm` (if present) and then `layouts/default.cfm`.
- **Default action** is `main.default` unless changed in the settings.
- **`rc`** (request context) carries URL/form data and data for views. Controllers fill `rc`; views only read it.
- **Controllers stay thin:** validate input, call a service, put results in `rc`, then redirect or render. Business logic goes in services.
- **Dependency injection:** DI/1 wires CFCs under `model/` by name. Declare dependencies as properties and they are injected:
  ```cfml
  component accessors=true {
      property userService;   // injects model/services/UserService.cfc
  }
  ```
- **Redirects after POST:** use `variables.fw.redirect( "user.list", "message" )` to follow Post/Redirect/Get and keep flash data.
- **Controller lifecycle methods:** `before(rc)`, `after(rc)`, `startItem(rc)`, `endItem(rc)` are available when needed.
- **Security checks** (authentication, authorisation) go in `Application.cfc` → `setupRequest()` or a controller's `before(rc)`.

## Coding Standards

- **Script syntax only** in CFCs. Use tag syntax only in `.cfm` views.
- **Always scope variables:** `var`/`local` in functions, `arguments.`, `variables.`, `rc.`. Never use unscoped variables.
- **Queries:** use `queryExecute()` with **parameters every time**. Never concatenate user input into SQL.
  ```cfml
  queryExecute(
      "SELECT id, name FROM users WHERE id = :id",
      { id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
  );
  ```
- **Output encoding in views:** escape all dynamic output with `encodeForHTML()`, `encodeForHTMLAttribute()`, `encodeForJavaScript()` or `encodeForURL()` as appropriate.
- **CSRF:** protect every state-changing form with `csrfGenerateToken()` / `csrfVerifyToken()`.
- **Naming:** PascalCase for CFC files (`UserService.cfc`), except controllers, which use lowercase section names (`user.cfc`). camelCase for functions and variables.
- **Functions:** declare `access`, return type and argument types, e.g. `public array function list( required numeric id )`.
- **No secrets in code.** Read credentials from environment variables (`server.system.environment`) or `.env` files that are not committed.

## Testing

- Tests live in `tests/specs/` and mirror the `model/` structure.
- Use TestBox BDD style (`describe` / `it` / `expect`).
- Every new service method should have a test. Mock gateways in service tests.

## Notes for Claude

- Do not edit anything in `framework/`. It is a third-party dependency.
- After changing `Application.cfc` or DI wiring, remember that a framework reload (`?reload=true`) is needed.
- Follow the existing section/item layout when adding features: controller method + view + service method (+ gateway method if it touches the DB) + test.
