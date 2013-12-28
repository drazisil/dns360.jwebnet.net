# $Id: QueryResult.pm,v 1.12 2000/10/12 19:03:43 davidb Exp $

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

package Net::Rwhois::QueryResult;

=head1 NAME

Net::Rwhois::QueryResult - Object interface for the result of a RWhois
query action.  This class acutally handles reading the results from
the server.

=head1 SYNOPSIS

  use Net::Rwhois::Connection;
  use Net::Rwhois::Query;
  use Net::Rwhois::QueryResult;

  $c = new Net::Rwhois::Connection(Host  => "root.rwhois.net",
                                   Port  => 4321,
                                   Proto => 'tcp');

  $q = new Net::Rwhois::Query( Class => "domain",
                               Value => "netsol.com" );


  $r = $q->execute($c);

  # reuse the New::Rwhois::Query object by resetting the query string.
  $q->configure(Query_String => "domain rwhois.net");

  $r = $q->execute($c);

  # $r is a Net::Rwhois::QueryResult object
  $r->read_results();

=head1 DESCRIPTION

C<Net::Rwhois::QueryResult> provides an object-oriented interface
around the result of an Rwhois query action. It provides methods
around retrieving the actual results from the server and either
returning a list of C<Net::Rwhois::RwhoisObject> instances, or providing
an internal iterator.

=head1 CONSTRUCTOR

=over 4

=item new (connection)

Creates a C<Net::Rwhois::QueryResult> object.  It takes an open C<Net::Rwhois::Connection> object as an argument.

=back

=head1 METHODS

=over 4

=item configure(connection)

Takes the same arguments as the constructor, with the same logic.

=item read_results()

retrieves all of the results from the server and stores them internally.

=item has_more_objects()

returns true if the internal iterator has not exhausted the list of
result objects.

=item get_current_object()

returns the current (as per the internal iterator) object.

=item next_object()

advances the internal iterator.

=item set_to_first()

resets the internal iterator back to the beginning of the list.

=item get_all_objects()

returns a list of C<Net::Rwhois::RwhoisObject>s.

=item has_more_referrals()

returns true if the internal referral iterator has not been exhausted.

=item get_current_referral()

returns the current (as per the internal referral iterator) referral.

=item next_referral()

advances the internal referral iterator.

=item get_all_referrals()

returns an array of C<Net::Rwhois::Referral>s.

=item get_rwhois_errors()

Returns a list of error code strings returned by the RWhois server.
Generally, the protocol states that only one error can be returned,
but, on the off chance that the server is incorrectly implemented or
the rules changes, this returns a list.

=item parse_rwhois_object(@lines)

given an array of "dump" format-style lines, return the associated
RWhois object.

=item parse_rwhois_referral(line)

given a referral line, return the assocated Referral object.

=back

=head1 SEE-ALSO

=over 4

=item L<Net::Rwhois>

=item L<Net::Rwhois::Connection>

=item L<Net::Rwhois::Query>

=item L<Net::Rwhois::RwhoisObject>

=back

=cut

require 5.003;

use Carp;
use Net::Rwhois::Connection;
use Net::Rwhois::RwhoisObject;

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
  my @args = @_;

  my $self = {};
  bless $self, $class;

  # defaults
  $self->{'result'}       = []; # array of response hashes
  $self->{'current'}      = 0;  # index into result array
  $self->{'referrals'}    = []; # array of referral objects
  $self->{'errors'}       = []; # array of error strings
  $self->{'cur_referral'} = 0;  # index into referral array

  $self->configure(@args);

  $self;
}

sub configure {
  my $self = shift;
  my @args = @_;

  my $connection = $args[0];

  if (ref($connection) ne "Net::Rwhois::Connection") {
    croak "Connection parameter must be a Net::Rwhois::Connection object";
  }

  $self->{'connection'} = $connection;
  $self->{'version'}    = $connection->get_version();
}


sub read_results {
  my $self = shift;

  my $connection = $self->{'connection'};
  my $line = "";
  my @lines;
  my $obj;
  my $ref;

  while (1) {

    $line = $connection->read_line();

    if ($line =~ /^\s*$|^%/o) {

      if (scalar @lines > 0) {
        # we have reached the end of the record
        $obj = $self->parse_rwhois_object(@lines);

        my $version = $self->{'version'};
        my @vals;
        if ($version eq "1.0"
         && scalar(@vals = $obj->get_attribute('referral')) > 0) {
          foreach (@vals) {
            if (/^\s*([^:]+):(\d+):rwhois\s*$/) {
              $ref = new Net::Rwhois::Referral(Host => $1, Port => $2);
              push @{$self->{'referrals'}}, $ref;
            }
          }
        } else {
          push @{$self->{'result'}}, $obj;
        }
        undef @lines;
      }

      # line is a referral indication.
      if ($line =~ /^%referral/io) {
        $ref = $self->parse_rwhois_referral($line);

        push @{$self->{'referrals'}}, $ref;
        next;
      }

      if ($line =~ /^%error\s+(\d+\s*.*)$/io) {
        push @{$self->{'errors'}}, $1;
        last;
      }

      # we've hit the termination condition
      last if $line =~ /^%(ok|err)/io;

      # the socket has closed on us
      last if (! $connection->is_open());

      # it is a stray blank line
      next;
    }

    push @lines, $line;
  }

  if (scalar @lines > 0) {
    carp "rrv says you can't get here";
  }

  scalar @{$self->{'result'}};
}

sub has_more_objects {
  my $self = shift;

  if ($self->{'current'} >= scalar @$self->{'result'}) {
    return 0;
  }

  1;
}

sub get_current_object {
  my $self = shift;
  my $current = $self->{'current'};

  $self->{'result'}[$current];
}

sub next_object {
  my $self = shift;

  $self->{'current'}++;
}

sub set_to_first {
  my $self = shift;

  $self->{'current'} = 0;
}


sub get_all_objects {
  my $self = shift;

  @{$self->{'result'}};
}

sub has_more_referrals {
  my $self = shift;

  if ($self->{'cur_referral'} >= scalar @$self->{'referrals'}) {
    return 0;
  }

  1;
}

sub get_current_referral {
  my $self = shift;
  my $current = $self->{'cur_referral'};

  $self->{'referrals'}[$current];
}

sub next_referral {
  my $self = shift;

  $self->{'cur_referral'}++;
}

sub set_to_first_referral {
  my $self = shift;

  $self->{'cur_referral'} = 0;
}

sub get_all_referrals {
  my $self = shift;

  @{$self->{'referrals'}};
}

sub get_rwhois_errors {
  my $self = shift;

  @{$self->{'errors'}};
}

sub parse_rwhois_object {
  my $self    = shift;
  my @lines   = @_;

  my $version = $self->{'version'};

  if ($version eq "1.0") {
    $self->_parse_object_1_0(@lines);
  }
  elsif ($version eq "1.5") {
    $self->_parse_object_1_5(@lines);
  }
}

sub parse_rwhois_referral {
  my $self = shift;
  my $line = shift;

  my $ref = ();
  my $version = $self->{'version'};

  if ($line =~ /^%referral/io) {
    if ($version eq "1.0") {
      if ($line =~ /^%referral\s+([^:]+):(\d+):rwhois\s*$/io) {
        $ref = new Net::Rwhois::Referral(Host => $1, Port => $2);
      }
    } else {
      $ref = new Net::Rwhois::Referral(Line => $line);
    }
  }
  else {
    carp "line '$line' must begin with '%referral'";
  }

  $ref;
}

##
## Private Methods/ Static Functions
##

sub _parse_line_1_0 {
  my $line = shift;

  $line =~ /^[^:]+:([^:]+):(.*)$/o;

  ($1, $2);
}

sub _parse_line_1_5 {
  my $line = shift;

  my($attr, $value, $type);

  $line =~ /^[^:]+:([^:]+):(.*)$/o;

  $attr = $1; $value = $2; $type = "";

  if ($attr =~ s/^([^;]+);(.*)$/$1/) {
    $type = $2;
  }

  ($attr, $value, $type);
}

sub _parse_object_1_0 {
  my $self  = shift;
  my @lines = @_;
  my $obj = new Net::Rwhois::RwhoisObject();

  my($line, $attr, $value);

  for $line (@lines) {
    last if $line =~ /^\s*$/o;

    ($attr, $value) = _parse_line_1_0($line);

    $obj->add_attribute($attr, $value);
  }

  $obj;
}

sub _parse_object_1_5 {
  my $self  = shift;
  my @lines = @_;
  my $obj = new Net::Rwhois::RwhoisObject();

  my($line, $attr, $value, $type);

  for $line (@lines) {
    last if $line =~ /^\s*$/o;

    ($attr, $value, $type) = _parse_line_1_5($line);

    $obj->add_attribute($attr, $value, $type);
  }

  $obj;
}

1;
