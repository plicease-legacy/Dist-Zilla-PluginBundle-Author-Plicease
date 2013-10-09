package Dist::Zilla::PluginBundle::Author::Plicease;

use Moose;
use v5.10;
use Dist::Zilla;
use PerlX::Maybe qw( maybe );

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
 format = %-9v %{yyyy-MM-dd HH:mm:ss Z}d
 [AutoPrereqs]
 [OurPkgVersion]
 [MetaJSON]
 
 [@Git]
 allow_dirty = dist.ini
 allow_dirty = Changes
 allow_dirty = README.md
 
 [AutoMetaResources]
 bugtracker.github = user:plicease
 repository.github = user:plicease
 homepage = http://perl.wdlabs.com/%{dist}/
 
 [Author::Plicease::TransformTravis]
 
 [InstallGuide]
 [MinimumPerl]
 [ConfirmRelease] 
 
 [ReadmeAnyFromPod]
 type     = text
 filename = README
 location = build
 
 [ReadmeAnyFromPod / ReadMePodInRoot]
 type     = markdown
 filename = README.md
 location = root
 
 [Author::Plicease::MarkDownCleanup]
 [Author::Plicease::Recommend]

=head1 OPTIONS

=head2 installer

Specify an alternative to L<[MakeMaker]|Dist::Zilla::Plugin::MakeMaker>
(L<[ModuleBuild]|Dist::Zilla::Plugin::ModuleBuild>,
L<[ModuleBuildTiny]|Dist::Zilla::Plugin::ModuleBuildTiny>, or
L<[ModuleBuildDatabase]|Dist::Zilla::Plugin::ModuleBuildDatabase> for example).

=head2 readme_from

Which file to pull from for the Readme (must be POD format).  If not 
specified, then the main module will be used.

=head2 release_tests

If set to true, then include release tests when building.

=head2 travis_status

if set to true, then include a link to the travis build page in the readme.

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
  );
  
  $self->add_plugins($self->payload->{installer} // 'MakeMaker');
  
  $self->add_plugins(
    'Manifest',
    'TestRelease',
  );
  
  
  $self->add_plugins(qw(

    Author::Plicease::PrePodWeaver
    PodWeaver
  ));
  
  $self->add_plugins([ NextRelease => { format => '%-9v %{yyyy-MM-dd HH:mm:ss Z}d' }]);
    
  $self->add_plugins(qw(
    AutoPrereqs
    OurPkgVersion
    MetaJSON

  ));

  $self->add_bundle('Git' => {
    allow_dirty => [ qw( dist.ini Changes README.md ) ],
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
  
  $self->add_plugins([
    'ReadmeAnyFromPod' => {
            type            => 'text',
            filename        => 'README',
            location        => 'build', 
      maybe source_filename => $self->payload->{readme_from},
    },
  ]);
  
  $self->add_plugins([
    'ReadmeAnyFromPod' => ReadMePodInRoot => {
      type                  => 'markdown',
      filename              => 'README.md',
      location              => 'root',
      maybe source_filename => $self->payload->{readme_from},
    },
  ]);
  
  $self->add_plugins([
    'Author::Plicease::MarkDownCleanup' => {
      travis_status => int($self->payload->{travis_status}//0),
    },
  ]);
  
  $self->add_plugins(qw( Author::Plicease::Recommend ));
}

__PACKAGE__->meta->make_immutable;

1;
