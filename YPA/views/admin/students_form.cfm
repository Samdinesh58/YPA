<!---
    views/admin/students_form.cfm - add or edit a student.
    rc.item holds the values (empty for "Add"); rc.branches fills the
    branch drop-down. Posts to admin.save.
--->
<cfset local.item = rc.item>
<cfoutput>
<h1 class="admin-title">#encodeForHTML( rc.pageTitle )#</h1>
<cfinclude template="_messages.cfm">

<form method="post" action="#buildURL( 'admin.save' )#" enctype="multipart/form-data" class="admin-card admin-form">
    <input type="hidden" name="csrfToken" value="#encodeForHTMLAttribute( rc.csrfToken )#">
    <input type="hidden" name="type" value="students">
    <input type="hidden" name="id" value="#val( local.item.id )#">
    <input type="hidden" name="returnTo" value="#encodeForHTMLAttribute( rc.returnTo )#">

    <div class="row g-3 mb-4">
        <div class="col-md-6">
            <label class="form-label fw-semibold" for="name">Name *</label>
            <input class="form-control" type="text" id="name" name="name" maxlength="120" required
                   value="#encodeForHTMLAttribute( local.item.name )#">
        </div>
        <div class="col-md-6">
            <label class="form-label fw-semibold" for="batch">Batch *</label>
            <input class="form-control" type="text" id="batch" name="batch" maxlength="80" required
                   value="#encodeForHTMLAttribute( local.item.batch )#" placeholder="e.g. Group 1 - Morning 2026">
        </div>
        <div class="col-md-6">
            <label class="form-label fw-semibold" for="branch_id">Branch</label>
            <select class="form-select" id="branch_id" name="branch_id">
                <option value="0">No branch</option>
                <cfloop array="#rc.branches#" item="local.branch">
                    <option value="#local.branch.id#"<cfif val( local.item.branch_id ) == local.branch.id> selected</cfif>>#encodeForHTML( local.branch.name )#</option>
                </cfloop>
            </select>
        </div>
    </div>

    <cfset local.imagePath = local.item.photo_url>
    <cfset local.imageLabel = "Photo">
    <cfinclude template="_imagefield.cfm">

    <button type="submit" class="btn btn-dark">Save student</button>
    <a class="btn btn-link" href="#len( rc.returnTo ) ? rc.basePath & 'index.cfm##' & rc.returnTo : buildURL( 'admin.list?type=students' )#">Cancel</a>
</form>
</cfoutput>
