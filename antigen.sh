#!/bin/sh
#
# A utility script to remove all generated files.
#
# Running autogen.sh will be required after running this script since
# the 'configure' script will also be removed.
#
# This script is mainly useful when testing autoconf/automake changes
# and as a part of their development process.
# If there's a Makefile, then run the 'distclean' target first (which
# will also remove the Makefile).
if test -f Makefile; then
  make distclean
fi
# Remove all tar-files (assuming there are some packages).
rm -f *.tar.* *.tgz
# Also remove the autotools cache directory.
rm -Rf autom4te.cache m4
# Remove rest of the generated files.
rm -f Makefile.in aclocal.m4 compile configure config.h.in config.status depcomp install-sh missing ltmain.sh libtool .built .configured configure.scan .prepared .version* *~ test-driver
rm -fr config.guess config.sub build-aux
find . -name Makefile.in -exec rm -f {} \;
find . -name \*~ -exec rm -f {} \;
host_os=`uname -s`
if [ "$host_os" = "Darwin" -o  "$host_os" = "FreeBSD" ]; then
	echo "Rebuild tags, please wait ..."
	/Applications/BBEdit.app/Contents/Helpers/ctags --excmd=number --tag-relative=no --fields=+a+m+n+S -R `pwd`
fi
