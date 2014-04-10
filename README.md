# Dist::Zilla::PluginBundle::Author::Plicease [![Build Status](https://secure.travis-ci.org/plicease/Dist-Zilla-PluginBundle-Author-Plicease.png)](http://travis-ci.org/plicease/Dist-Zilla-PluginBundle-Author-Plicease)

Dist::Zilla plugin bundle used by Plicease

# SYNOPSIS

In your dist.ini:

    [@Author::Plicease]

# DESCRIPTION

This Dist::Zilla plugin bundle is mostly equivalent to

    # Basic - UploadToCPAN, Readme, ExtraTests, and ConfirmRelease
    [GatherDir]
    [PruneCruft]
    except = .travis.yml
    [ManifestSkip]
    [MetaYAML]
    [License]
    [ExecDir]
    [ShareDir]
    [MakeMaker]
    [Manifest]
    [TestRelease]
    
    [Author::Plicease::PrePodWeaver]
    [PodWeaver]
    [NextRelease]
    format = %-9v %{yyyy-MM-dd HH:mm:ss Z}d
    [AutoPrereqs]
    [OurPkgVersion]
    [MetaJSON]
    
    [@Git]
    allow_dirty = dist.ini
    allow_dirty = Changes
    allow_dirty = README.md
    
    [AutoMetaResources]
    bugtracker.github = user:plicease
    repository.github = user:plicease
    homepage = http://perl.wdlabs.com/%{dist}/
    
    [InstallGuide]
    [MinimumPerl]
    [ConfirmRelease] 
    
    [ReadmeAnyFromPod]
    type     = text
    filename = README
    location = build
    
    [ReadmeAnyFromPod / ReadMePodInRoot]
    type     = markdown
    filename = README.md
    location = root
    
    [Author::Plicease::MarkDownCleanup]
    [Author::Plicease::Recommend]

Some exceptions:

- Perl 5.8

    [\[@Git\]](https://metacpan.org/pod/Dist::Zilla::PluginBundle::Git) does not support Perl 5.8, so it
    is not a prereq there, and it isn't included in the bundle.  As a result
    releasing from Perl 5.8 is not allowed.

- MSWin32

    Installing [\[@Git\]](https://metacpan.org/pod/Dist::Zilla::PluginBundle::Git) on MSWin32 is a pain
    so it is also not a prereq on that platform, isn't used and as a result
    releasing from MSWin32 is not allowed.

# OPTIONS

## installer

Specify an alternative to [\[MakeMaker\]](https://metacpan.org/pod/Dist::Zilla::Plugin::MakeMaker)
([\[ModuleBuild\]](https://metacpan.org/pod/Dist::Zilla::Plugin::ModuleBuild),
[\[ModuleBuildTiny\]](https://metacpan.org/pod/Dist::Zilla::Plugin::ModuleBuildTiny), or
[\[ModuleBuildDatabase\]](https://metacpan.org/pod/Dist::Zilla::Plugin::ModuleBuildDatabase) for example).

If installer is [Alien](https://metacpan.org/pod/Dist::Zilla::Plugin::Alien), then any options 
with the alien\_ prefix will be passed to [Alien](https://metacpan.org/pod/Dist::Zilla::Plugin::Alien)
(minus the alien\_ prefix).

If installer is [ModuleBuild](https://metacpan.org/pod/Dist::Zilla::Plugin::ModuleBuild), then any
options with the mb\_ prefix will be passed to [ModuleBuild](https://metacpan.org/pod/Dist::Zilla::Plugin::ModuleBuild)
(including the mb\_ prefix).

If you have a `inc/My/ModuleBuild.pm` file in your dist, then this plugin bundle
will assume `installer` is `ModuleBuild` and `mb_class` = `My::ModuleBuild`.

## readme\_from

Which file to pull from for the Readme (must be POD format).  If not 
specified, then the main module will be used.

## release\_tests

If set to true, then include release tests when building.

## release\_tests\_skip

Passed into the [Author::Plicease::Tests](https://metacpan.org/pod/Dist::Zilla::Plugin::Author::Plicease::Tests)
if `release_tests` is true.

## travis\_status

if set to true, then include a link to the travis build page in the readme.

## mb\_class

if builder = ModuleBuild, this is the mb\_class passed into the \[ModuleBuild\]
plugin.

# SEE ALSO

[Author::Plicease::Init](https://metacpan.org/pod/Dist::Zilla::Plugin::Author::Plicease::Init),
[MintingProfile::Plicease](https://metacpan.org/pod/Dist::Zilla::MintingProfile::Author::Plicease)

# AUTHOR

Graham Ollis <perl@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
