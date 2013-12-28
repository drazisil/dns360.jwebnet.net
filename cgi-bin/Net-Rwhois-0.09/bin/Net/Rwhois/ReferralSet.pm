# $Id: ReferralSet.pm,v 1.2 2000/10/12 19:03:43 davidb Exp $

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

package Net::Rwhois::ReferralSet;

=head1 NAME

Net::Rwhois::ReferralSet - Object interface for logical groupings of
Rwhois referral responses.

=head1 SYNOPSIS

  use Net::Rwhois::Connection;
  use Net::Rwhois::Referral;
  use Net::Rwhois::ReferralSet;

  $r1 = new Net::Rwhois::Referral(URL =>
                                  'rwhois://root0.rwhois.net/auth-area=com');
  $r2 = new Net::Rwhois::Referral(URL =>
                                  'rwhois://root0.rwhois.net/auth-area=com');

  $r3 = new Net::Rwhois::Referral(URL =>
                             'rwhois://rwhois.arin.net/auth-area=0.0.0.0/0');

  $r4 = new Net::Rwhois::Referral(URL =>
                                'whois://www.networksolutions.com');

  $rs = new Net::Rwhois::ReferralSet($r1, $r2, $r3, $r4);

  # $r1, $r2, $r3, $r4
  my @all_referrals = $rs->get_all_referrals();
  # 'com', '0.0.0.0/0'
  my @auth_areas = $rs->get_all_auth_areas();
  # $r1 or $r2, $r3
  my @referrals = $rs->get_referrals();
  # $r1, $r2
  my @com_referrals = $rs->get_all_referrals('com');
  # also
  my @com_referrals = $rs->get_referrals('com');
  # $r1 or $r2
  my $referral = $rs->get_referral('com');

  # $r4
  my @ext_referrals = $rs->get_ext_referrals();

  # actual referral chasing algorithm.  Basically, for each referral
  # equivalency, attempt to follow the referral until one works.
  my $aa; my $r;
  foreach $aa ($rs->get_all_authority_areas()) {
    foreach $r ($rs->get_referrals($aa)) {
      my $c = new Net::Rwhois($r) || continue;
      my @res = $c->execute_query($query) || continue;
      break;
    }
    foreach $r ($rs->get_ext_referrals()) {
      if ($r->get_protocol() eq "whois") {
        # do whois query ...
      } else {
        # do other type of query
      }
  }


=head1 DESCRIPTION

C<Net::Rwhois::ReferralSet> represents as set of referrals organized
by authority area (which defines Rwhois referral equivalency).
Methods exists for retrieving entire sets or sets by authority area.

=head1 CONSTRUCTOR

=over 4

=item new ( list of C<Net::Rwhois::Referral> objects )

Contructs a new referral set, initializing it with the provided list
of referrals.

=back

=head1 METHODS

=over 4

=item configure ( list of C<Net::Rwhois::Referral> objects )

This has the same semantics as new();

=item add ( list of C<Net::Rwhois::Referral> objects )

Appends the list of referrals to the set.

=item get_all_authority_areas()

Returns a list of authority areas that have referrals in the set.
Referrals without authority areas (punt referrals) have authority area
of ".")

=item get_all_referrals ( [authority area] )

Returns all of the referral objects contained in the set.  If the
authority area is provided, it will return only the rwhois referrals
matching the authority area.

=item get_referrals ( [authority area] )

Returns a list of one referral object per authority area.  If the
authority area is provided, it will return all of the referrals for
that authority area.

=item get_ext_referrals()

Returns all referrals whose protocol was not "rwhois".

=item has_referrals()

True if the set contains any referrals (rwhois or otherwise)

=item has_rwhois_referrals()

True if the set contains any rwhois referrals.  This implies that
there are authority areas as well.

=item has_ext_referrals()

True if there are external (non-rwhois) referrals.

=back

=head1 SEE-ALSO

=over 4

=item L<Net::Rwhois>

=item L<Net::Rwhois::Referral>

=back

=cut

require 5.003;

use Carp;

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

  my $self = {};
  bless $self, $class;

  $self->configure(@_);

  $self;
}

sub configure {
  my $self = shift;

  # defaults
  $self->{'set'}           = {};
  $self->{'ext_referrals'} = [];
  $self->{'ext_count'}     = 0;
  $self->{'rwhois_count'}  = 0;

  $self->add(@_);
}

sub add {
  my $self = shift;

  for my $r (@_) {

    # print STDERR "Net::Rwhois::ReferralSet::add:  ", ref($r), "\n";
    next if (not ref($r) =~ /referral$/io);

    if ($r->get_protocol() ne "rwhois") {
      push @{$self->{'ext_referrals'}}, $r;
      $self->{'ext_count'}++;
      return;
    }

    my $aa = $r->get_authority_area() || ".";

    if (not $self->{'set'}->{$aa}) {
      $self->{'set'}->{$aa} = [];
    }
    push @{$self->{'set'}->{$aa}}, $r;
    $self->{'rwhois_count'}++;
  }
}

sub get_all_authority_areas {
  my $self = shift;

  sort keys(%{$self->{'set'}});
}

sub get_all_referrals {
  my $self = shift;
  my $aa = shift || undef;

  if ($aa) {
    return @{$self->{'set'}->{$aa}};
  } else {
    my @list;

    for $aa ($self->get_all_authority_areas()) {
      push @list, $self->get_all_referrals($aa);
    }
    push @list, $self->get_ext_referrals();
  }
}

sub get_referrals {
  my $self = shift;
  my $aa = shift || undef;

  if ($aa) {
    return @{$self->{'set'}->{$aa}};
  } else {
    my @list;

    for ($self->get_all_authority_areas()) {
      push @list, $self->{'set'}->{$aa}->[0];
    }
  }
}

sub get_ext_referrals {
  my $self = shift;

  @{$self->{'ext_referrals'}};
}

sub has_referrals {
  my $self = shift;

  ($self->{'rwhois_count'} + $self->{'ext_count'}) > 0;
}

sub has_rwhois_referrals {
  my $self = shift;

  $self->{'rwhois_count'} > 0;
}

sub has_ext_referrals {
  my $self = shift;

  $self->{'ext_count'} > 0;
}


1;
