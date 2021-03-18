<pre>
  BIP: 0FFF
  Title: BIP process, revised
  Author: Thomas Hartman1  <email@gmail.com>,  Brian M Hamlin  <email@other.com>
  Comments-Summary: 
  Comments-URI: 
  Status: Under Construction
  Type: TechNote
  Created: 2020-10-31
  License: BSD-2-Clause
           OPL
  Replaces: None
</pre>

## Abstract ##

Technical Notes on Compact BITS Format 

This document describes the compact BITS format of uint32; where uint32 is a standard 32 bit long integer 
, and **cBITS** is an encoded representation of a larger value integer, described here.  

Very large integer numbers may be represented in a custom 256 bit structure uint256,  
a single variable containing eight 32bit words.   The cBITS format packs up
to three bytes of value from a uint256, and uses the remaining most-significant byte to store a
count of the total number of bytes in the expanded number.  The compact BITS format delivers a
lot less precision than uint256 but is portable in a standardized way.  This document explains
conversion from uint256 to the compact BITS format and back, in order to clarify the rules for
implementing conversion for common computer languages and minimize the chance of serious
differences between implementation.

**Conversion Rules**: Take three bytes from uint256, starting with the most-significant non-zero
bytes (left-most). The top bit of the three bytes is reserved for a sign bit (seldom used in
practice). Conversion code must take care to keep the sign bit clear in a compact result, which
often means retaining less value from the source uint256 as shown below.  A single byte in
compact BITS is used to keep the length of the expanded results


**Example 1** 

convert 256bit hex to cBITS  (28 bytes of data following four bytes of zero)

given:  0x000000008cc30f97a647313fe0cad97a647313fe0cad97a647313fe0cad97a64

--------------------------------------------------------------------------

Step) disregard leading zeroes; count the number of data bytes in uint256 input, store as inCount

Step) extract the most-significant three bytes of uint256, store as resInt

<pre>inCount = 28 (0x1C)</pre>

| **Int** | Octets |   140 (0x8C)   |   195 (0xC3)  |   15 (0x0F)    |
|--------|--------|-----------------|-----------------|-----------------|
|        | Bits   | 1 0 0 0 1 1 0 0 | 1 1 0 0 0 0 1 1 | 0 0 0 0 1 1 1 1 |


Step) test the high bit of the left-most, non-zero byte of input uint256 ;
      if set,
      shift right resInt one byte (losing precision)
      increment the count of pad bytes needed

<pre>inCount = 29 (0x1D)</pre>

| **Int** | Octets |   0 (0x00)    |  140 (0x8C)   |  195 (0xC3)   |
|--------|--------|-----------------|-----------------|-----------------|
|        | Bits   | 0 0 0 0 0 0 0 0 | 1 0 0 0 1 1 0 0 | 1 1 0 0 0 0 1 1 |


Step) multiply inCount by 2**24, resulting in a 32bit integer (left shift)

inCount shifted left by three (3) bytes


| **Int** | Octets |    29 (0x1D)    |     0 (0x00)    |     0 (0x00)    |     0 (0x00)    |
|---------|--------|-----------------|-----------------|-----------------|-----------------|
|         | Bits   | 0 0 0 1 1 1 0 1 | 0 0 0 0 0 0 0 0 | 0 0 0 0 0 0 0 0 | 0 0 0 0 0 0 0 0 |


Step) combine inCount and resInt (logical OR) to make the final Compact BITS (CBITS)


|**cBITS**| Octets |    29 (0x1D)    |     0 (0x00)    |    140 (0x8C)   |    195 (0xC3)   |
|--------|--------|-----------------|-----------------|-----------------|-----------------|
|        | Bits  | 0 0 0 1 1 1 0 1 | 0 0 0 0 0 0 0 0 | 1 0 0 0 1 1 0 0 | 1 1 0 0 0 0 1 1 |


Expanded Result from compact BITS

0x8cc30000000000000000000000000000000000000000000000000000


**Example 2**  

convert 256bit hex to cBITS (29 bytes of data following three bytes of zero)

given:  0x0000000128a0e4b1fb1fb1fb1fb1fb1fb1fb1fb1fb1fb1fb1fb1fb1fb1fb1fb1

--------------------------------------------------------------------------

Step) disregard leading zeroes; count the number of data bytes in uint256 input, store as inCount

Step) extract the most-significant three bytes of uint256, store as resInt

 inCount = 29 (0x1D)

| **Int** | Octets |     1 (0x01)    |     40 (0x28)   |    160 (0xA0)   |
|--------|--------|-----------------|-----------------|-----------------|
|        | Bits | 0 0 0 0 0 0 0 1 | 0 0 1 0 1 0 0 0 | 1 0 1 0 0 0 0 0 |


Step) test the high bit of the left-most, non-zero byte of input uint256 ; bit not set

Step) multiply inCount by 2**24, resulting in a 32bit integer (left shift)

inCount shifted left by three (3) bytes


| **Int** | Octets |    29 (0x1D)    |     0 (0x00)    |     0 (0x00)    |     0 (0x00)    |
|---------|--------|-----------------|-----------------|-----------------|-----------------|
|         | Bits | 0 0 0 1 1 1 0 1 | 0 0 0 0 0 0 0 0 | 0 0 0 0 0 0 0 0 | 0 0 0 0 0 0 0 0 |


Step) combine inCount and resInt (logical OR) to make the final Compact BITS (CBITS)


| **Int**t | Octets |    29 (0x1D)    |     1 (0x01)    |     40 (0x28)   |    160 (0xA0)   |
|---------|--------|-----------------|-----------------|-----------------|-----------------|
|         | Bits | 0 0 0 1 1 1 0 1 | 0 0 0 0 0 0 0 1 | 0 0 1 0 1 0 0 0 | 1 0 1 0 0 0 0 0 |


Expanded Result from compact BITS

0x0128A00000000000000000000000000000000000000000000000000000


-------------------------------------------------------------

--  Show coversions of a constant value with increasing left-shift
--  0xFACE00FF << (32+64+64+64)
--  0xface00ff00000000
--  0xface00ff000000000000000000000000
--  0xface00ff0000000000000000000000000000000000000000
--  0xface00ff00000000000000000000000000000000000000000000000000000000



**Example 3a**   convert uint64 to dst uint32 to src uint256
  Given:    0xFACE00FF00000000

0x000000000000000000000000000000000000000000000000FACE000000000000



**Example 3b**   convert  16 bytes to dst uint32, to src uint256
  Given:    0xFACE00FF000000000000000000000000

  0x00000000000000000000000000000000FACE0000000000000000000000000000


**Example 3c**   convert  24 bytes to dst uint32, to src uint256
  Given:    0xFACE00FF0000000000000000000000000000000000000000

  0x0000000000000000FACE00000000000000000000000000000000000000000000


**Example 3d**   convert  uint256 to dst uint32, to src uint256
  Given:    0xFACE00FF00000000000000000000000000000000000000000000000000000000

  0xFACE000000000000000000000000000000000000000000000000000000000000




**Example 4**   convert out-of-range dst uint32 to src uint256
  Given:    0x2A84FFFF

  0x0000000000000000000000000000000000000000000000000000000000000000

