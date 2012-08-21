package Dist::Zilla::Plugin::Author::Plicease::Tests;

use strict;
use warnings;
use Moose;
use File::Path qw( make_path );
use Dist::Zilla::MintingProfile::Plicease;

# ABSTRACT: add author only relese tests to xt/release
# VERSION

=head1 SYNOPSIS

 [Author::Plicease::Tests]
 source = foo/bar/baz ; source of tests
 skip = pod_.*

=cut

with 'Dist::Zilla::Role::BeforeBuild';

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
  : Dist::Zilla::MintingProfile::Plicease->profile_dir->subdir(qw( default skel xt release ));

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
}

1;
