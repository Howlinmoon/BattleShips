#!/usr/bin/perl -w

#use strict;
use diagnostics;
use CGI;  # available from http://www.perl.com/CPAN/
use Mysql;

# Create an instance of CGI
my $query = new CGI;

# Send an appropriate MIME header
print $query->header("text/html");
print "sorry - German AI is broken and staying off.";
exit;
# Grab values from the form 
# Prints are for debug only
if (-f "auto_target")
   {
   unlink  "auto_target";
   print "German AI is now disabled<br>\n";
   exit;
   }
   else
   {
   $cmd = "touch auto_target";
   system $cmd;
   print "German AI is now enabled<br>\n";
   exit;
   }

