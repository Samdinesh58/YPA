/**
 * Integration test: needs the ypa_academy database with db/schema.sql and
 * db/migrations/001_admin_images_and_settings.sql loaded.
 */
component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.service = new model.services.ProfessorService();
    }

    function run() {
        describe( "ProfessorService.list()", function() {

            it( "returns an array of structs with the columns the page needs", function() {
                var rows = variables.service.list();
                expect( rows ).toBeArray();
                expect( rows ).notToBeEmpty();
                for ( var key in [ "id", "name", "subject", "qualification", "experience_years", "bio", "photo_url", "accent_color" ] ) {
                    expect( rows[ 1 ] ).toHaveKey( key );
                }
            } );

            it( "returns professors in display order", function() {
                var rows = variables.service.list();
                for ( var i = 2; i <= rows.len(); i++ ) {
                    expect( rows[ i ].display_order ).toBeGTE( rows[ i - 1 ].display_order );
                }
            } );

        } );

        describe( "ProfessorService.validate()", function() {

            it( "accepts a complete professor", function() {
                expect( variables.service.validate( validData() ) ).toBeEmpty();
            } );

            it( "requires name and subject", function() {
                var data = validData();
                data.name = "";
                data.subject = "";
                expect( variables.service.validate( data ) ).toHaveLength( 2 );
            } );

            it( "rejects a bad accent colour and out-of-range experience", function() {
                var data = validData();
                data.accent_color = "red; background:url(x)";
                data.experience_years = "99";
                expect( variables.service.validate( data ) ).toHaveLength( 2 );
            } );

        } );

        describe( "ProfessorService save/get/delete", function() {

            it( "adds, updates and deletes a professor", function() {
                var data = validData();
                var id = variables.service.save( data );
                expect( id ).toBeGT( 0 );

                try {
                    expect( variables.service.get( id ).name ).toBe( data.name );

                    data.id = id;
                    data.subject = "Updated subject";
                    variables.service.save( data );
                    expect( variables.service.get( id ).subject ).toBe( "Updated subject" );
                } finally {
                    variables.service.delete( id );
                }
                expect( variables.service.get( id ) ).toBeEmpty();
            } );

        } );
    }

    private struct function validData() {
        var data = variables.service.newItem();
        data.name = "Test Professor #createUUID()#";
        data.subject = "Testing";
        data.experience_years = "5";
        data.display_order = "99";
        data.accent_color = "##1E7B3C";
        return data;
    }

}
