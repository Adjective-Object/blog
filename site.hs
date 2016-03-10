--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
import          Data.Monoid (mappend)
import          Data.List (isInfixOf, intercalate, findIndex)
import          Data.List.Split (splitWhen)
import          Data.Char (isSpace)
import          Hakyll
import          Hakyll.Web.Sass (sassCompiler)
import          System.FilePath.Posix (
                    takeBaseName,takeDirectory,
                    (</>),(<.>),splitFileName)

import GHC.IO.Encoding

--------------------------------------------------------------------------------

(<>) = mappend

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
            posts <- recentFirst =<< loadAll ("posts/*" .&&. hasNoVersion)

            -- default fields passed to the template
            let recent = take 5 posts
                indexCtx =
                    listField "posts" postCtx (return recent) <>
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


    --------------------
    -- POSTS + OEMBED --
    --------------------

    match "posts/*" $ do 
        route $ niceRoute
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls
            >>= removeIndexHtml

    match "posts/*" $ version "oembed-json" $ do 
        route $ (oEmbedRoute "json")
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/oembed.json" postCtx
            >>= relativizeUrls

    match "posts/*" $ version "oembed-xml" $ do 
        route $ (oEmbedRoute "xml")
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/oembed.xml" postCtx
            >>= relativizeUrls


    -------------
    -- ARCHIVE --
    -------------

    create ["archive.html"] $ do
        route niceRoute
        compile $ do
            posts <- recentFirst =<< loadAll ("posts/*" .&&. hasNoVersion)
            let informedArchiveCtx = archiveCtx posts
            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" informedArchiveCtx
                >>= loadAndApplyTemplate "templates/default.html" informedArchiveCtx
                >>= relativizeUrls
                >>= removeIndexHtml

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y"    <>
    metaKeywordContext              <>
    defaultContext                  <>
    oEmbedCtx                       <>
    teaserCtx

archiveCtx :: [Item String] -> Context String
archiveCtx posts =
    listField "posts" postCtx (return posts) <>
    constField "title" "Archives"            <>
    defaultContext

teaserCtx :: Context String
teaserCtx = 
    (field "teaser-description" $ \item -> do
        rawText <- getResourceBody
        let text = itemBody rawText
            teaserIndex = subListIndex "<!-- more -->" text
            extractText i = take i text
            removeNewlines = filter ((/=) '\n')
        return $ maybe "" (removeNewlines . extractText) teaserIndex) <>
    (field "teaser-description-tag" $ \item -> do
        teaserText <- getMetadataField (itemIdentifier item) "teaser-description"
        let wrapTag t = "<meta name=\"Description\" content\"" ++ t ++ "\" />"
        return $ maybe "" wrapTag teaserText)

oEmbedCtx :: Context String
oEmbedCtx = 
    (field "oembed-url" $ \item -> do
        path <- getResourceFilePath
        return $ "/" ++ createOEmbedRoute path) <>
    (field "oembed-thumbnail-url" $ \item -> do
        given_url <- getMetadataField (itemIdentifier item) "thumbnail"
        my_url <- getRoute (itemIdentifier item)
        let thumb_url = maybe "/assets/profile.jpg" id given_url
            my_real_url = maybe "" id my_url
        return $ (toSiteRoot my_real_url) ++ thumb_url
    )

-- construct a meta keyword string based on the tags field of a project 
metaKeywordContext :: Context String
metaKeywordContext = field "meta-keyword-tag" $ \item -> do 
      tags <- getMetadataField (itemIdentifier item) "tags"
      -- if tags is empty return an empty string
      -- in the other case return
      --   <meta name="keywords" content="$tags$">
      return $ maybe "" showMetaTags tags
            where
            showMetaTags t = "<meta name=\"keywords\" content=\""
                             ++ cleanTags t ++ "\">\n"
            cleanTags = collapseCommas . fillCommas
            fillCommas = map (\c -> if c == '\n' || isSpace c then ',' else c)
            collapseCommas x = 
                foldl (\a b ->
                    if (b == ',' && last a == ',')
                        then a
                        else a ++ [b]) 
                [head x]
                (tail x)

-- replace a foo/bar.md by foo/bar/index.html
-- this way the url looks like: foo/bar in most browsers
niceRoute :: Routes
niceRoute = customRoute createIndexRoute 
    where createIndexRoute ident = 
            takeDirectory p </> takeBaseName p </> "index.html"
            where p=toFilePath ident

-- routes for generating oEmbed content
oEmbedRoute :: String -> Routes
oEmbedRoute extension = customRoute (\ x -> 
    (createOEmbedRoute . toFilePath) x <.> extension)
createOEmbedRoute filepath = "oembed" </> filepath

-- replace url of the form foo/bar/index.html by foo/bar
removeIndexHtml :: Item String -> Compiler (Item String)
removeIndexHtml item = return $ fmap (withUrls removeIndexStr) item
  where
    removeIndexStr :: String -> String
    removeIndexStr url = case splitFileName url of
        (dir, "index.html") | isLocal dir -> dir
        _                                 -> url
        where isLocal uri = not (isInfixOf "://" uri)


--------------------------------------------------------------------------------
-- Utils
--------------------------------------------------------------------------------

subListIndex :: [Char] -> [Char] -> Maybe Int
subListIndex _ [] = Nothing
subListIndex as xxs@(x:xs)
  | all (uncurry (==)) $ zip as xxs = Just 0
  | otherwise                       = incremented
    where   incremented = maybe Nothing incrementJust len_xs
            incrementJust i = Just $ i + 1 
            len_xs = subListIndex as xs
        

