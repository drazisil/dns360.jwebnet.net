# $Id: RwhoisObject.pm,v 1.13 2000/10/12 19:03:43 davidb Exp $

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

package Net::Rwhois::RwhoisObject;

=head1 NAME

Net::Rwhois::RwhoisObject - Object interface around a RWhois data object.

=head1 SYNOPSIS

  use Net::Rwhois::RwhoisObject;

  $obj = new Net::Rwhois::RwhoisObject;

  $obj->add_attributes(Name => "John Q. Public",
                       Email => "jqp@public.net");

  print $obj->to_string();

  @lines = $obj->to_lines();

=head1 DESCRIPTION

C<Net::Rwhois::RwhoisObject> provides an object-oriented interface
around the an RWhois data object.  It provides a number of methods for
creating and modifying the data in the object.  It does not, however,
contain any real knoweledge of the schema of the object it represents.
It also has no knowledge of the version of the protocol to which the
object belongs.

=head1 CONSTRUCTOR

=over 4

=item new( ARGS )

Creates a C<Net::Rwhois::RwhoisObject> object.  This method takes an
anonymous hash as its parameter, allowing for a number of
initialization scenarios.  The case of the hash keys is ignored.

=over 4

=item * Class

Sets the class attribute.

=item * ID

Sets the ID attribute.

=item * Auth-Area

Sets the Auth-Area attribute.

=back

=back

=head1 METHODS

=over 4

=item configure( ARGS )

takes the same arguments as the new() method, with the same results.

=item add_attribute(attribute_name, value, [type] )

Adds a single (attribute_name, value) pair to the object.  Does not
replace attributes.  If an attribute already exists, the method adds
another instance of the attribute.  The type is optional, and defaults
to text.  This is the equivalent of the ";I" type identifier in the
1.5 protocol response.

=item add_attributes( ARGS )

Takes arguments in the form of key-value pairs, where the key is an
attribute name, and adds them to the object.  Types for attributes can
be specified by supplying a key-value pair where the key is the
<attr-name>,type and the value is the type string (TEXT, ID, etc.).

=item replace_attribute(attribute_name, value, [type])

Replaces (or adds) a single (attribute_name, value) pair to the
object.  If the attribute already existed, all instances of the
attribute are replaced by this instance.

=item set_attribute_type(attribute_name, type)

Sets the type of an attribute (i.e., TEXT, ID, or SEE-ALSO, as per 1.5).

=item get_attribute(attribute_name)

returns a list of values associated with the attribute name.  It
returns a list in order to handle repeated attributes.

=item get_one_attribute(attribute_name)

returns a single attribute value (i.e., in scalar context).  It will
return only the first of a list of possibly repeated attributes.

=item get_attribute_type()

returns the type string of a given attribute.  For records that have
been retrieved from a pre-1.5 server, this will always be "TEXT", the
default.  Note that this isn\'t really a replacement for fetching and
understanding the schema.

=item get_attribute_names()

returns a list of attribute names.  Does not repeat attribute names,
even when an attribute is repeated.

=item get_class_name()

returns the name of the class that this object belongs to.

=item get_id()

returns the id of the object, if set.

=item get_auth_area()

returns the name of the authority area this object belongs to, if set.

=item to_lines()

converts the attributes to an array of lines, each of the form
"attribute:value".

=item to_string()

converts the attributes to a string containing newlines.  It returns
the string.

=item to_hash()

converts the attributes to a hash, with the attribute name as the key.
Repeatable attributes are stored in one key, with the values separated
by newlines.  It returns the hash reference.

=item register_add(connection, maintainer_email)

add the object to the rwhois server at the other end of the connection. UNIMPLEMENTED

=item register_mod(connection, maintainer_email, [ security info ])

modify the object on the server at the other end of the connection.
Note that this will fail if you have (incorrectly) modified the ID or
Updated attributes. UNIMPLEMENTED

=item register_del(connection, maintainer_email, [ security info ])

delete the object on the server at the other end of the connection.
Note that this will fail if you have (incorrectly) modified the ID or
Updated attributes. UNIMPLEMENTED

=back

=head1 SEE-ALSO

=over 4

=item L<Net::Rwhois>

=item L<Net::Rwhois::Connection>

=item L<Net::Rwhois::Query>

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
  my(%args) = @_;

  my $self = {};
  bless $self, $class;

  # set defaults
  $self->{'_attribute_names'} = ();

  $self->configure(\%args);

  $self;
}

sub configure {
  my $self = shift;
  my $args = shift;

  for (keys %$args) {
    /^class/i       and do {
      $self->_set_class_name($args->{$_});
      next;
    };
    /^auth-area/i   and do {
      $self->_set_auth_area($args->{$_});
      next;
    };
    /^id/i          and do {
      $self->_set_id($args->{$_});
      next;
    };
  }

  $self;
}


sub add_attribute {
  my $self = shift;
  my($attr, $value, $type) = @_;


  $attr = lc $attr;
  chomp $value;

  if ($value =~ /\n/) {
    carp "value cannot contain LFs";
    return 0;
  }

  if ($self->{$attr}) {
    $self->{$attr} .= "\n$value";
  }
  else {
    # new attribute
    $self->{$attr} = $value;
    push @{$self->{'_attribute_names'}}, $attr;
  }

  # store type component, if not text
  $self->set_attribute_type($attr, $type) if ($type);

  if ($attr eq "id") {
    $self->_set_id($value);
  }
  elsif ($attr eq "class-name" || $attr eq "object-type" ||
         $attr eq "schema-name") {
    $self->_set_class_name($value);
  }
  elsif ($attr eq "auth-area") {
    $self->_set_auth_area($value);
  }
}

sub add_attributes {
  my $self = shift;
  my %args = @_;

  for (keys %args) {
    if (/^(\S+),type/io) {
      $self->set_attribute_type($1, $args{$_})
    } else {
      $self->add_attribute($_, $args{$_});
    }
  }
}

sub replace_attribute {
  my $self = shift;
  my($attr, $value, $type) = @_;

  $attr = lc $attr;

  if (not $self->{$attr}) {
    push @{$self->{'_attribute_names'}}, $attr;
  }

  $self->{$attr} = $value;

  $self->set_attribute_type($attr, $type) if ($type);
}

sub set_attribute_type {
  my $self = shift;
  my $attr = shift;
  my $type = shift;

  my $code =  _translate_type_to_code($type);
  $self->{"$attr,type"} = $code if ($code);
}

sub get_attribute {
  my $self = shift;
  my $attr = shift;

  $attr = lc $attr;

  if (not $self->{$attr}) { return; }

  split /\n/, $self->{$attr};
}

sub get_one_attribute {
  my $self = shift;
  my $attr = shift;

  my @vals = $self->get_attribute($attr);

  if (@vals) {
    $vals[0];
  }
  else {
    0;
  }
}

sub get_attribute_type {
  my $self = shift;
  my $attr = shift;

  _translate_type_to_text($self->{"$attr,type"});
}

sub get_attribute_names {
  my $self = shift;

  @{$self->{'_attribute_names'}};
}

sub get_class_name {
  my $self = shift;

  $self->{'_class'};
}

sub get_id {
  my $self = shift;

  $self->{'_id'};
}

sub get_auth_area {
  my $self = shift;

  $self->('_auth_area');
}

sub to_lines {
  my $self = shift;

  my @lines;

  # right now, this is real basic, but we probably want to impose a
  # specific order.
  my @attr_names = $self->get_attribute_names();
  my @values;
  my $attr;

  for $attr (@attr_names) {
    @values = $self->get_attribute($attr);
    for (@values) {
      push(@lines, "$attr:$_");
    }
  }

  @lines;
}

sub to_string {
  my $self = shift;

  my @lines = $self->to_lines();
  my $string = join("\n", @lines);

  $string;
}

sub to_hash {
  my $self = shift;

  my %h;

  for ($self->get_attribute_names()) {
    $h{"$_"} = $self->{"$_"};
  }

  \%h;
}

sub register_add {
  my $self = shift;

}

##
## Private Methods
##

sub _set_class_name {
  my $self  = shift;
  my $value = shift;

  my $set_attr = 0;

  $self->{'_class'} = $value;
  if ($self->{'object-type'}) {
    $self->replace_attribute('object-type', $value);
    $set_attr++;
  }
  if ($self->{'schema-name'}) {
    $self->replace_attribute('schema-name', $value);
    $set_attr++;
  }
  if ($self->{'class-name'} || !$set_attr) {
    $self->replace_attribute('class-name', $value);
  }
}

sub _set_id {
  my $self  = shift;
  my $value = shift;

  $self->{'_id'} = $value;

  $self->replace_attribute('id', $value);
}

sub _set_auth_area {
  my $self  = shift;
  my $value = shift;

  $self->{'_auth-area'} = $value;

  $self->replace_attribute('auth-area',$value);
}

sub _translate_type_to_code {
  my $type_str = shift;

  if ($type_str =~ /^I/io) {
    return "I";
  } elsif ($type_str =~ /^S/io) {
    return "S";
  }

  "";
}

sub _translate_type_to_text {
  my $type = shift;

  if (not $type) { return "TEXT"; }

  if ($type =~ /^I/io) {
    return "ID";
  } elsif ($type =~ /^S/io) {
    return "SEE-ALSO";
  }

  "TEXT";
}


1;
