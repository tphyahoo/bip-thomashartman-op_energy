
import Op_Energy_Parsing
import Numeric (showHex)


unpack_bits :: PackedBits -> Double
unpack_bits x = (fromIntegral . packedbits_mantissa $ x) * ( 2**(8*( (fromIntegral . packedbits_exponent $ x) - 3)) )

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

{-
hashes_from_target_and_elapsed_time :: PackedBits -> Seconds -> Int256
hashes_from_target_and_elapsed_time target elapsed_time =  
    let x = ( (2 ** 256) / ( unpack_bits target  ) ) 
               * 
               ( 600 / (fromIntegral . unwrap_seconds $ elapsed_time) ) 
     in Int256 . floor $ x


hashprice_from_target :: [OP_ENERGY_Block] -> Float
hashprice_from_target blocks = sum (map ( fromIntegral . unwrap_int256 . hashes_from_target  ) blocks) 
                                   / 
                                   sum (map ( fromIntegral . unwrap_satoshis . total_reward ) blocks)
-}

{-
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
-}



-- Test Data, todo, needs fixing 
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
{-
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
-}


