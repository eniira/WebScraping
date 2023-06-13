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
    return $ header ++ " " ++ url

processLink :: String -> IO (Maybe [String])
processLink link_book = do
    let bookUrl = link_book
    --putStrLn $ "Acessando link: " ++ fullUrl
    -- Faça aqui o processamento adicional que você deseja realizar para cada link
    
    -- Exemplo: Imprimir o conteúdo da página
    scrapeURL bookUrl fetch_book
    where
      fetch_book :: Scraper String [String]
      fetch_book = chroots ("div" @: [hasClass "page singleProduct"]) isolate_book

      isolate_book :: Scraper String String
      isolate_book = book

      book :: Scraper String String
      book = do
          title <- text "span"
    -- url <- attr "href" "a"
          return $ title
 
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

-- scrapingTravessa :: String -> IO (Maybe [String])
-- scrapingTravessa livro = do
--     let baseUrl = "https://www.travessa.com.br/Busca.aspx?d=1&bt=" ++ livro ++ "&cta=00&codtipoartigoexplosao="
--         page = 1
--         firstPageUrl = baseUrl ++ show page
--     result <- scrapeURL firstPageUrl fetch_updates

--     case result of
--         Just updates -> do
--             rest <- scrapeNextPages baseUrl (page + 1)
--             return (Just (updates ++ rest))
--         Nothing -> return Nothing

-- scrapeNextPages :: String -> Int -> IO [String]
-- scrapeNextPages baseUrl page = do
--     let url = baseUrl ++ show page
--     result <- scrapeURL url fetch_updates
--     case result of
--         Just updates -> do
--             moreUpdates <- scrapeNextPages baseUrl (page + 1)
--             return (updates ++ moreUpdates)
--         Nothing -> return []

-- fetch_updates :: Scraper String [String]
-- fetch_updates = chroots ("h4" @: [hasClass "search-result-item-heading"]) isolate_update
        
-- isolate_update :: Scraper String String
-- isolate_update = update
        
-- update :: Scraper String String
-- update = do 
--     header <- text "a"
--     return header

-- main :: IO ()
-- main = do
--     putStrLn "Digite o livro que deseja encontrar:"
--     livro <- getLine
--     result <- scrapingTravessa livro
--     case result of
--         Just updates -> mapM_ putStrLn updates
--         Nothing -> putStrLn "Failed to scrape updates"







-- {-# LANGUAGE OverloadedStrings #-}

-- import Text.HTML.Scalpel
-- import Control.Monad
-- -- import Text.HTML.Scalpel.Core
-- -- import Control.Applicative


-- scrapingTravessa :: String -> IO (Maybe [String])
-- scrapingTravessa livro = do
--     let baseUrl = "https://www.travessa.com.br/Busca.aspx?d=1&bt=" ++ livro ++ "&cta=00&codtipoartigoexplosao=1&pag=2"
--     -- let page = 2
--     -- let firstPageUrl = baseUrl ++ show page
--     -- result <- scrapeURL firstPageUrl fetch_updates
--     scrapeURL baseUrl fetch_updates
--     -- case result of
--     --     Just updates -> do
--     --         rest <- scrapeNextPages baseUrl (page + 1)
--     --         return (updates ++ rest)
--     --     Nothing -> return []

--     -- scrapeNextPages :: String -> Int -> IO [String]
--     -- scrapeNextPages baseUrl page = do
--     --     let url = baseUrl ++ show page
--     --     result <- scrapeURL url fetch_updates
--     --     case result of
--     --         Just updates -> do
--     --             moreUpdates <- scrapeNextPages baseUrl (page + 1)
--     --             return (updates ++ moreUpdates)
--     --         Nothing -> return []
--     where
--     fetch_updates :: Scraper String [String]
--     fetch_updates = chroots ("h4" @: [hasClass "search-result-item-heading"]) isolate_update
        
--     isolate_update :: Scraper String String
--     isolate_update = update
        
--     update :: Scraper String String
--     update = do 
--        header <- text  $ "a"
--        return $ header

-- main :: IO ()
-- main = do
--     putStrLn "Digite o livro que deseja encontrar:"
--     livro <- getLine
--     result <- scrapingTravessa livro
--     case result of
--         Just updates -> mapM_ putStrLn updates
--         Nothing -> putStrLn "Failed to scrape updates"

        

        
                   

