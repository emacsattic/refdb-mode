## Process this file with automake to produce Makefile.in
lisp_LISP = ris.el refdb-mode.el

sysconf_DATA = refdb-mode-config.el

docdir = $(datadir)/doc/$(PACKAGE)-$(VERSION)
doc_DATA = refdb-mode-manual.pdf refdb-mode-manual/*

info_TEXINFOS = refdb-mode.texi

EXTRA_DIST = $(lisp_LISP) $(doc_DATA) $(manual_DATA) refdb-mode-manual.xml refdb-mode-manual-stripped.xml refdb-mode.texi refdb-mode-config.el.in autogen.sh manual-fo.xsl striptable.pl

MAINTAINERCLEANFILES = $(doc_DATA) refdb-mode-manual.fo refdb-mode-manual-stripped.xml refdb-mode.texi
CLEANFILES = refdb-mode-config.el

fosheet="manual-fo.xsl"

htmlsheet="http://docbook.sourceforge.net/release/xsl/current/html/chunk.xsl"

all: refdb-mode-config.el refdb-mode-manual.pdf refdb-mode-manual/* refdb-mode.texi

refdb-mode-config.el: refdb-mode-config.el.in
	sed 's%<myrtfviewer>%$(myrtfviewer)%' < $(srcdir)/refdb-mode-config.el.in | \
	sed 's%<mypsviewer>%$(mypsviewer)%' | \
	sed 's%<mypdfviewer>%$(mypdfviewer)%' | \
	sed 's%<mygnumake>%$(mygnumake)%' | \
	sed 's%<myshell>%$(myshell)%' | \
	sed 's%<sysconfdir>%$(sysconfdir)%' > refdb-mode-config.el

refdb-mode-manual.pdf: refdb-mode-manual.xml
	xsltproc --param fop.extensions 1 --stringparam funcsynopsis.style ansi $(fosheet) refdb-mode-manual.xml > refdb-mode-manual.fo
	fop -fo refdb-mode-manual.fo -pdf refdb-mode-manual.pdf

refdb-mode-manual/*: refdb-mode-manual.xml
	rm -rf refdb-mode-manual/*
	mkdir -p refdb-mode-manual
	xsltproc --stringparam funcsynopsis.style ansi --stringparam html.stylesheet manual.css -o refdb-mode-manual/ $(htmlsheet) refdb-mode-manual.xml
	cp manual.css refdb-mode-manual

# the stripped version of the manual is required because docbook2texi cannot
# handle complex tables
refdb-mode-manual-stripped.xml: refdb-mode-manual.xml
	./striptable.pl < refdb-mode-manual.xml > refdb-mode-manual-stripped.xml

refdb-mode.texi: refdb-mode-manual-stripped.xml
	@mydb2texi@ --to-stdout refdb-mode-manual-stripped.xml > $@


