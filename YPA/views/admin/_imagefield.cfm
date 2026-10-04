<!---
    views/admin/_imagefield.cfm
    The image part of every admin form: current image, file picker and a
    "remove image" checkbox. Before including it, set:
      local.imagePath  : the current image path ("" if none)
      local.imageLabel : e.g. "Photo" or "Image"
    The file field is always named "image"; the controller reads it from there.
--->
<cfoutput>
<fieldset class="admin-image-field mb-4">
    <legend class="form-label fw-semibold fs-6">#encodeForHTML( local.imageLabel )#</legend>

    <img id="imagePreview" class="admin-image-preview"
         src="#len( local.imagePath ) ? encodeForHTMLAttribute( rc.basePath & local.imagePath ) : ''#"
         alt="Current #encodeForHTMLAttribute( lCase( local.imageLabel ) )#"
         <cfif !len( local.imagePath )>hidden</cfif>>

    <label class="form-label" for="image">Choose a new #encodeForHTML( lCase( local.imageLabel ) )# (optional)</label>
    <input class="form-control" type="file" id="image" name="image"
           accept="image/jpeg,image/png,image/gif,image/webp"
           data-preview="imagePreview" aria-describedby="imageHelp">
    <div id="imageHelp" class="form-text">JPG, PNG, GIF or WebP, up to 5 MB. Leave empty to keep the current one.</div>

    <cfif len( local.imagePath )>
        <div class="form-check mt-2">
            <input class="form-check-input" type="checkbox" id="removeImage" name="removeImage" value="1">
            <label class="form-check-label" for="removeImage">Remove the current #encodeForHTML( lCase( local.imageLabel ) )#</label>
        </div>
    </cfif>
    <cfif isArray( rc.errors ?: "" ) && arrayLen( rc.errors )>
        <div class="form-text text-danger">If you had chosen an image, please choose it again.</div>
    </cfif>
</fieldset>
</cfoutput>
