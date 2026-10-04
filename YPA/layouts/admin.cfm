<!---
    layouts/admin.cfm
    -----------------
    The page shell for every admin page (FW/1 uses layouts/admin.cfm for
    the "admin" section automatically). It is a complete HTML page, so it
    sets request.layout = false to stop FW/1 from also wrapping it in
    layouts/default.cfm.

    The admin pages are ordinary server-rendered pages (no app.js).
--->
<cfset request.layout = false>
<cfset local.loggedIn = structKeyExists( session, "isAdmin" ) && session.isAdmin>
<cfset local.adminTypes = [
    { type : "professors", label : "Professors" },
    { type : "branches",   label : "Branches" },
    { type : "achievers",  label : "Achievers" },
    { type : "events",     label : "Events" },
    { type : "students",   label : "Students" }
]>
<cfoutput>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex, nofollow">
    <title>#encodeForHTML( rc.pageTitle ?: "Admin" )# | YPA Academy Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Figtree:wght@400;500;600;700&family=Zilla+Slab:wght@400;500;600;700&display=swap">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="#rc.basePath#assets/css/site.css">
</head>
<body class="admin-body">

    <a class="skip-link visually-hidden-focusable" href="##adminMain">Skip to main content</a>

    <header>
        <nav class="navbar navbar-expand-lg site-nav" aria-label="Admin">
            <div class="container-fluid site-nav__inner">
                <a class="navbar-brand site-brand" href="#buildURL( local.loggedIn ? 'admin.default' : 'admin.login' )#">
                    <span class="site-brand__logo" aria-hidden="true">YPA</span>
                    <span class="site-brand__name">YPA Admin</span>
                </a>

                <cfif local.loggedIn>
                    <button class="navbar-toggler" type="button"
                            data-bs-toggle="collapse" data-bs-target="##adminNav"
                            aria-controls="adminNav" aria-expanded="false" aria-label="Open menu">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div class="collapse navbar-collapse" id="adminNav">
                        <ul class="navbar-nav ms-auto align-items-lg-center">
                            <li class="nav-item"><a class="nav-link" href="#buildURL( 'admin.poster' )#">Poster</a></li>
                            <cfloop array="#local.adminTypes#" item="local.t">
                                <li class="nav-item">
                                    <a class="nav-link<cfif ( rc.type ?: '' ) == local.t.type> active</cfif>"
                                       href="#buildURL( 'admin.list?type=' & local.t.type )#">#local.t.label#</a>
                                </li>
                            </cfloop>
                            <li class="nav-item"><a class="nav-link" href="#rc.basePath#index.cfm">View site</a></li>
                            <li class="nav-item">
                                <form method="post" action="#buildURL( 'admin.logout' )#" class="d-inline">
                                    <input type="hidden" name="csrfToken" value="#encodeForHTMLAttribute( rc.csrfToken )#">
                                    <button type="submit" class="nav-link btn btn-link">Log out</button>
                                </form>
                            </li>
                        </ul>
                    </div>
                </cfif>
            </div>
        </nav>
    </header>

    <main id="adminMain" class="admin-main" tabindex="-1">
        <div class="container">
            #body#
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Ask before deleting: any form with data-confirm shows that question first.
        document.addEventListener('submit', function (event) {
            var question = event.target.getAttribute('data-confirm');
            if (question && !window.confirm(question)) {
                event.preventDefault();
            }
        });

        // Show a preview as soon as a new image is chosen.
        document.addEventListener('change', function (event) {
            var input = event.target;
            if (!input.matches('input[type="file"][data-preview]') || !input.files || !input.files[0]) {
                return;
            }
            var preview = document.getElementById(input.getAttribute('data-preview'));
            if (preview) {
                preview.src = URL.createObjectURL(input.files[0]);
                preview.hidden = false;
            }
        });
    </script>
</body>
</html>
</cfoutput>
