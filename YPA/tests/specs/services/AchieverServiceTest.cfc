/**
 * Integration test: needs the ypa_academy database with db/schema.sql loaded.
 */
component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.service = new model.services.AchieverService();
    }

    function run() {
        describe( "AchieverService.list()", function() {

            it( "returns an array of structs with exam, rank and year", function() {
                var rows = variables.service.list();
                expect( rows ).toBeArray();
                expect( rows ).notToBeEmpty();
                for ( var key in [ "id", "name", "exam", "rank_or_post", "year", "photo_url" ] ) {
                    expect( rows[ 1 ] ).toHaveKey( key );
                }
            } );

            it( "returns the most recent year first", function() {
                var rows = variables.service.list();
                for ( var i = 2; i <= rows.len(); i++ ) {
                    expect( rows[ i ].year ).toBeLTE( rows[ i - 1 ].year );
                }
            } );

        } );

        describe( "AchieverService.validate()", function() {

            it( "requires name, exam and rank/post", function() {
                var data = variables.service.newItem();
                expect( variables.service.validate( data ) ).toHaveLength( 3 );
            } );

            it( "rejects an impossible year", function() {
                var data = validData();
                data.year = "1800";
                expect( variables.service.validate( data ) ).toHaveLength( 1 );
            } );

        } );

        describe( "AchieverService save/get/delete", function() {

            it( "adds, updates and deletes an achiever", function() {
                var data = validData();
                var id = variables.service.save( data );
                try {
                    expect( variables.service.get( id ).name ).toBe( data.name );
                    data.id = id;
                    data.rank_or_post = "State Rank 1";
                    variables.service.save( data );
                    expect( variables.service.get( id ).rank_or_post ).toBe( "State Rank 1" );
                } finally {
                    variables.service.delete( id );
                }
                expect( variables.service.get( id ) ).toBeEmpty();
            } );

        } );
    }

    private struct function validData() {
        var data = variables.service.newItem();
        data.name = "Test Achiever #createUUID()#";
        data.exam = "Test Exam";
        data.rank_or_post = "Rank 10";
        data.year = "2025";
        return data;
    }

}
