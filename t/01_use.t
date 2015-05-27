use strict;
use warnings;
use Test::More tests => 8;

use_ok("Dist::Zilla::MintingProfile::Author::Plicease");
use_ok("Dist::Zilla::Plugin::Author::Plicease::Init2");
use_ok("Dist::Zilla::Plugin::Author::Plicease::PrePodWeaver");
use_ok("Dist::Zilla::Plugin::Author::Plicease::Tests");
use_ok("Dist::Zilla::Plugin::Author::Plicease::Thanks");
use_ok("Dist::Zilla::Plugin::Author::Plicease::Upload");
use_ok("Dist::Zilla::Plugin::Author::Plicease::InstallerPerlVersion");
use_ok("Dist::Zilla::PluginBundle::Author::Plicease");
