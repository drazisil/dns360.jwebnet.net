#!/usr/local/bin/perl

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

# This is a sample CGI script acting as a RWhois client.  It relies on
# the standard perl5 module CGI as well as the Net::Rwhois package.
# It requires Net::Rwhois to be greater than or equal to version 0.04.

# usage:
#  This CGI script accepts the following parameters:
#    url: a rwhois or whois URL.
#    host: the server name of the rwhois/whois server.
#    port: the port of the rwhois/whois server.
#    proto: either 'rwhois' or 'whois'.
#    query: the query string.
#    overrideurl: flag specifying that the 'host' and 'port'
#      parameters should be favored over the 'url' parameter if both
#      are specified.

require 5.004;

# allow for the Net::RWhois package to be installed the the cgi-bin
# directory.
use FindBin qw($Bin);
use lib "$Bin";

use CGI;

use Net::Rwhois;
use Net::Rwhois::WhoisQuery;
use Net::Rwhois::WhoisResult;

use strict;

use vars qw($default_host $default_port $source_page $cgi_query $script_name);

$cgi_query = new CGI;

$script_name = $cgi_query->url();
# have to strip out the http://hostname part
$script_name =~ s|http://[^/]+||io;

$default_host = "172.25.28.33";  # drteeth
$default_port = 4321;
$source_page = "/rwhois/prwhois2.html";

# Query the referral server, recursively following RWhois referrals.
sub referralquery {
  my $query_string = shift;
  my $host  = shift || $default_host;
  my $port  = shift || $default_port;

  my $client = new Net::Rwhois( Host => $host,
                                Port => $port);

  my $result_set = $client->recursive_execute_query(Query_String =>
                                                    $query_string);

  my @results;

  for my $r ($result_set->get_referrals()) {
    if ($r->get_protocol() eq "whois") {
      push @results, whoisquery($query_string, $r);
    }
  }

  @results;
}

# given a whois referral, follow it and return the WhoisResult object.
sub whoisquery {
  my $query_string = shift;
  my $referral = shift;

  my $wc = new Net::Rwhois::WhoisQuery(URL => $referral->get_url(),
                                       Query => $query_string);
  my $wr = $wc->execute();

  $wr;
}


sub format_header {
  print $cgi_query->header();
  print $cgi_query->start_html(-title => "Registry Rwhois Referral Results",
                               -bgcolor => "white",
                               background => "/images/bluestripebg.gif"), "\n";
}

sub format_footer {
  $cgi_query->end_html();
}

sub format_navbar_open {
  # print the table, standard nav bar, and main logo.
  print <<EOF;
<table border="0" align="left" halign="0">
  <tr>
    <td width="135">&nbsp;</td>
    <td><img src="/images/mainlogo.gif" border="0"
            alt="Rwhois on the Web" width="235" height="110"></td>
  </tr>
  <tr>
    <td align=left valign=top width="135">
      <a href="/rwhois/index.html"><img name="Home" border="0"
      src="/images/homelabel.gif" width="120" height="20"></a><br><br>
      <a href="/rwhois/about.html"><img name="about" border="0"
      src="/images/about.gif" width="120" height="20"></a><br><br>
      <a href="/rwhois/download/index.html"><img name="Downloads"
      border="0" src="/images/downlabel.gif" width="120" height="20"
      alt="DownLoads"></a><br><br>
      <a href="/rwhois/docs/index.html"><img name="Documentation"
      border="0" src="/images/doclabel.gif" width="120" height="20"
      alt="Documentation"></a><br><br>
      <a href="/rwhois/lists/index.html"><img name="MailingLists"
      border="0" src="/images/listlabel.gif" width="120" height="20"
      alt="Mailing Lists"></a><br><br>
      <a href="/rwhois/contacts.html"><img name="Contacts" border="0"
      src="/images/contactlabel.gif" width="120" height="20"
      alt="Contacts"></a>

   </td>
EOF
}

sub format_navbar_close {
  # print the closing bit
  print <<EOF;
  </tr>
</table>
EOF
}

sub format_back_link {
  my $src = $source_page;

  if ($cgi_query->referer()) {
    $src = $cgi_query->referer();
  }

  print '     <p>Back to the <a href="', $src, '">form</a>.</p>', "\n";
}

sub format_single_whoisresult {
  my $result = shift;

  return if (not ref($result) =~ /Net::Rwhois::WhoisResult/io);

  # Results from:
  my $host = $result->get_host();
  my $port = $result->get_port();

  if ($host) {
    my $source = $host;
    if ($port != 43) { $source .= ":$port"; }

    print '      <p>Results From: ', $source, '</p>', "\n";
  }

  if ($result->has_disclaimer()) {
    print '      <p><i><font size="-1">Disclaimer:</font></i></p>', "\n";
    print '      <p>', "\n";
    print '      <form method="post" action="">', "\n";
    print '        <pre><textarea name="disclaimer" cols="75" rows="3">', "\n";
    print $result->get_disclaimer();
    print '        </textarea></pre>', "\n";
    print '      </form>', "\n";
    print '      </p>', "\n";
  }

  # print the result itself
  print '      <pre>', "\n";
  print $result->get_object();
  print '      </pre>', "\n";
}

sub format_results {
  my @results = @_;


  # first open the cell
  print '    <td valign="top">', "\n";

  # print the title
  print '      <p><b>Registry Referral Server Results</b></p>', "\n";

  # for each response, print the response (if we can)

  my $first = 1;
  for my $res (@results) {
    if (! $first) {
      print '      <hr>', "\n";
    }
    if (ref($res) =~ /Net::Rwhois::WhoisResult/io) {
      format_single_whoisresult($res);
    } else {
      print '      <p>Unknown object type: ', ref($res), '</p>', "\n";
    }
  }

  format_back_link();
  # close the cell
  print '    </td>', "\n";
}

sub format_no_results {
  # first open the cell
  print '    <td valign="top">', "\n";

  # print the title
  print '      <p><b>Registry Referral Server Results</b></p>', "\n";

  # print the message
  print '         <p>No Results Found.</p>';

  format_back_link();
  # close the cell
  print '    </td>', "\n";
}

sub format_error {
  my $error = shift;


  # first open the cell
  print '    <td valign="top">', "\n";

  # print the title
  print '      <p><b>Registry Referral Error</b></p>', "\n";

  # print the error message
  print '       <p>', $error, '</p>', "\n";

  format_back_link();

  # close the cell
  print '    </td>', "\n";
}

# Main CGI

sub main_cgi {
  my $query = $cgi_query->param('query');

  if (! $query){
    exit(0);
  }

  my $overrideurl = $cgi_query->param('overrideurl');

  # prefer URLs first, then separate host, port params, unless override url
  my $url = $cgi_query->param('url');
  my $host = $cgi_query->param('host');
  my $port = $cgi_query->param('port');

  if ($url and !($overrideurl and $host)) {
    my $r = new Net::Rwhois::Referral(Url => $url);

    $host = $r->get_host();
    $port = $r->get_port();
    $cgi_query->param('host', $host);
    $cgi_query->param('port', $port);
  } else {
    $cgi_query->param('url', "rwhois://$host:$port");
  }

  my @results = referralquery($query, $cgi_query->param('host'),
                              $cgi_query->param('port'));

  format_header();
  format_navbar_open();

  if (scalar @results > 0) {
    format_results(@results);
  } else {
    format_no_results();
  }

  format_navbar_close();
  format_footer();
}

if (scalar @ARGV > 0) {
  $cgi_query = new CGI(*STDIN);

  main_cgi();
  print "\n";
} else{
  main_cgi();
}
