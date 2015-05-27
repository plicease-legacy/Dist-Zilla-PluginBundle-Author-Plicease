use strict;
use warnings;
use 5.008001;
use Test::More tests => 2;
use Test::Script;

script_compiles 'example/unbundle.pl';

my $out = '';

script_runs     'example/unbundle.pl', { stdout => \$out };

note $out;
