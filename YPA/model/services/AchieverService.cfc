/**
 * model/services/AchieverService.cfc
 * ----------------------------------
 * Reads and writes past students who cleared their exams.
 * Same methods as ProfessorService (see the notes there).
 * `year` is in backticks because YEAR is also a MySQL keyword.
 */
component {

    /** All achievers, most recent year first. */
    public array function list() {
        return queryExecute(
            "SELECT id, name, exam, rank_or_post, `year`, photo_url
               FROM achievers
              ORDER BY `year` DESC, name",
            {},
            { returntype : "array" }
        );
    }

    /** One achiever by id, or an empty struct if not found. */
    public struct function get( required numeric id ) {
        var rows = queryExecute(
            "SELECT id, name, exam, rank_or_post, `year`, photo_url FROM achievers WHERE id = :id",
            { id : { value : arguments.id, cfsqltype : "cf_sql_integer" } },
            { returntype : "array" }
        );
        return rows.len() ? rows[ 1 ] : {};
    }

    public struct function newItem() {
        return { id : 0, name : "", exam : "", rank_or_post : "", year : year( now() ), photo_url : "" };
    }

    public struct function fromForm( required struct rc ) {
        return {
            id           : val( arguments.rc.id ?: 0 ),
            name         : trim( arguments.rc.name ?: "" ),
            exam         : trim( arguments.rc.exam ?: "" ),
            rank_or_post : trim( arguments.rc.rank_or_post ?: "" ),
            year         : trim( arguments.rc.year ?: "" ),
            photo_url    : ""
        };
    }

    public array function validate( required struct data ) {
        var errors = [];
        if ( !len( arguments.data.name ) )         errors.append( "Please enter the achiever's name." );
        if ( !len( arguments.data.exam ) )         errors.append( "Please enter the exam." );
        if ( !len( arguments.data.rank_or_post ) ) errors.append( "Please enter the rank or post." );
        if ( len( arguments.data.name ) > 120 || len( arguments.data.exam ) > 120 || len( arguments.data.rank_or_post ) > 120 ) {
            errors.append( "Name, exam and rank/post must each be 120 characters or fewer." );
        }
        if ( !isValid( "integer", arguments.data.year ) || arguments.data.year < 1950 || arguments.data.year > 2100 ) {
            errors.append( "Please enter a valid year, e.g. 2025." );
        }
        return errors;
    }

    /** Inserts (id = 0) or updates an achiever. Returns the id. */
    public numeric function save( required struct data ) {
        var params = {
            name         : { value : arguments.data.name, cfsqltype : "cf_sql_varchar" },
            exam         : { value : arguments.data.exam, cfsqltype : "cf_sql_varchar" },
            rank_or_post : { value : arguments.data.rank_or_post, cfsqltype : "cf_sql_varchar" },
            year         : { value : arguments.data.year, cfsqltype : "cf_sql_integer" },
            photo_url    : { value : arguments.data.photo_url, cfsqltype : "cf_sql_varchar", null : !len( arguments.data.photo_url ) }
        };

        if ( arguments.data.id > 0 ) {
            params.id = { value : arguments.data.id, cfsqltype : "cf_sql_integer" };
            queryExecute(
                "UPDATE achievers
                    SET name = :name, exam = :exam, rank_or_post = :rank_or_post,
                        `year` = :year, photo_url = :photo_url
                  WHERE id = :id",
                params
            );
            return arguments.data.id;
        }

        var result = {};
        queryExecute(
            "INSERT INTO achievers ( name, exam, rank_or_post, `year`, photo_url )
             VALUES ( :name, :exam, :rank_or_post, :year, :photo_url )",
            params,
            { result : "result" }
        );
        return result.generatedKey;
    }

    public void function delete( required numeric id ) {
        queryExecute(
            "DELETE FROM achievers WHERE id = :id",
            { id : { value : arguments.id, cfsqltype : "cf_sql_integer" } }
        );
    }

    public string function getImageColumn() {
        return "photo_url";
    }

}
