#!/usr/bin/perl -w

#use strict;
use diagnostics;
use CGI;  # available from http://www.perl.com/CPAN/
use Mysql;

# Create an instance of CGI
my $query = new CGI;

# Send an appropriate MIME header
print $query->header("text/html");
#print "sorry - British intelligence is on vacation.";
#exit;
# Grab values from the form 
# Prints are for debug only
if (-f "auto_brit")
   {
   unlink  "auto_brit";
   print "British AI is now disabled<br>\n";
   exit;
   }
   else
   {
   $cmd = "touch auto_brit";
   system $cmd;
   print "British AI is now enabled<br>\n";
   exit;
   }

