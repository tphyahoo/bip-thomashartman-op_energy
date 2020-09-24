for HEIGHT in {1..649616}
do
  bitcoin-cli getblockstats $HEIGHT | jq --monochrome-output '.["height","blockhash"]'
done
