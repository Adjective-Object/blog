
watch: site
	./site watch


site-static: site.hs
	ghc --make -threaded site.hs -o $@

site: site.hs
	ghc --make -threaded -dynamic site.hs
