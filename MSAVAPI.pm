package MSAVAPI;

use warnings;
use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;
require AutoLoader;
#require Color;

@ISA     = qw(Exporter AutoLoader);
@EXPORT  = qw(load_alignment);
$VERSION = '2.0';

use constant {
  SHOW_CHAR => 0,
  FILE_ALN  => 'Alignments.txt',
  FILE_COL  => 'Colors.txt',
  FILE_ORD  => 'SequenceOrder.txt',
};

sub load_alignment {
  my $align_id  = shift;
  my $sequences = &load_sequences(FILE_ALN, FILE_ORD);
  my $colors    = &load_colors(FILE_COL);
  my $alignment = { id => $align_id, status => 1, sequences => $sequences, colors => $colors };
  return $alignment;
}

sub load_sequences {
  my ($aln_file, $order_file) = @_;
  my $sequences;
  my $aln_data  = &load_alignment_file($aln_file);
  my $seq_order = &load_sequence_order($order_file);
  for my $seq_info (@$seq_order) {
    my ($seq_number, $seq_color) = ($seq_info->{number}, $seq_info->{color});
    my $sequence = $aln_data->[$seq_number - 1];
    $sequence->{color} = $seq_color;
    push @$sequences, $sequence;
  }
  return $sequences;
}

sub load_alignment_file {
  my $aln_file = shift;
  my $aln_data;
  my $row = 0;
  open ALN, $aln_file or die "Input file ($aln_file) is missing.\n";
	our $/ = ">";
	for my $aln_input (<ALN>) {
		chomp $aln_input;
		$aln_input =~ /^(.*?)\n(.*)/s or next;
		my ($name, $seq) = ($1, $2);
		$row ++;
		$seq =~ s/\n//sg;
		push @$aln_data, { name => $name, seq => $seq, row => $row };
	}
	$/ = "\n";
  close ALN;
  return $aln_data;
}

sub load_sequence_order {
  my $seq_order_file = shift;
  my $seq_order;
  open ORDER, $seq_order_file or die "Input file ($seq_order_file) is missing.\n";
  for my $seq_info (<ORDER>) {
    chomp $seq_info;
    my ($seq_number, $seq_hue) = split /\t/, $seq_info;
    push @$seq_order, { number => $seq_number, color => &hue_to_html($seq_hue) };
  }
  close ORDER;
  return $seq_order;
}

sub load_colors {
  my $color_file = shift;
  my $colors;
  open COLORS, $color_file or die "Input file ($color_file) is missing.\n";
  for my $line (<COLORS>) {
    chomp $line;
    next if $line =~ /^#/;
    die unless $line =~ /^\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)$/;
    $colors->[$1][$2] = &rgb_to_html($3, $4, $5);
  }
  close COLORS;
  return $colors;
}

sub rgb_to_html {
  my ($r, $g, $b) = @_;
  $r = 0 if $r < 0; $g = 0 if $g < 0; $b = 0 if $b < 0; 
  $r = 1 if $r > 1; $g = 1 if $g > 1; $b = 1 if $b > 1; 
  return sprintf "#%01x%01x%01x", int($r * 15.99), int($g * 15.99), int($b * 15.99);
}

sub hue_to_html {
  my $hue = shift;
  
  sub hue2prim {
    my $h = shift;
    $h = $h % 360;
    if ($h < 60)  { return $h / 60; }
    if ($h < 180) { return 1; }
    if ($h < 240) { return (240 - $h) / 60; }
    return 0;
  }

  my $r = &hue2prim($hue + 120);
  my $g = &hue2prim($hue);
  my $b = &hue2prim($hue - 120);
  return &rgb_to_html($r, $g, $b);
}

1;
__END__
