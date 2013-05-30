package Dist::Zilla::Plugin::Author::Plicease::Tests;

use strict;
use warnings;
use Moose;
use File::chdir;
use File::Path qw( make_path );
use Dist::Zilla::MintingProfile::Author::Plicease;

# ABSTRACT: add author only release tests to xt/release
# VERSION

=head1 SYNOPSIS

 [Author::Plicease::Tests]
 source = foo/bar/baz ; source of tests
 skip = pod_.*

=cut

with 'Dist::Zilla::Role::BeforeBuild';
with 'Dist::Zilla::Role::TestRunner';

has source => (
  is      =>'ro',
  isa     => 'Str',
);

has skip => (
  is      => 'ro',
  isa     => 'Str',
  default => '',
);

sub before_build
{
  my($self) = @_;
  
  my $skip = eval 'qr{^' . $self->skip . '$}';
  
  unless(-d $self->zilla->root->subdir(qw( xt release )))
  {
    $self->log("creating " . $self->zilla->root->subdir(qw( xt release )));
    make_path($self->zilla->root->subdir(qw( xt release ))->stringify);
  }
  
  my $source = defined $self->source
  ? $self->zilla->root->subdir($self->source)
  : Dist::Zilla::MintingProfile::Author::Plicease->profile_dir->subdir(qw( default skel xt release ));

  foreach my $t_file (grep { $_->basename =~ /\.t$/ } $source->children(no_hidden => 1))
  {
    next if $t_file->basename =~ $skip;
    my $new  = $t_file->slurp;
    my $file = $self->zilla->root->file(qw( xt release ), $t_file->basename);
    if(-e $file)
    {
      my $old  = $file->slurp;
      if($new ne $old)
      {
        $self->log("replacing " . $file->stringify);
        $file->openw->print($t_file->slurp);
      }
    }
    else
    {
      $self->log("creating " . $file->stringify); 
      $file->openw->print($t_file->slurp);
    }
  }
  
  my $t_config = $self->zilla->root->file(qw( xt release release.yml ));
  unless(-e $t_config)
  {
    $self->log("creating " . $t_config->stringify);
    $t_config->openw->print(<<EOF);
---
pod_spelling_system:
  # list of words that are spelled correctly
  # (regardless of what spell check thinks)
  stopwords: []

pod_coverage:
  # format is "Class#method" or "Class", regex allowed
  # for either Class or method.
  private: []
EOF
  }
}

sub test
{
  my($self, $target) = @_;
  system 'prove', '-br', 'xt';
  $self->log_fatal('release test failure') unless $? == 0;
}

1;
