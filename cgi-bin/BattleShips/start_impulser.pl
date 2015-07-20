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
if ( -f "start_run")
   {
   print "Start semphore already set - check back in 5 minutes.<br>";
   exit;
   }
if (! -f "stopped")
   {
   print "Impulser is already running.<br>";
   exit;
   }
($rsec,$rmin,$rhour,$rmday,$rmon,$ryear,$wday,$yday,$isdst) = localtime(time);
if ($rsec < 10) {
        $rsec = "0".$rsec;
        }
if ($rmin < 10) {
        $rmin = "0".$rmin;
        }
if ($rhour < 10) {
        $rhour = "0".$rhour;
        }
if ($rmday < 10) {
        $rmday = "0".$rmday;
        }
$rmon=$rmon+1;
if ($rmon < 10) {
        $rmon = "0".$rmon;
        }
$junk = $isdst;
$junk = $yday;
$junk = $wday;
print "current system time is $rhour:$rmin<br>"; 
print "setting start run semaphore - is checked every 5 minutes...<br>";
$cmd = "touch start_run";
system $cmd;
$cmd = "chmod a+rw start_run";
system $cmd;
