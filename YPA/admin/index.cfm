<!---
    /admin -> the admin login page (index.cfm?action=admin.login).
    If the visitor is already logged in, the login action forwards them
    straight to the dashboard.
--->
<cflocation url="../index.cfm?action=admin.login" addtoken="false">
