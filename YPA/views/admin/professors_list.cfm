<!--- views/admin/professors_list.cfm - all professors with Edit / Delete --->
<cfoutput>
<div class="admin-heading">
    <h1 class="admin-title">Professors</h1>
    <a class="btn btn-dark" href="#buildURL( 'admin.edit?type=professors' )#">+ Add professor</a>
</div>
<cfinclude template="_messages.cfm">

<cfif !arrayLen( rc.items )>
    <p class="status-message">No professors yet. Use "Add professor" to create the first one.</p>
<cfelse>
    <div class="table-responsive admin-card p-0">
        <table class="table align-middle mb-0">
            <thead>
                <tr><th scope="col">Photo</th><th scope="col">Name</th><th scope="col">Subject</th><th scope="col">Order</th><th scope="col"><span class="visually-hidden">Actions</span></th></tr>
            </thead>
            <tbody>
            <cfloop array="#rc.items#" item="local.row">
                <tr>
                    <td>
                        <cfif len( local.row.photo_url )>
                            <img class="admin-thumb" src="#encodeForHTMLAttribute( rc.basePath & local.row.photo_url )#" alt="">
                        <cfelse>
                            <span class="admin-thumb admin-thumb--empty"><span class="visually-hidden">No photo</span></span>
                        </cfif>
                    </td>
                    <td class="fw-semibold">#encodeForHTML( local.row.name )#</td>
                    <td>
                        <!--- Only a real #RRGGBB value goes into the style; anything else falls back to slate --->
                        <cfset local.swatch = reFind( "^##[0-9A-Fa-f]{6}$", local.row.accent_color ) ? local.row.accent_color : "##34495E">
                        <span class="admin-swatch" style="background: #local.swatch#" aria-hidden="true"></span>
                        #encodeForHTML( local.row.subject )#
                    </td>
                    <td>#encodeForHTML( local.row.display_order )#</td>
                    <td class="text-end text-nowrap">
                        <a class="btn btn-sm btn-outline-dark" href="#buildURL( 'admin.edit?type=professors&id=' & local.row.id )#"
                           aria-label="Edit #encodeForHTMLAttribute( local.row.name )#">Edit</a>
                        <form method="post" action="#buildURL( 'admin.delete' )#" class="d-inline"
                              data-confirm="Delete #encodeForHTMLAttribute( local.row.name )#? This cannot be undone.">
                            <input type="hidden" name="csrfToken" value="#encodeForHTMLAttribute( rc.csrfToken )#">
                            <input type="hidden" name="type" value="professors">
                            <input type="hidden" name="id" value="#local.row.id#">
                            <button type="submit" class="btn btn-sm btn-outline-danger"
                                    aria-label="Delete #encodeForHTMLAttribute( local.row.name )#">Delete</button>
                        </form>
                    </td>
                </tr>
            </cfloop>
            </tbody>
        </table>
    </div>
</cfif>
</cfoutput>
