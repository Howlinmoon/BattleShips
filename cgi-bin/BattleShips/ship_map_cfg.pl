#!/usr/bin/perl -w

use diagnostics;
use CGI;  # available from http://www.perl.com/CPAN/
# Create an instance of CGI
my $query = new CGI;

# Send an appropriate MIME header
print $query->header("text/html");

# Grab values from the form 
# Prints are for debug only

my $ship_id = $query->param("ship_id");
my $zoom_level = $query->param("zoom");
#print "ship_id = $ship_id, zoom = $zoom_level\n";
if (-f "stopped")
   {
   print "<h1>Impulser is STOPPED</h1><br>Please try again later.<br>\n";
   exit;
   }
open (ZOOM_SHIP,">zoom_ship");
print ZOOM_SHIP "$$\n";
close (ZOOM_SHIP);
open (ZOOM,">zoom_ship.$$");
print ZOOM "$ship_id:$zoom_level\n";
close (ZOOM);
while (-f "zoom_ship")
{
}
print "Ship #$ship_id\'s map zoom Level now at $zoom_level.<br>\n";
print "This will go into effect when the map is redrawn next impulse.<br>\n";
print "Return to <a href=\"/game_design/map_$ship_id.html\">Ship $ship_id</a> Text Map<br>\n";
exit;
