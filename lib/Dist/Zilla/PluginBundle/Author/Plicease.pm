package Dist::Zilla::PluginBundle::Author::Plicease;

use 5.008001;
use Moose;
use Dist::Zilla;
use PerlX::Maybe qw( maybe );
use Path::Class::File;
use YAML ();
use Term::ANSIColor ();
use Path::Class qw( file dir );

# ABSTRACT: Dist::Zilla plugin bundle used by Plicease
# VERSION

=head1 SYNOPSIS

In your dist.ini:

 [@Author::Plicease]

=head1 DESCRIPTION

This is a L<Dist::Zilla> plugin bundle is a set of my personal preferences.
You are probably reading this documentation not out of choice, but because
you have to.  Sorry.

=over 4

=item Taking over one of my modules?

This dist comes with a script in C<example/unbundle.pl>, which will extract
the C<@Author::Plicease> portion of the dist.ini configuration so that you
can edit it and make your own.  I strongly encourage you to do this, as it
will help you remove the preferences from the essential items.

=item Want to submit a patch for one of my modules?

Consider using C<prove -l> on the test suite or adding the lib directory
to C<PERL5LIB>.  Save yourself the hassle of dealing with L<Dist::Zilla>
at all.  If there is something wrong with one of the generated files
(such as C<Makefile.PL> or C<Build.PL>) consider opening a support ticket
instead.  Most other activities that you relating to the use of L<Dist::Zilla>
have to do with release testing and uploading to CPAN which is more
my responsibility than yours.

=item Really need to fix some aspect of the build process?

Or perhaps the module in question is using XS (hint: convert it to FFI
instead!).  If you really do need to fix some aspect of the build process
then you probably do need to install L<Dist::Zilla> and this bundle.
If you are having trouble figuring out how it works, then try extracting
the bundle using the C<example/unbundle.pl> script mentioned above.

=back

I've only uploaded this to CPAN to assist others who may be working on
one of my dists.  I don't expect anyone to use it for their own projects.

This plugin bundle is mostly equivalent to

# EXAMPLE: example/default_dist.ini

Some exceptions:

=over 4

=item Perl 5.8.x, Perl 5.10.0

C<Dist::Zilla::Plugin::Git::*> does not support Perl 5.8.x or 5.10.0, so it
is not a prereq there, and it isn't included in the bundle.  As a result
releasing from Perl 5.8 is not allowed.

=item MSWin32

Installing L<Dist::Zilla::Plugin::Git::*> on MSWin32 is a pain
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

=head2 appveyor

if set to a appveyor id, then include a link to the appveyor build page in the readme.

=head2 mb_class

if builder = ModuleBuild, this is the mb_class passed into the [ModuleBuild]
plugin.

=head2 github_repo

Set the GitHub repo name to something other than the dist name.

=head2 github_user

Set the GitHub user name.

=head2 copy_mb

Copy Build.PL and cpanfile from the build into the git repository.
Exclude them from gather.

This allows other developers to use the dist from the git checkout, without needing
to install L<Dist::Zilla> and L<Dist::Zilla::PluginBundle::Author::Plicease>.

=head2 allow_dirty

Additional dirty allowed file passed to @Git.

=head2 irc

IRC discussion URL for x_IRC meta (maybe changed to non x_ meta if/when IRC
becomes formally supported).

=head2 version_plugin

Specify an alternative to OurPkgVersion for updating the versions in .pm files.

=head2 perl

Specify a minimum Perl version.  If not specified it will be detected.

=cut

with 'Dist::Zilla::Role::PluginBundle::Easy';

sub mvp_multivalue_args { qw( 
  alien_build_command
  alien_install_command
  alien_auto_include
  alien_bin_requires
  alien_helper
  upgrade
  preamble
  diag_preamble
  
  diag
  allow_dirty ) }

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
    ['GatherDir' => { exclude_filename => [qw( Makefile.PL Build.PL cpanfile )],
                      exclude_match => '^_build/' }, ],
    [ PruneCruft => { except => '.travis.yml' } ],
    'ManifestSkip',
    'MetaYAML',
    'License',
    'ExecDir',
    'ShareDir',
  );

  do { # installer stuff
    my $installer = $self->payload->{installer};
    my %mb = map { $_ => $self->payload->{$_} } grep /^mb_/, keys %{ $self->payload };
    if(-e Path::Class::File->new('inc', 'My', 'ModuleBuild.pm'))
    {
      $installer ||= 'ModuleBuild';
      $mb{mb_class} = 'My::ModuleBuild'
        unless defined $mb{mb_class};
    }
    if(defined $installer && $installer eq 'Alien')
    {
      my %args = 
        map { $_ => $self->payload->{"alien_$_"} }
        map { s/^alien_//; $_ } 
        grep /^alien_/, keys %{ $self->payload };
      $self->add_plugins([ Alien => { %args, %mb } ]);
    }
    elsif(defined $installer && $installer eq 'ModuleBuild')
    {
      $self->add_plugins([ ModuleBuild => \%mb ]);
    }
    else
    {
      $installer ||= 'Author::Plicease::MakeMaker';
      $self->add_plugins($installer);
    }
  };
  
  $self->add_plugins(qw(
    Manifest
    TestRelease
    PodWeaver
  ));
  
  $self->add_plugins([ NextRelease => { format => '%-9v %{yyyy-MM-dd HH:mm:ss Z}d' }]);
    
  $self->add_plugins('AutoPrereqs');
  $self->add_plugins($self->payload->{version_plugin} || 'OurPkgVersion');
  $self->add_plugins('MetaJSON');

  if($] >= 5.010001 && $^O ne 'MSWin32')
  {
    my $dirty = { allow_dirty => [ qw( dist.ini Changes README.md ), @{ $self->payload->{allow_dirty} || [] } ] };
    
    $self->add_plugins(
      [ 'Git::Check',  $dirty ],
      [ 'Git::Commit', $dirty ],
      [ 'Git::Tag'            ],
      [ 'Git::Push'           ],
    );
  }

  do {
    my $name = dir->absolute->basename;
    my $user = $self->payload->{github_user} || 'plicease';
    my $repo = $self->payload->{github_repo} || $name;
  
    $self->add_plugins([
      'MetaResources' => {
        'homepage' => $self->payload->{homepage} || "http://perl.wdlabs.com/$name",
        'bugtracker.web'  => sprintf("https://github.com/%s/%s/issues", $user, $repo),
        'repository.url'  => sprintf("git://github.com/%s/%s.git",      $user, $repo),
        'repository.web'  => sprintf("https://github.com/%s/%s",        $user, $repo),
        'repository.type' => 'git',
        maybe 'x_IRC' => $self->payload->{irc},
      },
    ]);
  };

  if($self->payload->{release_tests})
  {
    $self->add_plugins([
      'Author::Plicease::Tests' => {
        maybe skip          => $self->payload->{release_tests_skip},
        maybe diag          => $self->payload->{diag},
        maybe diag_preamble => $self->payload->{diag_preamble},
      }
    ]);
  }
    
  $self->add_plugins(qw(

    InstallGuide
    ConfirmRelease

  ));
  
  $self->add_plugins([
    MinimumPerl => {
      maybe perl => $self->payload->{perl},
    },
  ]);

  unless($self->payload->{no_readme})
  {
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
  }
  
  $self->add_plugins([
    'Author::Plicease::MarkDownCleanup' => {
            travis_status => int(defined $self->payload->{travis_status} ? $self->payload->{travis_status} : 0),
      maybe appveyor      => $self->payload->{appveyor},
      maybe travis_user   => $self->payload->{github_user},
    },
  ]);

  $self->add_plugins([
    'Author::Plicease::SpecialPrereqs' => {
      maybe upgrade  => $self->payload->{upgrade},
      maybe preamble => $self->payload->{preamble},
    },
  ]);

  $self->add_plugins(
    'CPANFile',
  );

  if($self->payload->{copy_mb})
  {
    $self->add_plugins([
      'CopyFilesFromBuild' => {
        copy => [ 'Build.PL', 'cpanfile' ],
      },
    ]);
  }
  
  if(eval { require Dist::Zilla::Plugin::ACPS::RPM })
  { $self->add_plugins(qw( ACPS::RPM )) }
  
  if($^O eq 'MSWin32')
  {
    $self->add_plugins([
      'Run::AfterBuild' => {
        run => 'dos2unix README.md t/00_diag.*',
      },
    ]);
  }
  
  if(-e ".travis.yml")
  {
    my $travis = YAML::LoadFile(".travis.yml");
    
    if(exists $travis->{perl} && grep /^5\.19$/, @{ $travis->{perl} })
    {
      die "travis is trying to test Perl 5.19";
    }
    
    unless(exists $travis->{perl} && grep /^5\.22$/, @{ $travis->{perl} })
    {
      print STDERR Term::ANSIColor::color('bold red') if -t STDERR;
      print STDERR "travis is not testing Perl 5.22";
      print STDERR Term::ANSIColor::color('reset') if -t STDERR;
      print STDERR "\n";
    }
    
    unless(exists $travis->{sudo})
    {
      print STDERR Term::ANSIColor::color('bold red') if -t STDERR;
      print STDERR "You have not specified a value for sudo in travis (suggest setting to false for faster travis build)";
      print STDERR Term::ANSIColor::color('reset') if -t STDERR;
      print STDERR "\n";
    }
  }

  foreach my $name (qw( t/00_diag.txt t/00_diag.pre.txt xt/release/build_environment.t xt/release/unused.t ))
  {  
    if(-e $name)
    {
      print STDERR Term::ANSIColor::color('bold red') if -t STDERR;
      print STDERR "You have a lingering deprecated test: $name";
      print STDERR Term::ANSIColor::color('reset') if -t STDERR;
      print STDERR "\n";
    }
  }
}

__PACKAGE__->meta->make_immutable;

1;

=head1 SEE ALSO

=over 4

=item L<Dist::Zilla>

=item L<Dist::Zilla::Plugin::Author::Plicease::MarkDownCleanup>

=item L<Dist::Zilla::Plugin::Author::Plicease::SpecialPrereqs>

=item L<Dist::Zilla::Plugin::Author::Plicease::Tests>

=item L<Dist::Zilla::Plugin::Author::Plicease::Thanks>

=item L<Dist::Zilla::Plugin::Author::Plicease::Upload>

=back

=cut
