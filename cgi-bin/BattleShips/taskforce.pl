#!/usr/bin/perl -w

#use strict;
use diagnostics;
use CGI;  # available from http://www.perl.com/CPAN/
use Mysql;

#mysql> describe how_many_taskforces;
#+----------+------------+------+-----+---------+-------+
#| Field    | Type       | Null | Key | Default | Extra |
#+----------+------------+------+-----+---------+-------+
#| how_many | tinyint(4) |      | PRI | 0       |       |
#+----------+------------+------+-----+---------+-------+

#mysql> describe task_force_master;
#+---------------+-------------+------+-----+---------+-------+
#| Field         | Type        | Null | Key | Default | Extra |
#+---------------+-------------+------+-----+---------+-------+
#| tf_id         | tinyint(4)  |      | PRI | 0       |       |
#| tf_name       | varchar(20) |      |     | 0       |       |
#| tf_country    | varchar(20) |      |     | 0       |       |
#| tf_type       | varchar(20) |      |     | 0       |       |
#| num_waypoints | tinyint(4)  |      |     | 0       |       |
#| tf_speed      | tinyint(4)  |      |     | 0       |       |
#| tf_course     | varchar(10) |      |     | 0       |       |
#| tf_depth      | tinyint(4)  |      |     | 0       |       |
#+---------------+-------------+------+-----+---------+-------+

# Create an instance of CGI
my $query = new CGI;

# Send an appropriate MIME header
print $query->header("text/html");

# Grab values from the form 
# Prints are for debug only

my $command = $query->param("command");
if ($command eq "add_tf")
   {
   my $taskforce = $query->param("taskforce");
   my $country = $query->param("country");
   print "$country has just submitted the new taskforce: $taskforce<br>\n";
   print "Waiting on Impulser to update SQL Server....<br>\n";
#  order impulser to save data to sql server and wait till it has done so.

   $cmd = "touch /home/www/cgi-bin/game_design/update_db";
#  implement a timeout sometime....
   system $cmd;
   while (-f "/home/www/cgi-bin/game_design/update_db")
         {
         }
#  impulser has now done so since semaphore file is gone.
   print "Now retrieving data from SQL server....<br>\n";
   my $dbh = Mysql -> connect("localhost","test");

   my $command = "";
   $command = "select how_many from how_many_taskforces";
   my $sth=$dbh-> query($command);
   die "Error with command $command\n" unless (defined $sth);
   my @arr=();
   while (@arr = $sth->fetchrow)
        {
        ($num_task_forces) = @arr;
        }
   if ($num_task_forces eq "")
      {
      $num_task_forces = 0;
      }
  $new_force_num = $num_task_forces + 1; 
  print "There are already $num_task_forces created, this will make $new_force_num TFs<br>\n";

# now signal impulser to add this new taskforce...
# prepare semaphore for instructing impulser about new taskforce.
$taskforce .=":".$country;

open (CHANGE_SPEED,">taskforce.$$");
print CHANGE_SPEED "$taskforce\n";
close (CHANGE_SPEED);

open (SEMAPHORE,">add_taskforce");
print SEMAPHORE "$$\n";
close (SEMAPHORE);

print "Signalling Impulser about new task force - waiting for ACK<br>\n";
while (-f "add_taskforce")
{
}
print "Semaphore acknowledged - task force added<br>\n";
exit;
   }

if ($command eq "del_tf")
   {
   my $taskforce = $query->param("taskforce");
   print "I was ordered to delete the taskforce: $taskforce<br>\n";
   }
if ($command eq "add_ship")
   {
   my $ship_id = $query->param("ship_id");
   my $taskforce = $query->param("taskforce");
   print "I was ordered to assign ship #$ship_id to taskforce: #$taskforce<br>\n";
# now signal impulser to add this ship to this  taskforce...
  $data = $ship_id . ":" . $taskforce;
  open (CHANGE_SPEED,">add_ship_force.$$");
  print CHANGE_SPEED "$data\n";
  close (CHANGE_SPEED);

  open (SEMAPHORE,">add_ship_force");
  print SEMAPHORE "$$\n";
  close (SEMAPHORE);

  print "Signalling Impulser about new task force - waiting for ACK<br>\n";
  while (-f "add_ship_force")
        {
        }
  print "Semaphore acknowledged - ship added to task force<br>\n";
  exit;
   }
if ($command eq "del_ship")
   {
   my $ship_id = $query->param("ship_id");
   my $taskforce = $query->param("taskforce");
   print "I was ordered to remove ship #$ship_id from taskforce: $taskforce<br>\n"
   }
