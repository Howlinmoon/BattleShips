#!/usr/bin/perl -w

#use strict;
use diagnostics;
use CGI;  # available from http://www.perl.com/CPAN/
use Mysql;
my $dbh = Mysql -> connect("localhost","test");
# Create an instance of CGI
my $query = new CGI;

# Send an appropriate MIME header
print $query->header("text/html");

# Grab values from the form 
# Prints are for debug only

my $target = $query->param("target");
my $ship_id = $query->param("ship_id");
#print "Ship $ship_id will now have $target as it's target<br>\n";
if ($target eq "none")
   {
   $target = 0;
   print "What are ya - a COWARD?! You're a WARSHIP!<br>\n";
   }
if ($ship_id == $target)
   {
   print "Sorry - you can not target yourself.<br>\n";
   exit;
   }
# prepare semaphore for instructing impulser about speed change.

$command = "replace into targets (ship_id,target) values ($ship_id,\"$target\")";
#print "Command = $command<br>\n";
$sth = $dbh -> query($command);
die "Error with command: $command\n" unless (defined $sth);

print "<br>\n";
if ($target eq "none")
   {
   print "This Ship has no targets defined.<br>\n";
   }
   else
   {
   print "This Ship has the following target: $target<br>\n";
   }

open (CHANGE_SPEED,">add_target.$$");
print CHANGE_SPEED "$ship_id:$target\n";
close (CHANGE_SPEED);

open (SEMAPHORE,">add_target");
print SEMAPHORE "$$\n";
close (SEMAPHORE);

print "Signalling Impulser about target change - waiting for ACK<br>\n";
while (-f "add_target")
{
}
print "Received ACK - ship now has it's target modified.<br>\n";
print "Return to <a href=\"http://bigorc.com:4080/game_design/ship_status.html\">Ship Status Page</a><br>\n";
