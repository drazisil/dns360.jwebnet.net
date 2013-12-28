# $Id: Query.pm,v 1.10 2000/10/12 19:03:43 davidb Exp $

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

package Net::Rwhois::Query;

=head1 NAME

Net::Rwhois::Query - Object interface for a Rwhois query.

=head1 SYNOPSIS

  use Net::Rwhois::Query;
  use Net::Rwhois::Connection;
  use Net::Rwhois::QueryResult;

  $c = new Net::Rwhois::Connection(Host  => "root.rwhois.net",
                                   Port  => 4321,
                                   Proto => 'tcp');

  $q = new Net::Rwhois::Query( Class => "domain",
                               Value => "netsol.com" );


  $r = $q->execute($c);

  $q->configure(Query_String => "domain rwhois.net");

  $r = $q->execute($c);

=head1 DESCRIPTION

C<Net::Rwhois::Query> provides an object-oriented interface to a
Rwhois query.  It is used to create and execute queries against an
Rwhois server connection (see L<Net::Rwhois::Connection>).

=head1 CONSTRUCTOR

=over 4

=item new ( [ARGS] )

Creates a C<Net::Rwhois::Query> object.  It takes arguments in
key-value pairs.  The valid arguments are "Query_String", or the set
of "Class", "Attribute" and "Value".  If the latter syntax is used,
only "Value" is required and the constructor will generate the query
string for you.  At least one of "Query_String" or "Value" must be
supplied, and if "Query_String" is used, the others are invalid.

=back

=head1 METHODS

=over 4

=item configure( [ARGS] )

Takes the same arguments as the constructor, with the same logic.

=item set_limit( limit )

Sets the result limit to 'limit'.  This will cause the B<execute> method to issue a "-limit" directive, if approprate.

=item execute( connection )

executes the loaded query against the rwhois server connected to in
the connection object.  'connection' must be an open
B<Net::Rwhois::Connection> object.

=back

=head1 SEE-ALSO

=over 4

=item L<Net::Rwhois>

=item L<Net::Rwhois::Connection>

=item L<Net::Rwhois::QueryResponse>

=back

=cut

require 5.003;

use Carp;
use Net::Rwhois::Connection;
use Net::Rwhois::QueryResult;

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
  $self->{'limit'}        = "";

  $self->configure(\%args);

  $self;
}

sub configure {
  my $self = shift;
  my $args = shift;

  my($query_string, $class_name, $attr, $value);
  my $key;

  for (keys %$args) {
    /^query_string/i       and do {
      $query_string = $args->{$_};
      next;
    };
    /^class/i       and do {
      $class_name = $args->{$_};
      next;
    };
    /^attr/i      and do {
      $attr = $args->{$_};
    };
    /^value/i     and do {
      $value = $args->{$_};
    };
    /^limit/i     and do {
      $self->set_limit($args->{$_});
    };
  }

  croak "Either 'Query_String' or ('Class', 'Attribute', 'Value') " .
    "may be specified" if ($query_string and ($class_name or $attr or $value));
  croak "Either 'Query_String' or 'Value' must be specified"
    if (not $query_string and not $value);

  if ($class_name or $attr or $value) {
    if ($attr) {
      $query_string = "$class_name $attr=$value";
    }
    else {
      $query_string = "$class_name $value";
    }
  }

  $self->{'query_string'} = $query_string;
}

sub set_limit {
  my $self = shift;
  my $limit = shift;

  $self->{'limit'} = $limit;
}

# Execute the query based on the server version type.
sub execute {
  my $self = shift;
  my $connection = shift;

  my $query_string = $self->{'query_string'};

  return 0 if (not $query_string);
  return 0 if (ref($connection) ne 'Net::Rwhois::Connection');

  my $version = $connection->get_version();
  my $result;

  if ($version == 1.0) {
    $result = $self->_execute_query_1_0($connection);
  }
  elsif ($version == 1.5) {
    $result = $self->_execute_query_1_5($connection);
  }

  $result;
}

##
## Private Methods
##

# do some basic query translations for using queries with 1.0 servers.
sub _get_query_1_0 {
  my $self = shift;

  my $raw_query_string = $self->{'query_string'};

  $raw_query_string = "dump " . $raw_query_string;

  $raw_query_string;
}

# do some basic query translations for using queries with 1.5 servers.
sub _get_query_1_5 {
  my $self = shift;

  my $raw_query_string = $self->{'query_string'};

  $raw_query_string =~ s/!/ID=/g;

  $raw_query_string;
}

# if necessary, set the query limit on the remote servers.  Note that
# there is no substantial difference between 1.0 and 1.5 servers for
# this.
sub _execute_query_set_limit {
  my $self = shift;
  my $connection = shift;

  if ($self->{'limit'}) {
    $connection->write_line("-limit $self->{'limit'}");
    my $res = $connection->read_line();

    if ($res ne "%ok") {
      carp "-limit failed";
      return 0;
    }
  }
  1;
}

# Execute the query against a v1.0 server.
sub _execute_query_1_0 {
  my $self = shift;
  my $connection = shift;

  $self->_execute_query_set_limit($connection);

  my $query_string = $self->_get_query_1_0();

  $connection->write_line($query_string);

  # QueryResult.pm will do its own version negotiation
  my $result = new Net::Rwhois::QueryResult($connection);

  $result;
}

# Execute the query against a v1.5 server.
sub _execute_query_1_5 {
  my $self = shift;
  my $connection = shift;

  $self->_execute_query_set_limit($connection);

  my $query_string = $self->_get_query_1_5();

  $connection->write_line($query_string);

  # QueryResult.pm will do its own version negotiation
  my $result = new Net::Rwhois::QueryResult($connection);

  $result;
}

1;
