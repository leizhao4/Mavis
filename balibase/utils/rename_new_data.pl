#!/usr/bin/env perl

@files = `ls ../../data`;

for my $file (@files) {
  next unless $file =~ /([0-9]+)/;
  my $number = $1;
  system("svn rename ../../data/$number ../../data/balibase_$number");
}