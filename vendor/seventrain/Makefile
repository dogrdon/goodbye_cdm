VERSION=1.1beta1

DISTFILES=7train.xsl \
doc/ \
drivers/ \
cdm.bat \
cdmmd2dc.xwalk \
cdm.sh \
cdm.xsl \
examples/ \
input/ \
LICENSE \
README* \
SAXON_LICENSE \
saxon9.jar \
xwalker.xsl \

BASENAME=7train-$(VERSION)

dist: $(DISTFILES) docs
	mkdir tmp/
	mkdir tmp/$(BASENAME)
	cp -a $(DISTFILES) tmp/$(BASENAME)/
	cd tmp && find . -name \\.svn -type d | xargs rm -rf
	tar czvf $(BASENAME).tar.gz -C tmp/ --exclude \\.svn $(BASENAME)
	cd tmp && zip -r ../$(BASENAME).zip $(BASENAME) -x \\.svn
	cd ..
	rm -rf tmp/

docs:
	rst2pdf -s rst2pdf.style README
	rst2html README > README.html
	rst2pdf -s rst2pdf.style doc/About7train.txt -o doc/About7train.pdf
	rst2html doc/About7train.txt > doc/About7train.html
	rst2pdf -s rst2pdf.style doc/Customizing.txt -o doc/Customizing.pdf
	rst2html doc/Customizing.txt > doc/Customizing.html

clean:
	rm -rf tmp
	rm -f $(BASENAME).tar.gz $(BASENAME).zip
	rm -f README.html README.pdf doc/About7train.pdf doc/About7train.html doc/Customizing.pdf doc/Customizing.html
