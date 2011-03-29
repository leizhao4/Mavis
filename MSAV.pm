package MSAV;

use warnings;
use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;
require AutoLoader;
require Color;

@ISA     = qw(Exporter AutoLoader);
@EXPORT  = qw(visualize load_sequences load_colors create_css
              html_header html_footer alignment_header alignment_footer);
$VERSION = '1.0';

sub visualize {
  my $sequences = shift;
  my $html = "    <table class='aln_box' cellspacing='0'>\n";
  for my $sequence (@$sequences) {
    my $chars = [split //, $sequence->{seq}];
    $html .= "      <tr>\n";
  	$html .= "        <td id='seq_hue_$sequence->{row}'>&nbsp;</td>\n";
  	$html .= "        <td class='seq_name'>$sequence->{name}</td>\n";
  	for my $col (1 .. scalar @$chars) {
  	  my $char = $chars->[$col - 1] || '-';
  		$html .= "        <td id='cell_$sequence->{row}\_$col'>$char</td>\n";
  	}
  	$html .= "    </tr>\n";
  }
  $html .= "    </table>\n";
  return $html;
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
    $colors->[$1][$2] = $color;
  }
  close COLORS;
  return $colors;
}

sub create_css {
  my ($sequences, $colors, $show_char) = @_;
  my $css = <<HEADER;
    <style type="text/css">
      *     { margin: 0; padding: 0; font-family: Courier; font-size: 8pt; }
      body  { padding: 0 24px; }
      div.aln_header  { font-size: 28pt; margin: 18px 0; padding: 0 0 6px 6px; border-bottom: solid 1px #aaa; }
      div.aln_footer  { text-align: right; margin: 18px 0; padding: 6px 12px; border-top: solid 1px #aaa; }
      table.aln_box   { margin: 10px 20px; }
      .aln_box td     { color: #fff; }
      .aln_box td.seq_name  { color: #000; padding: 0 10px; }
HEADER
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

sub html_header {
  my $title = shift || 'Multiple Sequence Alignment Visualization';
  my $css   = shift || '';
  return <<HEADER;
Content-type: text/html\n
<html>
  <head>
    <title>$title</title>\n$css
  </head>
  <body>
HEADER
}

sub html_footer {
  return <<FOOTER;
  </body>
</html>
FOOTER
}

sub alignment_header {
  my $title = shift || 'Multiple Sequence Alignment Visualization';
  return "    <div class='aln_header'>$title</div>\n";
}

sub alignment_footer {
  my $time = localtime(time);
  return "    <div class='aln_footer'>$time</div>\n";
}

1;
__END__



