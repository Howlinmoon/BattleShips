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

my $speed = $query->param("speed");
my $convoy_id = $query->param("convoy");
print "Parameters are speed = $speed, Convoy id = $convoy_id\n<br>\n";
# prepare semaphore for instructing impulser about speed change.

open (CHANGE_SPEED,">convoy_speed.$$");
print CHANGE_SPEED "$convoy_id:$speed\n";
close (CHANGE_SPEED);

open (SEMAPHORE,">convoy_speed");
print SEMAPHORE "$$\n";
close (SEMAPHORE);

print "Signalling Impulser about speed change - waiting for ACK<br>\n";
while (-f "convoy_speed")
{
}
print "Received ACK - Convoy has new speed orders.<br>\n";
print "Return to <a href=\"http://bigorc.com:4080/game_design/ship_status.html\">Ship Status Page</a><br>\n";
