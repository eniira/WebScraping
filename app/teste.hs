{-# LANGUAGE OverloadedStrings #-}

import Control.Concurrent.Async
import Text.HTML.Scalpel

scrapingTravessa :: String -> IO (Maybe [String])
scrapingTravessa livro = do
    let baseUrl = "https://www.travessa.com.br/Busca.aspx?d=1&bt=" ++ livro ++ "&cta=00&codtipoartigoexplosao=&pag="
        page = 1
        firstPageUrl = baseUrl ++ show page
    result <- scrapeURL firstPageUrl fetch_links

    case result of
        Just updates -> do
            rest <- scrapeNextPagesParallel baseUrl (page + 1)
            return (Just (updates ++ concat rest))
        Nothing -> return Nothing

scrapeNextPagesParallel :: String -> Int -> IO [[String]]
scrapeNextPagesParallel baseUrl startPage = do
    let pageNumbers = [startPage..11]  -- Páginas de 2 a 21
    mapConcurrently_ (scrapeAndPrintPage baseUrl) pageNumbers
    return []

scrapeAndPrintPage :: String -> Int -> IO ()
scrapeAndPrintPage baseUrl page = do
    let url = baseUrl ++ show page
    result <- scrapeURL url fetch_links
    case result of
        Just updates -> do
            putStrLn ("Resultados da página " ++ show page ++ ":")
            mapM_ putStrLn updates
            putStrLn ""
        Nothing -> putStrLn ("Falha ao processar a página " ++ show page)

fetch_links :: Scraper String [String]
fetch_links = chroots ("h4" @: [hasClass "search-result-item-heading"]) isolate_link

isolate_link :: Scraper String String
isolate_link = link_book

link_book :: Scraper String String
link_book = do
    header <- text $ "a"
    url <- attr "href" "a"
    processLink url
    --return (header, url)

processLink :: String -> IO ()
processLink url = do
    let bookUrl = url
    -- Faça aqui o processamento adicional que você deseja realizar para cada link
    -- Implemente a raspagem dos dados desejados da página do livro usando scrapeURL
    -- Exemplo:
    result <- scrapeURL bookUrl fetch_book
    case result of
        Just bookData -> do
            putStrLn ("Dados do livro:")
            mapM_ putStrLn bookData
        Nothing -> putStrLn ("Falha ao processar a página do livro")
    where
        fetch_book :: Scraper String [String]
        fetch_book = do
            -- Defina os seletores e scrapers apropriados para extrair os dados desejados da página do livro
            -- Exemplo:
            title <- text "span"
            return [title]

main :: IO ()
main = do
    putStrLn "Digite o livro que deseja encontrar:"
    livro <- getLine
    result <- scrapingTravessa livro
    case result of
        Just updates -> do
            putStrLn ("Resultados da página 1:")
            mapM_ putStrLn updates
            putStrLn ""
            putStrLn "Processamento concluído"
        Nothing -> putStrLn "Falha ao processar os resultados"

-- {-# LANGUAGE OverloadedStrings #-}

-- import Text.HTML.Scalpel
-- import Control.Applicative

-- print_azure_updates :: IO (Maybe [String])
-- print_azure_updates = scrapeURL "https://azure.microsoft.com/en-gb/updates/" fetch_updates
--     where
--         fetch_updates :: Scraper String [String]
--         fetch_updates = chroots ("h3" @: [hasClass "text-body2"]) isolate_update
        
--         isolate_update :: Scraper String String
--         isolate_update = update
        
--         update :: Scraper String String
--         update = do 
--             header <- text $ "a"
--             return $ header

{-# LANGUAGE OverloadedStrings #-}

import Text.HTML.Scalpel
import Control.Applicative


scrapingTravessa :: IO (Maybe [String])
    putStrLn "Digite o livro que deseja encontrar:"
    livro <- getLine
    putStrLn ("Olá, " ++ name ++ "! Bem-vindo(a) ao Haskell!")
scrapingTravessa = scrapeURL "https://www.travessa.com.br/Busca.aspx?d=1&bt= ++ livro ++&cta=00&codtipoartigoexplosao=1" fetch_updates
    where
        fetch_updates :: Scraper String [String]
        fetch_updates = chroots ("h4" @: [hasClass "search-result-item-heading"]) isolate_update
        
        isolate_update :: Scraper String String
        isolate_update = update
        
        update :: Scraper String String
        update = do 
            header <- text $ "a"
            return $ header


-- import Text.HTML.Scalpel
-- import Text.HTML.Scalpel.Select
-- import Text.HTML.Scalpel.Types
-- import Control.Applicative

-- scrapingTravessa :: IO (Maybe [String])
-- scrapingTravessa = scrapeURL "https://www.travessa.com.br/Busca.aspx?d=1&bt=harry%20potter&cta=00&codtipoartigoexplosao=1" fetch_updates
--     where
--         fetch_updates :: Scraper String [String]
--         fetch_updates = chroots (tagSelector "h4" @: [hasClass "search-result-item-heading"]) isolate_update
        
--         isolate_update :: Scraper String String
--         isolate_update = update
        
--         update :: Scraper String String
--         update = do 
--             header <- text $ selector "a"
--             return $ header




mport Text.HTML.Scalpel
-- import Text.HTML.Scalpel.Core
-- import Control.Applicative


scrapingTravessa :: String -> IO (Maybe [String])
scrapingTravessa livro = do
    let baseUrl = "https://www.travessa.com.br/Busca.aspx?d=1&bt=" ++ livro ++ "&cta=00&codtipoartigoexplosao="
    let page = 1
    let firstPageUrl = baseUrl ++ show page
    result -> scrapeURL firstPageUrl fetch_updates
  where
    fetch_updates :: Scraper String [String]
    fetch_updates = chroots ("h4" @: [hasClass "search-result-item-heading"]) isolate_update
        
    isolate_update :: Scraper String String
    isolate_update = update
        
    update :: Scraper String String
    update = do 
       header <- text  $ "a"
       return $ header

main :: IO ()
main = do
    putStrLn "Digite o livro que deseja encontrar:"
    livro <- getLine
    result <- scrapingTravessa livro
    case result of
        Just updates -> mapM_ putStrLn updates
        Nothing -> putStrLn "Failed to scrape updates"
          












