version := 0.4
rst2html := rst2html.py --generator --time

html: Manual.html
	open Manual.html

dist: source ASUnit.scpt Manual.html
	-rm -rf ASUnit
	-mkdir ASUnit
	cp ASUnit.scpt ASUnit
	cp Manual.html ASUnit
	cp COPYING ASUnit
	zip -9 -r -m versions/ASUnit-$(version).zip ASUnit
	
source:
	bzr export versions/ASUnit-$(version).src.tgz	

Manual.html: Manual.txt
	$(rst2html) Manual.txt > Manual.html

ASUnit.scpt: ASUnit.applescript
	osacompile -d -o ASUnit.scpt ASUnit.applescript

.PHONY: dist
