#!/usr/bin/perl -w
#use strict;
use diagnostics;
use Mysql;
$pi = 3.14159265358979323846;
$profile_constant = 0.1;
$percentile_constant = 120;
$scalefactor = 30000;
$at_war = 0;
$mad_brits = 0;
$num_german_tf = 0;
$num_convoys = 0;
$convoy[$num_convoys] = 0;
sub tan { sin($_[0]) / cos($_[0])  }
##$scale_constant = 1/565.0801815667510;

#Unlink all of the semaphore files used in the game
unlink "./stop_update";
unlink "./add_ship";
unlink "./add_taskforce";
unlink "./delete_ship";
unlink "./pause_update";
unlink "./modify_ship";
unlink "./update_db";
unlink "./modify_course";
unlink "./modify_speed";
unlink "./modify_depth";
unlink "./new_waypoint";
unlink "./new_tf_waypoint";
unlink "./stopped";
unlink "./add_ship_force";
unlink "./tf_course";
unlink "./tf_speed";
unlink "./dump_tf_waypoints";
unlink "./update_new_ships";
unlink "./add_target";
unlink "zoom_ship";
unlink "convoy_speed";
unlink "make_war";
unlink "fire_torp";


$cmd = "touch read_gai";
system $cmd;
# "stop_update" is the semaphor to halt the update
# and exit the impulser.
# "add_ship" is the semaphor to indicate to the updater that it needs to
# "delete_ship" is the semaphor to indicate to the updater that it needs to
# delete a ship - and the file contains the id number of the ship to be deleted. 
# "pause_update" - if file is present pause updating and wait for it to
# be removed but do NOT exit the impulser.
# if "update_db" is present - the current data will be saved to the sql server

# fetch a newcopy of the ships from the SQL server
# update the gif to display correct status of the impulser.
$cmd = "cp ~www/game_design/running.gif ~www/game_design/status.gif";
system $cmd;
#Now implementing a conversion factor from impulse to game days
open(LOG,">~www/game_design/impulse.log");

($rsec,$rmin,$rhour,$rmday,$rmon,$ryear,$wday,$yday,$isdst) = localtime(time);
$ryear = 100 - $ryear;
if ($ryear < 10) {
	$ryear = "0" . $ryear;
	}
if ($rsec < 10) {
        $rsec = "0".$rsec;
        }
if ($rmin < 10) {
        $rmin = "0".$rmin;
        }
if ($rhour < 10) {
        $rhour = "0".$rhour;
        }
if ($rmday < 10) {
        $rmday = "0".$rmday;
        }
$rmon=$rmon+1;
if ($rmon < 10) {
        $rmon = "0".$rmon;
        }
$junk = $isdst;
$junk = $yday;
$junk = $wday;

#initialize brightness array
#@brightness = (-2,-1,0,1,2,3,4,5,6,7,8,9,10,9,8,7,6,5,4,3,2,1,0,-1);
@brightness = (-10,-10,-10,0,5,10,10,10,10,10,10,10,10,10,10,10,10,10,10,5,0,-10,-10,-10);
$border[1] = "0 + + + + 10+ + + + 20+ + + + 30+ + + + 40+ + + + 50+ + + + 60+ + + + 70+ + + + 80+ + + + 90+ + + +100+ + + +110+ + + +120+ + + +130+ + + +140+ + + +150+ + + 160<br>\n";
$border[2] = "0 + + + + 20+ + + + 40+ + + + 60+ + + + 80+ + + + 100 + + +120+ + + +140+ + + +160+ + + +180+ + + +200+ + + +220+ + + +240+ + + +260+ + + +280+ + + +300+ + + 320<br>\n"; 
$border[3] = "0 + + + + 30+ + + + 60+ + + + 90+ + + +120+ + + + 150 + + +180+ + + +210+ + + +240+ + + +270+ + + +300+ + + +330+ + + +360+ + + +390+ + + +420+ + + +450+ + + 480<br>\n";
$bottom[1] = "80+ + + + 70+ + + + 60+ + + + 50+ + + + 40+ + + + 30+ + + + 20+ + + + 10+ + + + 0 + + + + 10+ + + + 20+ + + + 30+ + + + 40+ + + + 50+ + + + 60+ + + + 70+ + + 80 <br>\n";
$bottom[2] = "160 + + + 140 + + + 120 + + + 100 + + + 80+ + + + +60 + + + 40+ + + + 20+ + + + 0 + + + + 20+ + + + 40+ + + + 60+ + + + 80+ + + +100+ + + +120+ + + +140+ + + 160<br>\n";
$bottom[3] = "240 + + +210+ + + 180 + + + + 150 + + +120+ + + + +90 + + + 60+ + + + 30+ + + + 0 + + + + 30+ + + + 60+ + + + 90+ + + +120+ + + +150+ + + +180+ + + +210+ + + 240<br>\n"; 
@ship_icon = ("north-","northeast-","east-","southeast-","south-","southwest-","west-","northwest-");
print LOG "\nOcean Impulser started at: $rmon/$rmday/$ryear $rhour:$rmin:$rsec\n";
close(LOG);
$game_time_stamp = "";
my $dbh = Mysql -> connect("localhost","test","orcus");

	$command = "";
        $command = "select how_many from how_many_ships";
        $sth=$dbh-> query($command);
        die "Error with command $command\n" unless (defined $sth);
        @arr=();
        while (@arr = $sth->fetchrow)
        {
        ($number_test_ships) = @arr;
	}

#initialize sighted and collision arrays to all 0s
#need to add this to the add ship routines as well...
print "initializing sinking array\n";
for ($xx = 1; $xx<= $number_test_ships; $xx++)
    {
    $sinking[$xx] = -99;
    $zoom[$xx] = 1;
    for ($yy = 1; $yy<= $number_test_ships; $yy++)
         {
         $sighted[$xx][$yy] = 0;
         $collision[$xx][$yy] = 0;
         }
    }

# Need to determine torpedo specific variables and initialize here.
# Assume no torpedo data is saved between impulser runs.
# Need the following variables:
# how_many_torps = highest number of possible torps out there.
# (not all of these will have status "active")
# possible values for torp_stat[xx] = "arming, active,spent"
# torp_type is needed $torp_type[xx] = "G7e" etc
# speed is needed $torp_speed[xx] (in knots)
# course is needed $torp_course[xx]
# depth is needed (for now - 10 feet) $torp_depth[xx]
# range of G7e is 25 in 5 impulses.
# 15 impulses needed to reload tube
# each torp hit does 25 flotations
# Initial torp positions after launch
# torpX = ShipX + cos(ShipHeading)
# torpY = ShipY +sin(ShipHeading)

$number_torps = 0;

$command = "select how_many from how_many_guns";
$sth=$dbh->query($command);
die "Error with command $command\n" unless (defined $sth);
@arr=();
while (@arr = $sth->fetchrow)
      {
      ($num_guns) = @arr;
      }
for ($xx = 1; $xx <= $num_guns; $xx++)
    {
    $command = "select * from master_gun_chart where gun_id = $xx";
    $sth=$dbh->query($command);
    die "Error with command $command\n" unless (defined $sth);
    @arr=();
    while (@arr = $sth->fetchrow)
          {
          ($id_junk,$gun_name[$xx],$rounds_imp[$xx],$shell_velo1[$xx],$shell_velo2[$xx],$shell_wgt1[$xx],$shell_wgt2[$xx],$max_elevation[$xx],$range1[$xx],$range2[$xx]) = @arr;
          }    
    }

        $command = "select how_many from how_many_hulls";
        $sth=$dbh-> query($command);
        die "Error with command $command\n" unless (defined $sth);
        @arr=();
        while (@arr = $sth->fetchrow)
              {
              ($number_hulls) = @arr;
              }

        for ($xx = 1; $xx <= $number_test_ships; $xx++)
            {
            $command = "";
            $command = "select target from targets where ship_id = $xx";
            $sth=$dbh-> query($command);
            die "Error with command $command\n" unless (defined $sth);
            @arr=();
            while (@arr = $sth->fetchrow)
                  {
                  ($target[$xx]) = @arr;
                  open (SHIPS_LOG,">>/home/www/game_design/ships_logs/ships_log_$xx.txt");
                  print SHIPS_LOG "<option>Impulser Restarted Old Target is $target[$xx]</option>\n";
                  close (SHIPS_LOG);
                  }
            }
        $command = "";
        $command = "select how_many from how_many_taskforces";
        $sth=$dbh-> query($command);
        die "Error with command $command\n" unless (defined $sth);
        @arr=();
        while (@arr = $sth->fetchrow)
        {
        ($number_taskforces) = @arr;
        }
	print "There are $number_taskforces taskforces in operation\n";


## Insert code to read in the taskforces!
if ($number_taskforces > 0)
	{
	for ($xx = 1; $xx <= $number_taskforces; $xx++) 
            {
            $command = "select tf_name, tf_country, tf_type, num_waypoints, tf_speed, tf_course, tf_depth from taskforce_master where tf_id = $xx";
            $sth = $dbh -> query($command);
            die "Error with command: $command\n" unless (defined $sth);
#           iterate thru the returned rows

            @arr = ($sth->fetchrow);
                {
                ($task_force[$xx],$task_force_country[$xx],$task_force_type[$xx],$task_force_waypoints[$xx],$task_force_speed[$xx],$task_force_course[$xx],$task_force_depth[$xx]) = @arr;
                }
             if ($task_force_country[$xx] eq "German")
                {
                $num_german_tf++;
                $german_tf[$num_german_tf] = $xx;
                }
#Convoys for now are aliased as TF's.  Determine if read in TF is a convoy...
             if ($task_force[$xx] =~ /convoy/) #convoy's have "convoy" in name
                {
                $no_match = 1;
                for ($which_one = 0; $which_one <= $num_convoys; $which_one++)
                    {
                    print "which_one = $which_one\n";
                    if ($convoy[$which_one] == $xx)
                       {
                       $no_match = 0;
                       }
                     }
                if ($no_match == 1)
                   {
                   $num_convoys++;
                   $convoy_name[$num_convoys] = $task_force[$xx];
                   $convoy_status[$num_convoys] = "*";
                   $zig_time[$num_convoys] = 1;
                   $zig_interval[$num_convoys] = 10;
                   $convoy_owner[$num_convoys] = "federation";
                   $convoy_country[$num_convoys] = $task_force_country[$xx];
                   $convoy_course[$num_convoys] = 337.5;
                   $convoy_speed[$num_convoys] = 0;
                   $convoy_max_speed[$num_convoys] = 11;
                   print "Task Force #$xx is really a convoy, Convoy #$num_convoys to be exact.\n";
                   $convoy[$num_convoys] = $xx;
                   }
                }
             $task_force_members[$xx] = 0;
#            print "name = $task_force[$xx], country = $task_force_country[$xx], type = $task_force_type[$xx],waypoints = $task_force_waypoints[$xx],speed = $task_force_speed[$xx],course = $task_force_course[$xx],depth = $task_force_depth[$xx]\n";
            }
        }
sub read_convoy
{
## Now really read in the convoy data:
print "reading in convoy data for $num_convoys convoys.\n";
for ($xx = 1; $xx<= $num_convoys; $xx++)
    {
    $command = "select * from convoy_master where convoy_id = $xx";
    $sth = $dbh -> query($command);
    die "Error with command $command\n" unless (defined $sth);
    @arr=();
    while (@arr = $sth->fetchrow)
          {
          ($id_junk,$x_spacing[$xx],$y_spacing[$xx],$x_start[$xx],$y_start[$xx],$num_columns[$xx],$zig_interval[$xx],$changes[$xx],$start_course[$xx],$zig_offset[$xx]) = @arr;
          }    
    $start_course[$xx] = 450 - $start_course[$xx];
    if ($start_course[$xx] > 360)
       {
       $start_course[$xx] -= 360;
       }
    $convoy_course[$xx] = $start_course[$xx];
    }
}
&read_convoy;

$game_year = 1930;
$game_month = 1;
$game_day = 1;
$game_hours = 0;
#$game_minute = 0;
$game_ticks = 0;
#$impulse = 0;
@month = ("DUMMY","January","February","March","April","May","June","July","August","September","October","November","December");

#Following code resumes impulse count
open (IMPULSE,"what_imp");
     while(<IMPULSE>)
     {
     chop;
     $impulser = $_;
     }
if ($impulser =~ /^(.\d*):(.\d*):(.\d*):(.\d*):(.\d*):(.\d*)/)
        {
        $impulse = $1;
        $game_ticks = $2;
        $game_hours = $3;
        $game_day = $4;
        $game_month = $5;
        $game_year = $6;
        }
print "starting impulse = $impulse\n";

$update = 0;
$task_force[0] = "NONE";

#Retrieve Data currently online for Ships in motion
$num_germans = 0;
for ($current_ship = 1; $current_ship <= $number_test_ships; $current_ship++) {

	$command = "select ship_id, ship_name, ship_owner, ship_country, ship_heading, ship_x, ship_y, ship_speed, ship_max_speed, ship_sighting_range, ship_sight_factor, hull_class, depth, task_force ,ship_class ,crew_skill from master_ship_chart where ship_id = $current_ship";

$sth = $dbh -> query($command);
die "Error with command: $command\n" unless (defined $sth);

# iterate thru the returned rows

@arr = ($sth->fetchrow);
	{
($ship_id[$current_ship],$ship_name[$current_ship],$ship_owner[$current_ship],$ship_country[$current_ship],$ship_course[$current_ship],$ship_x[$current_ship],$ship_y[$current_ship],$ship_speed[$current_ship],$max_speed[$current_ship],$ship_sighting_range[$current_ship],$ship_sight_factor[$current_ship], $hull_class[$current_ship], $depth[$current_ship], $task_force_id[$current_ship], $ship_class[$current_ship], $crew_skill[$current_ship]) = @arr;
	}
$task_force_members[$task_force_id[$current_ship]]++;
$org_max_speed[$current_ship] = $max_speed[$current_ship];
### temp only!
if ( ($ship_country[$current_ship] eq "none") && ($hull_class[$current_ship] eq "FR"))
   {
   $ship_country[$current_ship] = "British";
   }

if ( ($ship_country[$current_ship] eq "none") && ($hull_class[$current_ship] eq "SUB"))
   {
   $ship_country[$current_ship] = "German";
   }

   if ($ship_country[$current_ship] eq "German")
      {
      $command = "select use_ai, close_target, use_broadside, fight_outnumb, float_thresh, pursue_target, switch_closest, switch_damaged, return_fire, cap_priority, collis_avoid from german_ai where ship_id = $current_ship";
      $sth = $dbh -> query($command);
      die "Error with command: $command\n" unless (defined $sth);
# iterate thru the returned rows
      @arr = ($sth->fetchrow);
             {
             ($use_ai[$current_ship], $close_target[$current_ship], $use_broadside[$current_ship], $fight_outnumb[$current_ship], $float_thresh[$current_ship], $pursue_target[$current_ship], $switch_closest[$current_ship], $switch_damaged[$current_ship], $return_fire[$current_ship], $cap_priority[$current_ship], $collis_avoid[$current_ship] ) = @arr;
             }
      }

## next section is anti-mike code
if ($ship_speed[$current_ship] < -5)
    {
    $ship_speed[$current_ship] = -5;
    }

## Read ship hull specifics in...
$got_match = 0;
for ($xx = 1; $xx <= $number_hulls; $xx++)
    {
    $command = "select class,flotation, max_speed from master_hull_table where hull_id = $xx";
    $sth=$dbh->query($command);
    die "Error with command $command\n" unless (defined $sth);
    @arr=();
    while (@arr = $sth->fetchrow)
          {
          ($class,$float,$max_spd) = @arr;
          }
    if ( $class eq $ship_class[$current_ship] )
       {
       $got_match = $xx;
       $flotation[$current_ship] = $float;
       $org_flotation[$current_ship] = $float;
       $flot_warn[$current_ship] = 0;
       $max_speed[$current_ship] = $max_spd;
       }
    }

if ($got_match == 0)
   {
   print "No Hull class on file for ship number $current_ship\n";
   exit;
   }
$command = "select * from master_hull_table where hull_id = $got_match";
$sth=$dbh->query($command);
die "Error with command $command\n" unless (defined $sth);
@arr=();
while (@arr = $sth->fetchrow)
      {
      ($class_junk,$tonnage[$current_ship],$beam[$current_ship],$draft[$current_ship],$max_speed[$current_ship],$cruising_speed[$current_ship],$fuel[$current_ship],$flotation[$current_ship],$belt[$current_ship],$deck[$current_ship],$face[$current_ship],$top[$current_ship],$barbette[$current_ship],$tower[$current_ship],$main_guns[$current_ship],$turret[1][$current_ship],$turret[2][$current_ship],$turret[3][$current_ship],$turret[4][$current_ship],$turret[5][$current_ship],$turret[6][$current_ship],$aa_1[$current_ship],$aa_2[$current_ship],$torp[$current_ship],$s_gun1[$current_ship],$s_gun2[$current_ship],$hull_id[$current_ship],$sec_gun_type[$current_ship],$length[$current_ship] ) = @arr;
      }
# determine gun_id number for each ship now - save time during combat
$match = 0;
for ($xx = 1; $xx <= $num_guns; $xx++)
    {
    if ($main_guns[$current_ship] eq $gun_name[$xx])
       {
       $match = $xx;
       }
    }
if ($match == 0)
   {
   print "Could not find ships main guns in gun table.\n";
   print "current ship = $current_ship\n";
   exit;
   }
$gun_id[$current_ship] = $match;

#The following three default semaphore values indicate that
#they have no valid value.
$course_target[$current_ship] = -1;
$speed_target[$current_ship] = -999;
$depth_target[$current_ship] = -999;
#$task_force_id[$current_ship] = 0;
$following_waypoint[$current_ship] = 0;
$old_distance[$current_ship] = 0;
$eta[$current_ship] = 0;
$update = 0;
$waypoint_pause[$current_ship] = "FALSE";
$ship_status[$current_ship] = "*";
#Read Waypoints in
      $command = "";
        $command = "select waypoints from how_many_waypoints where ship_id = $current_ship";
        $sth=$dbh-> query($command);
        die "Error with command $command\n" unless (defined $sth);
        @arr=();
        while (@arr = $sth->fetchrow)
        {
        ($number_waypoints[$current_ship]) = @arr;
        }
	if ($number_waypoints[$current_ship] > 0)
           {
	   for ($xx = 1; $xx <= $number_waypoints[$current_ship]; $xx++)
               {
               $command = "";
               $command = "select waypoint from waypoint_master where ship = $current_ship and waypoint_num = $xx";
               $sth=$dbh-> query($command);
               die "Error with command $command\n" unless (defined $sth);
               @arr=();
               while (@arr = $sth->fetchrow)
                     {
                     ($waypoint[$current_ship][$xx]) = @arr;
                     }
#	       print "for ship $current_ship waypoint #$xx is $waypoint[$current_ship][$xx]\n";
               }
            }
} # end of ship for loop	


# Main loop can start here
# place a file called "stop_update" in game dir to bring it down gracefully.

if (-f "init_ships")
   {
   &update_db;
   unlink "init_ships";
   }
#print "edit me!\n";
#exit;

# *************************** MAIN LOOP **************************

while (! -f "stop_update") {

#try to thrash around here less with a sleep 1
sleep 1;

($rsec,$rmin,$rhour,$rmday,$rmon,$ryear,$wday,$yday,$isdst) = localtime(time);
$ryear = 100 - $ryear;
if ($ryear < 10) {
	$ryear = "0" . $ryear;
	}
if ($rsec < 10) {
        $rsec = "0".$rsec;
        }
if ($rmin < 10) {
        $rmin = "0".$rmin;
        }
if ($rhour < 10) {
        $rhour = "0".$rhour;
        }
if ($rmday < 10) {
        $rmday = "0".$rmday;
        }
$rmon=$rmon+1;
if ($rmon < 10) {
        $rmon = "0".$rmon;
        }
# /home/www/game_design/impulse.log
#The following schedules auto-saves 5 minutes after the hour
if ($rmin == "05")
   {
   if ($rsec == "00")
      {
      $update = 1;
      }
   }

# the following rotates the console log ever 10 minutes keeping it a manageable size
# for viewing with a browser

if ( (($rmin / 10) == int($rmin / 10)) && ($rsec <= 4) )
   {
   $cmd = "cat /home/www/game_design/impulse.log >> /home/www/game_design/impulselogs.bak";
   system $cmd;
   open (NEWLOG,">/home/www/game_design/impulse.log") || die "couldn't rotate the logs";
   print NEWLOG "New console log started $rmon/$rmday $rhour:$rmin\n\r";
   close (NEWLOG);
   }

if (-f "read_gai")
    {
    print "ordered to re-read german AI parameters from sql\n";
    for ($current_ship = 1; $current_ship <= $number_test_ships; $current_ship++)
        {
        if ($ship_country[$current_ship] eq "German")
           {
           $command = "select use_ai, close_target, use_broadside, fight_outnumb, float_thresh, pursue_target, switch_closest, switch_damaged, return_fire, cap_priority, collis_avoid from german_ai where ship_id = $current_ship";
           $sth = $dbh -> query($command);
           die "Error with command: $command\n" unless (defined $sth);
# iterate thru the returned rows
           @arr = ($sth->fetchrow);
             {
             ($use_ai[$current_ship], $close_target[$current_ship], $use_broadside[$current_ship], $fight_outnumb[$current_ship], $float_thresh[$current_ship], $pursue_target[$current_ship], $switch_closest[$current_ship], $switch_damaged[$current_ship], $return_fire[$current_ship], $cap_priority[$current_ship], $collis_avoid[$current_ship] ) = @arr;
             }
           }
        }
unlink "read_gai";
     }

if ($at_war == 0)
   {
   if (-f "make_war")
      {
      $at_war = 1;
      }
   }


if (-f "init_ships")
   {
   unlink "make_war";
   &read_convoy;
   $convoy_spot = 1;
   $odd_even = 1;
   $y_offset = $y_start[1];
   for ($current_ship = 1; $current_ship <= $number_test_ships; $current_ship++)
       {
       if ( ! ($task_force[$task_force_id[$current_ship]] =~ /convoy/) )
          {
          if ($ship_country[$current_ship] eq "German")
             {
             $ship_x[$current_ship] = (int(rand(100))+1) - 50 + 38100;
             $ship_y[$current_ship] = (int(rand(100))+1) - 50 + 490;
             }
             else
             {
             $ship_x[$current_ship] = (int(rand(100))+100) - 50 + 38100;
             $ship_y[$current_ship] = (int(rand(100))+100) - 50 + 490;
             }
          }
          else
          {
# handle init'ing convoy here
          print "ship $ship_name[$current_ship] is a convoy member\n";
          $ship_x[$current_ship] = ($x_start[1] + ($odd_even * $x_spacing[1]) - $x_spacing[1]);
          $odd_even++;
          $ship_y[$current_ship] = $y_offset;
#          print "oddeven = $odd_even convoy member $convoy_spot has an X of $ship_x[$current_ship] and a Y of $ship_y[$current_ship]\n";
          $ship_course[$current_ship] = $start_course[1];
          if ($odd_even == $num_columns[1]+1)
             {
             $odd_even = 1;
             $y_offset -= $y_spacing[1];
             }
          $convoy_spot++;
         }
      $depth[$current_ship] = 0;
      $ship_speed[$current_ship] = 0;
      $speed_target[$current_ship] = 0;
      $target[$current_ship] = 0;
      $ship_status[$current_ship] = "*";
      $at_war = 0;
      $mad_brits = 0;
      $got_match = 0;
      for ($xx = 1; $xx <= $number_hulls; $xx++)
          {
          $command = "select class,flotation, max_speed from master_hull_table where hull_id = $xx";
          $sth=$dbh->query($command);
          die "Error with command $command\n" unless (defined $sth);
          @arr=();
          while (@arr = $sth->fetchrow)
                {
                ($class,$float,$max_spd) = @arr;
                }
          if ( $class eq $ship_class[$current_ship] )
             {
             $got_match = $xx;
             $flotation[$current_ship] = $float;
             $org_flotation[$current_ship] = $float;
             $flot_warn[$current_ship] = 0;
             $max_speed[$current_ship] = $max_spd;
             }
      }
      $sinking[$current_ship] = -99;
      for ($xy = 1; $xy <= $number_test_ships; $xy++)
          {
          $collision[$current_ship][$xy] = 0;
          }
     }
   unlink "init_ships";
   $cmd = "rm -rf /home/www/game_design/ships_logs/*.txt";
   system $cmd;
   for ($xy = 1; $xy <= $number_test_ships; $xy++)
       {
       $cmd = "cp /home/www/game_design/ships_logs/empty.log  /home/www/game_design/ships_logs/ships_log_$xy.txt";
       system $cmd;
       }

   }

if (-f "modify_course")
   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to read ship modify semaphore\n";
   open (GET_PID,"modify_course");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    print LOG "PID of semaphore is $pid\n";

    open (NEW_COURSE,"ship_course.$pid");
	while (<NEW_COURSE>)
        {
        chop;
        $new_course = $_;
        }
     unlink "ship_course.$pid";
     print LOG "New course desired is $new_course\n";
    close(NEW_COURSE);

    open (WHAT_SHIP,"target_ship.$pid");
	while (<WHAT_SHIP>)
        {
        chop;
        $what_ship = $_;
        }
    unlink "target_ship.$pid";
     print LOG "Ship getting course change is $what_ship\n";
     close (WHAT_SHIP);
     $course_target[$what_ship] = $new_course;
unlink "modify_course";
close (LOG);
} #end of (if -f modify_course) 

if (-f "convoy_speed")
   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to read convoy speed modify semaphore\n";
   open (GET_PID,"convoy_speed");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    print LOG "PID of semaphore is $pid\n";
    unlink "convoy_speed";

    open (NEW_COURSE,"convoy_speed.$pid");
	while (<NEW_COURSE>)
        {
        chop;
        $raw = $_;
        }
if ($raw =~ /^(.\d*):(.\d*)/)
        {
        $convoy_id = $1;
        $speed = $2;
        }
     unlink "convoy_speed.$pid";
     print LOG "New Speed for Convoy #$convoy_id is $speed\n";
    close(NEW_COURSE);
    $convoy_speed[$convoy_id] = $speed;
}

if (-f "tf_course")
   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to read tf modify semaphore\n";
   open (GET_PID,"tf_course");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    print LOG "PID of semaphore is $pid\n";
    unlink "tf_course";

    open (NEW_COURSE,"tf_course.$pid");
	while (<NEW_COURSE>)
        {
        chop;
        $raw = $_;
        }
if ($raw =~ /^(.\d*):(.\d*)/)
        {
        $tf_id = $1;
        $tf_course = $2;
        }
     unlink "tf_course.$pid";
     print LOG "New course for tf #$tf_id is $tf_course\n";
    close(NEW_COURSE);
for ($xx = 1; $xx <= $number_test_ships; $xx++)
    {
    if ($task_force_id[$xx] == $tf_id)
       {
       $course_target[$xx] = $tf_course;
       }
     }
$update = 1;
close (LOG);
} #end of (if -f tf_course) 

if (-f "zoom_ship")
   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to read zoom_ship semaphore\n";
   open (GET_PID,"zoom_ship");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    print LOG "PID of semaphore is $pid\n";
    unlink "zoom_ship";

    open (NEW_COURSE,"zoom_ship.$pid");
	while (<NEW_COURSE>)
        {
        chop;
        $raw = $_;
        }
if ($raw =~ /^(.\d*):(.\d*)/)
        {
        $ship_id = $1;
        $zoom_level = $2;
        }
     unlink "zoom_ship.$pid";
     print LOG "Now setting zoom level for ship $ship_id to $zoom_level\n";
    close(NEW_COURSE);
    $zoom[$ship_id] = $zoom_level;
close (LOG);
} #end of (if -f zoom_ship) 

if (-f "tf_speed")
   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to read tf modify semaphore\n";
   open (GET_PID,"tf_speed");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    print LOG "PID of semaphore is $pid\n";
    unlink "tf_speed";

    open (NEW_COURSE,"tf_speed.$pid");
	while (<NEW_COURSE>)
        {
        chop;
        $raw = $_;
        }
if ($raw =~ /^(.\d*):(.\d*)/)
        {
        $tf_id = $1;
        $tf_speed = $2;
        }
     unlink "tf_speed.$pid";
     print LOG "New Speed for tf #$tf_id is $tf_speed\n";
    close(NEW_COURSE);
for ($xx = 1; $xx <= $number_test_ships; $xx++)
    {
    if ($task_force_id[$xx] == $tf_id)
       {
       $speed_target[$xx] = $tf_speed;
       }
     }
$update = 1;
close (LOG);
} #end of (if -f tf_speed) 


if (-f "modify_speed")
   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to read ship speed modify semaphore\n";
   open (GET_PID,"modify_speed");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    print LOG "PID of semaphore is $pid\n";

    open (NEW_COURSE,"ship_speed.$pid");
	while (<NEW_COURSE>)
        {
        chop;
        $new_speed = $_;
        }
     unlink "ship_speed.$pid";
     print LOG "New speed desired is $new_speed\n";
    close(NEW_COURSE);

    open (WHAT_SHIP,"target_ship.$pid");
	while (<WHAT_SHIP>)
        {
        chop;
        $what_ship = $_;
        }
    unlink "target_ship.$pid";
     print LOG "Ship getting speed change is $what_ship\n";
     close (WHAT_SHIP);
    
     if ($new_speed > $max_speed[$what_ship])
        {
        $new_speed = $max_speed[$what_ship];
        }
     if ($new_speed < 0)
        {
        $new_speed = 0;
        }
     $speed_target[$what_ship] = $new_speed;
unlink "modify_speed";

close (LOG);
} #end of (if -f modify_speed) 


if (-f "add_target")
   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to read ship add target semaphore\n";
   open (GET_PID,"add_target");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    print LOG "PID of semaphore is $pid\n";

    open (NEW_COURSE,"add_target.$pid");
	while (<NEW_COURSE>)
        {
        chop;
        $new_target = $_;
        }
     unlink "add_target.$pid";
     print LOG "Target passed is $new_target\n";
    close(NEW_COURSE);
   
    if ($new_target =~ /^(\d*):(\d*)/)
       {
       $ship_id = $1;
       $target_id = $2;
       print "Ship $ship_id now has $target_id as it's target\n";
       $target[$ship_id] = $target_id;
       open (SHIPS_LOG,">>/home/www/game_design/ships_logs/ships_log_$ship_id.txt");
       print SHIPS_LOG "<option>$game_month/$game_day/$game_year $game_hours:$game_ticks Have received new combat target - ";
       if ($target_id == 0)
          {
          print SHIPS_LOG "none</option>\n";
          }
          else
          {
          print SHIPS_LOG "$target_id</option>\n";
          }
       close (SHIPS_LOG);
       }
       
unlink "add_target";
close (LOG);
} #end of (if -f add_target) 

if (-f "modify_depth")
   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to read ship depth modify semaphore\n";
   open (GET_PID,"modify_depth");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    print LOG "PID of semaphore is $pid\n";

    open (NEW_COURSE,"ship_depth.$pid");
	while (<NEW_COURSE>)
        {
        chop;
        $new_depth = $_;
        }
     unlink "ship_depth.$pid";
     print LOG "New depth desired is $new_depth\n";
    close(NEW_COURSE);

    open (WHAT_SHIP,"target_ship.$pid");
	while (<WHAT_SHIP>)
        {
        chop;
        $what_ship = $_;
        }
    unlink "target_ship.$pid";
     print LOG "Ship getting depth change is $what_ship\n";
     close (WHAT_SHIP);
     $depth_target[$what_ship] = $new_depth;
unlink "modify_depth";
close (LOG);
} #end of (if -f modify_depth) 

if (-f "fire_torp")
   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to read torpedo firing semaphore\n";
   open (GET_PID,"fire_torp");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    print LOG "PID of semaphore is $pid\n";

    open (NEW_COURSE,"fire_torp.$pid");
	while (<NEW_COURSE>)
        {
        chop;
       $firing = $_;
        }
print "firing value retrieved is $firing\n";
     close(NEW_COURSE);
     unlink "fire_torp.$pid";
     unlink "fire_torp";
if ($firing =~ /^(.*):(.*)/)
        {
        $torp_course = $1;
        $firing_ship = $2;
        }
     print LOG "$ship_name[$firing_ship] has just fired a torpedo on the course of $torp_course\n";
     print "$ship_name[$firing_ship] has just fired a torpedo on the course of $torp_course\n";
     $number_torps++;
     $torp_id = $number_torps + 1000;
     $torp_x[$torp_id] = $ship_x[$firing_ship] + cos($ship_heading[$firing_ship]); 
     $torp_y[$torp_id] = $ship_y[$firing_ship] + sin($ship_heading[$firing_ship]);

# bastardizing torp variables for use with ship oriented collision code.
     $ship_x[$torp_id] = $torp_x[$torp_id];
     $ship_y[$torp_id] = $torp_y[$torp_id];

     $torp_duration[$torp_id] = 6;
     $torp_course[$torp_id] = $torp_course;
     $torp_status[$torp_id] = "launched";
     $torp_speed[$torp_id] = 30;
     $torp_launcher[$torp_id] = $firing_ship;
     $ship_name[$torp_id] = "Torpedo #$number_torps launched by $ship_name[$firing_ship]";
     print "torp id = $torp_id, torp_x = $torp_x[$torp_id] ship_x = $ship_x[$firing_ship] torp_y = $torp_y[$torp_id] ship_y = $ship_y[$firing_ship]\n"; 
}

if (-f "pause_waypoint")
   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to read ship waypoint pause semaphore\n";
   open (GET_PID,"pause_waypoint");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    unlink "pause_waypoint";
    print LOG "PID of semaphore is $pid\n";

    open (NEW_COURSE,"pause_waypoint.$pid");
	while (<NEW_COURSE>)
        {
        chop;
        $ship_to_pause = $_;
        }
     unlink "pause_waypoint.$pid";
     print LOG "Ship toggling waypoint pausing is $ship_to_pause\n";
    close(NEW_COURSE);

#Toggle the waypoint following on/off
    if ($waypoint_pause[$ship_to_pause] eq "FALSE")
       {
       $waypoint_pause[$ship_to_pause] = "TRUE";
       }
       else
       {
       $waypoint_pause[$ship_to_pause] = "FALSE";
       }

close (LOG);
} #end of (if -f pause_waypoint) 

if (-f "add_taskforce")

   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to add a taskforce\n";
   open (GET_PID,"add_taskforce");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    unlink "add_taskforce";
    print LOG "PID of taskforce semaphore is $pid\n";
    print "PID of taskforce semaphore is $pid\n";
    open (NEW_COURSE,"taskforce.$pid");
	while (<NEW_COURSE>)
        {
        chop;
        $new_taskforce = $_;
        }
print "new_task force value retrieved is $new_taskforce\n";
     close(NEW_COURSE);
     unlink "taskforce.$pid";
 $number_taskforces+=1;
if ($new_taskforce =~ /^(.*):(.*)/)
        {
        $taskforce_name = $1;
        $taskforce_country = $2;
        }
print "Task force Name = $taskforce_name, task force country = $taskforce_country\n";
 $task_force[$number_taskforces] = $taskforce_name;
 $task_force_country[$number_taskforces] = $taskforce_country;
 print "Country $task_force_country[$number_taskforces] just added a new taskforce: $task_force[$number_taskforces]\n";
#sql add details here
 $task_force_type[$number_taskforces] = "unspecified";
 $task_force_waypoints[$number_taskforces] = 0;
 $task_force_speed[$number_taskforces] = 0;
 $task_force_course[$number_taskforces] = 0;
 $task_force_depth[$number_taskforces] = 0;
 $update = 1;
}

if (-f "add_ship_force")
{

   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to add a ship to a taskforce\n";
   open (GET_PID,"add_ship_force");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    unlink "add_ship_force";
    print LOG "PID of add_ship_force semaphore is $pid\n";

    open (NEW_COURSE,"add_ship_force.$pid");
	while (<NEW_COURSE>)
        {
        chop;
        $new_taskforce = $_;
        }
     close(NEW_COURSE);
     unlink "add_ship_force.$pid";
if ($new_taskforce =~ /^(.\d*):(.\d*)/)
        {
        $ship_id = $1;
        $the_taskforce = $2;
        }
 $task_force_id[$ship_id] = $the_taskforce;
 print "Ship #$ship_id now belongs to task force $task_force[$the_taskforce]\n";
 print LOG "Ship #$ship_id now belongs to task force $task_force[$the_taskforce]\n";
 $update = 1;
}


if (-f "new_waypoint")
   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to read ship waypoint add semaphore\n";
   open (GET_PID,"new_waypoint");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    print LOG "PID of waypoint semaphore is $pid\n";

    open (NEW_COURSE,"new_waypoint.$pid");
	while (<NEW_COURSE>)
        {
        chop;
        $new_waypoint = $_;
        }
     close(NEW_COURSE);

if ($new_waypoint =~ /^(.\d*):(.\d*):(.\d*):(.\d*)/)
        {
        $waypoint_x = $1;
        $waypoint_y = $2;
        $waypoint_depth = $3;
        $waypoint_speed = $4;
        }
     unlink "new_waypoint.$pid";
     $new_waypoint = $waypoint_x . "," . $waypoint_y . "," . $waypoint_depth . "," . $waypoint_speed;
     print LOG "Waypoint Received is $new_waypoint\n";

    open (WHAT_SHIP,"target_ship.$pid");
	while (<WHAT_SHIP>)
        {
        chop;
        $what_ship = $_;
        }
     unlink "target_ship.$pid";
     print LOG "Ship getting new waypoint is $what_ship\n";
     close (WHAT_SHIP);
     unlink "new_waypoint";
	$number_waypoints[$what_ship]++;
	$waypoint[$what_ship][$number_waypoints[$what_ship]] = $new_waypoint;
close (LOG);

} #end of (if -f new_waypoint) 


if (-f "new_tf_waypoint")
   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to read tf waypoint add semaphore\n";
   open (GET_PID,"new_tf_waypoint");
	while (<GET_PID>)
        {
        chop;
        $pid = $_;
	}
    close (GET_PID);
    print LOG "PID of tf_waypoint semaphore is $pid\n";

    open (NEW_COURSE,"new_tf_waypoint.$pid");
	while (<NEW_COURSE>)
        {
        chop;
        $new_waypoint = $_;
        }
     close(NEW_COURSE);
     unlink "new_tf_waypoint";

if ($new_waypoint =~ /^(.\d*):(.\d*):(.\d*):(.\d*):(.\d*)/)
        {
        $tf_id = $1;
        $waypoint_x = $2;
        $waypoint_y = $3;
        $waypoint_depth = $4;
        $waypoint_speed = $5;
        }
     unlink "new_tf_waypoint.$pid";
     $new_waypoint = $waypoint_x . "," . $waypoint_y . "," . $waypoint_depth . "," . $waypoint_speed;
     print LOG "Waypoint Received is $new_waypoint\n";

     print LOG "Task Force getting new waypoint is $tf_id\n";

# Big Test here - if this is first waypoint for ships in this task force
# We need to TOSS all of their old waypoints...

    if ($task_force_waypoints[$tf_id] == 0)
       {
        print "Task Force $tf_id has no waypoints - YET - nuking personal ones\n";
       # Yep - chuck them...
       # $task_force_id[ship] = $tf_id...
       # 
	#       $course_target[$current_ship] = -1;
	#$speed_target[$current_ship] = -999;
	#$depth_target[$current_ship] = -999;
	#$following_waypoint[$current_ship] = 0;
	#$old_distance[$current_ship] = 0;
	#$number_waypoints[$what_ship]++;
        #$waypoint[$what_ship][$number_waypoints[$what_ship]] = $new_waypoint;

        for ($xx = 1; $xx <= $number_test_ships; $xx++)
            {
            if ($task_force_id[$xx] == $tf_id)
               {
               $following_waypoint[$xx] = 0;
               $number_waypoints[$xx] = 0;
               }
             }
        }

        $task_force_waypoints[$tf_id] +=1;
        for ($xx = 1; $xx <= $number_test_ships; $xx++)
            {
            if ($task_force_id[$xx] == $tf_id)
               {
               print "ship id #$xx is a member of this tf - getting new wp\n";
               $number_waypoints[$xx] +=1;
               $waypoint[$xx][$number_waypoints[$xx]] = $new_waypoint;
               }
            }
$update = 1;
close (LOG);

} #end of (if -f new_waypoint) 


if (-f "dump_tf_waypoints")
   {
   open(LOG,">>/home/www/game_design/impulse.log");
   print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec instructed to dump tf waypoints semaphore\n";
   open (GET_PID,"dump_tf_waypoints");
	while (<GET_PID>)
        {
        chop;
        $tf = $_;
	}
    close (GET_PID);
    print LOG "Preparing to dump waypoints of task force $tf\n";
    unlink "dump_tf_waypoints";
# Big Test here - if this is first waypoint for ships in this task force
# We need to TOSS all of their old waypoints...

$task_force_waypoints[$tf] = 0;

        for ($xx = 1; $xx <= $number_test_ships; $xx++)
            {
            if ($task_force_id[$xx] == $tf)
               {
               print "ship #$xx is in task force $tf\n";
               $following_waypoint[$xx] = 0;
               $number_waypoints[$xx] = 0;
               $speed_target = 0;
               }
             }

close (LOG);
$update = 1;
} #end of (if -f dump_tf_waypoints) 

if ($update == 1)
   {
   &update_db;
   $update = 0;
   }

if (-f "./update_new_ships")
   {
   #semaphore meaning update new ship add page with names from db
   unlink "./update_new_ships";
   open (SELECTOR,">/home/www/game_design/add_ship_middle");
   $command = "";
   $command = "select how_many from how_many_hulls";
   $sth=$dbh-> query($command);
   die "Error with command $command\n" unless (defined $sth);
   @arr=();
   while (@arr = $sth->fetchrow)
         {
         ($number_hulls) = @arr;
         }  
   print "There are $number_hulls ship hulls on file\n";
   for ($xx = 1; $xx <= $number_hulls; $xx++)
       {
       $command = "select class from master_hull_table where hull_id = $xx";
       $sth=$dbh-> query($command);
       die "Error with command $command\n" unless (defined $sth);
       @arr=();
       while (@arr = $sth->fetchrow)
             {
             ($class_name) = @arr;
             }
       print SELECTOR "<option>$class_name\n";
       }
       close (SELECTOR);
       $cmd = "cat /home/www/game_design/add_ship_top /home/www/game_design/add_ship_middle /home/www/game_design/add_ship_bottom > /home/www/game_design/add_test_ship2.html";
       system $cmd;
       $cmd = "cat /home/www/game_design/combat_upper /home/www/game_design/add_ship_middle /home/www/game_design/combat_mid /home/www/game_design/add_ship_middle /home/www/game_design/combat_lower > /home/www/game_design/combat_sim.html";
       system $cmd;
}

if (-f "./add_ship") { # If semaphore present - load up new ships
	unlink "./add_ship";
        $command = "";
        $command = "select how_many from how_many_ships";
        $sth=$dbh-> query($command);
        die "Error with command $command\n" unless (defined $sth);
        @arr=();
        while (@arr = $sth->fetchrow)
        {
        ($new_number_test_ships) = @arr;
        }
	print "Old Number $number_test_ships, New Number $new_number_test_ships\n";
        $old_number = $number_test_ships + 1;
	if ($new_number_test_ships != $number_test_ships) { 
	#this means there were indeed some new ships to retrieve
	#only retrieve the new ships - the data on file for the old ships is no doubt
	#obsolete by many impulses	

		for ($current_ship = ($number_test_ships + 1); $current_ship <= $new_number_test_ships; $current_ship++) {

        $command = "select ship_id, ship_name, ship_owner, ship_country, ship_heading, ship_x, ship_y, ship_speed, ship_max_speed, ship_sighting_range, ship_sight_factor, hull_class, depth, task_force,ship_class, crew_skill from master_ship_chart where ship_id = $current_ship";

	$sth = $dbh -> query($command);
	die "Error with command: $command\n" unless (defined $sth);

	# iterate thru the returned rows

	@arr = ($sth->fetchrow);
        {
	($ship_id[$current_ship],$ship_name[$current_ship],$ship_owner[$current_ship],$ship_country[$current_ship],$ship_course[$current_ship],$ship_x[$current_ship],$ship_y[$current_ship],$ship_speed[$current_ship],$max_speed[$current_ship],$ship_sighting_range[$current_ship],$ship_sight_factor[$current_ship], $hull_class[$current_ship], $depth[$current_ship], $task_force_id[$current_ship],$ship_class[$current_ship],$crew_skill[$current_ship] ) = @arr;
        }
       if ( ($ship_country[$current_ship] eq "none") && ($hull_class[$current_ship] eq "FR"))
          {
          $ship_country[$current_ship] = "British";
          }

        if ($task_force_id[$current_ship] > $number_taskforces)
        {
        $task_force_id[$current_ship] = 0;
        }
        $org_max_speed[$current_ship] = $max_speed[$current_ship];
	#print "depth of new ship is $depth[$current_ship]\n";
	#exit;
	$course_target[$current_ship] = -1;
	$speed_target[$current_ship] = -999;
	$depth_target[$current_ship] = -999;
	$number_waypoints[$current_ship] = 0;
        $following_waypoint[$current_ship] = 0;
	$old_distance[$current_ship] = 0;
        $eta[$current_ship] = 0;
        $waypoint_pause[$current_ship]  = "FALSE";
        $ship_status[$current_ship] = "*";
        $sinking[$current_ship] = -99;
        $zoom[$current_ship] = 1;
        $delta_x[$current_ship] = 0;
        $delta_y[$current_ship] = 0;
         
### Need to read in hull and gun information for newly added ships.

$got_match = 0;
for ($xx = 1; $xx <= $number_hulls; $xx++)
    {
    $command = "select class,flotation from master_hull_table where hull_id = $xx";
    $sth=$dbh->query($command);
    die "Error with command $command\n" unless (defined $sth);
    @arr=();
    while (@arr = $sth->fetchrow)
          {
          ($class,$float) = @arr;
          }
    if ( $class eq $ship_class[$current_ship] )
       {
       $got_match = $xx;
       $flotation[$current_ship] = $float;
       $org_flotation[$current_ship] = $float;
       print "ship_class = $ship_class[$current_ship] Hull_class = $hull_class[$current_ship]\n";
       if ($class eq "Type VIIC")
          {
          $ship_country[$current_ship] = "German";
          }
       }
    }

if ($got_match == 0)
   {
   print "No Hull class on file for ship number $current_ship\n";
   exit;
   }
$command = "select * from master_hull_table where hull_id = $got_match";
$sth=$dbh->query($command);
die "Error with command $command\n" unless (defined $sth);
@arr=();
while (@arr = $sth->fetchrow)
      {
      ($class_junk,$tonnage[$current_ship],$beam[$current_ship],$draft[$current_ship],$max_speed[$current_ship],$cruising_speed[$current_ship],$fuel[$current_ship],$flotation[$current_ship],$belt[$current_ship],$deck[$current_ship],$face[$current_ship],$top[$current_ship],$barbette[$current_ship],$tower[$current_ship],$main_guns[$current_ship],$turret[1][$current_ship],$turret[2][$current_ship],$turret[3][$current_ship],$turret[4][$current_ship],$turret[5][$current_ship],$turret[6][$current_ship],$aa_1[$current_ship],$aa_2[$current_ship],$torp[$current_ship],$s_gun1[$current_ship],$s_gun2[$current_ship],$hull_id[$current_ship],$sec_gun_type[$current_ship],$length[$current_ship] ) = @arr;
      }
# determine gun_id number for each ship now - save time during combat
$match = 0;
for ($xx = 1; $xx <= $num_guns; $xx++)
    {
    if ($main_guns[$current_ship] eq $gun_name[$xx])
       {
       $match = $xx;
       }
    }
if ($match == 0)
   {
   print "Could not find ships main guns in gun table.\n";
   print "current ship = $current_ship\n";
   exit;
   }
open (NEW_SHIP_LOG,">/home/www/game_design/ships_logs/ships_log_$current_ship.txt");
print NEW_SHIP_LOG "<option>New Ship Added to Game</option>\n";
close (NEW_SHIP_LOG);
$gun_id[$current_ship] = $match;
$target[$current_ship] = "0";
	} # end of ship for loop
#update ship counter to the new correct value
$number_test_ships = $new_number_test_ships;
open(LOG,">/home/www/game_design/impulse.log");
print LOG "Added new ships to database\n";
$update = 1;
for ($xx = $old_number; $xx<= $number_test_ships; $xx++)
    {
    if ($ship_country[$xx] eq "German")
       {
       $use_ai[$xx] = "YES";
       $close_target[$xx] = "40";
       $use_broadside[$xx] = "YES";
       $fight_outnumb[$xx] = "NO";
       $float_thresh[$xx] = "25";
       $pursue_target[$xx] = "NO";
       $switch_closest[$xx] = "NO";
       $switch_damaged[$xx] = "NO";
       $return_fire[$xx] = "YES";
       $cap_priority[$xx] = "YES";
       $collis_avoid[$xx] = "YES";
       }
       
    for ($yy=1; $yy<= $number_test_ships; $yy++)
        {
        $collision[$xx][$yy] = 0;
        $collision[$yy][$xx] = 0;
        $sighted[$xx][$yy] = 0;
        $sighted[$yy][$xx] = 0;
        }
    }

} # end of $numbers differ if...

} # end of add_ship semaphore check...

#if update_db exists - we were requested to save the current
#state of the ocean to the sql server unscheduled.

if (-f "update_db")
	{
        print "trying to call update_db sub\n";
        &update_db;
        }
        sub update_db
        {
        open(LOG,">>/home/www/game_design/impulse.log");
	print LOG "Requested to Save db at: $rmon/$rmday/$ryear $rhour:$rmin:$rsec\n";
#	$command = "";
#        $command = "delete from how_many_ships";
#        $sth = $dbh->query($command);
#        die "error with command $command" unless (defined $sth);

        $command = "replace into how_many_ships (how_many) values ($number_test_ships) ";
        $sth = $dbh->query($command);
	die "error with command $command" unless (defined $sth);

#        $command = "delete from master_ship_chart";
#        $sth = $dbh->query($command);
#        die "error with command $command" unless (defined $sth);

#        $command = "delete from german_ai";
#        $sth = $dbh->query($command);
#        die "error with command $command" unless (defined $sth);

#    	$command = "delete from how_many_waypoints";
#        $sth = $dbh->query($command);
#        die "error with command $command" unless (defined $sth);

#        $command = "delete from waypoint_master";
#        $sth = $dbh->query($command);
#        die "error with command $command" unless (defined $sth);
         $waypoint_id = 0;

#	$command = "delete from taskforce_master";
#        $sth = $dbh->query($command);
#        die "error with command $command" unless (defined $sth);

#	$command = "delete from how_many_taskforces";
#        $sth = $dbh->query($command);
#        die "error with command $command" unless (defined $sth);

	for ($current_ship = 1; $current_ship <= $number_test_ships; $current_ship++)
	    {
		$command = "";
		$command = "replace into master_ship_chart (ship_id, ship_name, ship_owner, ship_country, ship_heading, ship_x, ship_y, ship_speed, ship_max_speed, ship_sighting_range, ship_sight_factor, hull_class, depth, task_force, ship_class, crew_skill) values ($ship_id[$current_ship],\"$ship_name[$current_ship]\",\"$ship_owner[$current_ship]\",\"$ship_country[$current_ship]\",$ship_course[$current_ship],$ship_x[$current_ship],$ship_y[$current_ship],$ship_speed[$current_ship],$max_speed[$current_ship],$ship_sighting_range[$current_ship],$ship_sight_factor[$current_ship], \"$hull_class[$current_ship]\",$depth[$current_ship], $task_force_id[$current_ship],\"$ship_class[$current_ship]\",$crew_skill[$current_ship])";
		$sth = $dbh->query($command);
		die "error with command $command" unless (defined $sth);

                $command = "";
                $command = "replace into targets (ship_id, target) values ($current_ship,\"$target[$current_ship]\")";
                $sth = $dbh->query($command);
                die "error with command $command" unless (defined $sth);
#print "ship country for $current_ship = $ship_country[$current_ship]\n";
                if ($ship_country[$current_ship] eq "German")
                   {
#                   print "about to update $current_ship german_ai record\n";
                   $command = "";
                   $command = "replace into german_ai (use_ai,close_target,use_broadside,fight_outnumb,float_thresh,pursue_target,switch_closest,switch_damaged,ship_id,return_fire,cap_priority,collis_avoid) values (\"$use_ai[$current_ship]\",$close_target[$current_ship],\"$use_broadside[$current_ship]\",\"$fight_outnumb[$current_ship]\",\"$float_thresh[$current_ship]\",\"$pursue_target[$current_ship]\",\"$switch_closest[$current_ship]\",\"$switch_damaged[$current_ship]\",$current_ship,\"$return_fire[$current_ship]\",\"$cap_priority[$current_ship]\",\"$collis_avoid[$current_ship]\")";
                   $sth = $dbh->query($command);
                   die "error with command $command" unless (defined $sth);
		   $command = "";
                   }

		$command = "replace into how_many_waypoints (ship_id, waypoints) values ($current_ship, $number_waypoints[$current_ship])";
		$sth = $dbh->query($command);
		die "error with command $command" unless (defined $sth);
#		print "number of waypoints for ship $current_ship is $number_waypoints[$current_ship]\n";
		if ($number_waypoints[$current_ship] > 0 )
                   {
                   for ($xx = 1; $xx <= $number_waypoints[$current_ship]; $xx++)
		       {
		       $waypoint_id++;
		       $command = "";
		       $command = "replace into waypoint_master (waypoint_id, ship, waypoint_num, waypoint, speed, depth) values ($waypoint_id, $current_ship, $xx, \"$waypoint[$current_ship][$xx]\",0,0)";
#		       print "Command to save waypoints is $command\n";
                       $sth = $dbh->query($command);
                       die "error with command $command" unless (defined $sth);
		       }
                   }
            }
# Save Taskforce Information
        if ($number_taskforces >= 0)
        {
	$command = "replace into how_many_taskforces (how_many) values ($number_taskforces)";
        $sth = $dbh->query($command);
        die "error with command $command" unless (defined $sth);
	if ($number_taskforces > 0)
           {
           for ($xx = 1; $xx <= $number_taskforces; $xx++)
               {
               $command = "replace into taskforce_master (tf_id,tf_name,tf_country, tf_type, num_waypoints, tf_speed, tf_course, tf_depth) values ($xx,\"$task_force[$xx]\",\"$task_force_country[$xx]\", \"$task_force_type[$xx]\",$task_force_waypoints[$xx],$task_force_speed[$xx],\"$task_force_course[$xx]\",$task_force_depth[$xx])";
#               print "command to save tf's is $command\n";
                       $sth = $dbh->query($command);
                       die "error with command $command" unless (defined $sth);
               }
           }
        }
	unlink "./update_db";
        close (LOG);
	} #end of update_db subroutine

if (-f "delete_ship")
    {
    open(LOG,">>/home/www/game_design/impulse.log");
    open (DEL,"./delete_ship") || die "Could not open delete_ship\n";
    while (<DEL>)
         {
         chop;
         $pid = $_;
         }
    print LOG "Pidof ship to kill is $pid\n";
    open (SHIP,"delete_ship.$pid");
    while (<SHIP>)
         {
         chop;
         $killship = $_;
         }
    print LOG "Asked to kill ship $killship\n";
    $cmd = "rm -rf /home/www/game_design/ships_logs/ships_log_$killship.txt";
    system $cmd;
    $cmd = "rm -rf /home/www/game_design/ships_logs/ship_log.$killship.html";
    system $cmd;
    for ($XX = $killship; $XX<= ($number_test_ships - 1); $XX++)
        {
        $next_ship = $XX + 1;
        $ship_id[$XX] = $XX;
        $gun_id[$XX] = $gun_id[$XX+1];
        $ship_name[$XX] = $ship_name[$XX+1];
        $ship_owner[$XX] = $ship_owner[$XX+1];
	$ship_country[$XX] = $ship_country[$XX+1];
	$hull_class[$XX]  = $hull_class[$XX+1];
        $ship_class[$XX] = $ship_class[$XX+1];
        $crew_skill[$XX] = $crew_skill[$XX+1];
	$depth[$XX] = $depth[$XX+1];
	$task_force_id[$XX] = $task_force_id[$XX+1];
        $ship_course[$XX] = $ship_course[$XX+1];
        $ship_x[$XX] = $ship_x[$XX+1];
        $ship_y[$XX] = $ship_y[$XX+1];
        $delta_x[$XX] = $delta_x[$XX+1];
        $delta_y[$XX] = $delta_y[$XX+1];
        $zoom[$XX] = $zoom[$XX+1];
        $ship_speed[$XX] = $ship_speed[$XX+1];
	$max_speed[$XX] = $max_speed[$XX+1];
        $ship_sighting_range[$XX] = $ship_sighting_range[$XX+1];
        $ship_sight_factor[$XX] = $ship_sight_factor[$XX+1];
	$number_waypoints[$XX] = $number_waypoints[$XX+1];
        $following_waypoint[$XX] = $following_waypoint[$XX+1];
        $course_target[$XX] = $course_target[$XX+1];
        $speed_target[$XX] = $speed_target[$XX+1];
        $depth_target[$XX] = $depth_target[$XX+1];
        $old_distance[$XX] = $old_distance[$XX+1];
        $eta[$XX] = $eta[$XX+1];
        $waypoint_pause[$XX] = $waypoint_pause[$XX+1];
        $target[$XX] = $target[$XX+1];
        $ship_status[$XX] = $ship_status[$XX+1];
        $flotation[$XX] = $flotation[$XX+1];
        $org_flotation[$XX] = $org_flotation[$XX+1];
        $org_max_speed[$XX] = $org_max_speed[$XX+1];
        if ($num_torps > 0)
           {
           for ($j = 1; $j <= $num_torps; $j++)
               {
               $torp_id = $j + 1000;
               if ($torp_launcher[$torp_id] == $next_ship)
                  {
                  $torp_launcher[$torp_id] = $XX;
                  }
                }
            }
        if ($ship_country[$XX+1] eq "German")
           {
           $use_ai[$XX] = $use_ai[$XX+1];
           $close_target[$XX] = $close_target[$XX+1];
           $use_broadside[$XX] = $use_broadside[$XX+1];
           $fight_outnumb[$XX] = $fight_outnumb[$XX+1];
           $float_thresh[$XX] = $float_thresh[$XX+1];
           $pursue_target[$XX] = $pursue_target[$XX+1];
           $switch_closest[$XX] = $switch_closest[$XX+1];
           $switch_damaged[$XX] = $switch_damaged[$XX+1];
           $return_fire[$XX] = $return_fire[$XX+1];
           $cap_priority[$XX] = $cap_priority[$XX+1];
           $collis_avoid[$XX] = $collis_avoid[$XX+1];
           }
        $up1 = $XX + 1;
        $cmd = "mv /home/www/game_design/ships_logs/ships_log_$up1.txt /home/www/game_design/ships_logs/ships_log_$XX.txt";
        system $cmd;
        $cmd = "mv /home/www/game_design/ships_logs/ship_log.$up1.html /home/www/game_design/ships_logs/ship_log.$XX.html";
        system $cmd;
        }
     unlink "./delete_ship";
     unlink "delete_ship.$pid";
     $number_test_ships = $number_test_ships - 1;
     &update_db;
    }	
close(LOG);

# routines above are polled during idle time before an impulse..
# Conduct an impulse every 20 seconds...
while( ($rsec/20) == int($rsec/20)) { # Determines when we conduct an update

open(LOG,">>/home/www/game_design/impulse.log");

$impulse = $impulse + 1;
$game_ticks = $game_ticks + 1;

if ($game_ticks == 60)
   {
   $game_hours = $game_hours + 1;
   $game_ticks = 0;
   }

if ($game_hours == 24)
   {
   $game_day = $game_day + 1;
   $game_hours = 0;
   }

# if ( ($game_day == 32) && ( ($game_month == 1) || ($game_month == 3) || ($game_month == 5) || ($game_month == 7) || ($game_month == 8) || or ($game_month == 10) || ($game_month == 12) ) )  
if ($game_day == 32)
   {
   $game_month = $game_month + 1;
   $game_day = 1;
   }

if ( ($game_day == 29) && ($game_month == 2) )
   {
   $game_month = $game_month + 1;
   $game_day = 1; 
   }

if ( ($game_day == 31) && ( ($game_month == 4) || ($game_month == 6) || ($game_month == 9) || ($game_month == 1)) )
   {
   $game_month = $game_month + 1;
   $game_day = 1; 
   }
if ($game_month == 13)
   {
   $game_year = $game_year + 1;
   $game_month = 1;
   }

open (IMP,">./what_imp") || die "Could not open what_imp for writing\n";
print IMP "$impulse:$game_ticks:$game_hours:$game_day:$game_month:$game_year\n";
close (IMP);
print "Processing Impulse #$impulse\n";
#Above keeps an updated record of what impulse we are on

# keep track of zig-zag interval for convoys here
print "There are $num_convoys to move out this impulse.\n";
print "and there are $number_torps torpedoes to track.\n";
for ($hh = 1; $hh <= $num_convoys; $hh++)
    {
    print "working on convoy #$hh\n";
    $zig_time[$hh] = $zig_time[$hh] - 1;
    print "zig countdown = $zig_time[$hh]\n";
    if ($zig_time[$hh] == 0)
       {
       print "time for a zig!\n";
       if ($convoy_course[$hh] == ($start_course[$hh] - $zig_offset[$hh]) )
          {
          $convoy_course[$hh] = $start_course[$hh] + $zig_offset[$hh];
          if ($convoy_course[$hh] > 360)
             {
             $convoy_course[$hh] -= 360;
             }
          }
          else
          {
          $convoy_course[$hh] = $start_course[$hh] - $zig_offset[$hh];
          if ($convoy_course[$hh] < 0)
             {
             $convoy_course[$hh] += 360;
             }
          }
       for ($tt = 1; $tt<= $number_test_ships; $tt++)
           {
#           print "checking to see if $ship_name[$tt] is in a convoy...\n";
           if ($task_force_id[$tt] == $convoy[$hh])
              {
#              print "Yep - he's in this convoy - $hh\n";
              $course_target[$tt] = 450 - $convoy_course[$hh];
              if ($course_target[$tt] > 360)
                 {
                 $course_target[$tt] -= 360;
                 }
              $speed_target[$tt] = $convoy_speed[$hh];
              }
           }
       $zig_time[$hh] = $zig_interval[$hh];
     }
    }
print LOG "Impulse #$impulse at: $rmon/$rmday/$ryear $rhour:$rmin:$rsec\n";
print LOG "GameTime is $game_month/$game_day/$game_year $game_hours:$game_ticks\n";
#close(LOG);

# Handle the ship movement here......
#debug2

for ($current_ship = 1; $current_ship <= $number_test_ships; $current_ship++) {

   if ($depth[$current_ship] > 0)
      {
      $max_speed[$current_ship] = 10;
      }

if ($ship_speed[$current_ship] > $max_speed[$current_ship])
   {
   $speed_target[$current_ship] = $max_speed[$current_ship];
   }

if ( $speed_target[$current_ship] > -999)
   {
   if ($speed_target[$current_ship] > $max_speed[$current_ship])
      {
      $speed_target[$current_ship] = $max_speed[$current_ship];
      }
   }
#### NEW ADDITION ####
# $course_target[$ship_ID] is new desired heading.

if ($ship_course[$current_ship] > 360)
   {
   $ship_course[$current_ship] -= 360;
   }

open(LOG,">>/home/www/game_design/impulse.log");
if ($flotation[$current_ship] < $org_flotation[$current_ship] * .16)
   {
#   print LOG "<option>$game_time_stamp: We have no power to maneuver with!\n";
   $course_target[$current_ship] = -1;
   }

if ($course_target[$current_ship] != -1)
   {
   if ($course_target[$current_ship] >= $ship_course[$current_ship])
      {
###      print LOG "course target: $course_target[$current_ship] > ship course:$ship_course[$current_ship] - adjusting upward\n";     
### Preceding line put tons of garbage in impulser.log

      if ($course_target[$current_ship] - $ship_course[$current_ship] <= 20)
         {
         $ship_course[$current_ship] = $course_target[$current_ship];
	 $course_target[$current_ship] = -1;
         }
         else
         {
	 # here - course_target is greater than current course,
         # need to see if difference is greater than 180 - if so,
         # turn ship is less obvious direction.
         $difference = $course_target[$current_ship] - $ship_course[$current_ship];
         if ($difference > 180)
		{
		$total_difference = $ship_course[$current_ship] + (360 - $course_target[$current_ship]);
		if ($total_difference <= 20)
		   {
		   $ship_course[$current_ship] = $course_target[$current_ship];
		   $course_target[$current_ship] = -1;
		   }
                   else
                   {
                   $ship_course[$current_ship] -= 20;
		   if ($ship_course[$current_ship] < 0)
                      {
                      $ship_course[$current_ship] += 360;
		      }
		   }
                 } # end of difference > 180...
		else
		{
		#this means difference < 180...
		$ship_course[$current_ship] += 20;
		}

         } # end of else current course diff > 20....
 
     } # end of if target course > current course....
     else
     {
###      print LOG "course target: $course_target[$current_ship] < ship course $ship_course[$current_ship] - adjusting downward\n";
       if ($ship_course[$current_ship] - $course_target[$current_ship] <= 20)
          {
          $ship_course[$current_ship] = $course_target[$current_ship];
	  $course_target = -1;
          }
          else
          {
	  if ( ($ship_course[$current_ship] - $course_target[$current_ship]) > 180)
	     {
	     $difference = $course_target[$current_ship] + ( 360 - $ship_course[$current_ship]);
	     if ($difference <= 20)
                {
		$ship_course[$current_ship] = $course_target[$current_ship];
		$course_target[$current_ship] = -1;
		}
		else
		{
		$ship_course[$current_ship] += 20;
		if ($ship_course[$current_ship] > 360)
			{
			$ship_course[$current_ship] -= 360;
			}
		}
              } #end of is courses diff > 180?
	      else
              {
              $ship_course[$current_ship] -= 20;
	      } 
          }
      } #end of if target course < current course...
  close(LOG);
  } #end of if course_target != -1...
#	print "current_ship = $current_ship course = $ship_course[$current_ship]\n";
#print "speed_target for $current_ship is: $speed_target[$current_ship]\n";
if ( $speed_target[$current_ship] >  -999)
   {
#   print "speed_target = $speed_target[$current_ship]\n";
   if ($speed_target[$current_ship] > $ship_speed[$current_ship])
      {
      $ship_speed[$current_ship]+=5;
      if ($ship_speed[$current_ship] >= $speed_target[$current_ship])
         {
	 $ship_speed[$current_ship] = $speed_target[$current_ship];
         $speed_target[$current_ship] = -999;
         }
      }
      else
     {
     $ship_speed[$current_ship]-=5;
     if ($ship_speed[$current_ship] <= $speed_target[$current_ship])
         {
	 $ship_speed[$current_ship] = $speed_target[$current_ship];
         $speed_target[$current_ship] = -999;
         }
     }
   }

#print "depth target = $depth_target[$current_ship]\n";
if ( $depth_target[$current_ship] > -999)
   {
#   print "This depth target is not equeal to -999\n";
   if ($depth_target[$current_ship] > $depth[$current_ship])
      {
      $depth[$current_ship]+=15;
      if ($depth[$current_ship] >= $depth_target[$current_ship])
         {
	 $depth[$current_ship] = $depth_target[$current_ship];
         $depth_target[$current_ship] = -999;
         }
      }
      else
     {
     $depth[$current_ship]-=15;
     if ($depth[$current_ship] <= $depth_target[$current_ship])
         {
	 $depth[$current_ship] = $depth_target[$current_ship];
         $depth_target[$current_ship] = -999;
         }
     }
   }

### Waypoints are implemented here

# first check and see if current ship has any

if (($number_waypoints[$current_ship] > 0) && ($waypoint_pause[$current_ship] eq "FALSE") )
   {
   $distance = 0; # reset for the next ship - Doh!
   if ($following_waypoint[$current_ship] == 1)
      {

      # Ship has a waypoint and is following it. 
      # At least it STARTED following it.
#      print "ship $current_ship is following a waypoint\n";
      $distance = sqrt( ( ($waypoint_x[$current_ship] - $ship_x[$current_ship]) ** 2) + ( ($waypoint_y[$current_ship] - $ship_y[$current_ship]) ** 2) );
#      print "distance = $distance, old distance = $old_distance[$current_ship]\n";
#      print "course target = $course_target[$current_ship]\n";

      # This next section is for instantaneous course corrections.
          $delta_x = ($waypoint_x[$current_ship] - $ship_x[$current_ship]);
          $delta_y = ($waypoint_y[$current_ship] - $ship_y[$current_ship]);
          $heading = atan2($delta_y,$delta_x);
          $heading_deg = $heading * (180 / $pi);
          $pretty_ship_course = 450 - $heading_deg;
          if ($pretty_ship_course > 360)
             {
             $pretty_ship_course -= 360;
             }
          $shipcourse = 450 - $pretty_ship_course;
          if ($shipcourse > 360)
             {
             $shipcourse -= 360;
             }
           $course_target[$current_ship] = $shipcourse;

      if ($old_distance[$current_ship] > $distance)
         {
         $diff_distance =  $old_distance[$current_ship] - $distance;
         $eta[$current_ship] = int($distance / $diff_distance );
         $old_distance[$current_ship] = $distance;
#         print "Distance Change = $diff_distance, ETA is: $eta[$current_ship]\n";
         }
        else
         {
         if ($distance < 10)
            { 
#	    print "We have arrived at our destination!\n";
	    $old_distance[$current_ship] = 999990;
            $speed_target[$current_ship] = 0;
	    $following_waypoint[$current_ship] = 0;
            $number_waypoints[$current_ship] -=1;
            $eta[$current_ship] = 0;
            if ($number_waypoints[$current_ship] > 0)
               {
               for ($xx = 1; $xx <= $number_waypoints[$current_ship]; $xx++)
                   {
                   $waypoint[$current_ship][$xx] = $waypoint[$current_ship][$xx+1];
                   }
               }
            } 

         }
      }
      else
      {

       # Ship HAS a waypoint - but is not following it yet.
       # Parse out the fields and instruct ship to begin following it.

#       print "$current_ship Ship is NOT following a waypoint YET\n";
       if ($waypoint[$current_ship][1] =~ /^(.\d*),(.\d*),(.\d*),(.\d*)/)
          {
          $waypoint_x[$current_ship] = $1;
          $waypoint_y[$current_ship] = $2;
          $waypoint_depth[$current_ship] = $3;
          $waypoint_speed[$current_ship] = $4;
          $speed_target[$current_ship] = $waypoint_speed[$current_ship];
          $depth_target[$current_ship] = $waypoint_depth[$current_ship];
          $delta_x = ($waypoint_x[$current_ship] - $ship_x[$current_ship]);
          $delta_y = ($waypoint_y[$current_ship] - $ship_y[$current_ship]);
          $heading = atan2($delta_y,$delta_x);
          $heading_deg = $heading * (180 / $pi);
          $pretty_ship_course = 450 - $heading_deg;
          if ($pretty_ship_course > 360)
             {
             $pretty_ship_course -= 360;
             }
          $shipcourse = 450 - $pretty_ship_course;
          if ($shipcourse > 360)
             {
             $shipcourse -= 360;
             }
           $course_target[$current_ship] = $shipcourse;
           $following_waypoint[$current_ship] = 1;
           $old_distance[$current_ship] = sqrt( ( ($waypoint_x[$current_ship] - $ship_x[$current_ship]) ** 2) + ( ($waypoint_y[$current_ship] - $ship_y[$current_ship]) ** 2) );
#           print "waypoint is $waypoint_x[$current_ship],$waypoint_y[$current_ship] using a course of $pretty_ship_course\n";
           }
        }
   }

# second if it does - calculate a target course to get there

# compute range

# check range against last turns range

# if new range > last turns - waypoint reached - stop ship...




	$ship_heading[$current_ship] = $ship_course[$current_ship] * $pi / 180;
	$speed[$current_ship] = $ship_speed[$current_ship] * 0.1666667;
#	print "ship speed = $ship_speed[$current_ship], also $ship_speed[1]\n";
	$delta_x[$current_ship] = $speed[$current_ship] * cos($ship_heading[$current_ship]);
	$delta_y[$current_ship] = $speed[$current_ship] * sin($ship_heading[$current_ship]);
#	print "deltas x,y $delta_x[$current_ship],$delta_y[$current_ship]\n";
###	$ship_x[$current_ship] = $ship_x[$current_ship] + $delta_x[$current_ship];
###	$ship_y[$current_ship] = $ship_y[$current_ship] + $delta_y[$current_ship];
	} # end of main $current_ship loop

# calculate torpedo deltas here
    if ($number_torps > 0)
       {
        for ($current = 1; $current <= $number_torps; $current++)
            {
            $current_torp = $current + 1000;
            print "current_torp = $current_torp, status = $torp_status[$current_torp]\n";
            if ($torp_duration[$current_torp] > 0)
               {
               if ( ($torp_status[$current_torp] eq "active") || ($torp_status[$current_torp] eq "arming"))
                  {
                  $zcourse = 450 - $torp_course[$current_torp];
                  if ($zcourse > 360)
                     {
                     $zcourse -= 360;
                     }
                  $tcourse = $zcourse  * $pi / 180;
#                  print "for torp_course of $torp_course[$current_torp] tcours is $tcourse\n";
                  $tspeed = $torp_speed[$current_torp] * 0.1666667;
                  # handle normally running torps here
                  $torp_delta_x[$current_torp] = $tspeed * cos($tcourse);
                  $torp_delta_y[$current_torp] = $tspeed * sin($tcourse);

                  # more bastardization
                  $delta_x[$current_torp] = $torp_delta_x[$current_torp];
                  $delta_y[$current_torp] = $torp_delta_y[$current_torp];

                  }
                  else
                  {
                  # handle freshly launched torps here
                  $torp_delta_x[$current_torp] = 0;
                  $torp_delta_y[$current_torp] = 0;

                  # more bastardization
                  $delta_x[$current_torp] = $torp_delta_x[$current_torp];
                  $delta_y[$current_torp] = $torp_delta_y[$current_torp];

                  $torp_status[$current_torp] = "arming";
                  }
               $torp_duration[$current_torp]--;
               if ($torp_duration[$current_torp] == 3)
                  {
                  $torp_status[$current_torp] = "active";
                  }
               # just for now
               $torp_x[$current_torp] += $torp_delta_x[$current_torp];
               $torp_y[$current_torp] += $torp_delta_y[$current_torp]; 

               # more bastardization
               $ship_x[$current_torp] = $torp_x[$current_torp];
               $ship_y[$current_torp] = $torp_y[$current_torp];
               }
               else
                  {
                  # spent torpedoes come here to die
                  # need to log an entry in the subs log that his
                  # torpedo ran out and failed to hit anything.
                  # sending a ship to 999999,999999 could be bad...
                  $torp_status[$current_torp] = "spent";
                  $torp_x[$current_torp] = 999999;
                  $torp_y[$current_torp] = 999999;
                  $torp_speed[$current_torp] = 0;

                  # more bastardization
                  $ship_x[$current_torp] = $torp_x[$current_torp];
                  $ship_y[$current_torp] = $torp_y[$current_torp];
                  }
               }
            }
# Begin Mike's new improved collision detection formula.
# Need to ensure that only "active" torpedoes can cause collisions.
# and that sunken objects can not be collided with

   $num_things = $number_test_ships + $number_torps;
        for ($counter = 1; $counter <= $num_things; $counter++)
        {
        if ( $counter > $number_test_ships) 
            {
            $current_ship = $counter + (1000 - $number_test_ships);
            }
       else
            {
            $current_ship = $counter;
            }

if ($current_ship > 1000)
   {
   #bastardize ship heading for torps
   print "working on torpedo $current_ship\n";
   $ship_heading[$current_ship] = $torp_course[$current_ship] * $pi / 180;
   # need to give torps a depth so they can collide
   $depth[$current_ship] = 0;
    }
#        print "sinking for $current_ship is $sinking[$current_ship]\n";
# forgot to check if ship was already sinking...
        # bastardization coming up since torps dont "sink" thus sinking array
        # not defined for torps... 
        if ($current_ship > 1000)
           {
           $sinking[$current_ship] = -99;
           #end bastardization 
           }
        if ($sinking[$current_ship] == -99)
           {
        # dont give torps a ships log!
        if ($current_ship < 1001)
           {
           open (SHIPS_LOG,">>/home/www/game_design/ships_logs/ships_log_$current_ship.txt");
           }
        $ship1_endx = $ship_x[$current_ship] + $delta_x[$current_ship];
        $ship1_endy = $ship_y[$current_ship] + $delta_y[$current_ship];
        for ($counter2 = 1; $counter2 <= $num_things; $counter2++)
        {
        if ( $counter2 > $number_test_ships) 
            {
            $other_ship = $counter2 + (1000 - $number_test_ships);
            }
       else
            {
            $other_ship = $counter2;
            }

         if ($other_ship > 1000)
            {
            #bastardize ship heading for torps
            $ship_heading[$other_ship] = $torp_course[$other_ship] * $pi / 180;
            $depth[$other_ship] = 0;
            }
        if ( ($current_ship != $other_ship) && ( $depth[$current_ship] == 0 ) && ($depth[$other_ship] == 0) )
           {
           $collide1 = $collide2 = 0;
           $range_to_ship[$current_ship][$other_ship] = sqrt(($ship_x[$current_ship] - $ship_x[$other_ship]) **2 + ($ship_y[$current_ship] - $ship_y[$other_ship]) **2);
           if ($range_to_ship[$current_ship][$other_ship] < 10)
              {
              $ship2_endx = $ship_x[$other_ship] + $delta_x[$other_ship];
              $ship2_endy = $ship_y[$other_ship] + $delta_y[$other_ship];
              
              if ( ($ship_heading[$current_ship] == $ship_heading[$other_ship]) || ($ship_heading[$current_ship] == ($ship_heading[$other_ship] - $pi) ) )
                   {

### new code - parallel collisions - > north/south
                  if ( ($ship_heading[$current_ship] == ($pi/2)) || ($ship_heading[$current_ship] == (3 * $pi / 2) ) )
                     {
                   if (abs($ship_x[$current_ship] - $ship_x[$other_ship]) < abs($beam[$current_ship]/608 - $beam[$other_ship])/608)
                      {
                      $collide1 = 1;
                      }
                  if (( ($ship_y[$current_ship] < $ship_y[$other_ship]) && ($ship1_endy > $ship2_endy) ) || ( ($ship_y[$current_ship] > $ship_y[$other_ship]) && ($ship1_endy < $ship2_endy) ))
                     {
                     $collide2 = 1;
                     }
                     }

                     else
                     {
### new code - parallel collisions - > other angles
#####
                        $m = tan($ship_heading[$current_ship]);
                        $b1 = $ship_y[$current_ship] - ($m * $ship_x[$current_ship]);
                        $b2 = $ship_y[$other_ship] - ($m * $ship_x[$other_ship]);

                   if (abs($b1 - $b2) < abs($beam[$current_ship]/608 - $beam[$other_ship])/608)
                      {
                      $collide1 = 1;
                      }
                  if (( ($ship_x[$current_ship] < $ship_x[$other_ship]) && ($ship1_endx > $ship2_endx) ) || ( ($ship_x[$current_ship] > $ship_x[$other_ship]) && ($ship1_endx < $ship2_endx) ))
                     {
                     $collide2 = 1;
                     }
                     }

#####
#*** Coll check here                      
                  if ( ($collide1 == 1) && ($collide2 == 1) )
                       {
                       if ($current_ship > 1000)
                          {
                          if ($torp_status[$current_ship] ne "active")
                             {
                             $collide1 = 0;
#                             print "in the collision current_ship was $ship_name[$current_ship] with a status of $torp_status[$current_ship] NO COLLISION\n";
                             }
                             else
                             {
                             $collide1 = 0;
                             print "$ship_name[$other_ship] was struck by a torpedo! Scratch 25 floats\n";
                             $flotation[$other_ship] -= 25;
                             open (SHIP_LOG,">>/home/www/game_design/ships_logs/ships_log_$other_ship.txt");
                             print SHIP_LOG "<option>$game_time_stamp: We have been hit by $ship_name[$current_ship], Flotations are at $flotation[$other_ship]\n";                              
                             close (SHIP_LOG);
                             # Get rid of spent torpedo...
                             $torp_status[$current_ship] = "spent";
                             $torp_x[$current_ship] = 999999;
                             $torp_y[$current_ship] = 999999;
                             $torp_speed[$current_ship] = 0;

                             # more bastardization
                             $ship_x[$current_ship] = $torp_x[$current_ship];
                             $ship_y[$current_ship] = $torp_y[$current_ship];
                             }
                                  
                           }
                        if ($other_ship > 1000)
                           {
                          if ($torp_status[$other_ship] ne "active")
                             {
                             $collide2 = 0;
#                             print "in the collision other_ship was $ship_name[$other_ship] with a status of $torp_status[$other_ship] NO COLLISION\n";
                             }
                             else
                             {
                             $collide2 = 0;
                             print "$ship_name[$current_ship] was struck by a torpedo! Scratch 25 floats\n";
                             $flotation[$current_ship] -= 25;
                             open (SHIP_LOG,">>/home/www/game_design/ships_logs/ships_log_$current_ship.txt");
                             print SHIP_LOG "<option>$game_time_stamp: We have been hit by $ship_name[$other_ship], Flotations are at $flotation[$other_ship]\n";                              
                             close (SHIP_LOG);
                             # Get rid of spent torpedo...
                             $torp_status[$other_ship] = "spent";
                             $torp_x[$other_ship] = 999999;
                             $torp_y[$other_ship] = 999999;
                             $torp_speed[$other_ship] = 0;

                             # more bastardization
                             $ship_x[$other_ship] = $torp_x[$other_ship];
                             $ship_y[$other_ship] = $torp_y[$other_ship];
                              }
                            }
                        }
                  if ( ($collide1 == 1) && ($collide2 == 1) )
                     {
                     print "according to Mike's special case parallel code, $ship_name[$current_ship] and $ship_name[$other_ship] have collided.\n";
                     print SHIPS_LOG "<option>According to Mike's special case Parallel detection code we have collided with $ship_name[$other_ship]\n";

                   if ($other_ship < 1000)
                      {
                      open (OTHER_LOG,">>/home/www/game_design/ships_logs/ships_log_$other_ship.txt");
                      print OTHER_LOG "<option>$game_time_stamp Argh! Some knucklehead just collided with us! We are starting to Sink!</option>\n";
                      }
                   print "$ship_name[$current_ship] just collided with $ship_name[$other_ship]\n";
                   if ($current_ship < 1000)
                      {
                      print SHIPS_LOG "<option>$game_time_stamp Argh! Some knucklehead just collided with us! We are starting to Sink!</option>\n";
                      }

# prepare ships for sinking
# Let torps sink for now..
# change ships depth > 0 so they dont re-collide

                   $ship_status[$current_ship] = "s";
                   $ship_status[$other_ship] = "s";
                   $flotation[$current_ship] = 1;
                   $flotation[$other_ship] = 1;
                   $speed[$current_ship] = 0;
                   $speed[$other_ship] = 0;
                   $speed_target[$current_ship] = 0;
                   $speed_target[$other_ship] = 0;
                   $following_waypoint[$current_ship] = 0;
                   $following_waypoint[$other_ship] = 0;
                   $number_waypoints[$current_ship] = 0;
                   $number_waypoints[$other_ship] = 0;
                   $waypoint_pause[$current_ship] = "FALSE";
                   $waypoint_pause[$other_ship] = "FALSE";
                   $eta[$current_ship] = 0;
                   $eta[$other_ship] = 0;

                   $sinking[$current_ship] = int(rand(5)+1)+1;
                   $sinking[$other_ship] = int(rand(5)+1)+1;
                   if ($current_ship < 1000)
                      {
                      print "$ship_name[$current_ship] will sink in $sinking[$current_ship] more impulses, and $ship_name[$other_ship] in $sinking[$other_ship]\n";
                      print SHIPS_LOG "<option>At the rate we are taking on water, we have $sinking[$current_ship] impulses before we go under...</option>\n";
                      }
                   if ($other_ship < 1000)
                      {
                      print OTHER_LOG "<option>At the rate we are taking on water, we have $sinking[$other_ship] impulses before we go under...</option>\n";
                      close (OTHER_LOG);
                      }
                   }
                  } #end of parallel code test
                  else
                    {
 
                  if ( ($ship_heading[$current_ship] == ($pi/2)) || ($ship_heading[$current_ship] == (3 * $pi / 2) ) )
                     {
                     $Xintersect = $ship_x[$current_ship];
                     $m2 = tan($ship_heading[$other_ship]);
                     $b2 = $ship_y[$other_ship] - ($m2 * $ship_x[$other_ship]);
                     $Yintersect = $m2 * $Xintersect + $b2;
                     }
                  elsif ( ($ship_heading[$other_ship] == ($pi/2)) || ($ship_heading[$other_ship] == (3 * $pi / 2) ) )
                        {
                        $Xintersect = $ship_x[$other_ship];
                        $m1 = tan($ship_heading[$current_ship]);
                        $b1 = $ship_y[$current_ship] - ($m1 * $ship_x[$current_ship]); 
                        $Yintersect = $m1 * $Xintersect + $b1; 
                        }
                  else
                        {
                        $m1 = tan($ship_heading[$current_ship]);
                        $m2 = tan($ship_heading[$other_ship]);
                        $b1 = $ship_y[$current_ship] - ($m1 * $ship_x[$current_ship]);
                        $b2 = $ship_y[$other_ship] - ($m2 * $ship_x[$other_ship]);
                        $Xintersect = ($b1 - $b2) / ($m2 - $m1);
                        $Yintersect = $m1 * $Xintersect + $b1;
                        }
              #    $collide1 = $collide2 = 0;
                 if ( ($ship_y[$current_ship] < $Yintersect) && ($ship1_endy > $Yintersect) )
                     {
                     $collide1 = 1;
                     }

                  elsif ( ($ship_y[$current_ship] > $Yintersect) && ($ship1_endy < $Yintersect) )
                        {
                        $collide1 = 1;
                        }

                  elsif ( abs($ship_y[$current_ship] - $Yintersect) < 1 )
                        {
                        $collide1 = 1;
                        }

                 if ( ($ship_y[$other_ship] < $Yintersect) && ($ship2_endy > $Yintersect) )
                     {
                     $collide2 = 1;
                     }

                  elsif ( ($ship_y[$other_ship] > $Yintersect) && ($ship2_endy < $Yintersect) )
                        {
                        $collide2 = 1;
                        }

                  elsif ( abs($ship_y[$other_ship] - $Yintersect) < 1 )
                        {
                        $collide2 = 1;
                        }

                  if ( ($ship_x[$current_ship] < $Xintersect) && ($ship1_endx > $Xintersect) )
                     {
                     $collide1 = 1;
                     }

                  elsif ( ($ship_x[$current_ship] > $Xintersect) && ($ship1_endx < $Xintersect) )
                        {
                        $collide1 = 1;
                        }

                  elsif ( abs($ship_x[$current_ship] - $Xintersect) < 1 )
                        {
                        $collide1 = 1;
                        }
 
                 if ( ($ship_x[$other_ship] < $Xintersect) && ($ship2_endx > $Xintersect) )
                     {
                     $collide2 = 1;
                     }

                  elsif ( ($ship_x[$other_ship] > $Xintersect) && ($ship2_endx < $Xintersect) )
                        {
                        $collide2 = 1;
                        }

                  elsif ( abs($ship_x[$other_ship] - $Xintersect) < 1 )
                        {
                        $collide2 = 1;
                        }
#**** Coll Check here
                  if ( ($collide1 == 1) && ($collide2 == 1) )
                       {
                       if ($current_ship > 1000)
                          {
                          if ($torp_status[$current_ship] ne "active")
                             {
                             $collide1 = 0;
                             print "in the collision current_ship was $ship_name[$current_ship] with a status of $torp_status[$current_ship] NO COLLISION\n";
                             }
                             else
                             {
                             $collide1 = 0;
                             print "$ship_name[$other_ship] was struck by a torpedo! Scratch 25 floats\n";
                             $flotation[$other_ship] -= 25;
                             open (SHIP_LOG,">>/home/www/game_design/ships_logs/ships_log_$other_ship.txt");
                             print SHIP_LOG "<option>$game_time_stamp: We have been hit by $ship_name[$current_ship], Flotations are at $flotation[$other_ship]\n";                              
                             close (SHIP_LOG);
                             # Get rid of spent torpedo...
                             $torp_status[$current_ship] = "spent";
                             $torp_x[$current_ship] = 999999;
                             $torp_y[$current_ship] = 999999;
                             $torp_speed[$current_ship] = 0;

                             # more bastardization
                             $ship_x[$current_ship] = $torp_x[$current_ship];
                             $ship_y[$current_ship] = $torp_y[$current_ship];
                              }
                            }
                        if ($other_ship > 1000)
                           {
                          if ($torp_status[$other_ship] ne "active")
                             {
                             $collide2 = 0;
                             print "in the collision other_ship was $ship_name[$other_ship] with a status of $torp_status[$other_ship] NO COLLISION\n";
                             }
                             else
                             {
                             $collide2 = 0;
                             print "$ship_name[$current_ship] was struck by a torpedo! Scratch 25 floats\n";
                             $flotation[$current_ship] -= 25;
                             open (SHIP_LOG,">>/home/www/game_design/ships_logs/ships_log_$current_ship.txt");
                             print SHIP_LOG "<option>$game_time_stamp: We have been hit by $ship_name[$other_ship], Flotations are at $flotation[$current_ship]\n";                              
                             close (SHIP_LOG);
                             # Get rid of spent torpedo...
                             $torp_status[$other_ship] = "spent";
                             $torp_x[$other_ship] = 999999;
                             $torp_y[$other_ship] = 999999;
                             $torp_speed[$other_ship] = 0;

                             # more bastardization
                             $ship_x[$other_ship] = $torp_x[$other_ship];
                             $ship_y[$other_ship] = $torp_y[$other_ship];
                              }
                            }
                        }
                   if ( ($collide1 == 1) && ($collide2 == 1) )
                     {
                     if ($current_ship < 1000)
                        {
                        print SHIPS_LOG "<option>According to Mike's Normal detection code we have collided with $ship_name[$other_ship]\n";
                        print "according to Mike's Normal formula - $ship_name[$current_ship] and $ship_name[$other_ship] has collided\n";
                        print SHIPS_LOG "<option>$game_time_stamp Argh! Some knucklehead just collided with us! We are starting to Sink!</option>\n";
                        }
                     if ($other_ship < 1000)
                        {
                        open (OTHER_LOG,">>/home/www/game_design/ships_logs/ships_log_$other_ship.txt");
                        print OTHER_LOG "<option>$game_time_stamp Argh! Some knucklehead just collided with us! We are starting to Sink!</option>\n";
                        }
                   print "$ship_name[$current_ship] just collided with $ship_name[$other_ship]\n";

# prepare ships for sinking
                   $ship_status[$current_ship] = "s";
                   $ship_status[$other_ship] = "s";
                   $flotation[$current_ship] = 1;
                   $flotation[$other_ship] = 1;
                   $speed[$current_ship] = 0;
                   $speed[$other_ship] = 0;
                   $speed_target[$current_ship] = 0;
                   $speed_target[$other_ship] = 0;
                   $following_waypoint[$current_ship] = 0;
                   $following_waypoint[$other_ship] = 0;
                   $number_waypoints[$current_ship] = 0;
                   $number_waypoints[$other_ship] = 0;
                   $waypoint_pause[$current_ship] = "FALSE";
                   $waypoint_pause[$other_ship] = "FALSE";
                   $eta[$current_ship] = 0;
                   $eta[$other_ship] = 0;

                   $sinking[$current_ship] = int(rand(5)+1)+1;
                   $sinking[$other_ship] = int(rand(5)+1)+1;
                   print "$ship_name[$current_ship] will sink in $sinking[$current_ship] more impulses, and $ship_name[$other_ship] in $sinking[$other_ship]\n";
                   if ($current_ship < 1000)
                      {
                      print SHIPS_LOG "<option>At the rate we are taking on water, we have $sinking[$current_ship] impulses before we go under...</option>\n";
                      } 
                   if ($other_ship < 1000)
                      {
                      print OTHER_LOG "<option>At the rate we are taking on water, we have $sinking[$other_ship] impulses before we go under...</option>\n";
                      close (OTHER_LOG);
                      }  
                     }

                  } # end of non-parallel code
                } #end of < 10 range? (If not dont bother) check
               } #end of other_ship == current_ship check
            } #end of other ship inner loop
	$ship_x[$current_ship] = $ship_x[$current_ship] + $delta_x[$current_ship];
	$ship_y[$current_ship] = $ship_y[$current_ship] + $delta_y[$current_ship];
        if ($current_ship < 1000)
           {
           close (SHIPS_LOG);
           }
        } #end of if already sinking check
#save some variables for submarine processing later
$m1 = tan($ship_heading[$current_ship]);
$b1 = $ship_y[$current_ship] - ($m1 * $ship_x[$current_ship]);
$m[$current_ship] = $m1;
$b[$current_ship] = $b1;
#print "Just assigned values to m and b\n";
#print "they are $m[$current_ship] and $b[$current_ship]\n";
        } #end of main current ship outer loop 

# End of new collision detection formula

open (SHIP_STAT,">/home/www/game_design/ship_status.html") || die "Could not open ship_status.html for writing\n";
open (TF_STAT,">/home/www/game_design/task_force.html") || die "Could not open task_force.html for writing\n";
$header = "<html><META HTTP-EQUIV=\"Refresh\" CONTENT=\"20\"><meta http-equiv=\"Expires\" content=\"Saturday, 12-Nov-94 14:05:51 GMT\"> <head>\n";
$map_header = $header;
$map_header .= "<title>Temporary Text Map for Impulse #$impulse</title>\n";
$map_header .= "</head>\n<tt><nobr>";
$map_header .= "<body text=\"#FFFFFF\" bgcolor=\"#3333FF\" link=\"#FFFF00\" vlink=\"#FFFF00\" alink=\"#FF0000\">\n";

$tf_header = "<html><meta http-equiv=\"Expires\" content=\"Saturday, 12-Nov-94 14:05:51 GMT\"><head>\n<title>Task Force Status Page for Impulse #$impulse</title></head>\n";
$header .= "<title>Ship Status Page for Impulse #$impulse</title>\n";
$header .= "</head>\n";
$header .= "<BODY TEXT=\"#000000\" BGCOLOR=\"#C0C0C0\" LINK=\"#0000EE\" VLINK=\"#551A8B\" ALINK=\"#FF0000\">\n";
$tf_header .= "<body text=\"#000000\" bgcolor=\"#c0c0c0\" link=\"#0000ee\" vlink=\"#551a8b\" alink=\"#ff0000\">\n";
$tf_header .= "NOTE! THIS IS only somewhat ACTIVE YET!<br>\n";
$tf_header .= "<FORM action=\"/cgi-bin/game_design/taskforce.pl\" method= \"post\">\n";
$tf_header .= "<P><CENTER>Task Force Management</CENTER></P>\n";
$tf_header .= "<P>Create Or Delete a Task Force</P>";
print TF_STAT $tf_header;
if ($number_taskforces > 0)
   {
   print TF_STAT "<p>";
   for ($xx = 1; $xx <= $number_taskforces; $xx++)
       {
       print TF_STAT "TF #$xx<input type=\"radio\" value = \"$xx\" name=\"tf\">$task_force[$xx]<br>\n";
       }
   print TF_STAT "<p><input name = \"del_force\" type = \"submit\" value = \"Delete Task Force\"></p>\n";
   print TF_STAT "del dont work yet<br>\n";
   }
   else
   {
   print TF_STAT "NO TASK FORCES DEFINED<br>\n";
   }
print TF_STAT "<p>Name of New TaskForce: <input name=\"taskforce\" type=\"text\" size=\"20\"><input name=\"command\" type=\"submit\" value = \"add_tf\">\n";
print TF_STAT "</P>\n";
print TF_STAT "Country Creating TaskForce: <SELECT name=\"country\">\n";
print TF_STAT "<OPTION VALUE=\"usa\" SELECTED>USA\n";
print TF_STAT "<OPTION VALUE=\"japan\">JAPAN\n";
print TF_STAT "<OPTION VALUE=\"england\">ENGLAND\n";
print TF_STAT "<OPTION VALUE=\"germany\">GERMANY\n";
print TF_STAT "<OPTION VALUE=\"italy\">ITALY\n";
print TF_STAT "<OPTION VALUE=\"japan\">JAPAN\n";
print TF_STAT "<OPTION VALUE=\"other\">other\n";
print TF_STAT "</SELECT><BR>\n";
print TF_STAT "</form>\n";
print TF_STAT "<P><HR></P>\n";

print TF_STAT "<P>Recruit or Dismiss Ships from Current Task Forces</P>\n";
if ($number_taskforces > 0)
   {
   for ($xx = 1; $xx <= $number_test_ships; $xx++)
       {
       print TF_STAT "<form action=\"/cgi-bin/game_design/taskforce.pl\" method= \"post\">\n";
       print TF_STAT "$ship_name[$xx] is in Task Force #";

       for ($tf = 0; $tf <= $number_taskforces; $tf++)
           {
           if ($tf == $task_force_id[$xx])
              {
              print TF_STAT "<input type=\"radio\" value=\"$tf\" name = \"taskforce\" checked = \"1\">$tf \n"; 
              }
              else
              {
              print TF_STAT "<input type=\"radio\" value=\"$tf\" name = \"taskforce\">$tf \n";
              }
            }
       if ($task_force_id[$xx] > 0)
          {
          print TF_STAT "Position in Task Force:";
          for ($qq = 0; $qq<= $task_force_members[$task_force_id[$xx]]; $qq++)
              {
              print TF_STAT "<input type=\"radio\" value = \"$qq\" name = \"tf_position\">$qq \n";
              }
          print TF_STAT "<br>\n";
          }  
       print TF_STAT "<input name=\"command\" type=\"submit\" value = \"add_ship\"><br>\n";
       print TF_STAT "<input name=\"ship_id\" type=\"hidden\" value = \"$xx\">\n";

        print TF_STAT "</form>\n";
        }
    }
 
print TF_STAT "</body></html>\n";
close (TF_STAT);
print SHIP_STAT $header;
$game_time_stamp = "$month[$game_month] $game_day, $game_year";
$display_hours = $game_hours;
$display_minutes = $game_ticks;
if ($game_hours < 10)
   {
   $display_hours = "0" . $game_hours;
   }
if ($game_ticks < 10)
   {
   $display_minutes = "0" . $game_ticks;
   }
$weather = -2;
$visibility = $weather + $brightness[$game_hours];
$game_time_stamp = "$display_hours:$display_minutes On " . $game_time_stamp;
print SHIP_STAT "GameTime: $game_time_stamp.  The Impulser is currently <img src=\"/game_design/status.gif\"><br>\n";
print SHIP_STAT "Brightness is $brightness[$game_hours], Weather is currently $weather, Visibility = $visibility<br>\n";
$map_header .= "GameTime: $game_time_stamp<br>\n";
$map_header .= "Brightness is $brightness[$game_hours], Weather is currently $weather, Visibility = $visibility<br>\n";
print SHIP_STAT "<table BORDER=3>\n";
print SHIP_STAT "<tr>\n";
print SHIP_STAT "<td>ID_#</td><td>Name</td><td>Class</td><td>Log</td><td>WPs</td><td>ETA</td><td>TF</td><td>Depth</td><td>Owner</td><td>Country</td><td>Course</td><td>Knots</td><td>Max_spd</td><td>X_Co_ord</td><td>Y_Co_ord</td><td>Optics</td>";
for ($xx = 1; $xx <= $number_test_ships; $xx++)
	{
        if (! ($task_force[$task_force_id[$xx]] =~ /convoy/) ) 
           {
	   print SHIP_STAT "<td>Range Ship_$xx</td><td>Bearing Ship_$xx</td>";
           }
	}
print SHIP_STAT "</tr>\n";
$non_convoys = 0;
for ($current_ship = 1; $current_ship <= $number_test_ships; $current_ship++)
 {
    if ($flotation[$current_ship] <= 0)
       {
       $ship_status[$current_ship] = "S";
       $speed_target[$current_ship] = 0;
       $target[$current_ship] = 0;
       }
 if (! ($task_force[$task_force_id[$current_ship]] =~ /convoy/) )
   {
#   print "current_ship = $current_ship, it's tf_id is $task_force_id[$current_ship], it's tf_name is $task_force[$task_force_id[$current_ship]]\n";
   $non_convoys++;
   if ($current_ship / 2 == int($current_ship/2) )
      {
      $cell_color = " BGcolor=\"999999\" ";
      }
      else
      {
      $cell_color = " BGcolor=\"009900\" ";
      }
   print SHIP_STAT "<tr>\n";
   print SHIP_STAT "<TD align=\"center\"$cell_color>$current_ship</TD>\n";
   print SHIP_STAT "<TD align=\"center\"$cell_color><a href=\"/cgi-bin/game_design/modify_ship.pl?ship=$current_ship\">$ship_name[$current_ship]</a></TD>\n";
   print SHIP_STAT "<TD align=\"center\"$cell_color>$hull_class[$current_ship]</td>\n";
   print SHIP_STAT "<td align=\"center\"$cell_color><a href=\"/game_design/ships_logs/ship_log.$current_ship.html\">$ship_status[$current_ship]</a></td>";
   $cell_color .= " width=\"20\" height=\"40\" ";
   print SHIP_STAT "<td align=\"center\"$cell_color><a href=\"/cgi-bin/game_design/show_waypoints.pl?ship=$current_ship\">";
   if ($waypoint_pause[$current_ship] eq "TRUE")
      {
      print SHIP_STAT "<blink>$number_waypoints[$current_ship]</blink></a></td>\n";
      }
   else
      {
      print SHIP_STAT "$number_waypoints[$current_ship]</a></td>\n";
      }
   print SHIP_STAT "<td align=\"center\"$cell_color>$eta[$current_ship]</td>\n";
   print SHIP_STAT "<TD align=\"center\"$cell_color><a href=\"/cgi-bin/game_design/modify_tf.pl?tf=$task_force_id[$current_ship]\">$task_force_id[$current_ship]</a></td>\n";
   print SHIP_STAT "<TD align=\"center\"$cell_color>$depth[$current_ship]</td>\n";
   print SHIP_STAT "<TD align=\"center\"$cell_color>$ship_owner[$current_ship]</TD>\n";
   $flagicon = "none";
   if ($ship_country[$current_ship] eq "German")
      {
      $flagicon = "germany.gif";
      }
   if ($ship_country[$current_ship] eq  "British")
      {
      $flagicon = "british.gif";
      }
      if ($ship_country[$current_ship] eq "japan")
         {
         $flagicon = "japan2.gif";
   }
if ($ship_country[$current_ship] eq "usa")
   {
   $flagicon = "usflag.gif";
   }
if ($flagicon eq "none")
   {
   print SHIP_STAT "<td align=\"center\"$cell_color>$ship_country[$current_ship]</td>\n";
   }
   else
   {
   print SHIP_STAT "<td align = \"center\"$cell_color><img src=\"$flagicon\"></td>\n";
   }
} # end of convoy check
$pretty_ship_course[$current_ship] = int(450 - $ship_course[$current_ship]);
        if ($pretty_ship_course[$current_ship] > 360)
           {
           $pretty_ship_course[$current_ship] -= 360;
           }
 if (! ($task_force[$task_force_id[$current_ship]] =~ /convoy/) )
   {
#   print "current_ship = $current_ship, it's tf_id is $task_force_id[$current_ship], it's tf_name is $task_force[$task_force_id[$current_ship]]\n";

   print SHIP_STAT "<td align=\"center\"$cell_color>$pretty_ship_course[$current_ship]</td>\n";
   print SHIP_STAT "<td align=\"center\"$cell_color>$ship_speed[$current_ship]</td>\n";
   print SHIP_STAT "<td align=\"center\"$cell_color>$max_speed[$current_ship]</td>\n";
   $pretty_x = int($ship_x[$current_ship]* 100)/100;
   print SHIP_STAT "<td align=\"center\"$cell_color>$pretty_x</td>\n";
   $pretty_y = int($ship_y[$current_ship]* 100)/100;
   print SHIP_STAT "<td align=\"center\"$cell_color>$pretty_y</td>\n";
   #print SHIP_STAT "<TD align=\"center\"$cell_color>$ship_sighting_range[$current_ship]</TD>\n";
   print SHIP_STAT "<TD align=\"center\"$cell_color>$ship_sight_factor[$current_ship]</TD>\n";

##$latitude = $ship_y[$current_ship] * $scale_constant;
##$longitude = $ship_x[$current_ship] * (cos($latitude / 180 * $pi) * $scale_constant);
##$pretty_longitude = int($longitude * 100)/100;
##$pretty_latitude = int($latitude * 100)/100;
  }
for ($other_ship =1; $other_ship <= $number_test_ships; $other_ship++)
    {
    if ($current_ship != $other_ship)
        {
	$range_to_ship[$current_ship][$other_ship] = sqrt(($ship_x[$current_ship] - $ship_x[$other_ship]) **2 + ($ship_y[$current_ship] - $ship_y[$other_ship]) **2);
	$pretty_range = int($range_to_ship[$current_ship][$other_ship]);

	$Xdiff = $ship_x[$other_ship] - $ship_x[$current_ship];
	$Ydiff = $ship_y[$other_ship] - $ship_y[$current_ship];

	$dirextion = atan2($Ydiff,$Xdiff)*180/$pi;
	if ($dirextion < 0)
           {
	   $dirextion = $dirextion + 360;
           }

        $pretty_bearing = int($ship_course[$current_ship] - $dirextion);
        if ($pretty_bearing < 0)
           {
           $pretty_bearing += 360;
           }
       $bearing_to_ship[$current_ship][$other_ship] = $pretty_bearing;

          open (SHIPS_LOG,">>/home/www/game_design/ships_logs/ships_log_$current_ship.txt");

# code to determine if we are in danger of colliding with
# another ship - or if we have indeed already done so.
          if ( ($range_to_ship[$current_ship][$other_ship] < 5) && ($depth[$current_ship] == $depth[$other_ship]) ) # was 11
             {
             if ( ($ship_status[$current_ship] ne "S") && ($ship_status[$other_ship] ne "S") )
                {
                print "beginning collision avoidance code routine for $ship_name[$current_ship] and $ship_name[$other_ship]\n";
                print "bearing to ship = $bearing_to_ship[$current_ship][$other_ship]\n";

# part1 of German collision avoidance code
                if ( ($bearing_to_ship[$current_ship][$other_ship] < 360) && ($bearing_to_ship[$current_ship][$other_ship] > 337.5) && ($ship_country[$current_ship] eq "German"))
                    {
                    print "collis_avoid = $collis_avoid[$current_ship]\n";
                    if ($collis_avoid[$current_ship] eq "YES")
                       {
                       print SHIPS_LOG "<option>Adjusting course to avoid colliding with $ship_name[$other_ship]\n";
                       print "$ship_name[$current_ship] is executing a turn to port to miss $ship_name[$other_ship]\n"; 
                       print "target course was $target_course[$current_ship] and bearing to other ship is $bearing_to_ship[$current_ship][$other_ship] and our heading is $ship_course[$current_ship]\n";
                       $target_course[$current_ship] = $ship_course[$current_ship] - 2;
                       }
                    }
# part2 of German collision avoidance code
                elsif ( ($bearing_to_ship[$current_ship][$other_ship] > 0) && ($bearing_to_ship[$current_ship][$other_ship] < 22.5) && ($ship_country[$current_ship] eq "German") )
                      {
                      print "collis_avoid = $collis_avoid[$current_ship]\n";
                      if ($collis_avoid[$current_ship] eq "YES")
                         {
                         print "$ship_name[$current_ship] is executing a turn to starboard to miss $ship_name[$other_ship]\n";
                         print "target course was $target_course[$current_ship] and bearing to other ship is $bearing_to_ship[$current_ship][$other_ship] and our heading is $ship_course[$current_ship]\n";
                         $target_course[$current_ship]= $ship_course[$current_ship] + 2;
                         }
                       }

# sound the collision alarm - only once per incident tho...
                if ($collision[$current_ship][$other_ship] == 0)
                   {
                   print SHIPS_LOG "<option>$game_time_stamp The crew is worried since we are getting dangerously close to $ship_name[$other_ship].</option>\n";
                   print "$ship_name[$current_ship] is dangerously close to colliding with $ship_name[$other_ship]. Collision = $collision[$current_ship][$other_ship]\n";
                   $collision[$current_ship][$other_ship] = 1;
                   }
# need to transplant new collision detection code into here?

# Ships got to 1.2 range - sink them both.
# Or if they got to within 2.2 range and are not running parallel

              } #end of if both ships not sunk check
             } #end of if range to both ships < 5...
             else
             {
             $collision[$current_ship][$other_ship] = 0;
             }
# end of collision determination code

	} # end of if current ship != other ship...
	else
	{
	$pretty_range = "N/A";
	$pretty_bearing = "N/A";
	}
 if (! ($task_force[$task_force_id[$other_ship]] =~ /convoy/) )
   {
   if (! ($task_force[$task_force_id[$current_ship]] =~ /convoy/) )
        {
#        print "current _ship = $current_ship, it's tf = $task_force_id[$current_ship] it's tf_name = $task_force[$task_force_id[$current_ship]]\n";
	print SHIP_STAT "<td align=\"center\"$cell_color>$pretty_range</td>";
	print SHIP_STAT "<td align=\"center\"$cell_color>$pretty_bearing</td>";
        }
   }	
    }# end of other ship loop
   print SHIP_STAT "</tr>\n";
#print "sinking for ship $current_ship is $sinking[$current_ship]\n";
if ($sinking[$current_ship] > 0)
   {
   print "$ship_name[$current_ship] is sinking - has $sinking[$current_ship] impulses left (minus 1) before going under.\n";
   $sinking[$current_ship]--;
   if ($sinking[$current_ship] == 0)
      {
      open (SHIPS_LOG,">>/home/www/game_design/ships_logs/ships_log_$current_ship.txt");
      print SHIPS_LOG "<option>$game_time_stamp: We have sank! Glub! Glub!</option>\n";
      close (SHIPS_LOG);
      print "$ship_name[$current_ship] has just sunk!\n";
      $speed[$current_ship] = 0;
      $ship_status[$current_ship] = "S";
      $speed_target[$current_ship] = 0;
      $flotation[$current_ship] = 0;
      $target[$current_ship] = 0;
      $depth[$current_ship] = 999;
      }
   }

} # end of for test_ship loop

### sighting can go down here...
### visibility determination code
for ($current_ship = 1; $current_ship <= $number_test_ships; $current_ship++)
    {
    $beam_holder = 0;
    if ( ($depth[$current_ship] > 0) && ($depth[$current_ship] < 51) )
       {
       $beam_holder = $beam[$current_ship];
       $beam[$current_ship] = 5;
       } 
#    print "sighting for $current_ship\n";
    open (SHIPS_LOG,">>/home/www/game_design/ships_logs/ships_log_$current_ship.txt");
    for ($other_ship = 1; $other_ship <= $number_test_ships ; $other_ship++)
         {
    $length_holder = 0;
    if ( ($depth[$other_ship] > 0) && ($depth[$other_ship] < 51) )
       {
       $length_holder = $length[$other_ship];
       $length[$other_ship] = 1;
       }
#    print "other ship = $other_ship\n";
         if (! ($other_ship == $current_ship) )
            {
            $bearing = $bearing_to_ship[$other_ship][$current_ship];
            $profile = sqrt( (sin( $bearing * $pi / 180 ) * $length[$other_ship])**2 + (cos( $bearing * $pi / 180) * $beam[$other_ship])**2);
            $sight_distance[$current_ship][$other_ship] =  (1.17 * sqrt($beam[$current_ship]) + 1.17 * sqrt($beam[$other_ship]) * $profile / 5000 + $visibility) * 10;
#            if ( ($sight_distance[$current_ship][$other_ship] >= $range_to_ship[$current_ship][$other_ship]) && ($ship_status[$current_ship] ne "S") && ($ship_status[$other_ship] ne "S") && ($depth[$other_ship] == 0) )
            if ( ($sight_distance[$current_ship][$other_ship] >= $range_to_ship[$current_ship][$other_ship]) && ($ship_status[$current_ship] ne "S") && ($ship_status[$other_ship] ne "S") )
               {
#print "current_ship = $current_ship, other_ship = $other_ship. sighted = $sighted[$current_ship][$other_ship]\n";
#               if ( ($sighted[$current_ship][$other_ship] == 0) && ($depth[$other_ship] == 0) && ($depth[$current_ship] < 51) )
               if ($sighted[$current_ship][$other_ship] == 0) 
                  {
                  # enter log about sighting ship $game_time_stamp
                  if ($ship_country[$current_ship] ne $ship_country[$other_ship])
                     {
                     print "$ship_name[$current_ship] has sighted $ship_name[$other_ship]\n";
                     print SHIPS_LOG "<option>$game_time_stamp Have sighted $ship_name[$other_ship].</option>\n";
                     }
                  $sighted[$current_ship][$other_ship] = 1;
                  }
                }
                else
                {
#print "current_ship = $current_ship, other_ship = $other_ship. sighted = $sighted[$current_ship][$other_ship]\n";
                if ($sighted[$current_ship][$other_ship] == 1)
                   {
                   print "$ship_name[$current_ship] has lost sight of $ship_name[$other_ship]\n";
                   if ( ($ship_country[$current_ship] ne $ship_country[$other_ship]) && ($ship_status[$current_ship] ne "S") )
                       {
                       print SHIPS_LOG "<option>$game_time_stamp Have lost sight of $ship_name[$other_ship].</option>\n";
                       }
                    # Enter log about losing sight of ship
                    $sighted[$current_ship][$other_ship] = 0;
                    }
                 } 
              }
            if ($length_holder > 0)
               {
               $length[$current_ship] = $length_holder;
               $length_holder = 0;
               }
            }
           close (SHIPS_LOG);
           if ($beam_holder > 0)
              {
              $beam[$current_ship] = $beam_holder;
              $beam_holder = 0;
              }
          }
# End of Sighting code.

# CONVOY_STATS
# Now display the Convoy place holders
if ($num_convoys > 0)
   {
#   print "There are exactly $non_convoys ships that do not belong to a convoy.\n";
   for ($current_convoy = 1; $current_convoy <= $num_convoys; $current_convoy++)
       {
       print SHIP_STAT "<tr>\n";
       print SHIP_STAT "<td align=\"center\">$current_convoy</td><td align=\"center\"><a href=\"/cgi-bin/game_design/modify_convoy.pl?convoy=$current_convoy\">$convoy_name[$current_convoy]</a></td><td align=\"center\">convoy</td><td align=\"center\">$convoy_status[$current_convoy]</td><td align=\"center\">$zig_time[$current_convoy]</td><td align=\"center\">$zig_interval[$current_convoy]</td><td align=\"center\">$current_convoy</td><td align=\"center\">N/A</td><td align=\"center\">$convoy_owner[$current_convoy]</td><td align=\"center\">$convoy_country[$current_convoy]</td><td align=\"center\">$convoy_course[$current_convoy]</td><td align=\"center\">$convoy_speed[$current_convoy]</td><td align=\"center\">$convoy_max_speed[$current_convoy]</td><td align=\"center\">N/A</td><td align=\"center\">N/A</td><td align=\"center\">N/A</td>";
      
       for ($xx = 1; $xx <= $non_convoys; $xx++)
           {
           print SHIP_STAT "<td>N/A</td><td>N/A</td>";
           }
       print SHIP_STAT "</tr>\n";
       }
   }
print SHIP_STAT "</TABLE>\n";
$footer = "<a href=\"add_test_ship2.html\">Add A Test Ship</a><br>\n";
#$footer .= "<a href=\"/cgi-bin/game_design/update_ships.pl\">Update Hull List for Above</a><br>\n";
$footer .= "View Strategic <a href=\"/game_design/map.html\">Text Map</a>. Individual Ship Maps: ";
for ($tt = 1; $tt <= $number_test_ships; $tt++)
    {
    $footer .= "<a href=\"/game_design/map_$tt.html\">$tt</a> ";
    }
$footer .= "<br>\n";
$footer .= "<a href=\"/cgi-bin/game_design/reset_ships.pl\">Refloat Ships</a><br>\n";
$footer .= "<a href=\"/cgi-bin/game_design/control.pl\">AI CONTROL</a><br>\n";
$footer .= "<a href=\"task_force.html\">Task Force Manager</a><br>\n";
$footer .= "<a href=\"combat_sim.html\">Combat Simulator</a><br>\n";
$footer .= "<a href=\"http://bigorc.com:4080/sql/\">SQL Interface for DB Queries</a>\n";
print SHIP_STAT $footer;
print SHIP_STAT "<hr>Last Updated: $rmon/$rmday/$ryear $rhour:$rmin:$rsec<br>\n";
print SHIP_STAT "</body></html>\n";
close(SHIP_STAT);
#############################################################################
## COMBAT routines outside of main ship loop since we need the pre-calculated
## range and bearing data for all the ships from above.
#############################################################################
for ($current_ship = 1; $current_ship <= $number_test_ships; $current_ship++)
    {
    if ( $hull_class[$current_ship] ne "FR")
       {
#    print "combat-ship #$current_ship\n";
    if (! $target[$current_ship] == 0 )
       {
#    print "combat-target #$current_ship\n";
       open (SHIPS_LOG,">>/home/www/game_design/ships_logs/ships_log_$current_ship.txt");
       $num_shots = 0;
       $current_gun_id = $gun_id[$current_ship];
       $the_target = $target[$current_ship];
       open (TARGET_LOG,">>/home/www/game_design/ships_logs/ships_log_$the_target.txt");
       if ($ship_status[$the_target] eq "S")
          {
          $target[$current_ship] = 0;
          $ship_status[$current_ship] = "*";
          }
       $the_range = $range_to_ship[$current_ship][$the_target];
       if ($the_range == 0)
          {
          $the_range = 1;
          }
#       print "combat-range $the_range, gun range = $range1[$current_gun_id]\n";
#       print "sighted = $sighted[$current_ship][$the_target]\n";
       if ( ($range1[$current_gun_id] >= $the_range) && ($ship_status[$the_target] ne "S") && ($sighted[$current_ship][$the_target] > 0) )
          {
          print SHIPS_LOG "<option>$game_month/$game_day/$game_year $game_hours:$game_ticks WE ARE IN RANGE OF OUR ENEMY - $ship_name[$the_target]!\n";

          $bearing2 = $bearing_to_ship[$current_ship][$target[$current_ship]];
          $bearing3 = $bearing_to_ship[$target[$current_ship]][$current_ship];
          print SHIPS_LOG "<option>Turrets that Bear: ";
          for ($xx = 1; $xx<=6 ; $xx++)
              {
              if ($turret[$xx][$current_ship] =~ /^(\d),(\d*),(\d*),(\d*),(\d*)/)
                 {
                 $guns = $1;
                 $start_arc1 = $2;
                 $end_arc1 = $3;
                 $start_arc2 = $4;
                 $end_arc2 = $5;
                 }
                 else
                 {
                 $guns = 0;
                 $start_arc1 = 999;
                 $end_arc1 = -999;
                 $start_arc2 = 999;
                 $end_arc2 = -999;
                 }
              if ( ( ($bearing2 >= $start_arc1) && ($bearing2 <= $end_arc1) ) || ( ( $bearing2 >= $start_arc2) && ($bearing2 <= $end_arc2) ) )
                 {
                 print SHIPS_LOG "$xx, ";
                 $num_shots += $guns;
                 }
              else
                 {
#                 print SHIPS_LOG "dont Bear. ";
                 }
              } #end of turret loop
              print SHIPS_LOG "</option>\n";
         } #end of gun range check 
         else
            {
#            print "This Ship is Out of Range! Gun Range is only $range1[$current_gun_id] and target range is $the_range\n";
            $ship_status[$current_ship] = "*";
            $num_shots = 0;
            }
         $total_shots = $num_shots * $rounds_imp[$current_gun_id];
         if (! $total_shots == 0)
            {
# Begin  German auto-response code
            if ( $ship_country[$the_target] eq "German")
               {
               if ($use_ai[$the_target] ne "NO")
                  {
               print "beginning German auto-response code\n";
### if war was not declared before - do it now
               if ($at_war == 0)
                  {
                  $at_war = $current_ship;
                  print SHIPS_LOG "<option>We have Declared WAR on the Germans! Ruh Roh...</option>\n"; 
                  }
### if the targetted ship doesn't itself have a target - give it it's oppressor
### as a default target to start with.  Quick and Easy this way.
               if ($return_fire[$the_target] ne "NO")
                  {
               if ($target[$the_target] == 0)
                  {

# For now allow the targetted German ship to simply target it's attacker
#outside of this section we'll observe the change target rules.

                  $target[$the_target] = $current_ship;
                  print "$ship_name[$the_target] is Auto-Targetting our attacker $current_ship.\n";
### Now have the targetted vessel acquire the attacker as it's target and turn towards it to close
### distance and increase it's chance of a hit
                  $pursuit_course = $bearing3 + $pretty_ship_course[$the_target];
                  if ($pursuit_course > 360)
                     {
                     $pursuit_course = $pursuit_course - 360;
                     }
                  print "$ship_name[$the_target] did not have a target before, but now has $ship_name[$current_ship] as it's target, and is now setting a course of $pursuit_course to pursue it.\n";
                  if ($pursue_target[$the_target] eq "YES")
                     {
                     $course_target[$the_target] = $pursuit_course; 
                     $speed_target[$the_target] = 40;
                     }
### The next bit of code alerts it's tf mates that it has been attacked!
                  $german_tf = $task_force_id[$the_target];
                  if ($german_tf > 0) # does the target belong to a tf? 0 = no
                     {
                     for ($zz = 1; $zz <= $number_test_ships; $zz++)
                         {
                         if ($task_force_id[$zz] == $german_tf)
                            {
### By default - all members of the tf that dont have targets predefined,
### now acquire the attacker as their personal targets.
                            if ($target[$zz] == 0)
                               {
                               $target[$zz] = $current_ship;
                               if ($pursue_target[$the_target] ne "NO")
                                  { 
                                  $pursuit_course = $bearing_to_ship[$zz][$current_ship] + $pretty_ship_course[$zz];
                                  if ($pursuit_course > 360)
                                     {
                                     $pursuit_course = $pursuit_course - 360;
                                     }
                                  print "$ship_name[$zz] is a TF member and had no target - now on course of $pursuit_course to engage $ship_name[$current_ship]\n";
                                  $course_target[$zz] = $pursuit_course;
                                  $speed_target[$zz] = 40;
                                  }
                               }
### If fellow tf member already HAD a target - range is compared...
### Also here check and see if flotation condition is set...

                               elsif ($range_to_ship[$zz][$target[$zz]] > 125)
                                      {
                                      if ($pursue_target[$the_target] ne "NO")
                                      {
                                      print "$ship_name[$zz] had a target, but it's out of range so is joining in too!\n";
                                      $target[$zz] = $current_ship;
                                      $pursuit_course = $bearing_to_ship[$zz][$current_ship] + $pretty_ship_course[$zz];
                                      if ($pursuit_course > 360)
                                         {
                                         $pursuit_course = $pursuit_course - 360;
                                         }
                                      print "$ship_name[$zz] has decided to use a course of $pursuit_course to engage $ship_name[$current_ship]\n";
                                      $course_target[$zz] = $pursuit_course;
                                      $speed_target[$zz] = 40;
                                        } #end of use pursuit AI?
                                      } #end of pursuit code
                             } #end of Ship IS a member of targeted TF
                          } #end of cycling thru all ships looking for member of German TF
                      } #end of Do Any German TF's exist check
                    } #end of Does German Ship have a target already?
                  } # end of AI return fire toggle
               } #end use AI Check
        } #end country check (Germans Only)
## End German Retaliation Code
##
## Begin British auto-response code
            if ( ($ship_country[$the_target] eq "British") && ( -f "auto_brit") && ($hull_class[$the_target] ne "FR") )
               {
               if ($mad_brits == 0)
                  {
                  $mad_brits = $current_ship;
                  print SHIPS_LOG "<option>We have Declared WAR on the British! It's about time!..</option>\n"; 
                  }
               if ($target[$the_target] == 0)
                  {
                  $target[$the_target] = $current_ship;
                  print "$ship_name[$the_target] is Auto-Targetting our attacker $current_ship.\n";
                  $course_target[$the_target] = $bearing3; 
                  $speed_target[$the_target] = 40;
                  $british_tf = $task_force_id[$the_target];
                  if ($british_tf > 0)
                     {
                     for ($zz = 1; $zz <= $number_test_ships; $zz++)
                         {
                         if ($task_force_id[$zz] == $british_tf)
                            {
                            if ($target[$zz] == 0)
                               {
                               $target[$zz] = $current_ship;
                               $course_target[$zz] = $bearing_to_ship[$zz][$current_ship];
                               $speed_target[$zz] = 40;
                               }
                               elsif ($range_to_ship[$zz][$target[$zz]] > 125)
                                      {
                                      print "$ship_name[$zz] had a target, but it's out of range so is joining in too!\n";
                                      $target[$zz] = $current_ship;
                                      $course_target[$zz] = $bearing_to_ship[$zz][$current_ship];
                                      $speed_target[$zz] = 40;
                                      }
                             }
                          }
                      } 
                  }
               }
## End British Retaliation Code
            $ship_status[$current_ship] = "C";
            print SHIPS_LOG "<option>We get to fire a total of $num_shots with a ROF of $rounds_imp[$current_gun_id] for a total of $total_shots.</option>\n";
            $hita = ( abs(cos( $bearing3 / 180 * $pi)) + $profile_constant) * $length[$the_target];
            $hitb = ( abs(sin( $bearing3 / 180 * $pi)) + $profile_constant) * $beam[$the_target];
            $hitarea = $hita + $hitb;
            $hitp1 = ( $hitarea / $percentile_constant / $the_range);
            $hitp2 = ( $the_range * ( $ship_sight_factor[$current_ship] + $crew_skill[$current_ship] + $visibility + $range1[$current_gun_id]/$the_range) / $scalefactor);
            $hitprob = int( ($hitp1 + $hitp2) * 100);
            $p_hitarea = int($hitarea * 100)/100;
            $number_hits[$current_ship] = 0;
            for ($xxx = 1; $xxx <= $total_shots; $xxx++)
                {
                $hit_roll = int(rand(100))+1;
                if ($hit_roll <= $hitprob)
                   {
                   if ($ship_status[$the_target] ne "S")
                       {
                       $ship_status[$the_target] = "@";
                       }
                   $flotation[$the_target] = $flotation[$the_target] - 1;
                   $number_hits[$current_ship]++;
                   print TARGET_LOG "<option>We have been hit by \"$ship_name[$current_ship]\"! Flotation is at $flotation[$the_target].\n";
                   if ( ($flotation[$the_target] < $org_flotation[$the_target] * .75) && ($flot_warn[$the_target] == 0) )
                      {
                      $max_speed[$the_target] = $org_max_speed[$the_target] * .88;
                      print TARGET_LOG "<option>$game_time_stamp: We have lost 25% of our flotations - our best speed is now $max_speed[$the_target].\n";
                      print TARGET_LOG "<option>org_max_speed = $org_max_speed[$the_target]\n";
                      $flot_warn[$the_target] = 1;
                      }
                   if ( ($flotation[$the_target] < $org_flotation[$the_target] * .65) && ($flot_warn[$the_target] == 1) )
                      {
                      $max_speed[$the_target] = $org_max_speed[$the_target] * .76;
                      print TARGET_LOG "<option>$game_time_stamp: We have lost 35% of our flotations - our best speed is now $max_speed[$the_target].\n";
                      $flot_warn[$the_target] = 2;
                      }
                   if ( ($flotation[$the_target] < $org_flotation[$the_target] * .55) && ($flot_warn[$the_target] == 2) )
                      {
                      $max_speed[$the_target] = $org_max_speed[$the_target] * .64;
                      print TARGET_LOG "<option>$game_time_stamp: We have lost 45% of our flotations - our best speed is now $max_speed[$the_target].\n";
                      $flot_warn[$the_target] = 3;
                      }
                   if ( ($flotation[$the_target] < $org_flotation[$the_target] * .45) && ($flot_warn[$the_target] == 3) )
                      {
                      $max_speed[$the_target] = $org_max_speed[$the_target] * .52;
                      print TARGET_LOG "<option>$game_time_stamp: We have lost 55% of our flotations - our best speed is now $max_speed[$the_target].\n";
                      $flot_warn[$the_target] = 4;
                      }
                   if ( ($flotation[$the_target] < $org_flotation[$the_target] * .35) && ($flot_warn[$the_target] == 4) )
                      {
                      $max_speed[$the_target] = $org_max_speed[$the_target] * .40;
                      print TARGET_LOG "<option>$game_time_stamp: We have lost 65% of our flotations - our best speed is now $max_speed[$the_target].\n";
                       $flot_warn[$the_target] = 5;
                      }
                   if ( ($flotation[$the_target] < $org_flotation[$the_target] * .25) && ($flot_warn[$the_target] == 5) )
                      {
                      $max_speed[$the_target] = $org_max_speed[$the_target] * .10;
                      print TARGET_LOG "<option>$game_time_stamp: We have lost 75% of our flotations - our best speed is now $max_speed[$the_target].\n";
                      $flot_warn[$the_target] = 6;
                      }
                   if ( ($flotation[$the_target] < $org_flotation[$the_target] * .15) && ($flot_warn[$the_target] == 6) )
                      {
                      $max_speed[$the_target] = 0;
                      print TARGET_LOG "<option>$game_time_stamp: We have lost 85% of our flotations - our boilers are flooded - we are dead in the water!\n";
                      $flot_warn[$the_target] = 7;
                      }
                   }
                }
            print SHIPS_LOG "<option>The target HitArea computes to $p_hitarea, Probability of a hit is $hitprob</option>\n";
            print SHIPS_LOG "<option>We hit the target a total of $number_hits[$current_ship]</option>\n";
            if ($flotation[$the_target] <= 0)
               {
               print SHIPS_LOG "<option>We Sunk 'em Cap'n!</option>";
               $target[$current_ship] = 0;
               $ship_status[$current_ship] = "*";
               print TARGET_LOG "<option>*Glub* *Glub* We've been Sunk!</option>\n";
               $depth[$the_target] = 999;
## Insert sinking code here to be sure...
               }
            }
       } # end of if has a target...
   close (SHIPS_LOG);
   close (TARGET_LOG);
    } #end of freighter check
   } # End of for current_ship loop...
## End Combat routines
print "Status of at_war = $at_war\n";
# ship #9 = sub
# ship #5 = freighter

print "#5's b & m are: $b[5],$m[5]\n";
print "for ship #9 currently at $ship_x[9],$ship_y[9]\n";
print "and freighter #5 is at $ship_x[5],$ship_y[5] on a course of $pretty_ship_course[5]\n";
print "bearing from freighter #5's pov is $bearing_to_ship[5][9]\n";
if ( ($bearing_to_ship[5][9] > 180) && ($bearing_to_ship[5][9] <= 360) )
   {
   print "Sub is on left side of freighter - need to set a course of ";
   if ($pretty_ship_course[5] < 180)
      {
      $intercept_course = $pretty_ship_course[5] + 90;
      }
   else
      {
      $intercept_course = $pretty_ship_course[5] - 90;
      }
   if ($intercept_course < 0)
      {
      $intercept_course += 360;
      }
   if ($intercept_course > 360)
      {
      $intercept_course -= 360;
      }
   print "$intercept_course\n";
   }
   else
   {
   print "Sub is on right side of the freighter - need to set a course of ";
   if ($pretty_ship_course[5] < 180)
      {
      $intercept_course = $pretty_ship_course[5] - 90;
      }
   else
      {
      $intercept_course = $pretty_ship_course[5] + 90;
      }
   if ($intercept_course < 0)
     {
      $intercept_course += 360;
      }
   if ($intercept_course > 360)
      {
      $intercept_course -= 360;
      }
   print "$intercept_course\n";
  }
#put in check for /0 later
$sub_tan = tan($intercept_course);
print "tangent of sub intercept course is $sub_tan\n";

## German External AI Routines
if ($at_war > 0)
   {
### WAR was declared - now assign targets...
### Every impulse double check to ensure that you are engaging the best
### possible target and are closing distance to it.

   for ($xx = 1; $xx <= $number_test_ships; $xx++)
        {
        if ( ($ship_country[$xx] eq "German") && ($ship_status[$xx] ne "S") && ($use_ai[$xx] ne "NO") )
           {
#           print "processing $ship_name[$xx] currently.\n";
### Only non sunken German ships need apply
### Before this code was only executed for ships w/out a target - now every
### impulse the Germans will re-evaluate the situation and pursue the closest
### enemy vessel every time.

### If ship doesn't have a target - find one for it
              $choice_capital = 0;
              $choice_freighter = 0;
              $capital_range = 9999;
              $freighter_range = 9999;

### put logic in here to choose target based on remaining
### percentage of floats too...

              for ($yy = 1; $yy <= $number_test_ships; $yy++)
                  {
                  if ($ship_country[$yy] ne "German")
                     {
### Any non-German ship is a valid choice for a target

### Find best non-freighter target
                     if ( ($range_to_ship[$xx][$yy] < $capital_range) && ($ship_status[$yy] ne "S") && ($hull_class[$yy] ne "FR") )
                        {
                        $choice_capital = $yy;
                        $capital_range = $range_to_ship[$xx][$yy];
                        }

### Find best non-capital ship target
                     if ( ($range_to_ship[$xx][$yy] < $freighter_range) && ($ship_status[$yy] ne "S") && ($hull_class[$yy] eq "FR") )
                        {
                        $choice_freighter = $yy;
                        $freighter_range = $range_to_ship[$xx][$yy];
                        }
                     }
                   }
### $choice_target now either equeals the id of the best possible target
### or it's still a 0 indicating that no targets are left.
$ship_name[0] = "NONE";
#print "for $ship_name[$xx] choice freighter = $ship_name[$choice_freighter] and choice capital = $ship_name[$choice_capital]\n";
### Now - based on the two targets - choose one                    
              if ( ($choice_freighter > 0) && ($choice_capital > 0) )
                 {
                 if ( ($cap_priority[$xx] eq "YES") && ($capital_range < 125) )
                    {
#                    print "capital ship preference priority is enabled.\n";
                    print "Capital ship $ship_name[$choice_capital] is at $capital_range, freighter choice $ship_name[$choice_freighter] is at $freighter_range.\n";
#                    print "Capital ship within range 125 - selected.\n";
                    $target[$xx] = $choice_capital;
                    }
                   else
                    { 
                    if ($capital_range <= $freighter_range)
                       {
                       print "not using capital priority - capital ship is closer tho\n";
                       $target[$xx] = $choice_capital;
                       }
                      else
                       {
                       print "not using capital priority - freighter is closer tho\n";
                       $target[$xx] = $choice_freighter;
                       }
                    }
                 }
                  else
### if it gets here - one or both targets are 0....
                 {
                  $target[$xx] = $choice_freighter + $choice_capital;
                  print "only one choice and it is $ship_name[$target[$xx]]\n";
### Adding them together will choose the non-zero target if any.
                   }
#                print "pursue target $xx = $pursue_target[$xx]\n"; 
              if ( ($target[$xx] > 0 ) && ($pursue_target[$xx] ne "NO") )
                 {
#                 print "current German WILL alter course to accomodate target.\n";
### We found a target - now plot a course to head for it.
                 $pursuit_course = $bearing_to_ship[$xx][$target[$xx]] + $pretty_ship_course[$xx];
print "for $ship_name[$xx] it's preferred target $ship_name[$target[$xx]] bears $bearing_to_ship[$xx][$target[$xx]] right now\n";
                 if ($pursuit_course > 360)
                    {
                    $pursuit_course = $pursuit_course - 360;
                    }
                 if ( ($use_broadside[$xx] eq "YES") && ($range_to_ship[$xx][$target[$xx]] <= 25) )
                    {
                    print "ship is now attempting to maneuver into broadside positioning.\n";
                    print "xx = $xx, and target[xx] = $target[$xx], bearing to target = $bearing_to_ship[$xx][$target[$xx]]\n";
                    if ( ! ( ($bearing_to_ship[$xx][$target[$xx]] > 224) & ($bearing_to_ship[$xx][$target[$xx]] < 316) ) || ( ( $bearing_to_ship[$xx][$target[$xx]] > 45 ) && ($bearing_to_ship[$xx][$target[$xx]] < 135) ) )
                       {
                       $course_target[$xx] = $pretty_ship_course[$xx] + 90;
                       $course_target[$xx] = 450 - $course_target[$xx];
                       if ($course_target[$xx] > 360)
                          {
                          $course_target[$xx] -= 360;
                          }
                       }
                     }
                     else
                     {
                     $course_target[$xx] = 450 - $pursuit_course;
                     if ($course_target[$xx] > 360)
                        {
                        $course_target[$xx] -= 360;
                        }
                    }
                    #print "in at_war code $ship_name[$xx] has decided to use a course of $pursuit_course to engage $ship_name[$choice_target]\n";

                 if ($range_to_ship[$xx][$target[$xx]] > $close_target[$xx])
                    {
#                    print "range to ship exceeds close target threshold.\n";
                    $speed_target[$xx] = $ship_speed[$xx] + 5;
                    }
                 else
                    {
#                    print "ship and target within close range threshold - reducing speed.\n";
                    $speed_target[$xx] = $ship_speed[$xx] - 2;
                    }
                  if ($speed_target[$xx] < 0)
                     {
#                     print "speed is reduced all the way to 1\n";
                     $speed_target[$xx] = 1;
                     }
### The following ship status indicates the ship is now in "Pursuit" mode
                 $ship_status[$xx] = "P";
                 }
                 else
                 {
                 print "target for $xx = $target[$xx]\n";
                 print "$ship_name[$xx] Can't find a target - all must be sunken\n";
                 $ship_status[$xx] = "*";
#                 $at_war = 0;
                 if ($pursue_target[$xx] eq "YES")
                    {
                    $speed_target[$xx] = 0;
                    }
                 } 
           } #end of Only German ships need apply    
       } #end of loop thru ships looking for Germans
    } #end of if at war check



if ($mad_brits > 0)
   {
   #WAR was declared - now assign targets...
   for ($xx = 1; $xx <= $number_test_ships; $xx++)
        {
        if ( ($ship_country[$xx] eq "British") && ($ship_status[$xx] ne "S") && ($hull_class[$xx] ne "FR") )
           {
           if ($target[$xx] == 0)
              {
              $choice_target = 0;
              $target_range = 9999;
              for ($yy = 1; $yy <= $number_test_ships; $yy++)
                  {
                  if ($ship_country[$yy] ne "British")
                     {
                     if ( ($range_to_ship[$xx][$yy] < $target_range) && ($ship_status[$yy] ne "S") )
                        {
                        $choice_target = $yy;
                        $target_range = $range_to_ship[$xx][$yy];
                        }
                     }
                   }
              $target[$xx] = $choice_target;
              if ($choice_target > 0 )
                 {
                 $course_target[$xx] = $bearing_to_ship[$xx][$choice_target];
                 $speed_target[$xx] = 40; # use max speed next time
                 print "$ship_name[$xx] Has searched and determined $ship_name[$choice_target] shall be it's target. Headed for it.\n";
                 $ship_status[$xx] = "P";
                 }
                 else
                 {
                 print "$ship_name[$xx] Can't find a target - all must be sunken\n";
                 $ship_status[$xx] = "*";
                 $mad_brits = 0;
                 $speed_target[$xx] = 0;
                 } 
              }
           }     
       }
    }
for ($current_ship = 1; $current_ship <= $number_test_ships; $current_ship++)
{
# Now concatenate the ships logs together...
$cmd = "cat /home/www/game_design/ships_logs/ships_log.top /home/www/game_design/ships_logs/ships_log_$current_ship.txt /home/www/game_design/ships_logs/ships_log.bottom > /home/www/game_design/ships_logs/ship_log.$current_ship.html";
system $cmd;
}
#print "At end of impulse mad_brits = $mad_brits and at_war = $at_war\n";
open (VISIBILITY,">visibility_is");
print VISIBILITY "$visibility\n";
close (VISIBILITY);
##
##Make text map
##
## hull_class eq SUB

   $lowest_x = 99999;
   $highest_x = -99999;
   $lowest_y = 99999;
   $highest_y = -99999;
   
   for ($qq = 1; $qq <= $number_test_ships; $qq++)
       {
       if ($ship_x[$qq] > $highest_x)
          {
          $highest_x = $ship_x[$qq];
          }
       if ($ship_x[$qq] < $lowest_x)
          {
          $lowest_x = $ship_x[$qq];
          }
      if ($ship_y[$qq] > $highest_y)
          {
          $highest_y = $ship_y[$qq];
          }
       if ($ship_y[$qq] < $lowest_y)
          {
          $lowest_y = $ship_y[$qq];
          }
      }
$highest_x = 45000;
$lowest_x = 35000;
$highest_y = 10001;
$lowest_y = 1;
### Fix map temporarily from +-50000x+-50000

   $x_scaled = 80 / ($highest_x - $lowest_x);
   $y_scaled = 80 / ($highest_y - $lowest_y);
 if ($x_scaled < $y_scaled)
     {
     $y_scaled = $x_scaled ;
     }
     else
     {
     $x_scaled = $y_scaled;
     }
## $x_scaled = 80 / 50000;
## $y_scaled = $x_scaled;
   for ($x = 0; $x <= 80; $x++)
       {
       for($y = 0; $y <= 80; $y++)
          {
          $map[$x][$y] = ".";
          }
       }
   for ($qq = 1; $qq <= $number_test_ships; $qq++)
       {
       $ship_x_scaled = int( ($ship_x[$qq] - $lowest_x) * $x_scaled);
       $ship_y_scaled = 80 - int( ($ship_y[$qq] - $lowest_y) * $y_scaled);
       if ( ($ship_x_scaled < 0) || ($ship_y_scaled < 0) )
          {
          $ship_x_scaled = 100;
          $ship_y_scaled = 100;
          }
       $map[$ship_x_scaled][$ship_y_scaled] = "$qq";
       }
## Create dynamicaly generate map
 open (MAP,">/home/www/game_design/map.html");
 print MAP $map_header;
 print MAP "<center><img src=\"compass5.gif\"></center>\n";
 print MAP "<font color=\"#33CCFF\">\n";
 print MAP "<font size = \"3\">\n";
 for ($yy = 0; $yy <= 80; $yy++)
       {
       for($xx = 0; $xx <= 80; $xx++)
          {
          if ($map[$xx][$yy] ne ".")
             {
             print MAP "<a href=\"/cgi-bin/game_design/modify_ship.pl?ship=$map[$xx][$yy]\">$map[$xx][$yy]</a><a href=\"/game_design/ships_logs/ship_log.$map[$xx][$yy].html\">$ship_status[$map[$xx][$yy]]</a>";
             }
             else
             {
             print MAP "$map[$xx][$yy] ";
             }
          }
       print MAP "<br>\n";
       }
print MAP "<font color=\"black\">\n";
print MAP "<center><img src=\"compass5.gif\"></center>\n";
close (MAP);
$cmd = "touch started";
system $cmd;
### experimental - create 3 maps for each ship...
($rsec,$rmin,$rhour,$rmday,$rmon,$ryear,$wday,$yday,$isdst) = localtime(time);
$ryear = 100 - $ryear;
if ($ryear < 10) {
	$ryear = "0" . $ryear;
	}
if ($rsec < 10) {
        $rsec = "0".$rsec;
        }
if ($rmin < 10) {
        $rmin = "0".$rmin;
        }
if ($rhour < 10) {
        $rhour = "0".$rhour;
        }
if ($rmday < 10) {
        $rmday = "0".$rmday;
        }
$rmon=$rmon+1;
if ($rmon < 10) {
        $rmon = "0".$rmon;
        }
$junk = $isdst;
$junk = $yday;
$junk = $wday;

#print "beginning creation of maps at $rhour:$rmin:$rsec\n";

 for ($the_ship = 1; $the_ship <= $number_test_ships; $the_ship++)
    {
    $lowest_x = $ship_x[$the_ship] - (80 * $zoom[$the_ship]);
    $highest_x = $ship_x[$the_ship] + (80 * $zoom[$the_ship]);
    $lowest_y = $ship_y[$the_ship] - (80 * $zoom[$the_ship]);
    $highest_y = $ship_y[$the_ship] + (80 * $zoom[$the_ship]);
   
    $x_scaled = 80 / ($highest_x - $lowest_x);
    $y_scaled = 80 / ($highest_y - $lowest_y);
    for ($x = 0; $x <= 80; $x++)
        {
        for($y = 0; $y <= 80; $y++)
           {
           $map[$x][$y] = ".";
           }
        }
##hopefully the following will map ships that should not be displayed
##on the curren map to array spots > 80...

        for ($qq = 1; $qq <= $number_test_ships; $qq++)
            {
            $ship_x_scaled = int( ($ship_x[$qq] - $lowest_x) * $x_scaled);
            $ship_y_scaled = 80 - int( ($ship_y[$qq] - $lowest_y) * $y_scaled);
            if ( ($ship_x_scaled < 0) || ($ship_y_scaled < 0) )
               {
#               print "for map $the_ship zoom level $zoom, ship $qq should NOT be present.\n";
               $ship_x_scaled = 100;
               $ship_y_scaled = 100;
               }
             if ($the_ship != $qq)
                {
                if ($sighted[$the_ship][$qq] == 1)
                   {
                   $map[$ship_x_scaled][$ship_y_scaled] = "$qq";
                   }
                else
                   {
                   $map[$ship_x_scaled][$ship_y_scaled] = ".";
                   }
                 }
              else
                 {
                 $map[$ship_x_scaled][$ship_y_scaled] = "$qq";
                 }
            }

# now - if hull_class eq SUB...
        for ($qq = 1; $qq <= $number_test_ships; $qq++)
            {
            if ($hull_class[$qq] eq "SUB")
               {
# and if there are any torps in game
               if ($number_torps > 0)
                  {
                  for ($xx = 1; $xx <= $number_torps; $xx++)
                      {
                      $torp_id = $xx + 1000;
# check individually to see if they should be plotted
                      if ($torp_launcher[$torp_id] == $qq)
                         {
# only plot our own torps
                         $torp_x_scaled = int( ($torp_x[$torp_id] - $lowest_x) * $x_scaled);
                         $torp_y_scaled = 80 - int( ($torp_y[$torp_id] - $lowest_y) * $y_scaled);
                         if ( ($torp_x_scaled < 0) || ($torp_y_scaled < 0) )
                            {
#                           print "for map $the_ship zoom level $zoom, ship $qq should NOT be present.\n";
                            $torp_x_scaled = 100;
                            $torp_y_scaled = 100;
                            }
                         $map[$torp_x_scaled][$torp_y_scaled] = "$torp_id";
                         }
                      }
                  } #end of number of torps
           } #end of this is a sub
       } # end of our loop
      
#print "the ship = $the_ship\n";
### Create dynamicaly generate map
 open (MAP,">/home/www/game_design/map_$the_ship.html");
 print MAP $map_header;
 print MAP "<center><img src=\"compass5.gif\"></center>\n";
 print MAP "<font size = \"3\">\n";
 print MAP "<form ACTION=\"/cgi-bin/game_design/ship_map_cfg.pl\" method=\"post\">\n"; 
 print MAP "<input name=\"ship_id\" type=\"hidden\" value = \"$the_ship\">\n";
 print MAP "Zoom Level currently:$zoom[$the_ship]. Change Zoom level to ";
 print MAP "<select name=\"zoom\">\n";
 print MAP "<option>1\n";
 print MAP "<option>2\n";
 print MAP "<option>3\n";
 print MAP "</select>";
 print MAP "<INPUT NAME=\"chg_zoom\" TYPE=\"submit\" VALUE=\"Change Zoom\"><br>\n";
 print MAP "</form>\n";
 print MAP $border[$zoom[$the_ship]]; 
 for ($yy = 0; $yy <= 80; $yy++)
       {
       for($xx = 0; $xx <= 80; $xx++)
          {
          if ($map[$xx][$yy] ne ".")
             {
             $ship_number = $map[$xx][$yy];
             if ($ship_number < 1001)
                {
                $the_bearing = $pretty_ship_course[$ship_number];
                }
             elsif ($ship_number > 1000)
                   {
                   $the_bearing = $torp_course[$ship_number];
                   $suffix = "t";
                   }

                if ($the_bearing <= 22.5)
                   {
                   $graphic = "0";
                   }

                if ( ($the_bearing > 22.5) && ($the_bearing <= 67.5))
                   {
                   $graphic = "1";
                   }

                if ( ($the_bearing > 67.5) && ($the_bearing <= 112.5))
                   {
                   $graphic = "2";
                   }

                if ( ($the_bearing > 112.5) && ($the_bearing <= 157.5))
                   {
                   $graphic = "3";
                   }

                if ( ($the_bearing > 157.5) && ($the_bearing <= 202.5))
                   {
                   $graphic = "4";
                   }

                if ( ($the_bearing > 202.5) && ($the_bearing <= 247.5))
                   {
                   $graphic = "5";
                   }

                if ( ($the_bearing > 247.5) && ($the_bearing <= 292.5))
                   {
                   $graphic = "6";
                   }

                if ( ($the_bearing > 292.5) && ($the_bearing <= 337.5))
                   {
                   $graphic = "7";
                   }

                if ($the_bearing > 337.5)
                   {
                   $graphic = "0";
                   }

            $ship_graphic = $ship_icon[$graphic];
            if ($ship_number < 1000)
               {
                if ($ship_status[$ship_number] eq "S")
                   {
                   $ship_graphic = "sunk";
                   }
                if ( ($ship_country[$ship_number] eq "German") && ($hull_class[$ship_number] eq "BB") )
                   {
                   $ship_graphic .= "g.jpg";
                   }

                if ( ($ship_country[$ship_number] eq "German") && ($hull_class[$ship_number] eq "SUB") )
                   {
                   $ship_graphic .= "s.jpg";
                   }

                if ( ($ship_country[$ship_number] eq "British") && ($hull_class[$ship_number] eq "BB") )
                   {
                   $ship_graphic .= "b.jpg";
                   }

                if ( ($ship_country[$ship_number] eq "British") && ($hull_class[$ship_number] eq "FR") )
                   {
                   $ship_graphic .= "f.jpg";
                   }
               }
               else
                  {
                  $ship_graphic .= "t.jpg";
                  }
                        
             if ($ship_number < 1000)
                {
                print MAP "<a href=\"/cgi-bin/game_design/modify_ship.pl?ship=$ship_number\">";
                print MAP "<img src=\"/game_design/ship_icons/$ship_graphic\" alt=\"$ship_name[$ship_number], course: $pretty_ship_course[$ship_number], speed:$ship_speed[$ship_number]\"></a>";
                print MAP "<a href=\"/game_design/ships_logs/ship_log.$ship_number.html\">$ship_status[$ship_number]</a>";
                }
             elsif ($ship_number > 1000)
                 {
                 $cleantorp_x = int($torp_x[$ship_number]);
                 $cleantorp_y = int($torp_y[$ship_number]);
                  print MAP "<img src=\"/game_design/ship_icons/$ship_graphic\" alt=\"torp_id = $ship_number, course: $torp_course[$ship_number], x,y: $cleantorp_x,$cleantorp_y\">";
                  print MAP "$torp_duration[$ship_number]";
                 } 
             
             }
             else
             {
             if ( ($xx < 79) && ($map[$xx+1][$yy] ne "."))
                {
                print MAP "~";
                }
             else
                {
                print MAP "~ ";
                }
             }
                 
          }
       print MAP "<br>\n";
       }
print MAP $bottom[$zoom[$the_ship]];
print MAP "<center><img src=\"compass5.gif\"></center>\n";
close (MAP);
} # end of ship loop
$cmd = "touch finished";
system $cmd;
($rsec,$rmin,$rhour,$rmday,$rmon,$ryear,$wday,$yday,$isdst) = localtime(time);
$ryear = 100 - $ryear;
if ($ryear < 10) {
	$ryear = "0" . $ryear;
	}
if ($rsec < 10) {
        $rsec = "0".$rsec;
        }
if ($rmin < 10) {
        $rmin = "0".$rmin;
        }
if ($rhour < 10) {
        $rhour = "0".$rhour;
        }
if ($rmday < 10) {
        $rmday = "0".$rmday;
        }
$rmon=$rmon+1;
if ($rmon < 10) {
        $rmon = "0".$rmon;
        }
$junk = $isdst;
$junk = $yday;
$junk = $wday;
#print "ending creation of maps at $rhour:$rmin:$rsec\n";
sleep 1;

($rsec,$rmin,$rhour,$rmday,$rmon,$ryear,$wday,$yday,$isdst) = localtime(time);
$ryear = 100 - $ryear;
if ($ryear < 10) {
	$ryear = "0" . $ryear;
	}
if ($rsec < 10) {
        $rsec = "0".$rsec;
        }
if ($rmin < 10) {
        $rmin = "0".$rmin;
        }
if ($rhour < 10) {
        $rhour = "0".$rhour;
        }
if ($rmday < 10) {
        $rmday = "0".$rmday;
        }
$rmon=$rmon+1;
if ($rmon < 10) {
        $rmon = "0".$rmon;
        }
$junk = $isdst;
$junk = $yday;
$junk = $wday;
} # end of something or other (end of 20 sec?)

} # end of something else (end of stop check?)

# If this section is reached - we are requested to shutdown.
# first save off data to sql - then shut down...
open(LOG,">>/home/www/game_design/impulse.log");
print LOG "$rmon/$rmday/$ryear $rhour:$rmin:$rsec  Saving DB before Shutting Down\n";
close (LOG);
&update_db;
$cmd = "touch stopped";
system $cmd;
$cmd = "cp /home/www/game_design/stopped.gif /home/www/game_design/status.gif";
system $cmd;
exit;
