AC_DEFUN([FW_TEMPLATE_JAVA_MAVEN],
[
  AC_CHECK_PROG([JAVAC],[javac],[javac],[echo])
  if test "x$JAVAC" = xecho
    then
      AC_MSG_ERROR([cannot find javac])
      exit 1
    fi

  AC_CHECK_PROG([MVN],[mvn],[mvn],[echo])
  if test "x$MVN" = xecho
    then
      AC_MSG_ERROR([cannot find maven])
      exit 1
    fi
])
