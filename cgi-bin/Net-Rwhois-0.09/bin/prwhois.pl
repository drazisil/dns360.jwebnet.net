#!/usr/local/bin/perl -w

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

# command line perl rwhois/whois client.

require 5.003;

use FindBin qw{$Bin};
use lib "$Bin/../lib";

use Getopt::Std;

use Net::Rwhois;
use Net::Rwhois::ResultSet;
use Net::Rwhois::Connection;
use Net::Rwhois::Query;
use Net::Rwhois::QueryResult;
use Net::Rwhois::Referral;
use Net::Rwhois::ReferralSet;
use Net::Rwhois::RwhoisObject;
use Net::Rwhois::WhoisQuery;
use Net::Rwhois::WhoisResult;

use IO::Socket;

use strict;

my %config = (
              'server' => "root.rwhois.net:4321",
              'recurse' => 0,
              'query' => ''
             );

sub usage {
  print STDERR <<EOF;
usage: $0 [-r] [-h host:port] <query>
  -r: recursively follow queries
  -h: use specific host/port
EOF
  exit(64);
}

sub process_opts {
  my %opts;
  getopts('rh:', \%opts) || usage();

  if ($opts{'r'}) {
    $config{'recurse'} = 1;
  }
  if ($opts{'h'}) {
    $config{'server'} = $opts{'h'};
  }
  if (@ARGV) {
    $config{'query'} = join(' ', @ARGV);
  }
}

sub print_config {
  print <<EOF;
server:         $config{'server'}
recurse:        $config{'recurse'}
query:          $config{'query'}
EOF
}

sub sepHostPort {
  my $server = shift;
  split /:/, $server;
}


sub rwhois_query {
  my $query = shift;
  my $host = shift;
  my $port = shift || 4321;
  my $recurse = shift;

  my $rs;

  if (! $query) {
    print STDERR "null query\n";
  }
  my $client = new Net::Rwhois(Host => $host, Port => $port);
#  $client->set_debug(1);

  if ($recurse) {
    $rs = $client->recursive_execute_query(Query_String => $query);
  } else {
    $rs = $client->execute_query(Query_String => $query);
  }
  $rs;
}

sub follow_whois_ref {
  my $ref = shift;
  my $query = shift;

  my $wq = new Net::Rwhois::WhoisQuery(URL => $ref->get_url(),
                                       Query => $query);
  my $res = $wq->execute();

  $res->get_object();
}

sub get_other_results {
  my $rs = shift;
  my $query = shift;

  my @ext_refs = $rs->get_referrals();
  my @results;

  for my $r (@ext_refs) {
    my $proto = $r->get_protocol();
    next if ($proto eq "rwhois"); # should be any of these...

    if ($proto eq "whois") {
      my $whois_resp = follow_whois_ref($r, $query);
      push @results, $whois_resp if (defined $whois_resp);
    } else {
      print STDERR "Unknown protocol: $proto\n";
    }
  }

  @results;
}


sub print_rwhois_object {
  my $ro = shift;

  return if (not ref($ro) =~ /RwhoisObject$/io);

  my @attr_names = $ro->get_attribute_names();
  my @values;
  my $attr;

  foreach $attr (@attr_names) {
    @values = $ro->get_attribute($attr);
    for (@values) {
      printf("%-20s%s\n", $attr . ":", $_);
    }
  }
}
sub print_rwhois_results {

  return if (scalar @_ < 1);

  print "RWhois results:\n\n";

  for my $obj (@_) {
    if (ref($obj) =~/RwhoisObject/io) {
      print_rwhois_object($obj);
      print "\n\n";
    } elsif (ref($obj) =~ /ReferralSet$/io) {
      print "Referrals:\n";
      for ($obj->get_all_referrals()) {
        print "$obj\n";
      }
    } else {
      print "Unknown Object: $obj\n";
    }
  }
}

sub print_other_results {

  return if (scalar @_ < 1);

  print "Other results:\n\n";

  my $o;
  for $o (@_) {
    next if (ref($o) =~/RwhoisObject/io);

    print $o, "\n";
  }
}
sub main {

  process_opts(@ARGV);
  print_config();

  my $rs = rwhois_query($config{query},
                        sepHostPort($config{server}),
                        $config{recurse});

  print_rwhois_results($rs->get_objects());
  my @o_res = get_other_results($rs, $config{query});
  print_other_results(@o_res);
}

main();
