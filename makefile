
watch: site
	./site watch

site: site.hs
	ghc --make -threaded -dynamic site.hs
