for HEIGHT in {1..649616}
do
    HASH=`bitcoin-cli getblockstats $HEIGHT | jq --monochrome-output '.["blockhash"]' | cut -b2-65`  
  bitcoin-cli getblock $HASH | jq --monochrome-output '.["height","hash", "bits","difficulty","chainwork"]'
done
