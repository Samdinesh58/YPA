/**
 * model/services/StudentService.cfc
 * ---------------------------------
 * Reads and writes current students, with the name of their branch.
 * Same methods as ProfessorService (see the notes there).
 */
component {

    /** All students, grouped by batch then name. */
    public array function list() {
        return queryExecute(
            "SELECT s.id, s.name, s.batch, s.branch_id, s.photo_url, b.name AS branch_name
               FROM students s
               LEFT JOIN branches b ON b.id = s.branch_id
              ORDER BY s.batch, s.name",
            {},
            { returntype : "array" }
        );
    }

    /** One student by id, or an empty struct if not found. */
    public struct function get( required numeric id ) {
        var rows = queryExecute(
            "SELECT id, name, batch, branch_id, photo_url FROM students WHERE id = :id",
            { id : { value : arguments.id, cfsqltype : "cf_sql_integer" } },
            { returntype : "array" }
        );
        return rows.len() ? rows[ 1 ] : {};
    }

    public struct function newItem() {
        return { id : 0, name : "", batch : "", branch_id : "", photo_url : "" };
    }

    public struct function fromForm( required struct rc ) {
        return {
            id        : val( arguments.rc.id ?: 0 ),
            name      : trim( arguments.rc.name ?: "" ),
            batch     : trim( arguments.rc.batch ?: "" ),
            branch_id : val( arguments.rc.branch_id ?: 0 ),   // 0 = no branch
            photo_url : ""
        };
    }

    public array function validate( required struct data ) {
        var errors = [];
        if ( !len( arguments.data.name ) )  errors.append( "Please enter the student's name." );
        if ( !len( arguments.data.batch ) ) errors.append( "Please enter the batch." );
        if ( len( arguments.data.name ) > 120 ) errors.append( "The name must be 120 characters or fewer." );
        if ( len( arguments.data.batch ) > 80 ) errors.append( "The batch must be 80 characters or fewer." );
        return errors;
    }

    /** Inserts (id = 0) or updates a student. Returns the id. */
    public numeric function save( required struct data ) {
        var params = {
            name      : { value : arguments.data.name, cfsqltype : "cf_sql_varchar" },
            batch     : { value : arguments.data.batch, cfsqltype : "cf_sql_varchar" },
            branch_id : { value : arguments.data.branch_id, cfsqltype : "cf_sql_integer", null : arguments.data.branch_id <= 0 },
            photo_url : { value : arguments.data.photo_url, cfsqltype : "cf_sql_varchar", null : !len( arguments.data.photo_url ) }
        };

        if ( arguments.data.id > 0 ) {
            params.id = { value : arguments.data.id, cfsqltype : "cf_sql_integer" };
            queryExecute(
                "UPDATE students
                    SET name = :name, batch = :batch, branch_id = :branch_id, photo_url = :photo_url
                  WHERE id = :id",
                params
            );
            return arguments.data.id;
        }

        var result = {};
        queryExecute(
            "INSERT INTO students ( name, batch, branch_id, photo_url )
             VALUES ( :name, :batch, :branch_id, :photo_url )",
            params,
            { result : "result" }
        );
        return result.generatedKey;
    }

    public void function delete( required numeric id ) {
        queryExecute(
            "DELETE FROM students WHERE id = :id",
            { id : { value : arguments.id, cfsqltype : "cf_sql_integer" } }
        );
    }

    public string function getImageColumn() {
        return "photo_url";
    }

}
