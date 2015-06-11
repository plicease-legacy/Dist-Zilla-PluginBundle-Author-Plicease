# Dist::Zilla::PluginBundle::Author::Plicease [![Build Status](https://secure.travis-ci.org/plicease/Dist-Zilla-PluginBundle-Author-Plicease.png)](http://travis-ci.org/plicease/Dist-Zilla-PluginBundle-Author-Plicease)

Dist::Zilla plugin bundle used by Plicease

# SYNOPSIS

In your dist.ini:

    [@Author::Plicease]

# DESCRIPTION

This is a [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) plugin bundle is a set of my personal preferences.
You are probably reading this documentation not out of choice, but because
you have to.  Sorry.

- Taking over one of my modules?

    This dist comes with a script in `example/unbundle.pl`, which will extract
    the `@Author::Plicease` portion of the dist.ini configuration so that you
    can edit it and make your own.  I strongly encourage you to do this, as it
    will help you remove the preferences from the essential items.

- Want to submit a patch for one of my modules?

    Consider using `prove -l` on the test suite or adding the lib directory
    to `PERL5LIB`.  Save yourself the hassle of dealing with [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla)
    at all.  If there is something wrong with one of the generated files
    (such as `Makefile.PL` or `Build.PL`) consider opening a support ticket
    instead.  Most other activities that you relating to the use of [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla)
    have to do with release testing and uploading to CPAN which is more
    my responsibility than yours.

- Really need to fix some aspect of the build process?

    Or perhaps the module in question is using XS (hint: convert it to FFI
    instead!).  If you really do need to fix some aspect of the build process
    then you probably do need to install [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) and this bundle.
    If you are having trouble figuring out how it works, then try extracting
    the bundle using the `example/unbundle.pl` script mentioned above.

I've only uploaded this to CPAN to assist others who may be working on
one of my dists.  I don't expect anyone to use it for their own projects.

This plugin bundle is mostly equivalent to

    [GatherDir]
    exclude_filename = Makefile.PL
    exclude_filename = Build.PL
    exclude_filename = cpanfile
    exclude_match = ^_build/
    
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
    [PodWeaver]
    
    [NextRelease]
    format = %-9v %{yyyy-MM-dd HH:mm:ss Z}d
    
    [AutoPrereqs]
    [OurPkgVersion]
    [MetaJSON]
    
    [Git::Check]
    allow_dirty = dist.ini
    allow_dirty = Changes
    allow_dirty = README.md
    
    [Git::Commit]
    allow_dirty = dist.ini
    allow_dirty = Changes
    allow_dirty = README.md
    
    [Git::Tag]
    [Git::Push]
    
    [MetaResources]
    bugtracker.web = https://github.com/plicease/My-Dist/issues
    homepage = http://perl.wdlabs.com/My-Dist
    repository.type = git
    repository.url = git://github.com/plicease/My-Dist.git
    repository.web = https://github.com/plicease/My-Dist
    
    [InstallGuide]
    [MinimumPerl]
    [ConfirmRelease]
    
    [ReadmeAnyFromPod]
    filename = README
    location = build
    type = text
    
    [ReadmeAnyFromPod / ReadMePodInRoot]
    filename = README.md
    location = root
    type = markdown
    
    [Author::Plicease::MarkDownCleanup]
    travis_status = 0
    
    [Prereqs / NeedTestMore094]
    -phase = test
    Test::More = 0.94
    
    [Author::Plicease::SpecialPrereqs]
    [CPANFile]

Some exceptions:

- Perl 5.8.x, Perl 5.10.0

    `Dist::Zilla::Plugin::Git::*` does not support Perl 5.8.x or 5.10.0, so it
    is not a prereq there, and it isn't included in the bundle.  As a result
    releasing from Perl 5.8 is not allowed.

- MSWin32

    Installing [Dist::Zilla::Plugin::Git::\*](https://metacpan.org/pod/Dist::Zilla::Plugin::Git::*) on MSWin32 is a pain
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

## github\_repo

Set the GitHub repo name to something other than the dist name.

## github\_user

Set the GitHub user name.

## copy\_mb

Copy Build.PL and cpanfile from the build into the git repository.
Exclude them from gather.

This allows other developers to use the dist from the git checkout, without needing
to install [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) and [Dist::Zilla::PluginBundle::Author::Plicease](https://metacpan.org/pod/Dist::Zilla::PluginBundle::Author::Plicease).

## allow\_dirty

Additional dirty allowed file passed to @Git.

# SEE ALSO

- [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla)
- [Dist::Zilla::Plugin::Author::Plicease::MarkDownCleanup](https://metacpan.org/pod/Dist::Zilla::Plugin::Author::Plicease::MarkDownCleanup)
- [Dist::Zilla::Plugin::Author::Plicease::SpecialPrereqs](https://metacpan.org/pod/Dist::Zilla::Plugin::Author::Plicease::SpecialPrereqs)
- [Dist::Zilla::Plugin::Author::Plicease::Tests](https://metacpan.org/pod/Dist::Zilla::Plugin::Author::Plicease::Tests)
- [Dist::Zilla::Plugin::Author::Plicease::Thanks](https://metacpan.org/pod/Dist::Zilla::Plugin::Author::Plicease::Thanks)
- [Dist::Zilla::Plugin::Author::Plicease::Upload](https://metacpan.org/pod/Dist::Zilla::Plugin::Author::Plicease::Upload)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
