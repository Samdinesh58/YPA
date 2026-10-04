<!--- views/admin/events_list.cfm - all events with Edit / Delete --->
<cfoutput>
<div class="admin-heading">
    <h1 class="admin-title">Events</h1>
    <a class="btn btn-dark" href="#buildURL( 'admin.edit?type=events' )#">+ Add event</a>
</div>
<cfinclude template="_messages.cfm">

<cfif !arrayLen( rc.items )>
    <p class="status-message">No events yet. Use "Add event" to create the first one.</p>
<cfelse>
    <div class="table-responsive admin-card p-0">
        <table class="table align-middle mb-0">
            <thead>
                <tr><th scope="col">Image</th><th scope="col">Date</th><th scope="col">Title</th><th scope="col">Branch</th><th scope="col"><span class="visually-hidden">Actions</span></th></tr>
            </thead>
            <tbody>
            <cfloop array="#rc.items#" item="local.row">
                <tr>
                    <td>
                        <cfif len( local.row.image_url )>
                            <img class="admin-thumb" src="#encodeForHTMLAttribute( rc.basePath & local.row.image_url )#" alt="">
                        <cfelse>
                            <span class="admin-thumb admin-thumb--empty"><span class="visually-hidden">No image</span></span>
                        </cfif>
                    </td>
                    <td class="text-nowrap">#encodeForHTML( local.row.event_date )#</td>
                    <td class="fw-semibold">#encodeForHTML( local.row.title )#</td>
                    <td>#len( local.row.branch_name ) ? encodeForHTML( local.row.branch_name ) : "All branches"#</td>
                    <td class="text-end text-nowrap">
                        <a class="btn btn-sm btn-outline-dark" href="#buildURL( 'admin.edit?type=events&id=' & local.row.id )#"
                           aria-label="Edit #encodeForHTMLAttribute( local.row.title )#">Edit</a>
                        <form method="post" action="#buildURL( 'admin.delete' )#" class="d-inline"
                              data-confirm="Delete the event #encodeForHTMLAttribute( local.row.title )#? This cannot be undone.">
                            <input type="hidden" name="csrfToken" value="#encodeForHTMLAttribute( rc.csrfToken )#">
                            <input type="hidden" name="type" value="events">
                            <input type="hidden" name="id" value="#local.row.id#">
                            <button type="submit" class="btn btn-sm btn-outline-danger"
                                    aria-label="Delete #encodeForHTMLAttribute( local.row.title )#">Delete</button>
                        </form>
                    </td>
                </tr>
            </cfloop>
            </tbody>
        </table>
    </div>
</cfif>
</cfoutput>
