/**
 * Application.cfc
 * ---------------
 * Every request to the site starts here. This component extends FW/1
 * ("framework.one"), so FW/1 reads the "action" from the URL, runs the
 * matching controller method and then renders the matching view inside
 * the layout.
 *
 *   index.cfm                       -> action "main.default" (the page shell)
 *   index.cfm?action=api.professors -> controllers/api.cfc professors() (JSON)
 */
component extends="framework.one" {

    // ---- Basic application settings ---------------------------------------
    this.name               = "YPA_Academy";
    this.applicationTimeout = createTimeSpan( 1, 0, 0, 0 );

    // Sessions remember that the admin has logged in.
    this.sessionManagement  = true;
    this.sessionTimeout     = createTimeSpan( 0, 0, 30, 0 );   // log out after 30 idle minutes
    this.sessionCookie      = {
        httpOnly : true,     // JavaScript can't read the session cookie
        sameSite : "Lax"     // the cookie isn't sent on cross-site form posts
        // secure : true     // turn on once the site runs on HTTPS
    };

    // ---- Database ----------------------------------------------------------
    // The "ypa" datasource points at the MySQL database "ypa_academy".
    // Credentials are read from environment variables (CommandBox loads them
    // from the .env file), so no passwords are written in this file.
    this.datasources[ "ypa" ] = {
        class            : "com.mysql.cj.jdbc.Driver",
        bundleName       : "com.mysql.cj",
        connectionString : "jdbc:mysql://"
                         & getEnvSetting( "DB_HOST", "127.0.0.1" ) & ":"
                         & getEnvSetting( "DB_PORT", "3306" ) & "/"
                         & getEnvSetting( "DB_NAME", "ypa_academy" )
                         & "?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&useSSL=false&allowPublicKeyRetrieval=true",
        username         : getEnvSetting( "DB_USER", "root" ),
        password         : getEnvSetting( "DB_PASSWORD", "" )
    };
    this.datasource = "ypa";   // queryExecute() uses this datasource by default

    // ---- FW/1 settings -----------------------------------------------------
    variables.framework = {
        defaultSection : "main",      // index.cfm with no action -> main.default
        defaultItem    : "default",
        generateSES    : true,        // buildURL() makes /index.cfm/section/item style links
        // DEVELOPMENT ONLY: reloads FW/1 and DI/1 on every request so changes
        // show up straight away. Set this to false in production.
        reloadApplicationOnEveryRequest : true,
        trace          : false
        // DI/1 is used automatically. It scans /model and /controllers, so a
        // controller that declares "property professorService;" gets
        // model/services/ProfessorService.cfc injected.
    };

    /**
     * Runs once when the application starts (and on every request while
     * reloadApplicationOnEveryRequest is true).
     * Edit the site details here; the layout and home view read them.
     */
    public void function setupApplication() {
        application.siteInfo = {
            name    : "YPA Academy",
            tagline : "Coaching that turns government exam aspirants into achievers",
            address : "Walker HR Sec School, Dohnavur 627102",
            phone   : "+91 9087232748",
            email   : "samdinesh58@gmail.com"
        };
    }

    /**
     * Runs before any view or layout is rendered. Puts values every view
     * needs into rc (the request context).
     */
    public void function setupView( struct rc ) {
        arguments.rc.site = application.siteInfo;
        // The folder the app runs from ("/" normally). Used to build asset and
        // API URLs that work even if the site lives in a sub-folder.
        arguments.rc.basePath = getDirectoryFromPath( cgi.script_name );

        // Is the visitor logged in as admin? (Set by controllers/admin.cfc.)
        // The public pages use this to show pencil icons and "Add" buttons.
        arguments.rc.isAdmin = structKeyExists( session, "isAdmin" ) && session.isAdmin;
        if ( arguments.rc.isAdmin || getSection() == "admin" ) {
            // Every admin form (including the login form) must send this
            // token back, so other websites can't post forms here (CSRF).
            arguments.rc.csrfToken = csrfGenerateToken( "ypaAdmin" );
        }
    }

    /**
     * Reads a setting from the environment. CommandBox may load .env values
     * as environment variables or as Java system properties, so check both.
     */
    private string function getEnvSetting( required string name, string defaultValue = "" ) {
        if ( structKeyExists( server.system.environment, arguments.name ) ) {
            return server.system.environment[ arguments.name ];
        }
        if ( structKeyExists( server.system.properties, arguments.name ) ) {
            return server.system.properties[ arguments.name ];
        }
        return arguments.defaultValue;
    }

}
