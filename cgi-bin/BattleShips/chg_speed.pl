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

my $change_speed = $query->param("change_speed");
my $ship_ID = $query->param("ship_id");
my $start_x = $query->param("ship_x");
my $start_y = $query->param("ship_y");
print "Parameters are speed = $change_speed, ship id = $ship_ID X=$start_x Y=$start_y\n<br>\n";
# prepare semaphore for instructing impulser about speed change.

open (CHANGE_SPEED,">ship_speed.$$");
print CHANGE_SPEED "$change_speed\n";
close (CHANGE_SPEED);

open (CHANGE_SPEED_SHIP,">target_ship.$$");
print CHANGE_SPEED_SHIP "$ship_ID\n";
close (CHANGE_SPEED_SHIP);

open (SEMAPHORE,">modify_speed");
print SEMAPHORE "$$\n";
close (SEMAPHORE);

print "Signalling Impulser about speed change - waiting for ACK<br>\n";
while (-f "modify_speed")
{
}
print "Received ACK - ship is now in process of assuming new speed<br>\n";
print "Return to <a href=\"http://bigorc.com:4080/game_design/ship_status.html\">Ship Status Page</a><br>\n";
