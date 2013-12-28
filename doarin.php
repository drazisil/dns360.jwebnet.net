<?php

$type = $_REQUEST["type"];
$domain = $_REQUEST["host"];
$fgtld = $_REQUEST["fgtld"];
$whois_server = "whois.arin.net";

function ae_whois($query, $server){
	define('AE_WHOIS_TIMEOUT', 15); // connection timeout
    global $ae_whois_errno, $ae_whois_errstr;

    // connecting
	$f = fsockopen($server, 43, $ae_whois_errno, $ae_whois_errstr, AE_WHOIS_TIMEOUT);
    if (!$f)	return false; // connection failed

	// sending query
	fwrite($f, $query."\r\n");

    // receving response
	$response = '';
    while (!feof($f))	$response .= fgets($f, 1024);

    // closing connection
	fclose($f);

    return $response;
}

// copy-paste function ae_whois(see above) here
 $whois_data = ae_whois($domain, $whois_server);
 
echo " *** WHOIS SERVER : " . $whois_server . " ***\n\nData current as of " . date('r') ."\n\n";
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n";
echo $whois_data;
?>