#
# Makefile
# $Id: Makefile,v 1.4 2003-08-22 18:06:33 ukai Exp $
#

all: text html

%.txt: %.sgml
	LANG=C debiandoc2text $<

%.html/index.html: %.sgml
	LANG=C debiandoc2html $<

txt text: ruby-policy.txt
html: ruby-policy.html/index.html

clean:
	-rm -f ruby-policy.txt
	-rm -rf ruby-policy.html

#
