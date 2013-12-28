#! /usr/local/bin/perl

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

# This is a sample CGI script acting as a RWhois client.  It relies on
# the standard perl5 module CGI as well as the Net::Rwhois package.
# It requires Net::Rwhois to be greater than or equal to version 0.08.

# usage:
#  This CGI script accepts the following parameters:
#    url: a rwhois or whois URL.
#    host: the server name of the rwhois server.
#    port: the port of the rwhois server.
#    proto: either "whois" or "rwhois". defaults to rwhois.
#    query: the query string.
#    overrideurl: flag specifying that the 'host', 'port' and 'proto'
#                 parameters should be favored over the 'url'
#                 parameter if both are specified.


# Currently the output html is quite plain.

require 5.005;

# allow for the Net::RWhois package to be installed the the cgi-bin
# directory.
use FindBin qw($Bin);
use lib "$Bin";

use Carp;
use CGI;

use Net::Rwhois;
use Net::Rwhois::Referral;
use Net::Rwhois::WhoisQuery;
use Net::Rwhois::WhoisResult;

use strict;

# define the global variables
use vars qw($cgi $script_name $form_url);

# installation defined variable:
$form_url = "/rwhois/prwhois.html";

main_cgi();
exit(0);


##################################
# Setup routines
##################################

# init: define (and calculate) various global variables
sub init {

  if (scalar @ARGV > 0) {
    print "command line mode\n";
    $cgi = new CGI(*STDIN);
  } else {
    $cgi = new CGI();
  }

  $script_name = $cgi->url(-absolute => 1);

}

# processCgiArgs: handle the overrideurl argument, basically.
sub processCgiArgs {
  my $overrideurl = $cgi->param('overrideurl');

  # prefer URLs first, then separate host, port params, unless override url
  my $url   = $cgi->param('url');
  my $host  = $cgi->param('host');
  my $port  = $cgi->param('port');
  my $proto = $cgi->param('proto') || "rwhois";

  if ($url and !($overrideurl and $host)) {
    # if we have a url and we are not overriding it, set the host/port
    # information from the url.
    my $r = new Net::Rwhois::Referral(Url => $url);

    $cgi->param('host', $r->get_host());
    $cgi->param('port', $r->get_port());
    $cgi->param('proto', $r->get_protocol());

  } elsif (!$url) {
    # otherwise, we set the url to match the host and port
    my $r = new Net::Rwhois::Referral(Host => $host,
                                      Port => $port);
    $r->set_protocol($proto);
    $cgi->param('url', $r->get_url());
  }
}

#########################################
#  Query Routines
#########################################


sub queryRwhois {
  my $querystr = shift;
  my $host     = shift;
  my $port     = shift || 4321;

  my $connection = new Net::Rwhois::Connection(Host => $host, Port => $port );

  if (not $connection->open()) {
    die "A connection could not be made to the RWhois server running at " .
      "<i>$host:$port</i>\n";
  }

  my $query = new Net::Rwhois::Query(Query_String => $querystr,
                                     Limit        => 0 );

  my $qr = $query->execute($connection);

  $qr->read_results();

  $qr;
}

sub queryWhois {
  my $querystr = shift;
  my $url      = shift;

  my $wc = new Net::Rwhois::WhoisQuery(URL   => $url,
                                       Query => $querystr)
    || die "Could not query the whois server at <i>$url</i>: $!\n";

  my $wr = $wc->execute()
    || die "Could not query the whois server at <i>$url</i>: $!\n";

  $wr;
}

sub selfURL {
  my $querystr = shift;
  my $urlstr   = shift || $cgi->param('url');

  $script_name . "?url=$urlstr&query=$querystr" ;
}
################################
# Base HTML routines
################################

sub outputHeader {
  my $title = shift;

  print $cgi->header(), "\n";
  print $cgi->start_html(-title => $title,
                         -bgcolor => "white"), "\n";
}

sub outputFooter {
  if ($form_url) {
    print $cgi->hr();
    print "Back to the ", $cgi->a({-href => $form_url}, "form"), ".\n";
  }

  print $cgi->end_html();
}

sub outputReferrals {
  my $querystr = shift;
  my @refs     = @_;

  return if (! @refs);

  print $cgi->a({-name => "#referrals"}), "\n";

  for my $ref (@refs) {
    my $url = $ref->get_url();

    print "Referral ",
    $cgi->a({-href => selfURL($querystr, $url)}, $url), "\n";
    print $cgi->br(), "\n";
  }

  print $cgi->hr(), "\n";
}

sub outputErrorMessage {
  my $title = shift;
  my @lines = @_;

  if ($title) {
    outputHeader("RWhois Failure: $title");
  } else {
    outputHeader("RWhois Failure");
  }

  print $cgi->h1({-align => "center"}, $title), "\n";
  print $cgi->hr(), "\n";

  for my $line (@lines) {
    print $cgi->p($line), "\n";
  }
}

###############################
#  RWhois HTML routines
###############################

sub outputRwhoisHeading {
  my $querystr      = shift;
  my $url           = shift;
  my $num_objects   = shift;
  my $num_referrals = shift;
  my $num_errors    = shift;

  print $cgi->h1({-align => "center"},  "RWhois Query Results"), "\n";
  print "Query: ", $cgi->b($querystr), " from ", $cgi->i($url), "\n";
  print $cgi->br(), "\n";

  if ($num_objects) {
    print $cgi->b($cgi->a({-href => "#objects"}, "Objects Returned")
                  . ": $num_objects"), "\n";
    print $cgi->br(), "\n";
  }
  if ($num_referrals) {
    print $cgi->b($cgi->a({-href => "#referrals"}, "Referrals Returned")
                  . ": $num_referrals"), "\n";
    print $cgi->br(), "\n";
  }
  if ($num_errors) {
    print $cgi->b($cgi->a({-href => "#errors"}, "Errors Returned")
                  . ": $num_errors"), "\n";
    print $cgi->br(), "\n";
  }
  print $cgi->hr(), "\n";
}

sub outputRwhoisRecords {
  my @recs = @_;

  return if (! @recs);

  print $cgi->a({-name => "#objects"}), "\n";

  my $not_first = 0;

  for my $rec (@recs) {

    next if ($rec->get_id() eq "RESERVED-1.0.0.0.0/0");

    print $cgi->hr() if ($not_first);
    $not_first++;

    # each record is represented as a simple 2 column table
    print $cgi->start_table({-cols => 2, -border => 0}), "\n";

    for my $attr ($rec->get_attribute_names()) {
      my @vals = $rec->get_attribute($attr);

      for my $val (@vals) {
        if ($rec->get_attribute_type($attr) eq "ID") {
          my $self_url = selfURL($val);
          # my $self_url = $script_name . "?" . $cgi->query_string();
          # change the query part to the new query
          # $self_url =~ s/query=[^&]+/query=$val/i;
          # escape spaces (though none should exist, really)
          # fixme: what is the canonical URL escaping routine?
          $self_url =~ s/ /%20/go;

          print $cgi->Tr( $cgi->td($attr),
                          $cgi->td($cgi->a({-href => $self_url}, $val)) );
          print "\n";
        } else {
          print $cgi->Tr( $cgi->td($attr), $cgi->td($val) ), "\n";
        }
      }
    }

    print $cgi->end_table(), "\n";
  }
}

sub outputRwhoisErrors {
  my @errors = @_;

  return if (! @errors);

  print $cgi->a({-name => "#errors"}), "\n";
  print $cgi->b("Errors:"), "\n";

  print $cgi->start_ul();
  for my $e (@errors) {
    $e =~ s/\s*at \S+ line.*$//; # strip perl line number info.
    next if (! $e);
    print $cgi->li($e);
  }
  print $cgi->end_ul();
}

sub outputRwhois {
  my $querystr = shift;
  my $url      = shift;
  my $qr       = shift;

  my @results   = $qr->get_all_objects();
  my @referrals = $qr->get_all_referrals();
  my @errors    = $qr->get_rwhois_errors();

  outputHeader("RWhois Results");
  outputRwhoisHeading($querystr, $url, scalar @results, scalar @referrals,
                      scalar @errors);

  outputRwhoisRecords(@results);
  outputReferrals($querystr, @referrals);
  outputRwhoisErrors(@errors);
  outputFooter();
}

######################################
#  Whois HTML routines
######################################

sub outputWhoisHeading {
  my $querystr = shift;
  my $url      = shift;

  print $cgi->h1({-align => "center"}, "Whois Query Results"), "\n";
  print "Query: ", $cgi->b($querystr), " from ", $cgi->i($url), "\n";
  print $cgi->br(), "\n";
  print $cgi->hr(), "\n";
}

sub outputWhoisRecords {
  my @recs = @_;

  return if (! @recs);

  my $not_first = 0;

  for my $rec (@recs) {

    print $cgi->hr() if ($not_first);
    $not_first++;

    if ($rec->has_disclaimer()) {
      print $cgi->p($cgi->i
                    ($cgi->font({-size => "-1"},  "Disclaimer:"))), "\n";
      print $cgi->start_form();
      print $cgi->p
        ($cgi->pre
         ($cgi->textarea({-name => "disclaimer", -cols =>"75", -rows => "3",
                          -default => $rec->get_disclaimer()}))), "\n";

      print $cgi->end_form();
     }
    print $cgi->pre($rec->get_object()), "\n";
  }
}

sub outputWhois {
  my $querystr = shift;
  my $url      = shift;
  my $wqr      = shift;

  outputHeader("Whois Results");
  outputWhoisHeading($querystr, $url);
  outputWhoisRecords($wqr);
  outputFooter();
}

#################################
#  Main CGI
#################################

sub main_cgi {

  init();
  processCgiArgs();

  # outputTestInfo(); exit 0;

  my $proto    = $cgi->param('proto');
  my $url      = $cgi->param('url');
  my $querystr = $cgi->param('query');
  if (! $querystr) {
    outputErrorMessage("No Query", "There was no query specified");
    exit 0;
  }

  eval {

    if (lc $proto eq "whois") {
      my $wqr = queryWhois($querystr, $url);
      outputWhois($querystr, $url, $wqr);
    } else {
      my $host = $cgi->param('host');
      my $port = $cgi->param('port');
      my $rqr = queryRwhois($querystr, $host, $port);
      outputRwhois($querystr, $url, $rqr);
    }
  };
  if ($@) {
    outputErrorMessage("Query Error", $@);
    exit 0;
  }
}

sub outputTestInfo {
  outputHeader("Test Info");
  print "url = ", $cgi->url(), $cgi->br(), "\n";
  print "path_url = ", $cgi->url(-path => 1), $cgi->br(), "\n";
  print "relative_url = ", $cgi->url(-relative => 1), $cgi->br(), "\n";
  print "relative_path_url = ", $cgi->url(-relative => 1, -path => 1),
  $cgi->br(), "\n";
  print "absolute_url = ", $cgi->url(-absolute => 1), $cgi->br(), "\n";
  print "script_name = $script_name", $cgi->br(), "\n";
  outputFooter();
}

