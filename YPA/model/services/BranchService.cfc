/**
 * model/services/BranchService.cfc
 * --------------------------------
 * Reads and writes the academy's branches.
 * Same methods as ProfessorService (see the notes there).
 */
component {

    /** All branches, alphabetically. */
    public array function list() {
        return queryExecute(
            "SELECT id, name, address, phone, image_url
               FROM branches
              ORDER BY name",
            {},
            { returntype : "array" }
        );
    }

    /** One branch by id, or an empty struct if not found. */
    public struct function get( required numeric id ) {
        var rows = queryExecute(
            "SELECT id, name, address, phone, image_url FROM branches WHERE id = :id",
            { id : { value : arguments.id, cfsqltype : "cf_sql_integer" } },
            { returntype : "array" }
        );
        return rows.len() ? rows[ 1 ] : {};
    }

    public struct function newItem() {
        return { id : 0, name : "", address : "", phone : "", image_url : "" };
    }

    public struct function fromForm( required struct rc ) {
        return {
            id        : val( arguments.rc.id ?: 0 ),
            name      : trim( arguments.rc.name ?: "" ),
            address   : trim( arguments.rc.address ?: "" ),
            phone     : trim( arguments.rc.phone ?: "" ),
            image_url : ""
        };
    }

    public array function validate( required struct data ) {
        var errors = [];
        if ( !len( arguments.data.name ) )    errors.append( "Please enter the branch name." );
        if ( !len( arguments.data.address ) ) errors.append( "Please enter the address." );
        if ( len( arguments.data.name ) > 120 )    errors.append( "The name must be 120 characters or fewer." );
        if ( len( arguments.data.address ) > 255 ) errors.append( "The address must be 255 characters or fewer." );
        if ( len( arguments.data.phone ) && !reFind( "^[0-9+()\- ]{6,30}$", arguments.data.phone ) ) {
            errors.append( "The phone number may only contain digits, spaces, +, - and brackets." );
        }
        return errors;
    }

    /** Inserts (id = 0) or updates a branch. Returns the id. */
    public numeric function save( required struct data ) {
        var params = {
            name      : { value : arguments.data.name, cfsqltype : "cf_sql_varchar" },
            address   : { value : arguments.data.address, cfsqltype : "cf_sql_varchar" },
            phone     : { value : arguments.data.phone, cfsqltype : "cf_sql_varchar", null : !len( arguments.data.phone ) },
            image_url : { value : arguments.data.image_url, cfsqltype : "cf_sql_varchar", null : !len( arguments.data.image_url ) }
        };

        if ( arguments.data.id > 0 ) {
            params.id = { value : arguments.data.id, cfsqltype : "cf_sql_integer" };
            queryExecute(
                "UPDATE branches
                    SET name = :name, address = :address, phone = :phone, image_url = :image_url
                  WHERE id = :id",
                params
            );
            return arguments.data.id;
        }

        var result = {};
        queryExecute(
            "INSERT INTO branches ( name, address, phone, image_url )
             VALUES ( :name, :address, :phone, :image_url )",
            params,
            { result : "result" }
        );
        return result.generatedKey;
    }

    /**
     * Deletes one branch. Its events and students are kept; their branch
     * becomes empty (the foreign keys use ON DELETE SET NULL).
     */
    public void function delete( required numeric id ) {
        queryExecute(
            "DELETE FROM branches WHERE id = :id",
            { id : { value : arguments.id, cfsqltype : "cf_sql_integer" } }
        );
    }

    public string function getImageColumn() {
        return "image_url";
    }

}
