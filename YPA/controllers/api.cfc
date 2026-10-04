/**
 * controllers/api.cfc
 * -------------------
 * JSON endpoints used by assets/js/app.js. Each method asks a service for
 * its rows and sends them back with FW/1's renderData(), which skips the
 * view and layout and writes JSON instead.
 *
 *   index.cfm?action=api.professors  -> { "ok": true, "data": [ {...}, ... ] }
 *
 * On a database error the response is
 *   { "ok": false, "message": "..." }  with HTTP status 500.
 */
component accessors=true {

    // DI/1 sees these properties and injects the matching CFCs from
    // model/services/ (ProfessorService.cfc -> professorService, etc.).
    property professorService;
    property branchService;
    property achieverService;
    property eventService;
    property studentService;

    /** FW/1 passes itself in when it creates the controller. */
    public any function init( required any fw ) {
        variables.fw = arguments.fw;
        return this;
    }

    public void function professors( struct rc ) {
        sendList( variables.professorService, "professors" );
    }

    public void function branches( struct rc ) {
        sendList( variables.branchService, "branches" );
    }

    public void function achievers( struct rc ) {
        sendList( variables.achieverService, "achievers" );
    }

    public void function events( struct rc ) {
        sendList( variables.eventService, "events" );
    }

    public void function students( struct rc ) {
        sendList( variables.studentService, "students" );
    }

    /**
     * Calls service.list() and sends the rows as JSON.
     * If anything goes wrong, logs the real error on the server and sends
     * the browser a friendly message instead (never the raw error text).
     */
    private void function sendList( required any service, required string name ) {
        try {
            variables.fw.renderData( "json", { "ok" : true, "data" : arguments.service.list() } );
        } catch ( any e ) {
            writeLog( type = "error", file = "ypa", text = "api.#arguments.name# failed: #e.message# #e.detail#" );
            variables.fw.renderData(
                "json",
                { "ok" : false, "message" : "Sorry, we couldn't load this right now. Please try again in a moment." },
                500
            );
        }
    }

}
