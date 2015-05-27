use strict;
use warnings;
use Test::More tests => 1;
use File::Temp qw( tempdir );
use File::chdir;
use Dist::Zilla::App;
use Capture::Tiny qw( capture_merged );
use Test::File;
use YAML ();
use Path::Class qw( dir );
use Test::File::ShareDir
  -share => {
    -module => {
      'Dist::Zilla::MintingProfile::Author::Plicease' => dir->subdir('profiles')->stringify,
    },
  };

$Dist::Zilla::Plugin::Author::Plicease::Init2::chrome = 
$Dist::Zilla::Plugin::Author::Plicease::Init2::chrome = 'My::Chrome';

@INC = map { dir($_)->absolute->stringify } @INC;

subtest 'dzil new' => sub {
  local $CWD = tempdir( CLEANUP => 1 );

  my($out) = capture_merged {
    eval {
      local @ARGV = ('new', '-P', 'Author::Plicease', 'Foo::Bar');
      local $ENV{DIST_ZILLA_PLUGIN_AUTHOR_PLICEASE_INIT2_NO_GITHUB} = 1;
      #print "INC=$_\n" for @INC;    
      print "+ @ARGV\n";
      Dist::Zilla::App->run;    
    };
    if(my $error = $@)
    {
      print "EXCEPTION:$error\n";
    }
  };  

  note $out;  
  dir_exists_ok 'Foo-Bar';
  file_exists_ok 'Foo-Bar/dist.ini';
  file_exists_ok 'Foo-Bar/lib/Foo/Bar.pm';

};

package
  My::Chrome;

sub prompt_str
{
  my($self, $prompt) = @_;
  
  return 'My abstract' if $prompt eq 'abstract';
  return 'plicease' if $prompt eq 'github user';
  
  die "something else:\n" . YAML::Dump(@_);
}

sub prompt_yn
{
  my($self, $prompt) = @_;

  return 1 if $prompt eq 'include release tests?';
  
  die "something else:\n" . YAML::Dump(@_);
}
