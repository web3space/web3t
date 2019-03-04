require! {
    \prelude-ls : { obj-to-pairs, pairs-to-obj }
    \./math.ls : { minus }
    \./config-parser.ls
}

#{ calc-fee, get-keys, push-tx, get-balance, get-transactions, create-transaction } = provider

calc-fee-options = (network, tx, cb)->
    { fee-type } = tx
    { tx-fee-options } = network
    return cb "Expected object tx-fee-options" if typeof! tx-fee-options isnt \Object
    return cb "Expected string auto|cheap" if fee-type not in <[ auto cheap ]>
    option = tx-fee-options[fee-type]
    return cb "Option is not defined" if typeof! option isnt \String
    cb null, option

default-calc-fee = (network, tx, cb)->
    { fee-type } = tx
    { tx-fee-options } = network
    return calc-fee-options network, tx, cb if fee-type? and tx-fee-options?
    cb null, network.tx-fee

build-calc-fee = ({ network, provider })-> (tx, cb)->
    return cb null, network.tx-fee if typeof! provider.calc-fee isnt \Function
    err, tx-fee <- provider.calc-fee { network, tx }
    return cb err if err?
    return default-calc-fee network, tx, cb if not tx-fee?
    cb null, tx-fee

build-send-transaction = ({network, provider})-> ({ account, to, amount, data, fee-type }, cb)->
    { create-transaction, push-tx } = provider
    calc-fee = build-calc-fee { network, provider }
    
    err, amount-fee <- calc-fee { account, to, amount, data, fee-type }
    return cb err if err?
    err, data <- create-transaction { account, recipient: to, amount, data, network, amount-fee, fee-type }
    return cb err if err?
    err, data <- push-tx { network, data.rawtx }
    return cb err if err?
    cb null, data


build-get-balance = ({network, provider})-> ({ account }, cb)->
    { get-balance } = provider
    err, data <- get-balance { account.address, network }
    return cb err if err?
    cb null, data

build-send-all-funds = ({ network, provider })-> ({ account, to, data, fee-type}, cb)->
    send-transaction = build-send-transaction { network, provider }
    get-balance = build-get-balance { network, provider }
    calc-fee = build-calc-fee { network, provider }
    err, amount <- get-balance { account }
    return cb err if err?
    err, fee <- calc-fee { account, to, amount, data, fee-type }
    return cb err if err?
    all = amount `minus` fee
    send-transaction { account, to, amount: all, data, fee-type }, cb

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

build-pair = ([name, api], providers, config, cb)->
    return cb null, {} if api.enabled isnt yes or api.type isnt \coin
    { get-mode-for } = config-parser config
    mode = get-mode-for name
    #console.log mode if name is \eth
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
        
build-pairs = ([pair, ...rest], providers, config, cb)->
    return cb null, [] if not pair?
    err, item <- build-pair pair, providers, config
    return cb err if err?
    err, rest <- build-pairs rest, providers, config
    return cb err if err?
    cb null, ([[pair.0, item]] ++ rest)
    
build-api = (coins, providers, config, cb)->
    pairs = 
        coins |> obj-to-pairs
    err, items <- build-pairs pairs, providers, config
    return cb err if err?
    result = pairs-to-obj items
    cb null, result
module.exports = build-api