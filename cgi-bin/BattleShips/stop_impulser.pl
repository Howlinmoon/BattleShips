#!/usr/bin/perl -w

#use strict;
use diagnostics;
use CGI;  # available from http://www.perl.com/CPAN/
use Mysql;

# Create an instance of CGI
my $query = new CGI;

# Send an appropriate MIME header
print $query->header("text/html");
# Grab values from the form 
# Prints are for debug only
if ( -f "stopped")
   {
   print "Impulser not running already!<br>\n";
   exit;
   }
$cmd = "touch stop_update";
system $cmd;
print "ordered impulser to stop running...<br>";
while (! -f "stopped")
{
}
print "impulser now stopped.<br>";
exit;

