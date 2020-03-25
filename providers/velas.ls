require! {
    \../node_modules_embed/vlx-wallet/Crypto/Wallet.js : { default: Wallet }
    \../node_modules_embed/vlx-wallet/Crypto/index.js : { default: VelasCrypto }
    \prelude-ls : { map, foldl, filter }
    \./superagent.js : { get, post }
    \../math.js : { plus, minus, times, div, from-hex }
    \bip39
    \big-integer
    \moment
}
to-callback = (p, cb)->
    p.then (res)->
        cb null, res
    p.catch (res)->
        cb res
export calc-fee = ({ network, fee-type, account, amount, to, data }, cb)->
    cb null, network.tx-fee
export get-keys = ({ network, mnemonic, index }, cb)->
    err, vc <- to-callback VelasCrypto.init!
    seedBuffer = bip39.mnemonicToSeed(mnemonic)
    seed = seedBuffer.toString('hex')
    res = vc.keysGen.fromSeed(seed, 'm/' + index + '\'')
    address = res.to-wallet!.Base58Address
    { private-key } = res
    cb null, { address, private-key }
#amount: 1.01
#block_hash: "9f7c65e4ce03eca9a697310f2b15f795e985ed44589a4c3412a9e1d57d28dd69"
#commission: 0.01
#dt: "2020-01-15T17:25:41Z"
#from_address: "VLUrkcckaXNDHYqSb9vzqUKdbsoqovfWzNh"
#operation_type: 0
#status: 1
#to_address: "VLQMGJ3pBYm9v7J1FiYNSJiN62Y6zZ5xo6T"
#tx_hash: "0255c87e9306225ccda32e98772c6c32341469aba9e3cb9e11ab283dac444f6e"
#transform-tx = (network, t)-->
#    { url } = network.api
#    network = \vlx
#    tx = t.tx_hash
#    time = moment.utc(t.dt).unix!
#    url = "#{url}/tx/#{tx}"
#    to = t.to_address
#    from = t.from_address
#    fee = t.commission
#    { network, tx, t.amount, fee, time, url, from, to }
export get-transactions = ({ network, address }, cb)->
    #err, data <- get network.api.historyUrl.replace(':address', address) .end
    return cb err if err?
    txs = data.body?items ? []
    return cb "expected array" if typeof! txs isnt \Array
    return cb null, [] if txs.length is 0
    new-txs = 
        txs
            |> map transform-tx network
    #console.log \velas, txs, new-txs
    cb null, new-txs
    #err, data <- get "https://explorer.velas.com/api/v1/txs/tranlist2" .end
    #return cb err if err?
    #return cb "expected array" if typeof! data.body isnt \Array
    #only-my = (tx)->
    #    (tx.from ++ tx.to).index-of(address) > -1
    #txs =
    #    data.body |> filter only-my |> map transform-tx
    #return cb null, txs
export get-transactions = ({ network, address }, cb)->
    err, data <- get "https://explorer.velas.com/history-api/#{address}/txs" .end
    return cb err if err?
    txs = data.body
    return cb "expected array" if typeof! txs isnt \Array
    return cb null, [] if txs.length is 0
    cb null, txs
bigInt = -> new big-integer(it)
get-unspents = ({ network, address }, cb)->
    base-url = network.api.api-url
    err, res <- get "#{base-url}/wallet/unspent/#{address}" .end
    return cb err if err?
    unspents-native = res.body
    return cb "expected array, got #{typeof! unspents-native}" if typeof! unspents-native isnt \Array
    return cb err if err?
    cb null, res.body
export create-transaction = ({ network, account, recipient, amount, amount-fee, data, fee-type, tx-type} , cb)-->
    #IsValidAddress
    return cb "Given address is not valid Velas address" if not Wallet.Is-valid-address account.address
    return cb "Recipient address is not valid Velas address" if not Wallet.Is-valid-address recipient
    err, unspents-native <- get-unspents { network, account.address }
    return cb err if err?
    return cb "there is not any unspents" if unspents-native.length is 0
    unspents =
        unspents-native |> map -> { it.hash, it.index, value: bigInt it.value }
    err, fee <- calc-fee { network, fee-type, account, amount, to: recipient, data }
    return cb err if err?
    err, vc <- to-callback VelasCrypto.init!
    return cb err if err?
    hdKeys = vc.keys-gen.from-private-key account.private-key
    wallet = hdKeys.to-wallet!
    amount-satoshi = amount `times` (10^network.decimals)
    amount-satoshi-big-int = bigInt(amount-satoshi)
    fee-satoshi = fee `times` (10^network.decimals)
    fee-bigInt = big-int fee-satoshi
    #console.log do 
    #    unspents: unspents
    #    amount-satoshi-big-int: amount-satoshi-big-int
    #    hd-keys: hd-keys
    #    address: account.address
    #    recipient: recipient
    #    fee-bigInt: fee-bigInt
    #unspents, amount, velasKey, changeAddress, to, commission
    txUnsigned = vc.tx.generate unspents, amount-satoshi-big-int, hd-keys, account.address, recipient, fee-bigInt
    tx = tx-unsigned.sign!
    rawtx = tx.toJSON!
    cb null, { rawtx }
export push-tx = ({ network, rawtx } , cb)-->
    base-url = network.api.api-url
    tx = JSON.parse rawtx
    err, res <- post "#{base-url}/txs/publish", tx .end
    return cb err if err?
    return cb "expected result ok" if res.body.result isnt \ok
    #console.log res
    cb null, tx.hash
export check-tx-status = ({ network, tx }, cb)->
    cb "Not Implemented"
export get-total-received = ({ address, network }, cb)->
    return cb "Given address is not valid Velas address" if not Wallet.Is-valid-address address
    cb null, 0
export get-unconfirmed-balance = ({ network, address} , cb)->
    return cb "Given address is not valid Velas address" if not Wallet.Is-valid-address address
    cb null, 0
export get-balance = ({ network, address} , cb)->
    return cb "Given address is not valid Velas address" if not Wallet.Is-valid-address address
    err, data <- get "https://explorer.velas.com/api/v1/wallet/balance/#{address}" .end
    return cb err if err?
    #err, unspents-native <- get-unspents { network, address }
    #return cb err if err?
    #return cb null, 0 if unspents-native.length is 0
    decimals = (10^network.decimals)
    #balance =
    #    unspents-native |> map (.value) |> map (-> it `div` decimals ) |> foldl plus, 0
    balance = data.body.amount `div` decimals
    cb null, balance