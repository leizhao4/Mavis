#!/usr/bin/env perl

print "#COL_NUMBER\t#ROW_NUMBER_1\t#ROW_NUMBER_2\t#RES_PAIR_SCORE\n";

for my $col (1 .. 21) {
  for my $row1 (1 .. 3) {
    for my $row2 (1 .. 3) {
      next unless $row1 < $row2;
      my $score = (21 - $col) * .05;
      print "$col\t$row1\t$row2\t$score\n";
    }
  }
}
