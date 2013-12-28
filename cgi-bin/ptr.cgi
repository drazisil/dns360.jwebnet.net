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

my ($digdata,$nextlevel,$hostin);
my $host = param('host');
my $sent = "false";

&doHTMLStart;
&checkforErrors;
&startDigLoop;
&doHTMLEnd;


sub startDigLoop {
	&doTheDig;
}

sub doTheDig {
        $digdata = `nslookup $host`;
        &outputData;
        &extractNS;
}

sub checkforErrors {
        if ($host eq "") {
                print "<h1>Missing Host</h1>";
                exit;
        } elsif ($host =~ m/[\|&\+=\@%]/gi) {
                print "<h1>Invalid Host</h1>";
                exit;
        }
}

sub outputData {
	print $digdata;
}

sub extractNS {
        my @templist = $digdata =~ m/(NS\s+.+\.\n)/g;
        @templist = map { s/NS\s+(.+)\.\n/$1/; $_; } @templist; # clean the array
        for (@templist) {
                my $ns = lc($_);
        }
}

sub invalidPasswordExit {
        print "<h1>Invalid Password</h1>";
        exit;
}

sub doHTMLStart {
        print header();
}

sub doHTMLEnd {
}