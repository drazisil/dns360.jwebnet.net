<?php

// TODO: Clean this up!

$type = $_REQUEST["type"];
$domain = $_REQUEST["host"];
$fgtld = $_REQUEST["fgtld"];
switch (strtoupper(substr($domain, -4))) {
    case "INFO":
        $whois_server = "afilias.info";
        break;
}
switch (strtoupper(substr($domain, -3))) {
    case "BIZ":
        $whois_server = "whois.whois.biz";
        break;
    case "ORG":
        $whois_server = "whois.pir.org";
        break;
    case "COM":
    case "NET":
        $whois_server = "whois.verisign-grs.com";
        break;
    case "EDU";
        $whois_server = "whois.educause.net";
        break;
    case "GOV";
        echo "You CAN NOT access the .mil whois unless you are inside the .mil network.";
        exit;
    case "MIL";
        echo "You CAN NOT access the .gov whois unless you are inside the .mil network.";
        exit;
    default:
        $whois_server = "whois.verisign-grs.com";
        break;
}

function ae_whois($query, $server)
{
    define('AE_WHOIS_TIMEOUT', 15); // connection timeout
    global $ae_whois_errno, $ae_whois_errstr;

    // connecting
    $f = fsockopen($server, 43, $ae_whois_errno, $ae_whois_errstr, AE_WHOIS_TIMEOUT);
    if (!$f) return false; // connection failed

    // sending query
    fwrite($f, $query . "\r\n");

    // receving response
    $response = '';
    while (!feof($f)) $response .= fgets($f, 1024);

    // closing connection
    fclose($f);

    return $response;
}

// copy-paste function ae_whois(see above) here
$whois_data = ae_whois('domain ' . $domain . '', $whois_server);
// echo $whois_data;

if (preg_match("/Whois Server: ([a-zA-Z0-9\.]+)/", $whois_data, $regs)) {
    $whois_server = $regs[1];
    $whois_data = ae_whois($domain, $whois_server);
    echo " *** WHOIS SERVER : " . $whois_server . " ***\n\nData current as of " . date('r') . "\n\n";
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n";
    echo $whois_data;
} else {
    echo " *** WHOIS SERVER : " . $whois_server . " ***\n\nData current as of " . date('r') . "\n\n";
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n";
    echo $whois_data;
}