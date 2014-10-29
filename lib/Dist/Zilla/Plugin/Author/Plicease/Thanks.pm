package Dist::Zilla::Plugin::Author::Plicease::Thanks;

use Moose;
with 'Dist::Zilla::Role::FileMunger';
with 'Dist::Zilla::Role::FileFinderUser' => {
  default_finders => [ ':InstallModules', ':ExecFiles' ],
};

# ABSTRACT: munge the AUTHOR section
# VERSION

=head1 SYNOPSIS

 [Author::Plicease::Thanks]
 original = Original Author
 current = Current Maintainer
 contributor = Contributor One
 contributor = Contributor Two

=cut

has original => (
  is  => 'ro',
  isa => 'Str',
);

has current => (
  is  => 'ro',
  isa => 'Str',
);

has contributor => (
  is      => 'ro',
  isa     => 'ArrayRef[Str]',
  default => sub { [] },
);

sub mvp_multivalue_args { qw( contributor ) }

sub munge_files
{
  my($self) = @_;
  $self->munge_file($_) for @{ $self->found_files };
}

sub munge_file
{
  my($self, $file) = @_;
  
  $self->log_fatal('requires at least current')
    unless $self->current;
  
  my $replacer = sub {
    my @list;
    push @list, '=head1 AUTHOR', '';
    if($self->original)
    {
      push @list, 'original author: ' . $self->original,
                  '',
                  'current maintainer: ' . $self->current,
                  '';
    }
    else
    {
      push @list, 'author: ' . $self->current,
                  '';
    }
    if(@{ $self->contributor } > 0)
    {
      push @list, 'contributors:', '', map { ($_, '') } @{ $self->contributor }; 
    }
    return join "\n", @list, '';
  };
  
  my $content = $file->content;
  unless($content =~ s{^=head1 AUTHOR.*(=head1 COPYRIGHT)}{$replacer->() . $1}sem)
  {
    $self->log_fatal('could not replace AUTHOR section');
  }
  $file->content($content);
  
  return;
}

__PACKAGE__->meta->make_immutable;

1;
