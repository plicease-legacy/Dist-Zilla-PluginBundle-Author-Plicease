package Dist::Zilla::Plugin::Author::Plicease::MakeMaker;

use Moose;
use namespace::autoclean;

# ABSTRACT: munge the AUTHOR section
# VERSION

=head1 SYNOPSIS

 [Author::Plicease::MakeMaker]

=head1 DESCRIPTION

My personal customization of the L<Dist::Zilla::Plugin::MakeMaker>.  You are unlikely to
need or want to use this.

=head1 SEE ALSO

L<Dist::Zilla::PluginBundle::Author::Plicease>

=cut

extends 'Dist::Zilla::Plugin::MakeMaker';

around write_makefile_args => sub {
  my $orig = shift;
  my $self = shift;
  
  my $h = $self->$orig(@_);  

  # to prevent any non .pm files from being installed in lib
  # because shit like this is stuff we ought to have to customize.
  my %PM = map {; "lib/$_" => "\$(INST_LIB)/$_" } map { s/^lib\///; $_ } grep /^lib\/.*\.pm$/, map { $_->name } @{ $self->zilla->files };
  $h->{PM} = \%PM;

  $h;
};

__PACKAGE__->meta->make_immutable;

1;
