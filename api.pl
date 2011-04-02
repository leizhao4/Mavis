#!/usr/bin/env perl

use warnings;
use strict;
use CGI qw(:standard);
use JSON;
use Color;

use constant {
  SHOW_CHAR => 0,
  FILE_ALN  => 'Alignments.txt',
  FILE_COL  => 'Colors.txt',
  FILE_ORD  => 'SequenceOrder.txt',
};

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
    push @$seq_order, { number => $seq_number, hue => $seq_hue };
  }
  close ORDER;
  return $seq_order;
}

sub load_sequences {
  my ($aln_file, $order_file) = @_;
  my $sequences;
  my $aln_data  = &load_alignment_file($aln_file);
  my $seq_order = &load_sequence_order($order_file);
  for my $seq_info (@$seq_order) {
    my ($seq_number, $seq_hue) = ($seq_info->{number}, $seq_info->{hue});
    my $sequence = $aln_data->[$seq_number - 1];
    $sequence->{hue} = $seq_hue;
    push @$sequences, $sequence;
  }
  return $sequences;
}

sub load_colors {
  my $color_file = shift;
  my $colors;
  open COLORS, $color_file or die "Input file ($color_file) is missing.\n";
  for my $line (<COLORS>) {
    chomp $line;
    next if $line =~ /^#/;
    die unless $line =~ /^\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)$/;
    my $color = Color->new($3, $4, $5);
    $colors->[$1][$2] = $color->to_html;
  }
  close COLORS;
  return $colors;
}

sub create_css {
  my ($sequences, $colors, $show_char) = @_;
  my $css = "<style type='text/css'>\n";
  for my $sequence (@$sequences) {
    my $row = $sequence->{row};
    my $seq = $sequence->{seq};
    my $hue = $sequence->{hue};
    my $hue_html = Color->new_from_hue($hue)->to_html;
    $css .= "      td#seq_hue_$row { background-color: $hue_html; }\n";
  	for my $col (1 .. length $seq) {
  	  my $color      = $colors->[$col][$row];
  	  my $color_html = $color ? $color->to_html : next;
  	  my $char_html  = $show_char ? '' : " color: $color_html;";
    	$css .= "      td#cell_$row\_$col { background-color: $color_html;$char_html }\n";
  	}
  }
  $css .= "    </style>";
  return $css;
}


if (param()) {
  if (param('action') eq 'alignment') {
    my $alignment = &load_sequences(FILE_ALN, FILE_ORD);
    print header('application/json');
    print encode_json $alignment;
  }
  elsif (param('action') eq 'colors') {
    my $colors = &load_colors(FILE_COL);
    print header('application/json');
    print encode_json $colors;
  }
}
else {
  my $colors = &load_colors(FILE_COL);
  print header('application/json');
  print encode_json $colors;
}
