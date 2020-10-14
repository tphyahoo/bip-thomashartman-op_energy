# adapted from https://en.bitcoin.it/wiki/Difficulty#How_is_difficulty_calculated.3F_What_is_the_difference_between_bdiff_and_pdiff.3F

import decimal, math
l = math.log
e = math.e

def unpack_exp(x):
  return 8*(x - 3)

print 0x00ffff * 2**(8*(0x1d - 3)) / float(0x0404cb * 2**(8*(0x1b - 3)))



block_1_packed_exp = 0x1d
block_1_exp =        unpack_exp (block_1_packed_exp)
block_1_mantissa =   float(0x00ffff)

packed_exp =        0x1b
exp =               unpack_exp (packed_exp)
mantissa =          float(0x0404cb)

print l(block_1_mantissa *    2**(block_1_exp) / (mantissa * 2**(exp)))
print l(block_1_mantissa *    2**(block_1_exp)) - l(mantissa * 2**(exp))
print l(block_1_mantissa) + l(2**(block_1_exp)) - l(mantissa) - l(2**(exp))
print l(block_1_mantissa) + (block_1_exp)*l(2) - l(mantissa) - (exp)*l(2)
print l(block_1_mantissa / mantissa) + (block_1_exp)*l(2) - (exp)*l(2)
print l(block_1_mantissa / mantissa) + (unpack_exp (block_1_packed_exp))*l(2) - (unpack_exp (packed_exp))*l(2)
print l(block_1_mantissa / mantissa) + (8*(block_1_packed_exp - 3))*l(2) - (8*(packed_exp - 3))*l(2)

print l(block_1_mantissa / mantissa) + ((block_1_packed_exp - 3))*l(2**8) - ((packed_exp - 3))*l(2**8)


print l(block_1_mantissa / mantissa) + block_1_packed_exp * l(2**8) - packed_exp * l(2**8)
print l(block_1_mantissa / mantissa) + (block_1_packed_exp - packed_exp)*l(2**8)
