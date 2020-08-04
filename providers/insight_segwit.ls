require! {
    \./insight.ls
}
export calc-fee = insight.calc-fee
get-bitcoin-fullpair-by-index = (mnemonic, index, network)->
    seed = bip39.mnemonic-to-seed-hex mnemonic
    hdnode = BitcoinLib.HDNode.from-seed-hex(seed, network).derive(index)
    address = hdnode.get-address!
    private-key = hdnode.key-pair.toWIF!
    public-key = hdnode.get-public-key-buffer!.to-string(\hex)
    { address, private-key, public-key }
export get-keys = ({ network, mnemonic, index }, cb)->
    result = get-bitcoin-fullpair-by-index mnemonic, index, network
    console.log \here
    const { address } = BitcoinLib.payments.p2sh do
        redeem: bitcoin.payments.p2wpkh { pubkey: public-key }
    cb null, { ...result, address }
export create-transaction = insight.create-transaction
export push-tx = insight.push-tx
export get-total-received = insight.get-total-received
export get-unconfirmed-balance = insight.get-unconfirmed-balance
export get-balance = insight.get-balance
export check-tx-status = insight.check-tx-status
export get-transactions = insight.get-transactions