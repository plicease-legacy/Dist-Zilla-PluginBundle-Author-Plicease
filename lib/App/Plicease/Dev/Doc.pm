package App::Plicease::Dev::Doc;

use strict;
use warnings;
use autodie;
use v5.10;

my $temp_dir;
# FIXME shouldn't be static.
BEGIN { $temp_dir = '/tmp/foo' };
use lib $temp_dir;

use Mojolicious::Lite;
use File::HomeDir;
use File::Spec;
use IO::Dir::Closure qw( opendir_read );
use Pod::Perldoc;

app->static->classes(['App::Plicease::Dev::Doc']);

use YAML ();
print YAML::Dump(app->static->classes);

# ABSTRACT: script used by plicease in Perl development.
# VERSION

sub no_perldoc
{
  # Pod::Perldoc->new->grand_search_init(["perl"])
}

sub App::Plicease::Dev::Doc::main
{
  shift; #class;
  local @ARGV = @_;
  

  # Documentation browser under "/perldoc"
  plugin 'PODRenderer';

  sub recurse
  {
    my($dir, $prefix) = @_;
    $prefix //= '';
    my @list;
    foreach my $item (grep !/^\./, opendir_read $dir)
    {
      if(-d File::Spec->catdir($dir, $item))
      {
        push @list, recurse(File::Spec->catdir($dir, $item), $prefix . $item . '::');
      }
      elsif(-e File::Spec->catfile($dir, $item))
      {
        $item =~ s/\.pm$//;
        push @list, $prefix . $item;
      }
    }
    @list;
  }

  get '/' => sub {
    my $self = shift;

    my $root = File::Spec->catdir(File::HomeDir->my_home, qw( dev ));

    my @distros = grep !/^\./, opendir_read $root;

    my @progs;

    do {
      my @bins = map {
        my $script_dir_name = $_;
        grep { -d $_ } map { File::Spec->catfile(File::Spec->catdir($root, $_, $script_dir_name)) } @distros;
      } qw( bin script scripts );
      foreach my $bin (@bins)
      {
        foreach my $script (grep !/^\./, opendir_read $bin)
        {
          my $old_file = File::Spec->catfile($bin, $script);
          my $new_file = File::Spec->catfile($temp_dir, $script . ".pod");
          unlink $new_file if -e $new_file;
          symlink $old_file, $new_file;
          push @progs, $script;
        }
      }
    };

    my @modules;

    do {
      foreach my $lib (grep { -d $_ } map { File::Spec->catfile($root, $_, 'lib') } @distros)
      {
        push @modules, recurse $lib;
      }

    };

    my %no_perldoc = map {
      my @location = Pod::Perldoc->new->grand_search_init([$_]);
      $_ => @location > 0 ? 0 : 1;
    } (@progs,@modules);

    use YAML ();
    print YAML::Dump(\%no_perldoc);

    $self->stash( progs      => [ sort @progs   ] );
    $self->stash( modules    => [ sort @modules ] );
    $self->stash( no_perldoc => \%no_perldoc      );

    $self->render('index');
  };

  app->start;
}

=head1 SEE ALSO

L<App::Plicease::Dev>

=cut

1;

