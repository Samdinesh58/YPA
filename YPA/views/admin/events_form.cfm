<!---
    views/admin/events_form.cfm - add or edit an event.
    rc.item holds the values (empty for "Add"); rc.branches fills the
    branch drop-down. Posts to admin.save.
--->
<cfset local.item = rc.item>
<cfoutput>
<h1 class="admin-title">#encodeForHTML( rc.pageTitle )#</h1>
<cfinclude template="_messages.cfm">

<form method="post" action="#buildURL( 'admin.save' )#" enctype="multipart/form-data" class="admin-card admin-form">
    <input type="hidden" name="csrfToken" value="#encodeForHTMLAttribute( rc.csrfToken )#">
    <input type="hidden" name="type" value="events">
    <input type="hidden" name="id" value="#val( local.item.id )#">
    <input type="hidden" name="returnTo" value="#encodeForHTMLAttribute( rc.returnTo )#">

    <div class="row g-3 mb-4">
        <div class="col-md-8">
            <label class="form-label fw-semibold" for="title">Title *</label>
            <input class="form-control" type="text" id="title" name="title" maxlength="160" required
                   value="#encodeForHTMLAttribute( local.item.title )#">
        </div>
        <div class="col-md-4">
            <label class="form-label fw-semibold" for="event_date">Date *</label>
            <input class="form-control" type="date" id="event_date" name="event_date" required
                   value="#encodeForHTMLAttribute( local.item.event_date )#">
        </div>
        <div class="col-md-6">
            <label class="form-label fw-semibold" for="branch_id">Branch</label>
            <select class="form-select" id="branch_id" name="branch_id">
                <option value="0">All branches</option>
                <cfloop array="#rc.branches#" item="local.branch">
                    <option value="#local.branch.id#"<cfif val( local.item.branch_id ) == local.branch.id> selected</cfif>>#encodeForHTML( local.branch.name )#</option>
                </cfloop>
            </select>
        </div>
        <div class="col-12">
            <label class="form-label fw-semibold" for="description">Description</label>
            <textarea class="form-control" id="description" name="description" rows="4">#encodeForHTML( local.item.description )#</textarea>
        </div>
    </div>

    <cfset local.imagePath = local.item.image_url>
    <cfset local.imageLabel = "Image">
    <cfinclude template="_imagefield.cfm">

    <button type="submit" class="btn btn-dark">Save event</button>
    <a class="btn btn-link" href="#len( rc.returnTo ) ? rc.basePath & 'index.cfm##' & rc.returnTo : buildURL( 'admin.list?type=events' )#">Cancel</a>
</form>
</cfoutput>
