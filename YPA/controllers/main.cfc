/**
 * controllers/main.cfc
 * --------------------
 * The "main" section. Renders the single page shell
 * (layouts/default.cfm + views/main/default.cfm). The lists are fetched
 * later by assets/js/app.js from the "api" section.
 */
component accessors=true {

    property settingService;

    /** FW/1 passes itself in when it creates the controller. */
    public any function init( required any fw ) {
        variables.fw = arguments.fw;
        return this;
    }

    /**
     * action=main.default: loads the poster image and tagline set in the
     * admin area. If the database can't be reached, the page still shows
     * with the default tagline and no poster image.
     */
    public void function default( struct rc ) {
        arguments.rc.posterImage = "";
        arguments.rc.tagline = application.siteInfo.tagline;
        try {
            arguments.rc.posterImage = variables.settingService.get( "poster_image" );
            arguments.rc.tagline = variables.settingService.get( "poster_tagline", application.siteInfo.tagline );
        } catch ( any e ) {
            writeLog( type = "error", file = "ypa", text = "Could not load poster settings: #e.message#" );
        }
    }

}
