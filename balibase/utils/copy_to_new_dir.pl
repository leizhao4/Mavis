#!/usr/bin/env perl

@files = `ls ../bb_mft_hot/*seqorder.txt`;

for my $file (@files) {
  die unless $file =~ /balibase\.([0-9]+)_seqorder/;
  my $number = $1;
  system("mkdir ../../data/$number");
  system("cp ../bb_mft_hot/balibase.$number\_mafft.fasta ../../data/$number/alignment.fasta");
  system("cp ../bb_mft_hot/balibase.$number\_mafft_cos_res_pair.scr ../../data/$number/scores.tsv");
  system("cp ../bb_mft_hot/balibase.$number\_colors.txt ../../data/$number/colors.tsv");
  system("cp ../bb_mft_hot/balibase.$number\_seqorder.txt ../../data/$number/order.tsv");
}