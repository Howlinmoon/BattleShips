#!/usr/bin/perl -w

#mysql> describe how_many_ships;
#+----------+--------------+------+-----+---------+-------+
#| Field    | Type         | Null | Key | Default | Extra |
#+----------+--------------+------+-----+---------+-------+
#| how_many | mediumint(9) |      | PRI | 0       |       |
#+----------+--------------+------+-----+---------+-------+

#mysql> describe master_ship_chart;
#+---------------------+--------------+------+-----+---------+-------+
#| Field               | Type         | Null | Key | Default | Extra |
#+---------------------+--------------+------+-----+---------+-------+
#| ship_id             | mediumint(9) |      | PRI | 0       |       |
#| ship_name           | varchar(50)  |      |     |         |       |
#| ship_owner          | varchar(50)  |      |     |         |       |
#| ship_country        | varchar(50)  |      |     |         |       |
#| ship_heading        | varchar(6)   |      |     |         |       |
#| ship_x              | varchar(12)  |      |     |         |       |
#| ship_y              | varchar(12)  |      |     |         |       |
#| ship_speed          | varchar(5)   |      |     |         |       |
#| ship_max_speed      | mediumint(9) |      |     | 0       |       |
#| ship_sighting_range | varchar(12)  |      |     |         |       |
#| ship_sight_factor   | varchar(5)   |      |     |         |       |
#| hull_class          | varchar(20)  |      |     |         |       |
#| depth               | mediumint(9) |      |     | 0       |       |
#| task_force          | mediumint(9) |      |     | 0       |       |
#+---------------------+--------------+------+-----+---------+-------+

#mysql> describe how_many_waypoints;
#+-----------+--------------+------+-----+---------+-------+
#| Field     | Type         | Null | Key | Default | Extra |
#+-----------+--------------+------+-----+---------+-------+
#| ship_id   | mediumint(9) |      | PRI | 0       |       |
#| waypoints | mediumint(9) |      |     | 0       |       |
#+-----------+--------------+------+-----+---------+-------+

#mysql> describe waypoint_master;
#+--------------+--------------+------+-----+---------+-------+
#| Field        | Type         | Null | Key | Default | Extra |
#+--------------+--------------+------+-----+---------+-------+
#| waypoint_id  | mediumint(9) |      | PRI | 0       |       |
#| ship         | mediumint(9) |      |     | 0       |       |
#| waypoint_num | mediumint(9) |      |     | 0       |       |
#| waypoint     | varchar(22)  | YES  |     | NULL    |       |
#| speed        | mediumint(9) |      |     | 0       |       |
#| depth        | mediumint(9) |      |     | 0       |       |
#+--------------+--------------+------+-----+---------+-------+

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

my $ship1 = $query->param("ship1");
my $ship2 = $query->param("ship2");
my $bearing1 = $query->param("bearing1");
my $optics1 = $query->param("optics1");
my $crew_skill1 = $query->param("crew_skill1");
my $sighting1 = $query->param("sighting1");
my $bearing2 = $query->param("bearing2");
my $optics2 = $query->param("optics2");
my $crew_skill2 = $query->param("crew_skill2");
my $sighting2 = $query->param("sighting2");
my $range = $query->param("range");

print "Ship #1 is a $ship1, relative bearing of $bearing1, Optics value of $optics1, Crew Skill of $crew_skill1, and a sighting value of $sighting1<br>\n";
print "Ship #2 is a $ship2, relative bearing of $bearing2, Optics value of $optics2, Crew Skill of $crew_skill2, and a sighting value of $sighting2<br>\n";
print "For firing arc consideration - Ship #1 has Ship #2 bearing $bearing2.<br>\n";
print "For firing arc consideration - Ship #2 has Ship #1 bearing $bearing1.<br>\n";
$rounds_imp1 = 0;
$rounds_imp2 = 0;
print "This calculation is taking place at a range of $range<br>\n";

my $dbh = Mysql -> connect("localhost","test");

my $command = "";
        $command = "select how_many from how_many_hulls";
        my $sth=$dbh-> query($command);
        die "Error with command $command\n" unless (defined $sth);
        my @arr=();
        while (@arr = $sth->fetchrow)
        {
        ($hulls) = @arr;
        }
$got_match1 = 0;
$got_match2 = 0;
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
    if ($class eq $ship1)
       {
       $got_match1 = $xx;
       }
    if ($class eq $ship2)
       {
       $got_match2 = $xx;
       }

    }
if ($got_match1 == 0)
   {
   print "Sorry - $ship1 hull class is not on file<br>\n";
   exit;
   }
if ($got_match2 == 0)
   {
   print "Sorry - $ship2 hull class is not on file<br>\n";
   exit;
   }

$command = "select * from master_hull_table where hull_id = $got_match1";
$sth=$dbh->query($command);
die "Error with command $command\n" unless (defined $sth);
@arr=();
while (@arr = $sth->fetchrow)
      {
      ($class,$tonnage,$beam1,$draft,$max,$cruising,$fuel,$flotation,$belt,$deck,$face,$top,$barbette,$tower,$main_guns1,$turret1[1],$turret1[2],$turret1[3],$turret1[4],$turret1[5],$turret1[6],$aa_1,$aa_2,$torp,$s_gun1,$s_gun2,$hull_id,$sec_gun_type,$length1 ) = @arr;
      }

$command = "select * from master_hull_table where hull_id = $got_match2";
$sth=$dbh->query($command);
die "Error with command $command\n" unless (defined $sth);
@arr=();
while (@arr = $sth->fetchrow)
      {
      ($class,$tonnage,$beam2,$draft,$max,$cruising,$fuel,$flotation,$belt,$deck,$face,$top,$barbette,$tower,$main_guns2,$turret2[1],$turret2[2],$turret2[3],$turret2[4],$turret2[5],$turret2[6],$aa_1,$aa_2,$torp,$s_gun1,$s_gun2,$hull_id,$sec_gun_type,$length2 ) = @arr;
      }

print "For Ship #1, Length = $length1, beam = $beam1<br>\n";
print "For Ship #2, Length = $length2, beam = $beam2<br>\n";
print "Range = $range<br>\n";
print "Ship #1 has main guns type $main_guns1<br>\n";
print "Stand by while I check to see if main gun type \"$main_guns1\" is on file...<br>\n";
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
      ($gun_id,$gun_name,$rounds_imp1,$shell_velo1,$shell_velo2,$shell_wgt1,$shell_wgt2,$max_elevation,$range1,$range2) = @arr;
      }    
print "comparing \"$gun_name\" with \"$main_guns1\"<br>\n";
if ($gun_name eq $main_guns1)
   {
   print "We have a match - that guntype is on file!<br>\n";
   $found_gun = $xx;
   $gun_range1 = $range1;
   }
    }
if ($found_gun == 0)
   {
   print "No Match found.<br>\n";
   print "Sorry - but this ship can fire.<br>\n";
   exit;
   }
$num_shots = 0;
if ($gun_range1 >= $range)
   {
   print "This Ship is IN Range - range guns = $range1, Range = $range<br>\n";
   for ($xx = 1; $xx<=6 ; $xx++)
       {
       print "Turret #$xx is $turret1[$xx]<br>\n";
       if ($turret1[$xx] =~ /^(\d),(\d*),(\d*),(\d*),(\d*)/)
          {
          $guns = $1;
          $start_arc1 = $2;
          $end_arc1 = $3;
          $start_arc2 = $4;
          $end_arc2 = $5;
          print "This Turret has $guns main Guns and they ";
          if ( ( ($bearing2 >= $start_arc1) && ($bearing2 <= $end_arc1) ) || ( ( $bearing2 >= $start_arc2) && ($bearing2 <= $end_arc2) ) )
             {
             print "CAN Bear on the target.<br>\n";
             $num_shots += $guns;
             }
         else
             {
             print "can NOT Bear on the target.<br>\n";
             }
         }
      }
  }
  else
  {
  print "This Ship is Out of Range! Gun Range is only $gun_range1<br>\n";
  }
$total_shots = $num_shots * $rounds_imp1;
print "This Ship gets to fire a total of $num_shots with a ROF of $rounds_imp1 for a total of $total_shots.<br>\n";
print "<p>\n";

print "Ship #2 has main guns type $main_guns2<br>\n";
print "Stand by while I check to see if main gun type \"$main_guns2\" is on file...<br>\n";
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
      ($gun_id,$gun_name,$rounds_imp2,$shell_velo1,$shell_velo2,$shell_wgt1,$shell_wgt2,$max_elevation,$range1,$range2) = @arr;
      }    
print "comparing \"$gun_name\" with \"$main_guns2\"<br>\n";
if ($gun_name eq $main_guns2)
   {
   print "We have a match - that guntype is on file!<br>\n";
   $found_gun = $xx;
   $gun_range2 = $range1;
   }
    }
if ($found_gun == 0)
   {
   print "No Match found.<br>\n";
   print "Sorry - but this ship can fire.<br>\n";
   exit;
   }
$num_shots = 0;
if ($gun_range2 >= $range)
   {
   print "This Ship is IN Range - range guns = $range1, Range = $range<br>\n";
   for ($xx = 1; $xx<=6 ; $xx++)
       {
       print "Turret #$xx is $turret2[$xx]<br>\n";
       if ($turret2[$xx] =~ /^(\d),(\d*),(\d*),(\d*),(\d*)/)
          {
          $guns = $1;
          $start_arc1 = $2;
          $end_arc1 = $3;
          $start_arc2 = $4;
          $end_arc2 = $5;
          print "This Turret has $guns main Guns and they ";
          if ( ( ($bearing1 >= $start_arc1) && ($bearing1 <= $end_arc1) ) || ( ( $bearing1 >= $start_arc2) && ($bearing1 <= $end_arc2) ) )
             {
             print "CAN Bear on the target.<br>\n";
             $num_shots += $guns;
             }
         else
             {
             print "can NOT Bear on the target.<br>\n";
             }
         }
      }
  }
  else
  {
  print "This Ship is Out of Range! Gun Range is only $gun_range2<br>\n";
  }
$total_shots = $num_shots * $rounds_imp2;
print "This Ship gets to fire a total of $num_shots with a ROF of $rounds_imp2 for a total of $total_shots.<br>\n";
$pi = 3.14159265358979323846;
$profile_constant = 0.1;
$percentile_constant = 120;
$scalefactor = 30000;

$hita = ( abs(cos( $bearing1 / 180 * $pi)) + $profile_constant) * $length1;
$hitb = ( abs(sin( $bearing1 / 180 * $pi))+$profile_constant) * $beam1;
$hitarea = $hita + $hitb;
$hitp1 = ( $hitarea / $percentile_constant / $range);
$hitp2 = ( $range * ( $optics1 + $crew_skill1 + $sighting1) / $scalefactor);
#$hitp2 = ( ( $optics1 + $crew_skill1 + $sighting1) / $scalefactor);
$hitprob = $hitp1 + $hitp2;
print "For Ship #1, HitArea computes to $hitarea, Probability of a hit from Ship #2 is $hitprob<br>\n";


$hita = ( abs(cos( $bearing2 / 180 * $pi)) + $profile_constant) * $length2;
$hitb = ( abs(sin( $bearing2 / 180 * $pi))+$profile_constant) * $beam2;
$hitarea = $hita + $hitb;
$hitp1 = ( $hitarea / $percentile_constant / $range);
#$hitp2 = ( ( $optics2 + $crew_skill2 + $sighting2) / $scalefactor);
$hitp2 = ( $range* ( $optics2 + $crew_skill2 + $sighting2) / $scalefactor);
$hitprob = $hitp1 + $hitp2;
print "For Ship #2, HitArea computes to $hitarea, Probability of a hit from Ship #1 is $hitprob<br>\n";
