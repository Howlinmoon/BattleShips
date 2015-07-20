#!/usr/bin/perl -w

use diagnostics;
use CGI;  # available from http://www.perl.com/CPAN/
use Mysql;
use Text::ParseWords;
# Create an instance of CGI
my $query = new CGI;

# Send an appropriate MIME header
print $query->header("text/html");

# Grab values from the form 
# Prints are for debug only

my $ship_name = $query->param("ship_name");
@ship_names = quotewords(",", 0, $ship_name);
$qty = @ship_names;
print "You entered a total of $qty ship names<br>\n";
for ($xx = 1; $xx <= $qty; $xx++)
    {
    print "name of ship $xx is $ship_names[$xx - 1]<br>\n";
    }
#fix this laster
$hull_class = "BB";

my $ship_owner = $query->param("ship_owner");
print "Ship Owner: $ship_owner<br>\n";

my $task_force = $query->param("tf");
print "Starting TF = $task_force<br>\n";

my $ship_heading = $query->param("ship_heading");
print "Ship Initial Heading: $ship_heading<br>\n";

my $ship_class = $query->param("Ship_Class");
print "These vessels are of the $ship_class class.<br>\n";
# need to retrieve the current ship ID number - increment and use it.
# get this value from SQL database


if (-f "stopped")
   {
   print "<h1>Impulser is STOPPED</h1><br>Please try again later.<br>\n";
   exit;
   }


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
$command = "";
$command = "select how_many from how_many_hulls";
$sth=$dbh-> query($command);
die "Error with command $command\n" unless (defined $sth);
@arr=();
while (@arr = $sth->fetchrow)
      {
      ($hulls) = @arr;
      }
print "There are $hulls hull classes on file - checking to see if this one is valid<br>\n";
#$ship_class
$got_match = 0;
for ($xx = 1; $xx <= $hulls; $xx++)
    {
    $command = "select class from master_hull_table where hull_id = $xx";
    $sth=$dbh->query($command);
    die "Error with command $command\n" unless (defined $sth);
    @arr=();
    while (@arr = $sth->fetchrow)
          {
          ($class) = @arr;
          }
#print "Ship Class = $ship_class, Class = $class<br>\n";
    if ($class eq $ship_class)
       {
       $got_match = $xx;
       }
    }
if ($got_match == 0)
   {
   print "Sorry - that hull class is not on file<br>\n";
   exit;
   }
print "A Match was found $ship_class is hull id #$got_match<br>\n";
print "Specifications of this particular hull class are the following:<br>\n";
$command = "select * from master_hull_table where hull_id = $got_match";
$sth=$dbh->query($command);
die "Error with command $command\n" unless (defined $sth);
@arr=();
while (@arr = $sth->fetchrow)
      {
      ($class,$tonnage,$beam,$draft,$max,$cruising,$fuel,$flotation,$belt,$deck,$face,$top,$barbette,$tower,$main_guns,$turreta,$turretb,$turretc,$turretd,$turrete,$turretf,$aa_1,$aa_2,$torp,$s_gun1,$s_gun2,$hull_id,$sec_gun_type,$length ) = @arr;
      }

print "class = $class, tonnage = $tonnage,length = $length, beam = $beam, draft = $draft, max speed = $max, Crusing speed = $cruising,Fuel capacity (fake) = $fuel,flotation = $flotation, belt armor = $belt, deck armor = $deck, turret face armor = $face,turret top = $top, barbette = $barbette, tower = $tower, Main Gun Type = $main_guns, turret A = $turreta, turret B = $turretb, turret C = $turretc, turret D = $turretd, turret E = $turrete, turret F = $turretf$, AA type 1 = $aa_1, AA type 2 = $aa_2, torps = $torp, Sec Gun 1 type  = $s_gun1, Sec Gun 2 type = $s_gun2, Sec gun type = $sec_gun_type<br>\n";
print "<hr>\n";
$max_speed = $max;
if ($main_guns =~ /^(.\w*)/)
        {
        $nationality = $1;
        $ship_country = $nationality;
        }
if ($nationality eq "none")
   {
   $nationality = "British";
   $hull_class = "FR";
   }   
if ($class eq "Type VIIC")
   {
   $nationality = "German";
   $hull_class = "SUB";
   }
print "This is a $nationality ship<br>\n";
if ($nationality eq "German")
   {
   $ship_x = 11440;
   $ship_y = 41320;
   $ship_sight_factor = 6;
   $crew_skill = 6;
  }
if ($nationality eq "British")
   {
   $ship_x = 560;
   $ship_y = 39400;
   $ship_sight_factor = 3;
   $crew_skill = 3;
   }
print "The Ship's starting co-ords are $ship_x,$ship_y (for now)<br>\n";
print "Ship speed is now initialized to 0<br>\n";
print "optics for this this ship is $ship_sight_factor, Crew Skill is $crew_skill<br>\n";
$ship_speed = 0;
print "Stand by while I check to see if main gun type \"$main_guns\" is on file...<br>\n";
$command = "select how_many from how_many_guns";
$sth=$dbh->query($command);
die "Error with command $command\n" unless (defined $sth);
@arr=();
while (@arr = $sth->fetchrow)
      {
      ($num_guns) = @arr;
      }
print "There are $num_guns gun specifications on file - checking...<br>\n";
$found_gun = 0;
for ($xx = 1; $xx <= $num_guns; $xx++)
    {
    $command = "select * from master_gun_chart where gun_id = $xx";
$sth=$dbh->query($command);
die "Error with command $command\n" unless (defined $sth);
@arr=();
while (@arr = $sth->fetchrow)
      {
      ($gun_id,$gun_name,$rounds_imp,$shell_velo1,$shell_velo2,$shell_wgt1,$shell_wgt2,$max_elevation,$range1,$range2) = @arr;
      }    
print "comparing \"$gun_name\" with \"$main_guns\"<br>\n";
if ($gun_name eq $main_guns)
   {
   print "We have a match - that guntype is on file!<br>\n";
   $found_gun = $xx;
   }
    }
if ($found_gun == 0)
   {
   print "No Match found.<br>\n";
   print "Sorry - but this ship can not put to sea - aborted.<br>\n";
   exit;
   }
print "Currently There are $test_ships ships on file - this will increase to ";
	$new_amount = $test_ships + $qty;
print "$new_amount ships on file\n<br>";

# purge old test ship count before adding new one
        $command = "delete from how_many_ships";
# Send the query
$sth = $dbh->query($command);

# Make sure that $sth returned reasonably
die "Error with command $command" unless (defined $sth);
#print "stopped for now<br>";
#exit;
#print "Return code was $sth\n";
        $command = "";
        $command = "replace into how_many_ships (how_many) values ($new_amount) ";
#        print "SQL Command:$command\n";
        $sth = $dbh->query($command);
die "error with command $command" unless (defined $sth);
#print "return code was $sth\n";

#print "\nSQL database updated with new total of test ships en route.\n<br>";

#Compute starting parameters
# determine heading during the impulser - not now.
#$heading_deg = $heading * (180 / $pi);

# compute trig friendly heading to use:

$ship_course = 450 - $ship_heading;
        if ($ship_course > 360)
           {
           $ship_course -= 360;
           }

$depth = 0;
$ship_num = 0;
$ship_sighting_range = 1000;
for ($xx = ($test_ships + 1) ; $xx <= $new_amount ; $xx++)
    {
    $command = "";
    $command = "replace into master_ship_chart (ship_id, ship_name, ship_owner, ship_country, ship_heading, ship_x, ship_y, ship_speed, ship_max_speed, ship_sighting_range, ship_sight_factor, hull_class, depth, task_force, ship_class, crew_skill) values ($xx, \"$ship_names[$ship_num]\", \"$ship_owner\", \"$ship_country\", $ship_course, $ship_x, $ship_y, $ship_speed, $max_speed, $ship_sighting_range, $ship_sight_factor, \"$hull_class\",$depth,$task_force,\"$ship_class\",$crew_skill)";
	$sth = $dbh->query($command);
    die "error with command $command" unless (defined $sth);
#    print "<br> command = $command<br>\n";
    $ship_num++;    
#print "<br>\n";
#print "<B>Your Submission(s) was accepted - The Ship is Launched</b>\n<br>";
     $command = "";
     $command = "replace into how_many_waypoints (ship_id, waypoints) values ($xx, 0)";
	$sth = $dbh->query($command);
     die "error with command $command" unless (defined $sth);
#     print "<br> command = $command<br>\n";
     }
#print "<br>\n";
#print "initialized Waypoints for this vessel to 0.<br>\n";
system "touch /home/www/cgi-bin/game_design/add_ship";
system "chmod a+rw /home/www/cgi-bin/game_design/add_ship";
print "The Ship(s) were launched successfully!<br>\n";
