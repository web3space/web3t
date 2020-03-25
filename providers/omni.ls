require! {
    \qs : { stringify }
    \prelude-ls : { filter, map, foldl, each, find, sum, values }
    \../math.js : { plus, minus, times, div }
    \./superagent.js : { get, post }
    \../json-parse.js
    \../deadline.js
    \./deps.js : { BitcoinLib, bip39 }
}
get-bitcoin-fullpair-by-index = (mnemonic, index, network)->
    seed = bip39.mnemonic-to-seed-hex mnemonic 
    hdnode = BitcoinLib.HDNode.from-seed-hex(seed, network).derive(index)
    address = hdnode.get-address!
    private-key = hdnode.key-pair.toWIF!
    public-key = hdnode.get-public-key-buffer!.to-string(\hex)
    { address, private-key, public-key }
# https://api.omniexplorer.info/#request-v1-address-addr
export calc-fee = ({ network, tx, tx-type, account, fee-type }, cb)->
    o = network?tx-fee-options
    tx-fee = o?[fee-type] ? network.tx-fee ? 0
    return cb null, tx-fee if fee-type isnt \auto
    err, data <- get "#{get-api-url network}/utils/estimatefee?nbBlocks=6" .timeout { deadline } .end
    return cb err if err?
    vals = values data.body
    exists = vals.0 ? -1
    calced-fee = 
        | vals.0 is -1 => network.tx-fee
        | _ => vals.0
    cb null, calced-fee
export get-keys = ({ network, mnemonic, index }, cb)->
    result = get-bitcoin-fullpair-by-index mnemonic, index, network
    cb null, result
#const simple_send = [
#    "6f6d6e69", // omni
#    "0000",     // version
#    "00000000001f", // 31 for Tether
#    "000000003B9ACA00" // amount = 10 * 100 000 000 in HEX
#  ].join('')
#
#  const data = Buffer.from(simple_send, "hex")
#  const omniOutput = bitcoin.script.compile([
#    bitcoin.opcodes.OP_RETURN,
#    // payload for OMNI PROTOCOL:
#    data
#  ])
#
#  tx.addOutput(recipient_address, fundValue) // should be first!
#  tx.addOutput(omniOutput, 0)
#
#  tx.addOutput(alice_address, skipValue)
#get-outputs = ({ network, address} , cb)-->
#    { btc-api-url } = network.api
#    body <- get "#{btc-api-url}/api/addr/#{address}/utxo" .then
#    err, result <- json-parse body.text
#    return cb err if err?
#    return cb "Result is not an array" if typeof! result isnt \Array
#    result
#        |> each add-value network
#        |> map extend { network, address }
#        |> -> cb null, it
extend-num = (str, fixed)->
    return str if str.length >= fixed
    extend-num "0#{str}", fixed
extend = (add, json)--> json <<< add
to-hex = (num, fixed)->
    n = (+num).to-string 16
    extend-num n, fixed
get-api-url = (network)->
    api-name = network.api.api-name ? \api
    "#{network.api.api-url-btc}/#{api-name}"
add-value = (network, it)-->
    dec = get-dec network
    it.value =
        | it.satoshis? => it.satoshis
        | it.amount? => it.amount `times` dec
        | _ => 0
get-outputs = ({ network, address} , cb)-->
    { url } = network.api
    err, data <- get "#{get-api-url network}/addr/#{address}/utxo" .timeout { deadline } .end
    return cb err if err?
    return cb "Result is not an array" if typeof! data.body isnt \Array
    data.body
        |> each add-value network
        |> map extend { network, address }
        |> -> cb null, it
export create-transaction = ({ network, account, recipient, amount, amount-fee, fee-type, tx-type, spender }, cb)->
    err, outputs <- get-outputs { network, account.address }
    return cb err if err?
    return cb 'Not Enough Funds (Unspent Outputs)' if outputs.length is 0
    is-no-value =
        outputs |> find (-> !it.value?)
    return cb 'Each output should have a value' if is-no-value
    dec = get-dec network
    value = amount `times` dec
    fee = amount-fee `times` dec
    dust = 546
    total = 
        outputs
            |> map (.value)
            |> sum
    return cb 'Total is NaN' if isNaN total
    return cb "Balance is not enough to send tx" if +(total `minus` fee) <= 0
    err, omni-balance <- get-balance { network, account.address }
    return cb err if err?
    return cb "Balance is not enough to send this amount" if +omni-balance < +amount
    tx = new BitcoinLib.TransactionBuilder network
    simple_send =
        * "6f6d6e69" # omni
        * to-hex 0, 4
        * to-hex network.propertyid, 12
        * to-hex value, 16
    data = Buffer.from simple_send.join(''), \hex
    omni-output = BitcoinLib.script.compile [BitcoinLib.opcodes.OP_RETURN, data]
    rest = total `minus` fee `plus` dust
    tx.add-output recipient, dust
    tx.add-output omni-output, 0
    if +rest isnt 0
        tx.add-output account.address, +rest
    apply = (output, i)->
        tx.add-input output.txid, output.vout, 0xfffffffe
    sign = (output, i)->
        key = BitcoinLib.ECPair.fromWIF account.private-key, network
        tx.sign i, key  
    outputs.for-each apply
    outputs.for-each sign
    rawtx = tx.build!.to-hex!
    #console.log 5
    cb null, { rawtx }
transform-tx = ({ network, address }, t)-->
    { url } = network.api
    network = \usdt 
    dec = get-dec network
    tx = t.txid
    amount = t.amount
    time = t.blocktime
    url = "#{url}/tx/#{tx}"
    fee = t.fee
    from =  t.sendingaddress
    to = t.referenceaddress
    #console.log { t }
    { network, tx, amount, fee, time, url, from, to }
export get-transactions = ({ network, address }, cb)->
    { api-url } = network.api
    req =
        addr : address
    err, data <- post("#{api-url}/v1/address/addr/details/", req).type('form').end
    return cb err if err?
    return cb "expected object" if typeof! data isnt \Object
    return cb "expected array" if typeof! data.body?transactions isnt \Array
    txs =
        data.body.transactions
            |> filter (-> +it.propertyid is +network.propertyid)
            |> map transform-tx { network, address }
    cb null, txs
get-dec = (network)->
    { decimals } = network
    10^decimals
export check-decoded-data = (decoded-data, data)->
    cb null, ''
export push-tx = ({ network, rawtx } , cb)-->
    err, res <- post "#{get-api-url network}/tx/send", { rawtx } .end
    return cb err if err?
    cb null, res.body?txid
#export push-tx = ({ network, rawtx } , cb)-->
#    { api-url } = network.api
#    req =
#        signed-transaction : rawtx
#    err, data <- post("#{api-url}/v1/transaction/pushtx/", req).type('form').end
#    return cb err if err?
#    return cb "expected object" if typeof! data isnt \Object
#    return cb "status isnt OK" if data.body.status isnt \ok
#    return cb "not pushed" if data.body.pushed isnt \Success
#    cb null, data.body.tx
export check-tx-status = ({ network, tx }, cb)->
    cb "Not Implemented"
str = -> (it ? "").to-string!
export get-total-received = ({ address, network }, cb)->
    err, txs <- get-transactions { address, network }
    total =
        txs |> filter (-> it.to is address)
            |> map (.amount)
            |> foldl plus, 0
    cb null, total
export get-unconfirmed-balance = ({ network, address} , cb)->
    cb "Not Implemented"
export get-balance = ({ network, address} , cb)->
    { api-url } = network.api
    req =
        addr : address
    err, data <- post("#{api-url}/v1/address/addr/", req).type('form').end
    return cb err if err?
    return cb "expected object" if typeof! data isnt \Object
    return cb "expected balance array. got #{data.text}" if typeof! data.body.balance isnt \Array
    balance =
        data.body.balance |> find (-> str(it.id) is str(network.propertyid) )
    return cb null, 0 if not balance?
    dec = get-dec network
    value = balance.value `div` dec
    cb null, value