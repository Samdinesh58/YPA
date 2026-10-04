<!---
    views/admin/_messages.cfm
    Included at the top of admin pages. Shows:
      rc.message : success message (kept across the redirect by FW/1)
      rc.alert   : single warning message
      rc.errors  : array of form problems
--->
<cfoutput>
<cfif len( rc.message ?: "" )>
    <div class="alert alert-success" role="status">#encodeForHTML( rc.message )#</div>
</cfif>
<cfif len( rc.alert ?: "" )>
    <div class="alert alert-warning" role="alert">#encodeForHTML( rc.alert )#</div>
</cfif>
<cfif isArray( rc.errors ?: "" ) && arrayLen( rc.errors )>
    <div class="alert alert-danger" role="alert">
        <p class="fw-semibold mb-2">Please fix the following:</p>
        <ul class="mb-0">
            <cfloop array="#rc.errors#" item="local.error">
                <li>#encodeForHTML( local.error )#</li>
            </cfloop>
        </ul>
    </div>
</cfif>
</cfoutput>
