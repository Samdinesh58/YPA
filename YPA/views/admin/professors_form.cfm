<!---
    views/admin/professors_form.cfm - add or edit a professor.
    rc.item holds the values (empty for "Add"). Posts to admin.save.
--->
<cfset local.item = rc.item>
<cfset local.colours = [
    { value : "",        label : "Automatic (by position)" },
    { value : "##1E7B3C", label : "Green" },
    { value : "##0B6FA8", label : "Blue" },
    { value : "##C0392B", label : "Red" },
    { value : "##34495E", label : "Slate" }
]>
<cfoutput>
<h1 class="admin-title">#encodeForHTML( rc.pageTitle )#</h1>
<cfinclude template="_messages.cfm">

<form method="post" action="#buildURL( 'admin.save' )#" enctype="multipart/form-data" class="admin-card admin-form">
    <input type="hidden" name="csrfToken" value="#encodeForHTMLAttribute( rc.csrfToken )#">
    <input type="hidden" name="type" value="professors">
    <input type="hidden" name="id" value="#val( local.item.id )#">
    <input type="hidden" name="returnTo" value="#encodeForHTMLAttribute( rc.returnTo )#">

    <div class="row g-3 mb-4">
        <div class="col-md-6">
            <label class="form-label fw-semibold" for="name">Name *</label>
            <input class="form-control" type="text" id="name" name="name" maxlength="120" required
                   value="#encodeForHTMLAttribute( local.item.name )#">
        </div>
        <div class="col-md-6">
            <label class="form-label fw-semibold" for="subject">Subject *</label>
            <input class="form-control" type="text" id="subject" name="subject" maxlength="80" required
                   value="#encodeForHTMLAttribute( local.item.subject )#">
        </div>
        <div class="col-md-6">
            <label class="form-label fw-semibold" for="qualification">Qualification</label>
            <input class="form-control" type="text" id="qualification" name="qualification" maxlength="120"
                   value="#encodeForHTMLAttribute( local.item.qualification )#" placeholder="e.g. M.Sc. Mathematics">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold" for="experience_years">Years of experience</label>
            <input class="form-control" type="number" id="experience_years" name="experience_years" min="0" max="60"
                   value="#encodeForHTMLAttribute( local.item.experience_years )#">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold" for="display_order">Display order</label>
            <input class="form-control" type="number" id="display_order" name="display_order" aria-describedby="orderHelp"
                   value="#encodeForHTMLAttribute( local.item.display_order )#">
            <div id="orderHelp" class="form-text">Lower numbers show first.</div>
        </div>
        <div class="col-md-6">
            <label class="form-label fw-semibold" for="accent_color">Card colour</label>
            <select class="form-select" id="accent_color" name="accent_color">
                <cfloop array="#local.colours#" item="local.colour">
                    <option value="#local.colour.value#"<cfif compareNoCase( local.colour.value, local.item.accent_color ) == 0> selected</cfif>>#local.colour.label#</option>
                </cfloop>
            </select>
        </div>
        <div class="col-12">
            <label class="form-label fw-semibold" for="bio">About the professor</label>
            <textarea class="form-control" id="bio" name="bio" rows="5" aria-describedby="bioHelp">#encodeForHTML( local.item.bio )#</textarea>
            <div id="bioHelp" class="form-text">The first sentence appears on the card; the full text appears in "View profile".</div>
        </div>
    </div>

    <cfset local.imagePath = local.item.photo_url>
    <cfset local.imageLabel = "Photo">
    <cfinclude template="_imagefield.cfm">

    <button type="submit" class="btn btn-dark">Save professor</button>
    <a class="btn btn-link" href="#len( rc.returnTo ) ? rc.basePath & 'index.cfm##' & rc.returnTo : buildURL( 'admin.list?type=professors' )#">Cancel</a>
</form>
</cfoutput>
