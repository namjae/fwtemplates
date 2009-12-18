#! /bin/sh

cd .. &&                                                \
eval `fw-exec template/javascript/load-config` &&       \
cd tests

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

atexit () \
{
  atexit="$1 $atexit"
  trap 'set +e; eval $atexit' EXIT
}

cleanup_empty () \
{
  if test ! -s "$1"
    then
      rm -f "$1"
    fi
}

guess_port_number () \
{
  local count=${2-"1"}
  local guess

  if test $count -gt 10
    then
      echo "cannot guess open port number" 1>&2
      exit 1
    fi

  guess=$((1025 + (($count * $$) % 32771)))
  if nc -z 127.0.0.1 $guess </dev/null >/dev/null 2>/dev/null
    then
      guess_port_number "$1" $(($count + 1))
    else
      eval $1=$guess
    fi
}

run_jscoverage_server () \
{
  if which jscoverage-server >/dev/null 2>/dev/null
    then
        if test -d jscoverage 
          then
            rm -f jscoverage/*
          else
            mkdir jscoverage
          fi
        guess_port_number jscoverage_port
        jscoverage-server --document-root="`(cd ..; pwd)`" --port=$jscoverage_port --report-dir="`pwd`/jscoverage" &
        sleep 1
        eval atexit "'jscoverage-server --shutdown --port=$jscoverage_port >/dev/null 2>/dev/null;'"
        eval atexit "'rm -rf \"`pwd`\"/jscoverage;'"
        eval $1=\"http://127.0.0.1:\$jscoverage_port\"
    else
        eval $1=\"file://`(cd ..; pwd)`\"
    fi
}

run_xvfb () \
{
  Xvfb "$FW_TEMPLATE_JAVASCRIPT_XVFB_DISPLAY" 2>/dev/null &
  eval atexit "'kill $! 2>/dev/null;'"
  DISPLAY="$FW_TEMPLATE_JAVASCRIPT_XVFB_DISPLAY"
  export DISPLAY
}

run_jstestdriver () \
{
  if which jstestdriver >/dev/null 2>/dev/null
    then
      case "x$FW_TEMPLATE_JAVASCRIPT_USE_XVFB" in
        xauto)
          if which Xvfb >/dev/null 2>/dev/null
            then
              if test "x$DISPLAY" = x
                then
                  run_xvfb
                fi
            fi
          ;;
        xyes)
          run_xvfb
          ;;
        *)
          ;;
      esac

      parentdir=`(cd ..; pwd)`

      cat <<EOD >jsTestDriver.conf
{ "load" : [ "$parentdir/src/${FW_PACKAGE_NAME}-uncompressed.js", 
             "$parentdir/tests/*.jstestdriver.js"
             $FW_TEMPLATE_JAVASCRIPT_CONF_EXTRA ] }
EOD
      atexit 'rm -f jsTestDriver.conf;'

      case "x$FW_TEMPLATE_JAVASCRIPT_PORT" in
        xauto)
          guess_port_number port
          ;;
        *)
          port="$FW_TEMPLATE_JAVASCRIPT_PORT"
          ;;
      esac

      jstestdriver --captureConsole                             \
                   --port "$port"                               \
                   --browser "$FW_TEMPLATE_JAVASCRIPT_BROWSER"  \
                   --tests "$1" > "${1}.jstestdriver.test.out" 2>&1 
      cleanup_empty "${1}.jstestdriver.test.out" 
      egrep '^Total.*Fails: 0; Errors: 0' "${1}.jstestdriver.test.out" >/dev/null 2>&1
    else
      echo "jstestdriver not found, skipping test" 1>&2
      exit 77
    fi
}

run_browsers () \
{
  local browser
  local testspec=$1
  shift
  local port=$1
  shift
  for browser in "$@"
    do
      # nc is sometimes "bsd flavor", sometimes "traditional" ...
      # perl is always perl :)
      perl -MIO::Socket -e '
        $|=1;
        $s = new IO::Socket::INET (LocalHost => "127.0.0.1",
                                   LocalPort => $ARGV[0],
                                   Proto => "tcp",
                                   Listen => 1,
                                   Reuse => 1) or die;
        $ns = $s->accept ();
        while (defined ($_ = <$ns>))
          {
            print $_;
          }' "$port" > "qunit-test-output-capture-$$.txt" 2>/dev/null &
      ncpid=$!
      eval atexit "'kill $! 2>/dev/null;'"

      eval atexit "'rm -f qunit-test-output-capture-$$.txt;'"

      ucfirst=`perl -e '$ARGV[0] =~ s/^(.)/\U$1/; print $ARGV[0]' "$browser"`
      eval PATH=\"\$PATH:/Applications/\$ucfirst.app/Contents/MacOS/\" \$browser \$FW_TEMPLATE_JAVASCRIPT_BROWSER_ARGS_${browser} \"\${jscoverage_server_location}/tests/qunit-test-\$\$.html\" \&
      eval atexit "'kill $! 2>/dev/null;'"

      while test ! -s "qunit-test-output-capture-$$.txt"
        do
          kill -0 $ncpid >/dev/null 2>/dev/null
          sleep 1
        done

      if which xwd >/dev/null 2>/dev/null
        then
          xwd -display $DISPLAY -root -out "$testspec"-"$browser".xwd.test.out
        fi

      if test -d jscoverage
        then
          if test -d jscoverage-"$testspec"-"$browser"
            then
              rm -rf jscoverage-"$testspec"-"$browser"
          fi
          mv jscoverage jscoverage-"$testspec"-"$browser"
      fi

      egrep '^GET /0/' "qunit-test-output-capture-$$.txt" >/dev/null 2>&1
    done
}

run_qunit () \
{
  local port
  local parentdir

  if which nc >/dev/null 2>/dev/null
    then
      case "x$FW_TEMPLATE_JAVASCRIPT_USE_XVFB" in
        xauto)
          if which Xvfb >/dev/null 2>/dev/null
            then
              if test "x$DISPLAY" = x
                then
                  run_xvfb
                fi
            fi
          ;;
        xyes)
          run_xvfb
          ;;
        *)
          ;;
      esac

      run_jscoverage_server jscoverage_server_location

      case "x$FW_TEMPLATE_JAVASCRIPT_PORT" in
        xauto)
          guess_port_number port
          ;;
        *)
          port="$FW_TEMPLATE_JAVASCRIPT_PORT"
          ;;
      esac

      cat <<EOD >"qunit-test-$$.html"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" 
                    "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<script type="text/javascript" src="$jscoverage_server_location/tests/jquery-1.3.2.js"></script>
<script type="text/javascript" src="$jscoverage_server_location/src/${FW_PACKAGE_NAME}-uncompressed.js"></script>
<script type="text/javascript" src="$jscoverage_server_location/tests/$1"></script>
</head>
<body>
<script type="text/javascript" src="$jscoverage_server_location/tests/testrunner-2009-09-13.js"></script>
<script>
QUnit.done = function (failures, total) {
  if (window.jscoverage_report) {
    jscoverage_report ();
  };

  jQuery.getJSON ("http://localhost:$port/" + failures + "/&callback=?", function (data) { });
}
</script>
 <h1>QUnit example</h1>
 <h2 id="banner"></h2>
 <h2 id="userAgent"></h2>
 <ol id="tests"></ol>
 <div id="main"></div>
</body>
</html>
EOD
      eval atexit "'rm -f qunit-test-$$.html;'"

      run_browsers "$1" $port $(perl -e 'print join " ", split /,/, $ARGV[0]' "$FW_TEMPLATE_JAVASCRIPT_BROWSER")
    else
      echo "nc not found, skipping test" 1>&2
      exit 77
    fi
}

set -e
command="$1"
shift

trap 'exit 1' INT QUIT TERM 

case "$command" in
   ./qunit-*.js)
     testspec=${command#./}
     run_qunit "$testspec"
     ;;

   ./jstestdriver-*)
     testspec=${command#./jstestdriver-}

     run_jstestdriver "$testspec"
     ;;
   ./*.js)
     file=${command#./}
     if env CLASSPATH="$LOCAL_CLASSPATH:$CLASSPATH" java org.mozilla.javascript.tools.shell.Main /dev/null >/dev/null 2>&1
       then
         env CLASSPATH="$LOCAL_CLASSPATH:$CLASSPATH" java org.mozilla.javascript.tools.shell.Main "$command" "$@" > "${file}.test.out" 2>&1 
         cleanup_empty "${file}.test.out"
       else
         exit 77
       fi
     ;;
   *)
     "$command" "$@" > "${command}.test.out" 2>&1 
     cleanup_empty "${command}.test.out"
     ;;
esac
