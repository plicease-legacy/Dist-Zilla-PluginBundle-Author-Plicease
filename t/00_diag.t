use strict;
use warnings;
use Config;
use Test::More tests => 1;

# This .t file is generated.
# make changes instead to dist.ini

my %modules;
my $post_diag;

$modules{$_} = $_ for qw(
  Capture::Tiny
  Dist::Zilla
  Dist::Zilla::App
  Dist::Zilla::Plugin::AutoMetaResources
  Dist::Zilla::Plugin::CopyFilesFromBuild
  Dist::Zilla::Plugin::InsertExample
  Dist::Zilla::Plugin::InstallGuide
  Dist::Zilla::Plugin::MakeMaker
  Dist::Zilla::Plugin::MinimumPerl
  Dist::Zilla::Plugin::OurPkgVersion
  Dist::Zilla::Plugin::PodWeaver
  Dist::Zilla::Plugin::ReadmeAnyFromPod
  Dist::Zilla::Plugin::Run::BeforeBuild
  File::chdir
  IPC::System::Simple
  JSON::PP
  Module::Build
  Moose
  Path::Class
  PerlX::Maybe
  PerlX::Maybe::XS
  Pod::Markdown
  Test::Dir
  Test::File
  Test::File::ShareDir
  Test::Fixme
  Test::More
  Test::Pod
  Test::Pod::Coverage
  Test::Script
  Test::Version
  YAML
  YAML::XS
  autodie
  namespace::autoclean
);

$modules{$_} = $_ for qw(
  Dist::Zilla::Plugin::Git
  Perl::PrereqScanner
  Term::Encoding
);

my @modules = sort keys %modules;

sub spacer ()
{
  diag '';
  diag '';
  diag '';
}

pass 'okay';

my $max = 1;
$max = $_ > $max ? $_ : $max for map { length $_ } @modules;
our $format = "%-${max}s %s"; 

spacer;

my @keys = sort grep /(MOJO|PERL|\A(LC|HARNESS)_|\A(SHELL|LANG)\Z)/i, keys %ENV;

if(@keys > 0)
{
  diag "$_=$ENV{$_}" for @keys;
  
  if($ENV{PERL5LIB})
  {
    spacer;
    diag "PERL5LIB path";
    diag $_ for split $Config{path_sep}, $ENV{PERL5LIB};
    
  }
  elsif($ENV{PERLLIB})
  {
    spacer;
    diag "PERLLIB path";
    diag $_ for split $Config{path_sep}, $ENV{PERLLIB};
  }
  
  spacer;
}

diag sprintf $format, 'perl ', $];

foreach my $module (@modules)
{
  if(eval qq{ require $module; 1 })
  {
    my $ver = eval qq{ \$$module\::VERSION };
    $ver = 'undef' unless defined $ver;
    diag sprintf $format, $module, $ver;
  }
  else
  {
    diag sprintf $format, $module, '-';
  }
}

if($post_diag)
{
  spacer;
  $post_diag->();
}

spacer;

