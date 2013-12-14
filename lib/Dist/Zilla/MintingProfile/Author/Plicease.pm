package Dist::Zilla::MintingProfile::Author::Plicease;

use Moose;

# ABSTRACT: Minting profile for Plicease
# VERSION

=head1 SYNOPSIS

 dzil new -P Author::Plicease Module::Name

=head1 DESCRIPTION

This is the normal minting profile used by Plicease.

=cut

with qw( Dist::Zilla::Role::MintingProfile::ShareDir );

no Moose;
__PACKAGE__->meta->make_immutable;

1;

