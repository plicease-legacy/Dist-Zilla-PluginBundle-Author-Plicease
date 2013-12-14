package Dist::Zilla::Plugin::Author::Plicease::FiveEight;

use Moose;

with 'Dist::Zilla::Role::BeforeRelease';

# ABSTRACT: Don't release on old perls
# VERSION

sub before_release
{
  my $self = shift;
  $self->log_fatal('release requires Perl 5.10 or better') if $] < 5.010000;
  $self->log_fatal('don\'t release via MSWin32')           if $^O eq 'MSWin32';
}

1;

