

# Introduction #

Framewerk ships with support for:
  * automake build
  * cvs revision control
  * svn revision control
  * debian packaging
  * rpm packaging
  * script template
This particular combination of features is packed into the initial tarball because framewerk is self-building so this was the set of things I needed to get going.

This walkthrough demonstrates framewerk via the script template.

# Prerequisites #

[framewerk installed](FramewerkInstall.md)

# Details #

## Initialize the project ##

First, set up the project with fw-init.  **Warning**: this modifies your source code repository, so create a temporary one if that bothers you. [[1](#1.md)]
```
% env CVSROOT="YOURCVSROOT" fw-init --name myproject --template script --revision cvs
```
Generally template `foo` is initialized using `fw-init` with argument `--template foo`, although templates may define other required arguments to `fw-init`.

Changing directory into the project,
```
% cd myproject
% cvs -n -q up
A .cvsignore
A AUTHORS
A ChangeLog
A Makefile.am.local
A NEWS
A README
A bootstrap
A configure.ac.local
A bin/.cvsignore
A bin/Makefile.am.local
A bin/myscript
A fw-pkgin/.cvsignore
A fw-pkgin/Makefile.am.local
A fw-pkgin/config
A fw-pkgin/post-install
A fw-pkgin/post-remove
A fw-pkgin/pre-install
A fw-pkgin/pre-remove
A fw-pkgin/start
A fw-pkgin/stop
A tests/.cvsignore
A tests/Makefile.am.local
A tests/testmyscript
```
notice `.cvsignore` files have been made by the template corresponding to files the template feels should not be under revision control (e.g., for automake build based templates, Makefiles are generated and therefore not checked in).  Framewerk interacts with the revision control system via an abstraction layer so when using other revision control systems the template will indicate files should be ignored using the appropriate method.[[2](#2.md)]

## Anatomy of the top level ##

The root directory of the project now looks like:
```
% ls
AUTHORS                 NEWS                    configure.ac.local
CVS/                    README                  fw@
ChangeLog               bin/                    fw-pkgin/
Makefile.am.local       bootstrap*              tests/
```
Here's a breakdown:
  * `AUTHORS, ChangeLog, NEWS, README`: these are files inherited from the conventions of automake.  By default framewerk gets the long package description from the `README`, but otherwise these files are ignored by framewerk.
  * `CVS`: revision control specific
  * `bootstrap`: framewerk generally tries not to check in important scripts into your project, so that the project's behaviour can be easily changed by upgrading framewerk.  however bootstrap is installed and checked-in to get things going.[[5](#5.md)]
  * `Makefile.am.local`: this is where you can put any additional (auto)make commands beyond what is supplied by the template.  the template will link in a `Makefile.am` which contains a directive to include your `Makefile.am.local`.[[7](#7.md)]
  * `configure.ac.local`: this is where you can put any additional autoconf commands beyond what is supplied by the template.  the template will link in a `configure.ac` which contains a directive to include your `configure.ac.local`.[[7](#7.md)]
  * `bin, tests`: the script template creates a `bin` directory to contain your scripts, and `tests` directory to contain the tests for those scripts.  different templates will create additional directories.
  * `fw`: this is a link to the installation of framewerk on the local system (or, in a dist tarball, it is a copy of the installation of framewerk at `make dist` time).  generally you shouldn't have to look in here.[[6](#6.md)]
  * `fw-pkgin`: this directory contains files that configure how framewerk builds packages.

## Configure the project ##

Edit `fw-pkgin/config` in your favorite editor.  It consists of some shell variable assignments.
```
# The FW_PACKAGE_MAINTAINER field is populated with the 
# environment variable FW_PACKAGE_DEFAULT_MAINTAINER if non-empty

FW_PACKAGE_NAME="myproject"
FW_PACKAGE_VERSION="0.0.0"
FW_PACKAGE_MAINTAINER="Paul Mineiro <paul-fw@mineiro.com>"
FW_PACKAGE_SHORT_DESCRIPTION="A short description."
FW_PACKAGE_DESCRIPTION="`cat README`"
FW_PACKAGE_ARCHITECTURE_DEPENDENT="0"

# Dependency information.  The native syntax corresponds to Debian,
# http://www.debian.org/doc/debian-policy/ch-relationships.html
# Section 7.1 "Syntax of Relationship Fields"
# 
# For other packaging systems, the syntax is translated for you.

FW_PACKAGE_DEPENDS=""
FW_PACKAGE_CONFLICTS=""
FW_PACKAGE_PROVIDES=""
FW_PACKAGE_REPLACES=""

FW_PACKAGE_BUILD_DEPENDS=""
FW_PACKAGE_BUILD_CONFLICTS=""

# dupload is used for submitting debian packages to a package archive
# The FW_DUPLOAD_ARGS field is populated with the environment variable
# FW_DEFAULT_DUPLOAD_ARGS if non-empty at init time

FW_DUPLOAD_ARGS=${FW_DUPLOAD_ARGS-"-q"}

# scp+createrepo is used for submitting rpm packages to a package archive
# The FW_RPM_REPO_USER, FW_RPM_REPO_HOST, FW_RPM_REPO_BASEDIR,
# and FW_RPM_POSTCREATEREPO_COMMANDS variables are populated with 
# FW_RPM_REPO_USER_DEFAULT, FW_RPM_REPO_HOST_DEFAULT, 
# FW_RPM_REPO_BASEDIR_DEFAULT, and FW_RPM_POSTCREATEREPO_COMMANDS_DEFAULT
# respectively if non-empty at init time

FW_RPM_REPO_USER=${FW_RPM_REPO_USER-"`whoami`"}
FW_RPM_REPO_HOST=${FW_RPM_REPO_HOST-"localhost"}
FW_RPM_REPO_BASEDIR=${FW_RPM_REPO_BASEDIR-""}
FW_RPM_CREATEREPO_ARGS=${FW_RPM_CREATEREPO_ARGS-"-q --database"}

# this variable controls whether createrepo is run incrementally (--update).
# possible settings are yes (always do it), no (never do it), and 
# auto (do it if the repository has been previously initialized)
FW_RPM_CREATEREPO_INCREMENTAL=${FW_RPM_CREATEREPO_INCREMENTAL-"auto"}

# these commands will be run after a successful createrepo run
FW_RPM_POSTCREATEREPO_COMMANDS=${FW_RPM_POSTCREATEREPO_COMMANDS-"true"}
# here's a suggestion:
# FW_RPM_POSTCREATEREPO_COMMANDS="gpg --detach-sign --armor repodata/repomd.xml"
```
These variables affect how packages (and dist tarballs) are built.  For instance currently
`FW_PACKAGE_ARCHITECTURE_DEPENDENT="0"` so a binary package will be built for the "all" architecture.  If
`FW_PACKAGE_ARCHITECTURE_DEPENDENT="1"` then a binary package will be built for the host architecture.

Note some dependencies are added for you automatically by the template and are not listed explicitly.  For instance a build dependency on framewerk is automatically generated in this case. [[3](#3.md)]

## Packaging Hooks ##

Other important files in `fw-pkgin` are the packaging hooks
```
% ls fw-pkgin
Makefile.am.local  post-install*  pre-install*  start*
config             post-remove*   pre-remove*   stop*
```
These are hopefully self-documenting; basically they act like debian hooks (thus start/stop currently do nothing but confuse).  For details on how rpm is made to look like debian, check out [the package hooks wiki page](PackageHooks.md).

For the purposes of this walkthough, you can ignore the packaging hooks: the initially created versions do nothing.

## Build the project ##

All framewerk projects build the same way.[[15](#15.md)]
```
% ./bootstrap && ./build
```
The template should have created a working project which can be built in this way or the template has a bug.  Also there should be no new non-ignored files according the revision control system or the template has a bug.

Maintainer mode is used such that if `fw-pkgin/config` is modified, bootstrap and build are essentially re-run, so there is typically no need to run bootstrap at any time other than project check-out (although, bootstrap is useful to escape from snafus).

You can also test the project via[[16](#16.md)]
```
% make -s check
```
All templates should initialize a project in a state which passes `make check` or the template has a bug.[[4](#4.md)]

## Modify the project ##

Generally working with framewerk is like working with automake but with the common bits done for you already.[[8](#8.md)]  So to add stuff to the project you're going to have to know some automake.

If you wanted to add another script to the project you could create a file like
```
% cat > bin/mynewscript
#! /bin/sh

echo "awesome"
% chmod +x bin/mynewscript
```
and then edit `bin/Makefile.am.local` to look like:
```
% cat bin/Makefile.am.local
# put whatever (auto)make commands here, they will be included from Makefile.am

dist_bin_SCRIPTS =              \
  myscript                      \
  mynewscript
```
Framewerk uses `make install` to determine the contents of your package.  This means that a package made from this project will want to install `mynewscript` in `/usr/bin`.[[9](#9.md)]

You should also make a test for your new script:
```
% cat > tests/testmynewscript
#! /bin/sh

output=`../bin/mynewscript`

test "x$output" = "xawesome"
% chmod +x tests/testmynewscript
```
and add then edit `tests/Makefile.am.local` to make it look like
```
% cat tests/Makefile.am.local
# put whatever (auto)make commands here, they will be included from Makefile.am

TESTS =         \
  testmyscript  \
  testmynewscript

EXTRA_DIST +=   \
  testmyscript  \
  testmynewscript
```

Now re-run the tests.
```
% make -s check
Making check in fw-pkgin
Making check in bin
 cd .. && /usr/local/bin/bash /usr/home/pmineiro/src/myproject/missing --run automake-1.10 --foreign  bin/Makefile
 cd .. && /usr/local/bin/bash ./config.status bin/Makefile 
config.status: creating bin/Makefile
Making check in tests
 cd .. && /usr/local/bin/bash /usr/home/pmineiro/src/myproject/missing --run automake-1.10 --foreign  tests/Makefile
 cd .. && /usr/local/bin/bash ./config.status tests/Makefile 
config.status: creating tests/Makefile
PASS: testmyscript
PASS: testmynewscript
==================
All 2 tests passed
==================
```

## Making a package ##

If you installed framewerk as a debian package on your system (as opposed to `make install` from a source package) then you should've seen a line like
```
checking for native package type... deb (autodetected)
```
in the output of `./build`.  Similarly for rpm
```
checking for native package type... rpm (autodetected)
```
If you see
```
checking for native package type... none (autodetected)
```
then either you didn't install framewerk as a package or else you're using a packaging system that framewerk doesn't recognize.  Right now it only recognizes debian package format (which includes fink on OS/X) or rpm, but new package types can be provided via additional packages.[[10](#10.md)]

If everything's working then you can type
```
% make -s package
Making all in fw-pkgin
Making all in bin
Making all in tests
A .cvsignore
A AUTHORS
A ChangeLog
A Makefile.am.local
A NEWS
A README
A bootstrap
A configure.ac.local
A bin/.cvsignore
A bin/Makefile.am.local
A bin/myscript
? bin/mynewscript
A fw-pkgin/.cvsignore
A fw-pkgin/Makefile.am.local
A fw-pkgin/config
A fw-pkgin/post-install
A fw-pkgin/post-remove
A fw-pkgin/pre-install
A fw-pkgin/pre-remove
A fw-pkgin/start
A fw-pkgin/stop
A tests/.cvsignore
A tests/Makefile.am.local
A tests/testmyscript
? tests/testmynewscript
fw-package: warning: local project is not up to date
Making check in fw-pkgin
Making check in bin
Making check in tests
PASS: testmyscript
PASS: testmynewscript
==================
All 2 tests passed
==================
package/deb/make-package: warning: start hook not supported
package/deb/make-package: warning: stop hook not supported
dpkg-deb: building package `myproject' in `/root/myproject/fw-pkgout/myproject_0.0.0-TEST1_all.deb'.
dpkg-deb: building package `myproject-build' in `/root/myproject/fw-pkgout/myproject-build_0.0.0-TEST1_i386.deb'.
%
```
to have a test package made.[[11](#11.md)]  So a couple of things happened here:

  1. Revision control was queried to see if the project was up to date.  It is not, but since this is a test package the build was allowed to continue.  If this were a release version than the package build would've bailed out at this point.
  1. Tests were run.  They passed, but if they had failed it would've been ok because this is a test package build.  If this were a release version and the tests did not pass then the build would've bailed out at this point.[[12](#12.md)]
  1. A package was built and placed into `fw-pkgout/` at the root directory of the project.  Since this is a test build, TEST1 is appended to the version number.  If you are using rpm, you will get a similarly named set of rpms which includes a source rpm.
  1. A build package was built and placed into `fw-pkgout/`.  A build package is a exact dependency-clousure snapshot of the build environment at package creation time.  It is used to recreate the conditions under which the package was generated (along with the revision control tag generated at [release time](#Releasing_a_package.md)).  It provides some of the functionality of a source package (by assisting in creating a viable build environment) but also provides forensic functionality (because it captures the exact dependency closure at the time of build, it can be used to diagnose problems).

The exact sequence of what happens when a package is made is under the control of the template.  The script template doesn't do anything additional beyond the vanilla automake build hooks but other templates do.  For instance, the C template checks the objects in the project for coverage symbols and emits an error if any are found.  Generally templates are expected to extend their parent template's methods so you can expect all templates to do at least the above steps.[[13](#13.md)]

The result (for debian package systems) should be two packages in `fw-pkgout/`,
```
% ls fw-pkgout/
myproject-build_0.0.0-TEST1_i386.deb  myproject_0.0.0-TEST1_all.deb
```
You can inspect these with `dpkg --info` and `dpkg --contents`, or install them for testing with `sudo dpkg -i`, etc.
For rpm systems there should be three packages in `fw-pkgout/`,
```
% ls fw-pkgout/
myproject-0.0.0-TEST1.noarch.rpm  myproject_build-0.0.0-TEST1.i386.rpm
myproject-0.0.0-TEST1.src.rpm
```
and in addition a dist tarball is created at the top of the project.  You can inspect these with `rpm -q -p`, or install them for testing with `sudo rpm -i`, etc.

## Releasing a package ##

Releasing a package is very similar to making a test package, but less forgiving.  First we must bring the project up to date
```
% cvs add bin/mynewscript tests/testmynewscript
% cvs ci -m ''
...
```
After that we can release a package.  For deb packages, dupload is used to transfer the package to the repository, so generally you need to configure a [dupload.conf](http://www.debian.org/doc/maint-guide/ch-upload.en.html) to upload packages.[[14](#14.md)]  The environment variable `FW_DUPLOAD_ARGS` is passed to dupload, so we'll use that to make dupload do a dry-run.
```
% env FW_DUPLOAD_ARGS="-no" make release
...
```

The process is similar to `make package`, excepts that warnings are now errors.  In addition a side-effect is that the repository is tagged with a `PACKAGETYPE-VERSION-ARCH`, e.g.,
```
% cvs status -v configure.ac.local                                                  
===================================================================
File: configure.ac.local        Status: Up-to-date

   Working revision:    1.1     Mon Feb 18 05:14:35 2008
   Repository revision: 1.1     /Users/pmineiro/tmp/dild/myproject/configure.ac.local,v
   Sticky Tag:          (none)
   Sticky Date:         (none)
   Sticky Options:      (none)

   Existing Tags:
        deb-0_0_0-all           (revision: 1.1)
```
Combining the repository tag and the build package, it's possible to recreate the conditions under which the package was built.  This is useful for trying to find difficult-to-reproduce bugs.

For rpm the process is similar, but instead of leveraging dupload framewerk includes a simple mechanism for transferring the packages with scp and then running [createrepo](http://createrepo.baseurl.org/) via ssh on the repository host.  The environment variables in `fw-pkgin/config` indicate the hostname, user, directory, createrepo flags, and postprocessing commands.

## Releasing a tarball ##

Framewerk supports the `make dist` family of targets.  The distribution tarball is augmented with portions of framewerk so that end user of the tarball need not install framewerk.  Additionally dist tarballs build like vanilla automake projects, i.e.,
```
% ./configure && make
```
so that consumers of dist tarballs remain blissfully aware of framewerk.  Templates initialize the project in a state such that dist tarballs build correctly otherwise the template has a bug.  However for files added to the project sometimes [autoconf dist directives](http://www.delorie.com/gnu/docs/automake/automake_91.html) are required to ensure placement in the dist tarball.

Building an rpm package is a great way to test the dist tarball, since rpmbuild is supplied the dist tarball to build the package (thus, if it is broken, the rpm package will fail to build).

# Bells and whistles #

This section describes interesting bits and bobs of framewerk.

## Checking scripts ##

For automake the file `fw/build/automake/check-shell.am` defines a
scheme for checking interpreted files.

```
% cat fw/build/automake/check-shell.am
find_shell = $(shell perl -ne 'if (m%\043!\s*/usr/bin/env\s*([^/]+)%) { print $$1; } elsif (m%\043!\s*\S*?/([^/\s]+)\s*$$%) { print $$1; }; exit' $(1))

.PHONY: check-script-perl-%
check-script-perl-%:
        perl -cw $*

.PHONY: check-script-sh-%
check-script-sh-%:
        @CHECK_SHELL@ -n $*

.PHONY: unknown-script-%
unknown-script-%:
        @echo "warning: cant check $* : unknown interpreter '$(shell head -1 $*)'" 1>&2
        @echo "warning: try defining make target 'check-script-$(call find_shell,$*)-%'" 1>&2
        @echo "warning: to instruct make on how to check scripts of type $(call find_shell,$*)" 1>&2

.%.script_ok: %
        @$(MAKE) -q -s check-script-$(call find_shell,$<)-$< 2>/dev/null ; \
                                                                           \
        if test $$? = 2 ;                                                  \
          then                                                             \
            $(MAKE) --no-print-directory unknown-script-$< ;               \
          else                                                             \
            $(MAKE) -s --no-print-directory                                \
              check-script-$(call find_shell,$<)-$< &&                     \
            touch $@ ;                                                     \
          fi

CLEANFILES +=                                   \
  $(wildcard .*.script_ok)
```

The idea is that by defining the target `.foo.script_ok`, the
interpreted script `foo` will be syntax checked.  Knowledge about
additional interpreters can be provided by templates, e.g.,
in [Makefile.otp](FwTemplateErlangWalkthrough#Build_the_project.md) from
fw-template-erlang the rule
```
.PHONY: check-script-escript-%
check-script-escript-%:
        escript -s $*
```
informs the system about [escript](http://www.erlang.org/doc/man/escript.html).

Many templates will by default pass foo\_SCRIPTS target sets through
.script\_ok, e.g., in the `bin/Makefile.am` provided by the script
template the lines
```
noinst_DATA =                           \
  $(dist_bin_SCRIPTS:%=.%.script_ok)    \
  $(bin_SCRIPTS:%=.%.script_ok)
...
include $(top_srcdir)/fw/build/automake/check-shell.am
```
cause the scripts to be installed in $(prefix)/bin to be checked.

You can use this in your own Makefiles as well by just including
check-shell.am as above.

# Next steps #

Congratulations, you've made it through the framewerk walkthrough.  Hopefully you found it pedagogical.

Now you can install templates to extend the power of framewerk.

  * [fw-template-c](FwTemplateCInstall.md): for C development.
  * [fw-template-cxx](FwTemplateCPPInstall.md): for C++ development.
  * [fw-template-erlang](FwTemplateErlangInstall.md): for Erlang development.
  * [fw-template-javascript](FwTemplateJavascriptInstall.md): for Javascript development.

# Footnotes #

### 1 ###
Alternatively, if you are too young to remember cvs, you can initialize the project without revision control.
```
% fw-init --name mynorevproject --template script --revision none
```

### 2 ###
In practice, the only other revision control system to be ported to the framewerk API is subversion, which is not that different than cvs.  So maybe the abstraction is not abstract enough.

### 3 ###
For the truly curious, you can see how the template is modifying the config file by running
```
% fw-exec template/script/load-config
```
in the root directory of the project.

### 4 ###
Technically speaking this only required for templates which use automake to build.  Right now, however, that is all of them.

### 5 ###
It does pass a version number to fw-bootstrap so that, in theory, framewerk has a chance to upgrade it when it is run.

### 6 ###
There needs to be a whole wiki page about this feature, but here's a quick note instead.
Any file located in `fw/path/basename` relative to the root directory of your project can be overridden by a file `fw.local/path/basename` of the same name under `fw.local` in your root directory.  So for instance you could override the way the script template loads the config file by creating a `fw.local/template/script/load-config` file.  This escape hatch is here so that in case framewerk is getting in your way you can deal with it.

### 7 ###
The framewerk philosophy is to try to do the right thing by default but be able to be overridden if necessary.  So for `Makefile.am.local` and `configure.ac.local` files, if you for some reason can't work with the installed `Makefile.am` and `configure.ac` files and their include strategy, you can create your own `Makefile.am` and/or `configure.ac` and check them into your project.  If framewerk sees that you have these files, it will not link against the installed versions.  Note the disadvantage of doing this is that you no longer get your project automatically updated when framewerk is upgraded, so it should only be done when necessary.

### 8 ###
Which is weird because that's what automake said about make and autoconf.

### 9 ###
Assuming the prefix is `/usr`.  `/usr` is the default prefix for framewerk projects, but can be overridden, e.g. via the `--prefix` argument to `configure`.

### 10 ###
I haven't actually written a package to support any other package type, so it's probable that the abstraction is not good enough.

If for some reason you think framewerk is autodetecting your package type incorrectly you can force it via the `FW_NATIVE_PACKAGE_TYPE` environment variable when running configure, e.g.,
```
% FW_NATIVE_PACKAGE_TYPE="deb" ./configure
```

### 11 ###
If you try this when the native package type is 'none', it just does nothing.

### 12 ###
It is possible to skip running `make check` by setting the environment variable `FW_SKIP_TESTS`, e.g.,
```
% env FW_SKIP_TESTS="1" make package
```
but this can be a nasty habit.

### 13 ###
At least for all templates based upon the automake build system, which is currently all of them.

### 14 ###
At our company we have a package which installs an `/etc/dupload.conf` which knows how to talk to our package repository and makes that repository the default, and then we list that package in our build dependencies.  In addition for my personal work I put a `.dupload.conf` in my home directory which contains a definition for my personal package archive called 'myarchive', and then I use `FW_DUPLOAD_ARGS="-t myarchive"` in `fw-pkgin/config` to cause that entry to be used by dupload.

### 15 ###
When building from the source code repository, that is.  `make dist` tarballs are tweaked so that they [build just like vanilla automake projects](#Releasing_a_tarball.md).

### 16 ###
If you see something like:
```
fw requires GNU make to build, you are using bsd make
*** Error code 1

Stop.
```
Then you are using bsd make which will not work.  Try again with gnu make, e.g.,
```
% gmake -s check
```