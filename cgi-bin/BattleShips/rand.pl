#!/usr/bin/perl -w

# random_universe.pl
#Type . . . . . Mass (kg) . . Radius (pixels) . . Energy (Watts) . . frequency 
#Red Dwarf . . . . 1 E 27 . . . . . 2 . . . . . . . . 2 E 23 . . . . . 5% 
#White Dwarf . . . 1 E 28 . . . . . 4 . . . . . . . . 2 E 24 . . . . . 10% 
#Yellow . . . . . 2 E 30 . . . . . 70 . . . . . .. . 4 E 26 . . . . . 48% 
#Red Giant . . . . 3 E 33 . . . . . 300 . . . . . . . 6 E 29 . . . . . 30% 
#White Giant . . . 4 E 35 . . . . . 1590 . . . . .. . 7 E 31 . . . . . 3% 
#Blue Giant . . .. 5 E 36 . . . . . 3560 . . . . .. . 1 E 33 . . . . . 2% 
#Black Hole . . . .4 E 33 . . . . . 2 . . . . . . . . 0 . . . . . . . .2%

#Type . . . . Frequency . . . . avg distance from star (pixels) 
#Rocky . . . . . 50% . . . . . . 40 to 8,500 x diameter of star 
#Gas Giant . . . 50% . . . . . . 1,000 to 6,000 x diameter of star 

#Elements: 
#Oxygen, Hydrogen, Carbon, Silicon, Nitrogen, Sodium, Chlorine, Iron, Aluminum, Copper, Gold 
#Compounds 
#Water, Acetone, Carbon Dioxide 

#use strict;
use diagnostics;
use Mysql;

#init and define constants
$planet_index = 0;
$pi = 3.14159265358979323846;
$grav = 6.7E-11;
$number_of_stars = 100;
$star_name = 1;
open (STAR_NAMES,"planet.txt") || die "Could not open planet.txt\n";
open (PLANETS,">planets.data") || die "Could not open planets.data for writing\n";
open (STARS,">stars.data") || die "Could not open stars.data for writing\n";
while (<STAR_NAMES>) {
	chop;
	chop;
	$star_names[$star_name] = $_;
	$star_name_used[$star_name] = 0;
#	print "Star Name $star_names[$star_name]\n";
	$star_name +=1;
	}
	#print "A total of $star_name was found\n";

	for ($xx = 1; $xx < 101; $xx++) {
	$star_name_ok = 0;
	while ($star_name_ok == 0) {
                $star_name_guess = int(rand($star_name-1)+1);
#		print "rnd = $star_name_guess\n";
#                print "guessing...";
                if ($star_name_used[$star_name_guess] == 0) {
                        $star_name_ok = $star_name_guess;
                        $star_name_used[$star_name_guess] = 1;
                        $star_name[$xx] = $star_names[$star_name_ok];
#			print "chose $xx $star_name[$xx]\n";
                        } #end if
			else
			{
#			print "Guessing Again...";
			}
                } #end while
	} #end for
#for ($star_number=1; $star_number < ($number_of_stars+1);  $star_number++) {
#	print "Star # $star_number, Name = $star_name[$star_number]\n";
#	}
#exit;

for ($star_number=1; $star_number < ($number_of_stars+1);  $star_number++) {
	$angle[$star_number] = rand(2*$pi);
	$distance[$star_number] = int(rand(1.685E+10));
	$x_co_ord[$star_number] = int($distance[$star_number] * sin($angle[$star_number])) ;

	$y_co_ord[$star_number] = int($distance[$star_number] * cos($angle[$star_number]));
	print STARS "$x_co_ord[$star_number] , $y_co_ord[$star_number]\n";
	$star_type = int(rand(100)+1);
	if ($star_type < 6) {
		$star_kind = "Red Dwarf";
		$star_radius = 2;
		$star_mass = 1E+27;
		$star_energy = 2E+23;
		$num_planets = int(rand(1.6) - rand(1));
		if ($num_planets < 0) {
			$num_planets = 0;
			}

		}
	if ($star_type >5 && $star_type < 16) {
		$star_kind = "White Dwarf";
		$star_radius = 4;
		$star_mass = 1E+28;
		$star_energy = 2E+24;
		$num_planets = int(rand(2.2) - rand(2));
		if ($num_planets < 0) {
			$num_planets = 0;
			}

		}
	if ($star_type > 15 && $star_type < 64) {
		$star_kind = "Yellow";
		$star_radius = 70;
		$star_mass = 1E+30;
		$star_energy = 4E+26;
		$num_planets = int(rand(8)+1) + int(rand(8)+1);
		}
	if ($star_type > 63 && $star_type < 66) {
		$star_kind = "Black Hole";
		$star_radius = 2;
		$star_mass = 4E+33;
		$star_energy = 0;
		$num_planets = 0;
		}
	if ($star_type > 65 && $star_type < 96) {
		$star_kind = "Red Giant";
		$star_radius = 300;
		$star_mass = 3E+33;
		$star_energy = 6E+29;
		$num_planets = int(rand(8)+1) + int(rand(8)+1) + int(rand(8)+1);
		}
	if ($star_type > 95 && $star_type < 99) {
		$star_kind = "White Giant";
		$star_radius = 1590;
		$star_mass = 4E+35;
		$star_energy = 7E+31;
		$num_planets = int(rand(9) + 1) + int(rand(9)+1) + int(rand(9)+1);

		}
	if ($star_type > 98) {
		$star_kind = "Blue Giant";
		$star_radius = 3560;
		$star_mass = 5E+36;
		$star_energy = 1E+33;
		$num_planets = int(rand(10)+1)+int(rand(10)+1)+int(rand(10)+1);
		}
	$star_kind[$star_number] = $star_kind;
	$star_radius[$star_number] = $star_radius;
	$star_planets[$star_number] = $num_planets;
	$star_mass[$star_number] = $star_mass;
	$star_energy[$star_number] = $star_energy;
#	print "Star # $star_number Name: $star_name[$star_number]\n";
#	print "at X Co-Ord $x_co_ord[$star_number] Y Co-Ord $y_co_ord[$star_number] is a $star_kind[$star_number] star ($star_type) Mass of $star_mass\nIt has $star_planets[$star_number] Planets Oribitting it\n";	
	#exit;
	for ($planet_number =1; $planet_number<= $num_planets; $planet_number++) {
	$planet_index = $planet_index + 1;
 	if (int(rand(100)+1) > 50) {
		$planet_type[$planet_index] = "Gas Giant";
		$planet_diameter[$planet_index] = 10000 +int(rand(80000)+1)+int(rand(80000)+1);
		$planet_density[$planet_index] = 0;
		for ($repeats = 0; $repeats < 40; $repeats++) {
			$planet_density[$planet_index] = $planet_density[$planet_index] + int(rand(60)+1);
			}
		$K = .14;
		$orbit[$planet_index] = int( ( (1000 + 1/$K * exp(rand(1)/$K) * .8 * ($star_radius * 10000) * 2) )/10000 );
		$planet_angle[$planet_index] = rand(2*$pi);
		$planet_delta[$planet_index] = (200 * 2 * $pi / sqrt( (4 * ($pi**2) / ($grav * $star_mass)) * ($orbit[$planet_index] * 1E7)**3));
		
		}
		else {
		$planet_type[$planet_index] = "Rocky";
		$planet_diameter[$planet_index] = 1000 + int(rand(8000)+1) + int(rand(8000)+1);
		$planet_density[$planet_index] = 3000;
		for ($repeats = 0; $repeats < 100; $repeats++) {
			 $planet_density[$planet_index] = $planet_density[$planet_index] + int(rand(30)+1);
			}
		$K = .14;
		$orbit[$planet_index] = int( ( (40 + 1/$K * exp(rand(1)/$K) * .8 * ($star_radius * 10000) * 2) )/10000 );
		$planet_angle[$planet_index] = rand(2*$pi);
		$planet_delta[$planet_index] = (200 * 2 * $pi / sqrt( (4 * ($pi**2) / ($grav * $star_mass)) * ($orbit[$planet_index] * 1E7)**3));
		}
		$planet_name[$planet_index] = $star_name[$star_number] . "-" . $planet_number;
	$planet_star[$planet_index] = $star_number;
	$x_coord_planet[$planet_index] = int(sin($planet_angle[$planet_index]) * $orbit[$planet_index] + $x_co_ord[$star_number]);
	$y_coord_planet[$planet_index] = int(cos($planet_angle[$planet_index]) * $orbit[$planet_index] + $y_co_ord[$star_number]);
	
	print PLANETS "$x_coord_planet[$planet_index],$y_coord_planet[$planet_index]\n";	
	}	 

}

#exit;
#           master_star_chart
#+-----------+--------------+------+-----+---------+-------+
#| Field     | Type         | Null | Key | Default | Extra |
#+-----------+--------------+------+-----+---------+-------+
#| id_number | mediumint(9) |      | PRI | 0       |       |
#| x_co_ord  | mediumint(9) |      |     | 0       |       |
#| y_co_ord  | mediumint(9) |      |     | 0       |       |
#| type      | varchar(30)  |      |     |         |       |
#| mass      | varchar(10)  |      |     |         |       |
#| radius    | varchar(10)  |      |     |         |       |
#| energy    | varchar(10)  |      |     |         |       |
#| name      | varchar(50)  |      |     |         |       |
#| planets   | mediumint(9) |      |     | 0       |       |
#+-----------+--------------+------+-----+---------+-------+

#              master_planet_chart
#+-------------+--------------+------+-----+---------+-------+
#| Field       | Type         | Null | Key | Default | Extra |
#+-------------+--------------+------+-----+---------+-------+
#| id_number   | mediumint(9) |      | PRI | 0       |       |
#| x_co_ord    | mediumint(9) |      |     | 0       |       |
#| y_co_ord    | mediumint(9) |      |     | 0       |       |
#| init_angle  | mediumint(9) |      |     | 0       |       |
#| orbit_delta | mediumint(9) |      |     | 0       |       |
#| orbit       | mediumint(9) |      |     | 0       |       |
#| type        | varchar(15)  |      |     |         |       |
#| mass        | mediumint(9) |      |     | 0       |       |
#| density     | mediumint(9) |      |     | 0       |       |
#| name        | varchar(50)  |      |     |         |       |
#| star        | mediumint(9) |      |     | 0       |       |
#+-------------+--------------+------+-----+---------+-------+


# Connect via Unix sockets to the database on this server
my $dbh = Mysql->connect("localhost", "test");

# purge old star records before adding new ones
	my $command = "";
	$command = "delete from master_star_chart";
# Send the query
my $sth = $dbh->query($command);

# Make sure that $sth returned reasonably
die "Error with command $command" unless (defined $sth);

print "Return code was $sth\n";
 
# Insert Our Stars into the database

for ($star_number=1; $star_number < ($number_of_stars+1);  $star_number++) {
	
# Build up our SQL command
	$command = "";
#	$command = "insert into master_star_chart ";
	$command = "replace into master_star_chart ";
	$command .= "  (id_number,x_co_ord,y_co_ord,type,mass,radius,energy,name,planets) ";
	$command .= "values ";
	$command .= "  ($star_number,$x_co_ord[$star_number],$y_co_ord[$star_number], \"$star_kind[$star_number]\",";
	$command .= "$star_mass[$star_number],$star_radius[$star_number],$star_energy[$star_number],";
	$command .= "\"$star_name[$star_number]\",";
	$command .= "$star_planets[$star_number] )";
#exit;

# Uncomment for debugging
print "SQL command: $command\n";

# Send the query
 $sth = $dbh->query($command);

# Make sure that $sth returned reasonably
die "Error with command $command" unless (defined $sth);

print "Return code was $sth\n";
}

# Insert our Planets into the database

# purge old planet records before adding new ones
        $command = "";
        $command = "delete from master_planet_chart";
# Send the query
 $sth = $dbh->query($command);

# Make sure that $sth returned reasonably
die "Error with command $command" unless (defined $sth);

print "Return code was $sth\n";

for ($planet_number = 1; $planet_number <= $planet_index; $planet_number++) {
# Build up our SQL command
         $command = "";
#        $command = "insert into master_planet_chart ";
	$command = "replace into master_planet_chart ";
        $command .= "  (id_number,x_co_ord,y_co_ord,init_angle,orbit_delta,orbit,type,mass,density,name,star) ";
        $command .= "values ";
        $command .= "  ($planet_number,$x_coord_planet[$planet_number],$y_coord_planet[$planet_number],";
	$command .= "$planet_angle[$planet_number],$planet_delta[$planet_number],$orbit[$planet_number],";
	$command .= "\"$planet_type[$planet_number]\",1000,$planet_density[$planet_number],\"$planet_name[$planet_number]\",$planet_star[$planet_number] )";

# Uncomment for debugging
print "SQL command: $command\n";

# Send the query
 $sth = $dbh->query($command);

# Make sure that $sth returned reasonably
die "Error with command $command" unless (defined $sth);

print "Return code was $sth\n";
}
# purge old planet counts before adding new ones
        $command = "";
        $command = "delete from how_many_planets";
# Send the query
 $sth = $dbh->query($command);

# Make sure that $sth returned reasonably
die "Error with command $command" unless (defined $sth);

print "Return code was $sth\n";
	 $command = "";
	$command = "replace into how_many_planets (how_many) values ($planet_index) ";
	print "SQL Command:$command\n";
	$sth = $dbh->query($command);
die "error with command $command" unless (defined $sth);
print "return code was $sth\n";

