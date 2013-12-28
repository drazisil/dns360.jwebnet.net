# $Id: Rwhois.pm,v 1.11 2000/10/12 21:55:27 davidb Exp $

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

package Net::Rwhois;

=head1 NAME

Net::Rwhois -- Object-oriented Rwhois 1.0/1.5 client interface.

=head1 SYNOPSIS
  use Net::Rwhois;
  use Net::Rwhois::ResultSet;

  # do a simple, one level rwhois query

  my $client = new Net::Rwhois(Host  => "root.rwhois.net",
                               Port  => 4321);
  # execute_query will open the connection if necessary
  my @results = $client->execute_query(Query_String => "domain netsol.com");

  $client->close();

  # do a recursive query; $result set is a Net::Rwhois::ResultSet;

  my $result_set = $client->recursive_execute_query(Query_String =>
                                                    "network 216.168.0.0/19");

  @results = $result_set->get_objects();
  # the referrals should be referrals that use other protocols than
  # rwhois.
  my @referrals = $result_set->get_referrals();


  # more manually manipulate the client connection.

  $client->open();

  $client->write_line("-holdconnect on");

  ($response, $result) = $client->read_to_response();

  @results = $client->execute_query(Class => "domain",
                                    Value => "netsol.com");

  ($response, $result) = $client->read_to_response();

=head1 DESCRIPTION

C<Net::Rwhois> provides an object-oriented RWhois client API.  It is
mostly a wrapper around the subobjects that form the complete API.
The intention of this interface is to produce a simpler, useful API.

=head1 CONSTRUCTOR

=over 4

=item new( ARGS )

Creates a C<Net::Rwhois> object.  It takes arguments in key-value
pairs.  The valid arguments are "Host", "Port", and "Proto" (case
ignored). "Host" is required.  "Port" defaults to the IANA assigned
4321, and "Proto" defaults to 'tcp'.  These arguments are simply
passed on the the contained C<Net::Rwhois::Connection> object.

=back

=head1 METHODS

=over 4

=item configure ( ARGS )

Takes the same arguments as the constructor, with the same logic.

=item execute_query( ARGS )

executes a query against the server currently pointed to by the client
object (initially set via the constructor), and returns a
C<Net::Rwhois::ResultSet>, which contains
C<Net::Rwhois::RwhoisObject>s and C<Net::Rwhois::Referral>s.  The
method takes arguments in key-value pairs, like
C<Net::Rwhois::Query::new>.  The tags recognized area "Query_String",
"Class_Name", "Attribute", "Value", and "Limit".  This query form will
not follow any of the referrals.  It will open the held connection
object if it is not already open.  If the method opens the connection,
it will also close it.

=item recursive_execute_query( ARGS )

executes a query against the server currently pointed to by the client
object (like execute_query above), and returns a
C<Net::Rwhois::ResultSet>. It will attempt to recursively follow
rwhois referrals, creating new connections as necessary.  It will not
follow non-rwhois referrals (it does not presume to know how) instead
just leaving the referrals in the ResultSet.  This method will start
with the held connection object, opening it if necessary.  It will
create new connections as needed to follow the referrals.

=item results_to_string( @results )

translates the list of RwhoisObjects to a single string, using the
same behavior as C<Net::Rwhois::RwhoisObject::to_string>.

=back

=head1 PASS-THROUGH METHODS

This class contains methods that are simply wrappers around the methods of the contained (has-a) objects.

=over 4

=item Net::Rwhois::Connection Methods

  open
  is_open
  close
  get_version
  read_line
  read_to_response
  write_line

=back

=head1 SEE-ALSO

=over 4

=item L<Net::Rwhois::Connection>

=item L<Net::Rwhois::Client>

=item L<Net::Rwhois::Query>

=item L<Net::Rwhois::QueryResult>

=item L<Net::Rwhois::RwhoisObject>

=back

=cut

require 5.003;

use Carp;
use Net::Rwhois::ResultSet;
use Net::Rwhois::Connection;
use Net::Rwhois::Client;
use Net::Rwhois::Query;
use Net::Rwhois::QueryResult;
use Net::Rwhois::RwhoisObject;
use Net::Rwhois::ReferralSet;

use strict;
use vars qw($VERSION);

$VERSION = "0.09";

sub new {
  my $this = shift;
  my $class = ref($this) || $this;
  my %args = @_;

  my $self = {};
  bless $self, $class;

  # set defaults
  $self->configure(\%args);

  $self;
}

sub configure {
  my $self = shift;
  my $args = shift;

  $self->{'connection'} = new Net::Rwhois::Connection(%$args);
}

sub execute_query {
  my $self = shift;
  my %args = @_;

  my $opened = 0;

  my $connection;
  if ($args{'new_connection'}) {
    $connection = new Net::Rwhois::Connection(%args);
  } else {
    $connection = $self->{'connection'};
  }

  if (! $connection->is_open()) {
    $connection->open() || return undef;
    $opened++;
  }

  my $query = new Net::Rwhois::Query(%args);

  my $query_result = $query->execute($connection);

  $query_result->read_results();

  my $result_set = new Net::Rwhois::ResultSet($query_result);

  ### print "execute_query: returning ", ref($result_set),"\n";
  if ($opened) {
    $connection->close();
  }

  $result_set;
}

sub recursive_execute_query {
  my $self = shift;
  my %args = @_;

  my $opened = 0;

  my $connection;
  if ($args{'new_connection'}) {
    $connection = new Net::Rwhois::Connection(%args);
  } else {
    $connection = $self->{'connection'};
  }

  if (! $connection->is_open()) {
    $connection->open() || return undef;
    $opened++;
  }

  my $query = new Net::Rwhois::Query(%args);
  my $query_result = $query->execute($connection);

  $query_result->read_results();

  my $result_set = new Net::Rwhois::ResultSet();

  $result_set->add($query_result->get_all_objects());

  my $referral_set
    = new Net::Rwhois::ReferralSet($query_result->get_all_referrals());

  if ($opened) {
    $connection->close();
  }

  # return immediately if there are no referrals, or only external
  # referrals.
  if (! $referral_set->has_rwhois_referrals()) {
    $result_set->add($referral_set->get_ext_referrals());
    ### print "returning $result_set";
    return $result_set;
  }

  # otherwise, recurse.

  $self->{'recurse_server_list'} = {};

  my $server_list = $self->{'recurse_server_list'};

  my $aa; # authority area iterator
  my $r;  # referral iterator

 aa_loop:
  foreach $aa ($referral_set->get_all_authority_areas()) {

    my @rrs = $referral_set->get_referrals($aa);
    # print "referrals for $aa (", scalar @rrs, ") : ", ref(@rrs), "\n";
    # try each referral in the equiv. class until I get a success;
    foreach $r ($referral_set->get_referrals($aa)) {
      next if (! defined $r);
      my $rhost = lc $r->get_host();
      my $rport = $r->get_port() || 4321;
      my $rserver = "$rhost:$rport";

      # next equiv. class if we've visited this server before.
      if ($server_list->{$rserver}) {
        next aa_loop;
      }

      my $local_result_set;

      # recurse, catching execptions
      eval {
        # this converts non-fatal errors into catchable errors.
        local $SIG{__WARN__} = sub { die $_[0] };
        # reset the arguments to connect to the next host with a new
        # connection.
        $args{'Host'} = $rhost;
        $args{'Port'} = $rport;
        $args{'new_connection'} = 1;
        # and actually return the objects.
        $local_result_set = $self->recursive_execute_query(%args);
      };
      # if there was an error...
      if ($@) {
        print STDERR "referral chase failed for '$rserver': $!\n";
        next;
      }

      # add the successful referral chase to our list.

      $server_list->{$rserver} = 1;

      $result_set->add($local_result_set);
      next aa_loop;
    }
  }

  $result_set->add($referral_set->get_ext_referrals());

  $result_set;
}

##
## Net::Rwhois::Connection Pass-Through Methdods
##

sub open {
  my $self = shift;

  $self->{'connection'}->open();
}

sub is_open {
  my $self = shift;

  $self->{'connection'}->is_open();
}

sub close {
  my $self = shift;

  $self->{'connection'}->close();
}

sub get_server_version {
  my $self = shift;


  $self->{'connection'}->get_version();
}

sub read_line {
  my $self = shift;

  $self->{'connection'}->read_line();
}


sub read_to_response {
  my $self = shift;

  $self->{'connection'}->read_to_response()
}

sub write_line {
  my $self = shift;
  my $line = shift;

  $self->{'connection'}->write_line($line);
}

sub set_debug {
  my $self = shift;
  my $val = shift;

  $self->{'connection'}->set_debug($val);
}

##
## Net::Rwhois::RwhoisObject Pass-Through Methods
##

sub results_to_string {
  my $self = shift;
  my @results = @_;
  my $obj;

  my $string = "";
  my $r;

  for $obj (@results) {
    $r = $obj->to_string();
    $string .= $r;
    $string .= "\n";
  }

  $string;
}



1;
