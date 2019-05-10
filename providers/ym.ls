require! {
    \yandex-money-sdk : { Wallet }
    \prelude-ls : { map, find, split, map }
    \../math.ls : { div, times, plus, minus }
    \moment
}
export calc-fee = ({ network, fee-type, account, amount, to, data }, cb)->
    fixed = 50
    return cb null, fixed if +amount is 0
    def = fixed `plus` ((amount `div` 100) `times` 2)
    cb null, def
export get-keys = ({ network, mnemonic, index }, cb)->
    err, api <- get-api network.private-key
    return cb err if err?
    err, info <- api.account-info
    return cb err if err?
    address = info.account
    cb null, { network.private-key , address }
transform-tx = (network, t)-->
    { url } = network.api
    tx = t.operation_id
    amount = t.amount
    time = moment.utc(t.date).unix!
    fee = \n/a
    type = t.direction.to-upper-case!
    from = if t.direction is \out then 'my account'
    to = if t.direction is \out then `recipient`
    { network: 'ym', tx, amount, fee, time, url, t.from, t.to, type }
export get-transactions = ({ network, address }, cb)->
    err, api <- get-api network.private-key
    return cb err if err?
    err, info <- api.operation-history { records: 25 }
    return cb err if err?
    return cb "expected array" if typeof! info.operations isnt \Array
    txs =
        info.operations |> map transform-tx network
    cb null, txs
export create-transaction = ({ network, account, recipient, amount, amount-fee, data, fee-type, tx-type} , cb)-->
    err, balance <- get-balance { network, account.address }
    return cb err if err?
    rest = balance `minus` (amount `plus` amount-fee)
    return cb "Balance is not enough to send this amount" if +rest < 0
    return cb err if err?
    options =
        pattern_id : \p2p
        to : recipient
        amount_due : amount
        comment : "Payment"
        message : "Payment"
        label : "payment"
        test_payment : no
        test_result : \success
    err, res <- api.request-payment options
    return cb err if err?
    return cb res if res.status isnt \success
    rawtx = data.request_id
    cb null, { rawtx }
export push-tx = ({ network, rawtx } , cb)-->
    return cb "rawtx should be an string" if typeof! rawtx isnt \String
    err, api <- get-api network.private-key
    return cb err if err?
    request_id = rawtx
    err, data <- api.process-payment { request_id }
    #console.log err, data
    return cb err if err?
    return cb data if data.status isnt \success
    cb null, data.operation_id
export get-total-received = ({ address, network }, cb)->
    cb "Not Implemented"
get-api = (private-key, cb)->
    api = new Wallet private-key
    cb null, api
export get-balance = ({ network, address } , cb)->
    return cb "private key is required" if not network?private-key?
    err, api <- get-api network.private-key
    return cb err if err?
    err, info <- api.account-info
    return cb err if err?
    cb null, info.balance