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
 diag = +Acme::Override::INET
 diag = +IO::Socket::INET
 diag = +IO::SOCKET::IP
 diag = -EV

=cut

with 'Dist::Zilla::Role::BeforeBuild';
with 'Dist::Zilla::Role::InstallTool';
with 'Dist::Zilla::Role::TestRunner';

sub mvp_multivalue_args { qw( diag ) }

has source => (
  is      =>'ro',
  isa     => 'Str',
);

has skip => (
  is      => 'ro',
  isa     => 'Str',
  default => '',
);

has diag => (
  is      => 'ro',
  default => sub { [] },
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
  skip: 0
  # list of words that are spelled correctly
  # (regardless of what spell check thinks)
  stopwords: []

pod_coverage:
  skip: 0
  # format is "Class#method" or "Class", regex allowed
  # for either Class or method.
  private: []

EOF
  }

  my $diag = $self->zilla->root->file(qw( t 00_diag.t ));
  $diag->spew(scalar $source->parent->parent->file('t', '00_diag.t')->absolute->slurp);
}

# not really an installer, but we have to create a list
# of the prereqs / suggested modules after the prereqs
# have been calculated
sub setup_installer
{
  my($self) = @_;
  
  my %list;
  my $prereqs = $self->zilla->prereqs->as_string_hash;
  foreach my $phase (keys %$prereqs)
  {
    next if $phase eq 'develop';
    foreach my $type (keys %{ $prereqs->{$phase} })
    {
      foreach my $module (keys %{ $prereqs->{$phase}->{$type} })
      {
        next if $module =~ /^(perl|strict|warnings|base)$/;
        $list{$module}++;
      }
    }
  }
  
  foreach my $lib (@{ $self->diag })
  {
    if($lib =~ /^-(.*)$/)
    {
      delete $list{$1};
    }
    elsif($lib =~ /^\+(.*)$/)
    {
      $list{$1}++;
    }
    else
    {
      $self->log_fatal('diagnostic override must be prefixed with + or -');
    }
  }
  
  my $content = join "\n", sort keys %list;
  $content .= "\n";
  
  $self->zilla->root->file('t', '00_diag.txt')->spew($content);
  
  my($file) = grep { $_->name eq 't/00_diag.txt' } @{ $self->zilla->files };
  if($file)
  {
    $file->content($content);
  }
  else
  {
    $file = Dist::Zilla::File::InMemory->new({
      name    => 't/00_diag.txt',
      content => $content,
    });
    $self->add_file($file);
  }
  
  if($list{EV})
  {
    $self->zilla->root->file('t', '00_diag.pre.txt')->spew("EV\n");
    my($file) = grep { $_->name eq 't/00_diag.pre.txt' } @{ $self->zilla->files };
    if($file)
    {
      $file->content("EV\n");
    }
    else
    {
      $file = Dist::Zilla::File::InMemory->new({
        name    => '00_diag.pre.txt',
        content => "EV\n",
      });
      $self->add_file($file);
    }
  }
}

sub test
{
  my($self, $target) = @_;
  system 'prove', '-br', 'xt';
  $self->log_fatal('release test failure') unless $? == 0;
}

__PACKAGE__->meta->make_immutable;

1;

=head1 SEE ALSO

=over 4

=item L<Dist::Zilla>

=item L<Dist::Zilla::PluginBundle::Author::Plicease>

=back
