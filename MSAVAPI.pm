package MSAVAPI;

use warnings;
use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;
require AutoLoader;

@ISA     = qw(Exporter AutoLoader);
@EXPORT  = qw(load_alignment);
$VERSION = '2.0';

my $align_file  = 'Alignments.txt';
my $color_file  = 'Colors.txt';
my $order_file  = 'SequenceOrder.txt';

sub load_alignment {
  my $align_id  = shift;
  my $sequences = &load_sequences($align_file, $order_file);
  my $colors    = &load_colors($color_file);
  my $alignment = { id => $align_id, status => 1, sequences => $sequences, colors => $colors };
  return $alignment;
}

sub load_sequences {
  my ($align_file, $order_file) = @_;
  my $sequences;
  my $align_data = &load_alignment_file($align_file);
  my $order_data = &load_sequence_order($order_file);
  for my $order_info (@$order_data) {
    my $seq_info = $align_data->[$order_info->{row} - 1];
    push @$sequences, {(%$seq_info, %$order_info)};
  }
  return $sequences;
}

sub load_alignment_file {
  my $aln_file = shift;
  my $aln_data;
  open ALN, $aln_file or die "Input file ($aln_file) is missing.\n";
	our $/ = ">";
	for my $aln_input (<ALN>) {
		chomp $aln_input;
		$aln_input =~ /^(.*?)\n(.*)/s or next;
		my ($name, $seq) = ($1, $2);
		$seq =~ s/\n//sg;
		push @$aln_data, { name => $name, seq => $seq };
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
    my ($row, $seq_hue) = split /\t/, $seq_info;
    push @$seq_order, { row => $row, color => &hue_to_html($seq_hue) };
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
    next unless $line =~ /^\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)$/;
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
  my $r   = &hue2prim($hue + 120);
  my $g   = &hue2prim($hue);
  my $b   = &hue2prim($hue - 120);
  return &rgb_to_html($r, $g, $b);

  sub hue2prim {
    my $h = (shift) % 360;
    if ($h < 60)  { return $h / 60; }
    if ($h < 180) { return 1; }
    if ($h < 240) { return (240 - $h) / 60; }
    return 0;
  }
}

1;
__END__
