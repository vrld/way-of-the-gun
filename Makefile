love=/usr/bin/env love
zip=/usr/bin/env zip
luac=/usr/bin/env luac

# path to win and osx distributions
windir=~/love-dist/love-0.8.0-win-x86
osxapp=~/love-dist/love.app

game=way-of-the-gun
sources=$(wildcard *.lua **/*.lua)
res=$(wildcard font/*.ttf img/*.png snd/*.ogg) #adjust accordingly

# change this for out of tree builds. directories must exist
builddir=build
distdir=dist

.PHONY : run test love clean win

run : test imgs snd
	$(love) .

test : $(sources) $(res)
	$(luac) -p $(sources)

imgs: $(wildcard ~/shared/D/ldf7/*.png)
	cp ~/shared/D/ldf7/*.png ~/way-of-the-gun/img/

snd: $(wildcard ~/shared/D/ldf7/*.ogg)
	cp ~/shared/D/ldf7/*.ogg ~/way-of-the-gun/snd/

dist : love win osx

love : $(builddir)/$(game).love imgs snd
	cp $(builddir)/$(game).love $(distdir)/$(game).love

osx : $(builddir)/$(game).app
	zip -9 -q -r $(distdir)/$(game).osx.zip $(builddir)/$(game).app/

win : $(builddir)/$(game).exe
	cd $(builddir); \
	cp $(windir)/*.dll .; \
	zip -q ../$(distdir)/$(game).win.zip $(game).exe *.dll; \
	rm *.dll

$(builddir)/$(game).app : $(builddir)/$(game).love
	cp -a $(osxapp) $(builddir)/$(game).app
	cp $(builddir)/$(game).love $(builddir)/$(game).app/Contents/Resources/

$(builddir)/$(game).exe : $(builddir)/$(game).love
	cat $(windir)/love.exe $(builddir)/$(game).love > $(builddir)/$(game).exe

$(builddir)/$(game).love : $(sources) $(res)
	mkdir -p $(builddir)
	$(zip) $(builddir)/$(game).love $(sources) $(res)

clean :
	rm -rf $(builddirdir)/* $(distdir)/*
