require! {
    \superagent : { post, get }
    \prelude-ls : { map, find }
    \stellar-sdk : sdk
    \stellar-hd-wallet : hd
}
#https://stellar.github.io/js-stellar-sdk/
#https://github.com/chatch/stellar-hd-wallet
#https://www.stellar.org/developers/horizon/reference/endpoints/transactions-create.html
export calc-fee = ({ network, tx }, cb)->
    cb null
no-account = null
export get-keys = ({ network, mnemonic, index }, cb)->
    try 
        wallet = hd.from-mnemonic mnemonic
        public-key = wallet.get-public-key index
        private-key = wallet.get-secret index
        address = null
        cb null, { public-key, private-key, address }
    catch err
        cb err
transform-tx = (network, t)-->
    { explorer-url } = network.api
    dec = get-dec network
    network = \xlm
    tx = t.trx_id
    amount = t.quantity `div` dec
    time = t.timestamp
    url = "#{explorer-url}/tx/#{tx}"
    fee = 0 `div` dec
    from = t.sender
    to = t.receiver
    { network, tx, amount, fee, time, url, from, to }
export get-unconfirmed-balance = ({ network, address} , cb)->
    cb "Not Implemented"
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
    err, data <- get "#{network.api.api-url}/accounts/{address}" .end
    return cb err if err?
    balance =
        data.body.balances |> find (.asset_code is \XLM)
    xlm-balance = balance?balance ? 0
    cb null, xlm-balance