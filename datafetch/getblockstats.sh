# have to output block 0 manually because of bug in bitcoind
# https://github.com/bitcoin/bitcoin/issues/19885

# height
echo 0
# hash
echo '"000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"'
# subsidy
echo 5000000000
# totalfee
echo 0
# time
echo 1231006505
# mediantime
echo 1231006505


for HEIGHT in {1..649616}
do
  bitcoin-cli getblockstats $HEIGHT | jq --monochrome-output '.["height","blockhash","subsidy","totalfee","time","mediantime"]'  

done
