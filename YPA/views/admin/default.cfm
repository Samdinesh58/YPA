<!---
    views/admin/default.cfm - admin dashboard.
    One card per thing the admin can manage, with how many items exist.
--->
<cfset local.cards = [
    { type : "professors", label : "Professors", text : "Cards in the YPA Professors section" },
    { type : "branches",   label : "Branches",   text : "Academy centres, addresses and phones" },
    { type : "achievers",  label : "Achievers",  text : "Students who cleared their exams" },
    { type : "events",     label : "Events",     text : "Seminars, mock tests and workshops" },
    { type : "students",   label : "Students",   text : "Current students and their batches" }
]>
<cfoutput>
<h1 class="admin-title">Dashboard</h1>
<cfinclude template="_messages.cfm">

<div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
    <div class="col">
        <div class="admin-card h-100">
            <h2 class="h5 fw-bold">Poster</h2>
            <p class="text-secondary">The big image and tagline at the top of the home page.</p>
            <a class="btn btn-dark" href="#buildURL( 'admin.poster' )#">Edit poster</a>
        </div>
    </div>
    <cfloop array="#local.cards#" item="local.card">
        <div class="col">
            <div class="admin-card h-100">
                <h2 class="h5 fw-bold">#local.card.label# <span class="badge text-bg-secondary">#rc.counts[ local.card.type ]#</span></h2>
                <p class="text-secondary">#local.card.text#</p>
                <a class="btn btn-dark" href="#buildURL( 'admin.list?type=' & local.card.type )#">Manage</a>
                <a class="btn btn-outline-dark" href="#buildURL( 'admin.edit?type=' & local.card.type )#">Add new</a>
            </div>
        </div>
    </cfloop>
</div>
</cfoutput>
