#!/usr/bin/perl -w

#use strict;
use diagnostics;
use CGI;  # available from http://www.perl.com/CPAN/
# Create an instance of CGI
my $query = new CGI;

# Send an appropriate MIME header
print $query->header("text/html");

# Grab values from the form 
# Prints are for debug only

my $tf = $query->param("tf");

print "Signalling Impulser now to dump Task Force $tf's waypoints.<br>\n";
# prepare semaphore for instructing impulser about speed change.

open (CHANGE_SPEED,">dump_tf_waypoints");
print CHANGE_SPEED "$tf\n";
close (CHANGE_SPEED);

while (-f "dump_tf_waypoints")
{
}
print "Received ACK - They are GONE!<br>\n";
print "Return to <a href=\"http://bigorc.com:4080/game_design/ship_status.html\">Ship Status Page</a><br>\n";
