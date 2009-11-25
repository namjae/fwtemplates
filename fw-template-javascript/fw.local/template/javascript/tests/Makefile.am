templatetestsdir = $(prefix)/share/fw/template/@FW_TEMPLATE_TEMPLATE_TYPE@/tests

dist_templatetests_DATA =               \
  Makefile_dot_am                       \
  Makefile.am.local			\
  jquery-1.3.2.js			\
  testmylib.js				\
  testmylib.jstestdriver.js		\
  testrunner-2009-09-13.js		\
  qunit-testmylib.js

dist_templatetests_SCRIPTS =            \
  js-test-wrapper.sh

noinst_DATA =                           \
  $(dist_templatetests_SCRIPTS:%=.%.script_ok)

install-data-hook:
	find "$(DESTDIR)$(templatetestsdir)" -type f | xargs chmod -w

CLEANFILES =

MAINTAINERCLEANFILES =                  \
  Makefile.in

include $(top_srcdir)/fw/build/automake/check-shell.am
include $(top_srcdir)/fw/build/automake/gnu-make-check.am
