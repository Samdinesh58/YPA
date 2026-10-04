<!---
    views/main/default.cfm
    ----------------------
    The home section: the poster (hero) and the "YPA Professors" grid.
    The grid starts empty; assets/js/app.js loads the professors from
    api.professors and draws the cards into .js-professor-grid.

    The poster image and tagline are set in the admin area (Admin > Poster)
    and loaded by controllers/main.cfc into rc.posterImage and rc.tagline.
    Without an uploaded image, the old assets/img/poster.jpg is used if it
    exists; otherwise the hero shows its plain grey background.
--->
<cfscript>
    local.posterUrl = "";
    if ( len( rc.posterImage ) ) {
        local.posterUrl = rc.basePath & rc.posterImage;
    } else if ( fileExists( getDirectoryFromPath( getBaseTemplatePath() ) & "assets/img/poster.jpg" ) ) {
        local.posterUrl = rc.basePath & "assets/img/poster.jpg";
    }
</cfscript>
<cfoutput>
<section class="hero<cfif len( local.posterUrl )> hero--has-image</cfif>"
    <cfif len( local.posterUrl )>style="background-image: url('#encodeForCSS( local.posterUrl )#');"</cfif>
    aria-labelledby="heroTitle">

    <cfif rc.isAdmin>
        <!--- Admin only: pencil to change the poster image and tagline --->
        <a class="edit-pencil edit-pencil--hero" href="#encodeForHTMLAttribute( rc.basePath & 'index.cfm?action=admin.poster&returnTo=home' )#" aria-label="Edit poster">
            <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M4 20h4L19 9l-4-4L4 16v4zM14 6l4 4" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </a>
    </cfif>

    <div class="hero__content">
        <h1 class="hero__title" id="heroTitle">#encodeForHTML( rc.site.name )#</h1>
        <p class="hero__tagline">#encodeForHTML( rc.tagline )#</p>

        <!--- Icon-only button, so it needs an aria-label --->
        <button type="button" class="hero__scroll js-scroll-to-professors" aria-label="Scroll down to YPA Professors">
            <svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true" focusable="false">
                <path d="M6 9l6 6 6-6" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
        </button>
    </div>
</section>

<section class="page-section" id="professors-section" aria-labelledby="professorsTitle">
    <div class="container">
        <h2 class="section-title" id="professorsTitle" tabindex="-1">YPA Professors</h2>

        <!--- aria-live: screen readers announce when the cards arrive --->
        <div class="js-professor-grid" aria-live="polite">
            <noscript>
                <p class="status-message">Please turn on JavaScript to see our professors.</p>
            </noscript>
        </div>
    </div>
</section>
</cfoutput>
