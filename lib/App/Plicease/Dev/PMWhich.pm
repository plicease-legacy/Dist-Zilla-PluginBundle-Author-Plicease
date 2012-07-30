package App::Plicease::Dev::PMWhich;

use strict;
use warnings;
use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );

# ABSTRACT: script used by plicease in Perl development.
# VERSION

sub main
{
  shift; #class
  local @ARGV = @_;

  GetOptions(
    'help|h' => sub { pod2usage(-verbose => 2) },
  ) or pod2usage(2);

  my $module = shift;
  unless(defined $module)
  {
    pod2usage(2);
  }

  while(defined $module)
  {

    eval qq{ use $module };
    die $@ if $@;

    my $pm = $module;
    $pm =~ s{::}{/}g;
    $pm .= '.pm';

    my $version = eval qq{ \$${module}::VERSION };

    print "---\n";
    print "Module:  $module\n";
    print "File:    $INC{$pm}\n";
    print "VERSION: $version\n" if defined $version;

    $module = shift;
  }
}

1;

__END__

=head1 SEE ALSO

L<App::Plicease::Dev>

=cut


