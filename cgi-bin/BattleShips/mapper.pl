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
#| ship_heading        | varchar(6)   |      |     |         |       |
#| ship_x              | varchar(12)  |      |     |         |       |
#| ship_y              | varchar(12)  |      |     |         |       |
#| ship_speed          | varchar(5)   |      |     |         |       |
#| ship_sighting_range | varchar(12)  |      |     |         |       |
#| ship_sight_factor   | varchar(5)   |      |     |         |       |
#| hull_class          | varchar(20)  | YES  |     | NULL    |       |
#| depth               | mediumint(9) |      |     | 0       |       |
#| task_force          | mediumint(9) |      |     | 0       |       |
#+---------------------+--------------+------+-----+---------+-------+

#mysql> describe how_many_waypoints;
#+----------+--------------+------+-----+---------+-------+
#| Field    | Type         | Null | Key | Default | Extra |
#+----------+--------------+------+-----+---------+-------+
#| how_many | mediumint(9) |      | PRI | 0       |       |
#+----------+--------------+------+-----+---------+-------+

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

#print "Waiting on Impulser to update SQL Server....<br>\n";
#order impulser to save data to sql server and wait till it has done so.

$cmd = "touch /home/www/cgi-bin/game_design/update_db";
#implement a timeout sometime....
system $cmd;
while (-f "/home/www/cgi-bin/game_design/update_db")
{
}
#impulser has now done so since semaphore file is gone.
print "Now creating map...<br>\n";
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

for ($current_ship = 1; $current_ship <= $test_ships; $current_ship++) {

	$command = "select ship_id, ship_name, ship_owner, ship_heading, ship_x, ship_y, ship_speed, ship_sighting_range, ship_sight_factor, hull_class, depth, task_force, ship_class, crew_skill from master_ship_chart where ship_id = $current_ship";

$sth = $dbh -> query($command);
die "Error with command: $command\n" unless (defined $sth);

# iterate thru the returned rows

@arr = ($sth->fetchrow);
	{
	($ship_id[$current_ship],$ship_name[$current_ship],$ship_owner[$current_ship],$ship_course[$current_ship],$ship_x[$current_ship],$ship_y[$current_ship],$ship_speed[$current_ship],$ship_sighting_range[$current_ship],$ship_sight_factor[$current_ship],$hull_class[$current_ship], $depth[$current_ship], $task_force[$current_ship], $ship_class[$current_ship], $crew_skill[$current_ship] ) = @arr;
	}
}
   $lowest_x = 99999;
   $highest_x = -99999;
   $lowest_y = 99999;
   $highest_y = -99999;
   
   for ($qq = 1; $qq <= $test_ships; $qq++)
       {
#       print "qq = $qq, ship_x = $ship_x[$qq] , highest_x = $highest_x\n";
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
   $x_dif = $highest_x - $lowest_x;
   $y_dif = $highest_y - $lowest_y;
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
   for ($x = 0; $x <= 80; $x++)
       {
       for($y = 0; $y <= 80; $y++)
          {
          $map[$x][$y] = ".";
          }
       }
   for ($qq = 1; $qq <= $test_ships; $qq++)
       {
       $ship_x_scaled = int( ($ship_x[$qq] - $lowest_x) * $x_scaled);
       $ship_y_scaled = 80 - int( ($ship_y[$qq] - $lowest_y) * $y_scaled);
       $map[$ship_x_scaled][$ship_y_scaled] = "$qq";
       }
  open (MAP,">/home/www/game_design/map.txt") || die "Could'nt open map for writing!\n";
 for ($yy = 0; $yy <= 80; $yy++)
       {
       for($xx = 0; $xx <= 80; $xx++)
          {
          print MAP "$map[$xx][$yy]";
          }
       print MAP "\n";
       }
close (MAP);
print "Map is now ready for <a href=\"/game_design/map.txt\">viewing here</a> You probally want to \"shift-reload\" after viewing to ensure viewing fresh copy...\n";

