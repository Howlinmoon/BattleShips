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
if (! -f "upload/impulser.txt")
   {
   print "No new impulser.txt was uploaded - nothing to copy.<br>\n";
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
$backupname = "impulser.$rmon.$rmday.$rhour.$rmin.$rsec";
$cmd = "cp impulser.pl backups/$backupname";
system $cmd;
print "impulser backed up.<br>";
$cmd = "cp upload/impulser.txt impulser.pl";
system $cmd;
$cmd = "chmod a+rwx impulser.pl";
system $cmd;
print "new impulser copied over.";

exit;
