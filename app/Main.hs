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
    let pageNumbers = [startPage..11]  -- Páginas de 2 a 11
    mapConcurrently (scrapeAndProcessPage baseUrl) pageNumbers

scrapeAndProcessPage :: String -> Int -> IO [String]
scrapeAndProcessPage baseUrl page = do
    let url = baseUrl ++ show page
    result <- scrapeURL url fetch_links
    case result of
        Just links -> do
            --putStrLn ("Resultados da página " ++ show page ++ ":")
            processedLinks <- mapM processLink links
            --putStrLn ""
            return processedLinks
        Nothing -> do
            putStrLn ("Falha ao processar a página " ++ show page)
            return []

fetch_links :: Scraper String [String]
fetch_links = chroots ("h4" @: [hasClass "search-result-item-heading"]) isolate_link

isolate_link :: Scraper String String
isolate_link = link_book

link_book :: Scraper String String
link_book = do
    --header <- text $ "a"
    url <- attr "href" "a"
    return $ url

processLink :: String -> IO String
processLink links = do
    let bookUrl = links
    --putStrLn $ "Acessando link: " ++ bookUrl
    result <- scrapeURL bookUrl fetch_book
    case result of
        Just bookData -> do
            --putStrLn "Dados do livro:"
            mapM_ putStrLn bookData
            --putStrLn ""
            return links
        Nothing -> do
            putStrLn "Falha ao processar a página do livro"
            return ""

fetch_book :: Scraper String [String]
fetch_book = chroots ("div" @: [hasClass "main"]) isolate_book

isolate_book :: Scraper String String
isolate_book = book

book :: Scraper String String
book = do
    title <- text "span"
    autor <- text "a"
    --autor <- text $ "span#lblNomArtigo"
    --autor <- text  "" $ "div" @: [hasClass "autordiretor"] 
    return autor

main :: IO ()
main = do
    putStrLn "Digite o livro que deseja encontrar:"
    livro <- getLine
    result <- scrapingTravessa livro
    case result of
        Just updates -> do
            putStrLn ("Resultados da página 1:")
            --mapM_ putStrLn updates
            putStrLn ""
            putStrLn "Processamento concluído"
        Nothing -> putStrLn "Falha ao processar os resultados"
