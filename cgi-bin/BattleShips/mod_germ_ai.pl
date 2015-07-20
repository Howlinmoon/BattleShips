#!/usr/bin/perl -w

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
my $dbh = Mysql -> connect("localhost","test");

my $ship_id = $query->param("ship_id");
my $use_ai = $query->param("use_ai");
my $target_range = $query->param("target_range");
my $outnumber = $query->param("outnumber");
my $float_thresh = $query->param("float_thresh");
my $pursue = $query->param("pursue");
my $closer = $query->param("closer");
my $damaged = $query->param("damaged");
my $use_broadside = $query->param("broadside");
my $return_fire = $query->param("return_fire");

print "The SHIP ID passed is $ship_id, I'll check later if it is a German...<br>\n";
print "Should this ship use AI? Answer is $use_ai<br>\n";
if ($use_ai eq "NO")
   {
   print "Thats all our questions. You may leave now.<br>\n";
#   exit;
   }
print "What Range should this ship try to close to? $target_range<br>\n";
print "Should this vessel allow it self to be outnumbered? $outnumber<br>\n";
if ($outnumber eq "YES")
   {
   print "Thats the spirit!!<br>\n";
   }
print "At what percent of flotations remaining should this vessel retreat? $float_thresh<br>\n";
if ($float_thresh > 30)
   {
   print "and you call yourself a German?! Wimp!<br>\n";
   }
print "Will this Vessel pursue the only target it sees out of gunnery range? $pursue<br>\n";
print "should this vessel always switch to the closer target (if any)? $closer<br>\n";
print "should this vessel always switch to the more damaged target? (if any) $damaged<br>\n";
print "should this vessel attempt to turn broadside when in range? $use_broadside<br>\n";
print "thats it for now<br>\n";
my $command = "replace into german_ai (use_ai, close_target, use_broadside, fight_outnumb, float_thresh, pursue_target, switch_closest, switch_damaged, ship_id, return_fire) values ( \"$use_ai\",$target_range,\"$use_broadside\",\"$outnumber\",$float_thresh,\"$pursue\",\"$closer\",\"$damaged\",$ship_id,\"$return_fire\")";
print "command line = $command<br>\n";
my $sth = $dbh->query($command);
die "error with command $command" unless (defined $sth);
print "I think it worked - check with the sql interface...<br>\n";
print "Now ordering the impulser to read the AI settings...<br>\n";
$cmd = "touch read_gai";
system $cmd;
exit;
