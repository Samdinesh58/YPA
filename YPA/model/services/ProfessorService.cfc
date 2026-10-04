/**
 * model/services/ProfessorService.cfc
 * -----------------------------------
 * Reads and writes professors in MySQL. DI/1 creates one shared instance
 * (a singleton) and injects it wherever "property professorService;" is
 * declared.
 *
 * Every entity service (Professor, Branch, Achiever, Event, Student) has the
 * same methods, so the admin controller can treat them all the same way:
 *   list(), get(id), newItem(), fromForm(rc), validate(data), save(data),
 *   delete(id), getImageColumn()
 */
component {

    /** All professors, in the order they should appear on the page. */
    public array function list() {
        return queryExecute(
            "SELECT id, name, subject, qualification, experience_years, bio,
                    photo_url, accent_color, display_order
               FROM professors
              ORDER BY display_order, name",
            {},
            { returntype : "array" }
        );
    }

    /** One professor by id, or an empty struct if not found. */
    public struct function get( required numeric id ) {
        var rows = queryExecute(
            "SELECT id, name, subject, qualification, experience_years, bio,
                    photo_url, accent_color, display_order
               FROM professors
              WHERE id = :id",
            { id : { value : arguments.id, cfsqltype : "cf_sql_integer" } },
            { returntype : "array" }
        );
        return rows.len() ? rows[ 1 ] : {};
    }

    /** Default values for the "Add professor" form. */
    public struct function newItem() {
        return {
            id : 0, name : "", subject : "", qualification : "", experience_years : 0,
            bio : "", photo_url : "", accent_color : "", display_order : 0
        };
    }

    /** Picks this entity's fields out of the submitted form, trimmed. */
    public struct function fromForm( required struct rc ) {
        return {
            id               : val( arguments.rc.id ?: 0 ),
            name             : trim( arguments.rc.name ?: "" ),
            subject          : trim( arguments.rc.subject ?: "" ),
            qualification    : trim( arguments.rc.qualification ?: "" ),
            experience_years : trim( arguments.rc.experience_years ?: "0" ),
            bio              : trim( arguments.rc.bio ?: "" ),
            accent_color     : trim( arguments.rc.accent_color ?: "" ),
            display_order    : trim( arguments.rc.display_order ?: "0" ),
            photo_url        : ""   // filled in by the controller after the upload
        };
    }

    /** Returns a list of problems with the data (empty array = all good). */
    public array function validate( required struct data ) {
        var errors = [];
        if ( !len( arguments.data.name ) )    errors.append( "Please enter the professor's name." );
        if ( !len( arguments.data.subject ) ) errors.append( "Please enter the subject." );
        if ( len( arguments.data.name ) > 120 )          errors.append( "The name must be 120 characters or fewer." );
        if ( len( arguments.data.subject ) > 80 )        errors.append( "The subject must be 80 characters or fewer." );
        if ( len( arguments.data.qualification ) > 120 ) errors.append( "The qualification must be 120 characters or fewer." );
        if ( !isValid( "integer", arguments.data.experience_years ) || arguments.data.experience_years < 0 || arguments.data.experience_years > 60 ) {
            errors.append( "Years of experience must be a whole number from 0 to 60." );
        }
        if ( !isValid( "integer", arguments.data.display_order ) ) {
            errors.append( "Display order must be a whole number." );
        }
        if ( len( arguments.data.accent_color ) && !reFind( "^##[0-9A-Fa-f]{6}$", arguments.data.accent_color ) ) {
            errors.append( "Please choose a valid accent colour." );
        }
        return errors;
    }

    /** Inserts (id = 0) or updates a professor. Returns the id. */
    public numeric function save( required struct data ) {
        var params = {
            name             : { value : arguments.data.name, cfsqltype : "cf_sql_varchar" },
            subject          : { value : arguments.data.subject, cfsqltype : "cf_sql_varchar" },
            qualification    : { value : arguments.data.qualification, cfsqltype : "cf_sql_varchar", null : !len( arguments.data.qualification ) },
            experience_years : { value : arguments.data.experience_years, cfsqltype : "cf_sql_integer" },
            bio              : { value : arguments.data.bio, cfsqltype : "cf_sql_varchar", null : !len( arguments.data.bio ) },
            photo_url        : { value : arguments.data.photo_url, cfsqltype : "cf_sql_varchar", null : !len( arguments.data.photo_url ) },
            accent_color     : { value : arguments.data.accent_color, cfsqltype : "cf_sql_varchar", null : !len( arguments.data.accent_color ) },
            display_order    : { value : arguments.data.display_order, cfsqltype : "cf_sql_integer" }
        };

        if ( arguments.data.id > 0 ) {
            params.id = { value : arguments.data.id, cfsqltype : "cf_sql_integer" };
            queryExecute(
                "UPDATE professors
                    SET name = :name, subject = :subject, qualification = :qualification,
                        experience_years = :experience_years, bio = :bio, photo_url = :photo_url,
                        accent_color = :accent_color, display_order = :display_order
                  WHERE id = :id",
                params
            );
            return arguments.data.id;
        }

        var result = {};
        queryExecute(
            "INSERT INTO professors
                ( name, subject, qualification, experience_years, bio, photo_url, accent_color, display_order )
             VALUES
                ( :name, :subject, :qualification, :experience_years, :bio, :photo_url, :accent_color, :display_order )",
            params,
            { result : "result" }
        );
        return result.generatedKey;
    }

    /** Deletes one professor. */
    public void function delete( required numeric id ) {
        queryExecute(
            "DELETE FROM professors WHERE id = :id",
            { id : { value : arguments.id, cfsqltype : "cf_sql_integer" } }
        );
    }

    /** The column that holds this entity's image path. */
    public string function getImageColumn() {
        return "photo_url";
    }

}
