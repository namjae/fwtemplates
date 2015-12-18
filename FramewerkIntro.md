

Want to just start installing?  Check out the [install howto](FramewerkInstall.md).

# Introduction #

Back in the day, every time I would start a new project, I would copy around a wad of automake.  That got pretty unwieldly, and they would all diverge.  When I learned something new about automake, I had to try some find-xargs-perl trick to change everything over.

At Idealab I worked with and hacked on [wigwam](http://www.wigwam-framework.org/), which provided a standard layout for projects, standard build commands, standard deployment commands, a (proprietary) packaging system, and chroot-like localization; the packaging system effectively allowed the specification of build environments, although sometimes things were provided by the "base system" which was not well tracked.  The wigwam machinery was itself a wigwam package so that made upgrading processes straightforward.  However, one thing wigwam never made very easy was publishing new packages.

At Yahoo I worked on a system which was starting to create wads of automake everywhere.  Yahoo had a packaging system already (yinst), a nice localization strategy (yroot), and a very nice package archive with easy upload (dist-release) and management tools.  In particular, the easy package release feature greatly increased productivity over wigwam.  However their "build system" was a bunch of serious hacked up and specialized makefiles (not automake: straight make), so this new project was using automake.  There was room for improvement.  We still needed to enforce a standard project layout, standard build and release commands, build environment specification for reproducibility and maintainability [[1](#1.md)], and business processes associated with development activities (e.g., tag cvs in a particular way when releasing a package, or don't allow released packaged compiled with coverage symbols).  So we made a system called skeletor that worked pretty well.  Like wigwam, skeletor was itself a skeletor package and we could release new developer processes by upgrading skeletor (except that skeletor had to drop some automake files into a project when initializing and we discovered that sometimes that caused some work to need to be done to upgrade a project).  Unlike wigwam, skeletor leveraged yinst, yroot, and dist-release and was therefore more effective.

So I was pretty happy with skeletor, except that:

  * it was locked into one type of build system (automake), revision control (cvs), packaging (yinst), package archive (dist-release), etc., while the open source community was innovating in all these areas;
  * it put too much stuff into the project; in retrospect more could be abstracted so that only project specific stuff was in there, making upgrading easier; and
  * new project templates were added to skeletor itself, not provided by other packages.

So now framewerk is my third go at a build system, and this time around I'm heavily emphasizing template-ability. Basically, a framewerk template defines how to do the following things:

  1. Initialize a new project
  1. Bootstrap an existing project
  1. Build an existing project
  1. Release a package from an existing project

The template will typically define processes around these events, to ensure uniformity among your developers (or, for yourself, uniformity across your projects).

These things are done while abstracting the following out:

## Build system ##

In theory, the project could be based on [ant](http://ant.apache.org/manual/index.html) or [automake](http://sources.redhat.com/automake/) and it wouldn't matter for these tasks: the commands to run would be the same.  In practice, I have only implemented the build interface for automake, so probably the abstraction isn't sufficient.

## Revision control system ##

Templates might define processes which involve interacting with the revision control system; for instance, my templates

  * make sure I am up-to-date with the repository if I am releasing a non-test package, and
  * tag the repository with a tag generated from the package name, architecture, and package version.

The interface to the revision control system is abstracted out so that it can be made to work with cvs, subversion, perforce, mercurial, git, etc.  In practice right now only cvs and subversion are supported, so probably the abstraction is not sufficient.

## Packaging system ##

Templates might define processes which involve interacting with the packaging system, for instance

  * compute the dependency closure of a set of packages, or
  * find all the packages in the dependency closure of our build package set which contain pkgconfig files so I can auto-configure the C compiler as much as possible, or
  * make a package, or
  * upload a package to an archive.

The interface to the packaging system is abstracted out so that it can be made to work with debian, rpm, etc.  Right now debian and rpm are supported; since I did debian first, basically all the configuration is debian syntax and debian style with framewerk translating to the rpm equivalent.

# Packages #

## framewerk ##

This is the base of the system.  It provides several key components: build/automake, package/deb, package/rpm, revision/cvs, revision/svn, template/fw-template, template/fw-build, and template/script.  It also provides the key executables that define the framework: fw-init, fw-bootstrap, fw-exec, and fw-package.

template/fw-template is a template for making new templates.  I used it to make all the templates listed here, so I'm gaining confidence in it.

template/fw-build is a template for making new build plugins.  I haven't used it for anything real yet, so it's probably broken.

template/fw-script is a template for "shell script" projects.  They don't happen that often.  The real purpose of this template is to allow framewerk to bootstrap itself.  One can use this template to make a perl project, but only if you're the kind of person who'd rather use automake than makemaker (I happen to be this type of person).  I think most people would be better served by defining makemaker as a build type and then using a perl template based off on that, so that's on my todo list.

## fw-template-C ##

This is a C development template for framewerk.  It provides:

  * automake setup: libtool and compiler setup done for you.

  * pkg-config integration: pkg-config files for your project are made for you.  In addition, if any dependencies provide pkg-config files they are used, generally eliminating the need for AC\_CHECK\_LIBS and AC\_CHECK\_HEADERS.[[2](#2.md)]

  * valgrind integration: standard targets for running make check with valgrind.

  * coverage integration: standard configure and make check support for enabling coverage analysis.  guards against releasing packages with coverage enabled.

I've done a couple of projects with it (e.g., [fuserl](http://code.google.com/p/fuserl)), so I feel pretty good about it.

## fw-template-Cxx ##

This is derived from fw-template-C.  It doesn't do much more, except set up the C++ compiler.  There is more that could be done here; I know there are alot of autoconf macros that try to get around the various differences in C++ installations (e.g., std::cout or just cout?; iostream.h or iostream?).  However I mostly use an up-to-date g++, because I can't stand to read about crazy advanced techniques and then try them out only to have them fail.  (Also I've mostly given up on C++ in favor of Erlang).

Does it work?  Well, I've used framewerk to package external projects written in C++ using it if the didn't already have debian packages available; and I've done small C++ projects with it.

## fw-template-erlang ##

This is an Erlang development template for framewerk.  It is coming along: I have [eunit](http://svn.process-one.net/contribs/trunk/eunit/doc/overview-summary.html), [cover](http://www.erlang.org/doc/man/cover.html), and [edoc](http://www.erlang.org/doc/apps/edoc/index.html) integration now; the template also generates an OTP compliant [application resource file](http://www.erlang.org/doc/design_principles/applications.html#7.3) via scanning the source; and automatically integrates with [erlrc](http://http://code.google.com/p/erlrc/).  I use this daily at my job as do several other people so I have the highest confidence in the stability of this template, if not the strategies it prescribes.

## fw-template-revision ##

This is a template for revision control plugins for framewerk.  I used it to develop fw-revision-svn.  I then deprecated fw-revision-svn because I needed to pull svn support into the base to get the code onto google code's repository.  However the exercise gives me reason to believe fw-template-revision is good to go.

## fw-revision-svn ##

~~Installing this package instructs framewerk on how to use subversion for version control.
I use this all the time because google code is subversion based, so I have high confidence in subversion support.~~

subversion support now included in the base distribution of framewerk.

## fw-revision-javascript ##

I did this recently because of some javascript gigs I had.  The main value adds are integrating yuicompressor, qunit, and jscoverage; the latter two helping reduce my defect rate substantially.  Check out the [walkthrough](FwTemplateJavascriptWalkthrough.md) for more info.

# Next Steps #

[Install framewerk](FramewerkInstall.md).

# Footnotes #

## 1 ##

This particular point cannot be overemphasized.  One developer spent a week trying to  build a particularly complicated piece of software we had.  When we moved it over to skeletor with build environment snapshotting, it became a single command to reproduce the build environment and another single command to build the project; and these two commands were the same for every skeletor project.  Sometimes people forgot to specify build dependencies and then the resulting build snapshot was incomplete, but mostly it worked great.

## 2 ##

So I've discovered this is true **if** you and all your consumers are using a packaging format (because pkg-config files are found by querying the package system for files ending in .pc provided by a dependency).  Once you start making dist tarballs that you want to work anywhere, you have to start manually finding the .pc files again. :(