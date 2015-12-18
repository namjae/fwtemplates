# Introduction #

This page will assist you in installing fw-template-javascript.

If you've already installed fw-template-javascript and want to know how to use it,
check out the [walkthrough](FwTemplateJavascriptWalkthrough.md).

# Instructions #

Prerequisites:
  1. [framewerk](FramewerkInstall.md)
  1. working [rhino](http://www.mozilla.org/rhino/) installation.
    * debian: aptitude install rhino
    * os/x (with [fink](http://www.finkproject.org/)): fink install rhino
    * others: ???
  1. [jslint](http://www.jslint.com/lint.html) installed (optional but useful)
    * the template expects an executable named `jslint` to be in the path and do the right thing.  the walkthrough has [more detail](http://code.google.com/p/fwtemplates/wiki/FwTemplateJavascriptWalkthrough#jslint_integration).
  1. [yuicompressor](http://developer.yahoo.com/yui/compressor/) installed (optional but useful)
    * the template expects an executable named `yuicompressor` to be in the path and do the right thing.  the walkthrough has [more detail](http://code.google.com/p/fwtemplates/wiki/FwTemplateJavascriptWalkthrough#yuicompressor_integration).
  1. [jstestdriver](http://code.google.com/p/js-test-driver/) installed (optional but useful)
    * the template expects an executable named `jstestdriver` to be in the path and do the right thing.  the walkthrough has [more detail](http://code.google.com/p/fwtemplates/wiki/FwTemplateJavascriptWalkthrough#jstestdriver_integration).
  1. [netcat](http://netcat.sourceforge.net/) installed (optional but useful)
    * without netcat, qunit tests will be skipped, since netcat provides the infrastructure for extracting the test results from the browser.
    * debian: apt-get install netcat
    * os/x (with [fink](http://www.finkproject.org/)): apt-get install netcat
    * others: ???

Go to the [downloads section](http://code.google.com/p/fwtemplates/downloads/list?can=2&q=fw-template-javascript*.tar.gz&colspec=Filename+Summary+Uploaded+Size+DownloadCount) and grab the latest `.tar.gz` file.

Unpack the tarball, then run configure and make check.
```
# tar -zxf fw-template-javascript-0.0.1.tar.gz 
# cd fw-template-javascript-0.0.1
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
fw-template-javascript-build_0.0.1_i386.deb fw-template-javascript_0.0.1_all.deb
# sudo dpkg -i fw-pkgout/fw-template-javascript_0.0.1_all.deb 
Selecting previously deselected package fw-template-javascript.
(Reading database ... 49610 files and directories currently installed.)
Unpacking fw-template-javascript (from .../fw-template-javascript_0.0.1_all.deb) ...
Setting up fw-template-javascript (0.0.1) ...
```

That's it.

# Next steps #

Check out the [fw-template-javascript walkthrough](FwTemplateJavascriptWalkthrough.md).

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