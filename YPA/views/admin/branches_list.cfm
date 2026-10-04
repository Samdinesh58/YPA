<!--- views/admin/branches_list.cfm - all branches with Edit / Delete --->
<cfoutput>
<div class="admin-heading">
    <h1 class="admin-title">Branches</h1>
    <a class="btn btn-dark" href="#buildURL( 'admin.edit?type=branches' )#">+ Add branch</a>
</div>
<cfinclude template="_messages.cfm">

<cfif !arrayLen( rc.items )>
    <p class="status-message">No branches yet. Use "Add branch" to create the first one.</p>
<cfelse>
    <div class="table-responsive admin-card p-0">
        <table class="table align-middle mb-0">
            <thead>
                <tr><th scope="col">Image</th><th scope="col">Name</th><th scope="col">Address</th><th scope="col">Phone</th><th scope="col"><span class="visually-hidden">Actions</span></th></tr>
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
                    <td class="fw-semibold">#encodeForHTML( local.row.name )#</td>
                    <td>#encodeForHTML( local.row.address )#</td>
                    <td class="text-nowrap">#encodeForHTML( local.row.phone )#</td>
                    <td class="text-end text-nowrap">
                        <a class="btn btn-sm btn-outline-dark" href="#buildURL( 'admin.edit?type=branches&id=' & local.row.id )#"
                           aria-label="Edit #encodeForHTMLAttribute( local.row.name )#">Edit</a>
                        <form method="post" action="#buildURL( 'admin.delete' )#" class="d-inline"
                              data-confirm="Delete #encodeForHTMLAttribute( local.row.name )#? Its events and students will be kept but will no longer have a branch.">
                            <input type="hidden" name="csrfToken" value="#encodeForHTMLAttribute( rc.csrfToken )#">
                            <input type="hidden" name="type" value="branches">
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
