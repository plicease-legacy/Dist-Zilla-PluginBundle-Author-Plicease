package Dist::Zilla::Plugin::Author::Plicease::Init2;

use Moose;
use Dist::Zilla::File::InMemory;
use Dist::Zilla::File::FromCode;
use Dist::Zilla::MintingProfile::Author::Plicease;
use JSON::PP qw( encode_json );
use Encode qw( encode_utf8 );

# ABSTRACT: Dist::Zilla initialization tasks for Plicease
# VERSION

=head1 DESCRIPTION

Create a dist in plicease style.

=cut

with 'Dist::Zilla::Role::AfterMint';
with 'Dist::Zilla::Role::ModuleMaker';
with 'Dist::Zilla::Role::FileGatherer';

use namespace::autoclean;

has abstract => (
  is      => 'ro',
  isa     => 'Str',
  lazy    => 1,
  default => sub {
    my($self) = @_;
    $self->zilla->chrome->prompt_str("abstract");
  },
);

has include_tests => (
  is      => 'ro',
  isa     => 'Int',
  lazy    => 1,
  default => sub {
    shift->zilla->chrome->prompt_yn("include release tests?");
  },
);

sub make_module
{
  my($self, $arg) = @_;
  (my $filename = $arg->{name}) =~ s{::}{/}g;
  
  my $name = $arg->{name};
  my $abstract = $self->abstract;
  
  my $file = Dist::Zilla::File::InMemory->new({
    name    => "lib/$filename.pm",
    content => join("\n", qq{package $name;} ,
                          qq{} ,
                          qq{use strict;} ,
                          qq{use warnings;} ,
                          qq{} ,
                          qq{# ABSTRACT: $abstract} ,
                          qq{# VERSION} ,
                          qq{} ,
                          qq{1;}
    ),
  });
  
  $self->add_file($file);
}

sub gather_files
{
  my($self, $arg) = @_;
  
  $self->gather_file_dist_ini($arg);
  $self->gather_file_changes($arg);
  $self->gather_files_tests($arg);
  $self->gather_file_gitignore($arg);
  $self->gather_file_travis_yml($arg);
}

sub gather_file_travis_yml
{
  my($self, $arg) = @_;

  my $file = Dist::Zilla::File::InMemory->new({
    name    => '.travis.yml',
    content => join("\n", q{language: perl},
                          q{},
                          q{# remember need at least one install command, even if there are no},
                          q{# prereqs, else travis will try to install deps using cpanm},
                          q{# which is not what we want since this is a Dist::Zilla dist.},
                          q{install:},
                          q{  - cpanm -n Dist::Zilla},
                          q{  - dzil authordeps --missing | cpanm -n},
                          q{  - cpanm -n Pod::Find Test::CPAN::Changes Test::EOL Test::Fixme Test::NoTabs Test::Pod::Spelling::CommonMistakes Test::Spelling Test::Strict Test::Version Test::Vars || true},
                          q{#  - cpanm -n Foo::Bar},
                          q{},
                          q{perl:},
                          (map { "  - \"5.$_\""} qw( 8 10 12 14 16 18 20 )),
                          q{},
                          q{#env:},
                          q{#  - FOO=bar},
                          q{},
                          q{#before_script: /bin/true},
                          q{},
                          q{script:},
                          q{  - dzil test -v},
                          q{},
                          q{#after_script: /bin/true},
                          q{},
    ),
  });

  $self->add_file($file);

}

sub gather_file_dist_ini
{
  my($self, $arg) = @_;
  
  my $zilla = $self->zilla;
  
  my $code = sub {
    my $content = '';
    
    $content .= sprintf "name             = %s\n", $zilla->name;
    $content .= sprintf "author           = Graham Ollis <plicease\@cpan.org>\n";
    $content .= sprintf "license          = Perl_5\n";
    $content .= sprintf "copyright_holder = Graham Ollis\n";
    $content .= sprintf "copyright_year   = %s\n", (localtime)[5]+1900;
    $content .= sprintf "version          = 0.01\n";
    $content .= "\n";
    
    $content .= "[\@Author::Plicease]\n"
             .  "release_tests = " . $self->include_tests ."\n"
             .  "installer     = ModuleBuild\n"
             .  "\n";
    
    $content .= "[RemovePrereqs]\n"
             .  "remove = strict\n"
             .  "remove = warnings\n"
             .  "\n";
    
    $content .= ";[Prereqs]\n"
             .  ";Foo::Bar = 0\n"
             .  "\n";
    
    $content .= "[Author::Plicease::Upload]\n"
             .  "cpan = 0\n"
             .  "\n";
             
    $content .= "[Author::Plicease::InstallerPerlVersion]\n"
             .  "\n";
             
    $content;
  };
  
  my $file = Dist::Zilla::File::FromCode->new({
    name => 'dist.ini',
    code => $code,
  });
  
  $self->add_file($file);
}

sub gather_file_changes
{
  my($self, $arg) = @_;
  
  my $file = Dist::Zilla::File::InMemory->new({
    name    => 'Changes',
    content => join("\n", q{Revision history for {{$dist->name}}},
                          q{},
                          q{{{$NEXT}}},
                          q{  - initial version},
    ),
  });
  
  $self->add_file($file);
}

sub gather_files_tests
{
  my($self, $arg) = @_;
  
  if($self->include_tests)
  {
    my $source = Dist::Zilla::MintingProfile::Author::Plicease->profile_dir->subdir(qw( default skel xt release ));
    foreach my $test ($source->children)
    {
      my $file = Dist::Zilla::File::FromCode->new({
        name => "xt/release/" . $test->basename,
        code => sub { $test->slurp(iomode => '<:encoding(UTF-8)') },
      });
      $self->add_file($file);
    }
  }
  
  my $name = $self->zilla->name;
  $name =~ s{-}{::}g;

  my $use_t_file = Dist::Zilla::File::InMemory->new({
    name => 't/use.t',
    content => join("\n", q{use strict;},
                          q{use warnings;},
                          q{use Test::More tests => 1;},
                          q{},
                          qq{use_ok '$name';},
    ),
  });
  
  $self->add_file($use_t_file);
}

sub gather_file_gitignore
{
  my($self, $arg) = @_;
  
  my $name = $self->zilla->name;
  
  my $file = Dist::Zilla::File::InMemory->new({
    name    => '.gitignore',
    content => "/$name-*\n/.build\n",
  });
  
  $self->add_file($file);
}

has github_login => (
  is      => 'ro',
  isa     => 'Str',
  lazy    => 1,
  default => sub {
    my($self) = @_;
    $self->zilla->chrome->prompt_str("github user", { default => 'plicease' });
  },
);

has github_pass => (
  is => 'ro',
  isa => 'Str',
  lazy => 1,
  default => sub {
    my($self) = @_;
    $self->zilla->chrome->prompt_str("github pass", { noecho => 1 });
  },
);

sub after_mint
{
  my($self, $opts) = @_;
  
  unless(eval q{ use Git::Wrapper; 1; })
  {
    $self->zilla->log("no Git::Wrapper, can't create repository");
    return;
  }
  
  my $git = Git::Wrapper->new($opts->{mint_root});
  $git->init;
  $git->add($opts->{mint_root});
  $git->commit({ message => "Initial commit" });
  
  unless(eval q{ use LWP::UserAgent; use HTTP::Request; 1; })
  {
    $self->zilla->log("no LWP, can't create github repo");
  }

  my $no_github = 0;

  do {
    my $ua = LWP::UserAgent->new;
    my $request = HTTP::Request->new(
      POST => "https://api.github.com/user/repos",
    );
    
    my $data = encode_json({ name => $self->zilla->name, description => $self->abstract });
    $request->content($data);
    $request->header( 'Content-Length' => length encode_utf8 $data );
    $request->authorization_basic($self->github_login, $self->github_pass);
    my $response = $ua->request($request);
    unless($response->is_success)
    {
      $self->zilla->log("could not create a github repo!");
      $no_github = 1;
    }
  };
  
  $git->remote('add', 'origin', "git\@github.com:" . $self->github_login . '/' . $self->zilla->name . '.git');
  $git->push('origin', 'master') unless $no_github;
  
  return;
}

__PACKAGE__->meta->make_immutable;

1;
