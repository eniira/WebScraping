-- -- {-# LANGUAGE OverloadedStrings #-}

-- -- import Control.Concurrent.Async
-- -- import Text.HTML.Scalpel

-- -- data InfoBook = InfoBook
-- --     { title :: String
-- --     , author :: String
-- --     --, link :: String
-- --     , price :: String
-- --     , img :: URL
-- --     , description :: String
-- --     } deriving Show

-- -- scrapingTravessa :: String -> IO (Maybe [String])
-- -- scrapingTravessa livro = do
-- --     let baseUrl = "https://www.travessa.com.br/Busca.aspx?d=1&bt=" ++ livro ++ "&cta=00&codtipoartigoexplosao=&pag="
-- --         page = 0
-- --         firstPageUrl = baseUrl ++ show page
-- --     result <- scrapeURL firstPageUrl fetch_links

-- --     case result of
-- --         Just updates -> do
-- --             rest <- scrapeNextPagesParallel baseUrl (page + 1)
-- --             return (Just (updates ++ concat rest))
-- --         Nothing -> return Nothing

-- -- scrapeNextPagesParallel :: String -> Int -> IO [[String]]
-- -- scrapeNextPagesParallel baseUrl startPage = do
-- --     let pageNumbers = [startPage..26]  -- Páginas de 2 a 11
-- --     mapConcurrently (scrapeAndProcessPage baseUrl) pageNumbers

-- -- scrapeAndProcessPage :: String -> Int -> IO [String]
-- -- scrapeAndProcessPage baseUrl page = do
-- --     let url = baseUrl ++ show page
-- --     result <- scrapeURL url fetch_links
-- --     case result of
-- --         Just links -> do
-- --             processedLinks <- mapM processLink links
-- --             return processedLinks
-- --         Nothing -> do
-- --             putStrLn ("Falha ao processar a página " ++ show page)
-- --             return []

-- -- fetch_links :: Scraper String [String]
-- -- fetch_links = chroots ("h4" @: [hasClass "search-result-item-heading"]) isolate_link

-- -- isolate_link :: Scraper String String
-- -- isolate_link = link_book

-- -- link_book :: Scraper String String
-- -- link_book = do
-- --     url <- attr "href" "a"
-- --     return $ url

-- -- processLink :: String -> IO String
-- -- processLink links = do
-- --     let bookUrl = links
-- --     result <- scrapeURL bookUrl fetch_book
-- --     case result of
-- --         Just bookData -> do
-- --             mapM_ printBook bookData
-- --             return links
-- --         Nothing -> do
-- --             putStrLn "Falha ao processar a página do livro"
-- --             return ""

-- -- -- processLink :: String -> IO String
-- -- -- processLink link = do
-- -- --     let bookUrl = link
-- -- --     bookResult <- scrapeURL bookUrl fetch_book
-- -- --     sinopseResult <- scrapeURL bookUrl fetch_sinopse

-- -- --     case (bookResult, sinopseResult) of
-- -- --         (Just bookData, Just sinopseData) -> do
-- -- --             mapM_ printBook bookData
-- -- --             mapM_ printBook sinopseData
-- -- --             return link
-- -- --         _ -> do
-- -- --             putStrLn "Falha ao processar a página do livro ou da sinopse"
-- -- --             return ""


-- -- fetch_book :: Scraper String [InfoBook]
-- -- fetch_book = chroots ("div" @: [hasClass "main"]) isolate_book

-- -- -- fetch_sinopse :: Scraper String [InfoBook]
-- -- -- fetch_sinopse = chroots ("div" @: [hasClass "sinopse"]) isolate_sinopse

-- -- isolate_book :: Scraper String InfoBook
-- -- isolate_book = book

-- -- -- isolate_sinopse :: Scraper String InfoBook
-- -- -- isolate_sinopse = sinopse

-- -- book :: Scraper String InfoBook
-- -- book = do
-- --     titleText <- text "span"
-- --     authorText <- text "a"
-- --     priceText <-  text $ "strong" 
-- --     imgUrl <- attr "src" $ "imgUrl" 
-- --     return (InfoBook titleText authorText priceText imgUrl "")

-- -- -- sinopse :: Scraper String InfoBook
-- -- -- sinopse = do
-- -- --     descriptionText <- text "p"
-- -- --     return (InfoBook "" "" "" "" descriptionText)

-- -- printBook :: InfoBook -> IO ()
-- -- printBook book = do
-- --     putStrLn ("Título: " ++ title book)
-- --     putStrLn ("Autor: " ++ author book)
-- --     putStrLn ("Preço: " ++ price book)
-- --     putStrLn ("Imagem: " ++ img book)
-- --     --putStrLn ("Descrição: " ++ description book)
-- --     putStrLn "-------------------"

-- -- main :: IO ()
-- -- main = do
-- --     putStrLn ""
-- --     putStrLn "Digite o livro que deseja encontrar:"
-- --     livro <- getLine
-- --     putStrLn ""
-- --     putStrLn "Carregando..."
-- --     putStrLn ""
-- --     result <- scrapingTravessa livro
-- --     case result of
-- --         Just updates -> do
-- --             putStrLn "Processamento concluído"
-- --         Nothing -> putStrLn "Falha ao processar os resultados"

-- {-# LANGUAGE OverloadedStrings #-}

-- import Control.Concurrent.Async
-- import Text.HTML.Scalpel


-- data InfoBook = InfoBook
--     { title :: String
--     , author :: String
--     --, link :: String
--     , price :: String
--     , img :: URL
--     , description :: String
--     } deriving Show

-- scrapingTravessa :: String -> IO (Maybe [String])
-- scrapingTravessa livro = do
--     let baseUrl = "https://www.travessa.com.br/Busca.aspx?d=1&bt=" ++ livro ++ "&cta=00&codtipoartigoexplosao=&pag="
--         page = 0
--         firstPageUrl = baseUrl ++ show page
--     result <- scrapeURL firstPageUrl fetch_links

--     case result of
--         Just updates -> do
--             rest <- scrapeNextPagesParallel baseUrl (page + 1)
--             return (Just (updates ++ concat rest))
--         Nothing -> return Nothing

-- scrapeNextPagesParallel :: String -> Int -> IO [[String]]
-- scrapeNextPagesParallel baseUrl startPage = do
--     let pageNumbers = [startPage..11]  -- Páginas de 2 a 11
--     mapConcurrently (scrapeAndProcessPage baseUrl) pageNumbers

-- scrapeAndProcessPage :: String -> Int -> IO [String]
-- scrapeAndProcessPage baseUrl page = do
--     let url = baseUrl ++ show page
--     result <- scrapeURL url fetch_links
--     case result of
--         Just links -> do
--             --putStrLn ("Resultados da página " ++ show page ++ ":")
--             processedLinks <- mapM processLink links
--             --putStrLn ""
--             return processedLinks
--         Nothing -> do
--             putStrLn ("Falha ao processar a página " ++ show page)
--             return []

-- fetch_links :: Scraper String [String]
-- fetch_links = chroots ("h4" @: [hasClass "search-result-item-heading"]) isolate_link

-- isolate_link :: Scraper String String
-- isolate_link = link_book

-- link_book :: Scraper String String
-- link_book = do
--     --header <- text $ "a"
--     url <- attr "href" "a"
--     return $ url

-- processLink :: String -> IO String
-- processLink links = do
--     let bookUrl = links
--     -- putStrLn $ "Acessando link: " ++ bookUrl
--     result <- scrapeURL bookUrl fetch_book
--     case result of
--         Just bookData -> do
--             --putStrLn "Dados do livro:"
--             --mapM_ printBook bookData
--             mapM_ printBook bookData
--             --putStrLn ""
--             return links
--         Nothing -> do
--             putStrLn "Falha ao processar a página do livro"
--             return ""

-- fetch_book :: Scraper String [InfoBook]
-- fetch_book = chroots ("div" @: [hasClass "main"]) isolate_book

-- isolate_book :: Scraper String InfoBook
-- isolate_book = book

-- book :: Scraper String InfoBook
-- book = do
--     titleText <- text "span"
--     authorText <- text "a"
--     priceText <-  text $ "strong" 
--     imgUrl <- attr "src" $ "imgUrl" 
--     return (InfoBook titleText authorText priceText imgUrl "")

-- printBook :: InfoBook -> IO ()
-- printBook book = do
--     putStrLn "-------------------"
--     putStrLn  $ "Título: " ++ title book
--     putStrLn ("Autor: " ++ author book)
--     putStrLn ("Preço: " ++ price book)
--     putStrLn ("Imagem: " ++ img book)
--     --putStrLn ("Descrição: " ++ description book)
--     putStrLn "-------------------"

-- main :: IO ()
-- main = do
--     putStrLn "Digite o livro que deseja encontrar:"
--     livro <- getLine
--     result <- scrapingTravessa livro
--     case result of
--         Just updates -> do
--             putStrLn ""
--             putStrLn "Processamento concluído"
--         Nothing -> putStrLn "Falha ao processar os resultados"



{-# LANGUAGE OverloadedStrings #-}

import Control.Concurrent.Async
import Text.HTML.Scalpel

data Book = Book
    { title :: String
    , author :: String
    --, link :: String
    , price :: String
    , img :: URL
    } deriving Show

scrapingTravessa :: String -> IO (Maybe [String])
scrapingTravessa livro = do
    let baseUrl = "https://www.travessa.com.br/Busca.aspx?d=1&bt=" ++ livro ++ "&cta=00&codtipoartigoexplosao=&pag="
        page = 0
        firstPageUrl = baseUrl ++ show page
    result <- scrapeURL firstPageUrl fetch_links

    case result of
        Just updates -> do
            rest <- scrapeNextPagesParallel baseUrl (page + 1)
            return (Just (updates ++ concat rest))
        Nothing -> return Nothing

scrapeNextPagesParallel :: String -> Int -> IO [[String]]
scrapeNextPagesParallel baseUrl startPage = do
    let pageNumbers = [startPage..26]  -- Páginas de 2 a 11
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
            --let bookTitles = map (\book -> getTitle book) bookData -- Extrai os títulos dos livros
            mapM_ printBook bookData
            --mapM_ putStrLn bookData
            --putStrLn ""
            return links
        Nothing -> do
            putStrLn "Falha ao processar a página do livro"
            return ""

fetch_book :: Scraper String [Book]
fetch_book = chroots ("div" @: [hasClass "main"]) isolate_book

isolate_book :: Scraper String Book
isolate_book = book

book :: Scraper String Book
book = do
    titleText <- text "span"
    authorText <- text "a"
    priceText <-  text $ "strong"
    imgText <- attr "src" $ "img" 
    --autor <- text $ "span#lblNomArtigo"
    --autor <- text  "" $ "div" @: [hasClass "autordiretor"] 
    return (Book titleText authorText priceText imgText)

printBook :: Book -> IO ()
printBook info = do
    putStrLn ("Título: " ++ title info)
    putStrLn ("Autor: " ++ author info)
    putStrLn ("Preço: " ++ price info)
    putStrLn ("Imagem: " ++ img info)
    putStrLn "-------------------"

main :: IO ()
main = do
    putStrLn ""
    putStrLn "Digite o livro que deseja encontrar:"
    livro <- getLine
    putStrLn ""
    putStrLn "Carregando..."
    putStrLn ""
    result <- scrapingTravessa livro
    case result of
        Just updates -> do
            putStrLn "Processamento concluído"
        Nothing -> putStrLn "Falha ao processar os resultados"
