require! {
    \prelude-ls : { obj-to-pairs, pairs-to-obj }
    \./math.ls : { minus }
}

#{ calc-fee, get-keys, push-tx, get-balance, get-transactions, create-transaction } = provider
    
build-calc-fee = ({network, provider})-> ({ account, to, amount, data}, cb)->
    cb null, network.tx-fee
    
build-send-transaction = ({network, provider})-> ({ account, to, amount, data}, cb)->
    { create-transaction, push-tx } = provider
    calc-fee = build-calc-fee { network, provider }
    err, amount-fee <- calc-fee { account, to, amount, data}
    return cb err if err?
    err, rawtx <- create-transaction { account, recepient: to, amount, data, network, amount-fee }
    return cb err if err?
    err, data <- push-tx { network, rawtx }
    return cb err if err?
    cb null, data


build-get-balance = ({network, provider})-> ({ account }, cb)->
    { get-balance } = provider
    err, data <- get-balance { account.address, network }
    return cb err if err?
    cb null, data

build-send-all-funds = ({ network, provider })-> ({ account, to, data}, cb)->
    send-transaction = build-send-transaction { network, provider }
    get-balance = build-get-balance { network, provider }
    calc-fee = build-calc-fee { network, provider }
    err, amount <- get-balance { account }
    return cb err if err?
    err, fee <- calc-fee { account, to, amount, data}
    return cb err if err?
    all = amount `minus` fee
    send-transaction { account, to, amount: all, data }, cb

build-create-account = ({network, provider})-> ({ mnemonic, index }, cb)->
    { get-keys } = provider
    err, data <- get-keys { mnemonic, index, network }
    return cb err if err?
    cb null, data



build-get-history = ({network, provider})-> ({ account }, cb)->
    { get-transactions } = provider
    err, data <- get-transactions { account.address, network }
    return cb err if err?
    cb null, data

build-pair = ([name, api], providers, mode, cb)->
    return cb null, {} if api.enabled isnt yes or api.type isnt \coin
    network = api[mode]
    return cb "Network #{mode} not found for #{mode}" if not network?
    provider = providers[network.api.provider]
    return cb "Provider not found for #{name}" if not provider?
    send-transaction = build-send-transaction { network, provider }
    create-account = build-create-account { network, provider }
    calc-fee = build-calc-fee { network, provider }
    get-balance = build-get-balance { network, provider }
    get-history = build-get-history { network, provider }
    send-all-funds = build-send-all-funds { network, provider }
    cb null, { send-transaction, create-account, calc-fee, get-balance, get-history, send-all-funds }
        
build-pairs = ([pair, ...rest], providers, mode, cb)->
    return cb null, [] if not pair?
    err, item <- build-pair pair, providers, mode
    return cb err if err?
    err, rest <- build-pairs rest, providers, mode
    return cb err if err?
    cb null, ([[pair.0, item]] ++ rest)
    
build-api = (coins, providers, mode, cb)->
    pairs = 
        coins |> obj-to-pairs
    err, items <- build-pairs pairs, providers, mode
    return cb err if err?
    result = pairs-to-obj items
    cb null, result
module.exports = build-api