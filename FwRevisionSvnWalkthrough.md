# Introduction #

~~fw-revision-svn teaches framewerk how to use subversion for revision control.~~ svn support now included with the base infrastructure of framewerk.

This walkthrough demonstrates fw-revision-svn via the script template.

# Prerequisites #

  1. [framewerk installed](FramewerkInstall.md)
  1. ~~[fw-revision-svn installed](FwRevisionSvnInstall.md)~~
    * now included with the base infrastructure

# Details #

## Initialize the project ##

First, set up the project with fw-init.  **Warning**: this modifies your source code repository, so create a temporary one if that bothers you.
```
% fw-init --name myproject --template script --revision svn --svn_project_path YOUR_SVN_REPOSITORY
```
Here `--svn_project_path` is the novel argument.[[1](#1.md)]
Changing directory into the project,
```
% cd myproject
% svn status
 M     .
A      fw-pkgin
A      fw-pkgin/post-remove
A      fw-pkgin/pre-remove
A      fw-pkgin/Makefile.am.local
A      fw-pkgin/config
A      fw-pkgin/stop
A      fw-pkgin/post-install
A      fw-pkgin/pre-install
A      fw-pkgin/start
A      Makefile.am.local
A      tests
A      tests/Makefile.am.local
A      tests/testmyscript
A      AUTHORS
A      ChangeLog
A      bin
A      bin/Makefile.am.local
A      bin/myscript
A      NEWS
A      configure.ac.local
A      bootstrap
A      README
```
notice svn:ignore properties have been set by the template corresponding to files the template feels should not be under revision control (e.g., for automake build based templates, Makefiles are generated and therefore not checked in).

## Configure the project ##

fw-revision-svn responds to the following configurable variables in
[fw-pkgin/config](FramewerkWalkthrough#Configure_the_project.md) if set.

  * FW\_SUBVERSION\_TAG\_ROOT: set this to repository directory that will contain tags.  For example, [walkenfs](http://code.google.com/p/walkenfs) uses
```
FW_SUBVERSION_TAG_ROOT="https://walkenfs.googlecode.com/svn/tags/"
```

FW\_SUBVERSION\_TAG\_ROOT must be set in order to release packages, since releasing involves tagging.

# Conclusion #

Well that's it.  Generally framewerk is trying to do the same thing no
matter what revision control system you use so if this were a big
walkthrough that would be a red flag.

# Footnotes #

## 1 ##

There are no other arguments, so you might be wondering how to access
a repository with a username and password, such as google code.  Right
now I do this via the svn authentication cache, which I prime with an
initial checkout, e.g.,
```
svn checkout https://fwtemplates.googlecode.com/svn/trunk/ fwtemplates --username paul-google@mineiro.com
```
after which I can use `--svn_project_path https://fwtemplates.googlecode.com/svn/whatever` from fw-init.

So this works but it is lame and the plan is to eventually be able to pass
options to svn from fw-init and also set svn options in `fw-pkgin/config`.