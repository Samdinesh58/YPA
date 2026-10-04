<!---
    views/admin/achievers_form.cfm - add or edit an achiever.
    rc.item holds the values (empty for "Add"). Posts to admin.save.
--->
<cfset local.item = rc.item>
<cfoutput>
<h1 class="admin-title">#encodeForHTML( rc.pageTitle )#</h1>
<cfinclude template="_messages.cfm">

<form method="post" action="#buildURL( 'admin.save' )#" enctype="multipart/form-data" class="admin-card admin-form">
    <input type="hidden" name="csrfToken" value="#encodeForHTMLAttribute( rc.csrfToken )#">
    <input type="hidden" name="type" value="achievers">
    <input type="hidden" name="id" value="#val( local.item.id )#">
    <input type="hidden" name="returnTo" value="#encodeForHTMLAttribute( rc.returnTo )#">

    <div class="row g-3 mb-4">
        <div class="col-md-6">
            <label class="form-label fw-semibold" for="name">Name *</label>
            <input class="form-control" type="text" id="name" name="name" maxlength="120" required
                   value="#encodeForHTMLAttribute( local.item.name )#">
        </div>
        <div class="col-md-6">
            <label class="form-label fw-semibold" for="exam">Exam *</label>
            <input class="form-control" type="text" id="exam" name="exam" maxlength="120" required
                   value="#encodeForHTMLAttribute( local.item.exam )#" placeholder="e.g. Combined Graduate Level">
        </div>
        <div class="col-md-6">
            <label class="form-label fw-semibold" for="rank_or_post">Rank or post *</label>
            <input class="form-control" type="text" id="rank_or_post" name="rank_or_post" maxlength="120" required
                   value="#encodeForHTMLAttribute( local.item.rank_or_post )#" placeholder="e.g. State Rank 12">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold" for="year">Year *</label>
            <input class="form-control" type="number" id="year" name="year" min="1950" max="2100" required
                   value="#encodeForHTMLAttribute( local.item.year )#">
        </div>
    </div>

    <cfset local.imagePath = local.item.photo_url>
    <cfset local.imageLabel = "Photo">
    <cfinclude template="_imagefield.cfm">

    <button type="submit" class="btn btn-dark">Save achiever</button>
    <a class="btn btn-link" href="#len( rc.returnTo ) ? rc.basePath & 'index.cfm##' & rc.returnTo : buildURL( 'admin.list?type=achievers' )#">Cancel</a>
</form>
</cfoutput>
