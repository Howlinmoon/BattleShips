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

my $tf = $query->param("tf");
if ($tf == 0)
   {
   print "Sorry - you cannot give the NONE tf waypoints<br>\n";
   print "Nice try tho...<br>\n";
   exit;
   }

$pi = 3.14159265358979323846;

print "<FORM ACTION=\"/cgi-bin/game_design/chg_course_tf.pl\" ENCTYPE=\"x-www-form-urlencoded\"\n";
print "METHOD=\"POST\">\n";
print "Change Course: (in degrees) <INPUT NAME=\"change_course\" TYPE=\"text\" SIZE=\"15\">\n";
print "<input name=\"tf\" type=\"hidden\" value = \"$tf\">\n";
print "<INPUT NAME=\"change course\" TYPE=\"submit\" VALUE=\"change course\">\n";
print "</FORM>\n";

print "<FORM ACTION=\"/cgi-bin/game_design/chg_speed_tf.pl\" ENCTYPE=\"x-www-form-urlencoded\"\n";
print "METHOD=\"POST\">\n";
print "Change Speed:  <INPUT NAME=\"change_speed\" TYPE=\"text\" SIZE=\"5\">\n";
print "<input name=\"tf\" type=\"hidden\" value = \"$tf\">\n";
print "<INPUT NAME=\"change speed\" TYPE=\"submit\" VALUE=\"change speed\">\n";
print "</FORM>\n";

print "<FORM ACTION=\"/cgi-bin/game_design/add_waypoint_tf.pl\" ENCTYPE=\"x-www-form-urlencoded\"\n";
print "METHOD=\"POST\">\n";
print "Add a Waypoint: Waypoint (X,Y) <INPUT NAME=\"waypoint\" TYPE=\"text\" SIZE=\"15\">\n";
print "Speed Change: <input name=\"speed\" type = \"text\" size = \"3\">\n";
#if ($ship_class eq "Sub")
#   {
#   print "Depth Change: <input name=\"depth\" type =\"text\" size = \"3\">\n";
#   }
#   else
#   {
   print "<input name=\"depth\" type =\"hidden\" value = \"0\">\n";
#   }
print "<input name=\"tf\" type=\"hidden\" value = \"$tf\">\n";
print "<INPUT NAME=\"Add Waypoint\" TYPE=\"submit\" VALUE=\"Add Waypoint\">\n";
print "</FORM>\n";
print "<form action=\"/cgi-bin/game_design/dump_tf_waypoints.pl\">\n";
print "<br>Hit the Button to dump the TF waypoints ";
print "<input name = \"dump waypoints\" type = \"submit\" value = \"dump waypoints\">\n";
print "<input name = \"tf\" type = \"hidden\" value = \"$tf\">\n";
print "</form>\n";
