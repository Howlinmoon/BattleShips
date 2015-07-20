#!/usr/bin/perl -w

#use strict;
use diagnostics;
use CGI;  # available from http://www.perl.com/CPAN/

# Create an instance of CGI
my $query = new CGI;

# Send an appropriate MIME header
print $query->header("text/html");

print "Taking snapshot of current ship status page - click below to see it.<br>\n";

open (STATUS,"/home/www/game_design/ship_status.html");
open (SNAPSHOT,">/home/www/game_design/snapshot.html");
while (<STATUS>)
      {
      chop;
      if (/Refresh/)
         {
         print SNAPSHOT "<html>\n";
         }
      else
         {
         print SNAPSHOT "$_\n";
         }
       }
close (STATUS);
close (SNAPSHOT);
print "Snapshot taken - click <a href=\"/game_design/snapshot.html\">HERE</a> to view it.<br>\n";
    
