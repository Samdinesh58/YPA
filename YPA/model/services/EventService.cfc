/**
 * model/services/EventService.cfc
 * -------------------------------
 * Reads and writes events, with the name of the branch hosting each one.
 * Same methods as ProfessorService (see the notes there).
 *
 * event_date is returned as "YYYY-MM-DD" text (formatted in SQL), which is
 * what both the browser and <input type="date"> expect.
 */
component {

    /** All events, soonest first. */
    public array function list() {
        return queryExecute(
            "SELECT e.id, e.title, DATE_FORMAT( e.event_date, '%Y-%m-%d' ) AS event_date,
                    e.description, e.branch_id, e.image_url, b.name AS branch_name
               FROM events e
               LEFT JOIN branches b ON b.id = e.branch_id
              ORDER BY e.event_date, e.title",
            {},
            { returntype : "array" }
        );
    }

    /** One event by id, or an empty struct if not found. */
    public struct function get( required numeric id ) {
        var rows = queryExecute(
            "SELECT id, title, DATE_FORMAT( event_date, '%Y-%m-%d' ) AS event_date,
                    description, branch_id, image_url
               FROM events
              WHERE id = :id",
            { id : { value : arguments.id, cfsqltype : "cf_sql_integer" } },
            { returntype : "array" }
        );
        return rows.len() ? rows[ 1 ] : {};
    }

    public struct function newItem() {
        return { id : 0, title : "", event_date : "", description : "", branch_id : "", image_url : "" };
    }

    public struct function fromForm( required struct rc ) {
        return {
            id          : val( arguments.rc.id ?: 0 ),
            title       : trim( arguments.rc.title ?: "" ),
            event_date  : trim( arguments.rc.event_date ?: "" ),
            description : trim( arguments.rc.description ?: "" ),
            branch_id   : val( arguments.rc.branch_id ?: 0 ),   // 0 = all branches
            image_url   : ""
        };
    }

    public array function validate( required struct data ) {
        var errors = [];
        if ( !len( arguments.data.title ) )      errors.append( "Please enter the event title." );
        if ( len( arguments.data.title ) > 160 ) errors.append( "The title must be 160 characters or fewer." );
        if ( !isValidIsoDate( arguments.data.event_date ) ) {
            errors.append( "Please choose a valid event date." );
        }
        return errors;
    }

    /** Inserts (id = 0) or updates an event. Returns the id. */
    public numeric function save( required struct data ) {
        var parts = listToArray( arguments.data.event_date, "-" );
        var params = {
            title       : { value : arguments.data.title, cfsqltype : "cf_sql_varchar" },
            event_date  : { value : createDate( parts[ 1 ], parts[ 2 ], parts[ 3 ] ), cfsqltype : "cf_sql_date" },
            description : { value : arguments.data.description, cfsqltype : "cf_sql_varchar", null : !len( arguments.data.description ) },
            branch_id   : { value : arguments.data.branch_id, cfsqltype : "cf_sql_integer", null : arguments.data.branch_id <= 0 },
            image_url   : { value : arguments.data.image_url, cfsqltype : "cf_sql_varchar", null : !len( arguments.data.image_url ) }
        };

        if ( arguments.data.id > 0 ) {
            params.id = { value : arguments.data.id, cfsqltype : "cf_sql_integer" };
            queryExecute(
                "UPDATE events
                    SET title = :title, event_date = :event_date, description = :description,
                        branch_id = :branch_id, image_url = :image_url
                  WHERE id = :id",
                params
            );
            return arguments.data.id;
        }

        var result = {};
        queryExecute(
            "INSERT INTO events ( title, event_date, description, branch_id, image_url )
             VALUES ( :title, :event_date, :description, :branch_id, :image_url )",
            params,
            { result : "result" }
        );
        return result.generatedKey;
    }

    public void function delete( required numeric id ) {
        queryExecute(
            "DELETE FROM events WHERE id = :id",
            { id : { value : arguments.id, cfsqltype : "cf_sql_integer" } }
        );
    }

    public string function getImageColumn() {
        return "image_url";
    }

    /** True for a real calendar date written as YYYY-MM-DD. */
    private boolean function isValidIsoDate( required string value ) {
        if ( !reFind( "^\d{4}-\d{2}-\d{2}$", arguments.value ) ) {
            return false;
        }
        var parts = listToArray( arguments.value, "-" );
        return parts[ 2 ] >= 1 && parts[ 2 ] <= 12
            && parts[ 3 ] >= 1 && parts[ 3 ] <= daysInMonth( createDate( parts[ 1 ], parts[ 2 ], 1 ) );
    }

}
