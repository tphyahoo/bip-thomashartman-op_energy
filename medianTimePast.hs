{-# LANGUAGE FlexibleContexts#-}
import Data.List (sort)
import Test.QuickCheck
import Op_Energy_Parsing (windows)
-- median time past



t = median11 [100,101,102,103,104,105,106,90,40,600,3]



median11 :: (Ord a, Show a) => [a] -> a
median11 xs@[a,b,c,d,e,f,g,h,i,j,k] = sort xs !! 5
median11 ys = error $ "median11, needs 11 elements: " ++ show ys



prop_reverse :: [Integer] -> Bool
prop_reverse xs = reverse (reverse xs) == xs

prop_mtp11_monotonic :: [Integer] -> Bool
prop_mtp11_monotonic xs = {- (bigEnough xs) ==> -} (isMonotonic . map median11 . windows 11 $ xs)

bigEnough :: [Integer] -> Bool
bigEnough xs = and .  map (> 0) $ xs


-- isMonotonic :: [Integer] -> Bool
isMonotonic = isSorted

isSorted :: Ord a => [a] -> Bool
isSorted xs = and . map (\[x,y] -> x <= y) . windows 2 $ xs







