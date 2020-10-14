This is instructions for create the text files that are used as input to op_energyprice.hs

Create a bitcoin full node, get synced to tip. A fast way to do this is to use lunanode m.2 type. This is $200/month, but you only need it for a day and then you can shelve it.

Once you have full node synced to tip, install jq. Sanity check that jq works:


<pre>
bitcoin-cli getblock 00000000839a8e6886ab5951d76f411475428afc90947ee320161bbf18eb6048 | jq --monochrome-output '.["height","hash", "bits","difficulty","chainwork"]'
bitcoin-cli getblockstats 209999 | jq --monochrome-output '.["height","blockhash","subsidy","totalfee","time","mediantime"]'
bitcoin-cli getblockstats 1 | jq --monochrome-output '.["height","blockhash"]'
</pre>

Then run the following commands. This might take a while. 


time ./getblockhashes.sh >> blockhashes.txt
time ./getblockstats.sh >> blockstats.txt
time ./getblockbits.sh >> blockbits.txt
time ./getblockhashesCsv.sh >> blockhashes.csv (maybe this is obsolete)
