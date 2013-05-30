package Dist::Zilla::Plugin::Author::Plicease::Init;

use Moose;
use v5.10;

# ABSTRACT: Dist::Zilla initialization tasks for Plicease
# VERSION

=head1 SYNOPSIS

in your profile.ini:

 [Author::Plicease::Init]

=head1 DESCRIPTION

This will:

=over 4

=item *

git push origin master

=back

=cut

with 'Dist::Zilla::Role::AfterMint';

use namespace::autoclean;

sub after_mint
{
  my($self, $opts) = @_;
  my $git = Git::Wrapper->new($opts->{mint_root});
  $git->push('origin', 'master');
}

__PACKAGE__->meta->make_immutable;

1;

