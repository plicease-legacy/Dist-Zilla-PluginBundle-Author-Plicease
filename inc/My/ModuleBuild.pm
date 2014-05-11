package My::ModuleBuild;

use strict;
use warnings;
use base qw( Module::Build );

sub new
{
  my $class = shift;
  my %args = @_;

  if($] >= 5.010000 && $^O ne 'MSWin32')
  {
    $args{requires}->{$_} = 0 for qw( Dist::Zilla::PluginBundle::Git Dist::Zilla::Plugin::Git );
  }
  
  $class->SUPER::new(%args);
}

1;
