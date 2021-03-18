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

**Objective**: show BITS (4 byte) compact representation, conversion to a uint256 input and back

**Given**: Very large integer numbers may be represented in a custom eight-byte, 256 bit structure uint256. A second format is also defined using a standard four-byte 32bit unsigned integer. This compact BITS format packs up to three bytes of value from uint256, and uses the remaining most-significant byte to store a count of the total number of bytes in the expanded number. The compact BITS format delivers a lot less precision than uint256 but is portable in a standardized way. This page explains conversion from uint256 to the compact BITS format, in order to clarify the rules for implementing conversion for common computer languages and minimize the chance of serious differences between implementation.

Conversion Rules: Take three bytes from uint256, starting with the most-significant non-zero bytes (left-most). The top bit of the three bytes is reserved for a sign bit (seldom used in practice). Conversion code must take care to keep the sign bit clear in a compact result, which often means retaining less value from the source uint256 as shown below. A single byte in compact BITS is used to keep the length of the expanded results.



**Example 1** 

convert src to dst (28 bytes of data following four bytes of zero)

given:  0x000000008cc30f97a647313fe0cad97a647313fe0cad97a647313fe0cad97a64

--------------------------------------------------------------------------

Step) disregard leading zeroes; count the number of data bytes in uint256 input, store as inCount

Step) extract the most-significant three bytes of uint256, store as resInt

inCount = 28 (0x1C)

| **Int** | Octets |   140 (0x8C)   |   195 (0xC3)  |   15 (0x0F)    |
|--------|--------|-----------------|-----------------|-----------------|
|        | Bits   | 1 0 0 0 1 1 0 0 | 1 1 0 0 0 0 1 1 | 0 0 0 0 1 1 1 1 |


Step) test the high bit of the left-most, non-zero byte of input uint256 ;
      if set,
      shift right resInt one byte (losing precision)
      increment the count of pad bytes needed

inCount = 29 (0x1D)

| **Int** | Octets |   0 (0x00)    |  140 (0x8C)   |  195 (0xC3)   |
|--------|--------|-----------------|-----------------|-----------------|
|        | Bits   | 0 0 0 0 0 0 0 0 | 1 0 0 0 1 1 0 0 | 1 1 0 0 0 0 1 1 |


Step) multiply inCount by 2**24, resulting in a 32bit integer (left shift)

inCount shifted left by three (3) bytes


| inCount | Octets |    29 (0x1D)    |     0 (0x00)    |     0 (0x00)    |     0 (0x00)    |
|---------|--------|-----------------|-----------------|-----------------|-----------------|
|       Bits       | 0 0 0 1 1 1 0 1 | 0 0 0 0 0 0 0 0 | 0 0 0 0 0 0 0 0 | 0 0 0 0 0 0 0 0 |


Step) combine inCount and resInt (logical OR) to make the final Compact BITS (CBITS)


| cBITS | Octets |    29 (0x1D)    |     0 (0x00)    |    140 (0x8C)   |    195 (0xC3)   |
|-------|--------|-----------------|-----------------|-----------------|-----------------|
|       | Bits  | 0 0 0 1 1 1 0 1 | 0 0 0 0 0 0 0 0 | 1 0 0 0 1 1 0 0 | 1 1 0 0 0 0 1 1 |


Expanded Result from compact BITS

0x8cc30000000000000000000000000000000000000000000000000000


**Example 2**  

convert src to dst (29 bytes of data following three bytes of zero)

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

