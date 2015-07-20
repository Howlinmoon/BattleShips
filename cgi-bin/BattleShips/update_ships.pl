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
print "Signalling Impulser to update the add ship page...<br>\n";
$cmd = "touch update_new_ships";
system $cmd;
while (-f "update_new_ships")
      {
      }
print "Ship List should now be updated<br>\n";
print "<a href=\"/game_design/ship_status.html\">Ship Status Page</a><br>\n";
print "<a href=\"/game_design/add_test_ship2.html\">New Add Ship Page</a><br>\n";


