#!/usr/bin/perl -w
# Copyright (C) 2003 Paul T. Jobson
# pjobson@visual-e.net
# aim: vbrtrmn
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# The GNU General Public License is available here:
# http://www.gnu.org/copyleft/gpl.html#SEC3
##################################################################
# digger.cgi
# Program for doing recursive dig requests, used to find DNS
# propagation issues.

$| = 1;

use strict;
use CGI qw(:all);
use CGI::Carp('fatalsToBrowser');

my ($digdata,$nextlevel,$hostin,$gtld, $dt);
my $dt = param('type');
my $host = param('host');
my $fgtld = param('fgtld');
my $sent = "false";

&doHTMLStart;
&checkforErrors;
&startDigLoop;
&doHTMLEnd;


sub startDigLoop {
	$gtld = param('fgtld');
	&doTheDig;
}

sub doTheDig {
        $digdata = `dig \@$gtld $host -t $dt`;
        &outputData;
        &extractNS;
}

sub checkforErrors {
        } if ($host eq "") {
                print "Missing Host";
                exit;
        } elsif ($host =~ m/[\|&\+=\@%]/gi) {
                print "Invalid Host";
                exit;
}

sub outputData {
        my $header = "# dig \@$gtld $host $dt\n";
        if ($digdata =~ /(status: QUERY REFUSED)/) {
                print "$header $1";
        } elsif ($digdata =~ /(status: SERVER FAILED)/) {
                print "$header $1";
        } elsif ($digdata =~ /(status: CONNECTION REFUSED)/) {
                print "$header $1";
        } elsif ($digdata =~ /(status: TIMED OUT)/) {
                print "$header $1";
        } elsif ($digdata =~ /(status: NXDOMAIN)/) {
                print "$header $1";
        } elsif ($digdata =~ /(status: REFUSED)/) {
                print "$header $1";
        } elsif ($digdata =~ /(status: SERVFAIL)/) {
                # $header\n SERVFAIL means that the domain does exist and the root name servers have information on this domain, but that the authoritative name servers are not answering queries for this domain:\n\n\n +\n $digdata\n +"
		print $digdata;
        } elsif ($digdata =~ /status: NOERROR/) {
                print $digdata;
        } else {
                print "$header unknown error code, probably invalid name server or server time-out; try resubmitting query:\n\n\n +\n $digdata\n +";
        }
}

sub extractNS {
        my @templist = $digdata =~ m/(NS\s+.+\.\n)/g;
        @templist = map { s/NS\s+(.+)\.\n/$1/; $_; } @templist; # clean the array
        for (@templist) {
                my $ns = lc($_);
        }
}

sub invalidPasswordExit {
        print "Invalid Password";
        exit;
}

sub doHTMLStart {
        print header();
}

sub doHTMLEnd {
}