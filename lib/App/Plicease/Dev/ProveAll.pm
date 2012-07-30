package App::Plicease::Dev::ProveAll;

use strict;
use warnings;
use autodie;
use File::HomeDir;
use File::Spec;
use IO::Dir::Closure qw( opendir_read );
use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );

# ABSTRACT: script used by plicease in Perl development.
# VERSION

sub main
{
  shift; # class
  local @ARGV = @_;

  GetOptions(
    'help|h' => sub { pod2usage(-verbose => 2) },
  ) or pod2usage(2);

  my $root = File::Spec->catdir(File::HomeDir->my_home, qw( dev ) );

  my @distros = grep { -d File::Spec->catdir($_, 't') } map { File::Spec->catdir($root, $_) } grep !/^\./, opendir_read $root;

  foreach my $dir (@distros)
  {
    chdir $dir;
    if(-e 'Build.PL')
    {
      print "building $dir\n";
      system $^X, 'Build.PL';
      system './Build';
    }
    elsif(-e 'Makefile.PL')
    {
      print "building $dir\n";
      system $^X, 'Makefile.PL';
      # FIXME do this portably
      system 'make';
    }
  }

  system 'prove', '-b', map { File::Spec->catdir($_, 't') } @distros;
}

1;

=head1 SEE ALSO

L<App::Plicease::Dev>

=cut

__END__

=head1 SEE ALSO

L<App::Plicease::Dev>

=cut
