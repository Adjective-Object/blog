
all: html

html: site
	LANG=en_US.UTF-8 ./site rebuild > /dev/null

watch: site
	./site watch

site: site.hs
	ghc --make -threaded -dynamic site.hs
