<!---
    views/admin/login.cfm - admin login form.
    Posts to admin.doLogin, which checks the static username/password in
    model/services/AuthService.cfc.
--->
<cfoutput>
<div class="admin-login">
    <h1 class="admin-title text-center">Admin login</h1>

    <cfif structKeyExists( rc, "loggedout" )>
        <div class="alert alert-success" role="status">You have been logged out.</div>
    </cfif>
    <cfinclude template="_messages.cfm">

    <form method="post" action="#buildURL( 'admin.doLogin' )#" class="admin-card">
        <input type="hidden" name="csrfToken" value="#encodeForHTMLAttribute( rc.csrfToken )#">

        <div class="mb-3">
            <label class="form-label" for="username">Username</label>
            <input class="form-control" type="text" id="username" name="username"
                   value="#encodeForHTMLAttribute( rc.username ?: '' )#"
                   autocomplete="username" autocapitalize="none" spellcheck="false" required autofocus>
        </div>
        <div class="mb-4">
            <label class="form-label" for="password">Password</label>
            <input class="form-control" type="password" id="password" name="password"
                   autocomplete="current-password" required>
        </div>
        <button type="submit" class="btn btn-dark w-100">Log in</button>
    </form>

    <p class="text-center mt-3"><a href="#rc.basePath#index.cfm">&larr; Back to the website</a></p>
</div>
</cfoutput>
