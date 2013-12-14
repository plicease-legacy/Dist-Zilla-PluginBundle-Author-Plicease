package Dist::Zilla::MintingProfile::Author::Plicease::ModuleBuild;

use strict;
use warnings;
use base qw( Module::Build );

sub new
{
  my $class = shift;
  my %args = @_;

  unless($] < 5.010000)
  {
    $args{requires}->{$_} = 0 for qw( Dist::Zilla::PluginBundle::Git Dist::Zilla::Plugin::Git );
  }
  
  $class->SUPER::new(%args);
}

1;
