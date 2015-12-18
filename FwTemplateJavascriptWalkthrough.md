

# Introduction #

fw-template-javascript is the framewerk javascript development template.  It provides a few extras above the bare-bones script template that are useful for javascript development:
  * [jslint](http://www.jslint.com/lint.html) integration
  * [yuicompressor](http://developer.yahoo.com/yui/compressor/) integration
  * rules to drive the javascript shell for writing tests
    * [rhino](http://www.mozilla.org/rhino/) tests
    * [jstestdriver](http://code.google.com/p/js-test-driver/) tests
    * [qunit](http://docs.jquery.com/QUnit) tests
      * with [jscoverage](http://siliconforks.com/jscoverage/) coverage analysis

This walkthrough demonstrates fw-template-javascript.

# Prerequisites #

[fw-template-javascript installed](FwTemplateJavascriptInstall.md)

It's very helpful to have done the [framewerk walkthrough](FramewerkWalkthrough.md).

# Details #

## Initialize the project ##

First, set up the project with fw-init [in the usual way](FramewerkWalkthrough#Initialize_the_project.md).
```
% env CVSROOT="YOURCVSROOT" fw-init --name myproject --template javascript --revision cvs
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
A src/mylib.js
A tests/.cvsignore
A tests/Makefile.am.local
A tests/qunit-testmylib.js
A tests/testmylib.js
A tests/testmylib.jstestdriver.js
```

## Anatomy of the top level ##

The root directory of the project now looks like:
```
% ls
AUTHORS  ChangeLog          NEWS    bootstrap*          fw@        src/
CVS/     Makefile.am.local  README  configure.ac.local  fw-pkgin/  tests/
```
Here's a breakdown:
  * `AUTHORS, CVS, ChangeLog, NEWS, README, bootstrap, fw, fw-pkgin, configure.ac.local, Makefile.am.local`: these have the same meanings as in [other framewerk templates](FramewerkWalkthrough#Anatomy_of_the_top_level.md).
  * `src, tests`: Javascript source code (.js) is placed in `src/`, and unit tests in `tests/`.

## Configure the project ##

As with [other framewerk templates](FramewerkWalkthrough#Configure_the_project.md), `fw-pkgin/config` is used to configure the project.
```
% cat fw-pkgin/config
# The FW_PACKAGE_MAINTAINER field is populated with the 
# environment variable FW_PACKAGE_DEFAULT_MAINTAINER if non-empty

FW_PACKAGE_NAME="myproject"
FW_PACKAGE_VERSION="0.0.0"
FW_PACKAGE_MAINTAINER="Paul Mineiro <paul-fw@mineiro.com>"
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
FW_PACKAGE_SUGGESTS=""

FW_PACKAGE_BUILD_DEPENDS=""
FW_PACKAGE_BUILD_CONFLICTS=""

# whether js-test-wrapper.sh should use Xvfb to provide X-windows to 
# browsers invoked during testing.  valid choices are yes, no, or auto.
# auto will start Xvfb if the DISPLAY environment variable is not set.
FW_TEMPLATE_JAVASCRIPT_USE_XVFB="auto"

# if Xvfb is invoked, what display number should be used
FW_TEMPLATE_JAVASCRIPT_XVFB_DISPLAY=":1"

# if jstestdriver or netcat is invoked, what port number should be used
# should either be an integer, or auto.  auto attempts to guess an
# unused port.
FW_TEMPLATE_JAVASCRIPT_PORT="auto"

# if jstestdriver or qunit is invoked, what browsers should be used.  
# should be a list of comma seperated list of browser executable names.
FW_TEMPLATE_JAVASCRIPT_BROWSER="firefox"

# extra per-browser arguments.  for example, uncomment to instruct firefox 
# to use the profile called testing, which you should have previously
# set up with the profile manager
#FW_TEMPLATE_JAVASCRIPT_BROWSER_ARGS_firefox="-P testing"

# if jstestdriver is invoked, a jsTestDriver.conf is created by
# js-test-wrapper.sh which loads src/@FW_PACKAGE_NAME@-uncompressed.js 
# and tests/*.jstestdriver.js .  you can load additional files by indicating 
# a comma-prefixed, comma-seperated list of JSON strings 
# (so you should single quote the entire variable and then 
# double-quote the individual paths)
FW_TEMPLATE_JAVASCRIPT_CONF_EXTRA=''
```

The extra configuration variables above the basic template are related to controlling the testing process:
  * `FW_TEMPLATE_JAVASCRIPT_USE_XVFB`: whether or not to start a [Xvfb](http://en.wikipedia.org/wiki/Xvfb) server when invoking browsers for testing.  The default is "auto", which will start Xvfb if the `DISPLAY` environment variable is not set.
    * **Note**: if you utilize firefox under Xvfb (e.g., on a remote development machine or local vmware image), you'll probably want to [toggle the about:config browser.sessionstore.enabled variable to false](http://startupmeme.com/the-coolest-firefox-aboutconfig-tricks/), in order to avoid firefox popping up a prompt under the Xvfb and hanging forever.
  * `FW_TEMPLATE_JAVASCRIPT_XVFB_DISPLAY`: what display to use if invoking Xvfb.
  * `FW_TEMPLATE_JAVASCRIPT_PORT`: what port to use if invoking jstestdriver or netcat.  The default is "auto", which will attempt to find an unused port.
  * `FW_TEMPLATE_JAVASCRIPT_BROWSER`: a comma separated list of browser executables to invoke for testing.  these have to be accessible to the local machine.
  * `FW_TEMPLATE_JAVASCRIPT_CONF_EXTRA`: additional JSON appended to the generated [jsTestDriver.conf](http://code.google.com/p/js-test-driver/wiki/ConfigurationFile) file.
  * `FW_TEMPLATE_JAVASCRIPT_BROWSER_ARGS_firefox`, `FW_TEMPLATE_JAVASCRIPT_BROWSER_ARGS_Safari`, etc.: per-browser command line arguments for qunit testing

## Build the project ##

Build the project [the usual way](FramewerkWalkthrough#Build_the_project.md),
```
% ./bootstrap && ./build
```

### javascript shell integration ###

fw-template-javascript expects to be able to invoke a javascript shell via the following command
```
java org.mozilla.javascript.tools.shell.Main FILENAME
```
[rhino](http://www.mozilla.org/rhino/) is what I use to satisfy this requirement.  Fink OS/X users will have to set the CLASSPATH environment variable to find their installed rhino, e.g.,
```
CLASSPATH=$(cat /sw/share/java/classpath); export CLASSPATH
```
Centos (all redhat?) users can use build-classpath to set the CLASSPATH environment variable
```
CLASSPATH=$(build-classpath rhino); export CLASSPATH
```

### jslint integration ###

fw-template-javascript expects an executable called `jslint` to be in the path, otherwise it prints a warning message and skips jslint checks.  If you are using the [rhino command line version](http://www.jslint.com/rhino/index.html) then a script like
```
#! /bin/sh

if which build-classpath >/dev/null 2>/dev/null
  then
    # redhat
    LOCAL_CLASSPATH=$(build-classpath rhino)
  else 
    if test -f /sw/share/java/classpath
      then
        # fink os/x
        LOCAL_CLASSPATH=$(cat /sw/share/java/classpath)
      fi
  fi

# ubuntu just appears to work without anything special ...

CLASSPATH="$LOCAL_CLASSPATH:$CLASSPATH" java org.mozilla.javascript.tools.shell.Main /PATH/TO/jslint.js "$@"
```
is sufficient.

### yuicompressor integration ###

fw-template-javascript expects an executable called `yuicompressor` to be in the path, otherwise it prints a warning message and does identity (i.e., no) compression of javascript.  A script like
```
#! /bin/sh

java -jar /PATH/TO/yuicompressor-2.4.2.jar "$@"
```
is sufficient.

### jstestdriver integration ###

fw-template-javascript expects an executable called `jstestdriver` to be in the path, otherwise it prints a warning message and skips any jstestdriver based tests.  A script like
```
#! /bin/sh

java -jar /PATH/TO/JsTestDriver-1.0b.jar "$@" 
```
is sufficient.

### jscoverage integration ###

fw-template-javascript expects an executable called `jscoverage-server` to be in the path, otherwise it will not generate coverage reports for qunit tests.

## Anatomy of src/ ##

The `src/` directory should contain something like
```
% ls src
CVS/      Makefile.am@       Makefile.in  myproject-uncompressed.js
Makefile  Makefile.am.local  mylib.js     myproject.js
```
Here's the breakdown:
  * `CVS`: revision control specific
  * `Makefile.in, Makefile`: generated by automake/autoconf
  * `Makefile.am`: a link to the Makefile.am installed with fw-template-javascript
  * `Makefile.am.local`: this is where you can put any additional (auto)make commands beyond what is supplied by the template.
  * `mylib.js`: simple example javascript source code that you might have written
  * `myproject-uncompressed.js`: all the javascript source code files concatenated together
    * by default the order of concatenation is whatever order the [wildcard function](http://www.gnu.org/software/autoconf/manual/make/Wildcard-Function.html#Wildcard-Function) in [gnu make](http://www.gnu.org/software/make/) returns things in, but you can change that if order matters.
  * `myproject.js`: compressed version of `myproject-uncompressed.js`
    * typically you serve the compressed javascript for efficiency, but when you are debugging you serve the uncompressed version for sanity.

### src/Makefile.am.local ###

`src/Makefile.am.local` is initialized with some reasonable rules.

```
% cat src/Makefile.am.local 
# put whatever (auto)make commands here, they will be included from Makefile.am
#
pkglibdir=$(libdir)/@FW_PACKAGE_NAME@

pkglib_DATA =                           \
  @FW_PACKAGE_NAME@.js                  \
  @FW_PACKAGE_NAME@-uncompressed.js

jsfiles := $(filter-out $(pkglib_DATA), $(wildcard *.js))

@FW_PACKAGE_NAME@-uncompressed.js: $(jsfiles)
        @cat /dev/null $^ > $@

check_DATA =                            \
  $(patsubst %.js, .%.js_ok, $(jsfiles))

CLEANFILES +=                           \
  $(pkglib_DATA)

EXTRA_DIST +=                           \
  $(jsfiles)                            \
  $(pkglib_DATA)
```

Basically:
  * check each individual js file with jslint
  * combine all the js files into a single combined uncompressed file
  * compressed the combined uncompressed file
  * install the compressed and uncompressed combined javascript files into /prefix/lib/PACKAGENAME

## Anatomy of tests/ ##

```
% ls tests/
CVS/          Makefile.am.local  js-test-wrapper.sh@  testmylib.jstestdriver.js
Makefile      Makefile.in        qunit-testmylib.js   testrunner-2009-09-13.js@
Makefile.am@  jquery-1.3.2.js@   testmylib.js
```

`tests/js-test-wrapper.sh` is used to run the tests.  It
recognizes the following special test types:
  1. `qunit-*.js`: a qunit test that should be run in a browser harness.
  1. `jstestdriver-TESTSET`: a jstestdriver set of tests
  1. `something.js`: an ordinary javascript test to be invoked in the javascript shell

An example of each type of test is provided in the `tests/` directory.  They are invoked via elements in the `TESTS` variable in `tests/Makefile.am.local`.

```
% cat tests/Makefile.am.local
TESTS =                 \
  jstestdriver-all      \
  testmylib.js          \
  qunit-testmylib.js
```

**Note**: if you utilize firefox under Xvfb (e.g., on a remote development machine or local vmware image), you'll probably want to [toggle the about:config browser.sessionstore.enabled variable to false](http://startupmeme.com/the-coolest-firefox-aboutconfig-tricks/), in order to avoid firefox popping up a prompt under the Xvfb and hanging forever.

### QUnit Test ###

`qunit-testmylib.js` is an example QUnit test.
```
% cat tests/qunit-testmylib.js
$(document).ready (function () { 
  test ("mytestcase", function () { 
     expect (1);
     equals (MyLib.dude (0), "my car");
  });
});
```
In this case we are asserting that return value of `MyLib.dude (0)` is `"my car"`.  This test runs in the browsers indicated by the [configuration settings](#Configure_the_project.md), optionally under Xvfb, and reports the pass/fail status via a jsonp request to a netcat invoked by the test driver.  Check out `js-test-driver.sh` for details.

If xwd is present, the file `qunit-testmylib.js-BROWSERNAME.xwd.test.out` contains an X window dump which might prove useful in analyzing test failures.  You can view it under X windows via
```
% xwud -in qunit-testmylib.js-firefox.xwd.test.out
```

If jscoverage-server is present, the directory `jscoverage-qunit-testmylib.js-BROWSERNAME` will contain a coverage report.

### JsTestDriver Test ###

JsTestDriver cannot perform asynchronous testing, which limits its utility.  However it is included here because I did the work to integrate it before realizing that it doesn't support asynchronous testing.  `testmylib.jstestdriver.js` is the example test
```
% cat tests/testmylib.jstestdriver.js
MyTestCase = TestCase ("MyTestCase");

MyTestCase.prototype.testA = function () {
  expectAsserts (1);
  assertSame ("my car", MyLib.dude (0));
};
```
In this case the TESTS entry in the Makefile.am is actually `jstestdriver-all`, which means "invoke all jstestdriver tests".  If more granular reporting is desired, a [test specification](http://code.google.com/p/js-test-driver/wiki/CommandLineFlags#--tests) like `jstestdriver-MyTestCase` would invoke only the `MyTestCase` cases, or even `jstestdriver-MyTestCase.testA` for more granular specification.

### Rhino Test ###

`testmylib.js` is an example test.  It leverages [rhino's load() function](https://developer.mozilla.org/en/Rhino_Shell) to import the code being tested and then exercises it.
```
% cat tests/testmylib.js
load ('../src/mylib.js');

(function (a) {
   if (MyLib.dude (0) === "my car")
     {
       quit ();
     }
   else
     {
       quit (1);
     }
}) (arguments);
```

## Making a package ##

Making a package is done [the usual way](FramewerkWalkthrough#Making_a_package.md), as is [releasing a package](FramewerkWalkthrough#Releasing_a_package.md).

# Conclusion #

Congratulations!  You've made it through the fw-template-javascript walkthrough.
Hopefully you found it helpful.