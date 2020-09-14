import Numeric

main = putStrLn ("hello world")

decToHex x = Numeric.showHex x ""


-- bitsToDiff mantissa exponent =  target_genesis / ( unpack_bits mantissa exponent )

-- t1 = bitsToDiff 0x17 == 0x1007ea
-- t2 = bitsToDiff 0x17 == 0x109bac

unpack_bits :: PackedBits -> Double
unpack_bits x = (fromIntegral . packedbits_mantissa $ x) * ( 2**(8*( (fromIntegral . packedbits_exponent $ x) - 3)) )



data PackedBits = PackedBits { packedbits_exponent :: Int
                               , packedbits_mantissa :: Int
                               }
  deriving ( Read, Show )

data Block = Block { target :: PackedBits, 
                                   seconds :: Int,
                                   subsidy_satoshis :: Int,
                                   fee_satoshis :: Int
                                   }
  deriving ( Read, Show )



-- todo, use real blockchain median seconds instead of vanilla timestamp, if possible. 
-- Not sure if it is possible for genesis block actually. 

price_1_2 = hashprice [ block_genesis ]
price_1_3 = hashprice [ block_genesis, block_2 ]

block_genesis = Block bits_genesis (timestamp_2 - timestamp_1 ) (50*10^8) 0
block_2 = Block bits_genesis (timestamp_3 - timestamp_2 ) (50*10^8) 0
bits_genesis = PackedBits 0x1d 0x00ffff   -- decToHex 486604799 => "1d00ffff"
 


timestamp_1 = 1231469665
timestamp_2 = 1231469744
timestamp_3 = 1231470173



{-







price_first_halving = hashprice block_first_halving
  where block_first_halving = Block bits_first_halving 600 (25*10^8) 1356295554
        bits_first_halving = PackedBits 0x1a 0x04e0ea   -- decToHex 436527338 => "1a04e0ea"


price_second_halving = hashprice block_second_halving
  where block_second_halving = Block bits_second_halving 600 (125*10^7) 57569681 
        bits_second_halving = PackedBits 0x18 0x0526fd  -- decToHex 402990845 => "180526fd"

-}


hashprice blocks = sum (map hashes blocks) / sum (map revenue blocks)




hashes :: Block -> Double
hashes block =  ( (2 ** 256) / ( unpack_bits . target $ block ) ) 
                           * ( 600 / (fromIntegral . seconds $ block) ) 


revenue block = ( (fromIntegral . subsidy_satoshis $ block) + (fromIntegral . fee_satoshis $ block))

  

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



Probably don't need this but just as a breadcrumb, other ways of gathering this data are in 
  https://bitcoin.stackexchange.com/questions/73186/csv-file-of-every-block-timestamp-in-btc-history

-}

-- target_genesis :: Double
-- target_genesis = unpack_bits genesis_bits