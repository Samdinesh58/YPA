/**
 * Integration test: needs the ypa_academy database with db/schema.sql and
 * db/migrations/001_admin_images_and_settings.sql loaded.
 */
component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.service = new model.services.EventService();
    }

    function run() {
        describe( "EventService.list()", function() {

            it( "returns an array of structs including the branch name and image", function() {
                var rows = variables.service.list();
                expect( rows ).toBeArray();
                expect( rows ).notToBeEmpty();
                for ( var key in [ "id", "title", "event_date", "description", "branch_name", "image_url" ] ) {
                    expect( rows[ 1 ] ).toHaveKey( key );
                }
            } );

            it( "formats event_date as YYYY-MM-DD text", function() {
                var rows = variables.service.list();
                expect( rows[ 1 ].event_date ).toMatch( "^\d{4}-\d{2}-\d{2}$" );
            } );

        } );

        describe( "EventService.validate()", function() {

            it( "requires a title and a date", function() {
                var data = variables.service.newItem();
                expect( variables.service.validate( data ) ).toHaveLength( 2 );
            } );

            it( "rejects a date that doesn't exist", function() {
                var data = validData();
                data.event_date = "2026-02-30";
                expect( variables.service.validate( data ) ).toHaveLength( 1 );
            } );

        } );

        describe( "EventService save/get/delete", function() {

            it( "adds, updates and deletes an event for all branches", function() {
                var data = validData();
                var id = variables.service.save( data );
                try {
                    var saved = variables.service.get( id );
                    expect( saved.title ).toBe( data.title );
                    expect( saved.event_date ).toBe( "2026-12-05" );

                    data.id = id;
                    data.event_date = "2026-12-06";
                    variables.service.save( data );
                    expect( variables.service.get( id ).event_date ).toBe( "2026-12-06" );
                } finally {
                    variables.service.delete( id );
                }
                expect( variables.service.get( id ) ).toBeEmpty();
            } );

        } );
    }

    private struct function validData() {
        var data = variables.service.newItem();
        data.title = "Test Event #createUUID()#";
        data.event_date = "2026-12-05";
        data.branch_id = 0;
        return data;
    }

}
