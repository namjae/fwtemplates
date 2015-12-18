# Introduction #

fw-template-C is a C development template for framewerk.  It features:
  * automake setup: libtool and compiler setup done for you.
  * pkg-config integration: pkg-config files for your project are made for    you.  In addition, if any dependencies provide pkg-config files they are used, generally eliminating the need for AC\_CHECK\_LIBS and AC\_CHECK\_HEADERS.[[1](#1.md)]
  * valgrind integration: standard targets for running make check with valgrind.
  * coverage integration: standard configure and make check support for enabling coverage analysis.  guards against releasing packages with coverage enabled.

This walkthrough demonstrates fw-template-c.

# Prerequisites #

[fw-template-c installed](FwTemplateCInstall.md)

It's very helpful to have done the [framewerk walkthrough](FramewerkWalkthrough.md).

# Details #

## Initialize the project ##

First, set up the project with fw-init [in the usual way](FramewerkWalkthrough#Initialize_the_project.md).
```
% env CVSROOT="YOURCVSROOT" fw-init --name myproject --template C --revision cvs
```
Changing directory into the project,
```
% cd myproject/
% cvs -n -q up
A .cvsignore
A AUTHORS
A ChangeLog
A Makefile.am.local
A NEWS
A README
A bootstrap
A configure.ac.local
A fw-pkgin/.cvsignore
A fw-pkgin/Makefile.am.local
A fw-pkgin/config
A fw-pkgin/post-install
A fw-pkgin/post-remove
A fw-pkgin/pre-install
A fw-pkgin/pre-remove
A fw-pkgin/start
A fw-pkgin/stop
A src/.cvsignore
A src/Makefile.am.local
A src/mylib.c
A src/mylib.h
A src/myprog.c
A tests/.cvsignore
A tests/Makefile.am.local
A tests/testprog.c
```

## Anatomy of the top level ##

The root directory of the project now looks like:
```
% ls
AUTHORS  ChangeLog          NEWS    bootstrap           doc  fw-pkgin  tests
CVS      Makefile.am.local  README  configure.ac.local  fw   src
```
Here's a breakdown:
  * `AUTHORS, CVS, ChangeLog, NEWS, README, bootstrap, fw, fw-pkgin, configure.ac.local, Makefile.am.local`: these have the same meanings as in [other framewerk templates](FramewerkWalkthrough#Anatomy_of_the_top_level.md).
  * `src, tests`: C source code (.c, .h) is placed in `src/`, and unit tests in `tests/`.

## Configure the project ##

As with [other framewerk templates](FramewerkWalkthrough#Configure_the_project.md), `fw-pkgin/config` is used to configure the project.  However some new variables are available with this template.
```
% cat fw-pkgin/config
# The FW_PACKAGE_MAINTAINER field is populated with the 
# environment variable FW_PACKAGE_DEFAULT_MAINTAINER if non-empty

FW_PACKAGE_NAME="myproject"
FW_PACKAGE_VERSION="0.0.0"
FW_PACKAGE_MAINTAINER="Paul Mineiro <paul-fw@mineiro.com>"
FW_PACKAGE_SHORT_DESCRIPTION="A short description."
FW_PACKAGE_DESCRIPTION=`cat README`
FW_PACKAGE_ARCHITECTURE_DEPENDENT="1"

# Dependency information.  The native syntax corresponds to Debian,
# http://www.debian.org/doc/debian-policy/ch-relationships.html
# Section 7.1 "Syntax of Relationship Fields"
# 
# For other packaging systems, the syntax is translated for you.

FW_PACKAGE_DEPENDS=""
FW_PACKAGE_CONFLICTS=""
FW_PACKAGE_PROVIDES=""
FW_PACKAGE_REPLACES=""
FW_PACKAGE_SUGGESTS=""

FW_PACKAGE_BUILD_DEPENDS=""
FW_PACKAGE_BUILD_CONFLICTS=""

# uncomment and set to specify additional pkg-config packages on the Requires:
# line of the generated .pc file
# FW_PKGCONFIG_REQUIRES_EXTRA=""

# uncomment and set to specify additional content for the Libs:
# line of the generated .pc file
# FW_PKGCONFIG_LIBS_EXTRA=""

# uncomment and set to specify additional content for the Cflags:
# line of the generated .pc file
# FW_PKGCONFIG_CFLAGS_EXTRA=""

# uncomment and set to add arbitrary additional content to the 
# generated .pc file
# FW_PKGCONFIG_EXTRA=""
```
The extra variables are related to the [creation of a pkg-config file](#pkgconfig_file_generation.md).
This mostly just works (via scanning your source code directory) but in case
it doesn't you have additional control via these variables.

## Build the project ##

Build the project [the usual way](FramewerkWalkthrough#Build_the_project.md),
```
% ./bootstrap && ./build
```

### Hardcore ###

fw-template-c supports "hardcore" compilation mode, wherein a bunch of
warnings are enabled and warnings are treated as errors.  These are basically
the warnings that I have noticed over the years to take seriously.
Unfortunately setting warnings as errors causes alot of configure tests to
fail; fortunately, framewerk is smart enough to set the compiler options
at the very end so it doesn't cause problems during configure.

hardcore mode is enabled by default, but you can disable it by passing --disable-hardcore to build, e.g.,
```
% ./bootstrap && ./build --disable-hardcore
```

### Coverage ###

fw-template-c supports coverage testing compilation mode.  Basically,
a bunch of compiler flags are set and compiler optimization flags are
unset (these can frustrate coverage analysis).  The test driver in
coverage testing mode will run gcov for you and output coverage summaries
during 'make check'.

coverage mode is disabled by default, but you can enable it by passing --enable-coverage to build, e.g.,
```
% ./bootstrap && ./build --enable-coverage
```

fw-template-c will detect whether a package is being created with coverage
compiled code in it.  It is an error to release a package in this state
so 'make release' will error out; in that case 'make clean' and rerun build
without the --enable-coverage argument.

### Makefile.am ###

The top level Makefile.am has some useful rules in it:
```
% cat Makefile.am
include $(top_srcdir)/fw/build/automake/Makefile_dot_am

SUBDIRS += src tests

memcheck:
	cd tests && $(MAKE) memcheck

memcheck-%:
	cd tests && $(MAKE) memcheck-$*

leakcheck:
	cd tests && $(MAKE) leakcheck

leakcheck-%:
	cd tests && $(MAKE) leakcheck-$*

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = @FW_PACKAGE_NAME@-@FW_PACKAGE_MAJOR_VERSION@.0.pc

@FW_PACKAGE_NAME@-@FW_PACKAGE_MAJOR_VERSION@.0.pc: pkgconfig-template.pc
	@ln -f $< $@

srcmakefileamfiles := $(shell find src -name '*.am' -or -name '*.am.local')

pkgconfig-template.pc.in: $(srcmakefileamfiles)
	@fw-exec "template/C/make-pkgconfig-template" $^ > $@

CLEANFILES +=                                   	\
  pkgconfig-template.pc                        	 	\
  @FW_PACKAGE_NAME@-@FW_PACKAGE_MAJOR_VERSION@.0.pc

MAINTAINERCLEANFILES += 				\
  pkgconfig-template.pc.in
```

The memcheck and leakcheck family of targets run unit tests using valgrind
(if installed).  These basically proxy to the versions in the [tests](#Anatomy_of_tests.md) directory for your convenience.

The other rules are related to pkg-config file generation.

### pkgconfig file generation ###

There should now be a `myproject-0.0.pc` file in the root directory of the
project.
```
% cat myproject-0.0.pc
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: myproject
Description: A short description.
Version: 0.0.0
Requires:  
Libs: -L${exec_prefix}/lib -lmylib 
Cflags: -I${includedir}/myproject-0/ 
```
Some notes:
  * The major version number is embedded in the filename; thus possibly multiple major versions can be installed at the same time.  The minor version number is always set to 0 in the filename, e.g., for version a.b.c of the myproject package the filename would be `myproject-a.0.pc`.
  * Packages listed as build dependency that contain .pc files in their manifest will have entries added to Requires: corresponding to their .pc files . Additional Requires data can be added via FW\_PKGCONFIG\_REQUIRES\_EXTRA.
  * Libraries listed in a Makefile.am or Makefile.am.local under `src/` via LTLIBRARIES will have entries added to the Libs: line.  Additional Libs data can be added via FW\_PKGCONFIG\_LIBS\_EXTRA.
  * The Cflags: line is automatically populated with an include line corresponding to the location of installed headers.  Additional Cflags data can be added via FW\_PKGCONFIG\_CFLAGS\_EXTRA.
  * The contents of the FW\_PKGCONFIG\_EXTRA variable is appended verbatim to this file.[[2](#2.md)]

### src/myproject.h ###

A "include everything" header is automatically generated in src as
PROJECTNAME.h, in this case `src/myproject.h`.  It and the other
.h files in `src/` are installed in
$(includedir)/PACKAGE\_NAME-MAJOR\_VERSION, e.g. $(includedir)/myproject-0
for this project.

## Anatomy of tests ##

```
% ls tests/
CVS/                    Makefile.am.local       test-wrapper.sh.in@
Makefile                Makefile.in             testprog.c
Makefile.am@            test-wrapper.sh*
```

`tests/test-wrapper.sh` is used to run the tests without valgrind.
If coverage checking is enabled then it analyzes the test output with
gcov and produces a summary of the test coverage.  If tests are being
run under valgrind then coverage analysis is skipped.  The (make) variables
VALGRIND\_OPTS, MEMCHECK\_OPTS, and LEAKCHECK\_OPTS can be used to modify
the (reasonable) default arguments to valgrind, e.g.,
```
% cd tests/
% make memcheck-testprog
/bin/bash ../libtool    \
          --mode=execute valgrind                       \
          -q                            \
          --tool=memcheck                               \
          --num-callers=20                              \
          ./testprog
% make VALGRIND_OPTS="" memcheck-testprog
/bin/bash ../libtool    \
          --mode=execute valgrind                       \
                                        \
          --tool=memcheck                               \
          --num-callers=20                              \
          ./testprog
==4386== Memcheck, a memory error detector.
==4386== Copyright (C) 2002-2006, and GNU GPL'd, by Julian Seward et al.
==4386== Using LibVEX rev 1658, a library for dynamic binary translation.
==4386== Copyright (C) 2004-2006, and GNU GPL'd, by OpenWorks LLP.
==4386== Using valgrind-3.2.1-Debian, a dynamic binary instrumentation framework.
==4386== Copyright (C) 2000-2006, and GNU GPL'd, by Julian Seward et al.
==4386== For more details, rerun with: -v
==4386==
==4386==
==4386== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 8 from 1)
==4386== malloc/free: in use at exit: 0 bytes in 0 blocks.
==4386== malloc/free: 0 allocs, 0 frees, 0 bytes allocated.
==4386== For counts of detected errors, rerun with: -v
==4386== All heap blocks were freed -- no leaks are possible.
```
Note in the second run the "-q" option to VALGRIND\_OPTS was eliminated, thus
valgrind output a banner and summary.

Look at `tests/Makefile.am` for a complete understanding of what
the template provides.

## Making a package ##

Making a package is done [the usual way](FramewerkWalkthrough#Making_a_package.md), as is [releasing a package](FramewerkWalkthrough#Releasing_a_package.md).

# Conclusion #

Congratulations!  You've made it through the fw-template-c walkthrough.
Hopefully you found it helpful.

# Footnotes #

## 1 ##

So I've discovered this is true **if** you and all your consumers are using a packaging format (because pkg-config files are found by querying the package system for files ending in .pc provided by a dependency).  Once you start making dist tarballs that you want to work anywhere, you have to start manually finding the .pc files again. :(

## 2 ##

In case of need for extreme customization, you can create a file
`fw.local/template/C/make-pkgconfig-template` in your project
and it will be called instead of the (installed)
`fw/template/C/make-pkgconfig-template`.  This is a general
framewerk tip: anytime you see `fw-exec foo/bar/baz` that means
that `fw.local/foo/bar/baz` will be looked for first, followed
by `fw/foo/bar/baz`; framewerk never puts things in `fw.local`,
that space is for you.