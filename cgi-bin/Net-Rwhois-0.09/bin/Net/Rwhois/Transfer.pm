# $Id: Transfer.pm,v 1.2 2000/10/12 19:03:43 davidb Exp $

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

package Net::Rwhois::Transfer;

=head1 NAME

Net::Rwhois::Transfer - Object interface for an RWhois transfer
('-xfer') command.

=head1 SYNOPSIS


=head1 DESCRIPTION

C<Net::Rwhois::Transfer> provices an object-oriented interface to an
Rwhois transfer request.  It is used to create and execute transfer
requests against an Rwhois server connection
(L<Net::Rwhois::Connection>).

=head1 CONSTRUCTOR

=over 4

=item new( [ARGS] )

Creates a C<Net::Rwhois::Transfer> object.  It taks arguments in
key-value paris.  The valid arguments are

=over 4

=item * Query

A fully formed -xfer-style query.  Note that these have a different
format from the main RWhois query for RWhois 1.0 and 1.5.

=item * Class

The name of a class to transfer.

=item * Authority-Area

The name of the authority area to transfer.

=item * Attributes

A reference to a list of restricted attribute names.

=back

=back

=head1 METHODS

=over 4

=item configure( [ARGS] )

takes the same arguements as the constructor, with the same results.

=item set_class( class )

sets the class to transfer.  A null value means to transfer all
classes.

=item set_authority_area( auth-area )

sets the authority area to transfer.  This must not be null.

=item add_attribute_list( @list )

add the list of attributes in the list to the end of the restricted attribute list.

=item remove_all_attributes()

clear the restricted attribute list.

=item execute( connection )

Send the transfer request and returns a C<Net::Rwhois::TransferResult>
object.

=back

=head1 SEE-ALSO

=over 4

=item

=back

=cut

require 5.003;

use Carp;
use Net::Rwhois::Connection;
use Net::Rwhois::TransferResult;

use strict;
use vars qw(@ISA $VERSION);

# use Exporter;
# @ISA       = qw( Exporter );
# @EXPORT_OK = qw();

##
## Public Methods
##
sub new {
  my $this = shift;
  my $class = ref($this) || $this;
  my %args = @_;

  my $self = {};
  bless $self, $class;

  # defaults
  $self->{'class'}     = "";
  $self->{'auth_area'} = "";
  $self->{'attr_list'} = [];
  $self->{'query'}     = "";

  $self->configure(\%args);

  $self;
}

sub configure {
  my $self = shift;
  my $args = shift;

  for (keys %$args) {
    /^query/io         and do {
      $self->{'query'} = $args->{$_};
      next;
    };
    /^class/io         and do {
      $self->{'class'} = $args->{$_};
      next;
    };
    /^auth.*area/io    and do {
      $self->{'auth_area'} = $args->{$_};
      next;
    }
  }
}


sub set_class {
  my $self = shift;

  $self->{'class'} = $_;
}

sub set_auth_area {
  my $self = shift;

  $self->{'auth_area'} = $_;
}

sub add_attribute_list {
  my $self = shift;

  push @{$self->{'attr_list'}}, @_;
}

sub remove_all_attributes {
  my $self = shift;

  $self->{'attr_list'} = [];
}

sub execute {
  my $self = shift;
  my $conn = shift;

  my $result;

  croak "parameter to execute must be a Net::Rwhois::Connection object"
    if (ref $conn ne "Net::Rwhois::Connection");

  croak "connection must already be open" if (not $conn->is_open());

  if ($conn->get_version() eq "1.5") {
    $result = $self->_execute1_5($conn);
  }
  elsif ($conn->get_version() eq "1.0") {
    $result = $self->_execute1_0($conn);
  }

  $result;
}


##
## Private/Static Methods
##

sub _execute1_0 {
  my $self = shift;

  if (not $self->{'query'}) {
    $self->{'query'} = $self->_build_query1_0();
  }

}

sub _execute1_5 {
  my $self = shift;

  if (not $self->{'query'}) {
    $self->{'query'} = $self->_build_query1_5();
  }

}

sub _build_query1_0 {
  my $self = shift;

  my $query = "-xfer";

  if ($self->{'class'}) {
    $query .= " $self->{'class'}";
  }

}

sub _build_query1_5 {
  my $self = shift;

  my $query  = "-xfer";

  if (! $self->{'auth_area'}) {
    carp "xfer directive requires an authority area";
  }

  $query .= " $self->{'auth_area'}";

  if ($self->{'class'}) {
    $query .= " class=$self->{'class'}";
  }

  if (scalar @{$self->{'attr_list'}} > 0) {
    $query .= " attributes=";
    $query .= shift @{$self->{'attr_list'}};

    for @{$self->{'attr_list'}} {
      $query .=",$_";
    }
  }

  $query;
}
