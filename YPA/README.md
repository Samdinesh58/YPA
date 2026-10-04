# YPA Academy

A single-page website for YPA Academy, a coaching academy for government exams.

- **Server:** Lucee 6 (CFML) with the FW/1 framework, run by CommandBox
- **Database:** MySQL 8, database `ypa_academy`, Lucee datasource `ypa`
- **Front end:** Bootstrap 5 and jQuery 3 from a CDN

The page never fully reloads. The navbar links change the URL hash (`#branches`, `#events`, ...), and `assets/js/app.js` fetches the matching JSON from `index.cfm?action=api.<name>` and draws it on the page.

## Folder structure

```
YPA/
├── Application.cfc            FW/1 settings, the "ypa" datasource, site details
├── index.cfm                  empty: FW/1 handles every request
├── box.json                   CommandBox dependencies (FW/1, TestBox)
├── server.json                CommandBox server: Lucee 6 on port 8500
├── .env.example               copy to .env and add your MySQL login
├── admin/index.cfm            makes /admin go to the admin login
├── controllers/
│   ├── main.cfc               main.default: renders the page shell
│   ├── api.cfc                api.professors, api.branches, ... (JSON, read-only)
│   └── admin.cfc              login/logout, dashboard, poster, add/edit/delete
├── model/services/
│   ├── ProfessorService.cfc   one service per table: list, get, validate, save, delete
│   ├── BranchService.cfc
│   ├── AchieverService.cfc
│   ├── EventService.cfc
│   ├── StudentService.cfc
│   ├── AuthService.cfc        the static admin login + lockout after 5 wrong tries
│   ├── ImageService.cfc       safe image uploads into assets/uploads/
│   └── SettingService.cfc     poster image + tagline (site_settings table)
├── layouts/
│   ├── default.cfm            public page: <head>, navbar, #app, footer, modal
│   └── admin.cfm              admin pages
├── views/
│   ├── main/                  home (poster + professors) and error page
│   └── admin/                 login, dashboard, poster, <type>_list + <type>_form
├── assets/
│   ├── css/site.css
│   ├── js/app.js              hash router, API calls, cards, modal, admin pencils
│   ├── img/                   static images
│   └── uploads/               images uploaded in the admin area (created automatically)
├── db/
│   ├── schema.sql             creates the database, tables and sample rows
│   └── migrations/            later changes, run in number order
└── tests/                     TestBox runner + one test per service
```

## Run it locally (Windows)

### 1. Install the tools

1. **Java 11 or newer.** Check with `java -version`.
2. **CommandBox:** download it from <https://www.ortussolutions.com/products/commandbox>, unzip it, and put `box.exe` in a folder on your PATH (for example `C:\CommandBox`). Check with `box version`.
3. **MySQL 8 Server:** install it from <https://dev.mysql.com/downloads/installer/>. Make a note of the root password you choose.

### 2. Create the database

Open a terminal in the project folder and run:

```bash
mysql -u root -p < db/schema.sql
```

(If `mysql` is not found, run it from MySQL Workbench instead: *File → Open SQL Script → db/schema.sql → Execute*.)

This creates the `ypa_academy` database, the five tables and some sample rows.

Then run the migrations in number order. Each one runs only once:

```bash
mysql -u root -p ypa_academy < db/migrations/001_admin_images_and_settings.sql
```

This adds image columns to branches, events and students, and the `site_settings` table used for the poster.

Next, create a MySQL user just for the website. Using root for the site is not recommended:

```sql
CREATE USER 'ypa_app'@'localhost' IDENTIFIED BY 'choose-a-strong-password';
GRANT SELECT, INSERT, UPDATE, DELETE ON ypa_academy.* TO 'ypa_app'@'localhost';
FLUSH PRIVILEGES;
```

### 3. Set up the Lucee datasource

The `ypa` datasource is **defined in code** in `Application.cfc` (`this.datasources["ypa"]`). You don't need to click through the Lucee admin. The code reads its login details from environment variables:

1. Copy `.env.example` to `.env`.
2. Fill in your values:
   ```
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_NAME=ypa_academy
   DB_USER=ypa_app
   DB_PASSWORD=choose-a-strong-password
   ```
3. CommandBox reads `.env` when the server starts. If you change `.env`, run `box server restart`.

*Alternative: create it in the Lucee admin.* Open `http://127.0.0.1:8500/lucee/admin/server.cfm`, set an admin password the first time, and go to **Services → Datasource**. Enter the name `ypa`, choose type **MySQL**, click **Create**, then fill in host `127.0.0.1`, port `3306`, database `ypa_academy`, and your username and password. Click **Create** again and check that the status shows **OK**. If you do this, delete the `this.datasources["ypa"] = {...}` block in `Application.cfc` so the two don't conflict. Keep `this.datasource = "ypa";`.

### 4. Install dependencies and start the server

```bash
box install          # downloads FW/1 into /framework and TestBox into /testbox
box server start     # starts Lucee 6 on http://127.0.0.1:8500 and opens the browser
```

The first start downloads Lucee, which takes a minute. Then open <http://127.0.0.1:8500/>.

Useful commands:

```bash
box server log --follow   # watch the server log (database errors appear here)
box server stop
box testbox run           # run the tests (needs the server running and the DB loaded)
```

### 5. Add your own content (admin area)

1. Go to <http://127.0.0.1:8500/admin>. It redirects to the login page.
2. Log in with the admin username and password. The account is set in `model/services/AuthService.cfc`, not in the database.
3. From there you can:
   - **Poster:** upload or remove the poster image and change the tagline.
   - **Professors, Branches, Achievers, Events, Students:** each has its own list and its own add/edit form with an image upload, plus Delete.
4. While logged in, the public site shows a yellow admin bar, **pencil icons** on the poster and on every card or row, and an **"+ Add ..." button** above every list. Saving from a pencil brings you back to the same section of the site.

Uploaded images go into `assets/uploads/<type>/` with random file names. They are not in git, so back up that folder along with the database.

**Changing the admin password:** run `writeOutput( hash( "new-password", "SHA-256" ) );` in any CFML page, then paste the result into `variables.passwordHash` in `AuthService.cfc`. Only the hash is stored, never the password itself. After 5 wrong attempts, logins from that IP address are blocked for 15 minutes.

The address, phone and email in the footer are still set in `setupApplication()` in `Application.cfc`.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| Page shows "Sorry, we couldn't load this right now" | The database call failed. Run `box server log --follow` to see why. Usually the `.env` values are wrong or MySQL isn't running. |
| Log says the class `com.mysql.cj.jdbc.Driver` could not be loaded | The MySQL extension is missing. In the Lucee admin go to **Extension → Applications**, install **MySQL**, then restart. |
| Error that `framework.one` could not be found | Run `box install`, then check that `framework/one.cfc` exists. If FW/1 ended up in `framework/framework/`, move those files up one level. |
| Changes don't show up | `reloadApplicationOnEveryRequest` is on, so CFML changes appear on the next request. For CSS and JS changes, hard-refresh the browser (Ctrl+F5). |

## Before going live

- Set `reloadApplicationOnEveryRequest` to `false` in `Application.cfc`.
- Use a MySQL user with only the permissions the site needs.
- Turn on HTTPS, and enable SSL on the MySQL connection if the database is on another machine.
- Once HTTPS is on, uncomment `secure : true` in `this.sessionCookie` in `Application.cfc` so the admin login cookie is only sent over HTTPS.
- Change the admin password (see step 5) and don't share it.
