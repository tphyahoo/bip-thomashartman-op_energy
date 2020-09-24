bitcoin-cli getblock 00000000839a8e6886ab5951d76f411475428afc90947ee320161bbf18eb6048 | jq --monochrome-output '.["height","hash", "bits","difficulty","chainwork"]'
bitcoin-cli getblockstats 209999 | jq --monochrome-output '.["height","blockhash","subsidy","totalfee","time","mediantime"]'

bitcoin-cli getblockstats 1 | jq --monochrome-output '.["height","blockhash"]'
time ./getblockhashes.sh >> blockhashes.txt
time ./getblockstats.sh >> blockstats.txt
time ./getblockbits.sh >> blockbits.txt
bitcoin-cli getblock 00000000839a8e6886ab5951d76f411475428afc90947ee320161bbf18eb6048 | jq --monochrome-output '[.["height","hash", "bits","difficulty","chainwork"]] | @csv' 
time ./getblockhashesCsv.sh >> blockhashes.csv
