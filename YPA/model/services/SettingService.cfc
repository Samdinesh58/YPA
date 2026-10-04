/**
 * model/services/SettingService.cfc
 * ---------------------------------
 * Reads and writes site-wide settings in the site_settings table
 * (e.g. poster_image, poster_tagline).
 */
component {

    /** Returns the setting's value, or defaultValue if it isn't set. */
    public string function get( required string key, string defaultValue = "" ) {
        var rows = queryExecute(
            "SELECT setting_value FROM site_settings WHERE setting_key = :key",
            { key : { value : arguments.key, cfsqltype : "cf_sql_varchar" } },
            { returntype : "array" }
        );
        if ( !rows.len() || isNull( rows[ 1 ].setting_value ) ) {
            return arguments.defaultValue;
        }
        return rows[ 1 ].setting_value;
    }

    /** Creates or updates a setting. */
    public void function set( required string key, required string value ) {
        queryExecute(
            "INSERT INTO site_settings ( setting_key, setting_value )
             VALUES ( :key, :value )
             ON DUPLICATE KEY UPDATE setting_value = VALUES( setting_value )",
            {
                key   : { value : arguments.key,   cfsqltype : "cf_sql_varchar" },
                value : { value : arguments.value, cfsqltype : "cf_sql_varchar" }
            }
        );
    }

}
