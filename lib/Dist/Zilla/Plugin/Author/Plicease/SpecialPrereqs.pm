package Dist::Zilla::Plugin::Author::Plicease::SpecialPrereqs;

use strict;
use warnings;
use Moose;

# ABSTRACT: Special prereq handling
# VERSION

=head1 SYNOPSIS

 [Author::Plicease::SpecialPrereqs]

=head1 DESCRIPTION

Some older versions of modules have problematic for various
reasons (at least in the context of how I use them).  This
plugin will upgrade those prereqs to appropriate version
if they are C<0>, meaning any version.

Some modules are recommended if certain modules are already
prerequisites.  For example, XS modules may be recommended if
otherwise pure perl modules will optionally use them.

This plugin also enforces that releases are not done on
Perl 5.8 or C<MSWin32>.

=over 4

=item Moo

Require 2.x as this fixes the bug where fatal warnings was
enabled.

=item PerlX::Maybe

Require 0.003

=item File::HomeDir

Require 0.91 for File::HomeDir::Test

=item AnyEvent::Open3::Simple

Require 0.76 for new stdin style
Require 0.83 for deprecation removals

=item Path::Class

Require 0.26 for spew

=item Mojolicious

Require 4.31

=item Role::Tiny

Require 1.003001.  See rt#83248

=item JSON::XS

Recommended if JSON is required.

=item YAML::XS

Recommended if YAML is required.

=item PerlX::Maybe::XS

Recommended if PerlX::Maybe is required.

=item EV

Recommended if Mojolicious or AnyEvent modules are required.

=back

=cut

with 'Dist::Zilla::Role::BeforeRelease';
with 'Dist::Zilla::Role::PrereqSource';

my %upgrades = qw(
  Moo                                   2.0
  PerlX::Maybe                          0.003
  File::HomeDir                         0.91
  AnyEvent::Open3::Simple               0.83
  Path::Class                           0.26
  Mojolicious                           4.31
  Role::Tiny                            1.003001
);

sub register_prereqs
{
  my($self) = @_;

  my $prereqs = $self->zilla->prereqs->as_string_hash;
  foreach my $phase (keys %$prereqs)
  {
    foreach my $type (keys %{ $prereqs->{$phase} })
    {
      foreach my $module (sort keys %{ $prereqs->{$phase}->{$type} })
      {
        my $value = $prereqs->{$phase}->{$type}->{$module};
        next unless $value == 0;
        if($upgrades{$module})
        {
          $self->zilla->register_prereqs({
            type  => $type,
            phase => $phase,
          }, $module => $upgrades{$module} );
        }
      }
    }
  }

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

sub before_release
{
  my $self = shift;
  $self->log_fatal('release requires Perl 5.10 or better') if $] < 5.010000;
  $self->log_fatal('don\'t release via MSWin32')           if $^O eq 'MSWin32';
}

__PACKAGE__->meta->make_immutable;

1;
