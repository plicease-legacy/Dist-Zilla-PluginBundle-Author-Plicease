# Dist::Zilla::PluginBundle::Author::Plicease

Dist::Zilla plugin bundle used by Plicease

# VERSION

version 1.19

# SYNOPSIS

In your dist.ini:

    [@Author::Plicease]

# DESCRIPTION

This Dist::Zilla plugin bundle is the equivalent to

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
    

    [Author::Plicease::TransformTravis]
    

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

# OPTIONS

## installer

Specify an alternative to [\[MakeMaker\]](http://search.cpan.org/perldoc?Dist::Zilla::Plugin::MakeMaker)
([\[ModuleBuild\]](http://search.cpan.org/perldoc?Dist::Zilla::Plugin::ModuleBuild),
[\[ModuleBuildTiny\]](http://search.cpan.org/perldoc?Dist::Zilla::Plugin::ModuleBuildTiny), or
[\[ModuleBuildDatabase\]](http://search.cpan.org/perldoc?Dist::Zilla::Plugin::ModuleBuildDatabase) for example).

# SEE ALSO

[Author::Plicease::Init](http://search.cpan.org/perldoc?Dist::Zilla::Plugin::Author::Plicease::Init),
[MintingProfile::Plicease](http://search.cpan.org/perldoc?Dist::Zilla::MintingProfile::Author::Plicease)

# AUTHOR

Graham Ollis <perl@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
