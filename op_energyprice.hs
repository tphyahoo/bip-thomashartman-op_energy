{-# LANGUAGE ScopedTypeVariables #-}
import Numeric

import Data.List (tails, intersperse)
import Control.Applicative (ZipList(..))
import Op_Energy_Parsing

-- https://stackoverflow.com/questions/27726739/implementing-an-efficient-sliding-window-algorithm-in-haskell
windows :: Int -> [a] -> [[a]]
windows m = transpose' . take m . tails
  where 
    transpose' :: [[a]] -> [[a]]
    transpose' = getZipList . sequenceA . map ZipList

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





-- getPrices = do

{-
  return $ do (h :: Either ParseError [String]) <- parse linesP hashes input
              case h of 
                 Left e -> error . show $ e
                 Right r -> r
-}



unpack_bits :: PackedBits -> Double
unpack_bits x = (fromIntegral . packedbits_mantissa $ x) * ( 2**(8*( (fromIntegral . packedbits_exponent $ x) - 3)) )




-- next thing to do is to start dumping blocks
data OP_ENERGY_Block = OP_ENERGY_Block { block_number :: Integer,
                                         hashes_from_target :: Int256, 
                                         hashes_from_totalwork :: Int256,
                                         total_reward :: Satoshis
                                   }
  deriving ( Read, Show )

                                                     


-- Options stuff, / black scholes for binary options maybe can be removed or moved to a more pricing specific model
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
tsd10000_10250 = strikeDelta (10000, 380, 416) (10250, 210, 241)
tsd10250_10500 = strikeDelta (10250, 210, 236) (10500, 108, 123)


strikeDelta (strike1, bid1, ask1) (strike2, bid2, ask2) = 
  let callprice1 = ( bid1 + ask1 ) / 2
      callprice2 = ( bid2 + ask2 ) / 2
      dCv = callprice2 - callprice1
      dK  = strike2 - strike1
      dCv_dK = dCv / dK
  in  dCv_dK


decToHex x = Numeric.showHex x ""






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


mainTest = op_energy_report_test 3
main = op_energy_report 500


op_energy_report_test = op_energy_report' blockTotalsTest
op_energy_report = op_energy_report' blockTotals
op_energy_report' blockTotals' span = do
    totals <- blockTotals'
    let csvheader = concat . intersperse "," $ ["start","finish","OP_ENERGY price"]
        csvline xs = 
            let startBlock = head xs
                finishBlock = last xs
                start = oeh_blocknumber startBlock
                finish = oeh_blocknumber finishBlock
                price = op_energy startBlock finishBlock
            in  concat . intersperse "," $ [show start,show finish, show price]
        csvlines = map csvline . windows span $ totals
        csv :: String
        csv = concat . intersperse "\n" $ csvheader : csvlines
    putStrLn csv 



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