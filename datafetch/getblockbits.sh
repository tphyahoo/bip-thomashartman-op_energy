# have to output block 0 manually because of bug in bitcoind
# https://github.com/bitcoin/bitcoin/issues/19885

# height
echo 0
# hash
echo '"000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"'
# bits
echo '"1d00ffff"'
# difficulty 
echo 1
# chainwork
echo '"0000000000000000000000000000000000000000000000000000000100010001"'


for HEIGHT in {1..649616}
do
    HASH=`bitcoin-cli getblockstats $HEIGHT | jq --monochrome-output '.["blockhash"]' | cut -b2-65`  
  bitcoin-cli getblock $HASH | jq --monochrome-output '.["height","hash", "bits","difficulty","chainwork"]'
done
