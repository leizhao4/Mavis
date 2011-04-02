#!/usr/bin/env perl

use warnings;
use strict;
use CGI qw(:standard);
use JSON;
use Color;
use MSAV;

use constant {
  SHOW_CHAR => 0,
  FILE_ALN  => 'Alignments.txt',
  FILE_COL  => 'Colors.txt',
  FILE_ORD  => 'SequenceOrder.txt',
};

eval {
  my $alignment = &load_sequences(FILE_ALN, FILE_ORD);
  my $colors    = &load_colors(FILE_COL);
  my $css       = &create_css($alignment, $colors, SHOW_CHAR);
  print header('application/json');
  print encode_json $alignment;
  #print &html_header('Multiple Sequence Alignment Visualization', $css);
  #print &show_alignment($sequences);
  #print &html_footer;
  1;
}
or do {
  #print &html_header('An Error Has Occured');
  #print &alignment_header('An Error Has Occured');
  print $@;
  #print &alignment_footer;
  #print &html_footer;
}

