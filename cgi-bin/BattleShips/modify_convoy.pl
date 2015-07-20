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
my $convoy_id = $query->param("convoy");

print "<FORM ACTION=\"/cgi-bin/game_design/chg_convoy_spd.pl\" ENCTYPE=\"x-www-form-urlencoded\"\n";
print "METHOD=\"POST\">\n";
print "New Speed for Convoy #$convoy_id <INPUT NAME=\"speed\" TYPE=\"text\" SIZE=\"2\">\n";
print "<INPUT NAME=\"convoy\" TYPE=\"hidden\" VALUE=\"$convoy_id\">\n";
print "<INPUT NAME=\"Modify Speed\" TYPE=\"submit\" VALUE=\"Modify Speed\">\n";
print "</FORM>\n";

print "<FORM ACTION=\"/cgi-bin/game_design/init_convoy.pl\" ENCTYPE=\"x-www-form-urlencoded\"\n";
print "METHOD=\"POST\">\n";
print "<input name=\"convoy\" type=\"hidden\" value = \"$convoy_id\">\n";
print "X,Y Separation between Convoy Members: <INPUT NAME=\"xy_spacing\" TYPE=\"text\" SIZE=\"8\"><br>\n";
print "Absolute X,Y Location of Lead Convoy Ship: <input name=\"convoy_start\" type=\"text\" size=\"8\"><br>\n";
print "Number of Columns in Convoy: <input name=\"columns\" type=\"text\" size = \"2\"><br>\n";
print "(Rows will be determined automatically)<br>\n";
print "Zig Interval: <input name=\"zig\" type=\"text\" size = \"10\"><br>\n";
print "Number of Course changes 2/3 (3 includes a \"straight\"): <INPUT NAME=\"changes\" TYPE=\"text\" size=\"1\"><br>\n";
print "Base Convoy Course and Zig Offset (Deg,Off): <INPUT NAME=\"course\" TYPE=\"text\" SIZE=\"10\"><br>\n";
print "NOTE: These changes will go into effect the next time a refloat is done.<br>\n";
print "<INPUT NAME=\"Initialize Convoy\" TYPE=\"submit\" VALUE=\"Initialize Convoy\">\n";
print "</FORM>\n";
