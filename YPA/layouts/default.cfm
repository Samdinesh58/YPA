<!---
    layouts/default.cfm
    -------------------
    The HTML shell around every page: <head>, navbar, the #app container,
    footer, the professor modal and the scripts.

    FW/1 puts the rendered view (views/main/default.cfm) in the variable
    "body", which is output inside <main id="app">. After the first load,
    assets/js/app.js swaps the contents of #app without reloading the page.

    Inside <cfoutput>, "##" prints a single "#" (e.g. href="##home").

    Admin pages don't use this file: layouts/admin.cfm is a complete page
    and stops FW/1 from wrapping it in this layout.
--->
<cfoutput>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>#encodeForHTML( rc.site.name )#</title>
    <meta name="description" content="#encodeForHTMLAttribute( rc.site.name & ' - ' & rc.site.tagline )#">

    <!--- Google Fonts: Zilla Slab (headings) and Figtree (body text) --->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Figtree:wght@400;500;600;700&family=Zilla+Slab:wght@400;500;600;700&display=swap">

    <!--- Bootstrap 5 CSS, then our own styles (loaded last so they win) --->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="#rc.basePath#assets/css/site.css">
</head>
<!---
    data-api-url    : where the JSON endpoints live
    data-base-path  : the site's folder, used to build image URLs
    data-is-admin   : "true" when logged in, so app.js adds pencil icons
    data-admin-url  : start of the admin form URLs (only when logged in)
--->
<body data-api-url="#encodeForHTMLAttribute( rc.basePath & 'index.cfm?action=api.' )#"
      data-base-path="#encodeForHTMLAttribute( rc.basePath )#"
      data-is-admin="#rc.isAdmin ? 'true' : 'false'#"
      <cfif rc.isAdmin>data-admin-url="#encodeForHTMLAttribute( rc.basePath & 'index.cfm?action=admin.' )#"</cfif>>

    <!--- Lets keyboard users jump past the navbar --->
    <a class="skip-link visually-hidden-focusable" href="##app">Skip to main content</a>

    <cfif rc.isAdmin>
        <!--- Thin bar shown only to the logged-in admin --->
        <div class="admin-bar">
            <span>Admin mode: use the pencil icons to edit, or the Add buttons to add new items.</span>
            <span class="admin-bar__links">
                <a href="#encodeForHTMLAttribute( rc.basePath & 'index.cfm?action=admin.default' )#">Dashboard</a>
                <form method="post" action="#encodeForHTMLAttribute( rc.basePath & 'index.cfm?action=admin.logout' )#" class="d-inline">
                    <input type="hidden" name="csrfToken" value="#encodeForHTMLAttribute( rc.csrfToken )#">
                    <button type="submit" class="admin-bar__logout">Log out</button>
                </form>
            </span>
        </div>
    </cfif>

    <!--- ===== Navbar ===== --->
    <header>
        <nav class="navbar navbar-expand-lg site-nav" aria-label="Main">
            <div class="container-fluid site-nav__inner">
                <a class="navbar-brand site-brand" href="##home">
                    <span class="site-brand__logo" aria-hidden="true">YPA</span>
                    <span class="site-brand__name">#encodeForHTML( rc.site.name )#</span>
                </a>

                <!--- Hamburger button, only visible on small screens --->
                <button class="navbar-toggler" type="button"
                        data-bs-toggle="collapse" data-bs-target="##mainNav"
                        aria-controls="mainNav" aria-expanded="false"
                        aria-label="Open menu">
                    <span class="navbar-toggler-icon"></span>
                </button>

                <!--- The five section links. data-route matches the hash. --->
                <div class="collapse navbar-collapse" id="mainNav">
                    <ul class="navbar-nav ms-auto">
                        <li class="nav-item"><a class="nav-link" href="##branches"   data-route="branches">YPA Branches</a></li>
                        <li class="nav-item"><a class="nav-link" href="##achievers"  data-route="achievers">YPA Achievers</a></li>
                        <li class="nav-item"><a class="nav-link" href="##events"     data-route="events">YPA Events</a></li>
                        <li class="nav-item"><a class="nav-link" href="##professors" data-route="professors">YPA Professors</a></li>
                        <li class="nav-item"><a class="nav-link" href="##students"   data-route="students">YPA Students</a></li>
                    </ul>
                </div>
            </div>
        </nav>
    </header>

    <!--- ===== Main content: app.js replaces what is inside ===== --->
    <main id="app" tabindex="-1">
        #body#
    </main>

    <!--- ===== Footer ===== --->
    <footer class="site-footer">
        <div class="container-fluid site-footer__inner">
            <p class="site-footer__brand">#encodeForHTML( rc.site.name )#</p>
            <address class="site-footer__contact">
                #encodeForHTML( rc.site.address )#
                <span aria-hidden="true">&middot;</span>
                <a href="tel:#encodeForHTMLAttribute( reReplace( rc.site.phone, '[^0-9+]', '', 'all' ) )#">#encodeForHTML( rc.site.phone )#</a>
                <span aria-hidden="true">&middot;</span>
                <a href="mailto:#encodeForHTMLAttribute( rc.site.email )#">#encodeForHTML( rc.site.email )#</a>
            </address>
        </div>
    </footer>

    <!--- ===== Professor profile modal (filled in by app.js) ===== --->
    <div class="modal fade" id="professorModal" tabindex="-1" aria-labelledby="professorModalTitle" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h2 class="modal-title" id="professorModalTitle">Professor profile</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="professorModalBody"></div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!--- jQuery first, then Bootstrap (bundle includes Popper), then our app --->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="#rc.basePath#assets/js/app.js"></script>
</body>
</html>
</cfoutput>
