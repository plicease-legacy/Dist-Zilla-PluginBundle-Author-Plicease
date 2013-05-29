package Dist::Zilla::Plugin::Author::Plicease::UploadToCPAN;

use Moose;
use v5.10;

extends 'Dist::Zilla::Plugin::UploadToCPAN';

around release => sub {
  my $orig = shift;
  my $self = shift;
  
  eval { $self->$orig(@_) };
  if(my $error = $@)
  {
    $self->zilla->log("error uploading to cpan: $error");
    $self->zilla->log("you will have to manually upload the dist");
  }
  
  return;
};

1;
