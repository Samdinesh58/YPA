<!---
    views/admin/branches_form.cfm - add or edit a branch.
    rc.item holds the values (empty for "Add"). Posts to admin.save.
--->
<cfset local.item = rc.item>
<cfoutput>
<h1 class="admin-title">#encodeForHTML( rc.pageTitle )#</h1>
<cfinclude template="_messages.cfm">

<form method="post" action="#buildURL( 'admin.save' )#" enctype="multipart/form-data" class="admin-card admin-form">
    <input type="hidden" name="csrfToken" value="#encodeForHTMLAttribute( rc.csrfToken )#">
    <input type="hidden" name="type" value="branches">
    <input type="hidden" name="id" value="#val( local.item.id )#">
    <input type="hidden" name="returnTo" value="#encodeForHTMLAttribute( rc.returnTo )#">

    <div class="row g-3 mb-4">
        <div class="col-md-6">
            <label class="form-label fw-semibold" for="name">Branch name *</label>
            <input class="form-control" type="text" id="name" name="name" maxlength="120" required
                   value="#encodeForHTMLAttribute( local.item.name )#">
        </div>
        <div class="col-md-6">
            <label class="form-label fw-semibold" for="phone">Phone</label>
            <input class="form-control" type="tel" id="phone" name="phone" maxlength="30"
                   value="#encodeForHTMLAttribute( local.item.phone )#" placeholder="+91 98765 43210">
        </div>
        <div class="col-12">
            <label class="form-label fw-semibold" for="address">Address *</label>
            <input class="form-control" type="text" id="address" name="address" maxlength="255" required
                   value="#encodeForHTMLAttribute( local.item.address )#">
        </div>
    </div>

    <cfset local.imagePath = local.item.image_url>
    <cfset local.imageLabel = "Image">
    <cfinclude template="_imagefield.cfm">

    <button type="submit" class="btn btn-dark">Save branch</button>
    <a class="btn btn-link" href="#len( rc.returnTo ) ? rc.basePath & 'index.cfm##' & rc.returnTo : buildURL( 'admin.list?type=branches' )#">Cancel</a>
</form>
</cfoutput>
