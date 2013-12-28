#!/usr/local/bin/perl

require 5.003;

use Net::Rwhois;

$client = new Net::Rwhois( Host => "shaker.rwhois.net",
			   Port => 4321 );

$client->open();

@results = $client->execute_query( Query_String => "host asdf3-hst",
				   Limit        => 30 );

print "got ", scalar @results, " results\n";
$buf = $client->results_to_string(@results);

print "$buf";


