require! {
    \superagent : { get }
    \../math.ls : { div }
    \../json-parse.ls
    \../deadline.ls
}
export calc-fee = ({ network, tx }, cb)->
    cb null
export get-keys = ({ network, mnemonic, index }, cb)->
    cb "Not implemented"
export create-transaction = ({ account, recipient, amount, amount-fee } , cb)-->
    cb "Not implemented"
export push-tx = ({ network, rawtx } , cb)-->
    cb "Not implemented"
export get-balance = ({ address } , cb)->
    err, res <- get "https://nodes.wavesnodes.com/addresses/balance/#address"  .timeout({ deadline }).end
    return cb err if err?
    err, result <- json-parse res.text
    return cb err if err?
    return cb "Balance is not available" if not result?balance?
    balance = result.balance `div` 100000000
    cb null, balance
export check-tx-status = ({ network, tx }, cb)->
    cb "Not Implemented"
export get-total-received = ({ address, network }, cb)->
    cb "Not Implemented"
export get-transactions = ({ network, address}, cb)->
    cb null, []