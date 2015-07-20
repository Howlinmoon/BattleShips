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

my $change_depth = $query->param("change_depth");
my $ship_ID = $query->param("ship_id");
my $start_x = $query->param("ship_x");
my $start_y = $query->param("ship_y");
print "Parameters are speed = $change_depth, ship id = $ship_ID X=$start_x Y=$start_y\n<br>\n";
# prepare semaphore for instructing impulser about speed change.

open (CHANGE_SPEED,">ship_depth.$$");
print CHANGE_SPEED "$change_depth\n";
close (CHANGE_SPEED);

open (CHANGE_SPEED_SHIP,">target_ship.$$");
print CHANGE_SPEED_SHIP "$ship_ID\n";
close (CHANGE_SPEED_SHIP);

open (SEMAPHORE,">modify_depth");
print SEMAPHORE "$$\n";
close (SEMAPHORE);

print "Signalling Impulser about depth change - waiting for ACK<br>\n";
while (-f "modify_depth")
{
}
print "Received ACK - ship is now in process of assuming new depth<br>\n";
print "Return to <a href=\"http://bigorc.com:4080/game_design/ship_status.html\">Ship Status Page</a><br>\n";
