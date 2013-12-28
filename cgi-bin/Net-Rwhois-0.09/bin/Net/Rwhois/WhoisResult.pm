# $Id: WhoisResult.pm,v 1.2 2000/10/12 19:03:44 davidb Exp $

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

package Net::Rwhois::WhoisResult;

=head1 NAME

Net::Rwhois::WhoisResult - Object interface for the results of a WHOIS query.

=head1 SYNOPSIS

  use Net::Rwhois::WhoisQuery;
  use Net::Rwhois::WhoisResult;

  my $wq = new Net::Rwhois::WhoisQuery( Host => "whois.networksolutions.com",
                                        Query => "example.com" );
  my $wr = $wq->execute();

  print $wr->get_disclamer() if $wr->has_disclaimer();

  print $wr->get_object() if $rw->has_object();


=head1 DESCRIPTION

C<Net::Rwhois::WhoisResult> is the object interface the results of a
WHOIS query.  This result set is primarily designed for returning a
single object as multiple object responses tend to have very little
informationabout the objects themselves.  However, due to the
non-standardization of WHOIS, multi-object responses may be
interpreted as a single object response.

Note that this package does not make an attempt to parse the various
WHOIS responses.

=head1 CONSTRUCTOR

=over 4

=item new( whois_socket_connection )

This object is designed to be created by the
C<Net::Rwhois::WhoisQuery> object.

=back

=head1 METHODS

=over 4

=item has_disclaimer()

Returns a true value if a disclaimer was parsed out of the response.
Note that disclaimers are not (yet) standardized.

=item get_disclaimer()

Returns a string containing the disclaimer.

=item get_separator()

Returns the string value that was used to separate the disclaimer from
the object.

=item has_object()

Return a true value if a result was detected.

=item get_object()

Returns a string containing the WHOIS result, or undef if there was not one.

=back

=head1 SEE-ALSO

C<Net::Rwhois::WhoisQuery>

=cut

require 5.003;

use Carp;
use IO::Socket;

use strict;

use vars qw(@ISA $VERSION);

# use Exporter;
# @ISA = qw( Exporter );
# @EXPORT_OK = qw();


sub new {
  my $this = shift;
  my $class = ref($this) || $this;
  my %args = @_;

  # defaults
  my $self = {
              'connection' => undef,
              'host'       => undef,
              'port'       => 43,

              'fetched'    => 0,

              'disclaimer' => undef,
              'separator'  => undef,
              'object'     => undef
             };

  bless $self, $class;

  $self->configure(\%args);

  if (not ref($self->{'connection'}) =~ /^IO::Socket::INET/io) {
    croak "Net::Rwhois::WhoisResult::new called without valid constructor argument";
  } elsif  (not $self->{'connection'}->opened()) {
    croak "Net::Rwhois::WhoisResult::new called with the constructor argument in the wrong state";
  }
  $self;
}

sub configure {
  my $self = shift;
  my $args = shift;

  my $val;
  for (keys %$args) {
    $val = $args->{$_};

    /^connection/io and do {
      $self->{'connection'} = $val;
      next;
    };

    /^host/io and do {
      $self->{'host'} = $val;
      next;
    };

    /^port/io and do {
      $self->{'port'} = $val;
      next;
    };
  }
}

sub get_disclaimer {
  my $self = shift;

  $self->fetch();

  $self->{'disclaimer'};
}

sub has_disclaimer {
  my $self = shift;

  return 1 if ($self->get_disclaimer());

  0;
}

sub get_separator {
  my $self = shift;

  $self->fetch();

  $self->{'separator'};
}

sub has_sepatrator {
  my $self = shift;

  return 1 if ($self->get_separator());

  0;
}

sub get_object {
  my $self = shift;

  $self->fetch();

  $self->{'object'};
}

sub has_object {
  my $self = shift;

  return 1 if ($self->get_object());

  0;
}

sub get_host {
  my $self = shift;
  $self->{'host'};
}

sub get_port {
  my $self = shift;
  $self->{'port'};
}

sub fetch {
  my $self = shift;

  return if ($self->{'fetched'});

  my $c = $self->{'connection'};

  return if (!$c || !$c->opened());

  my $object = 0;
  $self->clear();

  while (<$c>) {
    # strip line endings
    s/\n$//;
    s/\r$//;

    last if (/Database last updated/io);

    # Right now, only know about the Registrant: separator.
    if (/^\s*Registrant:/io) {
      $object = 1;
      $self->{'separator'} = $_;
    } elsif ($object) {
      $self->{'object'} .= $_ . "\n";
    } else {
      $self->{'disclaimer'} .= $_ . "\n";
    }
  }

  # if there was no separator, then there was no disclaimer, only the
  # result.
  if (not $object) {
    $self->{'object'} = $self->{'disclaimer'};
    $self->{'disclaimer'} = undef;
  }

  $c->close();

  $self->{'fetched'} = 1;
}

sub clear {
  my $self = shift;

  $self->{'separator'}  = undef;
  $self->{'disclaimer'} = undef;
  $self->{'object'}     = undef;
}
