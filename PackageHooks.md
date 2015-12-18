

# Executive Summary #

Framewerk maps the RPM scriptlet interface into something that looks like the DEB package script model (excepting the absence of "error unwind" calls; which are technically feasible, so maybe someday I should implement them).  The skeleton hooks installed with a new project are hopefully sufficiently outlined to allow quick progress.

# Introduction #

I'm adding RPM support to framewerk.  It turns out, unsurprisingly, the package scripts have different semantics in RPM vs. DEB.  Most people will probably just develop for one or the other so they can write scripts into `fw-pkgin/` that don't work for both, no big deal.  However sometimes cross-packaging hooks need to be written (e.g., automatic [erlrc](http://code.google.com/p/erlrc/) integration into fw-template-erlang [fw-template-erlang](FwTemplateErlangWalkthrough.md)), which is the point of the `make-hook` package method, but now I have to figure it out.

From an [RPM reference](http://fedoraproject.org/wiki/Packaging/ScriptletSnippets) and a [DEB reference](http://www.debian.org/doc/debian-policy/ch-maintainerscripts.html), I cobbled together this understanding.

# Script Correspondence #

## Install ##

| RPM | DEB |
|:----|:----|
|  %pretrans of new package | -   |
| %pre of new package | new-preinst install |
| _new package installed_ | _new package files unpacked_ |
| %post of new package | -   |
| %posttrans of new package | postinst configure most-recently-configured-version |

Note the arguments are different:
  * RPM passes an installation count to scriptlets, and does not pass previous version information.
  * DEB passes a sum type argument to scriptlets, as well as previous version information.

## Updates ##

| RPM | DEB |
|:----|:----|
|  %pretrans of new package | new-prerm failed-upgrade old-version[[2](#2.md)] |
|  %pre of new package | new-preinst upgrade old-version |
| _new package installed_ | _new package files unpacked_ |
| %post of new package | -   |
| %preun of old package | old-postrm upgrade new-version [[1](#1.md)]  |
| _removal of old package_ | _"old but not new" package files removed_ |
| %postun of old package | -   |
| %posttrans of new package | postinst configure most-recently-configured-version |

Correspondence here is sketchy, due to the different models: RPM `%postun` happens after the old package files are removed, whereas DEB `postrm` happens after the new package files are installed but before the old package files are removed.

Again the arguments are different, and the result is more painful here because knowing previous version information is more critical for upgrade than for install (where there is no previous version) or remove (where the current version is the previous version).  Recent versions of RPM can be called from scriptlets but presumably `rpm -q` will return a different result after the _new package installed_ step in the above chain.

## Remove ##

| RPM | DEB |
|:----|:----|
|  %pretrans of old package | -   |
| %preun of old package | prerm remove |
| _removal of old package_ | _package files are removed_ |
| %postun of old package | postrm remove |
| %posttrans of old package | -   |

Correspondence here is really good.

# Framewerk Abstraction #

Right now we have the following files in `fw-pkgin/`:
```
 ls fw-pkgin/pre* fw-pkgin/post* fw-pkgin/s*
fw-pkgin/post-install*  fw-pkgin/pre-install*  fw-pkgin/start*
fw-pkgin/post-remove*   fw-pkgin/pre-remove*   fw-pkgin/stop*
```
The challenge is to interpret these in such a way as to have them mean about the same thing in RPM vs. DEB and not break alot of current packages (which were written prior to RPM support).

Therefore, I'll think I'll make RPM look like DEB.  This basically means decoding the "installation count" argument that RPM provides and use that to emulate the DEB sum type.  In addition I'll have to do something in `%pretrans` to record the old and new versions.

Thus, DEB script semantics continue to be the mapping
  * preinst -> pre-install
  * postinst -> post-install
  * prerm -> pre-remove
  * postrm -> post-remove
which means that you can look for extra arguments that indicate the "exception handling" portions of the DEB package management model.  These arguments will just never be encountered when the project is rendered as an
RPM package (for now anyway; if I feel inspired I could change the rpm package spec to emulate the exception
handling portions of the DEB model).

## Mapped RPM Installation ##

| RPM | Framewerk Mapping |
|:----|:------------------|
|  %pretrans of new package | -                 |
| %pre of new package | pre-install install |
| _new package installed_ | _new package files unpacked_ |
| %post of new package | -                 |
| %posttrans of new package | post-install configure "" |

## Mapped RPM Upgrade ##

| RPM | Framewerk Mapping |
|:----|:------------------|
|  %pretrans of new package | -                 |
|  %pre of new package | (new) pre-remove failed-upgrade old-version && (new) pre-install upgrade old-version |
| _new package installed_ | _new package files unpacked_ |
| %post of new package | -                 |
| %preun of old package | (new) post-remove failed-upgrade old-version [[1](#1.md)]  |
| _removal of old package_ | _"old but not new" package files removed_ |
| %postun of old package | -                 |
| %posttrans of new package | (new) post-install configure previously-installed version |

Yes it's wierd that the argument to pre-remove and post-remove is `failed-upgrade`, but one should be writing one's DEB hooks that way [[1](#1.md), [2](#2.md)].

## Mapped RPM Remove ##

| RPM | Framewerk Mapping |
|:----|:------------------|
|  %pretrans of old package | -                 |
| %preun of old package | pre-remove remove |
| _removal of old package_ | _package files are removed_ |
| %postun of old package | post-remove remove |
| %posttrans of old package | -                 |

# Gory Details #

In framewerk 2.0.1 I implement the hook correspondence with the following spec file hooks:

## %pretrans ##
The %pretrans hook records the currently installed version of the package (if any) to TMPDIR, and renders some of the actual scripts from the package to TMPDIR.  The latter is done because rpm uses the old %preun and %postun hooks on upgrade, whereas we want to use the new ones.
```
%pretrans
set +e
rpm -q "$FW_PACKAGE_NAME" --queryformat '%{VERSION}' | grep -v 'not installed' > \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".old_version
set -e
printf "%s" "$FW_PACKAGE_VERSION" > \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".new_version
cat <<'_RPMEOF' > \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".newpreinst
$preinst
_RPMEOF
chmod +x \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".newpreinst
cat <<'_RPMEOF' > \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".newpostinst
$postinst
_RPMEOF
chmod +x \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".newpostinst
cat <<'_RPMEOF' > \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".newpreremove
$preremove
_RPMEOF
chmod +x \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".newpreremove
cat <<'_RPMEOF' > \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".newpostremove
$postremove
_RPMEOF
chmod +x \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".newpostremove
exit 0
```

## %pre ##

The %pre hook uses the installation count to determine if this is a fresh install, and if so invokes the new pre-install handler; otherwise (for an upgrade) it invokes the new pre-remove handler followed by the new pre-install handler.
```
set -e
if test "\$1" -eq 1
  then
    \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".newpreinst install
  else
    \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".newpreremove failed-upgrade "\`cat \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".old_version\`" && \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".newpreinst upgrade "\`cat \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".old_version\`"
  fi

exit 0
```

## %post ##

%post does not cleanly correspond to the debian hook model, so it is unused, except for a call to ldconfig (just in case).
```
%post -p /sbin/ldconfig
```

## %preun ##

%preun checks the installation count, and if the package is being removed it invokes the old pre-remove hook; otherwise (for an upgrade) it invokes the new post-remove.
```
%preun
set -e
if test "\$1" -eq 0
  then
    cat <<'_RPMEOF' > \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".oldpreremove
$preremove
_RPMEOF
    chmod +x \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".oldpreremove

    \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".oldpreremove remove
  else
    \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".newpostremove failed-upgrade "\`cat \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".new_version\`"
  fi

exit 0
```

## %postun ##

%postun checks the installation count, and if the packaged is being removed it invokes the old post-remove; otherwise (for an upgrade), it does nothing (the %preun handles this case, due to debian defining "post" relative to the installation of the new package; rpm defines "post" relative to removal of the old package).  A call to ldconfig is thrown in for good measure.
```
%postun
set -e
if test "\$1" -eq 0
  then
    cat <<'_RPMEOF' > \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".oldpostremove
$postremove
_RPMEOF
    chmod +x \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".oldpostremove

    \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".oldpostremove remove
    rm -f \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME"*
  else
    true
  fi

/sbin/ldconfig
exit 0
```

## %posttrans ##

%posttrans invokes the configure phase of the post-install hook.  rpm will only call a %posttrans if the package is still installed at the end of the transaction (so package removals do not invoke this, only installs or upgrades).
```
%posttrans
set -e
\${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".newpostinst configure "\`cat \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME".old_version\`"
rm -f \${TMPDIR:=/tmp}/."$FW_PACKAGE_NAME"*
exit 0
```

# Footnotes #

## 1 ##

In the DEB model `new-postrm failed-upgrade old-version` is invoked if `old-postrm upgrade new-version` fails, so one can ensure the new postrm is always called if desired.  The RPM model appears to force using the old `%postun`, but we work around this.

## 2 ##
In the DEB model, `old-prerm upgrade new-version` is invoked first, but if this fails then `new-prerm failed-upgrade old-version` has a chance to "handle the exception".  Since RPM uses the new script for `%pretrans`, I corresponded it with `new-prerm`.  In practice this means `old-prerm upgrade new-version` should just be `exit 1` if pre-remove is to do something non-trivial on upgrade.  Easiest of all: just use pre-install, since the new version is always invoked on upgrade.