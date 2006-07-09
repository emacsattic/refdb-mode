#!/usr/bin/perl

# helper script to cut out the table of the refdb-mode manual before
# creating the texi file

$skip = 0;

while (<>) {
    if (/<table/) {
	# found table start
	$skip = 1;
    }
    elsif (/<\/table>/) {
	# found table end
	$skip = 0;
	# next avoids that the closing tag is printed
	next;
    }
    
    if (!$skip) {
	print $_;
    }
}

exit 0;
