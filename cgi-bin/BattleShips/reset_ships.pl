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
print "Signalling Impulser to re-init ships...<br>\n";
print "Hopefully dumped all of the ships logs too...<br>\n";
$cmd = "touch init_ships";
system $cmd;
while (-f "init_ships")
      {
      }
print "Ships should now be reset/refloated<br>\n";
print "<a href=\"/game_design/ship_status.html\">Ship Status Page</a><br>\n";


