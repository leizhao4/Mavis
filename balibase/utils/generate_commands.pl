#!/usr/bin/perl

@align_files = `ls ../bb_mft_hot/*.fasta`;
my $file_id  = 1;
my $count    = 0;
open OUTPUT, '>'.&filename($file_id);

for my $align_file (@align_files) {
  chomp $align_file;
  my $score_file = $align_file;
  my $color_file = $align_file;
  my $order_file = $align_file;
  $score_file =~ s/\.fasta/_cos_res_pair\.scr/;
  $color_file =~ s/mafft\.fasta/colors\.txt/;
  $order_file =~ s/mafft\.fasta/seqorder\.txt/;
  $count ++;
  print OUTPUT "Rscript balibase.R $score_file $color_file $order_file\n";
  if ($count % 40 == 0) {
    close OUTPUT;
    $file_id ++;
    open OUTPUT, '>'.&filename($file_id);
  }
}

close OUTPUT;

sub filename {
  my $file_id = shift;
  return "commands_bb_$file_id.sh";
}
