<!---
    views/admin/poster.cfm - change the home page poster image and tagline.
    Posts to admin.savePoster. The file field is "posterImage".
--->
<cfoutput>
<h1 class="admin-title">Poster</h1>
<cfinclude template="_messages.cfm">

<form method="post" action="#buildURL( 'admin.savePoster' )#" enctype="multipart/form-data" class="admin-card admin-form">
    <input type="hidden" name="csrfToken" value="#encodeForHTMLAttribute( rc.csrfToken )#">
    <input type="hidden" name="returnTo" value="#encodeForHTMLAttribute( rc.returnTo )#">

    <div class="mb-4">
        <label class="form-label fw-semibold" for="tagline">Tagline</label>
        <input class="form-control" type="text" id="tagline" name="tagline" maxlength="200"
               value="#encodeForHTMLAttribute( rc.tagline )#">
        <div class="form-text">Shown under "YPA Academy" on the poster.</div>
    </div>

    <fieldset class="mb-4">
        <legend class="form-label fw-semibold fs-6">Poster image</legend>
        <img id="posterPreview" class="admin-poster-preview"
             src="#len( rc.posterImage ) ? encodeForHTMLAttribute( rc.basePath & rc.posterImage ) : ''#"
             alt="Current poster image" <cfif !len( rc.posterImage )>hidden</cfif>>

        <label class="form-label" for="posterImage">Choose a new poster image (optional)</label>
        <input class="form-control" type="file" id="posterImage" name="posterImage"
               accept="image/jpeg,image/png,image/gif,image/webp"
               data-preview="posterPreview" aria-describedby="posterHelp">
        <div id="posterHelp" class="form-text">A wide photo works best (at least 1600 &times; 600 pixels). JPG, PNG, GIF or WebP, up to 5 MB.</div>

        <cfif len( rc.posterImage )>
            <div class="form-check mt-2">
                <input class="form-check-input" type="checkbox" id="removeImage" name="removeImage" value="1">
                <label class="form-check-label" for="removeImage">Remove the poster image (show the plain grey background)</label>
            </div>
        </cfif>
    </fieldset>

    <button type="submit" class="btn btn-dark">Save poster</button>
    <a class="btn btn-link" href="#len( rc.returnTo ) ? rc.basePath & 'index.cfm##' & rc.returnTo : buildURL( 'admin.default' )#">Cancel</a>
</form>
</cfoutput>
