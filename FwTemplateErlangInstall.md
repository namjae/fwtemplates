# Introduction #

This page will assist you in installing fw-template-erlang.

If you've already installed fw-template-erlang and want to know how to use it,
check out the [walkthrough](FwTemplateErlangWalkthrough.md).

# Instructions #

Prerequisites:
  1. [framewerk](FramewerkInstall.md)
  1. working erlang installation.
    * debian: aptitude install erlang-dev
    * os/x (with [fink](http://www.finkproject.org/)): apt-get install erlang-otp
    * freebsd: pkg\_add -r erlang
    * others: ???

Go to the [downloads section](http://code.google.com/p/fwtemplates/downloads/list?can=2&q=fw-template-erlang-*.tar.gz&colspec=Filename+Summary+Uploaded+Size+DownloadCount) and grab the latest `.tar.gz` file.

Unpack the tarball, then run configure and make check.
```
# tar -zxf fw-template-erlang-0.1.21.tar.gz 
# cd fw-template-erlang-0.1.21
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
fw-template-erlang-build_0.1.21_i386.deb  fw-template-erlang_0.1.21_all.deb
# sudo dpkg -i fw-pkgout/fw-template-erlang_0.1.21_all.deb 
Selecting previously deselected package fw-template-erlang.
(Reading database ... 19755 files and directories currently installed.)
Unpacking fw-template-erlang (from .../fw-template-erlang_0.1.21_all.deb) ...
Setting up fw-template-erlang (0.1.21) ...
```

That's it.

# Next steps #

Check out the [fw-template-erlang walkthrough](FwTemplateErlangWalkthrough.md).

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