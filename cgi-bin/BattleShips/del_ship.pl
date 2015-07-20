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

my $ship_ID = $query->param("ship_id");
print "Say Goodbye to Ship ID # $ship_ID\n<br>\n";
# prepare semaphore for instructing impulser about speed change.

open (DELETE,">delete_ship.$$");
print DELETE "$ship_ID\n";
close (DELETE);

open (SEMAPHORE,">delete_ship");
print SEMAPHORE "$$\n";
close (SEMAPHORE);

print "Signalling Impulser to sink your ship - waiting for ACK<br>\n";
while (-f "delete_ship")
{
}
print "Received ACK - Ship is GONE.<br>\n";
print "Return to <a href=\"http://bigorc.com/game_design/ship_status.html\">Ship Status Page</a><br>\n";
