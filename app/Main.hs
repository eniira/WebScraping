{-# LANGUAGE OverloadedStrings #-}

import Text.HTML.Scalpel
import System.IO
import qualified Data.Text.IO as TIO
import Data.Text.Encoding (decodeUtf8, encodeUtf8)
import Data.Text (pack)
import Data.Char (isAscii, isPrint)

data InfoBook = InfoBook
    { title :: String
    , author :: String
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
            rest <- scrapeNextPages baseUrl (page + 1)
            return (Just (updates ++ concat rest))
        Nothing -> return Nothing

scrapeNextPages :: String -> Int -> IO [[String]]
scrapeNextPages baseUrl startPage = do
    let pageNumbers = [startPage.. 26]
    mapM (scrapeAndProcessPage baseUrl) pageNumbers
    
        
        
scrapeAndProcessPage :: String -> Int -> IO [String]
scrapeAndProcessPage baseUrl page = do
    let url = baseUrl ++ show page
    result <- scrapeURL url fetch_links
    case result of
        Just links -> do
            processedLinks <- mapM processLink links
            return processedLinks
        Nothing -> do
            putStrLn ("Falha ao processar a página " ++ show page)
            return []

fetch_links :: Scraper String [String]
fetch_links = chroots ("h4" @: [hasClass "search-result-item-heading"]) isolate_link

isolate_link :: Scraper String String
isolate_link = link_book

link_book :: Scraper String String
link_book = attr "href" "a"

processLink :: String -> IO String
processLink links = do
    let bookUrl = links
    bookResult <- scrapeURL bookUrl fetch_book
    sinopseResult <- scrapeURL bookUrl fetch_sinopse
    case (bookResult, sinopseResult) of
        (Just bookData, Just sinopseData) -> do
            let content = concatMap printMainBook bookData ++ concatMap printSinopseBook sinopseData
            appendFileWithEncoding "travessa.txt" content
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
    priceText <- text $ "strong"
    imgText <- attr "src" "img"
    return (InfoBook titleText authorText priceText imgText "")

sinopse :: Scraper String InfoBook
sinopse = do
    descriptionText <- text "p"
    return (InfoBook "" "" "" "" descriptionText)

printMainBook :: InfoBook -> String
printMainBook info = "Titulo: " ++ title info ++ "\nAutor: " ++ author info ++ "\nPreco: " ++ price info ++ "\n"++ "Imagem: " ++ img info ++ "\n"
    
printSinopseBook :: InfoBook -> String
printSinopseBook infoSinop = "Descricao: " ++ description infoSinop ++ "\n\n"

appendFileWithEncoding :: FilePath -> String -> IO ()
appendFileWithEncoding path content = do
    let convertedContent = removeInvalidCharacters content
        encodedContent = encodeUtf8 (pack convertedContent)
    withFile path AppendMode $ \handle -> do
        hSetEncoding handle utf8
        TIO.hPutStr handle (decodeUtf8 encodedContent)


removeInvalidCharacters :: String -> String
removeInvalidCharacters = filter (\c -> isAscii c || isPrint c)

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
        Just _ -> do
            putStrLn "Finalizado"
        Nothing -> putStrLn "Falha ao processar os resultados"


