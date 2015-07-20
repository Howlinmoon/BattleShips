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

my $ship_id = $query->param("ship");

# Request Impulser update the sql server
print "Requesting the Impulser to update the sql db<br>\n";
$cmd = "touch update_db";
system $cmd;
while ( -f "update_db")
      {
      }
print "Received ack<br>\n";
my $dbh = Mysql -> connect("localhost","test");

$waypoints = 0;
my $command = "";
        $command = "select waypoints from how_many_waypoints where ship_id = $ship_id";
        my $sth=$dbh-> query($command);
        die "Error with command $command\n" unless (defined $sth);
        my @arr=();
        while (@arr = $sth->fetchrow)
        {
        ($waypoints) = @arr;
        }
print "Ship $ship_id has $waypoints waypoints on file<br>\n";
if ($waypoints == 0)
   {
   print "HEY! QUIT WASTING MY TIME!<br>\n";
   exit;
   }
print "If the waypoint count is BLINKING on the status page - waypoint following is PAUSED<br>\n";
print "Click <a href=\"/cgi-bin/game_design/toggle_waypoint?ship=$ship_id\">HERE</a> To Toggle<br>\n";
for ($xx = 1; $xx <= $waypoints; $xx++)
    {
    $command = "select waypoint from waypoint_master where ship = $ship_id and waypoint_num = $xx";
    $sth=$dbh-> query($command);
    die "Error with command $command\n" unless (defined $sth);
    @arr=();
    while (@arr = $sth->fetchrow)
          {
          ($waypoint) = @arr;
          }
    print "Waypoint #$xx is $waypoint (x,y, depth, speed)<br>\n";
    }
exit;
