templatesrcdir = $(prefix)/share/fw/template/@FW_TEMPLATE_TEMPLATE_TYPE@/src

dist_templatesrc_DATA =               	\
  Makefile_dot_am			\
  Makefile.am.local			\
  mylib.cc				\
  mylib.hh				\
  myprog.cc

install-data-hook:
	find "$(DESTDIR)$(templatesrcdir)" -type f | xargs chmod -w

MAINTAINERCLEANFILES = 			\
  Makefile.in
