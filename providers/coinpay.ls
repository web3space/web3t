require! {
    \superagent
    \prelude-ls : { map, find, split, map }
    \../math.js : { div, times, plus, minus }
    \moment
}

build-request = (private-key, cb)->
    #return cb "private key is required", {} if not private-key?
    base-url = \https://coinpay.org.ua/api/v1
    post = (url, data, cb)->
        err, res <- superagent.post("#{base-url}/#{url}", data).set(\X-CSRFToken , \sbo79kBAedsRgp1BgPFJUrkqgklYaybnVXB4hxHa8iZXqojg7Vt3JBMBMZ3LjcMw).set(\Authorization , "Bearer #{private-key}").end
        return cb err if err?
        return cb res.data if res.status isnt 201
        cb null, res.data
    get = (url, data, cb)->
        err, res <- superagent.get("#{base-url}/#{url}").set(\X-CSRFToken , \sbo79kBAedsRgp1BgPFJUrkqgklYaybnVXB4hxHa8iZXqojg7Vt3JBMBMZ3LjcMw).set(\Authorization , "Bearer #{private-key}").end
        return cb err if err?
        return cb res.data if res.status isnt 201
        cb null, res.data
    cb null, { post, get }

build-create-user = (private-key)-> (data, cb)->
    return cb "password is required" if typeof! data.password isnt \String
    return cb "email is required" if typeof!  data.email isnt \String
    return cb "username is required" if typeof!  data.username isnt \String
    err, { post } <- build-request private-key
    return cb err if err?
    post \user/create , data, cb

build-obtain-token = (private-key)-> (data, cb)->
    return cb "password is required" if typeof! data.password isnt \String
    return cb "email is required" if typeof!  data.email isnt \String
    err, { post } <- build-request private-key
    return cb err if err?
    post \user/obtain_token , data, cb
    
build-refresh-token = (private-key)-> (data, cb)->
    return cb "token is required" if typeof! data.token isnt \String
    err, { post } <- build-request private-key
    return cb err if err?
    post \user/refresh_token , data, cb
    
build-get-balance = (private-key)-> (data, cb)->
    err, { get } <- build-request private-key
    return cb err if err?
    get \user/balance , data, cb
    
build-account-info = (private-key)-> (cb)->
    err, { get } <- build-request private-key
    return cb err if err?
    get \user/account_info, {}, cb

build-withdrawal = (private-key)-> (data, cb)->
    return cb "withdrawal_type is required" if typeof! data.withdrawal_type isnt \String
    return cb "wallet_to is required" if typeof! data.wallet_to isnt \String
    #return cb "comment is required" if typeof! data.comment isnt \String
    return cb "amount is required" if typeof! data.amount isnt \String
    return cb "currency is required" if typeof! data.currency isnt \String
    err, { post } <- build-request private-key
    return cb err if err?
    post \withdrawal , data, cb

build-cancel-withdrawal = (private-key)-> (data, cb)->
    return cb "order_id is required" if typeof! data.order_id isnt \String
    err, { post } <- build-request private-key
    return cb err if err?
    post \withdrawal/cancel , data, cb
    
build-repeat-withdrawal = (private-key)-> (data, cb)->
    return cb "order_id is required" if typeof! data.order_id isnt \String
    err, { post } <- build-request private-key
    return cb err if err?
    post \withdrawal/repeat , data, cb

build-exchange = (private-key)-> (data, cb)->
    return cb "either currency_to_get_amount or сurrency_to_spend_amount is required" if typeof! data.currency_to_get_amount isnt \String and typeof! data.сurrency_to_spend_amount isnt \String
    return cb "currency_to_spend is required" if typeof! data.currency_to_spend isnt \String
    
    err, { post } <- build-request private-key
    return cb err if err?
    post \exchange , data, cb

build-order-history = (private-key)-> (data, cb)->
    err, { get } <- build-request private-key
    return cb err if err?
    get \orders/history, data, cb

build-order-details = (private-key)-> (data, cb)->
    return cb "order_id is required" if typeof! data.order_id isnt \String
    err, { get } <- build-request private-key
    return cb err if err?
    get \orders/details, data, cb


get-api = (private-key, cb)->
    create-user  = build-create-user null
    obtain-token = build-obtain-token null
    refresh-token = build-refresh-token null
    get-balance = build-get-balance private-key
    account-info = build-account-info private-key
    withdrawal = build-withdrawal private-key
    cancel-withdrawal = build-cancel-withdrawal private-key
    repeat-withdrawal = build-repeat-withdrawal private-key
    exchange = build-exchange private-key
    order-history = build-order-history private-key
    order-details = build-order-details private-key
    cb null, { create-user, obtain-token, refresh-token, get-balance, account-info, cancel-withdrawal, repeat-withdrawal, withdrawal, exchange, order-history, order-details }

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
    err, data <- api[send-name] data
    return cb err if err?
    return cb data.message if data.code is \QWPRC-319
    tx = data.transaction.id
    cb null, { tx, ...data }

export get-total-received = ({ address, network }, cb)->
    
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
