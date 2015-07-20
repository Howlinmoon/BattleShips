#!/usr/bin/perl -w

#$pi = 3.14159265358979323846;
$Gee = .000196;
$C = 6000;

#+---------------+--------------+------+-----+---------+-------+
#| Field         | Type         | Null | Key | Default | Extra |
#+---------------+--------------+------+-----+---------+-------+
#| id_number     | mediumint(9) |      | PRI | 0       |       |
#| current_x     | varchar(15)  |      |     |         |       |
#| current_y     | varchar(15)  |      |     |         |       |
#| velocity_x    | varchar(20)  |      |     |         |       |
#| velocity_y    | varchar(20)  |      |     |         |       |
#| accel_x       | varchar(20)  |      |     |         |       |
#| accel_y       | varchar(20)  |      |     |         |       |
#| warp_factor   | mediumint(9) |      |     | 0       |       |
#| overall_velo  | varchar(20)  |      |     |         |       |
#| heading       | varchar(20)  |      |     |         |       |
#| overall_accel | varchar(20)  |      |     |         |       |
#| name          | varchar(30)  | YES  |     | NULL    |       |
#+---------------+--------------+------+-----+---------+-------+

#use strict;
use diagnostics;
#use CGI;  # available from http://www.perl.com/CPAN/
use Mysql;

# Create an instance of CGI
#my $query = new CGI;

# Send an appropriate MIME header
#print $query->header("text/html");

# Grab values from the form 
# Prints are for debug only
# Impulse accel table in Gravs
$imp_accel[1] = 1.0;
$imp_accel[2] = 2.0;
$imp_accel[3] = 2.5;
$imp_accel[4] = 3.0;
$imp_accel[5] = 5.0;
$imp_accel[6] = 10.0;
# Warp Factor Table

for ($xx = 1; $xx <= 9; $xx++) {
	$imp_accel[6+$xx] = $xx;
}


print "Ship Speed Index:(refer to the source of the form for this meaning)  $ship_speed\n<br>";


# need to retrieve the current ship ID number - increment and use it.
# get this value from SQL database

my $dbh = Mysql -> connect("localhost","test");

my $command = "";
        $command = "select how_many from how_many_test_ships";
        my $sth=$dbh-> query($command);
        die "Error with command $command\n" unless (defined $sth);
        my @arr=();
        while (@arr = $sth->fetchrow)
        {
        ($test_ships) = @arr;
        }

print "Currently There are $test_ships on file - this will be ";
	$test_ships = $test_ships + 1;
print "the $test_ships ship on file\n<br>";
	

# purge old test ship count before adding new one
        $command = "delete from how_many_test_ships";
# Send the query
$sth = $dbh->query($command);

# Make sure that $sth returned reasonably
die "Error with command $command" unless (defined $sth);
$test_ships = 0;
#print "Return code was $sth\n";
        $command = "";
        $command = "replace into how_many_test_ships (how_many) values ($test_ships) ";
 #       print "SQL Command:$command\n";
        $sth = $dbh->query($command);
die "error with command $command" unless (defined $sth);
#print "return code was $sth\n";

print "\nSQL database updated with new total of test ships en route.\n<br>";


