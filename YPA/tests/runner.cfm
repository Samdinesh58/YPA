<!---
    tests/runner.cfm
    Open http://127.0.0.1:8500/tests/runner.cfm in a browser, or run
    "box testbox run" from the project folder.
--->
<cfsetting showDebugOutput="false">
<cfparam name="url.directory" default="tests.specs">
<cfparam name="url.recurse"   default="true">
<cfparam name="url.reporter"  default="simple">
<cfinclude template="/testbox/system/runners/HTMLRunner.cfm">
