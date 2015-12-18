# Introduction #

fw-template-Cxx is a C development template for framewerk.  It is very
similar to [fw-template-C](FwTemplateCWalkthrough.md) and like it features:
  * automake setup: libtool and compiler setup done for you.
  * pkg-config integration: pkg-config files for your project are made for    you.  In addition, if any dependencies provide pkg-config files they are used, generally eliminating the need for AC\_CHECK\_LIBS and AC\_CHECK\_HEADERS.[[1](#1.md)]
  * valgrind integration: standard targets for running make check with valgrind.
  * coverage integration: standard configure and make check support for enabling coverage analysis.  guards against releasing packages with coverage enabled.

This walkthrough demonstrates fw-template-cxx.

# Prerequisites #

[fw-template-cxx installed](FwTemplateCPPInstall.md)

It's very helpful to have done the [framewerk walkthrough](FramewerkWalkthrough.md)
and the [fw-template-c walkthrough](FwTemplateCWalkthrough.md).

# Details #

## Initialize the project ##

First, set up the project with fw-init [in the usual way](FramewerkWalkthrough#Initialize_the_project.md).
```
% env CVSROOT="YOURCVSROOT" fw-init --name myproject --template Cxx --revision cvs
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
A src/mylib.cc
A src/mylib.hh
A src/myprog.cc
A tests/.cvsignore
A tests/Makefile.am.local
A tests/testprog.cc
```

## Differences from fw-template-c ##

This template is almost identical to fw-template-c.  This is not necessarily
because C++ development is almost identical.  It's more due to the fact that
I haven't done alot of C++ since writing framewerk and so I haven't really
explored the possibilities.

Here are the differences:
  1. the automake macros for C++ compiler set up are called.
  1. AC\_LANG is set to C++ .
  1. the automatically generated header is called PROJECTNAME.hh, and includes all .hh files in `src/`.
  1. the options for [hardcore](FwTemplateCWalkthrough#Hardcore.md) compilation are slightly tweaked.

That's it!  So you should really read the [fw-template-c walkthrough](FwTemplateCWalkthrough.md).

# Conclusion #

Congratulations!  You've made it through the fw-template-cxx walkthrough.
Hopefully you found it helpful.

# Footnotes #

## 1 ##

So I've discovered this is true **if** you and all your consumers are using a packaging format (because pkg-config files are found by querying the package system for files ending in .pc provided by a dependency).  Once you start making dist tarballs that you want to work anywhere, you have to start manually finding the .pc files again. :(

