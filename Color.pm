package Color;

use warnings;
use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;
require AutoLoader;

@ISA     = qw(Exporter AutoLoader);
@EXPORT  = qw();
$VERSION = '1.1';

### Constructor ###

sub new {
  my ($class, $r, $g, $b) = @_;
  my $self = bless { _r => $r, _g => $g, _b => $b }, $class;
  return $self;
}

sub new_from_hue {
  my ($class, $hue) = @_;
  
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

  return Color->new($r, $g, $b);
}

### Accessors ###

sub r { $_[0] -> {_r} }
sub g { $_[0] -> {_g} }
sub b { $_[0] -> {_b} }

### Methods ###

sub to_html {
  return to_html_3(@_);
}

sub to_html_3 {
  my $self = shift;
  my ($r, $g, $b) = ($self->r, $self->g, $self->b);
  $r = 0 if $r < 0; $g = 0 if $g < 0; $b = 0 if $b < 0; 
  $r = 1 if $r > 1; $g = 1 if $g > 1; $b = 1 if $b > 1; 
  my $html = sprintf "#%01x%01x%01x", int($r * 15.99), int($g * 15.99), int($b * 15.99);
  return $html;
}

sub to_html_6 {
  my $self = shift;
  my ($r, $g, $b) = ($self->r, $self->g, $self->b);
  $r = 0 if $r < 0; $g = 0 if $g < 0; $b = 0 if $b < 0; 
  $r = 1 if $r > 1; $g = 1 if $g > 1; $b = 1 if $b > 1; 
  my $html = sprintf "#%02x%02x%02x", int($r * 255), int($g * 255), int($b * 255);
  return $html;
}

1;
__END__



