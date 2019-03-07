require! {
    \superagent : { post, get }
    \prelude-ls : { map }
}
export calc-fee = ({ network, tx }, cb)->
    cb null
no-account = null
export get-keys = ({ network, mnemonic, index }, cb)->
    cb "Not Implemented"
transform-tx = (network, t)-->
    { explorer-url } = network.api
    dec = get-dec network
    network = \trx
    tx = t.trx_id
    amount = t.quantity `div` dec
    time = t.timestamp
    url = "#{explorer-url}/tx/#{tx}"
    fee = 0 `div` dec
    from = t.sender
    to = t.receiver
    { network, tx, amount, fee, time, url, from, to }
export get-transactions = ({ network, address }, cb)->
    cb "Not Implemented"
export create-transaction = ({ network, account, recipient, amount, amount-fee, data, fee-type, tx-type} , cb)-->
    cb "Not Implemented"
export push-tx = ({ network, rawtx } , cb)-->
    cb "Not Implemented"
export check-tx-status = ({ network, tx }, cb)->
    cb "Not Implemented"
export get-total-received = ({ address, network }, cb)->
    cb "Not Implemented"
export get-balance = ({ network, address }, cb)->
    cb "Not Implemented"