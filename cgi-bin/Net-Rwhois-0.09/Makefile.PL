# $Id: Makefile.PL,v 1.3 1997/05/06 20:47:18 davidb Exp $

# Check for required modules.  This stolen from libwww.
$| = 1;
my $missing_modules = 0;

# Not sure what version of IO::Socket I should be checking for.
print "Checking for IO::Socket.";
eval {
    require IO::Socket;
    IO::Socket->require_version('1.15');
};
if ($@) {
    print " failed\n";
    $missing_modules++;
print <<EOT;
$@
The IO::Socket module is used by Net::Rwhois::Connection

EOT
    sleep(2);  # Don't hurry too much
} else {
    print "  ok\n";
}

print <<EOT if $missing_modules;
The missing modules can be obtained from CPAN.  Visit
<URL:http://www.perl.com/CPAN/> to find a CPAN site near you.

EOT

use ExtUtils::MakeMaker;

WriteMakefile(
	      'NAME' => "Net::Rwhois",
              'VERSION_FROM' => "lib/Net/Rwhois.pm",
	      'dist' => { COMPRESS => 'gzip', SUFFIX => 'gz' },
	     );
