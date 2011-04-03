#!/usr/bin/env perl

use warnings;
use strict;
use CGI qw(:standard);
use JSON;
use MSAVAPI;

my $action   = param('action');
my $align_id = param('id');

print header('application/json');

if (!defined $action or $action eq 'alignment') {
  eval {
    print encode_json &load_alignment($align_id);
  }
  or do {
    print encode_json({ status => -1 });
  }
}
elsif ($action eq 'list') {
  opendir DATADIR, 'data' or die "Can't open data directory.";
  my @align_list = grep { /^[^\.]/ } readdir(DATADIR) or die "Can't read data directory.";
  closedir DATADIR;
  print encode_json [ @align_list ];
}
else {
  print encode_json({ status => -1 });
}
