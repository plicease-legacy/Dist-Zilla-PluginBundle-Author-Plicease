package App::Plicease::Dev::RemoveTrailingSpace;

use strict;
use warnings;
use autodie;
use v5.10;
use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );
use Fcntl qw( :flock );
use File::Spec;
use IO::Dir::Closure qw( opendir_read );

# ABSTRACT: script used by plicease in Perl development.
# VERSION

sub main
{
  shift; # class;
  local @ARGV = @_;
  
  GetOptions(
    'help|h' => sub { pod2usage(-verbose => 2) },
  ) or pod2usage(2);

  sub recurse
  {
    my(@dir) = @_;
    my $dir = File::Spec->catdir(@dir);
    my @list;
    foreach my $filename (grep !/^\./, opendir_read $dir)
    {
      if(-d File::Spec->catdir($dir, $filename))
      {
        push @list, recurse(@dir, $filename);
      }
      elsif($filename =~ /\.(pm|pod|pl|t|PL)$/)
      {
        push @list, File::Spec->catfile($dir, $filename);
      }
    }
    @list;
  }

  foreach my $filename (@ARGV)
  {
    if(-d $filename)
    {
      unless(-d File::Spec->catdir($filename, 'bin')
      ||     -d File::Spec->catdir($filename, 'script')
      ||     -d File::Spec->catdir($filename, 'scripts')
      ||     -d File::Spec->catdir($filename, 'lib')
      ||     -d File::Spec->catdir($filename, 't'))
      {
        say STDERR "$filename does not appear to be a distro directory";
        exit 2;
      }

      foreach my $type (qw( bin script scripts ))
      {
        my $dir = File::Spec->catdir($filename, $type);
        next unless -d $dir;
        system $^X, __FILE__, map { File::Spec->catfile($dir, $_) } grep !/^\./, opendir_read $dir;
      }

      system $^X, __FILE__, recurse($filename);
    }
    elsif(-w $filename)
    {
      print "$filename\n";

      my $buffer = '';

      open my $fh, '+<', $filename;
      flock $fh, LOCK_EX;
      while(<$fh>)
      {
        chomp;
        s/\s+$//;
        $buffer .= $_ . "\n";
      }

      seek $fh, 0, 0;
      truncate $fh, 0;
      print $fh $buffer;

      close $fh;
    }
    elsif(-r $filename)
    {
      say STDERR "$filename is not writable";
      exit 2;
    }
    elsif(-e $filename)
    {
      say STDERR "$filename is not readable";
      exit 2;
    }
    else
    {
      say STDERR "$filename does not exist";
      exit 2;
    }
  }
}

1;

__END__

=head1 SEE ALSO

L<App::Plicease::Dev>

=cut
