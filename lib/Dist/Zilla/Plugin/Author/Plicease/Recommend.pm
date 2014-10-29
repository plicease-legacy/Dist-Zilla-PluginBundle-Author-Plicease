package Dist::Zilla::Plugin::Author::Plicease::Recommend;

use strict;
use warnings;
use Moose;

# ABSTRACT: make some obvious recommendations
# VERSION

with 'Dist::Zilla::Role::PrereqSource';

sub register_prereqs
{
  my($self) = @_;

  my $prereqs = $self->zilla->prereqs->as_string_hash;
  foreach my $phase (keys %$prereqs)
  {
    foreach my $type (keys %{ $prereqs->{$phase} })
    {
      foreach my $module (keys %{ $prereqs->{$phase}->{$type} })
      {
        if($module =~ /^(JSON|YAML|PerlX::Maybe)$/)
        {
          $self->zilla->register_prereqs({
            type  => 'recommends',
            phase => $phase,
          }, join('::', $module, 'XS') => 0 );
        }
        my($first) = split /::/, $module;
        if($first =~ /^(AnyEvent|Mojo|Mojolicious)$/)
        {
          $self->zilla->register_prereqs({
            type  => 'recommends',
            phase => $phase,
          }, EV => 0);
        }
      }
    }
  }
}

__PACKAGE__->meta->make_immutable;

1;
