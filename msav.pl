#!/usr/bin/perl

use warnings;
use strict;
use Color;
use MSAV;

use constant {
  SHOW_CHAR => 0,
  FILE_ALN  => 'Alignments.txt',
  FILE_COL  => 'Colors.txt',
  FILE_ORD  => 'SequenceOrder.txt',
};

eval {
  my $sequences = &load_sequences(FILE_ALN, FILE_ORD);
  my $colors    = &load_colors(FILE_COL);
  my $css       = &create_css($sequences, $colors, SHOW_CHAR);
  print &html_header('Multiple Sequence Alignment Visualization', $css);
  print &alignment_header('Multiple Sequence Alignment Visualization');
  print &visualize($sequences);
  print &alignment_footer;
  print &html_footer;
  1;
}
or do {
  print &html_header('An Error Has Occured');
  print &alignment_header('An Error Has Occured');
  print $@;
  print &alignment_footer;
  print &html_footer;
}

