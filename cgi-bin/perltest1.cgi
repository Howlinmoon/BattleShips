#!/usr/bin/perl -w
#
# Example 2-5. Drawing with polygons

use strict;
use GD;

my $image = new GD::Image(280,220);

# Create two new polygon objects

my $polygon1 = new GD::Polygon;
my $polygon2 = new GD::Polygon;

# Set up the points as a space-delimited string,
# compatible with the SVG polygon format

my $points1 = "140,140 220,60 220,10 270,60 220,60 ".
             "140,140 60,60 60,10 10,60 60,60 ";

my $points2 = "140,40 260,200 20,200";

# Add the points to each polygon

add_points($polygon1, $points1);
add_points($polygon2, $points2);

# Allocate colors; white is the background

my $white= $image->colorAllocate(255,255,255);
my $black = $image->colorAllocate(0,0,0);

# Draw the two extended triangles

$image->polygon($polygon1, $black);

# Draw the center triangle, filled

$image->filledPolygon($polygon2, $white);

# Stroke the center triangle

$image->polygon($polygon2, $black);

# Print the image

print "Content-type: image/png\n\n";
print $image->png();

exit;

# Split a space-delimited string of coordinates

sub add_points {
    my ($poly, $pts) = @_;
    foreach my $pair (split /\s/, $pts) {
        $pair =~ /(\d+),(\d+)/;
        $poly->addPt($1, $2);
    }
}
