package Dist::Zilla::PluginBundle::Author::Plicease;

use Moose;
use Dist::Zilla;
use PerlX::Maybe qw( maybe );
use Path::Class::File;

# ABSTRACT: Dist::Zilla plugin bundle used by Plicease
# VERSION

=head1 SYNOPSIS

In your dist.ini:

 [@Author::Plicease]

=head1 DESCRIPTION

This Dist::Zilla plugin bundle is mostly equivalent to

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

Some exceptions:

=over 4

=item Perl 5.8

L<[@Git]|Dist::Zilla::PluginBundle::Git> does not support Perl 5.8, so it
is not a prereq there, and it isn't included in the bundle.  As a result
releasing from Perl 5.8 is not allowed.

=item MSWin32

Installing L<[@Git]|Dist::Zilla::PluginBundle::Git> on MSWin32 is a pain
so it is also not a prereq on that platform, isn't used and as a result
releasing from MSWin32 is not allowed.

=back

=head1 OPTIONS

=head2 installer

Specify an alternative to L<[MakeMaker]|Dist::Zilla::Plugin::MakeMaker>
(L<[ModuleBuild]|Dist::Zilla::Plugin::ModuleBuild>,
L<[ModuleBuildTiny]|Dist::Zilla::Plugin::ModuleBuildTiny>, or
L<[ModuleBuildDatabase]|Dist::Zilla::Plugin::ModuleBuildDatabase> for example).

If installer is L<Alien|Dist::Zilla::Plugin::Alien>, then any options 
with the alien_ prefix will be passed to L<Alien|Dist::Zilla::Plugin::Alien>
(minus the alien_ prefix).

If installer is L<ModuleBuild|Dist::Zilla::Plugin::ModuleBuild>, then any
options with the mb_ prefix will be passed to L<ModuleBuild|Dist::Zilla::Plugin::ModuleBuild>
(including the mb_ prefix).

If you have a C<inc/My/ModuleBuild.pm> file in your dist, then this plugin bundle
will assume C<installer> is C<ModuleBuild> and C<mb_class> = C<My::ModuleBuild>.

=head2 readme_from

Which file to pull from for the Readme (must be POD format).  If not 
specified, then the main module will be used.

=head2 release_tests

If set to true, then include release tests when building.

=head2 release_tests_skip

Passed into the L<Author::Plicease::Tests|Dist::Zilla::Plugin::Author::Plicease::Tests>
if C<release_tests> is true.

=head2 travis_status

if set to true, then include a link to the travis build page in the readme.

=head2 mb_class

if builder = ModuleBuild, this is the mb_class passed into the [ModuleBuild]
plugin.

=head1 SEE ALSO

L<Author::Plicease::Init|Dist::Zilla::Plugin::Author::Plicease::Init>,
L<MintingProfile::Plicease|Dist::Zilla::MintingProfile::Author::Plicease>

=cut

with 'Dist::Zilla::Role::PluginBundle::Easy';

use namespace::autoclean;

sub mvp_multivalue_args { qw( alien_build_command alien_install_command diag ) }

sub configure
{
  my($self) = @_;

  # undocumented for a reason: sometimes I need to release on
  # a different platform that where I do testing, (eg. MSWin32
  # only modules, where Dist::Zilla is frequently not working
  # right).
  if($self->payload->{non_native_release})
  {
    eval q{
      no warnings 'redefine';
      use Dist::Zilla::Role::BuildPL;
      sub Dist::Zilla::Role::BuildPL::build {};
      sub Dist::Zilla::Role::BuildPL::test {};
    };
  }

  $self->add_plugins(['Run::AfterBuild'         => { run => "%x inc/run/after_build.pl      --name %n --version %v --dir %d" }])
    if -r "inc/run/after_build.pl";

  $self->add_plugins(['Run::AfterRelease'       => { run => "%x inc/run/after_release.pl    --name %n --version %v --dir %d --archive %a" }])
    if -r "inc/run/after_release.pl";

  $self->add_plugins(['Run::BeforeBuild'        => { run => "%x inc/run/before_build.pl     --name %n --version %v" }])
    if -r "inc/run/before_build.pl";

  $self->add_plugins(['Run::BeforeRelease'      => { run => "%x inc/run/before_release.pl   ---name %n --version %v --dir %d --archive %a" }])
    if -r "inc/run/before_release.pl";

  $self->add_plugins(['Run::Release'            => { run => "%x inc/run/release.pl          ---name %n --version %v --dir %d --archive %a" }])
    if -r "inc/run/release.pl";

  $self->add_plugins(['Run::Test'               => { run => "%x inc/run/test.pl             ---name %n --version %v --dir %d" }])
    if -r "inc/run/test.pl";

  $self->add_plugins(
    'Author::Plicease::FiveEight',
    'GatherDir',
    [ PruneCruft => { except => '.travis.yml' } ],
    'ManifestSkip',
    'MetaYAML',
    'License',
    'ExecDir',
    'ShareDir',
  );

  do { # installer stuff
    my $installer = $self->payload->{installer} || 'MakeMaker';
    my %mb = map { $_ => $self->payload->{$_} } grep /^mb_/, keys %{ $self->payload };
    if(-e Path::Class::File->new('inc', 'My', 'ModuleBuild.pm'))
    {
      $installer = 'ModuleBuild';
      $mb{mb_class} = 'My::ModuleBuild'
        unless defined $mb{mb_class};
    }
    if($installer eq 'Alien')
    {
      my %args = 
        map { $_ => $self->payload->{"alien_$_"} }
        map { s/^alien_//; $_ } 
        grep /^alien_/, keys %{ $self->payload };
      $self->add_plugins([ Alien => \%args ]);
    }
    elsif($installer eq 'ModuleBuild')
    {
      $self->add_plugins([ ModuleBuild => \%mb ]);
    }
    else
    {
      $self->add_plugins($installer);
    }
  };
  
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

  if($] >= 5.010000 && $^O ne 'MSWin32')
  {
    $self->add_bundle('Git' => {
      allow_dirty => [ qw( dist.ini Changes README.md ) ],
    });
  }

  $self->add_plugins([
    AutoMetaResources => {
      'bugtracker.github' => 'user:plicease',
      'repository.github' => 'user:plicease',
      homepage            => 'http://perl.wdlabs.com/%{dist}/',
    }
  ]);

  if($self->payload->{release_tests})
  {
    $self->add_plugins([
      'Author::Plicease::Tests' => {
        maybe skip => $self->payload->{release_tests_skip},
        maybe diag => $self->payload->{diag},
      }
    ]);
  }
    
  $self->add_plugins(qw(

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
      travis_status => int(defined $self->payload->{travis_status} ? $self->payload->{travis_status} : 0),
    },
  ]);
  
  $self->add_plugins(qw( Author::Plicease::Recommend ));
}

__PACKAGE__->meta->make_immutable;

1;
