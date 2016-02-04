{-# LANGUAGE DeriveDataTypeable,DeriveGeneric #-}
import Data.Typeable
import Data.Data
import GHC.Generics
import Data.Aeson( eitherDecode, FromJSON, ToJSON )
-- stuff above for Aeson

import System.Environment( getArgs )
import Data.ByteString.Lazy( ByteString )
import Data.ByteString.Lazy.Char8( pack, unpack )
-- stuff above for the input

import Data.Map( Map, empty, insert, keys, delete, lookup, update, elems )

type Label = String

data Connection = Connection {
  lab :: Label,
  edg :: [Label]
} deriving (Show, Typeable, Generic)

instance FromJSON Connection
instance ToJSON Connection

data Graph = Graph [Connection] deriving (Show, Typeable, Generic)

instance FromJSON Graph
instance ToJSON Graph

graphMap :: Graph -> Map Label Connection
graphMap (Graph connections) = foldr insertConnection empty connections
  where insertConnection = \ conn m -> insert (lab conn) conn m

totalTail [] = []
totalTail a = tail a

-- omitFirst 2 [1, 2, 3, 2, 1] == [1, 3, 2, 1]
omitFirst :: Eq a => a -> [a] -> [a]
omitFirst a aa = taken ++ (totalTail dropped)
  where (taken, dropped) = span (/= a) aa

updateHamilton curr m = delete curr m

updateEuler curr next = update removeEdge curr
  where removeEdge Connection { lab = l, edg = e}
          | length edgesLeft > 0  = Just Connection {lab = l, edg = edgesLeft}
          | otherwise             = Nothing -- remove it
          where edgesLeft = omitFirst next e

-- search functions are very similar, the common strategy could
-- probably be abstracted

searchHamiltonian :: Map Label Connection -> Label -> Label -> [[Label]]
searchHamiltonian m curr goal = maybe [] continue maybeConnection
  where maybeConnection = Data.Map.lookup curr m
        withThis sub = curr:sub
        explore :: Label -> [[Label]]
        explore next
          | next == goal = [[next]]
          | otherwise    = searchHamiltonian (updateHamilton curr m) next goal
        continue :: Connection -> [[Label]]
        continue conn = map withThis $ concat $ map explore (edg conn)

searchEulerian :: Map Label Connection -> Label -> [[Label]]
searchEulerian m curr = maybe [[curr]] continue maybeConnection
  where maybeConnection = Data.Map.lookup curr m
        withThis sub = curr:sub
        explore :: Label -> [[Label]]
        explore next = searchEulerian (updateEuler curr next m) next 
        continue :: Connection -> [[Label]]
        continue conn = map withThis $ concat $ map explore (edg conn)

getHamiltonian :: Graph -> [[Label]]
getHamiltonian graph = filter complete allCycles
  where complete cycle = (length cycle) == (length m) + 1
        allCycles = searchHamiltonian m l l
        l = head $ keys m
        m = graphMap graph

getEulerian :: Graph -> [[Label]]
getEulerian graph = filter complete allCycles
  where complete cycle = (length cycle) == (edgeCount) + 1
        edgeCount = sum (map (length . edg) $ elems m)
        allCycles = searchEulerian m l
        l = head $ keys m
        m = graphMap graph

isGraphEmpty (Graph connections) = length connections == 0

fileNameToGraph :: String -> IO (Either String Graph)
fileNameToGraph fileName = do
  contents <- readFile fileName
  return $ eitherDecode $ pack contents

talkAbout graph = do
  -- print graph
  if (isGraphEmpty graph)
    then
    putStrLn "The graph is empty"
    else
    do
      putStrLn "Hamiltonian cycles:"
      sequence $ map print $ getHamiltonian graph
      putStrLn "Eulerian cycles:"
      sequence $ map print $ getEulerian graph
      return ()

main = do
  [fileName] <- getArgs
  graph <- fileNameToGraph fileName
  either (\ e -> print $ "Parsing error: "++e) talkAbout graph
