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

 # Basic - UploadToCPAN, Readme, ExtraTests, and ConfirmRelease
 [GatherDir]
 [PruneCruft]
 except = .travis.yml
 [ManifestSkip]
 [MetaYAML]
 [License]
 [ExecDir]
 [ShareDir]
 [MakeMaker]
 [Manifest]
 [TestRelease]

 [Author::Plicease::PrePodWeaver]
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
 
 [Author::Plicease::TransformTravis]
 
 [InstallGuide]
 [MinimumPerl]
 [ConfirmRelease] 

=head1 SEE ALSO

L<Author::Plicease::Init|Dist::Zilla::Plugin::Author::Plicease::Init>,
L<MintingProfile::Plicease|Dist::Zilla::MintingProfile::Author::Plicease>

=cut

with 'Dist::Zilla::Role::PluginBundle::Easy';

use namespace::autoclean;

sub configure
{
  my($self) = @_;

  $self->add_plugins(
    'GatherDir',
    [ PruneCruft => { except => '.travis.yml' } ],
    'ManifestSkip',
    'MetaYAML',
    'License',
    'ExecDir',
    'ShareDir',
    'MakeMaker',
    'Manifest',
    'TestRelease',
  );
  
  
  $self->add_plugins(qw(

    Author::Plicease::PrePodWeaver
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

  $self->add_plugins('Author::Plicease::Tests')
    if $self->payload->{release_tests};
    
  $self->add_plugins(qw(

    Author::Plicease::TransformTravis
    InstallGuide
    MinimumPerl
    ConfirmRelease

  ));
}

__PACKAGE__->meta->make_immutable;

1;
