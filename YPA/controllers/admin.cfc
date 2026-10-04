/**
 * controllers/admin.cfc
 * ---------------------
 * The admin area (section "admin"). Every action except the login page
 * needs the admin to be logged in.
 *
 *   admin.login       GET   login form           (/admin redirects here)
 *   admin.doLogin     POST  check username/password
 *   admin.logout      POST  log out
 *   admin.default     GET   dashboard
 *   admin.poster      GET   poster form (image + tagline)
 *   admin.savePoster  POST  save the poster
 *   admin.list        GET   list of one type,   e.g. ?type=professors
 *   admin.edit        GET   add/edit form,      e.g. ?type=professors&id=3
 *   admin.save        POST  insert or update
 *   admin.delete      POST  delete
 *
 * "type" is one of: professors, branches, achievers, events, students.
 * Each type has its own list view (views/admin/<type>_list.cfm) and its own
 * form (views/admin/<type>_form.cfm). The saving logic is shared because
 * every service has the same methods.
 */
component accessors=true {

    property authService;
    property imageService;
    property settingService;
    property professorService;
    property branchService;
    property achieverService;
    property eventService;
    property studentService;

    // Actions that change something: they only accept POST requests.
    variables.postOnly = "doLogin,logout,savePoster,save,delete";
    // Actions anyone may open without being logged in.
    variables.publicItems = "login,doLogin";

    public any function init( required any fw ) {
        variables.fw = arguments.fw;
        return this;
    }

    /**
     * Runs before every admin action: checks the request method, the CSRF
     * token, the login and the "type" parameter.
     */
    public void function before( struct rc ) {
        var item = variables.fw.getItem();

        // 1. Changing actions must come from a form POST.
        if ( listFindNoCase( variables.postOnly, item ) && cgi.request_method != "POST" ) {
            variables.fw.redirect( "admin.default" );
        }

        // 2. Every POST must carry the CSRF token from our own form.
        if ( cgi.request_method == "POST" && !csrfVerifyToken( arguments.rc.csrfToken ?: "", "ypaAdmin" ) ) {
            arguments.rc.alert = "Your session expired. Please try again.";
            variables.fw.redirect( action = isLoggedIn() ? "admin.default" : "admin.login", preserve = "alert" );
        }

        // 3. Everything except the login page needs a logged-in admin.
        if ( !listFindNoCase( variables.publicItems, item ) && !isLoggedIn() ) {
            variables.fw.redirect( "admin.login" );
        }

        // 4. list/edit/save/delete need a known type, e.g. "professors".
        if ( listFindNoCase( "list,edit,save,delete", item ) ) {
            arguments.rc.type = lCase( arguments.rc.type ?: "" );
            if ( !structKeyExists( getTypes(), arguments.rc.type ) ) {
                variables.fw.redirect( "admin.default" );
            }
            arguments.rc.typeInfo = getTypes()[ arguments.rc.type ];
        }

        // Where to go after saving: a public section ("professors", "home"...)
        // when the admin came from a pencil icon on the site. Only known
        // names are allowed, so this can't redirect to another website.
        arguments.rc.returnTo = listFindNoCase( "home,professors,branches,achievers,events,students", arguments.rc.returnTo ?: "" )
            ? lCase( arguments.rc.returnTo ) : "";
    }

    // ---- Login / logout ---------------------------------------------------

    public void function login( struct rc ) {
        if ( isLoggedIn() ) {
            variables.fw.redirect( "admin.default" );
        }
        arguments.rc.pageTitle = "Admin login";
    }

    public void function doLogin( struct rc ) {
        var ip = cgi.remote_addr;
        arguments.rc.pageTitle = "Admin login";
        arguments.rc.username = trim( arguments.rc.username ?: "" );
        variables.fw.setView( "admin.login" );   // shown again if the login fails

        if ( variables.authService.isLockedOut( ip ) ) {
            arguments.rc.errors = [ "Too many wrong attempts. Please wait 15 minutes and try again." ];
            return;
        }

        if ( !variables.authService.checkLogin( arguments.rc.username, arguments.rc.password ?: "" ) ) {
            variables.authService.recordFailure( ip );
            arguments.rc.errors = [ "Wrong username or password." ];
            return;
        }

        variables.authService.clearFailures( ip );
        sessionRotate();                 // new session id after login (stops session fixation)
        session.isAdmin = true;
        session.adminUser = arguments.rc.username;
        variables.fw.redirect( "admin.default" );
    }

    public void function logout( struct rc ) {
        structDelete( session, "isAdmin" );
        structDelete( session, "adminUser" );
        sessionInvalidate();
        variables.fw.redirect( action = "admin.login", queryString = "loggedout=1" );
    }

    // ---- Dashboard -------------------------------------------------------

    public void function default( struct rc ) {
        arguments.rc.pageTitle = "Dashboard";
        arguments.rc.counts = {};
        for ( var type in getTypes() ) {
            arguments.rc.counts[ type ] = getTypes()[ type ].service.list().len();
        }
    }

    // ---- Poster ----------------------------------------------------------

    public void function poster( struct rc ) {
        arguments.rc.pageTitle = "Poster";
        arguments.rc.posterImage = variables.settingService.get( "poster_image" );
        arguments.rc.tagline = variables.settingService.get( "poster_tagline", application.siteInfo.tagline );
    }

    public void function savePoster( struct rc ) {
        var oldImage = variables.settingService.get( "poster_image" );
        var newImage = "";
        arguments.rc.tagline = trim( arguments.rc.tagline ?: "" );

        var errors = [];
        if ( len( arguments.rc.tagline ) > 200 ) {
            errors.append( "The tagline must be 200 characters or fewer." );
        }
        if ( !errors.len() ) {
            try {
                newImage = variables.imageService.saveUpload( "posterImage", "poster" );
            } catch ( ImageService.Invalid e ) {
                errors.append( e.message );
            }
        }
        if ( errors.len() ) {
            arguments.rc.errors = errors;
            arguments.rc.pageTitle = "Poster";
            arguments.rc.posterImage = oldImage;
            variables.fw.setView( "admin.poster" );
            return;
        }

        variables.settingService.set( "poster_tagline", arguments.rc.tagline );
        if ( len( newImage ) ) {
            variables.settingService.set( "poster_image", newImage );
            variables.imageService.deleteImage( oldImage );
        } else if ( structKeyExists( arguments.rc, "removeImage" ) ) {
            variables.settingService.set( "poster_image", "" );
            variables.imageService.deleteImage( oldImage );
        }

        arguments.rc.message = "The poster was saved.";
        finish( arguments.rc, "admin.default" );
    }

    // ---- Professors, branches, achievers, events, students ----------------

    /** List page for one type. */
    public void function list( struct rc ) {
        arguments.rc.pageTitle = arguments.rc.typeInfo.plural;
        arguments.rc.items = arguments.rc.typeInfo.service.list();
        variables.fw.setView( "admin.#arguments.rc.type#_list" );
    }

    /** Add form (no id) or edit form (with id). */
    public void function edit( struct rc ) {
        var service = arguments.rc.typeInfo.service;
        var id = val( arguments.rc.id ?: 0 );

        arguments.rc.item = id ? service.get( id ) : service.newItem();
        if ( structIsEmpty( arguments.rc.item ) ) {
            arguments.rc.alert = "That #lCase( arguments.rc.typeInfo.singular )# no longer exists.";
            variables.fw.redirect( action = "admin.list", preserve = "alert", queryString = "type=#arguments.rc.type#" );
        }
        showForm( arguments.rc );
    }

    /** Saves the add/edit form, including the optional image upload. */
    public void function save( struct rc ) {
        var service = arguments.rc.typeInfo.service;
        var imageColumn = service.getImageColumn();
        var data = service.fromForm( arguments.rc );
        var errors = service.validate( data );

        // When editing, start from the image already saved.
        var existing = {};
        if ( data.id > 0 ) {
            existing = service.get( data.id );
            if ( structIsEmpty( existing ) ) {
                arguments.rc.alert = "That #lCase( arguments.rc.typeInfo.singular )# no longer exists.";
                variables.fw.redirect( action = "admin.list", preserve = "alert", queryString = "type=#arguments.rc.type#" );
            }
        }
        var oldImage = existing[ imageColumn ] ?: "";
        data[ imageColumn ] = oldImage;

        // Only upload once the text fields are valid, so we don't keep
        // images for records that never get saved.
        var newImage = "";
        if ( !errors.len() ) {
            try {
                newImage = variables.imageService.saveUpload( "image", arguments.rc.typeInfo.folder );
            } catch ( ImageService.Invalid e ) {
                errors.append( e.message );
            }
        }

        if ( errors.len() ) {
            arguments.rc.errors = errors;
            arguments.rc.item = data;   // show the form again with what was typed
            showForm( arguments.rc );
            return;
        }

        if ( len( newImage ) ) {
            data[ imageColumn ] = newImage;
        } else if ( structKeyExists( arguments.rc, "removeImage" ) ) {
            data[ imageColumn ] = "";
        }

        service.save( data );

        // Delete the old file only after the database was updated.
        if ( len( oldImage ) && oldImage != data[ imageColumn ] ) {
            variables.imageService.deleteImage( oldImage );
        }

        arguments.rc.message = "#arguments.rc.typeInfo.singular# #( data.id ? 'updated' : 'added' )#.";
        finish( arguments.rc, "admin.list", "type=#arguments.rc.type#" );
    }

    /** Deletes a record and its image. */
    public void function delete( struct rc ) {
        var service = arguments.rc.typeInfo.service;
        var item = service.get( val( arguments.rc.id ?: 0 ) );

        if ( !structIsEmpty( item ) ) {
            service.delete( item.id );
            variables.imageService.deleteImage( item[ service.getImageColumn() ] ?: "" );
            arguments.rc.message = "#arguments.rc.typeInfo.singular# deleted.";
        }
        variables.fw.redirect( action = "admin.list", preserve = "message", queryString = "type=#arguments.rc.type#" );
    }

    // ---- Helpers ---------------------------------------------------------

    private boolean function isLoggedIn() {
        return structKeyExists( session, "isAdmin" ) && session.isAdmin;
    }

    /**
     * Everything the shared actions need to know about each type.
     *   service  : the injected service
     *   folder   : upload folder under assets/uploads/
     */
    private struct function getTypes() {
        return [
            professors : { service : variables.professorService, singular : "Professor", plural : "Professors", folder : "professors" },
            branches   : { service : variables.branchService,    singular : "Branch",    plural : "Branches",   folder : "branches" },
            achievers  : { service : variables.achieverService,  singular : "Achiever",  plural : "Achievers",  folder : "achievers" },
            events     : { service : variables.eventService,     singular : "Event",     plural : "Events",     folder : "events" },
            students   : { service : variables.studentService,   singular : "Student",   plural : "Students",   folder : "students" }
        ];
    }

    /** Shows views/admin/<type>_form.cfm, with the branch list where needed. */
    private void function showForm( required struct rc ) {
        arguments.rc.pageTitle = ( arguments.rc.item.id ? "Edit " : "Add " ) & lCase( arguments.rc.typeInfo.singular );
        if ( listFind( "events,students", arguments.rc.type ) ) {
            arguments.rc.branches = variables.branchService.list();   // for the branch drop-down
        }
        variables.fw.setView( "admin.#arguments.rc.type#_form" );
    }

    /**
     * After a successful save: back to the public section the admin came
     * from (pencil icon), otherwise to the admin page given.
     */
    private void function finish( required struct rc, required string action, string queryString = "" ) {
        if ( len( arguments.rc.returnTo ) ) {
            // e.g. "/index.cfm#professors" - the single-page site opens that section.
            location( url = getDirectoryFromPath( cgi.script_name ) & "index.cfm##" & arguments.rc.returnTo, addToken = false );
        }
        variables.fw.redirect( action = arguments.action, preserve = "message", queryString = arguments.queryString );
    }

}
