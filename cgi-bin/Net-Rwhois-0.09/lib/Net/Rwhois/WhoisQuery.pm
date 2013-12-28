# $Id: WhoisQuery.pm,v 1.2 2000/10/12 19:03:44 davidb Exp $

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

package Net::Rwhois::WhoisQuery;

=head1 NAME

Net::Rwhois::WhoisQuery - Object interface for a WHOIS query,
primarily used for following whois referrals from RWhois servers.

=head1 SYNOPSIS

use Net::Rwhois::WhoisQuery;
use Net::Rwhois::WhoisResult;
my $wc = new Net::Rwhois::WhoisQuery
                (URL => "whois://whois.networksolutions.com",
                 Query => "domain example.com");

my $result = $wc->execute();

print $result->get_disclaimer();
print $result->get_separator();
print $result->get_object();

=head1 DESCRIPTION

C<Net::Rwhois::Query> provides an object-oriented interface to
performing WHOIS lookups.  The querying mechanism is not intended to
be a universal WHOIS client package, and, since WHOIS is a largely
non-standardized protocol and response format, it is not guaranteed to
work correctly against all available whois servers.

=head1 CONSTRUCTOR

=over 4

=item new ( [ARGS] )

Creates a C<Net::Rwhois::WhoisQuery> object.  It takes arguments in key-value pairs.  The key values are:

=over 4

=item URL

A "whois" url.  It is an error to provide a non whois url to the
constructor.  This can be used instead of the 'Host' and 'Port'
options.

=item Host

The WHOIS server hostname.

=item Port

The port of the WHOIS server, defaults to 43.

=item Query

The WHOIS query.

=back

=back

=head1 METHODS

=over 4

=item configure( [ARGS] )

Takes the same arguments as the constructor.

=item execute()

Attempts to connect to the WHOIS server and retrieve the results.  Returns a C<Net::Rwhois::WhoisResult> object.

=item set_url( URL )

Sets the URL pointing to the whois serrver to query.  This overrides
host and port designations.

=item set_host( host )

Set the hostname of the whois server.

=item set_port( port )

Sets the port number of the whois service, in case it is being run on an odd port.

=item set_query( query )

Sets the query.

=back

=head1 SEE-ALSO

=over 4

=item L<Net::Rwhois::WhoisResult>

=cut

require 5.003;

use Carp;

use IO::Socket;

use Net::Rwhois::WhoisResult;

use strict;

use vars qw(@ISA $VERSION);

# use Exporter;
# @ISA = qw( Exporter );
# @EXPORT_OK = qw();


# global variables
 my $query_regex
  = "^\\s*(domain|host|contact|network|server)?\\s*([^=]+\\s*=)?\\s*(\\S+)\\s*";
my @keyword_ok_servers = ('networksolutions.com', 'internic.net');

sub new {
  my $this = shift;
  my $class = ref($this) || $this;
  my %args = @_;

  # set defaults
  my $self = {
              'url'  => undef,
              'host' => undef,
              'port' => 43,
              'query' => undef,
             };

  bless $self, $class;

  $self->configure(\%args);

  $self;
}

sub configure {
  my $self = shift;
  my $args = shift;

  my $val;

  for (keys %$args) {
    $val = $args->{$_};

    /^url/io and do {
      $self->set_url($val);
      next;
    };

    /^host/io and do {
      $self->set_host($val);
      next;
    };

    /^port/io and do {
      $self->set_port($val);
      next;
    };

    /^query/io and do {
      $self->set_query($val);
      next;
    };
  }
}


sub set_url {
  my $self = shift;
  my $url = shift;

  return if (not $url);

  my $host; my $port;
  if ($url =~ m|^whois://([a-z0-9.-]+)(:(\d+))?|io) {
    $self->set_host($1);
    $self->set_port($3) if ($3);
    $self->{'url'} = $url;
  } else {
    warn "url '$url' is invalid";
  }
}

sub set_host {
  my $self = shift;
  $self->{'host'} = shift;
}

sub set_port {
  my $self = shift;
  $self->{'port'} = shift;
}

sub set_query {
  my $self = shift;
  $self->{'query'} = shift;
}

sub execute {
  my $self = shift;

  my $host = $self->{'host'};
  my $port = $self->{'port'} || 43;

  return if (!$self->{'query'} || !$host);

  # modify query to account (somewhat) for query language differences
  # among the various WHOIS servers.
  $self->_correct_query();


  # open a connection to the WHOIS server.
  my $wc = new IO::Socket::INET( PeerAddr => $host,
                                 PeerPort => $port,
                                 Proto    => 'tcp' )
    || croak "could not open connection to '$host:$port': $!";

  $wc->autoflush(1);

  $wc->print($self->{'query'}, "\r\n");

  my $resp = new Net::Rwhois::WhoisResult(Connection => $wc,
                                          Host => $host,
                                          Port => $port);

  $resp;
}

### Private Methods

# note: not a method.
sub _no_keyword_server {
  my $server_host = shift;
  my $k;

  for $k (@keyword_ok_servers) {
    if ($server_host =~ /$k$/i) {
      return 0;
    }
  }

  1;
}

sub _correct_query {
  my $self = shift;

  return if (!$self->{'query'} || !$self->{'host'});

  # use a regular expression to break down the maximal query type:
  #  keyword attribute=value
  my ($keyword, $attribute, $value);
  if ($self->{'query'} =~ m|$query_regex|i) {
    $keyword = $1; $attribute = $2, $value = $3;
  } else {
    die "query does not match query regex";
  }

  if (_no_keyword_server($self->{'host'})) {
    $self->set_query($value);
  }
}
