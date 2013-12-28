# $Id: Client.pm,v 1.7 2000/10/12 19:03:43 davidb Exp $

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

package Net::Rwhois::Client;

=head1 NAME

Net::Rwhois::Client - Object interface for a Rwhois client instance;

=head1 SYNOPSIS

  use Net::Rwhois::Client;

  $client = new Net::Rwhois::Client(Host => "root.rwhois.net",
                                    Port => 4321);
  $connection = $client->get_connection();

  $connection->open();

  @aa_names = $client->get_authority_area_names();

=head1 DESCRIPTION

C<Net::Rwhois::Client> provides an object-oriented client interface to
an Rwhois server. It contains (has-a) a C<Net::Rwhois::Connection>
object, which manages the actual TCP (or UDP) connection to server.
This class provides some "pass-through" methods for directly
manipulating the connection object.

=head1 CONSTRUCTOR

=over 4

=item new ( [ARGS] )

Creates a C<Net::Rwhois::Client> object.  It takes arguments in
key-value pairs.  The valid arguments are "Connection" B<or> "Host"
and "Port" (case is ignored), where "Connection" is a reference to a
Net::Rwhois::Connection object, and "Host" and "Port" are the
arguments to the Net:Rwhois::Connection constructor.

=back

=head1 METHODS

=over 4

=item configure ( [ARGS] )

Takes the same arguments as the constructor, with the same logic.

=item get_authority_area_names ()

fetches (if necessary) the top level authority area information from
the Rwhois server, and returns a list of authority area names.

=item has_authority_area ( authority_area_name )

returns true (1) if the Rwhois server contains the authority area.

=item get_authority_area ( authority_area_name )

returns a L<Net::Rwhois::AuthorityArea> object corresponding with the
named authority area.  Note: currently not functional.

=back

=head1 SEE-ALSO

=over 4

=item L<Net::Rwhois>

=item L<Net::Rwhois::Connection>

=item L<Net::Rwhois::AuthorityArea>

=back

=cut

require 5.003;

use Carp;
use Net::Rwhois::Connection;

use strict;
use vars qw(@ISA $VERSION);

# use Exporter;
# @ISA       = qw( Exporter );
# @EXPORT_OK = qw();

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

  my $connection;
  my $host;
  my $port = "4321";

  my $key;

  for (keys %$args) {
    /^connection/i and do {
      if (ref($_) ne "Net::Rwhois::Connection") {
        croak "Connection parameter must be a Net::Rwhois::Connection object";
      }
      $connection = $args->{$_};
      next;
    };
    /^host/i       and do {
      $host = $args->{$_};
      next;
    };
    /^port/i       and do {
      $port = $args->{$_};
      next;
    };
  }

  # deal with erroneous usages
  croak "Either 'Connection' or 'Host' must be specified"
    if (not $connection and not $host);
  croak "Only one of 'Connection' or 'Host' should be specified"
    if ($connection and $host) ;

  if ($host) {
    $connection = new Net::Rwhois::Connection(Host => $host,
                                              Port => $port);
  }

  $self->{'connection'} = $connection;
}

sub load_authority_areas {
  my $self = shift;

  my $connection = $self->{'connection'};

  if ($connection->get_version() eq "1.0") {
    $self->_load_auth_areas_1_0();
  }
  elsif ($connection->get_version() eq "1.5") {
    $self->_load_auth_areas_1_5();
  }
  else {
    carp "load_authority_areas not implemented for ",
    $connection->get_version();
  }

}

sub get_authority_area_names {
  my $self = shift;

  my @name_list;
  my $aa_hr;

  for $aa_hr (@$self->{'auth_areas'}) {
    push @name_list, $aa_hr->{'name'} if $aa_hr->{'name'};
  }

  @name_list;
}

sub has_authority_area {
  my $self = shift;
  my $aa   = shift;

  my $a;

  for $a ($self->get_authority_area_names()) {
    if ($aa eq $a) {
      return 1;
    }
  }

  0;
}

sub get_authority_area {
  my $self = shift;
  my $aa_name = shift;

  my $aa_hr;

  for $aa_hr ($self->{'auth_areas'}) {
    if ($aa_hr->{'name'} eq $aa_name) {
      return $aa_hr;
    }
  }

  0;
}


##
## Private Methods
##

sub _load_auth_area_1_0 {
  my $self = shift;

}

sub _load_auth_area_1_5 {
  my $self = shift;

}

1;



