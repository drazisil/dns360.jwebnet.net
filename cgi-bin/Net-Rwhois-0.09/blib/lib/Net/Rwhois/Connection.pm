# $Id: Connection.pm,v 1.13 2000/10/12 19:03:43 davidb Exp $

# Copyright (c) 1997-2000 Network Solutions, Inc.
# See the file LICENSE for conditions of use and distribution.

package Net::Rwhois::Connection;

=head1 NAME

Net::Rwhois::Connection - Object interface for a Rwhois server connection.

=head1 SYNOPSIS

  use Net::Rwhois::Connection;

  $c = new Net::Rwhois::Connection(Host  => "root.rwhois.net",
                                   Port  => 4321,
                                   Proto => 'tcp');
  $c->open();

  $version = $c->get_version();

  $c->write_line("-holdconnect on");

  ($response, $result) = $c->read_to_response();

=head1 DESCRIPTION

C<Net::Rwhois::Connection> provides an object-oriented interface to a
socket connection to an RWhois server.  It provides the base
functionalilty for communicating with an RWhois server.  It is not
normally used directly, except to create it.

=head1 CONSTRUCTOR

=over 4

=item new ( [ARGS] )

Creates a C<Net::Rwhois::Connection> object.  It takes arguments in
key-value pairs.  The valid arguments are "Host", "Port", and "Proto"
(case ignored). "Host" is required.  "Port" defaults to the IANA
assigned 4321, and "Proto" defaults to 'tcp'.

=back

=head1 METHODS

=over 4

=item configure ( [ARGS] )

Takes the same arguments as the constructor, with the same logic.

=item open ( [host, port] )

opens a connection to the server, and manages the banner and '-rwhois'
directive manipulation. The host and port parameters are optional and
will reset the internally held values.

=item get_version()

returns the version of the server (e.g., "1.0", "1.5", etc.).

=item read_line()

reads a single line from the socket.  Returns the line.

=item read_to_response()

reads lines until it gets a terminating response (%ok or %error).  It
returns a list of lines, beginning with the response line.  It ignores
blank lines.

=item write_line( args )

writes a line consisting of 'args' to the socket, terminating it
correctly.  'args' should not have any terminator characters (CR or
LF).

=item close()

closes the socket.

=item is_open()

returns true of the socket connection is open.

=item get_host()

returns the current value of 'host', the value used to create the
socket connection in the B<open> method.

=item get_port()

returns the current value of 'port'.

=item set_host()

sets the 'host' value.

=item set_port()

sets the 'port' value.

=item set_client_version()

sets the client implementation info sent in the initial '-rwhois'
directive.

=item set_debug()

sets debug-mode on or off.

=item get_debug()

returns true if the connection is in debug-mode.

=back

=head1 SEE-ALSO

=over 4

=item L<Net::Rwhois>

=back

=cut

require 5.003;


use Carp;
use IO::Socket;
use IO::Handle;

use Net::Rwhois::Referral;

use strict;
use vars qw(@ISA $VERSION);

# use Exporter;
# @ISA       = qw( Exporter );
# @EXPORT_OK = qw();


sub new {
  my $this = shift;
  my $class = ref($this) || $this;
  my %args = @_;

  my $self  = {};
  bless $self, $class;

  # defaults
  $self->{'port'}           = 4321;
  $self->{'proto'}          = 'tcp';
  $self->{'server_version'} = "";
  $self->{'client_version'} = "Perl API 0.05";
  $self->{'debug_mode'}     = 0;
  $self->{'_is_open'}       = 0;

  $self->configure(\%args);

  $self;
}

sub configure {
  my $self = shift;
  my $args = shift;

  my $key;

  for (keys %$args) {
    /^host/i       and do {
      $self->{'host'} = $args->{$_};
      next;
    };
    /^port/i       and do {
      $self->{'port'} = $args->{$_};
      next;
    };
    /^proto/i      and do {
      $self->{'proto'} = $args->{$_};
      next;
    };
    /^referral/i   and do {
      my $r = $args->{$_};

      $self->{'host'} = $r->get_host();
      $self->{'port'} = $r->get_port();
      next;
    };
    /^debug/i      and do {
      $self->{'debug_mode'} = $args->{$_};
      next;
    };
  }

  # deal with erroneous usages
  croak "'Proto' is either 'tcp' or 'udp'"
    if (not $self->{'proto'} =~ /^(tcp|udp)/i);
}

sub open {
  my $self  = shift;
  my $host  = shift || $self->{'host'};
  my $port  = shift || $self->{'port'};
  my $proto = shift || $self->{'proto'};

  $self->{host} = $host;
  $self->{port} = $port;
  $self->{proto} = $proto;

  my $banner;
  my $version;

  $self->{'sock'} = IO::Socket::INET->new(PeerAddr => $host,
                                          PeerPort => $port,
                                          Proto    => $proto);

  if (not $self->{'sock'}) {
    carp "Could not open socket to '$host:$port': $!";
    return;
  }

  $self->{'sock'}->autoflush();
  $self->{'_is_open'} = 1;

  # rwhois servers should start out with a banner statement
  $banner = $self->read_line();

  carp "Rwhois server did not issue '%RWhois' banner" if (not $banner);

  $version = $self->_parse_banner($banner);

  if ($version eq "1.5") {
    $self->_rwhois_1_5_directive();
  }
  else { # version 1.0
    $self->_rwhois_1_0_directive();
  }
}

sub get_version {
  my($self) = shift;

  $self->{'server_version'};
}


sub read_line {
  my($self) = shift;

  my $line = $self->{'sock'}->getline();

  # if we actually read 0 bytes, we get to assume that there is
  # something horribly wrong with the socket.
  if (length $line == 0) {
    $self->close();
    return undef;
  }

  $line =~ s/\n$//o;
  $line =~ s/\r$//o;

  if ($self->get_debug()) {
    print STDERR "S: ", $line, "\n";
  }

  $line;
}

sub read_to_response {
  my $self = shift;

  my @result_lines;
  my $line = "";

  while (1) {
    $line = $self->read_line();
    last if $line =~ /^%(ok|error)/;
    last if (! $self->is_open());
    next if $line =~ /^\s*$/;
    push @result_lines, $line;
  }

  # put the result on the front;
  unshift @result_lines, $line;

  @result_lines;
}

sub write_line {
  my($self) = shift;
  my(@args) = @_;

  if ($self->get_debug()) {
    print STDERR "C: ", @args, "\n";
  }
  $self->{'sock'}->print(@args, "\r\n");
}

sub close {
  my($self) = shift;

  $self->{'sock'}->close();
  $self->{'_is_open'} = 0;
}

sub is_open {
  my($self) = shift;

  if ($self->{'_is_open'} && (! getpeername($self->{'sock'}))) {
    $self->close();
  }
  $self->{'_is_open'};
}

sub get_host {
  my($self) = shift;

  $self->{'host'};
}

sub get_port {
  my($self) = shift;

  $self->{'port'};
}

sub set_host {
  my($self) = shift;
  my($host) = shift;

  $self->{'host'} = $host;
}

sub set_port {
  my($self) = shift;
  my($port) = shift;

  $self->{'port'} = $port;
}

sub set_client_version {
  my($self) = shift;
  my($version_string) = shift;

  $self->{client_version} = $version_string;
}

sub set_debug {
  my $self = shift;
  my $val = shift;

  $self->{'debug_mode'} = $val;
}

sub get_debug {
  my $self = shift;

  $self->{'debug_mode'};
}

##
## Private Methods/ Functions
##

sub _parse_banner {
  my $self = shift;
  my $banner = shift;

  my $version;

  if ($banner =~ /^%rwhois\s+V-([\d,.]+)/io) {
    $version = $1;
    # FIXME: this should handle the 1.5 version list!
  }
  else {
    # broken banner string, so assume 1.0
    $version = "1.0";
  }

  $self->{'server_version'} = $version;

  $version;
}

sub _rwhois_1_0_directive {
  my $self = shift;

  my $resp;

  $self->write_line("-RWhois V-1.0 [$self->{'client_version'}]");

  ($resp) = $self->read_to_response();

  carp "server failed on -RWhois directive: $resp" if ($resp ne "%ok");

  1;
}

sub _rwhois_1_5_directive {
  my $self = shift;

  my $banner;
  my $resp;
  $self->write_line("-rwhois V-1.5 ($self->{'client_version'})");

  ($resp, $banner) = $self->read_to_response();

  carp "server failed on -rwhois directive: '$resp'" if ($resp ne "%ok");

  if ($banner) {
    $self->_parse_banner($banner);
  }

  1;
}


1;

