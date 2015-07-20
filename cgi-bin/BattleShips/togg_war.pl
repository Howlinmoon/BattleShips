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
if (-f "make_war")
   {
   print "WAR has already been declared.  Isn't it Glorius?!<br>\n";
   exit;
   }
$cmd = "touch make_war";
system $cmd;
$cmd = "chmod a+w make_war";
system $cmd;
print "War has now been declared!!<br>\n";
exit;
