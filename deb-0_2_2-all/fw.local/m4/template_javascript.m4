AC_DEFUN([FW_TEMPLATE_JAVASCRIPT],
[
  AC_CHECK_PROG([JSLINT],[jslint],[jslint],[echo])
  if test "x$JSLINT" = xecho
    then
      AC_MSG_WARN([cannot find jslint, skipping jslint checks])
    fi

  AC_CHECK_PROG([YUICOMPRESSOR],[yuicompressor],[yuicompressor],[cat])
  if test "x$YUICOMPRESSOR" = xcat
    then
      AC_MSG_WARN([cannot find yuicompressor, disabling compression])
    fi

  AC_CHECK_PROG([JSTESTDRIVER],[jstestdriver],[jstestdriver],[])
  if test "x$JSTESTDRIVER" = x
    then
      AC_MSG_WARN([cannot find jstestdriver, skipping jstestdriver tests])
    fi

  AC_CHECK_PROG([NETCAT],[nc],[nc],[])
  if test "x$NETCAT" = x
    then
      AC_MSG_WARN([cannot find nc, skipping qunit tests])
    fi

  AC_CHECK_PROG([JSCOVERAGE],[jscoverage-server],[jscoverage-server],[])
  if test "x$JSCOVERAGE" = x
    then
      AC_MSG_WARN([cannot find jscoverage-server, not generating coverage reports])
    fi

  AC_MSG_CHECKING([for working rhino installation])

  if java org.mozilla.javascript.tools.shell.Main /dev/null >/dev/null 2>&1
    then
      AC_MSG_RESULT([yes])
    else
      AC_MSG_RESULT([no])
      AC_MSG_WARN([cannot find working rhino installation, skipping javascript tests])
    fi

  AC_CONFIG_FILES([src/Makefile
                   tests/Makefile])
])
