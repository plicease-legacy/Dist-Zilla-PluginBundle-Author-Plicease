package Dist::Zilla::MintingProfile::Plicease;

use Moose;
use v5.10;

# ABSTRACT: Minting profile for Plicease
# VERSION

=head1 SYNOPSIS

 dzil new -P Plicease

=head1 DESCRIPTION

This is the normal minting profile used by Plicease.

=cut

with qw( Dist::Zilla::Role::MintingProfile::ShareDir );

no Moose;
__PACKAGE__->meta->make_immutable;

1;

