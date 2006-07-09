;;; refdb-mode.el --- Minor mode for RefDB interaction

;; Copyright (C) 2005-2006 Markus Hoenicka

;; Authors: (-1.9)         Michael Smith <smith@sideshowbarker.net>
;;          (1.10-current) Markus Hoenicka <markus@mhoenicka.de>
;; Created: 2003-11-04
;; X-URL: http://refdb.sf.net/
;; Keywords: xml docbook tei bibliography

;; This file is NOT part of GNU emacs.

;; This is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This software is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.


;; -------------------------------------------------------------------
;;; Commentary
;;-------------------------------------------------------------------
;; This package provides a menu-driven Emacs front-end for
;; interacting with RefDB, a reference database and
;; bibliography tool for SGML, XML, and LaTeX/BibTeX documents.
;;
;;   http://refdb.sourceforge.net/
;;
;; -------------------------------------------------------------------
;;; Compatibility
;; -------------------------------------------------------------------
;; `refdb-mode' requires RefDB version 0.9.6 or later.  It has been
;; tested and found to work with the Linux, FreeBSD, Cygwin/X-Windows,
;; and Win32-native "NTEmacs" versions of GNU Emacs 21.3 (the shell
;; commands work best in the latter if you use Cygwin bash)
;;
;; It has also been tested with OSX (Panther) using a build compiled
;; from current Emacs CVS source; some `refdb-mode' problems have been
;; seen with that OSX build that haven't been seen on other platforms.
;;
;; It has not been tested at all with Emacs 19 or with XEmacs, and
;; most likely will not work with those.
;;
;; -------------------------------------------------------------------
;;; Prerequisites
;; -------------------------------------------------------------------
;;
;; refdb-mode is a front-end to the command-line utilities of RefDB.
;; For refdb-mode to work at all, you need a working RefDB
;; installation on your box. The minimum requirement is that the
;; client refdbc is installed on your system and set up to talk to a
;; refdbd server by means of a system-wide or user configuration
;; file. This file must contain the RefDB username and the password,
;; if applicable. The server may run on a remote box.
;;
;; For the administrative functions to work, you also need the refdba
;; client along with a configuration file. Unless refdbd is
;; automatically started as a daemon or runs on a remote box anyway,
;; you can start and stop the server from refdb-mode. To this end,
;; refdbd must be installed locally, including the server control
;; script refdbctl. refdb-mode uses sudo to start refdbd as root. sudo
;; and an appropriate sudoers file must be installed for this feature
;; to work.
;;
;; RefDB deals with a variety of data formats. Notes and style input
;; use XML data, whereas references can be added either as XML or RIS
;; data. Output may be XML, RIS, SGML, HTML, XHTML, bibtex, or plain
;; text. Editing or viewing these data formats is a lot more
;; convenient if you use appropriate major modes. nxml-mode is
;; recommended for XML data, ris-mode for RIS data, PSGML for SGML
;; data. HTML and XHTML can be viewed by setting up Emacs
;; appropriately to use a built-in (w3-mode) or an external web
;; browser.
;;
;; -------------------------------------------------------------------
;;; Installation and Configuration
;; -------------------------------------------------------------------
;;
;; To install and use this package:
;;
;; 1. Either put this file into a directory that's already in your
;;    load path (e.g. /usr/local/share/emacs/site-lisp), or add
;;    whatever directory it's already in to your load path. For example,
;;
;;      (add-to-list 'load-path "c:/my-xml-stuff/elisp/")
;;
;; 2. Add the following to the end of your .emacs file exactly as
;;    shown:
;;
;;      (require 'refdb-mode)
;;
;; 3. You should probably specify a reference database that will be used
;;    by default.  You can do that by adding the following to your .emacs,
;;    with DATABASE replaced by the name of the database to use.
;;
;;      (setq refdb-database "DATABASE")
;;
;; 4. refdb-mode uses the information  in your ~/.refdbcrc, ~/.refdbarc,
;;    and ~/.refdbibrc configuration files to run the RefDB clients
;;    appropriately. Make sure that you set the username and password
;;    entries correctly, as well as the connection information required
;;    to talk to your refdbd server.
;;
;; 5. When working with RIS datasets, it is strongly recommended to use
;;    "Transient mark mode". Adding and updating RIS datasets works on
;;    the current region if a region is defined, otherwise on the whole
;;    buffer. Transient mark mode highlights the current region if there
;;    is one. To use transient mark mode, either use the menu command
;;    Options->Active Region Highlighting (Transient Mark mode) on demand,
;;    or add the following to your ~/.emacs to enable it by default:
;;
;;      (transient-mark-mode t)
;;
;; After you restart Emacs, to enter RefDB minor mode at any time,
;; either:
;;
;;   - choose RefDB Mode from your Emacs Tools menu
;;       or
;;   - type "\M-x refdb-mode<return>" (on MS Windows, that's
;;     "Alt-x refdb-mode" and then hit <Enter>)
;;
;; Starting RefDB mode automatically
;; ---------------------------------
;; There are a couple of ways you can have Emacs put you into RefDB
;; mode automatically.
;; 
;;   - To call up RefDB minor mode automatically depending on
;;     what major mode you're in, add something like the following
;;     example to you .emacs file.
;;
;;       (add-hook 'nxml-mode-hook 'refdb-mode)
;;       (add-hook 'psgml-mode-hook 'refdb-mode)
;;       (add-hook 'sgml-mode-hook 'refdb-mode)
;;       (add-hook 'ris-mode-hook 'refdb-mode)
;;       (add-hook 'bibtex-mode-hook 'refdb-mode)
;;       (add-hook 'refdb-output-mode-hook 'refdb-mode)
;;
;;     That example will call up RefDB mode automatically whenever you
;;     enter nXML mode, SGML/PSGML mode, ris mode, or bibtex-mode.
;;     The last line makes sure that refdb-mode is enabled in the RefDB
;;     plain-text output of commands like 'createdb'; the mode is defined
;;     at the end of this file and will be loaded automatically.
;;
;;   - To always have RefDB mode on, no matter what buffer/mode you're
;;     in, add the following to your .emacs file:
;;
;;       (add-hook 'find-file-hooks 'refdb-mode)
;;
;; To be able to show/hide the menu using a keyboard shortcut,
;; you need to add something like the following to your .emacs file.
;;
;;   (define-key global-map "\C-cb" 'refdb-mode)
;;
;; That example will enable you to use the 'Ctrl-c b' keyboard to
;; toggle RefDB mode on or off.
;;
;; -------------------------------------------------------------------
;;; Customization
;; -------------------------------------------------------------------
;; To customize the behavior of RefDB mode and the contents of the
;; RefDB menu, either:
;;
;;   - choose Customize RefDB Mode from the RefDB menu
;;       or
;;   - type \M-x customize-group<return>refdb<return>
;;
;; -------------------------------------------------------------------
;;; Features
;; -------------------------------------------------------------------
;;
;; ------------------------------
;;;      :: Menu contents ::
;; ------------------------------
;; By default, the RefDB menu provides the following submenus:
;;
;;   Add References
;;   Update References
;;   Delete References
;;   Get References >
;;   Get References on Region >
;;   Pick References
;;   Dump References
;;   Convert References >
;;   Cite References >
;;   Add Notes
;;   Update Notes
;;   Delete Notes
;;   Get Notes >
;;   Get Notes on Region >
;;   Add Links
;;   Delete Links
;;   Customize Data Output >
;;   Select Database >
;;   Show Database Info
;;   ----
;;   Administration >
;;   ----
;;   Show RefDB Message Log
;;   Show Version Information
;;   Info Manual
;;
;; Here are brief descriptions of each menu entry:
;;
;;   Add References
;;     Add references in the current region or buffer to the currently selected
;;     RefDB database.  (Runs 'refdbc -C addref' on current region or buffer.)
;;
;;   Update References
;;     Update references in the current region or bufferin the currently selected
;;     RefDB database.  (Runs 'refdbc -C updateref' on current region or buffer.)
;;
;;   Delete References
;;     Delete references by ID from the currently selected
;;     RefDB database.  (Runs 'refdbc -C deleteref' on current region.)
;;
;;   Get References
;;     Perform queries for data in the currently selected RefDB
;;     database. You can specify the search string interactively. Commands
;;     are provided to get literal or regular expression matches of your
;;     query string. Queries involving author names, keywords, and periodical
;;     names allow tab completion against the lists of these terms in the
;;     current database. (Provides submenus for performing various queries by
;;     passing parameters to 'refdbc -C getref'.)
;;
;;   Get References on Region
;;     Similar to the previous group of commands, but a region is used as the
;;     input instead of typing in a string interactively. Mark a region by
;;     highlighting it with the mouse or by setting a mark via the keyboard,
;;     then use one of the commands of this menu to find references that
;;     have the selected word or phrase as an author name, a keyword, a title
;;     word, or as a periodical name. Matches are by regular expression.
;;     (Provides submenus for performing various queries by passing parameters
;;     to 'refdbc -C getref'.)
;;
;;   Get References in Citation
;;     Move point somewhere into a citation (i.e. a <citation> element in
;;     a DocBook document and a <seg> in a TEI document), and this command
;;     will retrieve all references cited in this element.
;;
;;   Pick References
;;     Add references to your personal reference list
;;
;;   Dump References
;;     Remove references from your personal reference list
;;
;;   Convert References
;;     Run contents of the current buffer through various filters to convert
;;     the reference data format to or from RIS
;;
;;   Cite References
;;     Select one or more references in a RIS or risx buffer and use one
;;     of the commands of this submenu to copy a DocBook or TEI citation
;;     containing these references to the kill ring. You can then switch to
;;     a DocBook or TEI document buffer and yank (Ctrl-y) the citation
;;     wherever you need it.
;;
;;   Add Notes
;;     Add notes in the current buffer to the currently selected
;;     RefDB database.  (Runs 'refdbc -C addnote' on current region.)
;;
;;   Update Notes
;;     Update notes in the current buffer in the currently selected
;;     RefDB database.  (Runs 'refdbc -C updatenote' on current region.)
;;
;;   Delete Notes
;;     Delete notes by ID from the currently selected
;;     RefDB database.  (Runs 'refdbc -C deletenote' on current region.)
;;
;;   Get Notes
;;     Perform queries for notes in the currently selected RefDB
;;     database. You can specify the search string interactively. Commands
;;     are provided to get literal or regular expression matches of your
;;     query string. Queries involving author names, keywords, and periodical
;;     names allow tab completion against the lists of these terms in the
;;     current database.(Provides submenus for performing various queries by
;;     passing parameters to 'refdbc -C getnote'.)
;;
;;   Get Notes on Region
;;     Similar to the previous group of commands, but a region is used as the
;;     input instead of typing in a string interactively. Mark a region by
;;     highlighting it with the mouse or by setting a mark via the keyboard,
;;     then use one of the commands of this menu to find extended notes that
;;     have the selected word or phrase as a keyword or as a title word, or
;;     to find notes that are linked to either an author name, a keyword,
;;     or to a periodical name. Matches are by regular expression.
;;     (Provides submenus for performing various queries by passing parameters
;;     to 'refdbc -C getnote'.)
;;
;;   Add Links
;;     Links extended notes to various database objects
;;
;;   Delete Links
;;     Removes links from extended notes to database objects
;;
;;   Customize Data Output
;;     Select the output type and format to use for data returned from
;;     RefDB queries (i.e., values passed as arguments to the -t and
;;     -s options for the 'refdbc -C getref' and 'refdbc -C getnote'
;;     commands.) and for the citations.
;;
;;   Select Database
;;     Select the database to use for RefDB interaction (passed via
;;     the -d option to refdbc commands).
;;
;;   Database Info
;;     Displays information about the currently selected database
;;
;;   Administration
;;     Provides a submenu for the administrative tasks like creating
;;     databases or adding users, as well as for starting/stopping
;;     the refdbd daemon and for editing config files
;;
;;   Show RefDB Message Log
;;     Show the log of messages errors returned from RefDB
;;     commands.
;;
;;   Show RefDB Version
;;     Show refdb-mode and refdbd version information.
;;
;;   Info Manual
;;     Displays the refdb-mode node of the info documentation system
;; 
;;  ------------------------
;;;      :: Commands ::
;;  ------------------------
;;
;;   refdb-addref-on-region
;;   refdb-updateref-on-region
;;   refdb-deleteref
;;   --
;;   refdb-getref-by-author
;;   refdb-getref-by-author-regexp
;;   refdb-getref-by-title
;;   refdb-getref-by-title-regexp
;;   refdb-getref-by-keyword
;;   refdb-getref-by-keyword-regexp
;;   refdb-getref-by-periodical
;;   refdb-getref-by-periodical-regexp
;;   refdb-getref-by-id
;;   refdb-getref-by-citekey
;;   refdb-getref-by-advanced-search
;;   refdb-getref-by-author-on-region
;;   refdb-getref-by-title-on-region
;;   refdb-getref-by-keyword-on-region
;;   refdb-getref-by-periodical-on-region
;;   refdb-getref-by-id-on-region
;;   refdb-getref-by-citekey-on-region
;;   --
;;   refdb-pickref
;;   refdb-dumpref
;;   --
;;   refdb-import-from-bibtex
;;   refdb-import-from-copac
;;   refdb-import-from-endnote
;;   refdb-import-from-isi
;;   refdb-import-from-medline
;;   refdb-import-from-mods
;;   refdb-export-to-endnote
;;   refdb-export-to-mods
;;   --
;;   refdb-addnote-on-buffer
;;   refdb-updatenote-on-buffer
;;   refdb-deletenote
;;   --
;;   refdb-getnote-by-title
;;   refdb-getnote-by-title-regexp
;;   refdb-getnote-by-keyword
;;   refdb-getnote-by-keyword-regexp
;;   refdb-getnote-by-nid
;;   refdb-getnote-by-ncitekey
;;   refdb-getnote-by-authorlink
;;   refdb-getnote-by-authorlink-regexp
;;   refdb-getnote-by-periodicallink
;;   refdb-getnote-by-periodicallink-regexp
;;   refdb-getnote-by-keywordlink
;;   refdb-getnote-by-keywordlink-regexp
;;   refdb-getnote-by-idlink
;;   refdb-getnote-by-citekeylink
;;   refdb-getnote-by-advanced-search
;;   refdb-getnote-by-title-on-region
;;   refdb-getnote-by-keyword-on-region
;;   refdb-getnote-by-authorlink-on-region
;;   refdb-getnote-by-periodicallink-on-region
;;   refdb-getnote-by-keywordlink-on-region
;;   refdb-getnote-by-idlink-on-region
;;   refdb-getnote-by-citekeylink-on-region
;;   --
;;   refdb-addlink
;;   refdb-deletelink
;;   --
;;   refdb-select-data-output-type
;;   refdb-select-data-output-format
;;   refdb-select-notesdata-output-format
;;   refdb-select-additional-data-fields
;;   refdb-select-citation-format
;;   --
;;   refdb-select-database
;;   refdb-whichdb
;;   refdb-scan-database-list
;;   refdb-scan-admin-database-list
;;   refdb-scan-keywords-list
;;   refdb-scan-authors-list
;;   refdb-scan-periodicals-list
;;   refdb-update-completions-list
;;   refdb-scan-styles-list
;;   --
;;   refdb-create-document
;;   refdb-normalize-linkends
;;   refdb-transform
;;   refdb-transform-custom
;;   refdb-view-output
;;   refdb-create-docbook-citation-on-region
;;   refdb-create-tei-citation-on-region
;;   refdb-create-docbook-citation-from-point
;;   refdb-create-tei-citation-from-point
;;   --
;;   refdb-addstyle-on-buffer
;;   refdb-liststyle
;;   refdb-getstyle
;;   refdb-deletestyle
;;   refdb-adduser
;;   refdb-listuser
;;   refdb-deleteuser
;;   refdb-addword
;;   refdb-deleteword
;;   refdb-createdb
;;   refdb-deletedb
;;   refdb-scankw
;;   refdb-listdb
;;   refdb-viewstat
;;   refdb-backup-database
;;   refdb-restore-database
;;   refdb-init-refdb
;;   refdb-start-server
;;   refdb-stop-server
;;   refdb-restart-server
;;   refdb-reload-server
;;   --
;;   refdb-edit-refdbcrc
;;   refdb-edit-refdbarc
;;   refdb-edit-refdbibrc
;;   refdb-edit-refdbdrc
;;   refdb-edit-global-refdbcrc
;;   refdb-edit-global-refdbarc
;;   refdb-edit-global-refdbibrc
;;   --
;;   refdb-show-messages
;;   refdb-show-version
;;   refdb-show-manual
;;
;; -------------------------------------------------------------------
;;; Bugs
;; -------------------------------------------------------------------
;;
;; -------------------------------------------------------------------
;;; TODO
;; -------------------------------------------------------------------
;;
;;   - run viewstat after startup to see whether the server
;;     responds. Give a visual clue.
;;
;;   - define keyboard shortcuts for the most used commands
;;
;;   - integrate RefDB's own data converters into the menu
;;
;;   - fix deleteref/deletenote. Make delete-by-region available for
;;     ris-mode
;;
;;   - implement a "query builder" for complex queries which allows
;;     tab completion for targets and their values if applicable
;;
;; -------------------------------------------------------------------
;;; Error Messages
;; -------------------------------------------------------------------
;;   "Could not set terminal attributes"
;;      If a "Could not set terminal attributes" message appears in
;;      the *refdb-output*, it's probably because you don't have a
;;      password value set either in a RefDB client config file in
;;      your $HOME directory (for example, your .refdbcrc file) or in
;;      one of the global config files.
;;
;;   "incorrect username"
;;      This message means that refdbc or another RefDB client cannot
;;      determine a valid username to use for interaction with the
;;      RefDB server. Mostly likely, the cause is that you don't have
;;      a username value set in a RefDB client config file either in
;;      your $HOME directory (for example, your .refdbcrc file) or in
;;      one of the global config files.
;;
;; -------------------------------------------------------------------
;;; History:
;; -------------------------------------------------------------------
;;   See the CVS messages, conveniently accessible through the web at:
;;   http://sourceforge.net/projects
;;
;; -------------------------------------------------------------------
;;; Acknowledgments
;; -------------------------------------------------------------------
;;

;;; Code:

;; *******************************************************************
;;; Initialization
;; *******************************************************************

(require 'easymenu)
(require 'easy-mmode)

(add-hook 'refdb-mode-hook
	  ;;create RefDB menu using easy-menu
	  '(lambda ()
	     (easy-menu-define
	       refdb-menu
	       refdb-mode-map
	       "Easy menu command/variable for `refdb-mode'."
	       refdb-menu-definition
	       )
	     )
	  )

(add-hook 'refdb-mode-hook 'refdb-initialize-all-menus)
(add-hook 'refdb-mode-hook 'refdb-set-default-database)
(add-hook 'refdb-mode-hook 'refdb-initialize-database-list)
(add-hook 'refdb-mode-hook 'refdb-initialize-style-list)
(add-hook 'refdb-select-database-hook 'refdb-update-completion-lists)
(add-hook 'refdb-select-database-hook 'refdb-find-dbengine)

(defvar refdb-input-type "ris")
(defvar refdb-database-list-initialized-flag nil)
(defvar refdb-style-list-initialized-flag nil)
(defvar refdb-default-database-set-flag nil)
(defvar refdb-select-database-hook nil
  "A hook to be run after a new database has been selected")

;; tab-completion list for addlink/deletelink
(setq refdb-note-specifier-list '((":NID:" 1)
			    (":NCK:" 2)))

;; tab-completion list for addlink/deletelink
;; (setq refdb-link-target-specifier-list '((":ID:" 1)
;; 				   (":CK:" 2)
;; 				   (":AU:" 3)
;; 				   (":KW:" 4)
;; 				   (":JF:" 5)
;; 				   (":JO:" 6)
;; 				   (":J1:" 7)
;; 				   (":J2:" 8)))

;; tab-completion list for refdbnd document type
(setq refdb-refdbnd-doctype-list '(("DocBook SGML 3.1" 1)
				   ("DocBook SGML 4.0" 2)
				   ("DocBook SGML 4.1" 3)
				   ("DocBook XML 4.1.2" 4)
				   ("DocBook XML 4.2" 5)
				   ("DocBook XML 4.3" 6)
				   ("TEI XML P4" 7)))

;; tab-completion list for refdbnd root element
(setq refdb-refdbnd-root-element-list '(("book" 1)
					("article" 2)
					("set" 3)
					("TEI.2" 4)))

;; tab-completion list for viewing output
(setq refdb-output-type-list '(("html" 1)
			       ("xhtml" 2)
			       ("pdf" 3)
			       ("ps" 4)
			       ("rtf" 5)))


;; *******************************************************************
;;; User-customizable options, part 1
;; *******************************************************************
;;
;; These are all needed at startup in order to build the
;; Select Database submenu.

(defcustom refdb-database ""
  "*Name of a RefDB database to use in RefDB commands.
Passed to RefDB commands as the parameter for the -d option."
  :type 'string
  :group 'refdb
  )

(defcustom refdb-listdb-sql-regexp "%"
  "Expression for limiting list of available databases.
Passed as the argument for the 'refdbc -C listdb' command.  Leave at
'%' to show all available databases.  Set to some other value to
narrow the list.  For example, set to 'refdb%' to list just those
databases whose names begin with the string 'refdb'."
  :type 'string
  :group 'refdb-admin-options)

(defcustom refdb-refdbd-program "refdbd"
  "Command to run the refdbd executable."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-refdbd-script "refdbctl"
  "Command to run the control script used to start and stop refdbd."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-refdbc-program "refdbc"
  "Command to run the refdbc executable."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-refdbc-options "-c stdout"
  "Global options for refdbc."
  :set-after '(refdb-database-default)
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-refdba-program "refdba"
  "Command to run the refdba executable."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-refdba-options "-c stdout"
  "Global options for refdba."
  :set-after '(refdb-database-default)
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-refdbnd-program "refdbnd"
  "Command to run the refdbnd shell script."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-gnumake-program "make"
  "Command to run the GNU make utility. On systems using their own
version of make the executable is often called 'gmake'."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-addref-options ""
  "Options included when running the 'refdbc -C addref' command."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-updateref-options ""
  "Options included when running the 'refdbc -C updateref' command."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-deleteref-options ""
  "Options included when running the 'refdbc -C deleteref' command."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-getref-options ""
  "Options included when running the 'refdbc -C getref' command."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-addnote-options ""
  "Options included when running the 'refdbc -C addnote' command."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-updatenote-options ""
  "Options included when running the 'refdbc -C updatenote' command."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-deletenote-options ""
  "Options included when running the 'refdbc -C deletenote' command."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-addstyle-options ""
  "Options included when running the 'refdba -C addstyle' command."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-getnote-options ""
  "Options included when running the 'refdbc -C getnote' command."
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-sysconfdir "/usr/local/etc/refdb"
  "The directory which contains the global RefDB configuration files. Usually this would be /etc/refdb or /usr/local/etc/refdb"
  :type 'string
  :group 'refdb-programs)

(defcustom refdb-menu-suppress-toggle-flag nil
  "*Non-nil means suppress 'RefDB Mode' menu item.
Set to non-nil \(on\) to suppress, leave at nil \(off\) to show."
  :type 'boolean
  :group 'refdb-menu-definitions
  :require 'refdb
  )

(defcustom refdb-use-short-citations-document-flag nil
  "Non-nil means that after creating a new document the file
for use with short-style citations will be loaded for editing.
Nil means that the file for use with full citations will be loaded."
  :type 'boolean
  :group 'refdb
  )

(defcustom refdb-auto-normalize-linkends-flag t
  "Non-nil means normalize the endterms and linkends of RefDB citations
before running a transformation."
  :type 'boolean
  :group 'refdb
  )

(defcustom refdb-data-output-types
  '(
    scrn
    html
    xhtml
    db31
    db31x
    teix
    bibtex
    ris
    risx
    )
  "List of supported reference data output types for RefDB."
  :type '(list symbol symbol symbol symbol symbol symbol symbol symbol symbol)
  :group 'refdb-data-options)

(defcustom refdb-notesdata-output-types
  '(
    scrn
    html
    xhtml
    xnote
    )
  "List of supported notes data output types for RefDB."
  :type '(list symbol symbol symbol symbol)
  :group 'refdb-data-options)

(defcustom refdb-data-output-formats
  '(
    default
    more
    ID
    all
    )
  "*List of supported data output formats for RefDB."
  :type '(list symbol symbol symbol symbol)
  :group 'refdb-data-options)

(defcustom refdb-citation-types
  '(
    short
    full
    )
  "*List of supported citation types for RefDB."
  :type '(list symbol symbol)
  :group 'refdb-data-options)

(defcustom refdb-data-output-additional-fields
 '(N1 N2 UR)
  "*Use this to specify additional fields to display in Screen output."
  :type '(set
	  (const :tag "Notes                        \(N1\)" N1)
	  (const :tag "Abstract                     \(N2\)" N2)
	  (const :tag "Reprint Status               \(RP\)" RP)
	  (const :tag "Availability                 \(AV\)" AV)
 	  (const :tag "City of Publication          \(CY\)" CY)
 	  (const :tag "Publisher                    \(PB\)" PB)
 	  (const :tag "ISBN/ISSN                    \(SN\)" SN)
	  (const :tag "Contact Address              \(AD\)" AD)
	  (const :tag "URL                          \(UR\)" UR)
	  (const :tag "User-Defined 1               \(U1\)" U1)
	  (const :tag "User-Defined 2               \(U2\)" U2)
	  (const :tag "User-Defined 3               \(U3\)" U3)
	  (const :tag "User-Defined 4               \(U4\)" U4)
	  (const :tag "User-Defined 5               \(U5\)" U5)
	  (const :tag "Miscellaneous 1              \(M1\)" M1)
	  (const :tag "Miscellaneous 2              \(M2\)" M2)
	  (const :tag "Miscellaneous 3              \(M3\)" M3)
	  (const :tag "Miscellaneous 4              \(M4\)" M4)
	  (const :tag "Miscellaneous 5              \(M5\)" M5)
	  (const :tag "Link1                        \(L1\)" L1)
	  (const :tag "Link2                        \(L2\)" L2)
	  (const :tag "Link3                        \(L3\)" L3)
	  (const :tag "Link4                        \(L4\)" L4)
	  )
  :group 'refdb-data-options)

(defcustom refdb-citation-formats
  '(
    sgml
    xml
    )
  "*List of supported citation formats for RefDB."
  :type '(list symbol symbol)
  :group 'refdb-data-options)

(defcustom refdb-default-ris-encoding 'iso-latin-1
  "*Use this character encoding to display datasets in RIS format."
  :type 'symbol
  :group 'refdb-data-options)

(defcustom refdb-character-encodings-list
  '(
    "US-ASCII"
    "UTF-8"
    "UTF-16"
    "ISO-8859-1"
    "ISO-8859-2"
    "ISO-8859-3"
    "ISO-8859-4"
    "ISO-8859-9"
    "ISO-8859-10"
    "ISO-8859-13"
    "ISO-8859-14"
    "ISO-8859-15"
    "ISO-8859-16"
    "ISO-8859-5"
    "ISO-8859-6"
    "ISO-8859-7"
    "ISO-8859-8"
    "KOI8-R"
    "KOI8-R"
    "KOI8-U"
    "KOI8-U"
    "EUC-JP"
    "EUC-KR"
    "windows-1251"
    "IBM866"
    "windows-1250"
    "windows-1256"
    "windows-1257"
    "windows-1257"
    "IBM850"
    "IBM852"
    "IBM857"
    "IBM865"
    "IBM866"
    "Big5"
    "GB2312"
    "Shift_JIS"
    "ISO646-NO"
    "ISO646-HU"
    "GBK"
    "ISO-10646-UCS-2"
    "DEC-MCS"
    "TIS-620"
    "hp-roman8"
    )
  "*Available character encodings for reference databases.
Customize this to add/remove encodings according to your local system."
  :group 'refdb-admin-options
  :type '(repeat string)
  )

(defcustom refdb-wait-for-server-period 3
  "Sleep time in seconds before we contact the server after changing the server state"
  :group 'refdb-admin-options
  :type 'integer
)

(defcustom refdb-update-completion-lists-flag t
  "Automatically update keyword, author, and periodical completion lists whenever
they may have changed if set to t. If set to nil, the lists will only be updated
when you select a new database, or when you run refdb-update-completion-lists manually."
  :group 'refdb
  :type 'boolean
)

(defcustom refdb-use-regexp-match-in-getref-on-region-flag t
  "Use regexp matches when running getref or getnote on a region. If set
to nil, exact matches are used instead."
  :group 'refdb
  :type 'boolean
)

;; file viewers. (x)html files are handled by browse-url
(defcustom refdb-pdf-view-program "gv"
  "File name of the PDF file viewer."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-pdf-view-program-options ""
  "Command-line options of the PDF file viewer."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-ps-view-program "gv"
  "File name of the PDF file viewer."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-ps-view-program-options ""
  "Command-line options of the Postscript file viewer."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-rtf-view-program "/usr/local/OpenOffice.org1.1.4/program/swriter"
  "File name of the RTF file viewer."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-rtf-view-program-options ""
  "Command-line options of the RTF file viewer."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-external-program-shell "/bin/sh"
  "File name of the shell used to start external programs."
  :type 'string
  :group 'refdb-external-programs)

;; other external programs
(defcustom refdb-bibutils-bib2xml-program "bib2xml"
  "File name of the bibutils bib2xml executable."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-bib2xml-options "-un"
  "Global options for bibutils bib2xml."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-copac2xml-program "copac2xml"
  "File name of the bibutils copac2xml executable."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-copac2xml-options "-un"
  "Global options for bibutils copac2xml."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-end2xml-program "end2xml"
  "File name of the bibutils end2xml executable."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-end2xml-options "-un"
  "Global options for bibutils end2xml."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-isi2xml-program "isi2xml"
  "File name of the bibutils isi2xml executable."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-isi2xml-options "-un"
  "Global options for bibutils isi2xml."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-med2xml-program "med2xml"
  "File name of the bibutils med2xml executable."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-med2xml-options "-un"
  "Global options for bibutils med2xml."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-ris2xml-program "ris2xml"
  "File name of the bibutils ris2xml executable."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-ris2xml-options "-un"
  "Global options for bibutils ris2xml."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-xml2bib-program "xml2bib"
  "File name of the bibutils xml2bib executable."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-xml2bib-options ""
  "Global options for bibutils xml2bib."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-xml2end-program "xml2end"
  "File name of the bibutils xml2end executable."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-xml2end-options ""
  "Global options for bibutils xml2end."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-xml2ris-program "xml2ris"
  "File name of the bibutils xml2ris executable."
  :type 'string
  :group 'refdb-external-programs)

(defcustom refdb-bibutils-xml2ris-options ""
  "Global options for bibutils xml2ris."
  :type 'string
  :group 'refdb-external-programs)


;; *******************************************************************
;;; end of user-customizable options, part 1
;; *******************************************************************

(defun refdb-list-databases ()
  "List databases returned by 'refdbc -C listdb'."
  (message
   "Building list of databases using '%s %s -C listdb %s'..."
   refdb-refdbc-program
   refdb-refdbc-options
   refdb-listdb-sql-regexp
   )
  (split-string
   (with-output-to-string
     (with-current-buffer
	 standard-output
       (call-process
	shell-file-name nil '(t nil) nil shell-command-switch
	(format "%s %s -C listdb %s"
		refdb-refdbc-program
		refdb-refdbc-options
		refdb-listdb-sql-regexp
		)
	)
       )
     )
   )
  )

(defun refdb-list-admin-databases ()
  "List databases returned by 'refdba -C listdb'."
  (message
   "Building list of databases using '%s %s -C listdb %s'..."
   refdb-refdba-program
   refdb-refdba-options
   refdb-listdb-sql-regexp
   )
  (split-string
   (with-output-to-string
     (with-current-buffer
	 standard-output
       (call-process
	shell-file-name nil '(t nil) nil shell-command-switch
	(format "%s %s -C listdb %s"
		refdb-refdba-program
		refdb-refdba-options
		refdb-listdb-sql-regexp
		)
	)
       )
     )
   )
  )

(defun refdb-initialize-database-list ()
  "Initialize list of RefDB databases. Makes sure it runs only once per session.
To refresh the list interactively, use 'refdb-scan-database-list' instead"
  (if (eq refdb-database-list-initialized-flag nil)
      (progn
	(refdb-scan-database-list)
	(refdb-scan-admin-database-list)
	(setq refdb-database-list-initialized-flag t))
    )
  )

(defun refdb-set-default-database ()
  "Set default database for all RefDB commands.
This function uses output from 'refdbc -C set defaultdb' to determine
if a user has a 'defaultdb' value set in either the global refdbcrc
file or in his or her ~/.refdbcrc file. If so, that value is used as
the database value in all RefDB commands."
  (if (eq refdb-default-database-set-flag nil)
      (progn 
	(message "Setting default database...")
	(setq refdb-database-default
	      (car
	       (last
		(split-string
		 (with-output-to-string
		   (with-current-buffer
		       standard-output
		     (call-process shell-file-name nil '(t t) nil shell-command-switch
				   (format "%s %s -C set defaultdb"
					   refdb-refdbc-program
					   refdb-refdbc-options
					   )
				   )
		     )
		   )
		 )
		)
	       )
	      )
	(if (and
	     (equal refdb-database "")
	     (not (equal refdb-database-default "defaultdb"))
	     )
;	    (progn
	      (setq refdb-database refdb-database-default)
;	      (run-hooks 'refdb-select-database-hook))
	  )
	(run-hooks 'refdb-select-database-hook)
	(message "Setting default database...done")
	(setq refdb-default-database-set-flag t)
	)
    )
  )

(defun refdb-scan-database-list ()
  "Scan list of RefDB databases for the current user."
  (interactive)
  (progn
    (message "Initializing RefDB database list...")
    (setq refdb-selectdb-submenu-contents nil)
    (setq refdb-current-database-list (refdb-list-databases))
    (message
     "Building list of databases using '%s %s -C listdb %s'...done"
     refdb-refdbc-program
     refdb-refdbc-options
     refdb-listdb-sql-regexp
     )
    (message "Initializing RefDB database list...done")
    (refdb-make-selectdb-menu)
    )
  )

(defun refdb-update-database-menu ()
  (easy-menu-change (list "RefDB")
		    (car refdb-selectdb-submenu-contents)
		    (cdr refdb-selectdb-submenu-contents))
  )

(defun refdb-scan-admin-database-list ()
  "Scan list of all RefDB databases."
  (interactive)
  (progn
    (message "Initializing RefDB administrator database list...")
    (setq refdb-current-admin-database-list (refdb-list-admin-databases))
    (message
     "Building list of databases using '%s %s -C listdb %s'...done"
     refdb-refdba-program
     refdb-refdba-options
     refdb-listdb-sql-regexp
     )
    (message "Initializing RefDB administrator database list...done")
    )
  )

(defun refdb-list-keywords ()
  "List keywords returned by 'refdbc -C getkw'."
  (message
   "Building list of keywords using '%s %s -d %s -C getkw'..."
   refdb-refdbc-program
   refdb-refdbc-options
   refdb-database
   )
  (split-string 
   (with-output-to-string
     (with-current-buffer
	 standard-output
       (call-process
	shell-file-name nil '(t nil) nil shell-command-switch
	(format "%s %s -d %s -C getkw"
		refdb-refdbc-program
		refdb-refdbc-options
		refdb-database
		)
	)
       )
     )
   "\n")
  )

(defun refdb-scan-keywords-list ()
  "Scan list of RefDB keywords."
  (interactive)
  (progn
    (message "Initializing RefDB keywords list...")
    (setq refdb-current-keywords-list (refdb-list-keywords))
    (message
     "Building list of keywords using '%s %s -d %s -C getkw'...done"
     refdb-refdbc-program
     refdb-refdbc-options
     refdb-database
     )
    )
  )

(defun refdb-list-authors ()
  "List authors returned by 'refdbc -C getau'."
  (message
   "Building list of authors using '%s %s -d %s -C getau'..."
   refdb-refdbc-program
   refdb-refdbc-options
   refdb-database
   )
  (split-string 
   (with-output-to-string
     (with-current-buffer
	 standard-output
       (call-process
	shell-file-name nil '(t nil) nil shell-command-switch
	(format "%s %s -d %s -C getau"
		refdb-refdbc-program
		refdb-refdbc-options
		refdb-database
		)
	)
       )
     )
   "\n")
  )

(defun refdb-scan-authors-list ()
  "Scan list of RefDB authors."
  (interactive)
  (progn
    (message "Initializing RefDB authors list...")
    (setq refdb-current-authors-list (refdb-list-authors))
    (message
     "Building list of authors using '%s %s -d %s -C getau'...done"
     refdb-refdbc-program
     refdb-refdbc-options
     refdb-database
     )
    )
  )

(defun refdb-list-periodicals ()
  "List periodicals returned by 'refdbc -C getjo'."
  (message
   "Building list of periodicals using '%s %s -d %s -C getjo'..."
   refdb-refdbc-program
   refdb-refdbc-options
   refdb-database
   )
  (append
   (split-string 
    (with-output-to-string
      (with-current-buffer
	  standard-output
	(call-process
	 shell-file-name nil '(t nil) nil shell-command-switch
	 (format "%s %s -d %s -C getjo %s"
		 refdb-refdbc-program
		 refdb-refdbc-options
		 refdb-database
		 refdb-periodical-regexp
		 )
	 )
	)
      )
    "\n")
   (split-string 
    (with-output-to-string
      (with-current-buffer
	  standard-output
	(call-process
	 shell-file-name nil '(t nil) nil shell-command-switch
	 (format "%s %s -d %s -C getjf %s"
		 refdb-refdbc-program
		 refdb-refdbc-options
		 refdb-database
		 refdb-periodical-regexp
		 )
	 )
	)
      )
    "\n")
   )
  )

(defun refdb-scan-periodicals-list ()
  "Scan list of RefDB periodicals."
  (interactive)
  (progn
    (message "Initializing RefDB periodicals list...")
    (setq refdb-current-periodicals-list (refdb-list-periodicals))
    (message
     "Building list of periodicals using '%s %s -d %s -C getjo'...done"
     refdb-refdbc-program
     refdb-refdbc-options
     refdb-database
     )
    )
  )

(defun refdb-update-completion-lists ()
  "Update all tab completion lists."
  (interactive)
  (refdb-scan-keywords-list)
  (refdb-scan-authors-list)
  (refdb-scan-periodicals-list)
  )

(defun refdb-initialize-style-list ()
  "Initialize list of RefDB styles. Makes sure it runs only once per session.
To refresh the list interactively, use 'refdb-scan-styles-list' instead"
  (if (eq refdb-style-list-initialized-flag nil)
      (progn
	(refdb-scan-styles-list)
	(setq refdb-style-list-initialized-flag t))
    )
  )

(defun refdb-list-styles ()
  "List styles returned by 'refdbc -C liststyle'."
  (message
   "Building list of styles using '%s %s -C liststyle'..."
   refdb-refdbc-program
   refdb-refdbc-options
   )
  (split-string 
   (with-output-to-string
     (with-current-buffer
	 standard-output
       (call-process
	shell-file-name nil '(t nil) nil shell-command-switch
	(format "%s %s -C liststyle"
		refdb-refdbc-program
		refdb-refdbc-options
		)
	)
       )
     )
   "\n")
  )

(defun refdb-scan-styles-list ()
  "Scan list of RefDB styles."
  (interactive)
  (progn
    (message "Initializing RefDB style list...")
    (setq refdb-current-styles-list (refdb-list-styles))
    (message
     "Building list of styles using '%s %s -C liststyle'...done"
     refdb-refdbc-program
     refdb-refdbc-options
     )
    )
  )

(defun refdb-find-dbengine ()
  "Set variables according to the database engine running"
  (let* ((dbstring
	  (with-output-to-string
	    (with-current-buffer
		standard-output
	      (call-process
	       shell-file-name nil '(t nil) nil shell-command-switch
	       (format "%s %s -d %s -C whichdb | grep \'Database server\'"
		       refdb-refdbc-program
		       refdb-refdbc-options
		       refdb-database
		       )
	       ))))
	 (dbengine
	  (if (and
	       dbstring
	       (> (length dbstring) 0))
	      (substring
	       dbstring
	       ;; -1 removes the last char which is a newline
	       17 -1)
	    nil)
	  ))
    (message "Adapt to database engine %s" dbengine)
    (cond ((or
	    (equal dbengine "mysql")
	    (equal dbengine "pgsql"))
	   (progn
	     (setq refdb-regexp-query-string "")
	     (setq refdb-periodical-regexp ".+")
	     (setq refdb-regexp-prompt "\(regexp\)")))
	  ((or
	    (equal dbengine "sqlite")
	    (equal dbengine "sqlite3"))
	   (progn
	     (setq refdb-regexp-query-string "%%")
	     (setq refdb-periodical-regexp "_%%")
	     (setq refdb-regexp-prompt "\(SQL regexp\)")))
	  (t
	   (progn
	     (setq refdb-regexp-query-string "")
	     (setq refdb-periodical-regexp "")))
	  )
    )
  )

(defun refdb-select-data-output-type (outputtype)
  "Set RefDB reference output type to OUTPUTTYPE.
Note that OUTPUTTYPE is a symbol, not a string."
  (interactive
   (list (intern
	  (completing-read
	   "Output Type: "
	   (refdb-make-alist-from-symbol-list refdb-data-output-types)
	   nil t
	   )
	  )
	 )
   )
  (setq refdb-data-output-type outputtype)
  (message "Current output type is now '%s'" (symbol-name outputtype))
  )

(defun refdb-select-data-output-format (format)
  "Set dataset output to FORMAT.
Note that FORMAT is a symbol, not a string.

Use this function to control the value that is passed to the
'refdcbc -C getref -s' option.

Choose 'all' to display all fields (does not affect RIS output).
Choose 'ID' to display ID fields only (affects RIS output only).
Choose 'more' to display additional fields in non-RIS output.
Choose 'default' to display default fields only (in non-RIS output).
Use `refdb-select-additional-data-fields' to select which
additional (non-default) fields to display in non-RIS output."
  (interactive
   (list (intern
	  (completing-read
	   "Output Format: "
	   (refdb-make-alist-from-symbol-list refdb-data-output-formats)
	   nil t
	   )
	  )
	 )
   )
  (setq refdb-data-output-format format)
  (message "Dataset output is now set to display %s fields."
	   (symbol-name format))
	(if (equal format 'more)
	    (setq refdb-data-output-formatstring
		  (format "\\\"%s\\\""
			  ;; turn list of symbols into one big string
			  (mapconcat
			   'symbol-name
			   refdb-data-output-additional-fields
			   " "
			   )
			  )
		  )
	  (setq refdb-data-output-formatstring (upcase (symbol-name format)))
	  )
	)

(defun refdb-select-notesdata-output-type (outputtype)
  "Set RefDB notes output type to OUTPUTTYPE.
Note that OUTPUTTYPE is a symbol, not a string."
  (interactive
   (list (intern
	  (completing-read
	   "Output Type: "
	   (refdb-make-alist-from-symbol-list refdb-notesdata-output-types)
	   nil t
	   )
	  )
	 )
   )
  (setq refdb-notesdata-output-type outputtype)
  (message "Current notes output type is now '%s'" (symbol-name outputtype))
  )

(defun refdb-select-citation-type (citationtype)
  "Set RefDB citation type to CITATIONTYPE.
Note that CITATIONTYPE is a symbol, not a string."
  (interactive
   (list (intern
	  (completing-read
	   "Citation Type: "
	   (refdb-make-alist-from-symbol-list refdb-citation-types)
	   nil t
	   )
	  )
	 )
   )
  (setq refdb-citation-type citationtype)
  (message "Current citation type is now '%s'" (symbol-name citationtype))
  )

(defun refdb-select-citation-format (citationformat)
  "Set RefDB citation format to CITATIONFORMAT.
Note that CITATIONFORMAT is a symbol, not a string."
  (interactive
   (list (intern
	  (completing-read
	   "Citation Format: "
	   (refdb-make-alist-from-symbol-list refdb-citation-formats)
	   nil t
	   )
	  )
	 )
   )
  (setq refdb-citation-format citationformat)
  (message "Current citation format is now '%s'" (symbol-name citationformat))
  )

(defvar refdb-addref-menu-item
  ["Add References" (refdb-addref-on-region) t]
  "RefDB menu item for adding references."
  )

(defvar refdb-updateref-menu-item
  ["Update References" (refdb-updateref-on-region) t]
  "RefDB menu item for updating references."
  )

(defvar refdb-deleteref-menu-item
  ["Delete References"
   (call-interactively 'refdb-deleteref) t]
  "RefDB menu item for deleting references."
  )

(defvar refdb-getref-by-author-menu-item
  ["Author..."
   (call-interactively 'refdb-getref-by-author)
   t]
  "RefDB getref-by-author menu item."
  )

(defvar refdb-getref-by-author-regexp-menu-item
  ["Author \(regexp\)..."
   (call-interactively 'refdb-getref-by-author-regexp)
   t]
  "RefDB getref-by-author-regexp menu item."
  )

(defvar refdb-getref-by-title-menu-item
  ["Title..."
   (call-interactively 'refdb-getref-by-title)
   t]
  "RefDB getref-by-title menu item."
  )

(defvar refdb-getref-by-title-regexp-menu-item
  ["Title \(regexp\)..."
   (call-interactively 'refdb-getref-by-title-regexp)
   t]
  "RefDB getref-by-title-regexp menu item."
  )

(defvar refdb-getref-by-keyword-menu-item
  ["Keyword..."
   (call-interactively 'refdb-getref-by-keyword)
   t]
  "RefDB getref-by-keyword menu item."
  )

(defvar refdb-getref-by-keyword-regexp-menu-item
  ["Keyword \(regexp\)..."
   (call-interactively 'refdb-getref-by-keyword-regexp)
   t]
  "RefDB getref-by-keyword menu item."
  )

(defvar refdb-getref-by-periodical-menu-item
  ["Periodical..."
   (call-interactively 'refdb-getref-by-periodical)
   t]
  "RefDB getref-by-periodical menu item."
  )

(defvar refdb-getref-by-periodical-regexp-menu-item
  ["Periodical \(regexp\)..."
   (call-interactively 'refdb-getref-by-periodical-regexp)
   t]
  "RefDB getref-by-periodical menu item."
  )

(defvar refdb-getref-by-id-menu-item
  ["ID..."
   (call-interactively 'refdb-getref-by-id)
   t]
  "RefDB getref-by-id menu item."
  )

(defvar refdb-getref-by-citekey-menu-item
  ["Citation Key..."
   (call-interactively 'refdb-getref-by-citekey)
   t]
  "RefDB getref-by-citation-key menu item."
  )

(defvar refdb-getref-by-advanced-search-menu-item
  ["Advanced Search..."
   (call-interactively 'refdb-getref-by-advanced-search)
   t]
  "RefDB advanced-search menu item."
  )

(defvar refdb-getref-by-author-on-region-menu-item
  ["Author"
   (refdb-getref-by-author-on-region)
   t]
  "RefDB getref-by-author-on-region menu item."
  )

(defvar refdb-getref-by-title-on-region-menu-item
  ["Title"
   (refdb-getref-by-title-on-region)
   t]
  "RefDB getref-by-title-on-region menu item."
  )

(defvar refdb-getref-by-keyword-on-region-menu-item
  ["Keyword"
   (refdb-getref-by-keyword-on-region)
   t]
  "RefDB getref-by-keyword menu item."
  )

(defvar refdb-getref-by-periodical-on-region-menu-item
  ["Periodical"
   (refdb-getref-by-periodical-on-region)
   t]
  "RefDB getref-by-periodical menu item."
  )

(defvar refdb-getref-by-id-on-region-menu-item
  ["ID"
   (refdb-getref-by-id-on-region)
   t]
  "RefDB getref-by-id menu item."
  )

(defvar refdb-getref-by-citekey-on-region-menu-item
  ["Citation Key"
   (refdb-getref-by-citekey-on-region)
   t]
  "RefDB getref-by-citekey menu item."
  )

(defvar refdb-getref-from-citation-menu-item
  ["Get References from Citation"
   (refdb-getref-from-citation)
   t]
  "RefDB getref-from-citation menu item."
  )

(defvar refdb-pickref-menu-item
  ["Pick references" 
   (call-interactively 'refdb-pickref) t]
  "RefDB menu item for adding references to the personal reference list."
  )

(defvar refdb-dumpref-menu-item
  ["Dump references" 
   (call-interactively 'refdb-dumpref) t]
  "RefDB menu item for removing references from the personal reference list."
  )

(defvar refdb-create-docbook-citation-from-point-menu-item
  ["Current as DocBook"
   (refdb-create-docbook-citation-from-point)
   t]
  "RefDB cite point as DocBook menu item."
  )

(defvar refdb-create-tei-citation-from-point-menu-item
  ["Current as TEI"
   (refdb-create-tei-citation-from-point)
   t]
  "RefDB cite point as TEI menu item."
  )

(defvar refdb-create-latex-citation-from-point-menu-item
  ["Current as LaTeX"
   (refdb-create-latex-citation-from-point)
   t]
  "RefDB cite point as LaTeX menu item."
  )

(defvar refdb-create-docbook-citation-on-region-menu-item
  ["In Region as DocBook"
   (refdb-create-docbook-citation-on-region)
   t]
  "RefDB cite range as DocBook menu item."
  )

(defvar refdb-create-tei-citation-on-region-menu-item
  ["In Region as TEI"
   (refdb-create-tei-citation-on-region)
   t]
  "RefDB cite range as TEI menu item."
  )

(defvar refdb-create-latex-citation-on-region-menu-item
  ["In Region as LaTeX"
   (refdb-create-latex-citation-on-region)
   t]
  "RefDB cite range as LaTeX menu item."
  )

(defvar refdb-addnote-menu-item
  ["Add Notes" (refdb-addnote-on-buffer) t]
  "RefDB menu item for adding notes."
  )

(defvar refdb-updatenote-menu-item
  ["Update Notes" (refdb-updatenote-on-buffer) t]
  "RefDB menu item for updating notes."
  )

(defvar refdb-deletenote-menu-item
  ["Delete Notes" 
   (call-interactively 'refdb-deletenote) t]
  "RefDB menu item for deleting notes."
  )

(defvar refdb-getnote-by-title-menu-item
  ["Title..."
   (call-interactively 'refdb-getnote-by-title)
   t]
  "RefDB getnote-by-title menu item."
  )

(defvar refdb-getnote-by-title-regexp-menu-item
  ["Title \(regexp\)..."
   (call-interactively 'refdb-getnote-by-title-regexp)
   t]
  "RefDB getnote-by-title-regexp menu item."
  )

(defvar refdb-getnote-by-keyword-menu-item
  ["Keyword..."
   (call-interactively 'refdb-getnote-by-keyword)
   t]
 "RefDB getnote-by-keyword menu item."
  )

(defvar refdb-getnote-by-keyword-regexp-menu-item
  ["Keyword \(regexp\)..."
   (call-interactively 'refdb-getnote-by-keyword-regexp)
   t]
  "RefDB getnote-by-keyword menu item."
  )

(defvar refdb-getnote-by-nid-menu-item
  ["Note ID..."
   (call-interactively 'refdb-getnote-by-nid)
   t]
  "RefDB getnote-by-nid menu item."
  )

(defvar refdb-getnote-by-ncitekey-menu-item
  ["Note Citation Key..."
   (call-interactively 'refdb-getnote-by-ncitekey)
   t]
  "RefDB getnote-by-ncitation-key menu item."
  )

(defvar refdb-getnote-by-authorlink-menu-item
  ["Linked to Author..."
   (call-interactively 'refdb-getnote-by-authorlink)
   t]
  "RefDB getnote-by-authorlink menu item."
  )

(defvar refdb-getnote-by-authorlink-regexp-menu-item
  ["Linked to Author \(regexp\)..."
   (call-interactively 'refdb-getnote-by-authorlink-regexp)
   t]
  "RefDB getnote-by-authorlink-regexp menu item."
  )

(defvar refdb-getnote-by-periodicallink-menu-item
  ["Linked to Periodical..."
   (call-interactively 'refdb-getnote-by-periodicallink)
   t]
  "RefDB getnote-by-periodicallink menu item."
  )

(defvar refdb-getnote-by-periodicallink-regexp-menu-item
  ["Linked to Periodical \(regexp\)..."
   (call-interactively 'refdb-getnote-by-periodicallink-regexp)
   t]
  "RefDB getnote-by-periodicallink-regexp menu item."
  )

(defvar refdb-getnote-by-keywordlink-menu-item
  ["Linked to Keyword..."
   (call-interactively 'refdb-getnote-by-keywordlink)
   t]
  "RefDB getnote-by-keywordlink menu item."
  )

(defvar refdb-getnote-by-keywordlink-regexp-menu-item
  ["Linked to Keyword \(regexp\)..."
   (call-interactively 'refdb-getnote-by-keywordlink-regexp)
   t]
  "RefDB getnote-by-keywordlink menu item."
  )

(defvar refdb-getnote-by-idlink-menu-item
  ["Linked to ID..."
   (call-interactively 'refdb-getnote-by-idlink)
   t]
  "RefDB getnote-by-idlink menu item."
  )

(defvar refdb-getnote-by-citekeylink-menu-item
  ["Linked to Citation Key..."
   (call-interactively 'refdb-getnote-by-citekeylink)
   t]
  "RefDB getnote-by-citation-keylink menu item."
  )

(defvar refdb-getnote-by-advanced-search-menu-item
  ["Advanced Notes Search..."
   (call-interactively 'refdb-getnote-by-advanced-search)
   t]
  "RefDB notes advanced-search menu item."
  )

(defvar refdb-getnote-by-title-on-region-menu-item
  ["Title"
   (refdb-getnote-by-title-on-region)
   t]
  "RefDB getnote-by-title-on-region menu item."
  )

(defvar refdb-getnote-by-keyword-on-region-menu-item
  ["Keyword"
   (refdb-getnote-by-keyword-on-region)
   t]
 "RefDB getnote-by-keyword-on-region menu item."
  )

(defvar refdb-getnote-by-authorlink-on-region-menu-item
  ["Linked to Author"
   (refdb-getnote-by-authorlink-on-region)
   t]
  "RefDB getnote-by-authorlink-on-region menu item."
  )

(defvar refdb-getnote-by-periodicallink-on-region-menu-item
  ["Linked to Periodical"
   (refdb-getnote-by-periodicallink-on-region)
   t]
  "RefDB getnote-by-periodicallink-on-region menu item."
  )

(defvar refdb-getnote-by-keywordlink-on-region-menu-item
  ["Linked to Keyword"
   (refdb-getnote-by-keywordlink-on-region)
   t]
  "RefDB getnote-by-keywordlink-on-region menu item."
  )

(defvar refdb-getnote-by-idlink-on-region-menu-item
  ["Linked to ID"
   (refdb-getnote-by-idlink-on-region)
   t]
  "RefDB getnote-by-idlink-on-region menu item."
  )

(defvar refdb-getnote-by-citekeylink-on-region-menu-item
  ["Linked to Citation Key"
   (refdb-getnote-by-citekeylink-on-region)
   t]
  "RefDB getnote-by-citekeylink-on-region menu item."
  )

(defvar refdb-addlink-menu-item
  ["Add Links" 
   (call-interactively 'refdb-addlink) t]
  "RefDB menu item for adding links to extended notes."
  )

(defvar refdb-deletelink-menu-item
  ["Delete Links" 
   (call-interactively 'refdb-deletelink) t]
  "RefDB menu item for deleting links from extended notes."
  )

(defvar refdb-select-data-output-type-submenu-contents
  (list "Select Reference Output Type"
	["Screen"
	 (refdb-select-data-output-type 'scrn)
	 :style toggle
	 :selected (eq refdb-data-output-type 'scrn)]
	["HTML"
	 (refdb-select-data-output-type 'html)
	 :style toggle
	 :selected (eq refdb-data-output-type 'html)]
	["XHTML"
	 (refdb-select-data-output-type 'xhtml)
	 :style toggle
	 :selected (eq refdb-data-output-type 'xhtml)]
	["DocBook SGML"
	 (refdb-select-data-output-type 'db31)
	 :style toggle
	 :selected (eq refdb-data-output-type 'db31)]
	["DocBook XML"
	 (refdb-select-data-output-type 'db31x)
	 :style toggle
	 :selected (eq refdb-data-output-type 'db31x)
	 ]
	["TEI XML"
	 (refdb-select-data-output-type 'teix)
	 :style toggle
	 :selected (eq refdb-data-output-type 'teix)
	 ]
	["BibTeX"
	 (refdb-select-data-output-type 'bibtex)
	 :style toggle
	 :selected (eq refdb-data-output-type 'bibtex)
	 ]
	["RIS"
	 (refdb-select-data-output-type 'ris)
	 :style toggle
 	 :selected (eq refdb-data-output-type 'ris)
	 ]
	["RISX"
	 (refdb-select-data-output-type 'risx)
	 :style toggle
	 :selected (eq refdb-data-output-type 'risx)
	 ]
	)
  "RefDB 'Select Reference Output Type' submenu.
FIXME: This probably should be generated from value of `refdb-data-output-types'."
  )

(defvar refdb-select-data-output-format-submenu-contents
  (list "Select Output Format"
	["Default"
	 (refdb-select-data-output-format 'default)
	 :style toggle
	 :selected (eq refdb-data-output-format 'default)]
	["IDs only"
	 (refdb-select-data-output-format 'ID)
	 :style toggle
	 :selected (eq refdb-data-output-format 'ID)]
	["More (additional) fields"
	 (refdb-select-data-output-format 'more)
	 :style toggle
	 :selected (eq refdb-data-output-format 'more)]
	["All fields"
	 (refdb-select-data-output-format 'all)
	 :style toggle
	 :selected (eq refdb-data-output-format 'all)]
	)
  "RefDB 'Select Output Format' submenu.
FIXME: This probably should be generated from value of `refdb-data-output-formats'."
  )

(defvar refdb-select-additional-data-fields-menu-item
  ["Select Additional Data Fields..."
   (refdb-select-additional-data-fields) t]
  "RefDB 'Select Additional Data Fields' menu item."
  )

(defvar refdb-select-notesdata-output-type-submenu-contents
  (list "Select Notes Output Type"
	["Screen"
	 (refdb-select-notesdata-output-type 'scrn)
	 :style toggle
	 :selected (eq refdb-notesdata-output-type 'scrn)]
	["HTML"
	 (refdb-select-notesdata-output-type 'html)
	 :style toggle
	 :selected (eq refdb-notesdata-output-type 'html)]
	["XHTML"
	 (refdb-select-notesdata-output-type 'xhtml)
	 :style toggle
	 :selected (eq refdb-notesdata-output-type 'xhtml)]
	["xnote"
	 (refdb-select-notesdata-output-type 'xnote)
	 :style toggle
	 :selected (eq refdb-notesdata-output-type 'xnote)]
	)
  "RefDB 'Select Notes Output Type' submenu.
FIXME: This probably should be generated from value of `refdb-notesdata-output-types'."
  )

(defvar refdb-select-citation-type-submenu-contents
  (list "Select Citation Output Type"
	["Short"
	 (refdb-select-citation-type 'short)
	 :style toggle
	 :selected (eq refdb-citation-type 'short)]
	["Full"
	 (refdb-select-citation-type 'full)
	 :style toggle
	 :selected (eq refdb-citation-type 'full)]
	)
  "RefDB 'Select Citation Type' submenu."
  )

(defvar refdb-select-citation-format-submenu-contents
  (list "Select Citation Output Format"
	["XML"
	 (refdb-select-citation-format 'xml)
	 :style toggle
	 :selected (eq refdb-citation-format 'xml)]
	["SGML"
	 (refdb-select-citation-format 'sgml)
	 :style toggle
	 :selected (eq refdb-citation-format 'sgml)]
	)
  "RefDB 'Select Citation Format' submenu."
  )

(defvar refdb-whichdb-menu-item
  ["Show Database Info" (refdb-whichdb) t]
  "Show information about the current database."
  )

(defvar refdb-create-docbook31-menu-item
  ["DocBook SGML 3.1" 
   (refdb-create-document "DocBook SGML 3.1") t]
  "RefDB menu item for creating a DocBook SGML 3.1 document."
  )

(defvar refdb-create-docbook40-menu-item
  ["DocBook SGML 4.0" 
   (refdb-create-document "DocBook SGML 4.0") t]
  "RefDB menu item for creating a DocBook SGML 4.0 document."
  )

(defvar refdb-create-docbook41-menu-item
  ["DocBook SGML 4.1" 
   (refdb-create-document "DocBook SGML 4.1") t]
  "RefDB menu item for creating a DocBook SGML 4.1 document."
  )

(defvar refdb-create-docbook41x-menu-item
  ["DocBook XML 4.1.2" 
   (refdb-create-document "DocBook XML 4.1.2") t]
  "RefDB menu item for creating a DocBook XML 4.1.2 document."
  )

(defvar refdb-create-docbook42x-menu-item
  ["DocBook XML 4.2" 
   (refdb-create-document "DocBook XML 4.2") t]
  "RefDB menu item for creating a DocBook XML 4.2 document."
  )

(defvar refdb-create-docbook43x-menu-item
  ["DocBook XML 4.3" 
   (refdb-create-document "DocBook XML 4.3") t]
  "RefDB menu item for creating a DocBook XML 4.3 document."
  )

(defvar refdb-create-teip4-menu-item
  ["TEI XML P4" 
   (refdb-create-document "TEI XML P4") t]
  "RefDB menu item for creating a TEI P4 document."
  )

(defvar refdb-create-html-menu-item
  ["HTML" 
   (refdb-transform "html") t]
  "RefDB menu item for creating HTML output from a document."
  )

(defvar refdb-create-xhtml-menu-item
  ["XHTML" 
   (refdb-transform "xhtml") t]
  "RefDB menu item for creating XHTML output from a document."
  )

(defvar refdb-create-pdf-menu-item
  ["PDF" 
   (refdb-transform "pdf") t]
  "RefDB menu item for creating PDF output from a document."
  )

(defvar refdb-create-rtf-menu-item
  ["RTF" 
   (refdb-transform "rtf") t]
  "RefDB menu item for creating RTF output from a document."
  )

(defvar refdb-create-postscript-menu-item
  ["PostScript" 
   (refdb-transform "ps") t]
  "RefDB menu item for creating PostScript output from a document."
  )

(defvar refdb-create-custom-menu-item
  ["Custom..." 
   (call-interactively 'refdb-transform-custom ) t]
  "RefDB menu item for creating output from a document with custom arguments."
  )

(defvar refdb-clean-output-menu-item
  ["Clean" 
   (refdb-transform "clean") t]
  "RefDB menu item for cleaning all output from a document."
  )

(defvar refdb-view-html-menu-item
  ["HTML" 
   (refdb-view-output "html") t]
  "RefDB menu item for viewing HTML output from a document."
  )

(defvar refdb-view-xhtml-menu-item
  ["XHTML" 
   (refdb-view-output "xhtml") t]
  "RefDB menu item for viewing XHTML output from a document."
  )

(defvar refdb-view-pdf-menu-item
  ["PDF" 
   (refdb-view-output "pdf") t]
  "RefDB menu item for viewing PDF output from a document."
  )

(defvar refdb-view-rtf-menu-item
  ["RTF" 
   (refdb-view-output "rtf") t]
  "RefDB menu item for viewing RTF output from a document."
  )

(defvar refdb-view-postscript-menu-item
  ["PostScript" 
   (refdb-view-output "ps") t]
  "RefDB menu item for viewing PostScript output from a document."
  )

(defvar refdb-convert-from-bibtex-menu-item
  ["From BibTeX" (refdb-import-from-bibtex) t]
  "Convert the current buffer from BibTeX to RIS."
  )

(defvar refdb-convert-from-copac-menu-item
  ["From copac" (refdb-import-from-copac) t]
  "Convert the current buffer from copac to RIS."
  )

(defvar refdb-convert-from-endnote-menu-item
  ["From EndNote" (refdb-import-from-endnote) t]
  "Convert the current buffer from EndNote to RIS."
  )

(defvar refdb-convert-from-isi-menu-item
  ["From ISI" (refdb-import-from-isi) t]
  "Convert the current buffer from ISI to RIS."
  )

(defvar refdb-convert-from-medline-menu-item
  ["From MedLine" (refdb-import-from-medline) t]
  "Convert the current buffer from MedLine to RIS."
  )

(defvar refdb-convert-from-mods-menu-item
  ["From MODS" (refdb-import-from-mods) t]
  "Convert the current buffer from MODS to RIS."
  )

(defvar refdb-convert-to-endnote-menu-item
  ["To EndNote" (refdb-export-to-endnote) t]
  "Convert the current buffer RIS to EndNote."
  )

(defvar refdb-convert-to-mods-menu-item
  ["To MODS" (refdb-export-to-mods) t]
  "Convert the current buffer from RIS to MODS."
  )

(defvar refdb-addstyle-menu-item
  ["Add Styles" (refdb-addstyle-on-buffer) t]
  "RefDB addstyle menu item."
  )

(defvar refdb-adduser-menu-item
  ["Add Users"
   (call-interactively 'refdb-adduser)
   t]
  "RefDB adduser menu item."
  )

(defvar refdb-addword-menu-item
  ["Add Journal Title Words"
   (call-interactively 'refdb-addword)
   t]
  "RefDB addword menu item."
  )

(defvar refdb-createdb-menu-item
  ["Create Databases"
   (call-interactively 'refdb-createdb)
   t]
  "RefDB createdb menu item."
  )

(defvar refdb-deletedb-menu-item
  ["Delete Databases"
   (call-interactively 'refdb-deletedb)
   t]
  "RefDB deletedb menu item."
  )

(defvar refdb-deletestyle-menu-item
  ["Delete Style"
   (call-interactively 'refdb-deletestyle)
   t]
  "RefDB deletestyle menu item."
  )

(defvar refdb-deleteuser-menu-item
  ["Delete Users"
   (call-interactively 'refdb-deleteuser)
   t]
  "RefDB deleteuser menu item."
  )

(defvar refdb-deleteword-menu-item
  ["Delete Journal Title Words"
   (call-interactively 'refdb-deleteword)
   t]
  "RefDB deleteword menu item."
  )

(defvar refdb-getstyle-menu-item
  ["Get Style"
   (call-interactively 'refdb-getstyle)
   t]
  "RefDB getstyle menu item."
  )

(defvar refdb-scankw-menu-item
  ["Run Keyword Scan"
   (call-interactively 'refdb-scankw)
   t]
  "RefDB scankw menu item."
  )

(defvar refdb-listdb-menu-item
  ["List Databases"
   (call-interactively 'refdb-listdb)
   t]
  "RefDB listdb menu item."
  )

(defvar refdb-liststyle-menu-item
  ["List Styles"
   (call-interactively 'refdb-liststyle)
   t]
  "RefDB liststyle menu item."
  )

(defvar refdb-listuser-menu-item
  ["List Users"
   (call-interactively 'refdb-listuser)
   t]
  "RefDB listuser menu item."
  )

(defvar refdb-listword-menu-item
  ["List Journal Title Words"
   (call-interactively 'refdb-listword)
   t]
  "RefDB listword menu item."
  )

(defvar refdb-viewstat-menu-item
  ["View Server Information" (refdb-viewstat) t]
  "RefDB viewstat menu item."
  )

(defvar refdb-init-refdb-menu-item
  ["Initialize System Database" (refdb-init-refdb) t]
  "RefDB initialize refdb menu item."
  )

(defvar refdb-backup-database-menu-item
  ["Backup Reference Databases" (refdb-backup-database) t]
  "RefDB backup refdb menu item."
  )

(defvar refdb-restore-database-menu-item
  ["Restore Reference Databases" (refdb-restore-database) t]
  "RefDB restore refdb menu item."
  )

(defvar refdb-startd-menu-item
  ["Start Application Server on localhost" (refdb-start-server) t]
  "RefDB startd menu item."
  )

(defvar refdb-stopd-menu-item
  ["Stop Application Server on localhost" (refdb-stop-server) t]
  "RefDB stopd menu item."
  )

(defvar refdb-restartd-menu-item
  ["Restart Application Server on localhost" (refdb-restart-server) t]
  "RefDB restartd menu item."
  )

(defvar refdb-reloadd-menu-item
  ["Reload Application Server on localhost" (refdb-reload-server) t]
  "RefDB reloadd menu item."
  )

(defvar refdb-edit-refdbcrc-menu-item
  ["refdbc \(user\)" (refdb-edit-refdbcrc) t]
  "RefDB configure refdbc menu item"
  )

(defvar refdb-edit-refdbarc-menu-item
  ["refdba \(user\)" (refdb-edit-refdbarc) t]
  "RefDB configure refdba menu item"
  )

(defvar refdb-edit-refdbibrc-menu-item
  ["refdbib \(user\)" (refdb-edit-refdbibrc) t]
  "RefDB configure refdbib menu item"
  )

(defvar refdb-edit-global-refdbdrc-menu-item
  ["refdbd \(global\)" (refdb-edit-global-refdbdrc) t]
  "RefDB configure refdbd menu item"
  )

(defvar refdb-edit-global-refdbcrc-menu-item
  ["refdbc \(global\)" (refdb-edit-global-refdbcrc) t]
  "RefDB configure refdbc globally menu item"
  )

(defvar refdb-edit-global-refdbarc-menu-item
  ["refdba \(global\)" (refdb-edit-global-refdbarc) t]
  "RefDB configure refdba globally menu item"
  )

(defvar refdb-edit-global-refdbibrc-menu-item
  ["refdbib \(global\)" (refdb-edit-global-refdbibrc) t]
  "RefDB configure refdbib globally menu item"
  )

;;*************************************************************
;; refdbc commands
;;*************************************************************
(defun refdb-show-messages ()
  "Show RefDB messages buffer (stderr output from RefDB apps)."
  (interactive)
  (pop-to-buffer "*refdb-messages*")
)

(defun refdb-show-version ()
  "Show `redb-mode' and refdb version."
  (interactive)
  (message
   "refdb-mode %s running against RefDB %s"
   (car
    (cdr
     (split-string  "$Revision: 1.28 $")
     )
    )
   (car
    (cdr (split-string
	  (with-output-to-string
	    (with-current-buffer
		standard-output
	      (call-process
	       shell-file-name nil '(t nil) nil shell-command-switch
	       (format "%s -v 2>&1"
		       refdb-refdbc-program
		       )
	       )
	      )
	    )
	  )
	 )
    )
   )
  )

(defun refdb-show-manual ()
  "Display the refdb-mode node of the info documentation system."
  (interactive)
  (info "refdb-mode")
  )

(defun refdb-determine-input-type ()
  "Set RefDB output type according to user prefs.
Unless user has specified that input type should never be RISX, or
specified that input type should always be RISX, check to see what the
name of the major mode is, and if the major mode name contains 'xml'
or 'sgml', set the input type to RISX.  Otherwise, set the input type
to RIS."
  (if (and refdb-input-type-risx
	   (not (eq refdb-input-type-risx t)))
      (if
	  (not (null
		(string-match
		 "sgml\\|xml"
		 (downcase (symbol-name major-mode)))))
	  (progn
	    (setq refdb-input-type "risx")
	    (message "Input type set to risx.")
	    )
	(progn
	  (setq refdb-input-type "ris")
	  (message "Input type set to ris.")
	  )
	)
    (setq refdb-input-type "ris")
    (message "Input type set to ris.")
    )
  refdb-input-type
  )

(defun refdb-add-or-update-ref-on-region (mode)
  "Add \(MODE=add\) or update \(MODE=update\) references to/in the current database. For risx input, the whole buffer will be used. For RIS input, the selected region or the whole buffer (if mark is not set) will be added or updated."
  (interactive)
  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; addref output in separate buffer instead of minibuffer
  (setq resize-mini-windows nil)
  (refdb-determine-input-type)
  ;; start/end set the region properly. Must be the whole buffer for
  ;; risx. With RIS, if a mark is set, the region between point and
  ;; mark is used. If no mark is set, the whole buffer is used.
  (let ((start (if (equal refdb-input-type "risx")
		   (point-min)
		 (if (mark)
		     (region-beginning)
		   (point-min))))
	(end (if (equal refdb-input-type "risx")
		 (point-max)
	       (if (mark)
		   (region-end)
		 (point-max))))
	(command-string (if (equal mode "add")
			    "addref"
			  "updateref"))
	(message-mode (if (equal mode "add")
			  "Adding"
			"Updating"))
	(message-region (if (or (equal refdb-input-type "risx")
				(not (mark)))
			    "current buffer"
			  "selected region")))
    (if (not (eq (length refdb-database) 0))
	(progn
	  (message "%s references in %s to %s database..." message-mode message-region refdb-database)
	  (let ((coding-system-for-read buffer-file-coding-system)
		(coding-system-for-write buffer-file-coding-system))
	    (shell-command-on-region
	     start end
	     (format
	      "%s %s -C %s %s -d %s -t %s"
	      refdb-refdbc-program
	      refdb-refdbc-options
	      command-string
	      refdb-addref-options
	      refdb-database
	      refdb-input-type
	      )
	     "*refdb-output*" nil "*refdb-messages*"))
	  (message
	   "Displaying output for '%s %s -C %s %s -d %s -t %s'...done"
	   refdb-refdbc-program
	   refdb-refdbc-options
	   command-string
	   refdb-addref-options
	   refdb-database
	   refdb-input-type
	   )
	  (display-buffer "*refdb-output*")
	  (with-current-buffer "*refdb-output*"
	    (refdb-output-mode))
	  )

      ;; else if no databases specified, prompt to select from available
      ;; databases, then re-call command
      (call-interactively 'refdb-select-database)
      (refdb-add-or-update-ref-on-region mode)
      )
    (message "%s references in %s to %s database...done" message-mode message-region refdb-database)
    )
  ;; set resize-mini-windows back to default value
  (setq resize-mini-windows (get 'resize-mini-windows 'standard-value))
  (if refdb-update-completion-lists-flag
      (refdb-update-completion-lists))
  )

(defun refdb-addref-on-region ()
  "Add references to the current database. For risx input, the whole buffer will be used. For RIS input, the selected region will be added."
  (refdb-add-or-update-ref-on-region "add")
  )

(defun refdb-updateref-on-region ()
  "Update references in the current database. For risx input, the whole buffer will be used. For RIS input, the selected region will be updated."
  (refdb-add-or-update-ref-on-region "update")
  )

(defun refdb-deleteref-on-region ()
  "Delete all references in region from current database."
  (interactive)
  (if (yes-or-no-p
       "Really delete all references in the current region? "
       )
      ;; temporarily set resize-mini-windows to nil to force Emacs to show
      ;; addref output in separate buffer instead of minibuffer
      (progn
	(setq resize-mini-windows nil)
	(if (not (eq (length refdb-database) 0))
	    (if (mark)
		(progn
		  (refdb-determine-input-type)
		  (message "Deleting references in selected region from %s database..." refdb-database)
		  (shell-command-on-region
		   (point) (mark)
		   (format
		    "%s %s -C deleteref %s -d %s"
		    refdb-refdbc-program
		    refdb-refdbc-options
		    refdb-deleteref-options
		    refdb-database
		    )
		   "*refdb-output*" nil "*refdb-messages*")
		  (message
		   "Displaying output for '%s %s -C deleteref %s -d %s'...done"
		   refdb-refdbc-program
		   refdb-refdbc-options
		   refdb-deleteref-options
		   refdb-database
		   )
		  (if (not refdb-display-messages-flag)
		      (display-buffer "*refdb-output*")
		    (pop-to-buffer "*refdb-messages*")
		    (pop-to-buffer "*refdb-output*")
		    )
		  (with-current-buffer "*refdb-output*"
		    (refdb-output-mode))
		  )
	      (error "No region marked")
	      )
	  ;; else if no databases specified, prompt to select from available
	  ;; databases, then re-call command
	  (call-interactively 'refdb-select-database)
	  (refdb-deleteref-on-region)
	  )
	(message "Deleting references in selected region from %s database...done" refdb-database)
	;; set resize-mini-windows back to default value
	(setq resize-mini-windows (get 'resize-mini-windows 'standard-value))
	(if refdb-update-completion-lists-flag
	    (refdb-update-completion-lists))
	)
    (error "Deletion aborted")
    )
  )

(defun refdb-deleteref (idlist)
  "Delete RefDB datasets by ID."
  (interactive (list (read-string (format "Delete reference ID list: "))))

  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (if (not (eq (length refdb-database) 0))
      (shell-command
       (format
	"%s %s -C deleteref %s -d %s "
	refdb-refdbc-program
	refdb-refdbc-options
	idlist
	refdb-database
	)
       "*refdb-output*" "*refdb-messages*")
    ;; else if no db specified, prompt to select from available dbs and
    ;; then call `refdb-deleteref' with same values
    (progn
      (call-interactively 'refdb-select-database)
      (refdb-deleteref idlist)
      )
    )
  (message
   (format
    "Displaying output for '%s %s -C deleteref %s -d %s'...done"
    refdb-refdbc-program
    refdb-refdbc-options
    idlist
    refdb-database
    )
   )
  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  (with-current-buffer "*refdb-output*"
    (refdb-output-mode))
  (setq resize-mini-windows resize-mini-windows-default)
  (if refdb-update-completion-lists-flag
      (refdb-update-completion-lists))
  )

(defun refdb-message-getting-refs (field mode value)
  "Emit appropriate status message for FIELD and VALUE.
This function is called by the various refdb-getref-by commands."
  (message
   "Getting datasets for %s %s %s ..."
   field
   mode
   value
   )
  )

(defun refdb-message-getting-refs-done (field mode value)
  "Emit appropriate status message for FIELD and VALUE.
This function is called by the various refdb-getref-by commands."
  (message
   "Getting datasets for %s %s %s...done"
   field
   mode
   value
   )
  )

(defun refdb-getref-by-field (field value)
  "Display all RefDB datasets that match the specified FIELD and VALUE.
You shouldn't call this function directly.  Instead call, e.g.,
`refdb-getref-by-author'."
  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (let ((formatstring
	(if (equal refdb-data-output-format 'more)
	    (format "\'%s\'"
		    ;; turn list of symbols into one big string
		    (mapconcat
		     'symbol-name
		     refdb-data-output-additional-fields
		     ""
		     )
		    )
	  (upcase (symbol-name refdb-data-output-format))
	  )
	))
    (if (not (eq (length refdb-database) 0))
	(shell-command
	 (format
	  "%s %s -C getref \":%s:=\'%s\'\" %s -d %s -t %s -s %s"
	  refdb-refdbc-program
	  refdb-refdbc-options
	  field
	  value
	  refdb-getref-options
	  refdb-database
	  refdb-data-output-type
	  formatstring
	  )
	 "*refdb-output*" "*refdb-messages*")
      ;; else if no db specified, prompt to select from available dbs and
      ;; then call `refdb-getref-by-field' with same values
      (progn
	(call-interactively 'refdb-select-database)
	(refdb-getref-by-field field value)
	)
      )
    (message
     (format
      "Displaying output for '%s %s -C getref \":%s:='%s'\" %s -d %s -t %s -s %s'...done"
      refdb-refdbc-program
      refdb-refdbc-options
      field
      value
      refdb-getref-options
      refdb-database
      refdb-data-output-type
      formatstring
      )
     )
    (if (not refdb-display-messages-flag)
	(display-buffer "*refdb-output*")
      (pop-to-buffer "*refdb-messages*")
      (pop-to-buffer "*refdb-output*")
      )
    (refdb-output-buffer-choose-mode)
    (refdb-output-buffer-choose-encoding refdb-data-output-type)
    (setq resize-mini-windows resize-mini-windows-default)
    )
  )

(defun refdb-getref-by-field-regexp (field value)
  "Display all RefDB datasets that match the specified FIELD and VALUE (regular expression). You shouldn't call this function directly.  Instead call, e.g.,
`refdb-getref-by-author-regexp'."
  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (let ((formatstring
	(if (equal refdb-data-output-format 'more)
	    (format "\\\"%s\\\""
		    ;; turn list of symbols into one big string
		    (mapconcat
		     'symbol-name
		     refdb-data-output-additional-fields
		     " "
		     )
		    )
	  (upcase (symbol-name refdb-data-output-format))
	  )
	))
    (if (not (eq (length refdb-database) 0))
	(shell-command
	 (format
	  "%s %s -C getref \":%s:~\'%s\'\" %s -d %s -t %s -s %s"
	  refdb-refdbc-program
	  refdb-refdbc-options
	  field
	  value
	  refdb-getref-options
	  refdb-database
	  refdb-data-output-type
	  formatstring
	  )
	 "*refdb-output*" "*refdb-messages*")
      ;; else if no db specified, prompt to select from available dbs and
      ;; then call `refdb-getref-by-field-regexp' with same values
      (progn
	(call-interactively 'refdb-select-database)
	(refdb-getref-by-field-regexp field value)
	)
      )
    (message
     (format
      "Displaying output for '%s %s -C getref \":%s:~'%s'\" %s -d %s -t %s -s %s'...done"
      refdb-refdbc-program
      refdb-refdbc-options
      field
      value
      refdb-getref-options
      refdb-database
      refdb-data-output-type
      formatstring
      )
     )
    (if (not refdb-display-messages-flag)
	(display-buffer "*refdb-output*")
      (pop-to-buffer "*refdb-messages*")
      (pop-to-buffer "*refdb-output*")
      )
    (refdb-output-buffer-choose-mode)
    (refdb-output-buffer-choose-encoding refdb-data-output-type)
    (setq resize-mini-windows resize-mini-windows-default)
    )
  )

(defun refdb-getref-by-field-on-region (field)
  (interactive)
  (if (mark)
      (progn
	(let ((value (concat
		      refdb-regexp-query-string
		      (buffer-substring (mark) (point))
		      refdb-regexp-query-string)))
	  (if refdb-use-regexp-match-in-getref-on-region-flag
	      (refdb-getref-by-field-regexp field value)
	    (refdb-getref-by-field field value))
	  )
	)
    (error "No region selected")
    )
  )

(defun refdb-output-buffer-choose-mode ()
  "Choose appropriate major mode for RefDB output buffer."
  (if (or
       (eq refdb-data-output-type 'db31)
       (eq refdb-data-output-type 'db31x)
       (eq refdb-data-output-type 'teix)
       (eq refdb-data-output-type 'risx)
       (eq refdb-data-output-type 'xhtml)
       )
      (if (functionp 'nxml-mode)
	  (nxml-mode)
	(if (functionp 'xml-mode)
	    (xml-mode)                                        
	  (refdb-output-mode))
	)
    (if	(and
	 (or
	  (eq refdb-data-output-type 'db31)
	  (eq refdb-data-output-type 'html)
	  )
	 (functionp 'sgml-mode))
	(sgml-mode)
      (if (and
	   (eq refdb-data-output-type 'ris)
	   (functionp 'ris-mode)
	   )
	  (ris-mode)
	(if (eq refdb-data-output-type 'bibtex)
	    (bibtex-mode)
	  (refdb-output-mode))
	)
      )
    )
  )

(defun refdb-output-buffer-choose-encoding (hint)
  "Choose appropriate character encoding for RefDB output buffer."
  (if (or
       (eq hint 'db31)
       (eq hint 'db31x)
       (eq hint 'teix)
       (eq hint 'risx)
       (eq hint 'xhtml)
       (eq hint 'citestylex)
       (eq hint 'xnote)
       (eq hint 'mods)
       )
      (progn
	;; todo: the mapping should probably also be customizable, e.g. for line endings
	;; and little/big endian utf-16
	(cond ((looking-at "<\\?xml version=\"1\\.0\" encoding=\"\\(utf-8\\|UTF-8\\)\"")
	       (set-buffer-file-coding-system 'utf-8-unix))
	      ((looking-at "<\\?xml version=\"1\\.0\" encoding=\"\\(utf-16\\|UTF-16\\)\"")
	       (set-buffer-file-coding-system 'utf-16-le-unix))
	      ((looking-at "<\\?xml version=\"1\\.0\" encoding=\"\\(iso-8859-1\\|ISO-8859-1\\)\"")
	       (set-buffer-file-coding-system 'latin1-unix))
	      ((looking-at "<\\?xml version=\"1\\.0\" encoding=\"\\(us-ascii\\|US-ASCII\\)\"")
	       (set-buffer-file-coding-system 'us-ascii-unix))
	      (t
	       (set-buffer-file-coding-system 'iso-latin-1))
	  )
	)
    (set-buffer-file-coding-system refdb-default-ris-encoding)
    )
  )

(defun refdb-getref-by-author (author)
  "Display all RefDB datasets matching AUTHOR."
  (interactive (list 
		(completing-read "Author: "
				 (refdb-make-alist-from-list refdb-current-authors-list))
		)
	       )
  (refdb-message-getting-refs 'author "=" author)
  (refdb-getref-by-field "AU" author)
  (refdb-message-getting-refs-done 'author "=" author)
  )

(defun refdb-getref-by-author-regexp (author)
  "Display all RefDB datasets regexp-matching AUTHOR."
  (interactive (list 
		(completing-read 
		 (format "Author %s: " refdb-regexp-prompt)
		 (refdb-make-alist-from-list refdb-current-authors-list))
		)
	       )
  (refdb-message-getting-refs 'author "like" author)
  (refdb-getref-by-field-regexp "AU" author)
  (refdb-message-getting-refs-done 'author "like" author)
  )

(defun refdb-getref-by-title (title)
  "Display all RefDB datasets matching TITLE."
  (interactive (list (read-string (format "Title: "))))
  (refdb-message-getting-refs 'title "=" title)
  (refdb-getref-by-field "TI" title)
  (refdb-message-getting-refs-done 'title "=" title)
  )

(defun refdb-getref-by-title-regexp (title)
  "Display all RefDB datasets regexp-matching TITLE."
  (interactive (list (read-string (format "Title %s: " refdb-regexp-prompt))))
  (refdb-message-getting-refs 'title "like" title)
  (refdb-getref-by-field-regexp "TI" title)
  (refdb-message-getting-refs-done 'title "like" title)
  )

(defun refdb-getref-by-keyword (keyword)
  "Display all RefDB datasets matching KEYWORD."
  (interactive (list 
		(completing-read "Keyword: "
				 (refdb-make-alist-from-list refdb-current-keywords-list))
		)
	       )
  (refdb-message-getting-refs 'keyword "=" keyword)
  (refdb-getref-by-field "KW" keyword)
  (refdb-message-getting-refs-done 'keyword "=" keyword)
  )

(defun refdb-getref-by-keyword-regexp (keyword)
  "Display all RefDB datasets regexp-matching KEYWORD."
  (interactive (list 
		(completing-read 
		 (format "Keyword %s: " refdb-regexp-prompt)
		 (refdb-make-alist-from-list refdb-current-keywords-list))
		)
	       )
  (refdb-message-getting-refs 'keyword "like" keyword)
  (refdb-getref-by-field-regexp "KW" keyword)
  (refdb-message-getting-refs-done 'keyword "like" keyword)
  )

(defun refdb-getref-by-periodical (periodical)
  "Display all RefDB datasets matching PERIODICAL."
  (interactive (list 
		(completing-read "Periodical: "
				 (refdb-make-alist-from-list refdb-current-periodicals-list))
		)
	       )
  (refdb-message-getting-refs 'periodical "=" periodical)
  (refdb-getref-by-field "JX" periodical)
  (refdb-message-getting-refs-done 'periodical "=" periodical)
  )

(defun refdb-getref-by-periodical-regexp (periodical)
  "Display all RefDB datasets regexp-matching PERIODICAL."
  (interactive (list 
		(completing-read 
		 (format "Periodical %s: " refdb-regexp-prompt)
		 (refdb-make-alist-from-list refdb-current-periodicals-list))
		)
	       )
  (refdb-message-getting-refs 'periodical "like" periodical)
  (refdb-getref-by-field-regexp "JX" periodical)
  (refdb-message-getting-refs-done 'periodical "like" periodical)
  )

(defun refdb-getref-by-id (id)
  "Display all RefDB datasets matching ID."
  (interactive (list (read-string (format "ID: "))))
  (refdb-message-getting-refs 'id "=" id)
  (refdb-getref-by-field "ID" id)
  (refdb-message-getting-refs-done 'id "=" id)
  )

(defun refdb-getref-by-citekey (citekey)
  "Display all RefDB datasets matching CITEKEY."
  (interactive (list (read-string (format "Citation Key: "))))
  (refdb-message-getting-refs 'citekey "=" citekey)
  (refdb-getref-by-field "CK" citekey)
  (refdb-message-getting-refs-done 'citekey "=" citekey)
  )

(defun refdb-getref-by-advanced-search (searchstring)
  "Display all RefDB datasets matching SEARCHSTRING."
  (interactive "sSearch string: ")
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (let ((formatstring
	 (if (equal refdb-data-output-format 'more)
	     (format "\\\"%s\\\""
		     ;; turn list of symbols into one big string
		     (mapconcat
		      'symbol-name
		      refdb-data-output-additional-fields
		      " "
		      )
		     )
	   (upcase (symbol-name refdb-data-output-format))
	   )
	 ))
    (message (format "Getting datasets for search string %s ..." searchstring))
    (if (not (eq (length refdb-database) 0))
	(progn
	  (shell-command
	   (format
	    "%s %s -C getref %s %s -d %s -t %s -s %s"
	    refdb-refdbc-program
	    refdb-refdbc-options
	    searchstring
	    refdb-getref-options
	    refdb-database
	    refdb-data-output-type
	    formatstring
	    )
	   "*refdb-output*" "*refdb-messages*")
	
	  )
      ;; else if no db specified, prompt to select from available dbs and
      ;; then call `refdb-getref-by-advanced-search' with same values
      (progn
	(call-interactively 'refdb-select-database)
	(refdb-getref-by-advanced-search searchstring)
	)
      )
    (message
     (format
      "Displaying output for '%s %s -C getref %s %s -d %s -t %s -s %s'...done"
      refdb-refdbc-program
      refdb-refdbc-options
      searchstring
      refdb-getref-options
      refdb-database
      refdb-data-output-type
      formatstring
      )
     )
    (if (not refdb-display-messages-flag)
	(display-buffer "*refdb-output*")
      (pop-to-buffer "*refdb-messages*")
      (pop-to-buffer "*refdb-output*")
      )
    (refdb-output-buffer-choose-mode)
    (refdb-output-buffer-choose-encoding refdb-data-output-type)
    (setq resize-mini-windows resize-mini-windows-default)
    )
  (message (format "Getting datasets for search string %s...done" searchstring))
  )

(defun refdb-getref-by-author-on-region ()
  "Display all RefDB datasets matching AUTHOR in region."
  (refdb-message-getting-refs 'author "=" "REGION")
  (refdb-getref-by-field-on-region "AX")
  (refdb-message-getting-refs-done 'author "=" "REGION")
  )

(defun refdb-getref-by-title-on-region ()
  "Display all RefDB datasets matching TITLE in region."
  (refdb-message-getting-refs 'title "=" "REGION")
  (refdb-getref-by-field-on-region "TX")
  (refdb-message-getting-refs-done 'title "=" "REGION")
  )

(defun refdb-getref-by-keyword-on-region ()
  "Display all RefDB datasets matching KEYWORD in region."
  (refdb-message-getting-refs 'keyword "=" "REGION")
  (refdb-getref-by-field-on-region "KW")
  (refdb-message-getting-refs-done 'keyword "=" "REGION")
  )

(defun refdb-getref-by-periodical-on-region ()
  "Display all RefDB datasets matching PERIODICAL in region."
  (refdb-message-getting-refs 'periodical "=" "REGION")
  (refdb-getref-by-field-on-region "JX")
  (refdb-message-getting-refs-done 'periodical "=" "REGION")
  )

(defun refdb-getref-by-id-on-region ()
  "Display all RefDB datasets matching ID in region."
  (refdb-message-getting-refs 'id "=" "REGION")
  (refdb-getref-by-field-on-region "ID")
  (refdb-message-getting-refs-done 'id "=" "REGION")
  )

(defun refdb-getref-by-citekey-on-region ()
  "Display all RefDB datasets matching CITEKEY in region."
  (refdb-message-getting-refs 'citekey "=" "REGION")
  (refdb-getref-by-field-on-region "CK")
  (refdb-message-getting-refs-done 'citekey "=" "REGION")
  )

(defun refdb-getref-from-citation()
  "Display all references cited in the citation containing Point."
  (interactive)
  (save-excursion
    (let ((eoc (re-search-forward "</citation *>\\|</seg *>\\|}" nil t))
	  (id-string))
      (if (null
	   (string-match
	    "sgml\\|xml"
	    (downcase (symbol-name major-mode))))
	  ; most likely a LaTeX document
	  (progn
	    (re-search-backward "{" nil t)
	    (while (re-search-forward "\\([^{][^,}]+\\)[,\\|}]" eoc t)
	      (let ((target (match-string 1 nil)))
		(if (string-match "^[0-9]$" target)
		    (setq id-string (concat id-string " OR :ID:=" target))
		  (setq id-string (concat id-string " OR :CK:=" target)))
		)
	      )
	    )
	; else: SGML/XML document
	(re-search-backward "<citation role=\"REFDB\" *>\\|<seg type=\"REFDBCITATION\".*>" nil t)
	;; in multiple citations the first linkend is from the multiple definition but this doesn't hurt the query
	(while (re-search-forward "\\(target\\|linkend\\)=\"ID\\([^-\"]+\\)" eoc t)
	  (let ((target (match-string 2 nil)))
	    ;; see whether ID is a numeric ID or an alphanumeric CK
	    (if (string-match "^[0-9]$" target)
		(setq id-string (concat id-string " OR :ID:=" target))
	      (setq id-string (concat id-string " OR :CK:=" target)))
	    )
	  )
	)
      (if (not (eq (length id-string) 0))
	  ;; each cycle adds an " OR " at the beginning. We don't need the first one
	  (refdb-getref-by-advanced-search (substring id-string 4))
;	  (message id-string)
	(error "No citation found in the source document"))
      )
    )
  )

(defun refdb-pickref (idlist)
  "Add references to your personal reference list."
  (interactive (list (read-string (format "ID list: "))))

  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (if (not (eq (length refdb-database) 0))
      (shell-command
       (format
	"%s %s -C pickref %s -d %s "
	refdb-refdbc-program
	refdb-refdbc-options
	idlist
	refdb-database
	)
       "*refdb-output*" "*refdb-messages*")
    ;; else if no db specified, prompt to select from available dbs and
    ;; then call `refdb-pickref' with same values
    (progn
      (call-interactively 'refdb-select-database)
      (refdb-pickref idlist)
      )
    )
  (message
   (format
    "Displaying output for '%s %s -C pickref %s -d %s'...done"
    refdb-refdbc-program
    refdb-refdbc-options
    idlist
    refdb-database
    )
   )
  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  (refdb-output-buffer-mode)
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-dumpref (idlist)
  "Remove references from your personal reference list."
  (interactive (list (read-string (format "ID list: "))))

  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (if (not (eq (length refdb-database) 0))
      (shell-command
       (format
	"%s %s -C dumpref %s -d %s "
	refdb-refdbc-program
	refdb-refdbc-options
	idlist
	refdb-database
	)
       "*refdb-output*" "*refdb-messages*")
    ;; else if no db specified, prompt to select from available dbs and
    ;; then call `refdb-dumpref' with same values
    (progn
      (call-interactively 'refdb-select-database)
      (refdb-dumpref idlist)
      )
    )
  (message
   (format
    "Displaying output for '%s %s -C dumpref %s -d %s'...done"
    refdb-refdbc-program
    refdb-refdbc-options
    idlist
    refdb-database
    )
   )
  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  (refdb-output-buffer-mode)
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-notes-output-buffer-choose-mode ()
  "Choose appropriate major mode for RefDB notes output buffer."
  (if (or
       (eq refdb-notesdata-output-type 'xnote)
       (eq refdb-notesdata-output-type 'xhtml)
       )
      (if (functionp 'nxml-mode)
	  (nxml-mode)
	(if (functionp 'xml-mode)
	    (xml-mode)
	  (refdb-output-mode)))
    (if (and
	 (eq refdb-notesdata-output-type 'html)
	 (functionp 'sgml-mode)
	 )
	(sgml-mode)
      (refdb-output-mode))
    )
  )

(defun refdb-addnote-on-buffer ()
  "Add all notes in buffer to current database."
  (interactive)
  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; addref output in separate buffer instead of minibuffer
  (setq resize-mini-windows nil)
  (if (not (eq (length refdb-database) 0))
      (progn
	;; ToDo: make sure we have xnote data
	; (refdb-determine-input-type)
	(message "Adding notes in the current buffer to %s database..." refdb-database)
	(shell-command-on-region
	 (point-min) (point-max)
	 (format
	  "%s %s -C addnote %s -d %s -t %s"
	  refdb-refdbc-program
	  refdb-refdbc-options
	  refdb-addnote-options
	  refdb-database
	  refdb-input-type
	  )
	 "*refdb-output*" nil "*refdb-messages*")
	(message
	 "Displaying output for '%s %s -C addnote %s -d %s -t %s'...done"
	 refdb-refdbc-program
	 refdb-refdbc-options
	 refdb-addnote-options
	 refdb-database
	 refdb-input-type
	 )
	(display-buffer "*refdb-output*")
	(with-current-buffer "*refdb-output*"
	  (refdb-output-mode))
	)
    ;; else if no databases specified, prompt to select from available
    ;; databases, then re-call command
    (call-interactively 'refdb-select-database)
    (refdb-addnote-on-buffer)
    )
  (message "Adding notes in the current buffer to %s database...done" refdb-database)
  ;; set resize-mini-windows back to default value
  (setq resize-mini-windows (get 'resize-mini-windows 'standard-value))
  (if refdb-update-completion-lists-flag
      (refdb-update-completion-lists))
  )

(defun refdb-updatenote-on-buffer ()
  "Update all notes in buffer in current database."
  (interactive)
  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; updateref output in separate buffer instead of minibuffer
  (setq resize-mini-windows nil)
  (if (not (eq (length refdb-database) 0))
      (progn
	    ;; todo: make sure we have xnote data
;	    (refdb-determine-input-type)
	(message "Updating notes in the current buffer in %s database..." refdb-database)
	(shell-command-on-region
	 (point-min) (point-max)
	 (format
	  "%s %s -C updatenote %s -d %s -t %s"
	  refdb-refdbc-program
	  refdb-refdbc-options
	  refdb-updateref-options
	  refdb-database
	  refdb-input-type
	  )
	 "*refdb-output*" nil "*refdb-messages*")
	(message
	 "Displaying output for '%s %s -C updatenote %s -d %s -t %s'...done"
	 refdb-refdbc-program
	 refdb-refdbc-options
	 refdb-addref-options
	 refdb-database
	 refdb-input-type
	 )
	(display-buffer "*refdb-output*")
	(with-current-buffer "*refdb-output*"
	  (refdb-output-mode))
	)
    ;; else if no databases specified, prompt to select from available
    ;; databases, then re-call command
    (call-interactively 'refdb-select-database)
    (refdb-updatenote-on-buffer)
    )
  (message "Updating notes in the current buffer in %s database...done" refdb-database)
  ;; set resize-mini-windows back to default value
  (setq resize-mini-windows (get 'resize-mini-windows 'standard-value))
  (if refdb-update-completion-lists-flag
      (refdb-update-completion-lists))
  )

(defun refdb-deletenote-on-region ()
  "Delete all notes in region from current database."
  (interactive)
  (if (yes-or-no-p
       "Really delete all notes in the current region? "
       )
      ;; temporarily set resize-mini-windows to nil to force Emacs to show
      ;; addref output in separate buffer instead of minibuffer
      (progn
	(setq resize-mini-windows nil)
	(if (not (eq (length refdb-database) 0))
	    (if (mark)
		(progn
		  ;; todo: make sure we have xnote data
;		  (refdb-determine-input-type)
		  (message "Deleting notes in selected region from %s database..." refdb-database)
		  (shell-command-on-region
		   (point) (mark)
		   (format
		    "%s %s -C deletenote -d %s"
		    refdb-refdbc-program
		    refdb-refdbc-options
		    refdb-database
		    )
		   "*refdb-output*" nil "*refdb-messages*")
		  (message
		   "Displaying output for '%s %s -C deletenote -d %s'...done"
		   refdb-refdbc-program
		   refdb-refdbc-options
		   refdb-database
		   )
		  (if (not refdb-display-messages-flag)
		      (display-buffer "*refdb-output*")
		    (pop-to-buffer "*refdb-messages*")
		    (pop-to-buffer "*refdb-output*")
		    )
		  (with-current-buffer "*refdb-output*"
		    (refdb-output-mode))
		  )
	      (error "No region marked")
	      )
	  ;; else if no databases specified, prompt to select from available
	  ;; databases, then re-call command
	  (call-interactively 'refdb-select-database)
	  (refdb-deletenote-on-region)
	  )
	(message "Deleting notes in selected region from %s database...done" refdb-database)
	;; set resize-mini-windows back to default value
	(setq resize-mini-windows (get 'resize-mini-windows 'standard-value))
	(if refdb-update-completion-lists-flag
	    (refdb-update-completion-lists))
	)
    (error "Deletion aborted")
    )
  )

(defun refdb-deletenote (idlist)
  "Delete RefDB notes by ID."
  (interactive (list (read-string (format "NID list: "))))

  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (if (not (eq (length refdb-database) 0))
      (shell-command
       (format
	"%s %s -C deletenote %s -d %s "
	refdb-refdbc-program
	refdb-refdbc-options
	idlist
	refdb-database
	)
       "*refdb-output*" "*refdb-messages*")
    ;; else if no db specified, prompt to select from available dbs and
    ;; then call `refdb-deletenote' with same values
    (progn
      (call-interactively 'refdb-select-database)
      (refdb-deletenote idlist)
      )
    )
  (message
   (format
    "Displaying output for '%s %s -C deletenote %s -d %s'...done"
    refdb-refdbc-program
    refdb-refdbc-options
    idlist
    refdb-database
    )
   )
  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  (with-current-buffer "*refdb-output*"
      (refdb-output-mode))
  (setq resize-mini-windows resize-mini-windows-default)
  (if refdb-update-completion-lists-flag
      (refdb-update-completion-lists))
  )

(defun refdb-message-getting-notes (field mode value)
  "Emit appropriate status message for FIELD and VALUE.
This function is called by the various refdb-getnote-by commands."
  (message
   "Getting notes for %s %s %s ..."
   field
   mode
   value
   )
  )

(defun refdb-message-getting-notes-done (field mode value)
  "Emit appropriate status message for FIELD and VALUE.
This function is called by the various refdb-getnote-by commands."
  (message
   "Getting notes for %s %s %s...done"
   field
   mode
   value
   )
  )

(defun refdb-message-getting-notes-by-link (field mode value)
  "Emit appropriate status message for FIELD and VALUE.
This function is called by the various refdb-getnote-by commands."
  (message
   "Getting notes linked to %s %s %s ..."
   field
   mode
   value
   )
  )

(defun refdb-message-getting-notes-by-link-done (field mode value)
  "Emit appropriate status message for FIELD and VALUE.
This function is called by the various refdb-getnote-by commands."
  (message
   "Getting notes linked to %s %s %s...done"
   field
   mode
   value
   )
  )

(defun refdb-getnote-by-field (field value)
  "Display all RefDB notes that match the specified FIELD and VALUE.
You shouldn't call this function directly.  Instead call, e.g.,
`refdb-getnote-by-title'."
  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (let ((formatstring
	(if (equal refdb-data-output-format 'more)
	    (format "\\\"%s\\\""
		    ;; turn list of symbols into one big string
		    (mapconcat
		     'symbol-name
		     refdb-data-output-additional-fields
		     " "
		     )
		    )
	  (upcase (symbol-name refdb-data-output-format))
	  )
	))
    (if (not (eq (length refdb-database) 0))
	(shell-command
	 (format
	  "%s %s -C getnote \":%s:=\'%s\'\" %s -d %s -t %s -s %s"
	  refdb-refdbc-program
	  refdb-refdbc-options
	  field
	  value
	  refdb-getnote-options
	  refdb-database
	  refdb-notesdata-output-type
	  formatstring
	  )
	 "*refdb-output*" "*refdb-messages*")
      ;; else if no db specified, prompt to select from available dbs and
      ;; then call `refdb-getnote-by-field' with same values
      (progn
	(call-interactively 'refdb-select-database)
	(refdb-getnote-by-field field value)
	)
      )
    (message
     (format
      "Displaying output for '%s %s -C getnote \":%s:=\'%s\'\" %s -d %s -t %s -s %s'...done"
      refdb-refdbc-program
      refdb-refdbc-options
      field
      value
      refdb-getnote-options
      refdb-database
      refdb-notesdata-output-type
      formatstring
      )
     )
    (if (not refdb-display-messages-flag)
	(display-buffer "*refdb-output*")
      (pop-to-buffer "*refdb-messages*")
      (pop-to-buffer "*refdb-output*")
      )
    (refdb-notes-output-buffer-choose-mode)
    (refdb-output-buffer-choose-encoding refdb-notesdata-output-type)
    (setq resize-mini-windows resize-mini-windows-default)
    )
  )

(defun refdb-getnote-by-field-regexp (field value)
  "Display all RefDB notes that match the specified FIELD and VALUE (regular expression). You shouldn't call this function directly.  Instead call, e.g.,
`refdb-getnote-by-title-regexp'."
  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (let ((formatstring
	(if (equal refdb-data-output-format 'more)
	    (format "\\\"%s\\\""
		    ;; turn list of symbols into one big string
		    (mapconcat
		     'symbol-name
		     refdb-data-output-additional-fields
		     " "
		     )
		    )
	  (upcase (symbol-name refdb-data-output-format))
	  )
	))
    (if (not (eq (length refdb-database) 0))
	(shell-command
	 (format
	  "%s %s -C getnote \":%s:~\'%s\'\" %s -d %s -t %s -s %s"
	  refdb-refdbc-program
	  refdb-refdbc-options
	  field
	  value
	  refdb-getnote-options
	  refdb-database
	  refdb-notesdata-output-type
	  formatstring
	  )
	 "*refdb-output*" "*refdb-messages*")
      ;; else if no db specified, prompt to select from available dbs and
      ;; then call `refdb-getnote-by-field-regexp' with same values
      (progn
	(call-interactively 'refdb-select-database)
	(refdb-getnote-by-field-regexp field value)
	)
      )
    (message
     (format
      "Displaying output for '%s %s -C getnote \":%s:~\'%s\'\" %s -d %s -t %s -s %s'...done"
      refdb-refdbc-program
      refdb-refdbc-options
      field
      value
      refdb-getnote-options
      refdb-database
      refdb-notesdata-output-type
      formatstring
      )
     )
    (if (not refdb-display-messages-flag)
	(display-buffer "*refdb-output*")
      (pop-to-buffer "*refdb-messages*")
      (pop-to-buffer "*refdb-output*")
      )
    (refdb-notes-output-buffer-choose-mode)
    (refdb-output-buffer-choose-encoding refdb-notesdata-output-type)
    (setq resize-mini-windows resize-mini-windows-default)
    )
  )

(defun refdb-getnote-by-field-on-region (field)
  (interactive)
  (if (mark)
      (progn
	(let ((value (concat
		      refdb-regexp-query-string
		      (buffer-substring (mark) (point))
		      refdb-regexp-query-string)))
	  (if refdb-use-regexp-match-in-getref-on-region-flag
	      (refdb-getnote-by-field-regexp field value)
	    (refdb-getnote-by-field field value))
	  )
	)
    (error "No region selected")
    )
  )

(defun refdb-getnote-by-title (title)
  "Display all RefDB notes matching TITLE."
  (interactive (list (read-string (format "Title: "))))
  (refdb-message-getting-notes 'title "=" title)
  (refdb-getnote-by-field "NTI" title)
  (refdb-message-getting-notes-done 'title "=" title)
  )

(defun refdb-getnote-by-title-regexp (title)
  "Display all RefDB notes regexp-matching TITLE."
  (interactive (list (read-string (format "Title %s: " refdb-regexp-prompt))))
  (refdb-message-getting-notes 'title "like" title)
  (refdb-getnote-by-field-regexp "NTI" title)
  (refdb-message-getting-notes-done 'title "like" title)
  )

(defun refdb-getnote-by-keyword (keyword)
  "Display all RefDB notes matching KEYWORD."
  (interactive (list 
		(completing-read "Keyword: "
				 (refdb-make-alist-from-list refdb-current-keywords-list))
		)
	       )
  (refdb-message-getting-notes 'keyword "=" keyword)
  (refdb-getnote-by-field "NKW" keyword)
  (refdb-message-getting-notes-done 'keyword "=" keyword)
  )

(defun refdb-getnote-by-keyword-regexp (keyword)
  "Display all RefDB notes regexp-matching KEYWORD."
  (interactive (list 
		(completing-read 
		 (format "Keyword : " refdb-regexp-prompt)
		 (refdb-make-alist-from-list refdb-current-keywords-list))
		)
	       )
  (refdb-message-getting-notes 'keyword "like" keyword)
  (refdb-getnote-by-field-regexp "NKW" keyword)
  (refdb-message-getting-notes-done 'keyword "like" keyword)
  )

(defun refdb-getnote-by-nid (id)
  "Display all RefDB notes matching NID."
  (interactive (list (read-string (format "NID: "))))
  (refdb-message-getting-notes 'id "=" id)
  (refdb-getnote-by-field "NID" id)
  (refdb-message-getting-notes-done 'id "=" id)
  )

(defun refdb-getnote-by-ncitekey (citekey)
  "Display all RefDB notes matching CITEKEY."
  (interactive (list (read-string (format "NCK: "))))
  (refdb-message-getting-notes 'citekey "=" citekey)
  (refdb-getnote-by-field "NCK" citekey)
  (refdb-message-getting-notes-done 'citekey "=" citekey)
  )

(defun refdb-getnote-by-authorlink (author)
  "Display all RefDB notes linked to AUTHOR."
  (interactive (list 
		(completing-read "Author: "
				 (refdb-make-alist-from-list refdb-current-authors-list))
		)
	       )
  (refdb-message-getting-notes-by-link 'author "=" author)
  (refdb-getnote-by-field "AU" author)
  (refdb-message-getting-notes-by-link-done 'author "=" author)
  )

(defun refdb-getnote-by-authorlink-regexp (author)
  "Display all RefDB notes linked to regexp AUTHOR."
  (interactive (list 
		(completing-read 
		 (format "Author %s: " refdb-regexp-prompt)
		 (refdb-make-alist-from-list refdb-current-authors-list))
		)
	       )
  (refdb-message-getting-notes-by-link 'author "like" author)
  (refdb-getnote-by-field-regexp "AU" author)
  (refdb-message-getting-notes-by-link-done 'author "like" author)
  )

(defun refdb-getnote-by-periodicallink (periodical)
  "Display all RefDB notes linked to PERIODICAL."
  (interactive (list 
		(completing-read "Periodical: "
				 (refdb-make-alist-from-list refdb-current-periodicals-list))
		)
	       )
  (refdb-message-getting-notes-by-link 'periodical "=" periodical)
  (refdb-getnote-by-field "JX" periodical)
  (refdb-message-getting-notes-by-link-done 'periodical "=" periodical)
  )

(defun refdb-getnote-by-periodicallink-regexp (periodical)
  "Display all RefDB notes linked to regexp PERIODICAL."
  (interactive (list 
		(completing-read 
		 (format "Periodical : " refdb-regexp-prompt)
		 (refdb-make-alist-from-list refdb-current-periodicals-list))
		)
	       )
  (refdb-message-getting-notes-by-link 'periodical "like" periodical)
  (refdb-getnote-by-field-regexp "JX" periodical)
  (refdb-message-getting-notes-by-link-done 'periodical "like" periodical)
  )

(defun refdb-getnote-by-keywordlink (keyword)
  "Display all RefDB notes linked to KEYWORD."
  (interactive (list 
		(completing-read "Keyword: "
				 (refdb-make-alist-from-list refdb-current-keywords-list))
		)
	       )
  (refdb-message-getting-notes-by-link 'keyword "=" keyword)
  (refdb-getnote-by-field "KW" keyword)
  (refdb-message-getting-notes-by-link-done 'keyword "=" keyword)
  )

(defun refdb-getnote-by-keywordlink-regexp (keyword)
  "Display all RefDB notes linked to regexp KEYWORD."
  (interactive (list 
		(completing-read 
		 (format "Keyword %s: " refdb-regexp-prompt)
		 (refdb-make-alist-from-list refdb-current-keywords-list))
		)
	       )
  (refdb-message-getting-notes-by-link 'keyword "like" keyword)
  (refdb-getnote-by-field-regexp "KW" keyword)
  (refdb-message-getting-notes-by-link-done 'keyword "like" keyword)
  )

(defun refdb-getnote-by-idlink (id)
  "Display all RefDB notes linked to ID."
  (interactive (list (read-string (format "ID: "))))
  (refdb-message-getting-notes-by-link 'id "=" id)
  (refdb-getnote-by-field "ID" id)
  (refdb-message-getting-notes-by-link-done 'id "=" id)
  )

(defun refdb-getnote-by-citekeylink (citekey)
  "Display all RefDB notes linked to CITEKEY."
  (interactive (list (read-string (format "Citation Key: "))))
  (refdb-message-getting-notes-by-link 'citekey "=" citekey)
  (refdb-getnote-by-field "CK" citekey)
  (refdb-message-getting-notes-by-link-done 'citekey "=" citekey)
  )

(defun refdb-getnote-by-advanced-search (searchstring)
  "Display all RefDB notes matching SEARCHSTRING."
  (interactive "sSearch string: ")
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (let ((formatstring
	 (if (equal refdb-data-output-format 'more)
	     (format "\\\"%s\\\""
		     ;; turn list of symbols into one big string
		     (mapconcat
		      'symbol-name
		      refdb-data-output-additional-fields
		      " "
		      )
		     )
	   (upcase (symbol-name refdb-data-output-format))
	   )
	 ))
    (message (format "Getting notes for search string %s ..." searchstring))
    (if (not (eq (length refdb-database) 0))
	(progn
	  (shell-command
	   (format
	    "%s %s -C getnote %s %s -d %s -t %s -s %s"
	    refdb-refdbc-program
	    refdb-refdbc-options
	    searchstring
	    refdb-getnote-options
	    refdb-database
	    refdb-notesdata-output-type
	    formatstring
	    )
	   "*refdb-output*" "*refdb-messages*")
	
	  )
      ;; else if no db specified, prompt to select from available dbs and
      ;; then call `refdb-getnote-by-advanced-search' with same values
      (progn
	(call-interactively 'refdb-select-database)
	(refdb-getnote-by-advanced-search searchstring)
	)
      )
    (message
     (format
      "Displaying output for '%s %s -C getnote %s %s -d %s -t %s -s %s'...done"
      refdb-refdbc-program
      refdb-refdbc-options
      searchstring
      refdb-getnote-options
      refdb-database
      refdb-notesdata-output-type
      formatstring
      )
     )
    (if (not refdb-display-messages-flag)
	(display-buffer "*refdb-output*")
      (pop-to-buffer "*refdb-messages*")
      (pop-to-buffer "*refdb-output*")
      )
    (refdb-notes-output-buffer-choose-mode)
    (refdb-output-buffer-choose-encoding refdb-notesdata-output-type)
    (setq resize-mini-windows resize-mini-windows-default)
    )
  (message (format "Getting notes for search string %s...done" searchstring))
  )

(defun refdb-getnote-by-title-on-region ()
  "Display all RefDB notes matching REGION in title."
  (interactive)
  (refdb-message-getting-notes 'title "=" "REGION")
  (refdb-getnote-by-field-on-region "NTI")
  (refdb-message-getting-notes-done 'title "=" "REGION")
  )

(defun refdb-getnote-by-keyword-on-region ()
  "Display all RefDB notes matching REGION in keyword."
  (interactive)
  (refdb-message-getting-notes 'keyword "=" "REGION")
  (refdb-getnote-by-field-on-region "NKW")
  (refdb-message-getting-notes-done 'keyword "=" "REGION")
  )

(defun refdb-getnote-by-authorlink-on-region ()
  "Display all RefDB notes linked to authors matching REGION."
  (interactive)
  (refdb-message-getting-notes 'author "=" "REGION")
  (refdb-getnote-by-field-on-region "AU")
  (refdb-message-getting-notes-done 'author "=" "REGION")
  )

(defun refdb-getnote-by-periodicallink-on-region ()
  "Display all RefDB notes linked to periodicals matching REGION."
  (interactive)
  (refdb-message-getting-notes 'periodical "=" "REGION")
  (refdb-getnote-by-field-on-region "JX")
  (refdb-message-getting-notes-done 'periodical "=" "REGION")
  )

(defun refdb-getnote-by-keywordlink-on-region ()
  "Display all RefDB notes linked to keywords matching REGION."
  (interactive)
  (refdb-message-getting-notes 'keyword "=" "REGION")
  (refdb-getnote-by-field-on-region "KW")
  (refdb-message-getting-notes-done 'keyword "=" "REGION")
  )

(defun refdb-getnote-by-idlink-on-region ()
  "Display all RefDB notes linked to IDs matching REGION."
  (interactive)
  (refdb-message-getting-notes 'id "=" "REGION")
  (refdb-getnote-by-field-on-region "ID")
  (refdb-message-getting-notes-done 'id "=" "REGION")
  )

(defun refdb-getnote-by-citekeylink-on-region ()
  "Display all RefDB notes linked to citation keys matching REGION."
  (interactive)
  (refdb-message-getting-notes 'citekey "=" "REGION")
  (refdb-getnote-by-field-on-region "CK")
  (refdb-message-getting-notes-done 'citekey "=" "REGION")
  )

(defun refdb-addlink ()
  "Add links from extended notes to database objects."
  (interactive)
  ;; todo: loop over target spec and value pairs until empty input
  (let* ((note-specifier (completing-read
		 "Addlink note specifier: "
		 refdb-note-specifier-list
		 nil t
		 ))
	(note-value (read-string "Note value: "))
	(link-to (read-string (format "Link %s=%s to items: " note-specifier note-value)))
	)

    ;; temporarily set resize-mini-windows to nil to force Emacs to show
    ;; output in separate buffer instead of minibuffer
    (setq resize-mini-windows-default resize-mini-windows)
    (setq resize-mini-windows nil)
    (if (not (eq (length refdb-database) 0))
	(shell-command
	 (format
	  "%s %s -C addlink -d %s %s %s %s "
	  refdb-refdba-program
	  refdb-refdba-options
	  refdb-database
	  note-specifier
	  note-value
	  link-to
	  )
	 "*refdb-output*" "*refdb-messages*")
      ;; else if no db specified, prompt to select from available dbs and
      ;; then call `refdb-addlink' with same values
      (progn
	(call-interactively 'refdb-select-database)
	(refdb-addlink)))

    (message
     (format
      "Displaying output for '%s %s -C addlink -d %s %s %s %s'...done"
      refdb-refdba-program
      refdb-refdba-options
      note-specifier
      note-value
      link-to
      )
     ))

  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  (with-current-buffer "*refdb-output*"
      (refdb-output-mode))
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-deletelink ()
  "Delete links from extended notes to database objects."
  (interactive)
  ;; todo loop over target spec and value pairs until empty input
  (let* ((note-specifier (completing-read
		 "Deletelink note specifier: "
		 refdb-note-specifier-list
		 nil t
		 ))
	(note-value (read-string "Note value: "))
	(link-to (read-string (format "Unlink %s=%s from items: " note-specifier note-value)))
	)

    ;; temporarily set resize-mini-windows to nil to force Emacs to show
    ;; output in separate buffer instead of minibuffer
    (setq resize-mini-windows-default resize-mini-windows)
    (setq resize-mini-windows nil)
    (if (not (eq (length refdb-database) 0))
	(shell-command
	 (format
	  "%s %s -C deletelink -d %s %s %s %s "
	  refdb-refdba-program
	  refdb-refdba-options
	  refdb-database
	  note-specifier
	  note-value
	  link-to
	  )
	 "*refdb-output*" "*refdb-messages*")
      ;; else if no db specified, prompt to select from available dbs and
      ;; then call `refdb-deletelink' with same values
      (progn
	(call-interactively 'refdb-select-database)
	(refdb-deletelink)))

    (message
     (format
      "Displaying output for '%s %s -C deletelink -d %s %s %s %s'...done"
      refdb-refdba-program
      refdb-refdba-options
      note-specifier
      note-value
      link-to
      )
     ))

  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  (with-current-buffer "*refdb-output*"
    (refdb-output-mode))
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-whichdb ()
  "Display information about the current database."
  (interactive)

  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (if (not (eq (length refdb-database) 0))
      (shell-command
       (format
	"%s %s -C whichdb -d %s"
	refdb-refdbc-program
	refdb-refdbc-options
	refdb-database
	)
       "*refdb-output*" "*refdb-messages*")
    ;; else if no db specified, prompt to select from available dbs and
    ;; then call `refdb-whichdb' with same values
    (progn
      (call-interactively 'refdb-select-database)
      (refdb-whichdb)
      )
    )
  (message
   (format
    "Displaying output for '%s %s -C whichdb -d %s'...done"
    refdb-refdbc-program
    refdb-refdbc-options
    refdb-database
    )
   )
  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  (with-current-buffer "*refdb-output*"
    (refdb-output-mode))
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-create-document (type)
  "Create a new RefDB document with type TYPE."
  (interactive (list 
		(completing-read "Type: " refdb-refdbnd-doctype-list)
		)
	       )
  (if (not (eq (length refdb-database) 0))
      (let* ((doctype (cond ((equal type "DocBook SGML 3.1")
			     "db31")
			    ((equal type "DocBook SGML 4.0")
			     "db40")
			    ((equal type "DocBook SGML 4.1")
			     "db41")
			    ((equal type "DocBook XML 4.1.2")
			     "db41x")
			    ((equal type "DocBook XML 4.2")
			     "db42x")
			    ((equal type "DocBook XML 4.3")
			     "db43x")
			    ((equal type "TEI XML P4")
			     "teix")
			    ))
	     (document-suffix (cond ((or (equal type "DocBook SGML 3.1")
					 (equal type "DocBook SGML 4.0")
					 (equal type "DocBook SGML 4.1"))
				     (if refdb-use-short-citations-document-flag
					 ".short.sgml"
				       ".sgml"))
				    ((or (equal type "DocBook XML 4.1.2")
					 (equal type "DocBook XML 4.2")
					 (equal type "DocBook XML 4.3")
					 (equal type "TEI XML P4"))
				     (if refdb-use-short-citations-document-flag
					 ".short.xml"
				       ".xml"))
				    ))
	     (document-root (completing-read "Document root element: "
					     refdb-refdbnd-root-element-list
					     nil t))
	     (document-style (completing-read "Bibliography style: "
					      (refdb-make-alist-from-list refdb-current-styles-list)
					      nil t))
	     (document-encoding (completing-read "Character encoding: "
						 (refdb-make-alist-from-list refdb-character-encodings-list)
						 nil t))
	     (document-cssfile (read-string "Custom CSS file (RETURN to use none): "))
	     (document-path (read-file-name "Document base name: "))
	     (document-basename (substring
				 document-path
				 (+ 1 (string-match
				       "/\\([^/]+\\)$"
				       document-path))))
	     (document-directory (substring
				  document-path
				  0
				  (string-match
				   "/\\([^/]+\\)$"
				   document-path)))
	     )

	;; first attempt to create the directory. The command makes
	;; sure to create any missing directories in the hierarchy,
	;; and it will not fail if the directory already exists. Then
	;; change to that directory and run the refdbnd script with
	;; all command line options in non-interactive mode. This will
	;; create the skeleton document and a Makefile If the command
	;; succeeds, we visit the basename.short.suffix file
	(if (shell-command
	     (format
	      "mkdir -p %s && cd %s && %s %s %s %s %s %s %s %s"
	      document-directory
	      document-directory
	      refdb-refdbnd-program
	      document-basename
	      doctype
	      document-root
	      refdb-database
	      document-style
	      document-encoding
	      document-cssfile
	      )
;	     "*refdb-output*" "*refdb-messages*")
	     nil "*refdb-messages*")
	    (find-file
	     (format
	      "%s%s"
	      document-path
	      document-suffix))
	  (error "Could not create the document")
	  )
	)
    ;; else if no db specified, prompt to select from available dbs and
    ;; then call `refdb-create-document' with same values
    (progn
      (call-interactively 'refdb-select-database)
      (refdb-create-document type)
      )
    )
  )

(defun refdb-transform (type)
  "Transform a document to an output format for printing or online browsing"
  (interactive)
  (if refdb-auto-normalize-linkends-flag
      (progn
	(refdb-normalize-linkends)
	(save-buffer)
	(set-buffer-modified-p nil))
    )
  (if (buffer-modified-p)
      (if (y-or-n-p "Save changes before transformation? ")
	  (progn
	    (save-buffer)
	    (set-buffer-modified-p nil))
	)
    )
  (message "Transforming document to %s..." type)
  (start-process-shell-command
   (concat "refdb-transform-" (buffer-name))
   (get-buffer-create "*refdb-messages*")
   refdb-gnumake-program
   type
   )
  (pop-to-buffer "*refdb-messages*")
  )

(defun refdb-transform-custom ()
  "Transform a document to an output format using custom arguments"
  (interactive)
  (let ((type (split-string (read-string (format "Make argument list: ")))))
    ;; todo: guess we have to turn type into a list and pass the arguments
    ;; separately to start-process

    (if refdb-auto-normalize-linkends-flag
	(progn
	  (refdb-normalize-linkends)
	      (save-buffer)
	      (set-buffer-modified-p nil))
      )
    (if (buffer-modified-p)
	(if (y-or-n-p "Save changes before transformation? ")
	    (progn
	      (save-buffer)
	      (set-buffer-modified-p nil))
	  )
      )
    (message "Transforming document to %s..." type)
    (start-process-shell-command
     (concat "refdb-transform-" (buffer-name))
     (get-buffer-create "*refdb-messages*")
     refdb-gnumake-program
     type
     )
    (pop-to-buffer "*refdb-messages*")
    )
  )
  
(defun refdb-check-doctype ()
  "Determine the document type of the current document. Only DocBook and TEI are handled currently."
  (save-excursion
    (goto-char (point-min))
    (cond ((search-forward "<!DOCTYPE article" nil t)
	   "article")
	  ((search-forward "<!DOCTYPE book" nil t)
	   "book")
	  ((search-forward "<!DOCTYPE TEI.2" nil t)
	   "TEI.2")
	  ((re-search-forward "<article.*>" nil t)
	   "article")
	  ((re-search-forward "<book.*>" nil t)
	   "book")
	  ((re-search-forward "<TEI\\.2.*>" nil t)
	   "TEI.2")
	  (t
	   nil)
	  )
    )
  )
    
(defun refdb-view-output (type)
  "Display the transformed document in an appropriate viewer"
  (interactive (list 
		(completing-read "Output Type: " refdb-output-type-list)
		)
	       )
  (let ((view-target-file
;; the DSSSL stylesheet generate book1.html, t1.html and so on
;; the XSLT stylesheets generate basename.html
;; both stylesheets generate basename.XXX for all other output types
	  (cond ((and (or
		       (equal type "html")
		       (equal type "xhtml"))
		      (string-match ".sgml$" buffer-file-name))
		 (concat
		  ;; need the protocol at least on Windoze
		  "file://"
		  ;; we may have to prepend a slash because Windoze paths
		  ;; start with a drive letter which has the browsers complain
		  ;; about malformed URLs...
		  (if (not (= (string-to-char buffer-file-name) 47))
			   "/")
		  (substring
		   buffer-file-name
		   0
		   (string-match "/[^/]+$" buffer-file-name))
		  (if (string= (refdb-check-doctype) "book")
		      "/book1.html"
		    "/t1.html")
		  ))
		(t
		 (concat
		  ;; add the protocol for (x)html files
		  (if (or
		       (equal type "html")
		       (equal type "xhtml"))
		      (concat
		       "file://"
		       (if (not (= (string-to-char buffer-file-name) 47))
				"/")
		       )
		    )
		  (substring
		   buffer-file-name 
		   0
		   (if (string-match "\\.short\\." buffer-file-name)
		       (string-match "\\.short\\." buffer-file-name)
		     (string-match "\\.[^\\.]+$" buffer-file-name)))
		  "."
		  type)))
	 )
	(view-program
	 (cond ((equal type "pdf")
		refdb-pdf-view-program)
	       ((equal type "ps")
		refdb-ps-view-program)
	       ((equal type "rtf")
		refdb-rtf-view-program)
	       (t
		nil)))
	(view-options
	 (cond ((equal type "pdf")
		refdb-pdf-view-program-options)
	       ((equal type "ps")
		refdb-ps-view-program-options)
	       ((equal type "rtf")
		refdb-rtf-view-program-options)
	       (t
		nil))))
    (message "Viewing %s in %s viewer" view-target-file type)
    (cond ((or
	    (equal type "html")
	    (equal type "xhtml"))
	   ;; browse-url apparently does its own quoting as calling
	   ;; shell-quote-argument here screws up things
	   (browse-url-of-file view-target-file))
	  (t
	   (if
	       (start-process-shell-command
		(concat "refdb-view-output-" (buffer-name))
		(get-buffer-create "*refdb-messages*")
		(format "%s %s %s"
			view-program
			view-options
			(shell-quote-argument view-target-file)))
	       (message "Viewing %s in %s viewer...done" view-target-file type)
	     (error "Could not start %s viewer")
	     )
	   )
	  )
    )
  )

(defun refdb-create-citation-on-region (type)
  "Provide a citation element using document type TYPE in the kill ring based
on the references within the current region in a getref buffer."
  (let* ((my-id-string
	 (if (eq major-mode 'ris-mode)
	     (refdb-get-ris-idstring-from-region type)
	   (if (or
		(eq major-mode 'nxml-mode)
		(eq major-mode 'xml-mode)
		(eq major-mode 'sgml-mode))
	       (refdb-get-risx-idstring-from-region type)
	     nil
	     ))
	 )
	)
    (kill-new
     (cond ((eq type 'docbook)
	    (format "<citation role=\"REFDB\">%s</citation>" my-id-string))
	   ((eq type 'tei)
	    (format "<seg type=\"REFDBCITATION\" part=\"N\" TEIform=\"seg\">%s</seg>" my-id-string))
	   ((eq type 'latex)
	    (format "\\cite{%s}" my-id-string))
	   )
       )
    )
  )

(defun refdb-create-docbook-citation-on-region ()
  "Provide a DocBook citation element in the kill ring based
on the references within the current region in a getref buffer.
Use the entire buffer if mark is not set."
  (interactive)
  (refdb-create-citation-on-region 'docbook)
  (message "Added citations in range to the kill ring as DocBook")
  )

(defun refdb-create-tei-citation-on-region ()
  "Provide a TEI citation element in the kill ring based
on the references within the current region in a getref buffer.
Use the entire buffer if mark is not set."
  (interactive)
  (refdb-create-citation-on-region 'tei)
  (message "Added citations in range to the kill ring as TEI")
  )

(defun refdb-create-latex-citation-on-region ()
  "Provide a LaTeX citation element in the kill ring based
on the references within the current region in a getref buffer.
Use the entire buffer if mark is not set."
  (interactive)
  (refdb-create-citation-on-region 'latex)
  (message "Added citations in range to the kill ring as LaTeX")
  )

(defun refdb-get-ris-idstring-from-region (type)
  "Scan the currently selected region for RIS ID elements and return their
values as a list of strings. Use the entire buffer if mark is not set."
  (save-excursion
    (let* ((region-extended-end 
	    (if (mark)
		(progn
		  (goto-char (region-end))
		  (re-search-forward "^ER  - $" nil t))
	      (point-max)))
	   (id-string))

      (if (mark)
	  (progn
	    (goto-char (region-beginning))
	    (re-search-backward "^TY  - " nil t))
	(goto-char (point-min)))
      (while (re-search-forward "^ID  - \\(.*\\)$" region-extended-end t)
	(if (eq type 'latex)
	    (setq id-string (concat id-string "," (match-string 1 nil)))
	  (if (eq refdb-citation-type 'short)
	      (setq id-string (concat id-string ";" (match-string 1 nil)))
	    ;; the xref notation must be adapted to SGML and XML
	    (setq id-string (concat id-string 
				    (format
				     (if (eq refdb-citation-format 'xml)
					 "<xref linkend=\"ID%s-X\"/>"
				       "<xref linkend=\"ID%s-X\">")
				     (match-string 1 nil))
				    ))
	    )
	  )
	)
      ;; remove leading separator in short type strings and LaTeX strings
      ;; add multixref element in full type strings
      (cond ((and
	      (or
	       (eq refdb-citation-type 'short)
	       (eq type 'latex))
	      (not (string= id-string "")))
	     (substring id-string 1))
	    ((and
	      (eq refdb-citation-type 'full)
	      (not (eq type 'latex))
	      (not (string= id-string "")))
	     (let ((linkend
		    (progn
		      (string-match "linkend=\"\\([^-\"]*\\)" id-string)
		      (match-string 1 id-string))))
	       (concat
		;; the xref notation used here works for both SGML and XML
		(format
		 (if (eq refdb-citation-format 'xml)
		     "<xref endterm=\"IM0\" linkend=\"%s\" role=\"MULTIXREF\"/>"
		     "<xref endterm=\"IM0\" linkend=\"%s\" role=\"MULTIXREF\">")
		 linkend
		 )
		id-string)
	       ))
	    (t
	     id-string)
	    )
      )
    )
  )

(defun refdb-get-risx-idstring-from-region (type)
  "Scan the currently selected region for RIS ID elements and return their
values as a list of strings."
  (save-excursion
    (let* ((region-extended-end 
	    (if (mark)
		(progn
		  (goto-char (region-end))
		  (re-search-forward "</entry *>" nil t))
	      (point-max)))
	   (id-string))

      (if (mark)
	  (progn
	    (goto-char (region-beginning))
	    (re-search-backward "<entry" nil t))
	(goto-char (point-min)))
      (while (re-search-forward "citekey=\"\\([^\"]*\\)\"" region-extended-end t)
	(if (eq type 'latex)
	    (setq id-string (concat id-string "," (match-string 1 nil)))
	  (if (eq refdb-citation-type 'short)
	      (setq id-string (concat id-string ";" (match-string 1 nil)))
	    ;; the xref notation must be adapted to SGML and XML
	    (setq id-string (concat id-string 
				    (format
				     (if (eq refdb-citation-format 'xml)
					 "<xref linkend=\"ID%s-X\"/>"
				       "<xref linkend=\"ID%s-X\">")
				     (match-string 1 nil))
				    ))
	    )
	  )
	)
      ;; remove leading semicolon in short type strings
      ;; add multixref element in full type strings
      (cond ((and
	      (or
	       (eq refdb-citation-type 'short)
	       (eq type 'latex))
	      (not (string= id-string "")))
	     (substring id-string 1))
	    ((and
	      (eq refdb-citation-type 'full)
	      (not (eq type 'latex))
	      (not (string= id-string "")))
	     (let ((linkend
		    (progn
		      (string-match "linkend=\"\\([^-\"]*\\)" id-string)
		      (match-string 1 id-string))))
	       (concat
		(format
		 (if (eq refdb-citation-format 'xml)
		     "<xref endterm=\"IM0\" linkend=\"%s\" role=\"MULTIXREF\"/>"
		     "<xref endterm=\"IM0\" linkend=\"%s\" role=\"MULTIXREF\">")
		 linkend
		 )
		id-string)
	       ))
	    (t
	     id-string)
	    )
      )
    )
  )

(defun refdb-create-citation-from-point (type)
  "Provide a DocBook citation element in the kill ring based
on the reference where point is currently located in a getref buffer."
  (let ((my-id
	 (if (eq major-mode 'ris-mode)
	     (refdb-get-ris-id-from-point type)
	   (if (or
		(eq major-mode 'nxml-mode)
		(eq major-mode 'xml-mode)
		(eq major-mode 'sgml-mode))
	       (refdb-get-risx-id-from-point type)
	     nil
	     ))
	 ))
    (kill-new
     (cond ((eq type 'docbook)
	    (format "<citation role=\"REFDB\">%s</citation>" my-id))
	   ((eq type 'tei)
	    (format "<seg type=\"REFDBCITATION\" part=\"N\" TEIform=\"seg\">%s</seg>" my-id))
	   ((eq type 'latex)
	    (format "\\cite{%s}" my-id))
	   )
     )
    )
  )

(defun refdb-create-docbook-citation-from-point ()
  "Provide a DocBook citation element in the kill ring based
on the reference where point is currently located in a getref buffer."
  (interactive)
  (refdb-create-citation-from-point 'docbook)
  (message "Added citation from point to the kill ring as DocBook")
  )

(defun refdb-create-tei-citation-from-point ()
  "Provide a TEI citation element in the kill ring based
on the reference where point is currently located in a getref buffer."
  (interactive)
  (refdb-create-citation-from-point 'tei)
  (message "Added citation from point to the kill ring as TEI")
  )

(defun refdb-create-latex-citation-from-point ()
  "Provide a LaTeX citation element in the kill ring based
on the reference where point is currently located in a getref buffer."
  (interactive)
  (refdb-create-citation-from-point 'latex)
  (message "Added citation from point to the kill ring as LaTeX")
  )

(defun refdb-get-ris-id-from-point (type)
  "Search for the ID of the current reference in a RIS buffer."
  (save-excursion
    (let ((eor (re-search-forward "^ER  - $" nil t)))
      (re-search-backward "^TY  - " nil t)
      (if (re-search-forward "^ID  - \\(.*\\)$" eor t)
	  (if (or
	       (eq refdb-citation-type 'short)
	       (eq type 'latex))
	      (match-string 1 nil)
	    ;; the xref notation used here works for both SGML and XML
	    (format
	     (if (eq refdb-citation-format 'xml)
		 "<xref linkend=\"ID%s-X\"/>"
	       "<xref linkend=\"ID%s-X\">")
	     (match-string 1 nil)))
	nil)
      )
    )
  )

(defun refdb-get-risx-id-from-point (type)
  "Search for the ID of the current reference in a risx buffer."
  (save-excursion
    (let ((eor (re-search-forward "</entry *>" nil t)))
      (re-search-backward "<entry" nil t)
      (if (re-search-forward "citekey=\"\\(.*\\)\"" eor t)
	  (if (or
	       (eq refdb-citation-type 'short)
	       (eq type 'latex))
	      (match-string 1 nil)
	    ;; the xref notation used here works for both SGML and XML
	    (format
	     (if (eq refdb-citation-format 'xml)
		 "<xref linkend=\"ID%s-X\"/>"
	       "<xref linkend=\"ID%s-X\">")
	     (match-string 1 nil)))
	nil)
      )
    )
  )
    
(defun refdb-normalize-linkends ()
  (interactive)
  (save-excursion
    (let ((im-count 1)
	  (id-list))
      ;; replace full and author citations with the "subsequent" equivalents
      ;; where appropriate
      (goto-char (point-min))
      (while (re-search-forward "linkend=\"ID\\([^-\"]+\\)-\\([AQSXY]\\)\"" nil t)
	(if (member (match-string 1 nil) id-list)
	    (cond ((equal (match-string 2 nil) "A")
		   (replace-match "Q" nil t nil 2))
		  ((equal (match-string 2 nil) "X")
		   (replace-match "S" nil t nil 2)))
	  (setq id-list (append (list (match-string 1 nil)) id-list))
	  (cond ((equal (match-string 2 nil) "Q")
		 (replace-match "A" nil t nil 2))
		((equal (match-string 2 nil) "S")
		 (replace-match "X" nil t nil 2)))
	  )
	)
      ;; make the endterms of multiple citations unique
      (goto-char (point-min))
      (while (re-search-forward "endterm=\"IM\\([^\"]+\\)\"" nil t)
	(replace-match
	 (format "%s" im-count)
	 nil t nil 1)
	(setq im-count (+ 1 im-count)))
      )
    )
  )

(defun refdb-make-alist-from-list (list)
  "Make an alist from LIST by cons'ing elements with themselves."
  (mapcar
   (lambda (atom)
     (cons atom nil))
   list)
  )

(defun refdb-make-alist-from-symbol-list (list)
  "Make an alist from LIST of symbols."
  (mapcar
   (lambda (atom)
     (cons (symbol-name atom) nil))
   list)
  )

(defun refdb-select-database (database)
  "Select DATABASE as the current RefDB database.
If called interactively, prompt user with completion list of available
databases."
  (interactive
   (list
    (completing-read
     "Database: "
     (refdb-make-alist-from-list refdb-current-database-list)
     nil t
     )
    )
   )
  (setq refdb-database database)
  (run-hooks 'refdb-select-database-hook)
  (message (concat "Current database is now " database))
  )

(defun refdb-select-additional-data-fields ()
  "Choose additional data fields to display in Screen/(X)HTML output."
  (customize-variable 'refdb-data-output-additional-fields)
  )

(defun refdb-select-additional-notesdata-fields ()
  "Choose additional data fields to display in Screen/(X)HTML notes output."
  (customize-variable 'refdb-notesdata-output-additional-fields)
  )

;;*************************************************************
;; refdba commands
;;*************************************************************

(defun refdb-addstyle-on-buffer ()
  "Add all styles in the current buffer to current database."
  (interactive)
  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; addref output in separate buffer instead of minibuffer
  (setq resize-mini-windows nil)
  (progn
    ;; ToDo: make sure we have citestylex data
    (message "Adding styles in the current buffer to the main database...")
    ;; logic: if nXML mode is active, proceed only if the contents are valid
    ;;        if a different mode is active, always proceed
    (if (or (and (equal mode-name "nXML")
		 (equal (rng-compute-mode-line-string) " Valid"))
	    (not (equal mode-name "nXML")))
	(progn
	  (let ((coding-system-for-read buffer-file-coding-system)
		(coding-system-for-write buffer-file-coding-system))
	    (shell-command-on-region
	     (point-min) (point-max)
	     (format
	      "%s %s %s -C addstyle"
	      refdb-refdba-program
	      refdb-refdba-options
	      refdb-addstyle-options
	      )
	     "*refdb-output*" nil "*refdb-messages*"))
	  (message
	   "Displaying output for '%s %s -C addstyle'...done"
	   refdb-refdba-program
	   refdb-refdba-options
	   )
	  (display-buffer "*refdb-output*")
	  (with-current-buffer "*refdb-output*"
	    (refdb-output-mode)))
      (error "Buffer contents is invalid:%s<<" (rng-compute-mode-line-string))
	 ))
  (refdb-scan-styles-list)
  (message "Adding styles in the current buffer to the main database...done")
  ;; set resize-mini-windows back to default value
  (setq resize-mini-windows (get 'resize-mini-windows 'standard-value))
  )

(defun refdb-adduser ()
  "Allow a user access to a reference database."
  (interactive)
  (let* ((dbname (completing-read
		 "Database: "
		 (refdb-make-alist-from-list refdb-current-admin-database-list)
		 nil t
		 ))
	(hostname (read-string "Host name: "))
	(username (read-string "Username: "))
	(passwd (read-string "Password (leave empty if already set): "))
	(hostopt (if (not (eq (length hostname) 0))
		     (format
		      " -H %s "
		      hostname)
		   ""))
	(passopt (if (not (eq (length passwd) 0))
		     (format
		      " -N %s "
		      passwd)
		   "")))

    ;; temporarily set resize-mini-windows to nil to force Emacs to show
    ;; output in separate buffer instead of minibuffer
    (setq resize-mini-windows-default resize-mini-windows)
    (setq resize-mini-windows nil)
    (if (not (eq (length dbname) 0))
	(if (not (eq (length username) 0))
	    (shell-command
	     (format
	      "%s %s -C adduser -d %s %s %s %s "
	      refdb-refdba-program
	      refdb-refdba-options
	      dbname
	      hostopt
	      passopt
	      username
	      )
	     "*refdb-output*" "*refdb-messages*")
	  ;; else if no db specified, prompt to select from available dbs and
	  ;; then call `refdb-deletenote' with same values
	  (error "No username specified"))
      (error "No database specified"))

    (message
     (format
      "Displaying output for '%s %s -C adduser -d %s %s %s %s'...done"
      refdb-refdba-program
      refdb-refdba-options
      dbname
      hostopt
      passopt
      username
      )
     ))

  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  ;; update internal database list
  (refdb-scan-database-list)

  (with-current-buffer "*refdb-output*"
    (refdb-output-mode))
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-addword (wordlist)
  "Add words to the journal words list."
  (interactive "sWords: ")

  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (if (not (eq (length wordlist) 0))
      (shell-command
       (format
	"%s %s -C addword  %s "
	refdb-refdba-program
	refdb-refdba-options
	wordlist
	)
       "*refdb-output*" "*refdb-messages*")
    (error "No words specified"))

  (message
   (format
    "Displaying output for '%s %s -C addword %s'...done"
      refdb-refdba-program
      refdb-refdba-options
      wordlist
      )
   )

  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  (with-current-buffer "*refdb-output"
    (refdb-output-mode))
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-createdb ()
  "Create a reference database."
  (interactive)
  (let* ((dbname (read-string "Database name: "))
	 (encoding (completing-read
		    "Encoding: "
		    (refdb-make-alist-from-list refdb-character-encodings-list)
		    ))
	 (encodingopt (if (not (eq (length encoding) 0))
		     (format
		      " -E %s "
		      encoding)
		   "")))

    ;; temporarily set resize-mini-windows to nil to force Emacs to show
    ;; output in separate buffer instead of minibuffer
    (setq resize-mini-windows-default resize-mini-windows)
    (setq resize-mini-windows nil)
    (if (not (eq (length dbname) 0))
	(shell-command
	 (format
	  "%s %s -C createdb %s %s "
	  refdb-refdba-program
	  refdb-refdba-options
	  encodingopt
	  dbname
	  )
	 "*refdb-output*" "*refdb-messages*")
      (error "No database specified"))

    (message
     (format
      "Displaying output for '%s %s -C createdb %s %s'...done"
      refdb-refdba-program
      refdb-refdba-options
      encodingopt
      dbname
      )
     ))

  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )

  ;; update internal database lists
  (refdb-scan-database-list)
  (refdb-scan-admin-database-list)

  (with-current-buffer "*refdb-output*"
    (refdb-output-mode))
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-deletedb (dbname)
  "Delete a reference database."
  (interactive
   (list (completing-read
    "Delete Database: "
    (refdb-make-alist-from-list refdb-current-admin-database-list)
    nil t
    )))

  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (if (not (eq (length dbname) 0))
      (shell-command
       (format
	"%s %s -C deletedb  %s "
	refdb-refdba-program
	refdb-refdba-options
	dbname
	)
       "*refdb-output*" "*refdb-messages*")
    (error "No database specified"))

  (message
   (format
    "Displaying output for '%s %s -C deletedb %s'...done"
    refdb-refdba-program
    refdb-refdba-options
    dbname
    )
   )

  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )

  ;; update internal database list
  (refdb-scan-database-list)
  (refdb-scan-admin-database-list)

  (with-current-buffer "*refdb-output*"
    (refdb-output-mode))
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-deletestyle (stylename)
  "Delete a style."
  (interactive
   (list (completing-read
    "Delete Style: "
    (refdb-make-alist-from-list refdb-current-styles-list)
    nil t
    )))

  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (if (not (eq (length stylename) 0))
      (shell-command
       (format
	"%s %s -C deletestyle %s "
	refdb-refdba-program
	refdb-refdba-options
	stylename
	)
       "*refdb-output*" "*refdb-messages*")
    (error "No style specified"))

  (message
   (format
    "Displaying output for '%s %s -C deletestyle %s'...done"
    refdb-refdba-program
    refdb-refdba-options
    stylename
    )
   )

  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  (with-current-buffer "*refdb-output*"
    (refdb-output-mode))
  (refdb-scan-styles-list)
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-deleteuser ()
  "Deny a user access to a reference database."
  (interactive)
  (let* ((dbname (completing-read
		 "Delete user from Database: "
		 (refdb-make-alist-from-list refdb-current-admin-database-list)
		 nil t
		 ))
	(hostname (read-string "Host name: "))
	(username (read-string "Username: "))
	(hostopt (if (not (eq (length hostname) 0))
		     (format
		      " -H %s "
		      hostname)
		   "")))

    ;; temporarily set resize-mini-windows to nil to force Emacs to show
    ;; output in separate buffer instead of minibuffer
    (setq resize-mini-windows-default resize-mini-windows)
    (setq resize-mini-windows nil)
    (if (not (eq (length dbname) 0))
	(if (not (eq (length username) 0))
	    (shell-command
	     (format
	      "%s %s -C deleteuser -d %s %s %s "
	      refdb-refdba-program
	      refdb-refdba-options
	      dbname
	      hostopt
	      username
	      )
	     "*refdb-output*" "*refdb-messages*")
	  ;; else if no db specified, prompt to select from available dbs and
	  ;; then call `refdb-deletenote' with same values
	  (error "No username specified"))
      (error "No database specified"))

    (message
     (format
      "Displaying output for '%s %s -C deleteuser -d %s %s %s'...done"
      refdb-refdba-program
      refdb-refdba-options
      dbname
      hostopt
      username
      )
     ))

  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )

  ;; update internal database list
  (refdb-scan-database-list)

  (with-current-buffer "*refdb-output*"
    (refdb-output-mode))
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-deleteword (wordlist)
  "Delete words from the journal word list."
  (interactive "sDelete Words:")

  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (if (not (eq (length wordlist) 0))
      (shell-command
       (format
	"%s %s -C deleteword %s "
	refdb-refdba-program
	refdb-refdba-options
	wordlist
	)
       "*refdb-output*" "*refdb-messages*")
    (error "No word specified"))

  (message
   (format
    "Displaying output for '%s %s -C deleteword %s'...done"
    refdb-refdba-program
    refdb-refdba-options
    wordlist
    )
   )

  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )

  (with-current-buffer "*refdb-output*"
    (refdb-output-mode))
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-getstyle (stylename)
  "Retrieve a style as an XML document."
  (interactive
   (list (completing-read
    "Retrieve Style: "
    (refdb-make-alist-from-list refdb-current-styles-list)
    nil t
    )))

  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (if (not (eq (length stylename) 0))
      (shell-command
       (format
	"%s %s -C getstyle %s "
	refdb-refdba-program
	refdb-refdba-options
	stylename
	)
       "*refdb-output*" "*refdb-messages*")
    (error "No style specified"))

  (message
   (format
    "Displaying output for '%s %s -C getstyle %s'...done"
    refdb-refdba-program
    refdb-refdba-options
    stylename
    )
   )

  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )

  ;; invoke appropriate mode for XML data
  (if (functionp 'nxml-mode)
      (nxml-mode)
    (if (functionp 'xml-mode)
	(xml-mode)
      )
    )
  (refdb-output-buffer-choose-encoding "citestylex")
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-scankw ()
  "Initiate background keyword scan."
  (interactive)
  (let ((dbname (completing-read
		 "Initiate keyword scan in Database: "
		 (refdb-make-alist-from-list refdb-current-admin-database-list)
		 nil t
		 )))
    ;; temporarily set resize-mini-windows to nil to force Emacs to show
    ;; addref output in separate buffer instead of minibuffer
    (setq resize-mini-windows nil)
    (progn
      (message "Initiating keyword scan...")
      (if (not (eq (length dbname) 0))
	  (shell-command
	   (format
	    "%s %s -C scankw -d %s"
	    refdb-refdba-program
	    refdb-refdba-options
	    dbname
	    )
	   "*refdb-output*" "*refdb-messages*")
	(message
	 "Displaying output for '%s %s -C scankw -d %s'...done"
	 refdb-refdba-program
	 refdb-refdba-options
	 dbname
	 )
	(display-buffer "*refdb-output*")
	(with-current-buffer "*refdb-output*"
	  (refdb-output-mode))
	)
      )
    )
  (message "Initiating keyword scan...done")
  ;; set resize-mini-windows back to default value
  (setq resize-mini-windows (get 'resize-mini-windows 'standard-value))
  )

(defun refdb-list-item (command regexp)
  "List items from the database using COMMAND and REGEXP. You should not call this function directly. Use e.g. 'refdb-listdb' instead."
  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (shell-command
   (format
    "%s %s -C %s %s "
    refdb-refdba-program
    refdb-refdba-options
    command
    regexp
    )
   "*refdb-output*" "*refdb-messages*")


  (message
   (format
    "Displaying output for '%s %s -C %s %s'...done"
    refdb-refdba-program
    refdb-refdba-options
    command
    regexp
    )
   )

  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  (with-current-buffer "*refdb-output*"
    (refdb-output-mode))
  (refdb-output-buffer-choose-encoding "list")
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-listdb (dbname)
  "List available databases."
  (interactive "sDatabase name \(SQL regexp\):")

  (refdb-list-item "listdb" dbname)
)

(defun refdb-liststyle (stylename)
  "List available styles."
  (interactive "sStyle name \(regexp\):")

  (refdb-list-item "liststyle" stylename)
)

(defun refdb-listword (word)
  "List available journal title words."
  (interactive "sWord \(regexp\):")

  (refdb-list-item "listword" word)
)

(defun refdb-listuser ()
  "List users of a reference database."
  (interactive)
  (let* ((dbname (completing-read
		 "List users of Database: "
		 (refdb-make-alist-from-list refdb-current-admin-database-list)
		 nil t
		 ))
	(username (read-string "Username \(regexp\): ")))

    ;; temporarily set resize-mini-windows to nil to force Emacs to show
    ;; output in separate buffer instead of minibuffer
    (setq resize-mini-windows-default resize-mini-windows)
    (setq resize-mini-windows nil)
    (if (not (eq (length dbname) 0))
	(shell-command
	 (format
	  "%s %s -C listuser -d %s %s "
	      refdb-refdba-program
	      refdb-refdba-options
	      dbname
	      username
	      )
	 "*refdb-output*" "*refdb-messages*")
      (error "No database specified"))

    (message
     (format
      "Displaying output for '%s %s -C listuser -d %s %s'...done"
      refdb-refdba-program
      refdb-refdba-options
      dbname
      username
      )
     ))

  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  (with-current-buffer "*refdb-output*"
    (refdb-output-mode))
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-viewstat ()
  "Show RefDB server information."
  (interactive)
  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; addref output in separate buffer instead of minibuffer
  (setq resize-mini-windows nil)
  (progn
    (message "Retrieving server information...")
    (shell-command
     (format
      "%s %s -C viewstat"
      refdb-refdba-program
      refdb-refdba-options
      )
     "*refdb-output*" "*refdb-messages*")
    (message
     "Displaying output for '%s %s -C viewstat'...done"
     refdb-refdba-program
     refdb-refdba-options
     )
    (display-buffer "*refdb-output*")
    (with-current-buffer "*refdb-output*"
      (refdb-output-mode))
    )
  (message "Retrieving server information...done")
  ;; set resize-mini-windows back to default value
  (setq resize-mini-windows (get 'resize-mini-windows 'standard-value))
  )

(defun refdb-start-or-stop-server (mode)
  "Start (MODE=start), stop (MODE=stop), restart (MODE=restart), or reload (MODE=reload) the refdbd application server. You should not call this function directly. Use refdb-start-server, refdb-stop-server and so on instead."
  (message
   "Attempting to %s the server..."
   mode
   )
;; first try sudo without a password
  (if (eq (shell-command
	   (format
	    "sudo %s %s"
	    refdb-refdbd-script
	    mode
	    )) 0)
      (progn
	(message
	 "Attempting to %s the server...done"
	 mode
	 )
	(sleep-for refdb-wait-for-server-period)
	(with-current-buffer
	    (buffer-name (get-buffer-create "*refdb-output*"))
	  (progn
	    ;; update internal database lists
	    (refdb-scan-database-list)
	    (refdb-scan-admin-database-list)
	    (refdb-scan-styles-list)
	    (refdb-find-dbengine)
	    (run-hooks 'refdb-select-database-hook)
	    (refdb-output-mode)
	    )))
    (progn
      ;; if it fails w/o password, ask for the password and try again
      (let ((sudo-password (read-passwd "Your sudo password: ")))
	(if (eq (shell-command
		 (format
		  "echo \"%s\" | sudo -S %s %s"
		  sudo-password
		  refdb-refdbd-script
		  mode
		  )) 0)
	    (progn
	      (message
	       "Attempting to %s the server...done"
	       mode
	       )
	      (sleep-for refdb-wait-for-server-period)
	      (with-current-buffer
		  (buffer-name (get-buffer-create "*refdb-output*"))
		(progn
		  ;; update internal database lists
		  (refdb-scan-database-list)
		  (refdb-scan-admin-database-list)
		  (refdb-scan-styles-list)
		  (refdb-find-dbengine)
		  (run-hooks 'refdb-select-database-hook)
		  (refdb-output-mode)
		  )))
	  (message
	   "Attempting to %s the server...failed"
	   mode
	   )
	  )
	)
      )
    )
  )

(defun refdb-start-server ()
  "Start the refdbd application server."
  (refdb-start-or-stop-server "start")
  )

(defun refdb-stop-server ()
  "Start the refdbd application server."
  (refdb-start-or-stop-server "stop")
  )

(defun refdb-restart-server ()
  "Restart the refdbd application server."
  (refdb-start-or-stop-server "restart")
  )

(defun refdb-reload-server ()
  "Reload the refdbd application server."
  (refdb-start-or-stop-server "reload")
  )

(defun refdb-edit-user-config-file (userconfig-file)
  "Edit a user RefDB config file. Don't call this function directly. Use refdb-edit-refdbarc, refdb-edit-refdbcrc and so on instead."
  (let* ((userconfig-path (format "~/%s" userconfig-file))
	 (userconfig-dotpath (format "~/.%s" userconfig-file))
	 (my-file (if (and (file-exists-p userconfig-dotpath)
			   (file-writable-p userconfig-dotpath))
		      userconfig-dotpath
		    (progn
		      (if (and (file-exists-p userconfig-path)
			       (file-writable-p userconfig-path))
			  userconfig-path
			nil)))))
    (if (not (eq my-file nil))
	(find-file-other-window my-file)
      (error "Config file %s not writable" userconfig-file)))
  )

(defun refdb-edit-global-config-file (globalconfig-file)
  "Edit a global RefDB config file. Don't call this function directly. Use refdb-edit-global-refdbarc, refdb-edit-global-refdbcrc and so on instead."
  (let* ((globalconfig-path (format "%s/%s" refdb-sysconfdir globalconfig-file))
	 (my-file (if (file-exists-p globalconfig-path)
		      globalconfig-path
		    nil)))
    (if (not (eq my-file nil))
	(progn
	  (let ((sudo-password (read-passwd "Your sudo password: "))
		(my-proc (start-process-shell-command
			  "my-proc"
			  (get-buffer-create "*refdb-messages*")
			  "sudo"
			  "-S"
			  "emacs"
			  my-file
			  )))
	    (if (not (eq my-proc nil))
		(progn
		  ;; if we send the string immediately, sudo may not yet
		  ;; be accepting input
		  (sleep-for 1)
		  (process-send-string my-proc (format "%s\n" sudo-password)))
	      (error "Cannot edit global config file"))
	    ))
      (error "Cannot edit global config file %s" globalconfig-file)))
  )

(defun refdb-edit-refdbcrc ()
  "Edit the refdbc user configuration file"
  (interactive)
  (refdb-edit-user-config-file "refdbcrc")
  )

(defun refdb-edit-refdbarc ()
  "Edit the refdbc user configuration file"
  (interactive)
  (refdb-edit-user-config-file "refdbarc")
  )

(defun refdb-edit-refdbibrc ()
  "Edit the refdbc user configuration file"
  (interactive)
  (refdb-edit-user-config-file "refdbibrc")
  )

(defun refdb-edit-global-refdbcrc ()
  "Edit the global refdbc configuration file"
  (interactive)
  (refdb-edit-global-config-file "refdbcrc")
  )

(defun refdb-edit-global-refdbarc ()
  "Edit the global refdba configuration file"
  (interactive)
  (refdb-edit-global-config-file "refdbarc")
  )

(defun refdb-edit-global-refdbibrc ()
  "Edit the global refdbib configuration file"
  (interactive)
  (refdb-edit-global-config-file "refdbibrc")
  )

(defun refdb-edit-global-refdbdrc ()
  "Edit the global refdbd configuration file"
  (interactive)
  (refdb-edit-global-config-file "refdbdrc")
  )

(defun refdb-init-refdb ()
  "Create the system database. Use this command once to initialize
your RefDB installation. It will destructively replace any existing
RefDB system database. You've been warned."
  (interactive)
;; read refdbdrc config file with sudo, find defs of refdblib, dbserver etc
;; then run db cli tool to create the refdb database
  (let* ((sudo-password (read-passwd "Your sudo password: "))
	 (refdbdrc-path (format "%s/refdbdrc" refdb-sysconfdir))
	 (my-file (if (file-exists-p refdbdrc-path)
		      refdbdrc-path
		    nil))
	 (main-database "refdb")
	 )
    (if my-file
	(let ((refdbdrc-content
		(with-output-to-string
		  (with-current-buffer
		      standard-output
		    (call-process
		     shell-file-name nil '(t nil) nil shell-command-switch
		     (format "cat %s" my-file))))))
	  (if refdbdrc-content
	      (let* ((refdblib 
		     (progn
		       (string-match
			"^refdblib[ \t]+\\(.+\\)$"
			refdbdrc-content)
		       (match-string 1 refdbdrc-content)
			))
		    (dbserver 
		     (progn
		       (string-match
			"^dbserver[ \t]+\\(.+\\)$"
			refdbdrc-content)
		       (match-string 1 refdbdrc-content)
		       ))
		    (dbsport 
		     (progn
		       (string-match
			"^dbsport[ \t]+\\(.+\\)$"
			refdbdrc-content)
		       (match-string 1 refdbdrc-content)
		       ))
		    (dbshost 
		     (progn
		       (string-match
			"^serverip[ \t]+\\(.+\\)$"
			refdbdrc-content)
		       (match-string 1 refdbdrc-content)
		       ))
		    (dbpath 
		     (progn
		       (string-match
			"^dbpath[ \t]+\\(.+\\)$"
			refdbdrc-content)
		       (match-string 1 refdbdrc-content)
		       ))
		    (dbroot
		     (if (or (equal dbserver "mysql")
			     (equal dbserver "pgsql"))
			 (read-string "Database administrator name: ")))
		    (dbroot-password
		     (if (or (equal dbserver "mysql")
			     (equal dbserver "pgsql"))
			 (read-passwd "Database administrator password: ")))
		    (dbroot-opt
		     (cond ((and dbroot
				 (equal dbserver "mysql"))
			    (format
			     "-u %s"
			     dbroot))
			   ((and dbroot
				 (equal dbserver "pgsql"))
			    (format
			     "-U %s"
			     dbroot))
			   (t
			    "")))
		    (dbroot-password-opt
		     (cond ((and dbroot-password
				 (equal dbserver "mysql"))
			    (format
			     "-p%s"
			     dbroot-password))
			   ((and dbroot-password
				 (equal dbserver "pgsql"))
			    (format
			     "-U %s"
			     dbroot))
			   (t
			    "")))
		    (ipopt
		     (cond ((and dbshost
				 (not (equal dbshost "localhost"))
				 (equal dbserver "mysql"))
			    (format
			     "-h %s"
			     dbshost))
			   ((and dbshost
				 (not (equal dbshost "localhost"))
				 (equal dbserver "pgsql"))
			    (format
			     "-h %s"
			     dbshost))
			   (t
			    "")
			   )
		     )
		    (portopt
		     (cond ((and dbsport
				 (equal dbserver "mysql"))
			    (format
			     "-P %s"
			     dbsport))
			   ((and dbsport
				 (equal dbserver "pgsql"))
			    (format
			     "-p %s"
			     dbsport))
			   (t
			    "")
			   )
		     )
		    (db-drop-command
		     (cond ((equal dbserver "mysql")
			    (format
			     "%s -c \'mysql %s %s %s %s -e \"DROP DATABASE IF EXISTS %s\"\'"
			     refdb-external-program-shell
			     ipopt
			     portopt
			     dbroot-opt
			     dbroot-password-opt
			     main-database))
			   ((equal dbserver "pgsql")
			    (format
			     "xterm -title \'Drop database %s\' -e %s -c \'dropdb %s %s %s %s\'"
			     main-database
			     refdb-external-program-shell
			     ipopt
			     portopt
			     dbroot-opt
			     main-database))
			   ((or (equal dbserver "sqlite")
				(equal dbserver "sqlite3"))
			    (format
			     "echo \"%s\"| sudo -S %s -c \'test ! -e %s/%s || rm %s/%s\'"
			     sudo-password
			     refdb-external-program-shell
			     dbpath
			     main-database
			     dbpath
			     main-database))
			   ))
		    (db-create-command
		     (cond ((equal dbserver "mysql")
			    (format
			     "%s -c \'mysql %s %s %s %s -e \"CREATE DATABASE %s CHARACTER SET \'utf8\'\"\'"
			     refdb-external-program-shell
			     ipopt
			     portopt
			     dbroot-opt
			     dbroot-password-opt
			     main-database))
			   ((equal dbserver "pgsql")
			    (format
			     "xterm -title \'Create database %s\' -e %s -c \'createdb %s %s %s -E UNICODE %s\'"
			     main-database
			     refdb-external-program-shell
			     ipopt
			     portopt
			     dbroot-opt
			     main-database))
			   ))
		    (db-command
		     (cond ((equal dbserver "sqlite")
			    (format
			     "echo \"%s\"| sudo -S %s -c \'sqlite %s/%s< %s/sql/refdb.dump.sqlite\'"
			     sudo-password
			     refdb-external-program-shell
			     dbpath
			     main-database
			     refdblib))
			   ((equal dbserver "sqlite3")
			    (format
			     "echo \"%s\"| sudo -S %s -c \'sqlite3 %s/%s < %s/sql/refdb.dump.sqlite\'"
			     sudo-password
			     refdb-external-program-shell
			     dbpath
			     main-database
			     refdblib))
			   ((equal dbserver "mysql")
;; todo: detect older versions of MySQL and use the other dumpfile
			    (format
			     "%s -c \'mysql %s %s %s %s %s < %s/sql/refdb.dump.mysql41\'"
			     refdb-external-program-shell
			     ipopt
			     portopt
			     dbroot-opt
			     dbroot-password-opt
			     main-database
			     refdblib))
			   ((equal dbserver "pgsql")
			    (format
			     "xterm -title \'Create tables in %s\' -e %s -c \'psql %s %s %s %s < %s/sql/refdb.dump.pgsql\'"
			     main-database
			     refdb-external-program-shell
			     ipopt
			     portopt
			     dbroot-opt
			     main-database
			     refdblib))
			   )
		     )
		    )
		(if (eq (shell-command
			 db-drop-command) 0)
		    (if (or (equal dbserver "mysql")
			    (equal dbserver "pgsql"))
			(if (eq (shell-command
				 db-create-command) 0)
			    (if (not (eq (shell-command
					  db-command) 0))
				(error "Failed to initialize RefDB")
			      (message "RefDB sucessfully initialized")
			      )
			  (error "Failed to initialize RefDB")
			  )
		      (if (not (eq (shell-command
				    db-command) 0))
			  (error "Failed to initialize RefDB")
			(message "RefDB sucessfully initialized")
			)
		      )
		  (error "Failed to initialize RefDB")
		  )
		)
	    )
	  )
      )
    )
  )

(defun refdb-backup-database ()
  "Create backup of a reference database."
  (interactive)
  (let* ((refdbdrc-path (format "%s/refdbdrc" refdb-sysconfdir))
	 (my-file (if (file-exists-p refdbdrc-path)
		      refdbdrc-path
		    nil))
	 )
    (if my-file
	(let ((refdbdrc-content
	       (with-output-to-string
		 (with-current-buffer
		     standard-output
		   (call-process
		    shell-file-name nil '(t nil) nil shell-command-switch
		    (format "cat %s" my-file))))))
	  (if refdbdrc-content
	      (let* ((dbname (completing-read
			      "Backup Database: "
			      (refdb-make-alist-from-list refdb-current-admin-database-list)
			      nil t
			      ))
		     (backup-filename (read-file-name "Save backup to: "))
		     (dbserver 
		      (progn
			(string-match
			 "^dbserver[ \t]+\\(.+\\)$"
			 refdbdrc-content)
			(match-string 1 refdbdrc-content)
			))
		     (dbsport 
		      (progn
			(string-match
			 "^dbsport[ \t]+\\(.+\\)$"
			 refdbdrc-content)
			(match-string 1 refdbdrc-content)
			))
		     (dbshost 
		      (progn
			(string-match
			 "^serverip[ \t]+\\(.+\\)$"
			 refdbdrc-content)
			(match-string 1 refdbdrc-content)
			))
		     (dbpath 
		      (progn
			(string-match
			 "^dbpath[ \t]+\\(.+\\)$"
			 refdbdrc-content)
			(match-string 1 refdbdrc-content)
			))
		     (dbroot
		      (if (or (equal dbserver "mysql")
			      (equal dbserver "pgsql"))
			  (read-string "Database administrator name: ")))
		     (dbroot-password
		      (if (or (equal dbserver "mysql")
			      (equal dbserver "pgsql"))
			  (read-passwd "Database administrator password: ")))
		     (dbroot-opt
		      (cond ((and dbroot
				  (equal dbserver "mysql"))
			     (format
			      "-u %s"
			      dbroot))
			    ((and dbroot
				  (equal dbserver "pgsql"))
			     (format
			      "-U %s"
			      dbroot))
			    (t
			     "")))
		     (dbroot-password-opt
		      (cond ((and dbroot-password
				  (equal dbserver "mysql"))
			     (format
			      "-p%s"
			      dbroot-password))
			    ((and dbroot-password
				  (equal dbserver "pgsql"))
			     (format
			      "-U %s"
			      dbroot))
			    (t
			     "")))
		     (ipopt
		      (cond ((and dbshost
				  (not (equal dbshost "localhost"))
				  (equal dbserver "mysql"))
			     (format
			      "-h %s"
			      dbshost))
			    ((and dbshost
				  (not (equal dbshost "localhost"))
				  (equal dbserver "pgsql"))
			     (format
			      "-h %s"
			      dbshost))
			    (t
			     "")
			    )
		      )
		     (portopt
		      (cond ((and dbsport
				  (equal dbserver "mysql"))
			     (format
			      "-P %s"
			      dbsport))
			    ((and dbsport
				  (equal dbserver "pgsql"))
			     (format
			      "-p %s"
			      dbsport))
			    (t
			     "")
			    )
		      )
		     (db-backup-command
		      (cond ((equal dbserver "mysql")
			     (format
			      "%s -c \'mysqldump --opt %s %s %s %s --databases %s > %s\'"
			      refdb-external-program-shell
			      ipopt
			      portopt
			      dbroot-opt
			      dbroot-password-opt
			      dbname
			      backup-filename))
			    ((equal dbserver "pgsql")
			     (format
			      "xterm -title \'Backup database %s\' -e %s -c \'pg_dump %s %s %s %s>%s\'"
			      dbname
			      refdb-external-program-shell
			      ipopt
			      portopt
			      dbroot-opt
			      dbname
			      backup-filename))
			    ((equal dbserver "sqlite")
			     (format
			      "%s -c \'echo \'.dump\'|sqlite %s/%s >%s\'"
			      refdb-external-program-shell
			      dbpath
			      dbname
			      backup-filename))
			    ((equal dbserver "sqlite3")
			     (format
			      "%s -c \'echo \'.dump\'|sqlite3 %s/%s >%s\'"
			      refdb-external-program-shell
			      dbpath
			      dbname
			      backup-filename))
			    ))
		     )
		(if (eq (shell-command
			 db-backup-command) 0)
		    (message "Backup written successfully to %s" backup-filename)
		  (error "Failed to create backup")
		  )
		)
	    (error "Failed to read server configuration file")
	    )
	  )
      (error "Failed to read server configuration file")
      )
    )
  )

(defun refdb-restore-database ()
  "Restore a reference database from a backup file."
  (interactive)
  (let* ((sudo-password (read-passwd "Your sudo password: "))
	 (refdbdrc-path (format "%s/refdbdrc" refdb-sysconfdir))
	 (my-file (if (file-exists-p refdbdrc-path)
		      refdbdrc-path
		    nil))
	 )
    (if my-file
	(let ((refdbdrc-content
	       (with-output-to-string
		 (with-current-buffer
		     standard-output
		   (call-process
		    shell-file-name nil '(t nil) nil shell-command-switch
		    (format "cat %s" my-file))))))
	  (if refdbdrc-content
	      (let* ((dbname (read-string "Database name: "))
		     (backup-filename (read-file-name "Restore backup from: "))
		     (dbserver 
		      (progn
			(string-match
			 "^dbserver[ \t]+\\(.+\\)$"
			 refdbdrc-content)
			(match-string 1 refdbdrc-content)
			))
		     (dbsport 
		      (progn
			(string-match
			 "^dbsport[ \t]+\\(.+\\)$"
			 refdbdrc-content)
			(match-string 1 refdbdrc-content)
			))
		     (dbshost 
		      (progn
			(string-match
			 "^serverip[ \t]+\\(.+\\)$"
			 refdbdrc-content)
			(match-string 1 refdbdrc-content)
			))
		     (dbpath 
		      (progn
			(string-match
			 "^dbpath[ \t]+\\(.+\\)$"
			 refdbdrc-content)
			(match-string 1 refdbdrc-content)
			))
		     (dbroot
		      (if (or (equal dbserver "mysql")
			      (equal dbserver "pgsql"))
			  (read-string "Database administrator name: ")))
		     (dbroot-password
		      (if (or (equal dbserver "mysql")
			      (equal dbserver "pgsql"))
			  (read-passwd "Database administrator password: ")))
		     (dbroot-opt
		      (cond ((and dbroot
				  (equal dbserver "mysql"))
			     (format
			      "-u %s"
			      dbroot))
			    ((and dbroot
				  (equal dbserver "pgsql"))
			     (format
			      "-U %s"
			      dbroot))
			    (t
			     "")))
		     (dbroot-password-opt
		      (cond ((and dbroot-password
				  (equal dbserver "mysql"))
			     (format
			      "-p%s"
			      dbroot-password))
			    ((and dbroot-password
				  (equal dbserver "pgsql"))
			     (format
			      "-U %s"
			      dbroot))
			    (t
			     "")))
		     (ipopt
		      (cond ((and dbshost
				  (not (equal dbshost "localhost"))
				  (equal dbserver "mysql"))
			     (format
			      "-h %s"
			      dbshost))
			    ((and dbshost
				  (not (equal dbshost "localhost"))
				  (equal dbserver "pgsql"))
			     (format
			      "-h %s"
			      dbshost))
			    (t
			     "")
			    )
		      )
		     (portopt
		      (cond ((and dbsport
				  (equal dbserver "mysql"))
			     (format
			      "-P %s"
			      dbsport))
			    ((and dbsport
				  (equal dbserver "pgsql"))
			     (format
			      "-p %s"
			      dbsport))
			    (t
			     "")
			    )
		      )
		     (db-drop-command
		      (cond ((equal dbserver "mysql")
			     (format
			      "%s -c \'mysql %s %s %s %s -e \"DROP DATABASE IF EXISTS %s\"\'"
			      refdb-external-program-shell
			      ipopt
			      portopt
			      dbroot-opt
			      dbroot-password-opt
			      dbname))
			    ((equal dbserver "pgsql")
			     (format
			      "xterm -title \'Drop database %s\' -e %s -c \'dropdb %s %s %s %s\'"
			      dbname
			      refdb-external-program-shell
			      ipopt
			      portopt
			      dbroot-opt
			      dbname))
			    ((or (equal dbserver "sqlite")
				 (equal dbserver "sqlite3"))
			     (format
			      "echo \"%s\"| sudo -S %s -c \'test ! -e %s/%s || rm %s/%s\'"
			      sudo-password
			      refdb-external-program-shell
			      dbpath
			      main-database
			      dbpath
			      dbname))
			    ))
		     (db-restore-command
		      (cond ((equal dbserver "mysql")
			     (format
			      "%s -c \'mysql %s %s %s %s %s <%s\'"
			      refdb-external-program-shell
			      ipopt
			      portopt
			      dbroot-opt
			      dbroot-password-opt
			      dbname
			      backup-filename))
			    ((equal dbserver "pgsql")
			     (format
			      "xterm -title \'Restore database %s\' -e %s -c \'psql %s %s %s %s<%s\'"
			      dbname
			      refdb-external-program-shell
			      ipopt
			      portopt
			      dbroot
			      dbname
			      backup-filename))
			    ((equal dbserver "sqlite")
			     (format
			      "%s -c \'sqlite %s < %s/%s\'"
			      refdb-external-program-shell
			      dbname
			      dbpath
			      backup-filename))
			    ((equal dbserver "sqlite3")
			     (format
			      "%s -c \'sqlite3 %s <%s/%s\'"
			      refdb-external-program-shell
			      dbname
			      dbpath
			      backup-filename))
			    ))
		     )
		(if (eq (shell-command
			 db-drop-command) 0)
		    (if (eq (shell-command
			     db-restore-command) 0)
			(message "Backup restored successfully from %s" backup-filename)
		      (error "Failed to restore backup")
		      )
		  (error "Failed to drop existing database")
		  )
		)
	    (error "Failed to read server configuration file")
	    )
	  )
      (error "Failed to read server configuration file")
      )
    )
  )


;; *******************************************************************
;;; bibutils support functions
;; *******************************************************************
(defun refdb-import-refdata (from-type)
  "Convert the reference data in the current buffer to RIS format.
You shouldn't call this function directly.  Instead call, e.g.,
`refdb-import-from-mods'."
  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (let ((bibutils-input-filter
	 (cond
	  ((equal from-type "bib")
	   refdb-bibutils-bib2xml-program)
	  ((equal from-type "copac")
	   refdb-bibutils-copac2xml-program)
	  ((equal from-type "end")
	   refdb-bibutils-end2xml-program)
	  ((equal from-type "isi")
	   refdb-bibutils-isi2xml-program)
	  ((equal from-type "med")
	   refdb-bibutils-med2xml-program)
	  ((equal from-type "mods")
	   nil)
	  ))
	(bibutils-input-filter-options
	 (cond
	  ((equal from-type "bib")
	   refdb-bibutils-bib2xml-options)
	  ((equal from-type "copac")
	   refdb-bibutils-copac2xml-options)
	  ((equal from-type "end")
	   refdb-bibutils-end2xml-options)
	  ((equal from-type "isi")
	   refdb-bibutils-isi2xml-options)
	  ((equal from-type "med")
	   refdb-bibutils-med2xml-options)
	  ((equal from-type "mods")
	   nil)
	  ))
	(coding-system-for-read buffer-file-coding-system)
	(coding-system-for-write buffer-file-coding-system)
	)
    (if (eq bibutils-input-filter nil)
	(progn
	  (shell-command-on-region
	   (point-min)
	   (point-max)
	   (format
	    "%s %s"
	    refdb-bibutils-xml2ris-program
	    refdb-bibutils-xml2ris-options
	    )
	   "*refdb-output*" nil "*refdb-messages*")
	  (message
	   (format
	    "Displaying output for '%s %s'...done"
	    refdb-bibutils-xml2ris-program
	    refdb-bibutils-xml2ris-options
	    )
	   )
	  )
      (progn
	  (shell-command-on-region
	   (point-min)
	   (point-max)
	   (format
	    "%s %s | %s %s"
	    bibutils-input-filter
	    bibutils-input-filter-options
	    refdb-bibutils-xml2ris-program
	    refdb-bibutils-xml2ris-options
	    )
	   "*refdb-output*" nil "*refdb-messages*")
	  (message
	   (format
	    "Displaying output for '%s %s | %s %s'...done"
	    bibutils-input-filter
	    bibutils-input-filter-options
	    refdb-bibutils-xml2ris-program
	    refdb-bibutils-xml2ris-options
	    )
	   )
	  )
      )
    )
  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  (if (functionp 'ris-mode)
      (ris-mode)
    (refdb-output-mode))
  (refdb-output-buffer-choose-encoding "ris")
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-import-from-bibtex ()
  (interactive)
  (refdb-import-refdata "bib")
  )

(defun refdb-import-from-copac ()
  (interactive)
  (refdb-import-refdata "copac")
  )

(defun refdb-import-from-endnote ()
  (interactive)
  (refdb-import-refdata "end")
  )

(defun refdb-import-from-isi ()
  (interactive)
  (refdb-import-refdata "isi")
  )

(defun refdb-import-from-medline ()
  (interactive)
  (refdb-import-refdata "med")
  )

(defun refdb-import-from-mods ()
  (interactive)
  (refdb-import-refdata "mods")
  )


(defun refdb-export-refdata (to-type)
  "Convert the RIS reference data in the current buffer to another format.
You shouldn't call this function directly.  Instead call, e.g.,
`refdb-export-to-mods'."
  ;; temporarily set resize-mini-windows to nil to force Emacs to show
  ;; output in separate buffer instead of minibuffer
  (setq resize-mini-windows-default resize-mini-windows)
  (setq resize-mini-windows nil)
  (let ((bibutils-output-filter
	 (cond
	  ((eq to-type 'end)
	   refdb-bibutils-xml2end-program)
	  ((eq to-type 'mods)
	   nil)
	  ))
	(bibutils-output-filter-options
	 (cond
	  ((eq to-type 'end)
	   refdb-bibutils-xml2end-options)
	  ((eq to-type 'mods)
	   nil)
	  ))
	(coding-system-for-read buffer-file-coding-system)
	(coding-system-for-write buffer-file-coding-system)
	)
    (if (eq bibutils-output-filter nil)
	(progn
	  (shell-command-on-region
	   (point-min)
	   (point-max)
	   (format
	    "%s %s"
	    refdb-bibutils-ris2xml-program
	    refdb-bibutils-ris2xml-options
	    )
	   "*refdb-output*" nil "*refdb-messages*")
	  (message
	   (format
	    "Displaying output for '%s %s'...done"
	    refdb-bibutils-ris2xml-program
	    refdb-bibutils-ris2xml-options
	    )
	   )
	  )
      (progn
	  (shell-command-on-region
	   (point-min)
	   (point-max)
	   (format
	    "%s %s | %s %s"
	    refdb-bibutils-ris2xml-program
	    refdb-bibutils-ris2xml-options
	    bibutils-output-filter
	    bibutils-output-filter-options
	    )
	   "*refdb-output*" nil "*refdb-messages*")
	  (message
	   (format
	    "Displaying output for '%s %s | %s %s'...done"
	    refdb-bibutils-ris2xml-program
	    refdb-bibutils-ris2xml-options
	    bibutils-output-filter
	    bibutils-output-filter-options
	    )
	   )
	  )
      )
    )
  (if (not refdb-display-messages-flag)
      (display-buffer "*refdb-output*")
    (pop-to-buffer "*refdb-messages*")
    (pop-to-buffer "*refdb-output*")
    )
  (if (eq to-type 'mods)
      (if (functionp 'nxml-mode)
	  (nxml-mode)
	(if (functionp 'xml-mode)
	    (xml-mode)
	  (refdb-output-mode))
	(refdb-output-mode))
    (refdb-output-mode))
  (refdb-output-buffer-choose-encoding to-type)
  (setq resize-mini-windows resize-mini-windows-default)
  )

(defun refdb-export-to-endnote ()
  (interactive)
  (refdb-export-refdata 'end)
  )

(defun refdb-export-to-mods ()
  (interactive)
  (refdb-export-refdata 'mods)
  )

;;*************************************************************
;; the mode itself and its menus
;;*************************************************************

(easy-mmode-define-minor-mode
 refdb-mode
 "Minor mode for RefDB interaction."
 ;; Initial value is nil.
 nil
 ;; No indicator for the mode line.
 nil
 ;; Define a keymap. \C-c\C-r is the common prefix for all commands
 '( ("\C-c\C-rv" . refdb-show-version)
; reference management: r
    ("\C-c\C-rra" . refdb-addref-on-region)
    ("\C-c\C-rru" . refdb-updateref-on-region)
    ("\C-c\C-rrd" . refdb-deleteref)
; notes management: n
    ("\C-c\C-rna" . refdb-addnote-on-buffer)
    ("\C-c\C-rnu" . refdb-updatenote-on-buffer)
    ("\C-c\C-rnd" . refdb-deletenote)
; get references: g: exact match x: regexp match
    ("\C-c\C-rga" . refdb-getref-by-author)
    ("\C-c\C-rxa" . refdb-getref-by-author-regexp)
    ("\C-c\C-rgt" . refdb-getref-by-title)
    ("\C-c\C-rxt" . refdb-getref-by-title-regexp)
    ("\C-c\C-rgk" . refdb-getref-by-keyword)
    ("\C-c\C-rxk" . refdb-getref-by-keyword-regexp)
    ("\C-c\C-rgp" . refdb-getref-by-periodical)
    ("\C-c\C-rxp" . refdb-getref-by-periodical-regexp)
    ("\C-c\C-rgi" . refdb-getref-by-id)
    ("\C-c\C-rgc" . refdb-getref-by-citekey)
    ("\C-c\C-rgd" . refdb-getref-by-advanced-search)
; get references on region: \C-g
    ("\C-c\C-r\C-ga" . refdb-getref-by-author-on-region)
    ("\C-c\C-r\C-gt" . refdb-getref-by-title-on-region)
    ("\C-c\C-r\C-gk" . refdb-getref-by-keyword-on-region)
    ("\C-c\C-r\C-gp" . refdb-getref-by-periodical-on-region)
    ("\C-c\C-r\C-gi" . refdb-getref-by-id-on-region)
    ("\C-c\C-r\C-gc" . refdb-getref-by-citekey-on-region)
; get references from citation: \C-c
    ("\C-c\C-r\C-c" . refdb-getref-from-citation)
; get notes: o: exact match p: regexp match
    ("\C-c\C-rot" . refdb-getnote-by-title)
    ("\C-c\C-rpt" . refdb-getnote-by-title-regexp)
    ("\C-c\C-rok" . refdb-getnote-by-keyword)
    ("\C-c\C-rpk" . refdb-getnote-by-keyword-regexp)
    ("\C-c\C-roi" . refdb-getnote-by-nid)
    ("\C-c\C-roc" . refdb-getnote-by-ncitekey)
    ("\C-c\C-roa" . refdb-getnote-by-authorlink)
    ("\C-c\C-rpa" . refdb-getnote-by-authorlink-regexp)
    ("\C-c\C-rop" . refdb-getnote-by-periodicallink)
    ("\C-c\C-rpp" . refdb-getnote-by-periodicallink-regexp)
    ("\C-c\C-rol" . refdb-getnote-by-keywordlink)
    ("\C-c\C-rpl" . refdb-getnote-by-keywordlink-regexp)
    ("\C-c\C-roq" . refdb-getnote-by-idlink)
    ("\C-c\C-rov" . refdb-getnote-by-citekeylink)
    ("\C-c\C-rod" . refdb-getnote-by-advanced-search)
; get notes on region: \C-o
    ("\C-c\C-r\C-ot" . refdb-getnote-by-title-on-region)
    ("\C-c\C-r\C-ok" . refdb-getnote-by-keyword-on-region)
    ("\C-c\C-r\C-oa" . refdb-getnote-by-authorlink-on-region)
    ("\C-c\C-r\C-op" . refdb-getnote-by-periodicallink-on-region)
    ("\C-c\C-r\C-ol" . refdb-getnote-by-keywordlink-on-region)
    ("\C-c\C-r\C-oq" . refdb-getnote-by-idlink-on-region)
    ("\C-c\C-r\C-ov" . refdb-getnote-by-citekeylink-on-region)
; select: s
    ("\C-c\C-rsd" . refdb-select-database)
    ("\C-c\C-rsr" . refdb-select-data-output-type)
    ("\C-c\C-rsn" . refdb-select-notesdata-output-type)
; transform: c
    ("\C-c\C-rcc" . refdb-transform)
    ("\C-c\C-rcv" . refdb-view-output)
    ("\C-c\C-rcs" . refdb-create-docbook-citation-on-region)
    ("\C-c\C-rcr" . refdb-create-tei-citation-on-region)
    ("\C-c\C-rcx" . refdb-create-latex-citation-on-region)
    ("\C-c\C-rcd" . refdb-create-docbook-citation-from-point)
    ("\C-c\C-rct" . refdb-create-tei-citation-from-point)
    ("\C-c\C-rcl" . refdb-create-latex-citation-from-point)
    ))

(defvar refdb-menu-item-separator1
  ["--" t]
  "Separator between command `refdb-mode' menu items."
  )
(defvar refdb-menu-item-separator2
  ["---" t]
  "Separator between command `refdb-mode' menu items."
  )
(defvar refdb-menu-item-separator3
  ["----" t]
  "Separator between command `refdb-mode' menu items."
  )
(defvar refdb-menu-item-separator4
  ["-----" t]
  "Separator between command `refdb-mode' menu items."
  )

(defvar refdb-show-messages-menu-item
  ["Show RefDB Message Log"
   (refdb-show-messages) t]
  "RefDB menu item for showing message log."
  )

(defvar refdb-show-version-menu-item
  ["Show Version Information"
   (refdb-show-version) t]
  "RefDB menu item for showing RefDB Mode version."
  )

(defvar refdb-show-manual-menu-item
  ["Show Manual"
   (refdb-show-manual) t]
  "RefDB menu item for displaying RefDB Mode manual."
  )

(defvar refdb-customize-menu-item
  ["Customize RefDB Mode..."
   (customize-group 'refdb) t]
  "Customize submenu for command `refdb-mode'."
  )

(defgroup refdb nil
  "RefDB menu."
  :group 'applications
  :link '(emacs-commentary-link "refdb-mode.el")
  :link '(url-link "http://refdb.sf.net/")
  :prefix "refdb-"
  )

(defgroup refdb-programs nil
  "RefDB programs and command option settings."
  :group 'refdb
  :prefix "refdb-"
  )

(defgroup refdb-menu-definitions nil
  "RefDB menu customizations."
  :group 'refdb
  :prefix "refdb-"
  )

(defgroup refdb-admin-options nil
  "RefDB administrator customizations."
  :group 'refdb
  :prefix "refdb-"
  )

(defgroup refdb-data-options nil
  "RefDB input and output data type and format options."
  :group 'refdb
  :prefix "refdb-"
  )

(defgroup refdb-external-programs nil
  "RefDB options for external programs and their options."
  :group 'refdb
  :prefix "refdb-"
  )

(defun refdb-make-selectdb-menu ()
  "Build the Select Database submenu."
  (setq refdb-selectdb-submenu-items nil)
  (setq refdb-selectdb-submenu-contents
	(cons "Select Database"
	      (progn
		(setq my-database-list refdb-current-database-list)
		(while my-database-list
		  (setq current-database (car my-database-list))
		  (setq refdb-selectdb-submenu-items
			(nconc refdb-selectdb-submenu-items
			       (list
				(vector
				 current-database
				 `(refdb-select-database ,current-database)
				 :style 'toggle
				 :selected `(equal refdb-database ,current-database)
				 )
				)
			       )
			)
		  (setq my-database-list (cdr my-database-list))
		  )
		refdb-selectdb-submenu-items
		)
	      )
	)
  )


;; *******************************************************************
;;; User-customizable options, part 2
;; *******************************************************************

(defun refdb-initialize-all-menus ()
  "Build all menus."

  (defcustom refdb-input-type-risx 'use-mode-name
    "*Indicates whether RISX is used as the input type.
Passed to the 'refdbc -C addref' command as the argument for the -t
option.  If t, RISX is always used.  If nil, RISX is never used.  If
non-t and non-nil, use RISX if the name of the buffer's major mode
contains 'xml' or 'sgml'."
    :type '(choice (const :tag "always" t) (const :tag "never" nil)
		   (const :tag "use-mode-name" use-mode-name))
    :group 'refdb-data-options
    )

(defcustom refdb-display-messages-flag t
  "*Non-nil means split window and display the *refdb-messages* buffer.
If nil \(off\), show *refdb-output* window at full
frame.  Keep at non-nil \(on\) to cause current frame to be split to
show both output and messages."
    :type 'boolean
    :group 'refdb)

(defcustom refdb-data-output-type 'ris
  "*Specifies the default output type.
Passed to the 'refdbc -C getref' command as the argument for the -t
option.  FIXME: Should be generated from output-types list."
  :type '(choice (const :tag "Screen      "  scrn)
		 (const :tag "HTML        "  html)
		 (const :tag "XHTML       "  xhtml)
		 (const :tag "DocBook SGML"  db31)
		 (const :tag "DocBook XML "  db31x)
		 (const :tag "TEX XML     "  teix)
		 (const :tag "BibTeX      "  bibtex)
		 (const :tag "RIS         "  ris)
		 (const :tag "RISX        "  risx)
		 )
  :group 'refdb-data-options
  )

(defcustom refdb-notesdata-output-type 'xnote
  "*Specifies the default output type of notes.
Passed to the 'refdbc -C getnote' command as the argument for the -t
option.  FIXME: Should be generated from output-types list."
  :type '(choice (const :tag "Screen      "  scrn)
		 (const :tag "HTML        "  html)
		 (const :tag "XHTML       "  xhtml)
		 (const :tag "xnote       "  xnote)
		 )
  :group 'refdb-data-options
  )

(defcustom refdb-data-output-format 'default
  "*Specifies the default output type.
Passed to the 'refdbc -C getref' command as the argument for the -t
option.  FIXME: Should be generated from output-formats list."
  :type '(choice (const :tag "Default          "  default)
		 (const :tag "All fields       "  all)
		 (const :tag "IDs only         "  ID)
		 (const :tag "Additional fields"  more)
		 )
  :group 'refdb-data-options
  )

(defcustom refdb-citation-type 'full
  "*Specifies the default citation type."
  :type '(choice (const :tag "Short          "  short)
		 (const :tag "Full           "  full)
		 )
  :group 'refdb-data-options
  )

(defcustom refdb-citation-format 'xml
  "*Specifies the default citation type."
  :type '(choice (const :tag "XML            "  xml)
		 (const :tag "SGML           "  sgml)
		 )
  :group 'refdb-data-options
  )

(defcustom refdb-data-output-submenu-contents
  '(
    refdb-select-data-output-type-submenu-contents
    refdb-select-notesdata-output-type-submenu-contents
    refdb-select-data-output-format-submenu-contents
    refdb-select-additional-data-fields-menu-item
    refdb-select-citation-type-submenu-contents
    refdb-select-citation-format-submenu-contents
    )
  "*Contents of 'Customize Data Output' submenu for RefDB mode.
Customize this to add/remove/rearrange submenus."
  :set (lambda (sym val)
	 (setq refdb-data-output-submenu-contents val)
	 (setq refdb-data-output-submenu-definition
	       (cons "Customize Data Output"
		     ;; turn quoted contents value back into a real list
		     (mapcar (lambda (item) (if (symbolp item) (eval item) item)) val)
		     )
	       )
	 )
  :group 'refdb-menu-definitions
  :type '(repeat variable)
  )

(defcustom refdb-getref-submenu-contents
  '(
    refdb-getref-by-author-menu-item
    refdb-getref-by-author-regexp-menu-item
    refdb-getref-by-title-menu-item
    refdb-getref-by-title-regexp-menu-item
    refdb-getref-by-keyword-menu-item
    refdb-getref-by-keyword-regexp-menu-item
    refdb-getref-by-periodical-menu-item
    refdb-getref-by-periodical-regexp-menu-item
    refdb-getref-by-id-menu-item
    refdb-getref-by-citekey-menu-item
    refdb-getref-by-advanced-search-menu-item
    )
  "*Contents of 'Get References' submenu for RefDB mode.
Customize this to add/remove/rearrange submenus."
  :set (lambda (sym val)
	 (setq refdb-getref-submenu-contents val)
	 (setq refdb-getref-submenu-definition
	       (cons "Get References"
		     ;; turn quoted contents value back into a real list
		     ;; thanks, sachac :)
		     (mapcar (lambda (item) (if (symbolp item) (eval item) item)) val)
		     )
	       )
	 )
  :group 'refdb-menu-definitions
  :type '(repeat variable)
  )

(defcustom refdb-getref-on-region-submenu-contents
  '(
    refdb-getref-by-author-on-region-menu-item
    refdb-getref-by-title-on-region-menu-item
    refdb-getref-by-keyword-on-region-menu-item
    refdb-getref-by-periodical-on-region-menu-item
    refdb-getref-by-id-on-region-menu-item
    refdb-getref-by-citekey-on-region-menu-item
    )
  "*Contents of 'Get References on Region' submenu for RefDB mode.
Customize this to add/remove/rearrange submenus."
  :set (lambda (sym val)
	 (setq refdb-getref-on-region-submenu-contents val)
	 (setq refdb-getref-on-region-submenu-definition
	       (cons "Get References on Region"
		     ;; turn quoted contents value back into a real list
		     ;; thanks, sachac :)
		     (mapcar (lambda (item) (if (symbolp item) (eval item) item)) val)
		     )
	       )
	 )
  :group 'refdb-menu-definitions
  :type '(repeat variable)
  )

(defcustom refdb-getnote-submenu-contents
  '(
    refdb-getnote-by-title-menu-item
    refdb-getnote-by-title-regexp-menu-item
    refdb-getnote-by-keyword-menu-item
    refdb-getnote-by-keyword-regexp-menu-item
    refdb-getnote-by-nid-menu-item
    refdb-getnote-by-ncitekey-menu-item
    refdb-getnote-by-authorlink-menu-item
    refdb-getnote-by-authorlink-regexp-menu-item
    refdb-getnote-by-periodicallink-menu-item
    refdb-getnote-by-periodicallink-regexp-menu-item
    refdb-getnote-by-keywordlink-menu-item
    refdb-getnote-by-keywordlink-regexp-menu-item
    refdb-getnote-by-idlink-menu-item
    refdb-getnote-by-citekeylink-menu-item
    refdb-getnote-by-advanced-search-menu-item
    )
  "*Contents of 'Get Notes' submenu for RefDB mode.
Customize this to add/remove/rearrange submenus."
  :set (lambda (sym val)
	 (setq refdb-getnote-submenu-contents val)
	 (setq refdb-getnote-submenu-definition
	       (cons "Get Notes"
		     ;; turn quoted contents value back into a real list
		     ;; thanks, sachac :)
		     (mapcar (lambda (item) (if (symbolp item) (eval item) item)) val)
		     )
	       )
	 )
  :group 'refdb-menu-definitions
  :type '(repeat variable)
  )

(defcustom refdb-getnote-on-region-submenu-contents
  '(
    refdb-getnote-by-title-on-region-menu-item
    refdb-getnote-by-keyword-on-region-menu-item
    refdb-getnote-by-authorlink-on-region-menu-item
    refdb-getnote-by-keywordlink-on-region-menu-item
    refdb-getnote-by-periodicallink-on-region-menu-item
    refdb-getnote-by-idlink-on-region-menu-item
    refdb-getnote-by-citekeylink-on-region-menu-item
    )
  "*Contents of 'Get Notes on Region' submenu for RefDB mode.
Customize this to add/remove/rearrange submenus."
  :set (lambda (sym val)
	 (setq refdb-getnote-on-region-submenu-contents val)
	 (setq refdb-getnote-on-region-submenu-definition
	       (cons "Get Notes on Region"
		     ;; turn quoted contents value back into a real list
		     ;; thanks, sachac :)
		     (mapcar (lambda (item) (if (symbolp item) (eval item) item)) val)
		     )
	       )
	 )
  :group 'refdb-menu-definitions
  :type '(repeat variable)
  )

(defcustom refdb-customize-submenu-contents
  '(
    refdb-edit-refdbcrc-menu-item
    refdb-edit-refdbarc-menu-item
    refdb-edit-refdbibrc-menu-item
    refdb-menu-item-separator4
    refdb-edit-global-refdbdrc-menu-item
    refdb-edit-global-refdbcrc-menu-item
    refdb-edit-global-refdbarc-menu-item
    refdb-edit-global-refdbibrc-menu-item
    )
  "*Contents of 'Customize RefDB' submenu for RefDB mode.
Customize this to add/remove/rearrange submenus."
  :set (lambda (sym val)
	 (setq refdb-customize-submenu-contents val)
	 (setq refdb-customize-submenu-definition
	       (cons "Edit RefDB Config Files"
		     ;; turn quoted contents value back into a real list
		     (mapcar (lambda (item) (if (symbolp item) (eval item) item)) val)
		     )
	       )
	 )
  :group 'refdb-menu-definitions
  :type '(repeat variable)
  )

(defcustom refdb-administration-submenu-contents
  '(
    refdb-createdb-menu-item
    refdb-listdb-menu-item
    refdb-deletedb-menu-item
    refdb-menu-item-separator4
    refdb-addstyle-menu-item
    refdb-liststyle-menu-item
    refdb-getstyle-menu-item
    refdb-deletestyle-menu-item
    refdb-menu-item-separator4
    refdb-adduser-menu-item
    refdb-listuser-menu-item
    refdb-deleteuser-menu-item
    refdb-menu-item-separator4
    refdb-addword-menu-item
    refdb-listword-menu-item
    refdb-deleteword-menu-item
    refdb-menu-item-separator4
    refdb-scankw-menu-item
    refdb-viewstat-menu-item
    refdb-menu-item-separator4
    refdb-backup-database-menu-item
    refdb-restore-database-menu-item
    refdb-menu-item-separator4
    refdb-init-refdb-menu-item
    refdb-customize-menu-item
    refdb-customize-submenu-definition
    refdb-menu-item-separator4
    refdb-startd-menu-item
    refdb-stopd-menu-item
    refdb-restartd-menu-item
    refdb-reloadd-menu-item
    )
  "*Contents of 'Administration' submenu for RefDB mode.
Customize this to add/remove/rearrange submenus."
  :set (lambda (sym val)
	 (setq refdb-administration-submenu-contents val)
	 (setq refdb-administration-submenu-definition
	       (cons "Administration"
		     ;; turn quoted contents value back into a real list
		     ;; thanks, sachac :)
		     (mapcar (lambda (item) (if (symbolp item) (eval item) item)) val)
		     )
	       )
	 )
  :group 'refdb-menu-definitions
  :type '(repeat variable)
  )

(defcustom refdb-convert-submenu-contents
  '(
    refdb-convert-from-bibtex-menu-item
    refdb-convert-from-copac-menu-item
    refdb-convert-from-endnote-menu-item
    refdb-convert-from-isi-menu-item
    refdb-convert-from-medline-menu-item
    refdb-convert-from-mods-menu-item
    refdb-menu-item-separator4
    refdb-convert-to-endnote-menu-item
    refdb-convert-to-mods-menu-item
    )
  "*Contents of 'Convert References' submenu for RefDB mode.
Customize this to add/remove/rearrange submenus."
  :set (lambda (sym val)
	 (setq refdb-convert-submenu-contents val)
	 (setq refdb-convert-submenu-definition
	       (cons "Convert References"
		     ;; turn quoted contents value back into a real list
		     (mapcar (lambda (item) (if (symbolp item) (eval item) item)) val)
		     )
	       )
	 )
  :group 'refdb-menu-definitions
  :type '(repeat variable)
  )

(defcustom refdb-cite-references-contents
  '(
    refdb-create-docbook-citation-from-point-menu-item
    refdb-create-tei-citation-from-point-menu-item
    refdb-create-latex-citation-from-point-menu-item
    refdb-menu-item-separator4
    refdb-create-docbook-citation-on-region-menu-item
    refdb-create-tei-citation-on-region-menu-item
    refdb-create-latex-citation-on-region-menu-item
    )
  "*Contents of 'Cite References' submenu for RefDB mode.
Customize this to add/remove/rearrange submenus."
  :set (lambda (sym val)
	 (setq refdb-cite-references-submenu-contents val)
	 (setq refdb-cite-references-submenu-definition
	       (cons "Cite References"
		     ;; turn quoted contents value back into a real list
		     (mapcar (lambda (item) (if (symbolp item) (eval item) item)) val)
		     )
	       )
	 )
  :group 'refdb-menu-definitions
  :type '(repeat variable)
  )

(defcustom refdb-create-document-submenu-contents
  '(
    refdb-create-docbook31-menu-item
    refdb-create-docbook40-menu-item
    refdb-create-docbook41-menu-item
    refdb-menu-item-separator4
    refdb-create-docbook41x-menu-item
    refdb-create-docbook42x-menu-item
    refdb-create-docbook43x-menu-item
    refdb-menu-item-separator4
    refdb-create-teip4-menu-item
    )
  "*Contents of 'Create Document' submenu for RefDB mode.
Customize this to add/remove/rearrange submenus."
  :set (lambda (sym val)
	 (setq refdb-create-document-submenu-contents val)
	 (setq refdb-create-document-submenu-definition
	       (cons "Create Document"
		     ;; turn quoted contents value back into a real list
		     (mapcar (lambda (item) (if (symbolp item) (eval item) item)) val)
		     )
	       )
	 )
  :group 'refdb-menu-definitions
  :type '(repeat variable)
  )

(defcustom refdb-transform-submenu-contents
  '(
    refdb-create-html-menu-item
    refdb-create-xhtml-menu-item
    refdb-create-pdf-menu-item
    refdb-create-rtf-menu-item
    refdb-create-postscript-menu-item
    refdb-create-custom-menu-item
    refdb-clean-output-menu-item
    )
  "*Contents of 'Transform' submenu for RefDB mode.
Customize this to add/remove/rearrange submenus."
  :set (lambda (sym val)
	 (setq refdb-transform-submenu-contents val)
	 (setq refdb-transform-submenu-definition
	       (cons "Transform Document"
		     ;; turn quoted contents value back into a real list
		     (mapcar (lambda (item) (if (symbolp item) (eval item) item)) val)
		     )
	       )
	 )
  :group 'refdb-menu-definitions
  :type '(repeat variable)
  )

(defcustom refdb-view-output-submenu-contents
  '(
    refdb-view-html-menu-item
    refdb-view-xhtml-menu-item
    refdb-view-pdf-menu-item
    refdb-view-rtf-menu-item
    refdb-view-postscript-menu-item
    )
  "*Contents of 'View Output' submenu for RefDB mode.
Customize this to add/remove/rearrange submenus."
  :set (lambda (sym val)
	 (setq refdb-view-output-submenu-contents val)
	 (setq refdb-view-output-submenu-definition
	       (cons "View Output"
		     ;; turn quoted contents value back into a real list
		     (mapcar (lambda (item) (if (symbolp item) (eval item) item)) val)
		     )
	       )
	 )
  :group 'refdb-menu-definitions
  :type '(repeat variable)
  )

(defcustom refdb-menu-contents
  '(
    refdb-addref-menu-item
    refdb-updateref-menu-item
    refdb-deleteref-menu-item
    refdb-getref-submenu-definition
    refdb-getref-on-region-submenu-definition
    refdb-getref-from-citation-menu-item
    refdb-pickref-menu-item
    refdb-dumpref-menu-item
    refdb-convert-submenu-definition
    refdb-menu-item-separator4
    refdb-addnote-menu-item
    refdb-updatenote-menu-item
    refdb-deletenote-menu-item
    refdb-getnote-submenu-definition
    refdb-getnote-on-region-submenu-definition
    refdb-addlink-menu-item
    refdb-deletelink-menu-item
    refdb-menu-item-separator4
    refdb-data-output-submenu-definition
    refdb-selectdb-submenu-contents
    refdb-whichdb-menu-item
    refdb-menu-item-separator4
    refdb-create-document-submenu-definition
    refdb-cite-references-submenu-definition
    refdb-transform-submenu-definition
    refdb-view-output-submenu-definition
    refdb-menu-item-separator4
    refdb-administration-submenu-definition
    refdb-menu-item-separator4
    refdb-show-messages-menu-item
    refdb-show-version-menu-item
    refdb-show-manual-menu-item
    )
  "*Contents of command `refdb-mode' menu.
Customize this to add/remove/rearrange submenus."
  :set (lambda (sym val)
	 (setq refdb-menu-contents val)
	 (setq refdb-menu-definition
	       (cons "RefDB"
		     (mapcar (lambda (item) (if (symbolp item) (eval item) item)) val)
		     )
	       )
	 )
  :group 'refdb-menu-definitions
  :type '(repeat variable)
  )
)

;; *******************************************************************
;;; end of user-customizable options, part 2
;; *******************************************************************


(define-key-after menu-bar-tools-menu [refdb-mode-toggle]
  ;; add "RefDB Mode" item to Tools menu
     '(menu-item "RefDB Mode" refdb-mode
		 :help "Toggle RefDB Mode"
		 :button (:toggle . (and (boundp 'refdb-mode) refdb-mode))
		 ;; hide if 'suppress' flag is set
		 :visible (not refdb-menu-suppress-toggle-flag)
		 )
     nil)

(provide 'refdb-mode)

;; *******************************************************************
;;; refdb-output-mode
;; *******************************************************************


;; define a mode for RefDB plain text output.
;; the main purpose of this mode is to keep the RefDB menu available
;; in the plain text output. Besides, it colors error/warning/ok modes
;; nicely
(make-face 'refdb-output-ok-face)
(make-face 'refdb-output-warning-face)
(make-face 'refdb-output-error-face)

(set-face-foreground 'refdb-output-ok-face "green")
(set-face-foreground 'refdb-output-warning-face "blue")
(set-face-foreground 'refdb-output-error-face "red")

(defvar refdb-output-font-lock-keywords
  '(
    ;; ok
    ("^\\([0-9][0-9][0-9]:\\).*" 1 'refdb-output-ok-face t)

    ;; errors
    ("^\\(209:\\|239:\\|253:\\|255:\\|410:\\|411:\\|412:\\|414:\\|416:\\|417:\\|420:\\).*" 1 'refdb-output-error-face t)

    ;; warnings
    ("^\\(252:\\|409:\\|415:\\|418:\\|422:\\|423:\\|424:\\).*" 1 'refdb-output-warning-face t)
    )
  "Keyword highlighting specification for `refdb-output-mode'.")

(require 'derived)

;;;###autoload
(define-derived-mode refdb-output-mode fundamental-mode "refdb-output"
  "A major mode for displaying RefDB plain-text output."
  (set (make-local-variable 'font-lock-defaults)
       '(refdb-output-font-lock-keywords))
)

(provide 'refdb-output-mode)

;;; refdb-mode.el ends here
