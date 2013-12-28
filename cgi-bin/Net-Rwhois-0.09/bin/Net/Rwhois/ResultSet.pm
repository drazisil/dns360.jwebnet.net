# $Id: ResultSet.pm,v 1.2 2000/10/12 19:03:43 davidb Exp $

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

package Net::Rwhois::ResultSet;

require 5.003;

sub new {
  my $this = shift;
  my $class = ref($this) || $this;
  my @args = @_;

  my $self = {};
  bless $self, $class;

  $self->{'objects'} = [];
  $self->{'referrals'} = [];

  $self->add(@_) if (@_);
  $self;
}

sub add {
  my $self = shift;
  my $item;

  foreach $item (@_) {

    my $type = ref($item);

    if ( $type =~ /RwhoisObject$/io ) {
      push @{$self->{'objects'}}, $item;
    } elsif ( $type =~ /Referral$/io) {
      push @{$self->{'referrals'}}, $item;
    } elsif ( $type =~ /ResultSet$/io ) {
      $self->add($item->get_objects());
      $self->add($item->get_referrals());
    } elsif ( $type =~ /QueryResult$/io ) {
      $self->add($item->get_all_objects());
      $self->add($item->get_all_referrals());
    } else {
      print STDERR "Net::Rwhois::Result::add() -- unknown type '$type'\n";
    }
  }
}

sub get_objects {
  my $self = shift;
  @{$self->{'objects'}};
}

sub get_referrals {
  my $self = shift;
  @{$self->{'referrals'}};
}
