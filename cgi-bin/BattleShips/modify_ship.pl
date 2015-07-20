#!/usr/bin/perl -w
$pi = 3.14159265358979323846;

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
if (-f "stopped")
   {
   print "Impulser is shut down - try later<br>\n";
   exit;
   }
my $ship_ID = $query->param("ship");
#print "Waiting on Impulser to update SQL Server....<br>\n";
#order impulser to save data to sql server and wait till it has done so.

$cmd = "touch /home/www/cgi-bin/game_design/update_db";
#implement a timeout sometime....
system $cmd;
while (-f "/home/www/cgi-bin/game_design/update_db")
{
}
#impulser has now done so since semaphore file is gone.
#print "Now retrieving data from SQL server....<br>\n";
my $dbh = Mysql -> connect("localhost","test");

my $command = "";
        $command = "select how_many from how_many_ships";
        my $sth=$dbh-> query($command);
        die "Error with command $command\n" unless (defined $sth);
        my @arr=();
        while (@arr = $sth->fetchrow)
        {
        ($test_ships) = @arr;
        }
$found_ship_id = 0;

for ($current_ship = 1; $current_ship <= $test_ships; $current_ship++) {

	$command = "select ship_id, ship_name, ship_owner, ship_country, ship_heading, ship_x, ship_y, ship_speed, ship_sighting_range, ship_sight_factor, hull_class, depth, task_force, ship_class, crew_skill from master_ship_chart where ship_id = $current_ship";

$sth = $dbh -> query($command);
die "Error with command: $command\n" unless (defined $sth);

# iterate thru the returned rows

@arr = ($sth->fetchrow);
	{
	($ship_id[$current_ship],$ship_name[$current_ship],$ship_owner[$current_ship],$ship_country[$current_ship],$ship_course[$current_ship],$ship_x[$current_ship],$ship_y[$current_ship],$ship_speed[$current_ship],$ship_sighting_range[$current_ship],$ship_sight_factor[$current_ship],$hull_class[$current_ship], $depth[$current_ship], $task_force[$current_ship], $ship_class[$current_ship], $crew_skill[$current_ship] ) = @arr;
	}
if ($ship_id[$current_ship] == $ship_ID)
	{
	$found_ship_id = $current_ship;
	$ship_NAME = $ship_name[$current_ship];
	$ship_OWNER = $ship_owner[$current_ship];
	$ship_COURSE = $ship_course[$current_ship];
	$ship_X	= $ship_x[$current_ship];
	$ship_Y = $ship_y[$current_ship];
	$ship_SPEED = $ship_speed[$current_ship];
	$ship_SIGHT = $ship_sighting_range[$current_ship];
	$ship_SIGHT_FACT = $ship_sight_factor[$current_ship];
	$ship_depth = $depth[$current_ship];
	$hull_class = $hull_class[$current_ship];
        $ship_tf = $task_force[$current_ship];
        $the_ship_class = $ship_class[$current_ship];
	}

} # end of ship for loopA
$current_ship = $found_ship_id;	
for ($out_loop = 1; $out_loop <= $test_ships; $out_loop++)
    {
    for ($other_ship =1; $other_ship <= $test_ships; $other_ship++)
        {
        if ($out_loop != $other_ship)
           {
           $range_to_ship[$out_loop][$other_ship] = sqrt(($ship_x[$out_loop] - $ship_x[$other_ship]) **2 + ($ship_y[$out_loop] - $ship_y[$other_ship]) **2);
           $pretty_range = int($range_to_ship[$out_loop][$other_ship]);
           $range_to_ship[$out_loop][$other_ship] = int($range_to_ship[$out_loop][$other_ship] * 100) / 100;
           $Xdiff = $ship_x[$other_ship] - $ship_x[$out_loop];
           $Ydiff = $ship_y[$other_ship] - $ship_y[$out_loop];

           $dirextion = atan2($Ydiff,$Xdiff)*180/$pi;
           if ($dirextion < 0)
              {
              $dirextion = $dirextion + 360;
              }
 
           $pretty_bearing = int($ship_course[$out_loop] - $dirextion);
           if ($pretty_bearing < 0)
              {
              $pretty_bearing += 360;
              }
           $bearing_to_ship[$out_loop][$other_ship] = $pretty_bearing;

        } # end of if current ship != other ship...
        else
        {
        $pretty_range = "N/A";
        $pretty_bearing = "N/A";
        }

    }# end of other ship loop
}# end out out_loop


if ($found_ship_id == 0)
	{
	print "That ship ID does not exist in the database<br>\n";
	exit;
	}
	else
	{
	print "A valid ship id was passed - it checked out\n";
	}	
   if ($ship_country[$found_ship_id] eq "German")
      {
      $command = "select use_ai, close_target, use_broadside, fight_outnumb, float_thresh, pursue_target, switch_closest, switch_damaged, return_fire, cap_priority, collis_avoid from german_ai where ship_id = $found_ship_id";
      $sth = $dbh -> query($command);
      die "Error with command: $command\n" unless (defined $sth);
# iterate thru the returned rows
      @arr = ($sth->fetchrow);
             {
             ($use_ai, $close_target, $use_broadside, $fight_outnumb, $float_thresh, $pursue_target, $switch_closest, $switch_damaged, $return_fire, $cap_priority, $collis_avoid ) = @arr;
             }
      }

for ($xx = 1; $xx <= $test_ships; $xx++)
    {
 
$command = "select beam, length from master_hull_table where class = \"$ship_class[$xx]\"";
#print "<br>command is $command<br>\n";
$sth = $dbh -> query($command);
die "Error with command: $command\n" unless (defined $sth);

# iterate thru the returned rows

@arr = ($sth->fetchrow);
        {
        ($beam[$xx],$length[$xx]) = @arr;
        }
    }

$command = "select target from targets where ship_id = $found_ship_id";
$sth = $dbh -> query($command);
die "Error with command: $command\n" unless (defined $sth);

# iterate thru the returned rows

@arr = ($sth->fetchrow);
        {
        ($target) = @arr;
        }
print "<br>\n";
if ($target == 0)
   {
   print "This Ship has no targets defined.<br>\n";
   }
   else
   {
   print "This Ship has the following target: $target<br>\n";
   }
#print "This ship has a height of roughly $beam[$found_ship_id].<br>\n";
$horizon = 1.17 * sqrt($beam[$found_ship_id]);
#print "The horizon is $horizon nm away.<br>\n";

#print "<br>";
if ($hull_class eq "SUB")
{
if ($ship_depth == 0)
	{
	$ship_depth = "Surfaced";
        }
if ( ($ship_depth < 50) && ($ship_depth > 0) )
        {
        $ship_depth = "Periscope Depth";
        }
}
$current_ship = $found_ship_id;
#$current_ship = $ship_ID;
$sighted = 0;
#$cmd = "touch need_visibility";
#system $cmd;
if (! -f "visibility_is")
{
print "For somereason the current visibility is missing....<br>\n";
print "Halted.<br>\n";
exit;
}
open (VISIBILITY,"visibility_is");
while(<VISIBILITY>)
     {
#     chop;
     $visibility = $_;
     }
close (VISIBILITY);
print "Visibility is $visibility according to the impulser.<p>\n";

#$visibility = 10;
#print "temporarily calculations are using a visibility constant of 10<br>\n"; 
for ($other_ship = 1; $other_ship <= $test_ships; $other_ship++)
   {
	if ($current_ship != $other_ship)
           {
           $bearing = $bearing_to_ship[$other_ship][$current_ship];
           $part1 = (cos( $bearing * $pi / 180) * length[$other_ship]);
           $profile = sqrt( (sin( $bearing * $pi / 180 ) * $length[$other_ship])**2 + (cos( $bearing * $pi / 180) * $beam[$other_ship])**2);
           $max_sight_distance =  (1.17 * sqrt($beam[$current_ship]) + 1.17 * sqrt($beam[$other_ship]) * $profile / 5000 + $visibility) * 10;
           if ( ($range_to_ship[$other_ship][$current_ship] <= $max_sight_distance ) && ($depth[$other_ship] == 0) && ($depth[$current_ship] < 51) )
	      {
	      print "$ship_name[$other_ship] has been sighted! Bearing TO other ship = $bearing_to_ship[$current_ship][$other_ship], Range to Other Ship: $range_to_ship[$current_ship][$other_ship]<br>\n";
	      $sighted += 1;
	      }

	   }
	   else
	   {
	   $pretty_range = "N/A";
	   $pretty_bearing = "N/A";
	   }
    }  

$pretty_ship_course = 450 - $ship_COURSE;
        if ($pretty_ship_course > 360)
           {
           $pretty_ship_course -= 360;
           }
print "<hr>";
print "Ship Name: $ship_NAME,   X-Y Co_ords: $ship_X,$ship_Y;  Course:$pretty_ship_course, Speed:$ship_SPEED<br>\n";
print "Ship Class: $the_ship_class,   Depth: $ship_depth,   Task Force: $ship_tf\n<br>";
#print "Currently in Enemy|Own|Neutral Territorial Waters<br>\n";
print "There are $sighted ships currently in visual range<br>\n";
#print "NOTE! This is NOT using the bearings in the formula as modifier just yet<br>\n";
#print "There are Y ships currently in gunnery range<br>\n";
if ($ship_country[$found_ship_id] eq "German")
   {
   print "This is a German ship - it's AI settings are as follows:<br>\n";
   print "Use AI: $use_ai, Close Target to Range: $close_target, Maneuver For Broadside: $use_broadside, Fight When Outnumbered: $fight_outnumb<br>\n";
   print "Flotation Retreat Threshold: $float_thresh, Alter Course to Pursue Target: $pursue_target, Auto-Switch to Closest Target: $switch_closest<br>\n";
   print "Auto-Switch to most Damaged Target: $switch_damaged, Auto-Return Fire: $return_fire, Capital Ships are Priority Target: $cap_priority<br>\n";
   print "Collision Avoidance is switched: $collis_avoid<br>\n";
   if (! -f "make_war")
      {
      print "<p>Currently the Germans are at peace. <a href=\"/cgi-bin/game_design/togg_war.pl\">Change That.</a><br>\n";
      }
   }
print "<p>\n";
#print "If an enemy ship is spotted we will Fight|Flee|Shadow|Ignore<br>\n";
#print "We are currently observing|not observing Radio Silence Rules<br>\n";
print "<hr>\n";

print "<FORM ACTION=\"/cgi-bin/game_design/chg_course.pl\" ENCTYPE=\"x-www-form-urlencoded\"\n";
print "METHOD=\"POST\">\n";
print "Change Course: (in degrees or X,Y) <INPUT NAME=\"change_course\" TYPE=\"text\" SIZE=\"15\">\n";
print "<input name=\"ship_id\" type=\"hidden\" value = \"$ship_ID\">\n";
print "<input name=\"ship_x\" type=\"hidden\" value = \"$ship_X\">\n";
print "<input name=\"ship_y\" type=\"hidden\" value = \"$ship_Y\">\n";
print "<INPUT NAME=\"change course\" TYPE=\"submit\" VALUE=\"change course\">\n";
print "</FORM>\n";

print "<FORM ACTION=\"/cgi-bin/game_design/dump_log.pl\" ENCTYPE=\"x-www-form-urlencoded\"\n";
print "METHOD=\"POST\">\n";
print "<input name=\"ship_id\" type=\"hidden\" value = \"$ship_ID\">\n";
print "<INPUT NAME=\"dump log\" TYPE=\"submit\" VALUE=\"Empty Ships Log\">\n";
print "</FORM>\n";

print "<FORM ACTION=\"/cgi-bin/game_design/chg_speed.pl\" ENCTYPE=\"x-www-form-urlencoded\"\n";
print "METHOD=\"POST\">\n";
print "Change Speed:  <INPUT NAME=\"change_speed\" TYPE=\"text\" SIZE=\"5\">\n";
print "<input name=\"ship_id\" type=\"hidden\" value = \"$ship_ID\">\n";
print "<input name=\"ship_x\" type=\"hidden\" value = \"$ship_X\">\n";
print "<input name=\"ship_y\" type=\"hidden\" value = \"$ship_Y\">\n";
print "<INPUT NAME=\"change speed\" TYPE=\"submit\" VALUE=\"change speed\">\n";
print "</FORM>\n";

if ($the_ship_class ne "Liberty Ship")
   {
   print "<FORM ACTION=\"/cgi-bin/game_design/chg_target.pl\" ENCTYPE=\"x-www-form-urlencoded\"\n";
   print "METHOD=\"POST\">\n";
   print "Change/Add Target:('none' to remove target) <INPUT NAME=\"target\" TYPE=\"text\" SIZE=\"10\">\n";
   print "<input name=\"ship_id\" type=\"hidden\" value = \"$ship_ID\">\n";
   print "<INPUT NAME=\"add_target\" TYPE=\"submit\" VALUE=\"add_target\">\n";
   print "</FORM>\n";
   }
print "<FORM ACTION=\"/cgi-bin/game_design/add_waypoint.pl\" ENCTYPE=\"x-www-form-urlencoded\"\n";
print "METHOD=\"POST\">\n";
print "Add a Waypoint: Waypoint (X,Y) <INPUT NAME=\"waypoint\" TYPE=\"text\" SIZE=\"15\">\n";
print "Speed Change: <input name=\"speed\" type = \"text\" size = \"3\">\n";
#print "hull_class = $hull_class<br>\n";
if ($hull_class eq "SUB")
   {
   print "Depth Change: <input name=\"depth\" type =\"text\" size = \"3\">\n";
   }
   else
   {
   print "<input name=\"depth\" type =\"hidden\" value = \"0\">\n";
   }
print "<input name=\"ship_id\" type=\"hidden\" value = \"$ship_ID\">\n";
print "<input name=\"ship_x\" type=\"hidden\" value = \"$ship_X\">\n";
print "<input name=\"ship_y\" type=\"hidden\" value = \"$ship_Y\">\n";
print "<INPUT NAME=\"Add Waypoint\" TYPE=\"submit\" VALUE=\"Add Waypoint\">\n";
print "</FORM>\n";

if ($hull_class eq "SUB")
{
print "<FORM ACTION=\"/cgi-bin/game_design/chg_depth.pl\" ENCTYPE=\"x-www-form-urlencoded\"\n";
print "METHOD=\"POST\">\n";
print "Change Depth (Submarines Only!):  <INPUT NAME=\"change_depth\" TYPE=\"text\" SIZE=\"5\">\n";
print "<input name=\"ship_id\" type=\"hidden\" value = \"$ship_ID\">\n";
print "<input name=\"ship_x\" type=\"hidden\" value = \"$ship_X\">\n";
print "<input name=\"ship_y\" type=\"hidden\" value = \"$ship_Y\">\n";
print "<INPUT NAME=\"change depth\" TYPE=\"submit\" VALUE=\"change depth\">\n";
print "</FORM>\n";
}
if ($hull_class eq "SUB")
{
print "<FORM ACTION=\"/cgi-bin/game_design/fire_torp.pl\" ENCTYPE=\"x-www-form-urlencoded\"\n";
print "METHOD=\"POST\">\n";
print "Fire Experimental Torpedo (course):<INPUT NAME=\"torp_course\" TYPE=\"text\" SIZE=\"5\">\n";
print "<input name=\"ship_id\" type=\"hidden\" value = \"$ship_ID\">\n";
print "<input name=\"ship_x\" type=\"hidden\" value = \"$ship_X\">\n";
print "<input name=\"ship_y\" type=\"hidden\" value = \"$ship_Y\">\n";
print "<INPUT NAME=\"fire\" TYPE=\"submit\" VALUE=\"Fire!\">\n";
print "</FORM>\n";
}


print "<hr>\n";

print "<FORM ACTION=\"/cgi-bin/game_design/del_ship.pl\" ENCTYPE=\"x-www-form-urlencoded\"\n";
print "METHOD=\"POST\">\n";
print "WARNING! Press this button and this ship is history. No second chances!<br>\n";
print "<input name=\"ship_id\" type=\"hidden\" value = \"$ship_ID\">\n";
print "<INPUT NAME=\"delete ship\" TYPE=\"submit\" VALUE=\"delete ship\"><P>\n";
print "</FORM><br>\n";
