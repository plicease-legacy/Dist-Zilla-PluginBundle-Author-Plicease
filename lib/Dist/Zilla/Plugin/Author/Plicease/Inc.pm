package Dist::Zilla::Plugin::Author::Plicease::Inc;

use strict;
use warnings;
use File::Spec;

# VERSION
# ABSTRACT: Include the inc directory to find plugins

use lib File::Spec->catdir(File::Spec->curdir(), 'inc');

sub log_debug { 1 }
sub plugin_name { 'Author::Plicease::Inc' }
sub dump_config { return; }
sub register_component { return; }

1;
