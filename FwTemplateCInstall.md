# Introduction #

This page will assist you in installing fw-template-c.

If you've already installed fw-template-c and want to know how to use it,
check out the [walkthrough](FwTemplateCWalkthrough.md).

# Instructions #

Prerequisites:
  1. [framewerk](FramewerkInstall.md)
  1. working C development setup with libtool and pkg-config.
    * debian: aptitude install build-essential pkg-config libtool
    * os/x (with [fink](http://www.finkproject.org/)): install [xcode](http://developer.apple.com/tools/xcode/); apt-get install pkgconfig
      * it is pkgconfig, **not** pkg-config
    * freebsd: pkg\_add -r libtool; pkg\_add -r pkg-config
    * others: ???

Go to the [downloads section](http://code.google.com/p/fwtemplates/downloads/list?can=2&q=fw-template-c-*.tar.gz&colspec=Filename+Summary+Uploaded+Size+DownloadCount) and grab the latest `.tar.gz` file.

Unpack the tarball, then run configure and make check.
```
# tar -zxf fw-template-c-0.0.4.tar.gz
# cd fw-template-c-0.0.4
# ./configure --prefix=/usr/local && make -s check
```
The default prefix is `/usr` so if you are ok with that then you can omit the prefix argument.  Hopefully you will see something like[[2](#2.md)]
```
...
PASS: test-template
==================
All 1 tests passed
==================
```
If not, the test output is in `tests/test-template.out`; perhaps it is informative.

Now you can either `make install` to just stick stuff on your system, or you can build your own debian package if you are on a debian based system. To do the latter type
```
# env FW_DUPLOAD_ARGS="-no" make release
...
```
which should run the tests again and ultimately produce a `.deb` in `fw-pkgout/` in the root directory of the project which you can install.[[1](#1.md)]
```
# ls fw-pkgout/
fw-template-c-build_0.0.4_i386.deb  fw-template-c_0.0.4_all.deb
# sudo dpkg -i fw-pkgout/fw-template-c_0.0.4_all.deb 
Selecting previously deselected package fw-template-c.
(Reading database ... 19755 files and directories currently installed.)
Unpacking fw-template-c (from .../fw-template-c_0.0.4_all.deb) ...
Setting up fw-template-c (0.0.4) ...
```

That's it.

# Next steps #

Check out the [fw-template-c walkthrough](FwTemplateCWalkthrough.md).

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