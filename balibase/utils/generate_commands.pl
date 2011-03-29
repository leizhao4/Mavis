#!/usr/bin/perl

@align_files = `ls bb_mft_hot/*.fasta`;

for my $align_file (@align_files) {
  chomp $align_file;
  my $score_file = $align_file;
  my $color_file = $align_file;
  my $order_file = $align_file;
  $score_file =~ s/\.fasta/_cos_res_pair\.scr/;
  $color_file =~ s/mafft\.fasta/colors\.txt/;
  $order_file =~ s/mafft\.fasta/seqorder\.txt/;
  print "Rscript balibase.R $score_file $color_file $order_file\n";
}