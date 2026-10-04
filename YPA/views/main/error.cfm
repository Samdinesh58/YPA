<!---
    views/main/error.cfm
    --------------------
    FW/1 shows this view (action "main.error") when an unhandled error
    happens. Visitors see a friendly message; the real error is in the
    Lucee logs (run "box server log --follow").
--->
<section class="page-section">
    <div class="container text-center">
        <h1 class="section-title">Something went wrong</h1>
        <p class="status-message">Sorry, this page could not be shown. Please try again in a moment.</p>
        <p><a class="btn btn-dark" href="./">Back to home</a></p>
    </div>
</section>
