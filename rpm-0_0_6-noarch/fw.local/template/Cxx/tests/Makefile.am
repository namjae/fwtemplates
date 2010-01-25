templatetestsdir = $(prefix)/share/fw/template/@FW_TEMPLATE_TEMPLATE_TYPE@/tests

dist_templatetests_DATA =               \
  Makefile.am.local			\
  testprog.cc

install-data-hook:
	find "$(DESTDIR)$(templatetestsdir)" -type f | xargs chmod -w

CLEANFILES =

MAINTAINERCLEANFILES = 			\
  Makefile.in

include $(top_srcdir)/fw/build/automake/check-shell.am
