# Introduction #

This page will assist you in installing fw-revision-svn.

If you've already installed fw-revision-svn and want to know how
to use it, check out the [walkthrough](FwRevisionSvnWalkthrough.md).

# The Easy Way #

If you are running a debian package based system (Debian, Ubuntu, [Mac OS/X with fink](http://www.finkproject.org/), etc.), just go to the
[downloads section](http://code.google.com/p/fwtemplates/downloads/list?can=2&q=*.deb&colspec=Filename+Summary+Uploaded+Size+DownloadCount) and grab the latest `.deb` files.

# The Less Easy Way #

Prerequisites:
  1. [framewerk](FramewerkInstall.md)
  1. working subversion installation
    * debian: apt-get install subversion
    * os/x (with [fink](http://www.finkproject.org/)): apt-get install svn
    * freebsd: pkg\_add -r subversion
    * others: ???

If you are not running a debian based system, or you just like to kick the tires,
go to the [downloads section](http://code.google.com/p/fwtemplates/downloads/list?can=2&q=*.tar.gz&colspec=Filename+Summary+Uploaded+Size+DownloadCount) and grab the latest `.tar.gz` file.

Unpack the tarball, then run configure and make check.
```
# tar -zxf fw-revision-svn-0.0.3.tar.gz
# cd fw-revision-svn-0.0.3
# ./configure --prefix=/usr/local && make -s check
```
The default prefix is `/usr` so if you are ok with that then you can omit the prefix argument.  Hopefully you will see something like[[2](#2.md)]
```
...
PASS: test-revision
==================
All 1 tests passed
==================
```
If not, the test output is in `tests/test-revision.out`; perhaps it is informative.

Now you can either `make install` to just stick stuff on your system, or you can build your own debian package if you are on a debian based system. To do the latter type
```
# env FW_DUPLOAD_ARGS="-no" make release
...
```
which should run the tests again and ultimately produce a `.deb` in `fw-pkgout/` in the root directory of the project which you can install.[[1](#1.md)]
```
# ls fw-pkgout/*.deb
fw-pkgout/fw-revision-svn-build_0.0.3_darwin-i386.deb
fw-pkgout/fw-revision-svn_0.0.3_all.deb
# sudo dpkg -i fw-pkgout/fw-revision-svn_0.0.3_all.deb
Selecting previously deselected package fw-revision-svn.
(Reading database ... 51894 files and directories currently installed.)
Unpacking fw-revision-svn (from .../fw-revision-svn_0.0.3_all.deb) ...
Setting up fw-revision-svn (0.0.3) ...
```

That's it.

# Next steps #

Check out the [fw-revision-svn walkthrough](FwRevisionSvnWalkthrough.md).

# Footnotes #

## 1 ##
You might see some errors here if dupload is not installed.  Framewerk wants to upload the package it makes to a repository and I'm assuming you don't have one, hence the FW\_DUPLOAD\_ARGS="-no" (in case you do have dupload installed, this causes it to do a dry run).

If you have dupload installed and your own repository than you can set FW\_DUPLOAD\_ARGS as desired.  For your own projects you can even hard code this in.  Check out `fw-pkgin/config` if you are interested.

## 2 ##
If you see something like:
```
fw requires GNU make to build, you are using bsd make
*** Error code 1

Stop.
```
Then you are using bsd make which will not work.  Try again with gnu make, e.g.,
```
# ./configure --prefix=/usr/local && gmake -s check
```