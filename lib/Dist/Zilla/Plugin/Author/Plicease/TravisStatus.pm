package Dist::Zilla::Plugin::Author::Plicease::TravisStatus;

use strict;
use warnings;
use Moose;

# ABSTRACT: add a travis status button to the README.md file
# VERSION

=head1 SYNOPSIS

 [Author::Plicease::TravisStatus]

=cut

with 'Dist::Zilla::Role::AfterBuild';

# [![Build Status](https://secure.travis-ci.org/plicease/Yars.png)](http://travis-ci.org/plicease/Yars)

sub after_build
{
  my($self) = @_;
  my $readme = $self->zilla->root->file("README.md");
  if(-r $readme)
  {
    my $name = $self->zilla->root->absolute->basename;
    my $status = "[![Build Status](https://secure.travis-ci.org/plicease/$name.png)](http://travis-ci.org/plicease/$name)";
    my $content = $readme->slurp;
    $content =~ s{# NAME\s+(.*?) - (.*?#)}{# $1 $status\n\n$2}s;
    $readme->spew($content);
  }
  else
  {
    $self->log("no README.md found");
  }
}

1;
