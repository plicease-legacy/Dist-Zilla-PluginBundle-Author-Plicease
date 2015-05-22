package Dist::Zilla::MintingProfile::Author::Plicease;

use Moose;
use Path::Class qw( file dir );

# ABSTRACT: Minting profile for Plicease
# VERSION

=head1 SYNOPSIS

 dzil new -P Author::Plicease Module::Name

=head1 DESCRIPTION

This is the normal minting profile used by Plicease.

=cut

with qw( Dist::Zilla::Role::MintingProfile );

sub profile_dir
{
  my($self, $name) = @_;

  unless(defined $Dist::Zilla::MintingProfile::Author::Plicease::VERSION)
  {
    my $dir = eval { dir( File::ShareDir::module_dir( $self->meta->name ) )->subdir( $name ) };
    return $dir if defined $dir && -d $dir;
  }
  
  my $dir = file( __FILE__ )
    ->parent->parent->parent->parent->parent->parent->subdir('profiles')->subdir($name);
  return $dir if defined $dir && -d $dir;
  
  confess "Can't find profile $name via $self ($dir)";
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

