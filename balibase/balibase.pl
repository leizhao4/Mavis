#!/usr/bin/perl

use warnings;
use strict;
use Color;
use MSAV;

my $show_char  = 0;
my $file_align = 'Alignments.txt';
my $file_color = 'Colors.txt';
my $file_order = 'SequenceOrder.txt';

my $aln_num    = '';

if ($ENV{PATH_INFO} =~ /\/([0-9]+)/) {
  $aln_num = $1;
  $file_align = "bb_mft_hot/balibase.$aln_num\_mafft.fasta";
  $file_color = "bb_mft_hot/balibase.$aln_num\_colors.txt";
  $file_order = "bb_mft_hot/balibase.$aln_num\_seqorder.txt";
}

sub align_list {
  my $html = "    <div id='other_aligns'>BaliBASE Data Set:<br />\n";
  for (`ls bb_mft_hot/*_colors.txt`) {
    next unless /balibase\.([0-9]+)_colors.txt/;
    $html .= "      <a href='/msav/balibase/$1'>$1</a>\n";
  }
  $html .= "    </div><br /><br /><br />\n";
  return $html;
}

eval {
  my $title     = 'MSA Visualization';
  if ($aln_num eq '') {
    print &html_header($title);
    print &align_list;
    print &html_footer;
  }
  else {
    my $sequences = &load_sequences($file_align, $file_order);
    my $colors    = &load_colors($file_color);
    my $css       = &create_css($sequences, $colors, $show_char);
    $title .= " (Balibase $aln_num)" if $aln_num ne '';
    print &html_header($title, $css);
    print &alignment_header($title);
    print &visualize($sequences);
    print &alignment_footer;
    print &align_list;
    print &html_footer;
  }
  1;
}
or do {
  print &html_header('An Error Has Occured');
  print &alignment_header('An Error Has Occured');
  print $@;
  print &alignment_footer;
  print &html_footer;
}

