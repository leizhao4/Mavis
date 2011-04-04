#!/usr/bin/env perl

use warnings;
use strict;
use CGI qw(:standard);

print header('text/html');

my $count = 0;
print "<table><tr>\n";

open COLORS, "key_colors.tsv";
while (my $line = <COLORS>) {
  $count ++;
  chomp $line;
  my ($r, $g, $b) = split /\t/, $line;
  my $color = &rgb_to_html($r, $g, $b);
  print "<td style='background-color: $color'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>\n";
  print "</tr><tr>" if $count % 21 == 0;
}
close COLORS;

print "</tr></table>\n";

sub rgb_to_html {
  my ($r, $g, $b) = @_;
  $r = 0 if $r < 0; $g = 0 if $g < 0; $b = 0 if $b < 0; 
  $r = 1 if $r > 1; $g = 1 if $g > 1; $b = 1 if $b > 1; 
  return sprintf "#%01x%01x%01x", int($r * 15.99), int($g * 15.99), int($b * 15.99);
}
