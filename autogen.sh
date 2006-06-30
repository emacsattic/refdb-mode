#!/bin/sh

echo "@setfilename refdb-mode.info" >refdb-mode.texi
aclocal
automake --add-missing
autoconf
rm refdb-mode.texi
