require! {
    \eosjs : Eos
    \superagent : { post, get }
    \prelude-ls : { map, filter, foldl }
    \../math.ls : { plus }
}
#https://developer.eospark.com/api-doc/https/transaction.html#push-transaction
#https://developers.eos.io/eosio-nodeos/reference
#https://github.com/MarcelBlockchain/eosjs-node-cli/blob/master/eos.js
#https://github.com/EOSIO/eosjs-api/blob/master/docs/api.md
#https://eosio.stackexchange.com/questions/1989/sign-push-transaction-separately-eosjs/1992
as-callback = (promise, cb)->
    state =
        res: null
        err: null
    promise
        .then do
            * (res)-> state.res = res
        .catch (err)-> state.err = err
        .finally ->
            #console.log state
            cb state.err, state.res
apikey = \a9564ebc3289b7a14551baf8ad5ec60a
list-accounts = ({ network, public-key } , cb)->
    eos = get-eos { network }
    err, data <- as-callback eos.get-key-accounts(public-key)
    return cb err if err?
    names = data.account_names ? []
    cb null, names
export calc-fee = ({ network, tx }, cb)->
    cb null
no-account = null
export get-keys = ({ network, mnemonic, index }, cb)->
    { ecc } = Eos.modules
    private-key = ecc.seed-private "#{mnemonic} #{index}"
    public-key = ecc.private-to-public private-key
    err, accounts <- list-accounts { network, public-key }
    return cb err if err?
    address = accounts?0 ? no-account
    cb null, { public-key, private-key, address }
transform-tx = (network, t)-->
    { explorer-url } = network.api
    dec = get-dec network
    network = \eos
    tx = t.trx_id
    amount = t.quantity `div` dec
    time = t.timestamp
    url = "#{explorer-url}/tx/#{tx}"
    fee = 0 `div` dec
    from = t.sender
    to = t.receiver
    { network, tx, amount, fee, time, url, from, to }
export get-transactions = ({ network, address }, cb)->
    return cb null, [] if no-account is address
    account-name = address
    err, data <- get "#{network.api.api-url}/api?module=account&action=get_account_related_trx_info&apikey=#{apikey}&account=#{account-name}&page=1&size=2&transaction_type=3"
    return cb err if err?
    return cb data.text if data.body.errno isnt 0
    list = data.body.data?trace_list ? []
    transformed = 
        list |> map transform network
    cb null, transformed
get-random-int = (max)->
    Math.floor(Math.random! * Math.floor(max))
get-random-url = (arr)->
    index = get-random-int arr.length
    #arr[index] ? arr.0
    arr.2
get-node-url = (node-url)->
    return node-url if typeof! node-url is \String
    return get-random-url node-url if typeof! node-url is \Array
    null
get-eos = ({ network, account })->
    key-provider =
        | account?private-key? => [account.private-key]
        | _ => null
    config =
        chain-id: network.chain-id
        key-provider: key-provider
        http-endpoint : get-node-url network.api.node-url
        sign: key-provider?
        broadcast: no
        verbose: no
    Eos config
export create-transaction = ({ network, account, recipient, amount, amount-fee, data, fee-type, tx-type} , cb)->
    return cb "Account is not registered" if account.address is no-account
    eos = get-eos { network, account }
    broadcast = no
    sign = yes
    from = account.address
    err, tr <- as-callback eos.transfer(from, recipient, amount, data, { broadcast, sign })
    #console.log('created transaction: ', tr)
    cb null, tr.transaction
export push-tx = ({ network, rawtx } , cb)-->
    eos = get-eos { network }
    err, data <- as-callback eos.push-transaction(rawtx)
    return cb err if err?
    cb null, data
export get-unconfirmed-balance = ({ network, address} , cb)->
    cb "Not Implemented"
export check-tx-status = ({ network, tx }, cb)->
    cb "Not Implemented"
export get-total-received = ({ address, network }, cb)->
    err, txs <- get-transactions { address, network }
    total =
        txs |> filter (-> it.to is address)
            |> map (.amount)
            |> foldl plus, 0
    cb null, total
export get-balance = ({ network, address }, cb)->
    #address = \helloworldjs
    return cb null, 0 if address is no-account
    account-name = address
    err, data <- get "#{network.api.api-url}/api?module=account&action=get_account_balance&apikey=#{apikey}&account=#{account-name}" .end
    return cb err if err?
    return cb data.text if data.body.errno isnt 0
    balance = data.body.data?balance ? 0
    cb null, balance