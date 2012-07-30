package App::Plicease::Dev;

use strict;
use warnings;
use autodie;
use File::HomeDir;
use File::Spec;
use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );
use Cwd;

# ABSTRACT: scripts used by plicease in Perl development.
# VERSION

sub main
{
  shift; # class
  local @ARGV = @_;

  my $shell;

 GetOptions(
    'csh'    => sub { $shell = 'csh'           },
    'sh'     => sub { $shell = 'sh'            },
    'cmd'    => sub { $shell = 'cmd'           },
    'help|h' => sub { pod2usage(-verbose => 2) },
  ) or pod2usage(2);

  unless(defined $shell)
  {
    require System::Shell::Detect;
    $shell = System::Shell::Detect->running_shell;
  }

  my $root = shift @ARGV;
  if(defined $root)
  {
    chdir $root;
    $root = getcwd;
  }
  else
  {
    $root  = File::Spec->catdir(File::HomeDir->my_home, qw( dev ));
  }

  my @dirs;

  do {
    opendir my($dir), $root;
    @dirs = grep { -d File::Spec->catdir($root => $_) }
            grep !/^\./, readdir $dir;
    closedir $dir;
  };

  my %path = map {; $_ => 1 } split /:/, $ENV{PATH};
  my %inc  = map {; $_ => 1 } @INC;

  my @bins = map {
               my $subdir = $_;
               grep { ! $path{$_} }
               map { File::Spec->catdir($root => $_, $subdir) }
               grep { -d File::Spec->catdir($root => $_, $subdir) } @dirs;
             } qw( bin script scripts );
  my @libs = grep { ! $inc{$_} }
             map { File::Spec->catdir($root => $_, 'lib') }
             grep { -d File::Spec->catdir($root => $_, 'lib') } @dirs;

  if($^X ne '/usr/bin/perl')
  {
    mkdir File::Spec->catdir($root, 'bin')
      if !-d File::Spec->catdir($root, 'bin');
    foreach my $bin (@bins)
    {
      opendir my($dh), $bin;
      my @list = grep !/^\./, readdir $dh;
      closedir $dh;

      foreach my $exe (@list)
      {
        open my $fh, '>', File::Spec->catfile($root, 'bin', $exe);
        chmod 0755, $fh;
        print $fh "#!$^X\n";
        print $fh "use strict;use warnings;\n";
        print $fh 'exec $^X, "', File::Spec->catfile($bin, $exe), '", @ARGV;', "\n";
        close $fh;
      }
    }
    @bins = File::Spec->catdir($root, 'bin')
  }

  if($shell =~ /^csh|sh$/)
  {
    if($shell eq 'csh')
    {
      if(@bins > 0)
      {
        print "setenv PATH \"", join(':', @bins), "\"";
        print ':$PATH;' if defined $ENV{PATH};
        print "\n";
      }
      if(@libs > 0)
      {
        print "setenv PERL5LIB \"", join(':', @libs), "\"";
        print ':$PERL5LIB;' if defined $ENV{PERL5LIB};
        print "\n";
      }
    }
    elsif($shell eq 'sh')
    {
      if(@bins > 0)
      {
        print "export PATH=\"", join(':', @libs), "\"";
        print ':$PATH;' if defined $ENV{PATH};
        print "\n";
      }
      if(@libs > 0)
      {
        print "export PERL5LIB=\"", join(':', @libs), "\"";
        print ':$PERL5LIB;' if defined $ENV{PERL5LIB};
        print "\n";
      }
    }
  }
  elsif($shell eq 'cmd')
  {
    # FIXME handle spaces in paths
    # FIXME output cmd
  }
  else
  {
    die "unknown shell: $shell\n";
  }
}

1;

__END__

=head1 SEE ALSO

L<dev>, L<devdoc>, L<pmwhich>, L<proveall>, L<remove_trailing_space>

=cut
