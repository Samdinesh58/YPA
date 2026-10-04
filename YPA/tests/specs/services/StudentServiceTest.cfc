/**
 * Integration test: needs the ypa_academy database with db/schema.sql and
 * db/migrations/001_admin_images_and_settings.sql loaded.
 */
component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.service = new model.services.StudentService();
    }

    function run() {
        describe( "StudentService.list()", function() {

            it( "returns an array of structs with batch, branch name and photo", function() {
                var rows = variables.service.list();
                expect( rows ).toBeArray();
                expect( rows ).notToBeEmpty();
                for ( var key in [ "id", "name", "batch", "branch_name", "photo_url" ] ) {
                    expect( rows[ 1 ] ).toHaveKey( key );
                }
            } );

        } );

        describe( "StudentService.validate()", function() {

            it( "requires name and batch", function() {
                var data = variables.service.newItem();
                expect( variables.service.validate( data ) ).toHaveLength( 2 );
            } );

        } );

        describe( "StudentService save/get/delete", function() {

            it( "adds, updates and deletes a student without a branch", function() {
                var data = variables.service.newItem();
                data.name = "Test Student #createUUID()#";
                data.batch = "Test Batch";
                data.branch_id = 0;

                var id = variables.service.save( data );
                try {
                    expect( variables.service.get( id ).name ).toBe( data.name );
                    data.id = id;
                    data.batch = "Updated Batch";
                    variables.service.save( data );
                    expect( variables.service.get( id ).batch ).toBe( "Updated Batch" );
                } finally {
                    variables.service.delete( id );
                }
                expect( variables.service.get( id ) ).toBeEmpty();
            } );

        } );
    }

}
