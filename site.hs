--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
import          Data.Monoid (mappend)
import          Data.List (isInfixOf)
import          Hakyll
import          Hakyll.Web.Sass (sassCompiler)
import          System.FilePath.Posix (
                    takeBaseName,takeDirectory,
                    (</>),splitFileName)

import GHC.IO.Encoding

--------------------------------------------------------------------------------
main :: IO ()
main = do
    setLocaleEncoding utf8
    setFileSystemEncoding utf8
    setForeignEncoding utf8

    hakyll $ do
    

    match "assets/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*.scss" $ do
        route   $ setExtension "css"
        compile $ sassCompiler

    match "index.md" $ do
        route   $ setExtension "html"
        compile $ do 

            -- load all posts
            posts <- recentFirst =<< loadAll "posts/*"

            -- default fields passed to the template
            let recent = take 5 posts
                indexCtx =
                    listField "posts" postCtx (return recent) `mappend`
                    defaultContext

            pandocCompiler
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/index.html" indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls
                >>= removeIndexHtml

    match "contact.md" $ do
        route niceRoute
        compile $ do 
            pandocCompiler
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls
                >>= removeIndexHtml


    match "posts/*" $ do
        route $ niceRoute
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls
            >>= removeIndexHtml


    create ["archive.html"] $ do
        route niceRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls
                >>= removeIndexHtml

    --match "index.html" $ do
    --    route $ setExtension "html"
    --    compile $ do
    --        -- load all posts
    --        posts <- recentFirst =<< loadAll "posts/*"

    --        -- default fields passed to the template
    --        let recent = take 5 posts
    --            indexCtx =
    --                listField "posts" postCtx (return recent) `mappend`
    --                defaultContext

    --        -- 
    --        getResourceBody 
    --            >>= applyAsTemplate indexCtx
    --            >>= loadAndApplyTemplate "templates/default.html" indexCtx
    --            >>= relativizeUrls
    --            >>= removeIndexHtml

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext


-- replace a foo/bar.md by foo/bar/index.html
-- this way the url looks like: foo/bar in most browsers
niceRoute :: Routes
niceRoute = customRoute createIndexRoute 
    where createIndexRoute ident = 
            takeDirectory p </> takeBaseName p </> "index.html"
            where p=toFilePath ident


-- replace url of the form foo/bar/index.html by foo/bar
removeIndexHtml :: Item String -> Compiler (Item String)
removeIndexHtml item = return $ fmap (withUrls removeIndexStr) item
  where
    removeIndexStr :: String -> String
    removeIndexStr url = case splitFileName url of
        (dir, "index.html") | isLocal dir -> dir
        _                                 -> url
        where isLocal uri = not (isInfixOf "://" uri)
