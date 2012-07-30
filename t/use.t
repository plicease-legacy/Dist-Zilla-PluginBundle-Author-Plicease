use strict;
use warnings;
use Test::More tests => 4;

use_ok 'Dist::Zilla::PluginBundle::Author::Plicease';
use_ok 'Dist::Zilla::Plugin::Author::Plicease::Init';
use_ok 'Dist::Zilla::MintingProfile::Plicease';
use_ok 'App::Plicease::Dev';
