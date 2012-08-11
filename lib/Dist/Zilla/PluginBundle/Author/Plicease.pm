package Dist::Zilla::PluginBundle::Author::Plicease;

use Moose;
use v5.10;
use Dist::Zilla;
use Dist::Zilla::Plugin::PodWeaver;
use Dist::Zilla::Plugin::NextRelease;
use Dist::Zilla::Plugin::AutoPrereqs;
use Dist::Zilla::PluginBundle::Git;
use Dist::Zilla::Plugin::Git;
use Dist::Zilla::Plugin::GitHub;
use Dist::Zilla::Plugin::ReadmeAnyFromPod;

# ABSTRACT: Dist::Zilla plugin bundle used by Plicease
# VERSION

=head1 SYNOPSIS

In your dist.ini:

 [@Author::Plicease]

=head1 DESCRIPTION

This Dist::Zilla plugin bundle is the equivalent to

 [@Filter]
 -bundle = @Basic
 -remove = UploadToCPAN
 -remove = Readme

 [PodWeaver]
 [NextRelease]
 [AutoPrereqs]

 [@Git]
 allow_dirty = dist.ini
 allow_dirty = Changes
 allow_dirty = README.pod

 [GitHub::Update]
 [GitHub::Meta]

=head1 SEE ALSO

L<App::Plicease::Dev>,
L<Author::Plicease::Init|Dist::Zilla::Plugin::Author::Plicease::Init>,
L<MintingProfile::Plicease|Dist::Zilla::MintingProfile::Plicease>

=cut

with 'Dist::Zilla::Role::PluginBundle::Easy';

use namespace::autoclean;

sub configure
{
  my($self) = @_;

  $self->add_bundle('Filter' => {
    -bundle => '@Basic',
    -remove => [ qw( UploadToCPAN Readme ) ],
  });

  $self->add_plugins(qw(

    PodWeaver
    NextRelease
    AutoPrereqs

  ));

  $self->add_bundle('Git' => {
    allow_dirty => [ qw( dist.ini Changes README.pod ) ],
  });

  $self->add_plugins(qw(

    GitHub::Update
    GitHub::Meta

  ));
}

__PACKAGE__->meta->make_immutable;

1;
