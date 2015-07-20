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
if (-f "auto_brit")
   {
   $auto_brit = "ENGAGED";
   }
   else
   {
   $auto_brit = "DISENGAGED";
   }
if (-f "auto_target")
   {
   $auto_germ = "ENGAGED";
   }
   else
   {
   $auto_germ = "DISENGAGED";
   }
print "British Fight Back AI is currently: $auto_brit<br>\n";
#print "German Fight Back AI is currently: $auto_germ<br>\n";
print "<p>British AI can be <a href=\"/cgi-bin/game_design/togg_brit.pl\">TOGGLED</a> on or off<br>\n";
#print "<p>German AI can be <a href=\"/cgi-bin/game_design/togg_germ.pl\">TOGGLED</a> on or off<br>\n";
print "<p>German AI is controlled via this <a href=\"/game_design/germanai.html\">control panel</a> now.<br>\n";
