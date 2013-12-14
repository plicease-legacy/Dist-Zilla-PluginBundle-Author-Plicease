package Dist::Zilla::Plugin::Author::Plicease::Upload;

use Moose;

# ABSTRACT: Upload dist to CPAN
# VERSION

extends 'Dist::Zilla::Plugin::UploadToCPAN';

has cpan => (
  is      => 'ro',
  default => sub { 1 },
);

around release => sub {
  my $orig = shift;
  my $self = shift;
  
  if($self->cpan && $self->zilla->chrome->prompt_yn("upload to CPAN?"))
  {
    eval { $self->$orig(@_) };
    if(my $error = $@)
    {
      $self->zilla->log("error uploading to cpan: $error");
      $self->zilla->log("you will have to manually upload the dist");
    }
  }
  else
  {
    my($archive) = @_;
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
  
  return;
};

1;
