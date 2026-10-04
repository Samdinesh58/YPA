/**
 * Integration test: needs the ypa_academy database with db/schema.sql and
 * db/migrations/001_admin_images_and_settings.sql loaded.
 */
component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.service = new model.services.BranchService();
    }

    function run() {
        describe( "BranchService.list()", function() {

            it( "returns an array of structs with name, address, phone and image", function() {
                var rows = variables.service.list();
                expect( rows ).toBeArray();
                expect( rows ).notToBeEmpty();
                for ( var key in [ "id", "name", "address", "phone", "image_url" ] ) {
                    expect( rows[ 1 ] ).toHaveKey( key );
                }
            } );

        } );

        describe( "BranchService.validate()", function() {

            it( "requires name and address", function() {
                var data = variables.service.newItem();
                expect( variables.service.validate( data ) ).toHaveLength( 2 );
            } );

            it( "rejects letters in the phone number", function() {
                var data = validData();
                data.phone = "call me";
                expect( variables.service.validate( data ) ).toHaveLength( 1 );
            } );

        } );

        describe( "BranchService save/get/delete", function() {

            it( "adds, updates and deletes a branch", function() {
                var data = validData();
                var id = variables.service.save( data );
                try {
                    expect( variables.service.get( id ).name ).toBe( data.name );
                    data.id = id;
                    data.address = "New address";
                    variables.service.save( data );
                    expect( variables.service.get( id ).address ).toBe( "New address" );
                } finally {
                    variables.service.delete( id );
                }
                expect( variables.service.get( id ) ).toBeEmpty();
            } );

        } );
    }

    private struct function validData() {
        var data = variables.service.newItem();
        data.name = "Test Branch #createUUID()#";
        data.address = "1 Test Street";
        data.phone = "+91 90000 00000";
        return data;
    }

}
