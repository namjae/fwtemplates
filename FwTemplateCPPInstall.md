# Introduction #

This page will assist you in installing fw-template-cxx.

If you've already installed fw-template-cxx and want to know how to use it,
check out the [walkthrough](FwTemplateCPPWalkthrough.md).

# Instructions #

Prerequisites:
  1. [framewerk](FramewerkInstall.md)
  1. [fw-template-c](FwTemplateCInstall.md)
  1. working C++ development setup.

Go to the [downloads section](http://code.google.com/p/fwtemplates/downloads/list?can=2&q=fw-template-cxx*.tar.gz&colspec=Filename+Summary+Uploaded+Size+DownloadCount) and grab the latest `.tar.gz` file.

Unpack the tarball, then run configure and make check.
```
# tar -zxf fw-template-cxx-0.0.3.tar.gz
# cd fw-template-cxx-0.0.3
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
fw-template-cxx-build_0.0.3_darwin-i386.deb fw-template-cxx_0.0.3_all.deb
# sudo dpkg -i fw-pkgout/fw-template-cxx_0.0.3_all.deb 
Selecting previously deselected package fw-template-cxx.
(Reading database ... 19755 files and directories currently installed.)
Unpacking fw-template-cxx (from .../fw-template-cxx_0.0.3_all.deb) ...
Setting up fw-template-cxx (0.0.3) ...
```

That's it.

# Next steps #

Check out the [fw-template-cxx walkthrough](FwTemplateCPPWalkthrough.md).

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