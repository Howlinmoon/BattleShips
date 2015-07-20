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

my $ship_id = $query->param("ship_id");
print "Purging the Ships log for Ship #$ship_id<br>\n";
$cmd = "rm /home/www/game_design/ships_logs/ships_log_$ship_id.txt";
system $cmd;
if (-f "/home/www/game_design/ships_logs/ships_log_$ship_id.txt")
   {
   print "failed to purge log.<br>\n";
   exit;
   }
$cmd = "cp /home/www/game_design/ships_logs/empty.log  /home/www/game_design/ships_logs/ships_log_$ship_id.txt";
system $cmd;
$cmd = "chmod g+rwx /home/www/game_design/ships_logs/ships_log_$ship_id.txt";
system $cmd;
print "DONE - Ships log emptied.<br>\n";
print "Return to <a href=\"http://bigorc.com:4080/game_design/ship_status.html\">Ship Status Page</a><br>\n";
