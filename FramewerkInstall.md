# Introduction #

This page will assist you in installing framewerk.

If you've already installed Framewerk and want to know how to use it, check out
the [walkthrough](FramewerkWalkthrough.md).

If you're wondering "what is framewerk?", check out the [introduction](FramewerkIntro.md).

# Instructions #

Prerequisites:
  1. automake, preferably 1.9 or better.
  1. autoconf, preferable 2.5 or better.
  1. (gnu) make
  1. cvs [[1](#1.md)]
  1. posix compliant `/bin/sh`
  1. perl

Go to the [downloads section](http://code.google.com/p/fwtemplates/downloads/list?can=2&q=framewerk-*.tar.gz&colspec=Filename+Summary+Uploaded+Size+DownloadCount) and grab the latest `.tar.gz` file.

```
# tar -zxf framewerk-0.1.15.tar.gz
# cd framewerk-0.1.15
# ./bootstrap && ./build --prefix=/usr/local && make -s check
...
```
The default prefix is `/usr` so if you are ok with that you can omit the prefix argument.  Hopefully what you see[[2](#2.md)] is something like
```
PASS: test-template-fw-build
PASS: test-template-fw-template
PASS: test-template-script
PASS: test-cvs
==================
All 4 tests passed
==================
```
If not, the test output for `test-FOO` is in `tests/test-FOO.out`; perhaps it is informative.

Now you can either `make install` to just stick stuff on your system, or you can build your own debian package if you are on a debian based system. To do the latter type
```
# env FW_DUPLOAD_ARGS="-no" make release
...
```
which should run the tests again and ultimately produce a `.deb` in `fw-pkgout/` in the root directory of the project which you can install.[[3](#3.md)]
```
# ls fw-pkgout/
framewerk-build_0.1.15_i386.deb  framewerk_0.1.15_all.deb
# sudo dpkg -i fw-pkgout/framewerk_0.1.15_all.deb 
Selecting previously deselected package framewerk.
(Reading database ... 17065 files and directories currently installed.)
Unpacking framewerk (from .../framewerk_0.1.15_all.deb) ...
Setting up framewerk (0.1.15) ...

#
```

That's it.

# Next steps #

Check out the [framewerk walkthrough](FramewerkWalkthrough.md).

Or you can install templates to extend the power of framewerk.

  * [fw-template-c](FwTemplateCInstall.md): for C development.
  * [fw-template-erlang](FwTemplateErlangInstall.md): for Erlang development.
  * [fw-revision-svn](FwRevisionSvnInstall.md): for subversion support.

# Footnotes #

## 1 ##
Not strictly required but test-cvs will fail 'make check' since it exercises the cvs revision control hooks.

## 2 ##
If you see something like:
```
fw requires GNU make to build, you are using bsd make
*** Error code 1

Stop.
```
Then you are using bsd make which will not work.  Try again with gnu make, e.g.,
```
# ./bootstrap && ./build --prefix=/usr/local && gmake -s check
```

## 3 ##
You might see some errors here if dupload is not installed.  Framewerk wants to upload the package it makes to a repository and I'm assuming you don't have one, hence the FW\_DUPLOAD\_ARGS="-no" (in case you do have dupload installed, this causes it to do a dry run).

If you have dupload installed and your own repository than you can set FW\_DUPLOAD\_ARGS as desired.  For your own projects you can even hard code this in.  Check out `fw-pkgin/config` if you are interested.