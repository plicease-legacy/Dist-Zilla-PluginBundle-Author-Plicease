use strict;
use warnings;
use 5.008001;
use Test::More;
use Test::Script;

plan skip_all => 'test requires Devel::Hide'
  unless eval { require Devel::Hide; };
plan tests => 2;

script_compiles 'example/unbundle.pl';

my $out = '';

script_runs     'example/unbundle.pl', { stdout => \$out };

note $out;
