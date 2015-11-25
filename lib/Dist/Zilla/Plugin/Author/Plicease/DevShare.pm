package Dist::Zilla::Plugin::Author::Plicease::DevShare;

use Moose;
use Path::Class qw( dir );
use namespace::autoclean;

# ABSTRACT: Plugin to deal with dev/project share directory
# VERSION

with 'Dist::Zilla::Role::FileGatherer';

sub gather_files
{
  my($self) = @_;

  my $filename = $self->zilla->main_module->name;
  $filename =~ s{^(.*)/(.*?)\.pm$}{$1/.$2.devshare};
  
  my $count = $filename;
  $count =~ s/[^\/]//g;
  $count = length $count;
  my $content = ('../' x $count) . 'share';
  
  my $file = Dist::Zilla::File::InMemory->new({
    name    => $filename,
    content => $content,
  });
  
  $self->add_file($file);
  
  dir->file($filename)->spew($content);
}

__PACKAGE__->meta->make_immutable;

1;
