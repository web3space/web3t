require! {
    \node-qiwi-api : { Qiwi }
    \prelude-ls : { map, find, split, map }
    \../math.ls : { div, times, plus, minus }
    \moment
}
export calc-fee = ({ network, fee-type, account, amount, to, data }, cb)->
    fixed = 50
    return cb null, fixed if +amount is 0
    def = fixed `plus` ((amount `div` 100) `times` 2)
    #return cb null, def if (to ? "").length is 0
    cb null, def
    #err, api <- get-api network.private-key
    #return cb err if err?
    #err, fee <- api.check-comission to
    #return cb err if err?
    #res = 
    #    | fee.rate? => (amount `div` 100) `times` fee.rate
    #    | _ => fee.fixed
    #cb null, res
export get-keys = ({ network, mnemonic, index }, cb)->
    err, api <- get-api network.private-key
    return cb err if err?
    err, info <- api.get-account-info
    return cb err if err?
    address = \+ + info.contract-info?contract-id
    cb null, { network.private-key , address }
transform-tx = (network, t)-->
    { url } = network.api
    tx = t.txnId
    amount = t.total.amount
    time = moment(t.date).utc!.unix!
    fee = t.commission.amount
    from = if t.type is 'OUT' then t.personId else t.account
    to = if t.type is 'OUT' then t.account else t.personId
    { network: 'qiwi', tx, amount, fee, time, url, t.from, t.to }
export get-transactions = ({ network, address }, cb)->
    err, api <- get-api network.private-key
    return cb err if err?
    sources =
        | network.currency is 643 => <[ QW_RUB ]>
        | _ => []
    err, info <- api.get-operation-history { rows: 25, sources }
    return cb err if err?
    return cb "expected array" if typeof! info.data isnt \Array
    txs =
        info.data |> map transform-tx network
    cb null, txs
get-dec = (network)->
    { decimals } = network
    10^decimals
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
    send-name =
        | account.match(/^[0-9]{16}$/) => \toCard
        | account.match(/^\+[0-9]{10}$/) => \toWallet
        | account.match(/^[0-9]{10}$/) => \toMobilePhone
        | _ => \toWallet
    #console.log [amount, account], send-name
    err, data <- api[send-name] data
    #console.log { err ,data }
    return cb err if err?
    return cb data.message if data.code is \QWPRC-319
    tx = data.transaction.id
    cb null, { tx, ...data }
export get-total-received = ({ address, network }, cb)->
get-api = (private-key, cb)->
    api = new Qiwi private-key
    cb null, api
export get-balance = ({ network, address } , cb)->
    return cb "private key is required" if not network?private-key?
    err, api <- get-api network.private-key
    return cb err if err?
    err, info <- api.get-balance
    return cb err if err?
    account =
        info.accounts |> find (.currency is network.currency)
    return cb null, 0 if not account?
    cb null, account.balance.amount