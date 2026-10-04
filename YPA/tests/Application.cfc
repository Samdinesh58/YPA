/**
 * tests/Application.cfc
 * ---------------------
 * Settings for the TestBox runner. Uses the same "ypa" datasource as the
 * site, so the service tests read the real development database
 * (load db/schema.sql first).
 */
component {

    this.name = "YPA_Academy_Tests_" & hash( getCurrentTemplatePath() );

    variables.rootPath = getDirectoryFromPath( getCurrentTemplatePath() ) & "../";
    this.mappings[ "/model" ]   = variables.rootPath & "model";
    this.mappings[ "/testbox" ] = variables.rootPath & "testbox";

    // Same datasource definition as the site's Application.cfc.
    this.datasources[ "ypa" ] = {
        class            : "com.mysql.cj.jdbc.Driver",
        bundleName       : "com.mysql.cj",
        connectionString : "jdbc:mysql://"
                         & getEnvSetting( "DB_HOST", "127.0.0.1" ) & ":"
                         & getEnvSetting( "DB_PORT", "3306" ) & "/"
                         & getEnvSetting( "DB_NAME", "ypa_academy" )
                         & "?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC&useSSL=false&allowPublicKeyRetrieval=true",
        username         : getEnvSetting( "DB_USER", "root" ),
        password         : getEnvSetting( "DB_PASSWORD", "" )
    };
    this.datasource = "ypa";

    private string function getEnvSetting( required string name, string defaultValue = "" ) {
        if ( structKeyExists( server.system.environment, arguments.name ) ) {
            return server.system.environment[ arguments.name ];
        }
        if ( structKeyExists( server.system.properties, arguments.name ) ) {
            return server.system.properties[ arguments.name ];
        }
        return arguments.defaultValue;
    }

}
