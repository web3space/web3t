require! {
    \eosjs-ecc : ecc
    \superagent : { post }
}
#https://developer.eospark.com/api-doc/https/transaction.html#push-transaction
apikey = \a9564ebc3289b7a14551baf8ad5ec60a
export calc-fee = ({ network, tx }, cb)->
    cb null
export get-keys = ({ network, mnemonic, index }, cb)->
    private-key = ecc.seed-private "#{mnemonic} #{index}"
    public-key = ecc.private-to-public private-key
    cb null, { public-key, private-key }
export get-transactions = ({ network, address }, cb)->
    cb "Not Implemented"
export create-transaction = ({ network, account, recipient, amount, amount-fee, data, fee-type, tx-type} , cb)-->
    cb "Not Implemented"
export push-tx = ({ network, rawtx } , cb)-->
    err, data <- post "https://api.eospark.com/api?module=transaction&action=push_transaction&apikey=#{apikey}&fmt=raw" .end
    return cb err if err?
    return cb data.text if typeof! data.body.errno is \Number
    cb null, data.body
export check-tx-status = ({ network, tx }, cb)->
    cb "Not Implemented"
export get-balance = ({ network, address} , cb)->
    cb "Not Implemented"