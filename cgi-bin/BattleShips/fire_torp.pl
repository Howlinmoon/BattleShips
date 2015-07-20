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

my $torp_course = $query->param("torp_course");
my $ship_ID = $query->param("ship_id");
my $start_x = $query->param("ship_x");
my $start_y = $query->param("ship_y");
print "Torpedo Course = $torp_course, ship id = $ship_ID X=$start_x Y=$start_y\n<br>\n";
# prepare semaphore for instructing impulser about speed change.

open (CHANGE_SPEED,">fire_torp.$$");
print CHANGE_SPEED "$torp_course:$ship_ID\n";
close (CHANGE_SPEED);

open (FIRE_TORP,">fire_torp");
print FIRE_TORP "$$\n";
close (FIRE_TORP);
print "Signalling Impulser about torp firing - waiting for ACK<br>\n";
while (-f "fire_torp")
{
}
print "Received ACK - Torp is away!<br>\n";
print "Return to <a href=\"http://bigorc.com:4080/game_design/ship_status.html\">Ship Status Page</a><br>\n";
