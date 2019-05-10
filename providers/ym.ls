require! {
    \yandex-money-sdk : { Wallet }
    \prelude-ls : { map, find, split, map }
    \../math.ls : { div, times, plus, minus }
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
    console.log info.account
    address = \+ + info.account?contract-id
    cb null, { network.private-key , address }
transform-tx = (network, t)-->
    { url } = network.api
    tx = t.txnId
    amount = t.total.amount
    time = t.date
    fee = t.commission.amount
    from = if t.type is 'OUT' then t.personId else t.account
    to = if t.type is 'OUT' then t.account else t.personId
    { network: 'ym', tx, amount, fee, time, url, t.from, t.to }
export get-transactions = ({ network, address }, cb)->
    err, api <- get-api network.private-key
    return cb err if err?
    sources =
        | network.currency is 643 => <[ QW_RUB ]>
        | _ => []
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
    rawtx = "#{amount} -> #{recipient}"
    cb null, { rawtx }
export push-tx = ({ network, rawtx } , cb)-->
    return cb "rawtx should be an string" if typeof! rawtx isnt \String
    [amount, account] = 
        rawtx |> split '->'
            |> map -> it.trim!
    err, api <- get-api network.private-key
    return cb err if err?
    data = { amount, comment: 'Money Transfer', account }
    cb "Not Implemented"
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