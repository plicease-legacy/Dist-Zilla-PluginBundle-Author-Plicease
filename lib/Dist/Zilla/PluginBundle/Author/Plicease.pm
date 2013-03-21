package Dist::Zilla::PluginBundle::Author::Plicease;

use Moose;
use v5.10;
use Dist::Zilla;

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
 -remove = ExtraTests

 [PodWeaver]
 [NextRelease]
 [AutoPrereqs]
 [OurPkgVersion]
 [MetaJSON]

 [@Git]
 allow_dirty = dist.ini
 allow_dirty = Changes
 allow_dirty = README.pod

 [AutoMetaResources]
 bugtracker.github = user:plicease
 repository.github = user:plicease
 homepage = http://perl.wdlabs.com/%{dist}/
 
 [InstallGuide]
 [MinimumPerl]

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
    -remove => [ qw( UploadToCPAN Readme ExtraTests ) ],
  });

  $self->add_plugins(qw(

    PodWeaver
    NextRelease
    AutoPrereqs
    OurPkgVersion
    MetaJSON

  ));

  $self->add_bundle('Git' => {
    allow_dirty => [ qw( dist.ini Changes README.pod ) ],
  });

  $self->add_plugins([
    AutoMetaResources => {
      'bugtracker.github' => 'user:plicease',
      'repository.github' => 'user:plicease',
      homepage            => 'http://perl.wdlabs.com/%{dist}/',
    }
  ]);

  $self->add_plugins(qw(

    InstallGuide
    MinimumPerl

  ));
}

__PACKAGE__->meta->make_immutable;

1;
