package Dist::Zilla::Plugin::Author::Plicease::TransformTravis;

use Moose;
with 'Dist::Zilla::Role::FileGatherer';
use YAML qw( Dump LoadFile );

# ABSTRACT: transform .travis.yml so that it uses Module::Build or MakeMaker for deps
# VERSION

=head1 SYNOPSIS

 [Author::Plicease::TransformTravis]

=cut

use namespace::autoclean;

sub gather_files
{
  my($self) = @_;
  
  my $source_filename = $self->zilla->root->file('.travis.yml');
  return unless -r $source_filename;
  
  my $file = Dist::Zilla::File::FromCode->new(
    name    => '.travis.yml',
    code    => sub {
      my($build) = grep { $_->name =~ /^(Makefile|Build)\.PL$/ } @{ $self->zilla->files };
      $self->log_fatal("need at least one of Makefile.PL or Build.PL")
        unless defined $build;
      $self->log("transforming .travis.yml");

      my $data = LoadFile($source_filename->stringify);
  
      if($build->name eq 'Build.PL')
      {
        $data->{install} = "perl Build.PL && ./Build installdeps";
      }
      else
      {
        $data->{install} = "perl Makefile.PL && make installdeps";
      }
      Dump($data),
    },
  );
  $self->add_file($file);
}

__PACKAGE__->meta->make_immutable;

1;
