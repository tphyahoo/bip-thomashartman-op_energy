{-# LANGUAGE ScopedTypeVariables #-}

import Data.List (intersperse)
import Op_Energy_Parsing


-- Before running these commands, you need to create input files for them to use.
-- See datafetch/README.md \
-- todo, these should be in current directory, and in gitignore
main = op_energy_report_100_500

op_energy_report_100_500 = do
  totals <- blockTotals
  let sampled = sample 100 . windows 500 $ totals
      csv = op_energy_csv sampled
  putStrLn csv

mainTest = do
  totals <- blockTotalsTest
  let sampled = sample 1 . windows 3 $ totals
      csv = op_energy_csv sampled
  putStrLn csv


op_energy_csv :: [[OP_ENERGY_TOTALS]] -> [Char]
op_energy_csv s = 
    let csvheader = concat . intersperse "," $ 
            ["start block","finish block","start time","finish time","OP_ENERGY price"]
        csvline xs = 
            let startBlockTotals = head xs
                finishBlockTotals = last xs

                startBlockNum  = show $ oeh_blocknumber $ startBlockTotals
                finishBlockNum = show $ oeh_blocknumber $ finishBlockTotals
                startTime  = show $ unwrap_seconds . oeh_median_time $ startBlockTotals
                finishTime = show $ unwrap_seconds . oeh_median_time $ finishBlockTotals

                price = show $ op_energy startBlockTotals finishBlockTotals
            in  concat . intersperse "," $ 
                    [startBlockNum,finishBlockNum,startTime, finishTime,price]
        csvlines = map csvline s
    in  concat . intersperse "\n" $ csvheader : csvlines
    



sample _ [] = []
sample i xs@(x:_) = x : ( sample i $ drop i xs)

op_energy :: OP_ENERGY_TOTALS -> OP_ENERGY_TOTALS -> Integer
op_energy fromBlock toBlock = floor $ hashes / satoshis
  where 
    hashes :: Float
    hashes = fromIntegral expectedHashes * ( fromIntegral expectedTime / fromIntegral time )
            where
              numBlocks = (oeh_blocknumber toBlock) - (oeh_blocknumber fromBlock)
              expectedTime = 600 * numBlocks
              time = (unwrap_seconds . oeh_median_time $ toBlock) - (unwrap_seconds . oeh_median_time $ fromBlock)
              expectedHashes = (unwrap_int256 . oeh_chainwork $ toBlock) - (unwrap_int256. oeh_chainwork $ fromBlock)
    satoshis :: Float
    satoshis = fromIntegral $ ( unwrap_satoshis . oeh_chainreward $ toBlock ) - ( unwrap_satoshis . oeh_chainreward $ fromBlock)


-- todo, needs fixing 
t = take 10 `fmap` blockTotals

blockTotals     = blockTotals' ("/Users/flipper/op_energy_prices/blockbits.txt", 
                                "/Users/flipper/op_energy_prices/blockstats.txt")
blockTotalsTest = blockTotals' ("/Users/flipper/op_energy_prices/blockbitsTest.txt",
                                "/Users/flipper/op_energy_prices/blockstatsTest.txt")
blockTotals' :: (FilePath, FilePath) -> IO [OP_ENERGY_TOTALS]
blockTotals' (bits, stats)= do
    b <- parseFile blocksP bits --  
    s <- parseFile statsP stats -- 
    let z = OP_ENERGY_TOTALS 0 (Seconds 0) (Int256 0) (Satoshis 0)
        blocktotals :: [OP_ENERGY_TOTALS]
        blocktotals = tail . scanl (flip make_next_helper_record) z $ zip b s
    return blocktotals

-- stdout to "/Users/flipper/op_energy_prices/blocktotalsTest.txt" 
saveBlockTotalsHaskellShow = putStrLn . show =<< blockTotals 
-- stdout to "/Users/flipper/op_energy_prices/blocktotalsTest.txt"
saveBlockTotalsHaskellShowTest =  putStrLn . show =<< blockTotalsTest 

readBlockTotals, readBlockTotalsTest :: IO [OP_ENERGY_TOTALS]
readBlockTotals = read `fmap` readFile "/Users/flipper/op_energy_prices/blocktotalsHaskellShow.txt"
readBlockTotalsTest = read `fmap` readFile "/Users/flipper/op_energy_prices/blocktotalsHaskellShowTest.txt"



t1 = putStrLn "hello world"
-- $ runghc op_energyprice.hs --ghc-arg "main-is t1"
-- $ runghc op_energyprice.hs --ghc-arg "main-is saveBlockTotalsCsv" > /Users/flipper/op_energy_prices/blocktotals.csv
saveBlockTotalsCsv :: IO ()
saveBlockTotalsCsv = do
  totals <- blockTotals 
  let csvheader :: String
      csvheader = concat . intersperse "," $
                ["block number", "median time", "chain work", "chain reward"]
      csvline ( OP_ENERGY_TOTALS 
                oeh_blocknumber 
                oeh_median_time 
                oeh_chainwork 
                oeh_chainreward ) = concat . intersperse "," $
                                      [ show oeh_blocknumber, 
                                        show . unwrap_seconds $ oeh_median_time,
                                        show . unwrap_int256 $ oeh_chainwork,
                                        show . unwrap_satoshis $ oeh_chainreward ]
                                                     
      csvlines = map csvline totals
      csv = concat . intersperse "\n" $ csvheader : csvlines
  writeFile "/Users/flipper/op_energy_prices/blocktotals.csv" csv




-- getPrices = do

{-
  return $ do (h :: Either ParseError [String]) <- parse linesP hashes input
              case h of 
                 Left e -> error . show $ e
                 Right r -> r
-}

timestamp_1 = 1231469665
timestamp_2 = 1231469744
timestamp_3 = 1231470173


workaccum_1 = 0x0000000000000000000000000000000000000000000000000000000200020002
workaccum_2 = 0x0000000000000000000000000000000000000000000000000000000300030003
workaccum_3 = 0x0000000000000000000000000000000000000000000000000000000400040004

sanityCheck = do
    totals <- blockTotals
    let op_energy' x y = op_energy (totals !! (x-1)) (totals !! (y-1))
    putStrLn $ "OP_ENERGY 1 2: " ++ ( show $ op_energy' 1 2)
    putStrLn $ "OP_ENERGY 1 3: " ++ ( show $ op_energy' 1 3)
    putStrLn $ "OP_ENERGY 210000 210001: " ++ ( show $ op_energy' 210000 210001)
    putStrLn $ "OP_ENERGY 420000 420001: " ++ ( show $ op_energy' 420000 420001)
    putStrLn $ "OP_ENERGY 630000 630001: " ++ ( show $ op_energy' 630000 630001)

    putStrLn $ "first 500 blocks, OP_ENERGY 1 500): " ++ ( show $ op_energy' 1 500)
    putStrLn $ "first 1000 blocks, OP_ENERGY 1 1000): " ++ ( show $ op_energy' 1 1000)
    putStrLn $ "first 10,000 blocks, OP_ENERGY 1 10000): " ++ ( show $ op_energy' 1 10000)
    putStrLn $ "first 100,000 blocks, OP_ENERGY 1 100,000): " ++ ( show $ op_energy' 1 100000)    
    putStrLn $ "before first halving, OP_ENERGY 209499 209999): " ++ ( show $ op_energy' 209499 209999)
    putStrLn $ "around first halving, OP_ENERGY 209750 210250): " ++ ( show $ op_energy' 209750 210250)
    putStrLn $ "after first halving (OP_ENERGY 210000 210500): " ++ ( show $ op_energy' 210000 210500)
    putStrLn $ "before second halving (OP_ENERGY 419499 419999): " ++ ( show $ op_energy' 419499 419999)
    putStrLn $ "around second halving (OP_ENERGY 419750 420250): " ++ ( show $ op_energy' 419750 420250)
    putStrLn $ "after second halving (OP_ENERGY 420000 420500): " ++ ( show $ op_energy' 420000 420500)
    putStrLn $ "before third halving (OP_ENERGY 629499 629999): " ++ ( show $ op_energy' 629499 629999)
    putStrLn $ "around third halving (OP_ENERGY 629750 630250): " ++ ( show $ op_energy' 629750 630250)
    putStrLn $ "after third halving (OP_ENERGY 430000 430500): " ++ ( show $ op_energy' 430000 430500)

{-
https://blockchair.com/bitcoin/block/645996           bits 386926570       171007ea
https://blockchair.com/bitcoin/block/642403           bits 386970872       1710b4f8 

In the beginning of time, bits, ie packed difficulty is   486604799
“The highest possible target (difficulty 1) is defined as 0x1d00ffff”
Prelude> 0x1d00ffff    => 486604799

-}

{-
   https://developer.bitcoin.org/reference/rpc/getblockstats.html
   miner revenue is totalfee + subsidy
   This can be sanity checked against stats from blockchain
   https://api.blockchair.com/bitcoin/raw/block/1

   Also needed: mediantime

   https://developer.bitcoin.org/reference/rpc/getblockheader.html
     Bits



-}