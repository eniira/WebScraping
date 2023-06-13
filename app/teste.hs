{-# LANGUAGE OverloadedStrings #-}

import Control.Concurrent.Async
import Text.HTML.Scalpel
import System.Directory (getCurrentDirectory)
--import System.IO (withFile, IOMode(WriteMode), hPutStr, stdout)
import System.IO
import qualified Data.Text.IO as TIO
import Data.Text.Encoding (decodeUtf8, encodeUtf8)
import Data.Text (Text, pack, unpack)
import Data.Char (isAscii)

data InfoBook = InfoBook
    { title :: String
    , author :: String
    --, link :: String
    , price :: String
    , img :: URL
    , description :: String
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
    let pageNumbers = [startPage..26] 
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

-- processLink :: String -> IO String
-- processLink links = do
--     let bookUrl = links
--     --putStrLn $ "Acessando link: " ++ bookUrl
--     result <- scrapeURL bookUrl fetch_book
--     case result of
--         Just bookData -> do
--             --putStrLn "Dados do livro:"
--             --let bookTitles = map (\book -> getTitle book) bookData -- Extrai os títulos dos livros
--             mapM_ printBook bookData
--             --mapM_ putStrLn bookData
--             --putStrLn ""
--             return links
--         Nothing -> do
--             putStrLn "Falha ao processar a página do livro"
--             return ""

processLink :: String -> IO String
processLink links = do
    let bookUrl = links
    bookResult <- scrapeURL bookUrl fetch_book
    sinopseResult <- scrapeURL bookUrl fetch_sinopse
    case (bookResult, sinopseResult) of
        (Just bookData, Just sinopseData) -> do
            let content = concatMap printMainBook bookData ++ concatMap printSinopseBook sinopseData
            appendFileWithEncoding "file.txt" content
            --writeFile "file.txt" content
            -- let content = concatMap printMainBook bookData ++ concatMap printSinopseBook sinopseData
            -- withAsync (writeFileAsync "file.txt" content)  $ \_ -> return () 
                -- mapM_ printMainBook bookData
                -- mapM_ printMainBook sinopseData
            return links
        _ -> do
            putStrLn "Falha ao processar a página do livro ou da sinopse"
            return ""



fetch_book :: Scraper String [InfoBook]
fetch_book = chroots ("div" @: [hasClass "main"]) isolate_book

fetch_sinopse :: Scraper String [InfoBook]
fetch_sinopse = chroots ("div" @: [hasClass "sinopse"]) isolate_sinopse

isolate_book :: Scraper String InfoBook
isolate_book = book

isolate_sinopse :: Scraper String InfoBook
isolate_sinopse = sinopse

book :: Scraper String InfoBook
book = do
    titleText <- text "span"
    authorText <- text "a"
    priceText <-  text $ "strong"
    imgText <- attr "src" $ "img" 
    return (InfoBook titleText authorText priceText imgText "")

sinopse :: Scraper String InfoBook
sinopse = do
    descriptionText <- text "p"
    return (InfoBook "" "" "" "" descriptionText)

-- printMainBook :: InfoBook -> IO ()
-- printMainBook info = do
--     putStrLn ("Título: " ++ title info)
--     putStrLn ("Autor: " ++ author info)
--     putStrLn ("Preço: " ++ price info)
--     putStrLn ("Imagem: " ++ img info)

-- printSinopBook :: InfoBook -> IO ()
-- printSinopBook info = do
--     putStrLn ("Descrição: " ++ description info)
--     putStrLn "-------------------"

-- writeFileAsync :: FilePath -> String -> IO ()
-- writeFileAsync path content = withAsync (withFile path WriteMode (\handle -> hPutStr handle content)) wait

printMainBook :: InfoBook -> String
printMainBook book = "Titulo: " ++ title book ++ "\nAutor: " ++ author book ++ "\nPreco: " ++ price book ++ "\nImagem: " ++ img book ++ "\n"
    
printSinopseBook :: InfoBook -> String
printSinopseBook book = "Descricao: " ++ description book ++ "\n\n"

-- Escreve o conteúdo no arquivo usando a codificação UTF-8
appendFileWithEncoding :: FilePath -> String -> IO ()
appendFileWithEncoding path content = do
    let convertedContent = removeInvalidCharacters content
        encodedContent = encodeUtf8 (pack convertedContent)
    withFile path AppendMode $ \handle -> do
        hSetEncoding handle utf8
        TIO.hPutStr handle (decodeUtf8 encodedContent)

-- Remove caracteres inválidos do texto
removeInvalidCharacters :: String -> String
removeInvalidCharacters = filter (\c -> isAscii c || isPrint c)

-- Verifica se um caractere é ASCII imprimível
isPrint :: Char -> Bool
isPrint c = c >= ' ' && c <= '~'

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
