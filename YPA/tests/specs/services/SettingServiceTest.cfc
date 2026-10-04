/**
 * Integration test: needs db/migrations/001_admin_images_and_settings.sql loaded.
 */
component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.service = new model.services.SettingService();
        variables.key = "test_setting_" & left( replace( createUUID(), "-", "", "all" ), 20 );
    }

    function afterAll() {
        queryExecute(
            "DELETE FROM site_settings WHERE setting_key = :key",
            { key : { value : variables.key, cfsqltype : "cf_sql_varchar" } }
        );
    }

    function run() {
        describe( "SettingService", function() {

            it( "returns the default for a setting that isn't set", function() {
                expect( variables.service.get( variables.key, "fallback" ) ).toBe( "fallback" );
            } );

            it( "creates and then updates a setting", function() {
                variables.service.set( variables.key, "first" );
                expect( variables.service.get( variables.key ) ).toBe( "first" );
                variables.service.set( variables.key, "second" );
                expect( variables.service.get( variables.key ) ).toBe( "second" );
            } );

        } );
    }

}
