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
my $tf = $query->param("tf");
print "Parameters are speed = $change_speed, Task Force id = $tf\n<br>\n";
# prepare semaphore for instructing impulser about speed change.

open (CHANGE_SPEED,">tf_speed.$$");
print CHANGE_SPEED "$tf:$change_speed\n";
close (CHANGE_SPEED);

open (SEMAPHORE,">tf_speed");
print SEMAPHORE "$$\n";
close (SEMAPHORE);

print "Signalling Impulser about speed change - waiting for ACK<br>\n";
while (-f "tf_speed")
{
}
print "Received ACK - Task Force is now in process of assuming new speed<br>\n";
print "Return to <a href=\"http://bigorc.com:4080/game_design/ship_status.html\">Ship Status Page</a><br>\n";
