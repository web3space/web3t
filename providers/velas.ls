require! {
    \../node_modules_embed/vlx-wallet/Crypto/Wallet.js : { default: Wallet }
    \../node_modules_embed/vlx-wallet/Crypto/index.js : { default: VelasCrypto }
    \prelude-ls : { map, foldl, filter }
    \./superagent.js : { get, post }
    \../math.js : { plus, minus, times, div, from-hex }
    \bip39
    \bignumber.js
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
transform-tx = (tx)->
    tx
export get-transactions = ({ network, address }, cb)->
    err, data <- get network.api.historyUrl.replace(':address', address) .end
    return cb err if err?
    cb null, data.body
    #err, data <- get "https://explorer.velas.com/api/v1/txs/tranlist2" .end
    #return cb err if err?
    #return cb "expected array" if typeof! data.body isnt \Array
    #only-my = (tx)->
    #    (tx.from ++ tx.to).index-of(address) > -1
    #txs =
    #    data.body |> filter only-my |> map transform-tx
    #return cb null, txs
bigInt = -> new bignumber(it)
get-unspents = ({ network, address }, cb)->
    base-url = network.api.api-url
    err, res <- get "#{base-url}/unspent/#{address}" .end
    unspents-native = res.body
    return cb "expected array" if typeof! unspents-native isnt \Array
    return cb err if err?
    cb null, res.body
export create-transaction = ({ network, account, recipient, amount, amount-fee, data, fee-type, tx-type} , cb)-->
    #IsValidAddress
    return cb "Given address is not valid Velas address" if not Wallet.Is-valid-address account.address
    return cb "Recipient address is not valid Velas address" if not Wallet.Is-valid-address recipient
    err, unspents-native <- get-unspents { network, account.address }
    return cb err if err?
    return cb "there is not any unspents" if unspents.length is 0
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
    fee-bigInt = big-int fee
    txUnsigned = vc.tx.generate unspents, amount-satoshi-big-int, hd-keys, account.address, recipient, fee-bigInt
    tx = tx-unsigned.sign!
    rawtx = tx.toJSON!
    cb null, { rawtx }
export push-tx = ({ network, rawtx } , cb)-->
    base-url = network.api.api-url
    err, tx <- post "#{base-url}/send", rawtx .end
    return cb err if err?
    cb null, tx
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
    err, unspents-native <- get-unspents { network, address }
    return cb err if err?
    return cb null, 0 if unspents-native.length is 0
    balance =
        unspents-native |> map (.value) |> foldl plus, 0
    cb null, balance