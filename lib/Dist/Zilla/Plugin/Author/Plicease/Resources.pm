package Dist::Zilla::Plugin::Author::Plicease::Resources;

use Moose;
with 'Dist::Zilla::Role::MetaProvider';

# ABSTRACT: Set distribution meta resources
# VERSION

=head1 SYNOPSIS

 [Author::Plicease::Resources]
 ; with the default values specified for
 ; dist Foo-Bar
 github_user = plicease
 github_repo = Foo-Bar
 homepage    = http://perl.wdlabs.com/Boo-Bar

=head1 DESCRIPTION

Set the repository and bugtracker to use GitHub, and set the home page for the
appropriate L<http://perl.wdlabs.com> link.

=cut

has github_user => (
  is      => 'ro',
  isa     => 'Str',
  default => "plicease",
);

has github_repo => (
  is      => 'ro',
  isa     => 'Str',
  lazy    => 1,
  default => sub { shift->zilla->name },
);

has homepage => (
  is      => 'ro',
  isa     => 'Str',
  lazy    => 1,
  default => sub { "http://perl.wdlabs.com/" . shift->zilla->name },
);

sub metadata
{
  my($self) = @_;
  return {
    resources => {
      bugtracker => {
        web => sprintf("https://github.com/%s/%s/issues", $self->github_user, $self->github_repo),
      },
      homepage => $self->homepage,
      repository => {
        type => 'git',
        url  => sprintf("git://github.com/%s/%s.git", $self->github_user, $self->github_repo),
        web  => sprintf("https://github.com/%s/%s",   $self->github_user, $self->github_repo),
      },
    }
  };
}

__PACKAGE__->meta->make_immutable;

1;
