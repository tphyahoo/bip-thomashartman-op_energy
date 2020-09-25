{-# LANGUAGE ScopedTypeVariables #-}
import Numeric

import Data.List (tails)
import Control.Applicative (ZipList(..))
import Op_Energy_Parsing

main = putStrLn ("hello world")


-- https://stackoverflow.com/questions/27726739/implementing-an-efficient-sliding-window-algorithm-in-haskell
windows :: Int -> [a] -> [[a]]
windows m = transpose' . take m . tails
  where 
    transpose' :: [[a]] -> [[a]]
    transpose' = getZipList . sequenceA . map ZipList



  
tgetHashes = return . (take 10) =<< getHashes 
getHashes = parseFile hashesP "/Users/flipper/op_energy_prices/blockhashes.txt"

tgetStats = return . (take 10) =<< getStats
getStats = parseFile statsP "/Users/flipper/op_energy_prices/blockstats.txt"

tgetBlocks = return . (take 10) =<< getBlocks
getBlocks = parseFile blocksP "/Users/flipper/op_energy_prices/blockbits.txt"

{-}
get_op_energy x y = do
	blocks <- getBlocks
	foldM combine [] blocks


writePrices :: IO ()
writePrices = do
    s <- getStats
    b <- getBits
    print . last $ s
    print . last $ b
-}





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
data OP_ENERGY_Block = OP_ENERGY_Block { block_number :: Int,
                                         hashes_from_target :: Int256, 
                                         hashes_from_totalwork :: Int256,
                                         total_reward :: Satoshis
                                   }
  deriving ( Read, Show )

data OP_ENERGY_BLOCK_HELPER = OP_ENERGY_BLOCK_HELPER { oeh_blocknumber :: Int,
                                                       oeh_target :: PackedBits,
                                                       oeh_median_time :: Seconds,
                                                       oeh_totalwork :: Int256,
                                                       oeh_total_reward :: Satoshis
                                                     }
  deriving (Read, Show)                                                     

hashes_from_target_and_elapsed_time :: PackedBits -> Seconds -> Int256
hashes_from_target_and_elapsed_time target elapsed_time =  
    let x = ( (2 ** 256) / ( unpack_bits target  ) ) 
               * 
               ( 600 / (fromIntegral . unwrap_seconds $ elapsed_time) ) 
     in Int256 . floor $ x



hashprice_from_target blocks = sum (map ( fromIntegral . unwrap_int256 . hashes_from_target  ) blocks) 
                                   / 
                                   sum (map ( fromIntegral . unwrap_satoshis . total_reward ) blocks)

-- get the OP_ENERGY block data from two neighboring blocks
openergyblock_from_delta :: OP_ENERGY_BLOCK_HELPER -> OP_ENERGY_BLOCK_HELPER -> OP_ENERGY_Block
openergyblock_from_delta x y = 
    let total_work_hashes = Int256 $ ( unwrap_int256 . oeh_totalwork $ x ) - ( unwrap_int256 . oeh_totalwork $ y )
        elapsed = Seconds $ (unwrap_seconds . oeh_median_time $ x) - (unwrap_seconds . oeh_median_time $ y) 
        hashes_target = hashes_from_target_and_elapsed_time (oeh_target x) elapsed 
    in  OP_ENERGY_Block
            (oeh_blocknumber x)
            hashes_target
            total_work_hashes
            (oeh_total_reward x)                            


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

-- Test Data
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
block_genesis = 
    let hashes_target = hashes_from_target_and_elapsed_time bits_genesis (Seconds $ timestamp_2 - timestamp_1 )
    in OP_ENERGY_Block
        1 
        hashes_target
        (Int256 $ workaccum_1)
        (Satoshis $ (50*10^8) + 0 )

block_2 =       
   let hashes_target = hashes_from_target_and_elapsed_time bits_genesis (Seconds $ timestamp_3 - timestamp_2 )
   in OP_ENERGY_Block 
        2
        hashes_target
        (Int256 $ workaccum_2 - workaccum_1)
        (Satoshis $ (50*10^8) + 0 )

bits_genesis = PackedBits 0x1d 0x00ffff   -- decToHex 486604799 => "1d00ffff"
 

price_first_halving = hashprice_from_target [ block ]
  where 
    block = 
       let bits = PackedBits 0x1a 0x04e0ea   -- decToHex 436527338 => "1a04e0ea"
           hashes_target = hashes_from_target_and_elapsed_time bits (Seconds 600)
       in OP_ENERGY_Block 
            210000
            hashes_target
            (Int256 $ error "block_first_halving, fixme")
            (Satoshis $ (25*10^8) + 1356295554)


price_second_halving = hashprice_from_target [ block ]
  where 
    block = 
       let bits = PackedBits 0x18 0x0526fd  -- decToHex 402990845 => "180526fd"
           hashes_target = hashes_from_target_and_elapsed_time bits (Seconds 600)
       in OP_ENERGY_Block 
            420000
            hashes_target
            (Int256 $ error "block_second_halving, fixme")
            (Satoshis $ (125*10^7) + 57569681 )    

-- hashes_from_totalwork :: OP_ENERGY_Block -> Double
-- hashes_from_totalwork block =  error "hashes_from_totalwork, todo" 




timestamp_1 = 1231469665
timestamp_2 = 1231469744
timestamp_3 = 1231470173


workaccum_1 = 0x0000000000000000000000000000000000000000000000000000000200020002
workaccum_2 = 0x0000000000000000000000000000000000000000000000000000000300030003
workaccum_3 = 0x0000000000000000000000000000000000000000000000000000000400040004



price_1_2 = hashprice_from_target [ block_genesis ]
price_1_3 = hashprice_from_target [ block_genesis, block_2 ]


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