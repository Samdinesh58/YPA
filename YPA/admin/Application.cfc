/**
 * admin/Application.cfc
 * ---------------------
 * This folder exists only so that typing /admin in the browser works.
 * Its own tiny Application.cfc stops FW/1 from handling this one file;
 * admin/index.cfm then sends the visitor to the real admin login action.
 */
component {
    this.name = "YPA_Academy_AdminRedirect";
    this.sessionManagement = false;
}
