module Op_Energy_Parsing where

import Text.Parsec
import Text.Parsec.String (Parser)
import Safe (readMay)
import Control.Applicative (ZipList(..))
import Data.List (tails)


newtype Satoshis = Satoshis { unwrap_satoshis :: Integer }
  deriving (Read,Show)
newtype Seconds = Seconds { unwrap_seconds :: Integer }
  deriving (Read,Show)
newtype Int256 = Int256 { unwrap_int256 :: Integer }
  deriving (Read,Show,Eq)

data PackedBits = PackedBits { packedbits_exponent :: Int
                               , packedbits_mantissa :: Int
                               }
  deriving ( Read, Show )


data OP_ENERGY_TOTALS = OP_ENERGY_TOTALS { oeh_blocknumber :: Integer,
                                                       oeh_median_time :: Seconds,
                                                       oeh_chainwork :: Int256,
                                                       oeh_chainreward :: Satoshis
                                                     }
  deriving (Read, Show)

-- https://stackoverflow.com/questions/27726739/implementing-an-efficient-sliding-window-algorithm-in-haskell
windows :: Int -> [a] -> [[a]]
windows m = transpose' . take m . tails
  where
    transpose' :: [[a]] -> [[a]]
    transpose' = getZipList . sequenceA . map ZipList

make_next_helper_record :: ((Integer, Int256, PackedBits, Float, Int256),(Integer, Int256, Satoshis, Seconds, Seconds)) 
                             -> OP_ENERGY_TOTALS 
                             -> OP_ENERGY_TOTALS
make_next_helper_record ( block_record@(br_num,br_hash,_,_,chainwork), stats_record@(sr_num,sr_hash,reward@(Satoshis sr_reward),_,mediantime) ) 
                        oeh@(OP_ENERGY_TOTALS _ _ _ (Satoshis oeh_cr)) = 
    if ( br_num == sr_num && br_hash == sr_hash )
        then OP_ENERGY_TOTALS br_num
                                    mediantime
                                    chainwork
                                    (Satoshis $ oeh_cr + sr_reward)
        else error $ "make_helper_record" ++ show (br_num == sr_num , br_hash == sr_hash)
   


blocksP :: Parsec String () [(Integer,Int256,PackedBits,Float,Int256)]
blocksP = do
  many $ do
    blockNum <- numLineP
    blockHash <- hexLineP
    blockTarget <- packedbitsLineP 
    blockDiff <- floatLineP
    blockWork <- hexLineP
    return (blockNum, blockHash, blockTarget, blockDiff, blockWork)

statsP :: Parsec String () [(Integer,Int256, Satoshis,Seconds,Seconds)]
statsP = do
  many $ do
    blockNum <- numLineP
    blockHash <- hexLineP
    blockTotalReward <- do
      blockSubsidy <- numLineP
      blockFees <- numLineP
      return $ Satoshis $ blockSubsidy + blockFees
    blockTime <- Seconds `fmap` numLineP
    blockMedianTime <- Seconds `fmap` numLineP
    return (blockNum, blockHash, blockTotalReward, blockTime, blockMedianTime)



parseFile :: Parsec String () b -> FilePath -> IO b
parseFile parserP f  = do
  input <- readFile f
  return $ case ( parse parserP f input ) 
             of Left e -> error $ "parseFile: " ++ f ++", " ++ show e
                Right r -> r


numLineP :: Parser Integer
numLineP = do
        numS <- manyTill anyChar (char '\n')
        case (readMay numS) of
            Nothing -> error $ "numLineP, bad numS: " ++ numS
            Just num -> return num 

hexLineP :: Parser Int256
hexLineP = do
        _ <- char '"'
        hashS  <- manyTill anyChar (char '"') 
        -- _ <- char '"'
        _ <- char '\n'
        case (readMay $ "0x" ++ hashS) of
            Nothing -> error $ "hashLineP, bad hashS: " ++ hashS
            Just num -> return $ Int256 num

packedbitsLineP :: Parser PackedBits
packedbitsLineP = do
        _ <- char '"'
        packedS  <- ( manyTill anyChar (char '"') ) 
        _ <- char '\n'
        {- case (readMay ("0x" ++ packedS :: Int32) of -- sanity check, it can be read as a 32 bit int
            Nothing -> error $ "hashLineP, bad packedS, not an Int32: " ++ packedS
            Just _ -> do -}
        case packedS of 
            [a,b,c,d,e,f,g,h] -> 
                let exponent = case (readMay $ "0x" ++ [a,b] ) of
                        Nothing -> error $ "packedbitsLineP, bad exponent: " ++ [a,b]
                        Just x -> x
                    mantissa = case (readMay $ "0x" ++ [c,d,e,f,g,h] ) of
                        Nothing -> error $ "packedbitsLineP, bad mantissa: " ++ [c,d,e,f,g,h]
                        Just x -> x
                 in return $ PackedBits exponent mantissa
            _ -> error $ "hashLineP, bac packedS, not 8 characters: " ++ packedS


floatLineP :: Parser Float
floatLineP = do
        floatS <- manyTill anyChar (char '\n') 
        case (readMay floatS) of
            Nothing -> error $ "floatLineP, bad floatS: " ++ floatS
            Just num -> return num

-- hashesP :: Parsec String () [(Integer,Int256)]
hashesP = do
  many $ do 
    blockNum <- numLineP
    blockHash <- hexLineP
    return (blockNum,blockHash)




