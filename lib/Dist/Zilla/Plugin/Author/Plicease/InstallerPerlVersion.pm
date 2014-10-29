package Dist::Zilla::Plugin::Author::Plicease::InstallerPerlVersion;

use strict;
use warnings;
use Moose;

# ABSTRACT: Make Makefile.PL and Build.PL exit instead of die on Perl version mismatch
# VERSION

=head1 SYNOPSIS

 [Author::Plicease::InstallerPerlVersion]

=head1

This adds a preface to your C<Makefile.PL> or C<Build.PL> to
test the Perl version in a way that will not throw an exception,
instead calling exit, so that they will not be reported on
cpantesters as failures.  This plugin should be the last
L<Dist::Zilla::Role::InstallTool> plugin in your C<dist.ini>.

=cut

with 'Dist::Zilla::Role::InstallTool';

sub setup_installer
{
  my($self) = @_;
  
  my $prereqs = $self->zilla->prereqs->as_string_hash;
  
  my $perl_version = $prereqs->{runtime}->{requires}->{perl};
  
  $self->log("perl version required = $perl_version");
  
  foreach my $file (grep { $_->name =~ /^(Makefile\.PL|Build\.PL)$/ } @{ $self->zilla->files })
  {
    my $content = $file->content;
    $content = join "\n", 
      "BEGIN {",
      "  unless(eval q{ use $perl_version; 1}) {",
      "    print \"Perl $perl_version or better required\\n\";",
      "    exit;",
      "  }",
      "}",
      $content;
    $file->content($content);
  }
}

__PACKAGE__->meta->make_immutable;

1;
