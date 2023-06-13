-- {-# LANGUAGE OverloadedStrings #-}

-- import Control.Concurrent.Async
-- import Text.HTML.Scalpel

-- data Book = Book
--     { title :: String
--     , author :: String
--     , price :: String
--     , img :: URL
--     } deriving Show

-- scrapingSaraiva :: String -> IO (Maybe [String])
-- scrapingSaraiva livro = do
--     let baseUrl = "https://www.saraiva.com.br/busca?conteudo=" ++ livro ++ "&ordenacao=maior-preco"
--         page = 1
--         firstPageUrl = baseUrl ++ "&page=" ++ show page
--     result <- scrapeURL firstPageUrl fetch_links

--     case result of
--         Just links -> do
--             rest <- scrapeNextPagesParallel baseUrl (page + 1)
--             return (Just (links ++ concat rest))
--         Nothing -> return Nothing

-- scrapeNextPagesParallel :: String -> Int -> IO [[String]]
-- scrapeNextPagesParallel baseUrl startPage = do
--     let pageNumbers = [startPage..5]  -- Páginas de 2 a 5
--     mapConcurrently (scrapeAndProcessPage baseUrl) pageNumbers

-- scrapeAndProcessPage :: String -> Int -> IO [String]
-- scrapeAndProcessPage baseUrl page = do
--     let url = baseUrl ++ "&page=" ++ show page
--     result <- scrapeURL url fetch_links
--     case result of
--         Just links -> do
--             processedLinks <- mapM processLink links
--             return processedLinks
--         Nothing -> do
--             putStrLn ("Falha ao processar a página " ++ show page)
--             return []

-- fetch_links :: Scraper String [String]
-- fetch_links = chroots ("div" @: [hasClass "product-name"]) isolate_link

-- isolate_link :: Scraper String String
-- isolate_link = link_book

-- link_book :: Scraper String String
-- link_book = attr "href" "a"

-- processLink :: String -> IO String
-- processLink link = do
--     let bookUrl = link
--     result <- scrapeURL bookUrl fetch_book
--     case result of
--         Just bookData -> do
--             mapM_ printBook bookData
--             return link
--         Nothing -> do
--             putStrLn "Falha ao processar a página do livro"
--             return ""

-- fetch_book :: Scraper String [Book]
-- fetch_book = chroots ("div" @: [hasClass "col-sm-5", hasClass "product-main-info"]) isolate_book

-- isolate_book :: Scraper String Book
-- isolate_book = book

-- book :: Scraper String Book
-- book = do
--     titleText <- text "h1"
--     authorText <- text $ "span" @: [hasClass "product-subtitle"]
--     priceText <- text $ "span" @: [hasClass "price-value"]
--     imgText <- attr "src" $ "img" 
--     return (Book titleText authorText priceText imgText)

-- printBook :: Book -> IO ()
-- printBook info = do
--     putStrLn ("Título: " ++ title info)
--     putStrLn ("Autor: " ++ author info)
--     putStrLn ("Preço: " ++ price info)
--     putStrLn ("Imagem: " ++ img info)
--     putStrLn "-------------------"

-- main :: IO ()
-- main = do
--     putStrLn ""
--     putStrLn "Digite o livro que deseja encontrar:"
--     livro <- getLine
--     putStrLn ""
--     putStrLn "Carregando..."
--     putStrLn ""
--     result <- scrapingSaraiva livro
--     case result of
--         Just links -> putStrLn "Processamento concluído"
--         Nothing -> putStrLn "Falha ao processar os resultados"
