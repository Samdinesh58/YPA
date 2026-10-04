/**
 * model/services/AuthService.cfc
 * ------------------------------
 * Checks the admin login. There is one static admin account, no database.
 *
 * Only a SHA-256 hash of the password is stored here, never the password
 * itself. To change the password, run this once in any CFML page and paste
 * the result into variables.passwordHash:
 *     writeOutput( hash( "your-new-password", "SHA-256" ) );
 *
 * After 5 wrong attempts from the same IP address, logins from that address
 * are blocked for 15 minutes, which slows down password guessing.
 */
component {

    variables.username     = "samdinesh";
    variables.passwordHash = "75607CFD68DDC192717105823EEDAFD23CF4168B65591DAA304893E87FA6FB1E";

    variables.maxAttempts  = 5;
    variables.lockMinutes  = 15;

    /** True when both the username and password are correct. */
    public boolean function checkLogin( required string username, required string password ) {
        var usernameOk = compare( arguments.username, variables.username ) == 0;               // case-sensitive
        var passwordOk = compareNoCase( hash( arguments.password, "SHA-256" ), variables.passwordHash ) == 0;
        return usernameOk && passwordOk;
    }

    /** True while this IP address is blocked after too many wrong attempts. */
    public boolean function isLockedOut( required string ip ) {
        var failures = getFailures();
        if ( !structKeyExists( failures, arguments.ip ) ) {
            return false;
        }
        var entry = failures[ arguments.ip ];
        if ( entry.count >= variables.maxAttempts
             && dateDiff( "n", entry.lastAttempt, now() ) < variables.lockMinutes ) {
            return true;
        }
        // The block has expired: start counting again.
        if ( dateDiff( "n", entry.lastAttempt, now() ) >= variables.lockMinutes ) {
            structDelete( failures, arguments.ip );
        }
        return false;
    }

    /** Counts one wrong attempt for this IP address. */
    public void function recordFailure( required string ip ) {
        lock name="ypaLoginFailures" type="exclusive" timeout="5" {
            var failures = getFailures();
            if ( !structKeyExists( failures, arguments.ip ) ) {
                failures[ arguments.ip ] = { count : 0, lastAttempt : now() };
            }
            failures[ arguments.ip ].count++;
            failures[ arguments.ip ].lastAttempt = now();
        }
    }

    /** Forgets wrong attempts after a successful login. */
    public void function clearFailures( required string ip ) {
        structDelete( getFailures(), arguments.ip );
    }

    /**
     * Failed attempts live in the application scope (not in this CFC) so
     * they survive the framework reload that happens on every request in
     * development.
     */
    private struct function getFailures() {
        if ( !structKeyExists( application, "loginFailures" ) ) {
            application.loginFailures = {};
        }
        return application.loginFailures;
    }

}
