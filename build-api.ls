require! {
    \prelude-ls : { obj-to-pairs }
}

#{ calc-fee, get-keys, push-tx, get-balance, get-transactions, create-transaction } = provider
    
build-calc-fee = ({network, provider})-> ({ sender, recepient, amount, data}, cb)->
    cb null, network.tx-fee
    
build-send-transaction = ({network, provider})-> ({ sender, recepient, amount, data}, cb)->
    { create-transaction, push-tx } = provider
    calc-fee = build-calc-fee { network, provider }
    err, amount-fee <- calc-fee { sender, recepient, amount, data}
    return cb err if err?
    err, rawtx <- create-transaction { sender, recepient, amount, data, network, amount-fee }
    return cb err if err?
    err, data <- push-tx { network, rawtx }
    return cb err if err?
    cb null, data

build-create-sender = ({network, provider})-> ({ mnemonic, index }, cb)->
    { get-keys } = provider
    err, data <- get-keys { mnemonic, index, network }
    return cb err if err?
    cb null, data

build-get-balance = ({network, provider})-> ({ sender }, cb)->
    { get-balance } = provider
    err, data <- get-balance { sender.address, network }
    return cb err if err?
    cb null, data

build-get-history = ({network, provider})-> ({ sender }, cb)->
    { get-transactions } = provider
    err, data <- get-transactions { sender.address, network }
    return cb err if err?
    cb null, data

build-pair = ([name, api], providers, mode, cb)->
    return cb null, {} if api.enabled isnt yes or api.type isnt \coin
    network = api[mode]
    return cb "Network #{mode} not found for #{mode}" if not network?
    provider = providers[name]
    return cb "Provider not found for #{name}" if not provider?
    send-transaction = build-send-transaction { network, provider }
    create-sender = build-create-sender { network, provider }
    calc-fee = build-calc-fee { network, provider }
    get-balance = build-get-balance { network, provider }
    get-history = build-get-history { network, provider }
    cb null, { send-transaction, create-sender, calc-fee, get-balance, get-history }
        
build-pairs = ([pair, ...rest], providers, mode, cb)->
    return cb null, {} if not pair?
    err, item <- build-pair pair, providers, mode
    return cb err if err?
    err, rest <- build-pairs rest, providers, mode
    return cb err if err?
    cb null, { item, ...rest }

build-api = (coins, providers, mode, cb)->
    pairs = 
        coins |> obj-to-pairs
    build-pairs pairs, providers, mode, cb
    
module.exports = build-api