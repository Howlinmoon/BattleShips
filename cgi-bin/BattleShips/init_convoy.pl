#!/usr/bin/perl -w

#use strict;
use diagnostics;
use CGI;  # available from http://www.perl.com/CPAN/
use Mysql;

my $dbh = Mysql -> connect("localhost","test");
my $command = "";

# Create an instance of CGI
my $query = new CGI;

# Send an appropriate MIME header
print $query->header("text/html");

# Grab values from the form 
# Prints are for debug only

my $convoy_id = $query->param("convoy");
my $xy_spacing = $query->param("xy_spacing");
my $convoy_start = $query->param("convoy_start");
my $columns = $query->param("columns");
my $zig = $query->param("zig");
my $changes = $query->param("changes");
my $course = $query->param("course");

print "Convoy being re-initialized is $convoy_id<br>\n";
print "XY spacing will be $xy_spacing<br>\n";
print "Convoy's lead ship will start at $convoy_start<br>\n";
print "Convoy will consist of $columns columns. (Rows will be calculated)<br>\n";
print "Zig Interval is $zig<br>\n";
print "Number of course changes per cycle are $changes<br>\n";
print "starting course and zig offset is $course<br>\n";
print "this doesn't do anything yet...<br>\n";

if ($xy_spacing =~ /^(.\d*),(.\d*)/)
        {
        $x_spacing = $1;
        $y_spacing = $2;
        }
#print "X Spacing = $x_spacing and Y Spacing = $y_spacing.<br>\n";

if ($convoy_start =~ /^(.\d*),(.\d*)/)
   {
   $x_start = $1;
   $y_start = $2;
   }
#print "X Starting Spot is $x_start, and Y Starting Spot is $y_start.<br>\n";

if ($course =~ /^(.\d*),(.*)/)
        {
        $start_course = $1;
        $zig_offset = $2;
        }
#print "Starting Course is $start_course, Zig Offset is $zig_offset.<br>\n";
print "preparing to save convoy data to sql server<br>\n";

$command = "replace into convoy_master (convoy_id, x_spacing, y_spacing, x_start, y_start, num_columns, zig_interval, changes, start_course, zig_offset) values ($convoy_id, $x_spacing, $y_spacing, $x_start, $y_start, $columns, $zig, $changes, $start_course, $zig_offset)";
$sth = $dbh->query($command);
die "error with command $command" unless (defined $sth);
print "sql database updated<br>\n";
print "Changes will not take effect until ships are refloated.<br>\n";
#exit;
#open (CHANGE_SPEED,">init_convoy.$$");
#print CHANGE_SPEED "$convoy_id";
#close (CHANGE_SPEED);

#open (SEMAPHORE,">init_convoy");
#print SEMAPHORE "$$\n";
#close (SEMAPHORE);

#print "Signalling Impulser to Re-Initialize Convoy - waiting for ACK<br>\n";
#while (-f "init_convoy")
#{
#}
#print "Received ACK - Convoy Will be Re-Initialized.<br>\n";
print "Return to <a href=\"http://bigorc.com:4080/game_design/ship_status.html\">Ship Status Page</a><br>\n";
