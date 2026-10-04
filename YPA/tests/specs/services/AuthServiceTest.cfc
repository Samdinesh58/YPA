/**
 * Unit test: no database needed.
 * Login failures are stored in application.loginFailures, so each test
 * uses its own made-up IP address.
 */
component extends="testbox.system.BaseSpec" {

    function beforeAll() {
        variables.service = new model.services.AuthService();
    }

    function run() {
        describe( "AuthService.checkLogin()", function() {

            it( "accepts the correct username and password", function() {
                expect( variables.service.checkLogin( "samdinesh", "Sdinesh58@" ) ).toBeTrue();
            } );

            it( "rejects a wrong password", function() {
                expect( variables.service.checkLogin( "samdinesh", "wrong" ) ).toBeFalse();
            } );

            it( "rejects a wrong username, and the username is case-sensitive", function() {
                expect( variables.service.checkLogin( "someone", "Sdinesh58@" ) ).toBeFalse();
                expect( variables.service.checkLogin( "SamDinesh", "Sdinesh58@" ) ).toBeFalse();
            } );

        } );

        describe( "AuthService lockout", function() {

            it( "locks an IP after 5 failures and unlocks it after clearFailures()", function() {
                var ip = "test-" & createUUID();
                for ( var i = 1; i <= 4; i++ ) {
                    variables.service.recordFailure( ip );
                }
                expect( variables.service.isLockedOut( ip ) ).toBeFalse();

                variables.service.recordFailure( ip );
                expect( variables.service.isLockedOut( ip ) ).toBeTrue();

                variables.service.clearFailures( ip );
                expect( variables.service.isLockedOut( ip ) ).toBeFalse();
            } );

        } );
    }

}
