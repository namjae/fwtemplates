# Introduction #

fw-template-erlang is the framewerk Erlang template.  It features:
  * [cover](http://erlang.org/doc/man/cover.html) integration with 'make check'
  * [edoc](http://www.erlang.org/doc/apps/edoc/index.html) integration for documentation.
  * [eunit](http://svn.process-one.net/contribs/trunk/eunit/doc/index.html) integration with 'make check'
  * generates an [otp compliant application file](http://www.erlang.org/doc/design_principles/applications.html#7.3) by scanning the source code
  * standard make rules to drive the erlang compiler
  * [erlrc](http://code.google.com/p/erlrc) integration

This walkthrough demonstrates fw-template-erlang.

# Prerequisites #

[fw-template-erlang installed](FwTemplateErlangInstall.md)

It's very helpful to have done the [framewerk walkthrough](FramewerkWalkthrough.md).

# Details #

## Initialize the project ##

First, set up the project with fw-init [in the usual way](FramewerkWalkthrough#Initialize_the_project.md).
```
% env CVSROOT="YOURCVSROOT" fw-init --name myproject --template erlang --revision cvs
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
A doc/.cvsignore
A doc/Makefile.am.local
A doc/overview.edoc
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
A src/myapp.erl
A tests/.cvsignore
A tests/Makefile.am.local
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
  * `src, tests`: Erlang source code (.erl, .hrl) is placed in `src/`, and unit tests in `tests/`.

## Configure the project ##

As with [other framewerk templates](FramewerkWalkthrough#Configure_the_project.md), `fw-pkgin/config` is used to configure the project.  However some new variables are available with this template.
```
% cat fw-pkgin/config
# The FW_PACKAGE_MAINTAINER field is populated with the
# environment variable FW_PACKAGE_DEFAULT_MAINTAINER if non-empty

FW_PACKAGE_NAME="myproject"
FW_PACKAGE_VERSION="0.0.0"
FW_PACKAGE_MAINTAINER="root <root@ec2-67-202-48-148.compute-1.amazonaws.com>"
FW_PACKAGE_SHORT_DESCRIPTION="A short description."
FW_PACKAGE_DESCRIPTION=`cat README`
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

# uncomment and set manually if autodetection of modules is incorrect
# FW_ERL_APP_MODULES=""

# uncomment and set manually if autodetection of registered processes is incorrect
# FW_ERL_APP_REGISTERED=""

# uncomment and set manually if autodetection of start module is incorrect
# FW_ERL_APP_START_MODULE=""

# uncomment to define start args to the start module.  should be an erlang
# expression which evaluates to a list.
# FW_ERL_APP_START_ARGS="[]"

# uncomment if the module line being generated is incorrect and you want
# to override it.
# FW_ERL_APP_MOD_LINE="{ mod, { $FW_ERL_APP_START_MODULE, $FW_ERL_APP_START_ARGS } },"

# uncomment to define the application environment variables. should be an
# erlang expression which evaluates to a list.
# FW_ERL_APP_ENVIRONMENT="[]"
```
The extra variables are mostly related to creation of an
[otp compliant application file](http://www.erlang.org/doc/design_principles/applications.html#7.3).  This mostly just works but in case it doesn't
you have override control via these variables.

## Build the project ##

Build the project [the usual way](FramewerkWalkthrough#Build_the_project.md),
```
% ./bootstrap && ./build
```

### Makefile.otp ###

Now there should be a `Makefile.otp` in the root directory of the project.[[2](#2.md)]
```
% cat Makefile.otp
erlappdir="@ERLAPPDIR@"
erlappsrcdir="$(erlappdir)/src"
erlappebindir="$(erlappdir)/ebin"
erlappprivdir="$(erlappdir)/priv"
erlappincludedir="$(erlappdir)/include"
erldocdir="@ERLDOCDIR@"

SUFFIXES = .beam .erl .P

ERLCFLAGS ?= +debug_info -pa ../src -I ../src

# put an overly broad dependency on .hrl for now, 
# which will cause some spurious extra compiles
# TODO: depgen for erlang

%.beam: %.erl $(wildcard *.hrl)
        erlc ${ERLCFLAGS} ${$*_ERLCFLAGS} $<

%.P: %.erl $(wildcard *.hrl)
        erlc +"'P'" ${ERLCFLAGS} ${$*_ERLCFLAGS} $<

.%.beam_ok: %.beam
        dialyzer -c $*.beam
        touch $@

.%.erl_ok: %.erl
        dialyzer --src -c $*.erl
        touch $@

.dialyzer_ok: $(wildcard *.erl)
        dialyzer ${DIALYZERFLAGS} --src -c .
        touch $@

CLEANFILES +=                   \
  $(wildcard *.P)               \
  $(wildcard *.beam)            \
  $(wildcard .*.beam_ok)        \
  $(wildcard .*.erl_ok)         \
  .dialyzer_ok                  \
  erl_crash.dump

include $(top_srcdir)/fw/build/automake/check-shell.am
include $(top_srcdir)/fw/build/automake/gnu-make-check.am
```

Notes:
  * The standard directory targets erlappsrc, erlappebin, erlapppriv, and erlappinclude are defined, corresponding to the [otp application directory structure](http://www.erlang.org/doc/design_principles/applications.html#7.4).
  * Automatic rules for building a `.beam` (or a `.P`) from the corresponding `.erl` file.  These are parametrized by ${ERLCFLAGS} globally and ${$`*_`ERLCFLAGS} per target.  In other words, foo.beam can be built from foo.erl, and the compilation line would be
```
erlc ${ERLCFLAGS} ${foo_ERLCFLAGS} foo.erl
```
  * Unless otherwise set, ERLCFLAGS defaults to something reasonable.
  * Some rules are defined to drive the dialyzer.

## Anatomy of src/ ##

The `src/` directory should contain something like
```
% ls src
CVS          Makefile.am.local        fw-erl-app-template.app.in  myproject.app
Makefile     Makefile.in              myapp.beam
Makefile.am  fw-erl-app-template.app  myapp.erl
```
Here's the breakdown:
  * `CVS`: revision control specific
  * `Makefile.in, Makefile`: generated by automake/autoconf
  * `Makefile.am`: a link to the Makefile.am installed with fw-template-erlang
  * `Makefile.am.local`: this is where you can put any additional (auto)make commands beyond what is supplied by the template.
  * `fw-erl-app-template.app, fw-erl-template-app.in`: intermediate files in the automatic generation of the otp compliant application file.
  * `myproject.app`: the automatically generated otp compliant application file.
  * `myapp.erl`: simple example application installed with the template
  * `myapp.beam`: compiled version of myapp.erl
  * `myproject.app`: autogenerated otp compliant application file.

### src/myproject.app ###

`src/myproject.app` is autogenerated by scanning source.
```
% cat src/myproject.app
{ application, myproject,
  [ 
    { description, "A short description." }, 
    { vsn, "0.0.0" },
    { modules, [ myapp ] },
    { registered, [ hello_world ] },
    { applications, [ kernel, stdlib   ] },
    { mod, { myapp, [] } },
    { env, [] }
    
  ] 
}.
```
The template assumes that the project contains at most one application and
generates a `.app` file by scanning the contents of `src/`.  By
inspecting `fw-erl-app-template.app.in` you can get an idea of how it works.
```
% cat src/fw-erl-app-template.app.in
{ application, @FW_PACKAGE_NAME@,
  [ 
    { description, "@FW_PACKAGE_SHORT_DESCRIPTION@" },
    { vsn, "@FW_PACKAGE_VERSION@" },
    { modules, [ @FW_ERL_APP_MODULES@ ] },
    { registered, [ @FW_ERL_APP_REGISTERED@ ] },
    { applications, [ kernel, stdlib @FW_ERL_PREREQ_APPLICATIONS@ @FW_ERL_PREREQ_APPLICATIONS_EXTRA@ ] },
    @FW_ERL_APP_MOD_LINE@
    { env, @FW_ERL_APP_ENVIRONMENT@ }
    @FW_ERL_APP_EXTRA@
  ]
}.
```
Some notes:
  * the application named is forced to be the package name.
  * the version is forced to be the package version.
  * the modules are autodetected, but setting FW\_ERL\_APP\_MODULES in `fw-pkgin/config` takes precedence.
  * registered processes are autodetected, but setting FW\_ERL\_APP\_REGISTERED in `fw-pkgin/config` take precedence.
  * FW\_ERL\_PREREQ\_APPLICATIONS is reserved for an attempt to detect dependent applications automatically, but currently does nothing.
  * FW\_ERL\_PREREQ\_APPLICATIONS\_EXTRA is only set via `fw-pkgin/config`.
  * FW\_ERL\_APP\_MOD\_LINE defaults to { mod, { @FW\_ERL\_APP\_START\_MODULE@, @FW\_ERL\_APP\_START\_ARGS@ } }, both of which are individually overridden by values in `fw-pkgin/config`.  in addition if the situation is totally borked, you can set FW\_ERL\_APP\_MOD\_LINE in `fw-pkgin/config` and that takes precedence.
  * FW\_ERL\_APP\_ENVIRONMENT defaults to [.md](.md) but can be set in `fw-pkgin/config`.
  * FW\_ERL\_APP\_EXTRA can be anything you want.  this is a good place to put [included applications directives](http://www.erlang.org/doc/design_principles/included_applications.html#8).
  * to override everything, rm the `src/fw-erl-app-template.app.in` link, write your own file in it's place, and check into revision control.  the template will not link over something that already exists.

### src/Makefile.am.local ###

`src/Makefile.am.local` is initialized with some reasonable rules.

```
% cat src/Makefile.am.local 
# put whatever (auto)make commands here, they will be included from Makefile.am

dist_erlappsrc_DATA =           \
  $(wildcard *.erl)

dist_erlappinclude_DATA =       \
  $(wildcard *.hrl)

erlappebin_SCRIPTS =                                    \
  @FW_PACKAGE_NAME@.app                                 \
  $(patsubst %.erl, %.beam, $(dist_erlappsrc_DATA))

check_DATA =                    \
  .dialyzer_ok
```

Basically:
  * put all `.erl` files into `OTPROOT/application-version/src`
  * put all `.hrl` files into `OTPROOT/application-version/include`
  * make a `.beam` for each `.erl`
  * put `.beam` files into `OTPROOT/application-version/ebin`
  * put `.app` file into `OTPROOT/application-version/ebin`
  * run the dialyzer on all the source files during 'make check'

This last rule is usually the one that requires customization.  DIALYZERFLAGS
can be set to pass flags to the dialyzer.  Sometimes
a custom rule which only analyzes some of the source code is necessary.
Look to Makefile.otp for inspiration.

## Anatomy of tests/ ##

```
% ls tests/
CVS  Makefile.am  Makefile.am.local  Makefile.in  otp-test-wrapper.sh
```

`tests/otp-test-wrapper.sh` is used to run the tests.  It
recognizes tests of the form `module-foo` and interprets that
as a directive to run foo:test/0 and then run coverage analysis on
foo.[[1](#1.md)]  Output is contained in foo.test.out in case of snafu.
Thus
```
% cat tests/Makefile.am.local
TESTS =                 \
  module-myapp
```
runs myapp:test/0 and outputs coverage information.  Tests not of the form
module-foo are executed directly, although artifacts of cover analysis
generated from such tests are attempted to be detected.  Check out
`tests/otp-test-wrapper.sh` if you're curious.

## Making a package ##

Making a package is done [the usual way](FramewerkWalkthrough#Making_a_package.md), as is [releasing a package](FramewerkWalkthrough#Releasing_a_package.md).

# Conclusion #

Congratulations!  You've made it through the fw-template-erlang walkthrough.
Hopefully you found it helpful.

# Addendum #

Here's a summary of interesting changes since this walkthrough was written.

  1. There's a parse transform that is run by default during compilation that adds a -vsn attribute to files that lack one (using FW\_PACKAGE\_VERSION).  This is useful for hot code upgrade.  See Makefile.otp for details.
  1. escript is now [a recognized interpreter](FramewerkWalkthrough#Checking_scripts.md) and causes 'escript -s' to be run.

# Footnotes #

## 1 ##

module:test/0 is the method autogenerated by [eunit](http://svn.process-one.net/contribs/trunk/eunit/doc/index.html), so this counts as
eunit integration (and [cover](http://erlang.org/doc/man/cover.html) integration).

## 2 ##

You do not edit `Makefile.otp` directly; it is included in the Makefiles in `src/` and `tests/`, and you can include it in other Makefiles as necessary.