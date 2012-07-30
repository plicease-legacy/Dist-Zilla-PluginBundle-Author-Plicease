use strict;
use warnings;
use Test::More tests => 8;

use_ok 'Dist::Zilla::PluginBundle::Author::Plicease';
use_ok 'Dist::Zilla::Plugin::Author::Plicease::Init';
use_ok 'Dist::Zilla::MintingProfile::Plicease';
use_ok 'App::Plicease::Dev';
use_ok 'App::Plicease::Dev::PMWhich';
use_ok 'App::Plicease::Dev::ProveAll';
use_ok 'App::Plicease::Dev::RemoveTrailingSpace';
use_ok 'App::Plicease::Dev::Doc';
