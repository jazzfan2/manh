# Name: manh
manh - opens internal or external manual page in - no-snap version - Firefox or Lynx browser

# Description:
This program opens a given internal or external manual page (man-page) in a - no-snap version-  Firefox or Lynx browser (alternative for bash-functions 'hman' or 'man --html=firefox').

Default source: (internal) man-page from own Ubuntu-installation.

With options for various (external) alternative man-page sources on the Internet. To be extendible as desired.

Finds pages if existent at chosen source, even if command in question is not present on own system.
Outputs via Links or Lynx browser to terminal if opted for.

# How to use manh:
Usage:

	manh [-cdDhHlLmMu] <command_name>

Options:

	-h     Help (this output)
	-l     Open output in Links instead of Firefox
	-L     Open output in Lynx instead of Firefox
	-c     Open man page via https://man.cx/
	-d     Open man page via https://linux.die.net
	-D     Open man page via https://manpages.debian.org
	-H     Open man page via man.he.net/
	-m     Open man page via https://man7.org/linux/man-pages/
	-M     Open man page via https://manpages.org
	-u     Open man page via https://manpages.ubuntu.com/

# Author:
Written by Rob Toscani (rob_toscani@yahoo.com).
