package Dist::Zilla::Plugin::Author::Plicease::UploadToMatrix;

use Moose;
use v5.10;

# ABSTRACT: Upload dist to matrix
# VERSION

with 'Dist::Zilla::Role::AfterRelease';

use namespace::autoclean;

sub after_release
{
  my($self, $archive) = @_;
  use autodie qw( :system );
  my @cmd = ('scp', '-q', $archive, 'ollisg@matrix.wdlabs.com:web/sites/dist');
  $self->zilla->log("% @cmd");
  eval { system @cmd };
  if(my $error = $@)
  {
    $self->zilla->log("NOTE SCP FAILED: $error");
    $self->zilla->log("manual upload will be required");
  }
  else
  {
    $self->zilla->log("download URL: http://dist.wdlabs.com/$archive");
  } 
}

1;
