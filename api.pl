#!/usr/bin/env perl

use warnings;
use strict;
use CGI qw(:standard);
use JSON;
use MSAVAPI;

my $alignment_id = param('id');

print header('application/json');
print encode_json &load_alignment($alignment_id);
