#!/usr/bin/env perl

use warnings;
use strict;
use CGI qw(:standard);
use JSON;
use MSAVAPI;

my $alignment_id = param('id');

print header('application/json');

eval {
  print encode_json &load_alignment($alignment_id);
}
or do {
  print encode_json({ status => -1, id => 'Error', sequences => [], colors => [[]] });
}
