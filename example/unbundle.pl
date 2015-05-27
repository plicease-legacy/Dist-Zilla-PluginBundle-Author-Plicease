use strict;
use warnings;
use Dist::Zilla::PluginBundle::Author::Plicease;
use Config::INI::Reader;
use Path::Class qw( file dir );

BEGIN {  @INC = map { dir($_)->absolute->stringify } @INC }

use Devel::Hide qw( Dist::Zilla::Plugin::ACPS::RPM );
use File::Temp qw( tempdir );

my $nl = 0;
my $in_config;

if($ARGV[0] eq '--default')
{
  $in_config = {};
  warn "using default";
  chdir(tempdir( CLEANUP => 1));
}
else
{
  die "run from the directory with the dist.ini file" unless -r 'dist.ini';
  $in_config = Config::INI::Reader->read_file('dist.ini')->{'@Author::Plicease'};
}

die "unable to find [\@Author::Plicease] in your dist.ini" unless defined $in_config;

my $bundle = Bundle->new;

Dist::Zilla::PluginBundle::Author::Plicease::configure($bundle);

chdir(dir("")->stringify);

package
  Bundle;

sub new { bless {} }
sub payload { $in_config }

sub add_plugins
{
  shift; # self
  foreach my $item (map { ref $_ ? [@$_] : [$_] } @_)
  {
    if(ref($item) eq 'ARRAY')
    {
      my %config = ref $item->[-1] eq 'HASH' ? %{ pop @$item } : ();
      my($moniker, $name) = @$item;
      
      print "\n" if $nl && %config;
      if(defined $name)
      {
        print "[$moniker / $name]\n";
      }
      else
      {
        print "[$moniker]\n";
      }

      while(my($k, $v) = each %config)
      {
        $v = [ $v ] unless ref $v;
        print "$k = $_\n" for @$v;
      }
      
      if(%config)
      {
        print "\n";
        $nl = 0;
      }
      else
      {
        $nl = 1;
      }

    }
    else
    {
      die "do not know how to handle " . ref $item;
    }
  }
}

