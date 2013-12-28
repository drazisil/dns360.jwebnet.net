<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<?php
// Insert this block of code at the very top of your page:
$time = microtime();
$time = explode(" ", $time);
$time = $time[1] + $time[0];
$start = $time;
?>
<html>
    <head>
        <meta http-equiv="Content-Language" content="en">
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title>DNS 360 : Home</title>
        <link rel="stylesheet" href="assets/css/dns360.css" type="text/css" media="screen, projection">
        <link rel="stylesheet" href="assets/css/ui.tabs.css" type="text/css">
        <script type="text/javascript" src="assets/js/jquery-1.5.1.min.js"></script>
        <script type="text/javascript" src="assets/js/jquery-ui-1.8.14.custom.min.js"></script>

    </head>
    <body class="flora">

        <h1>DNS 360</h1>
        <p><a name="top" href="/">Reset All</a></p>

        <div id="container-1">
            <ul>
                <li><a href="#fragment-1"><span>Home</span></a></li>
                <li><a href="#fragment-2"><span>Whois</span></a></li>
                <li><a href="#fragment-3"><span>DIG</span></a></li>
                <li><a href="#fragment-4"><span>PTR Lookup</span></a></li>
                <li><a href="#fragment-5"><span>ARIN IP Lookup</span></a></li>
                <li><a href="#fragment-6"><span>Misc</span></a></li>
                <li><a href="#fragment-7"><span>New Whois</span></a></li>
            </ul>
            <div id="fragment-1">
                <p>
                    DNS 360 provides the most common tools together in one place. 
                    You can perform WHOIS, DIG and PTR lookups with this set of tools. 
                </p>
                <p>
                    The currently supported domains for the WHOIS are .INFO, .BIZ, .ORG, .COM, .NET and .EDU.
                    WHOIS information for the .GOV and .MIL domains is not available.
                </p>
                <p>
                    Any questions please contact dns360@jwebnet.net. 
                </p>
            </div>
            <div id="fragment-2">
                <?php require("tab-whois.php"); ?>
            </div>
            <div id="fragment-3">
                <?php require("tab-dig.php"); ?>
            </div>
            <div id="fragment-4">
                <?php require("tab-ptr.php"); ?>
            </div>
            <div id="fragment-5">
                <?php require("tab-arin.php"); ?>
            </div>
            <div id="fragment-6">
                <p>
                    Misc Tools
                </p>
            </div>
            <div id="fragment-7">
                <?php require("tab-whois2.php"); ?>
            </div>
        </div>


        <script type="text/javascript">
            // <![CDATA[
            $(window).bind('load', function() {
                $('#container-1').tabs();
            });
            // ]]>
        </script>
        <script type="text/javascript">

            var _gaq = _gaq || [];
            _gaq.push(['_setAccount', 'UA-246703-5']);
            _gaq.push(['_trackPageview']);

            (function() {
                var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
                ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
            })();

        </script>
        <?php
        $time = microtime();
        $time = explode(" ", $time);
        $time = $time[1] + $time[0];
        $finish = $time;
        $totaltime = ($finish - $start);
        printf("<!-- This page took %f seconds to load.-->", $totaltime);
        ?> 
    </body>
</html>