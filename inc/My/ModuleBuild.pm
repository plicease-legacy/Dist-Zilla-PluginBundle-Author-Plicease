package My::ModuleBuild;

use strict;
use warnings;
use 5.008001;
use base qw( Module::Build );

sub new
{
  my($class, %args) = @_;

  $args{requires}->{'Dist::Zilla::PluginBundle::Git'} = 0
    if $] >= 5.010000 && $^O ne 'MSWin32';

  my $self = $class->SUPER::new(%args);
  
  return $self;
}

1;
