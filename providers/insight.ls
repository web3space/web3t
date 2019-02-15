require! {
    \moment
    \prelude-ls : { map, foldl, any, each, find, sum, filter, head }
    \superagent : { get, post } 
    \../math.ls : { plus, minus, div, times }
    \bitcoinjs-lib : BitcoinLib
    \../json-parse.ls
    \whitebox : { get-fullpair-by-index }
    \../deadline.ls
}
export calc-fee = ({ network, tx }, cb)->
    cb null
export get-keys = ({ network, mnemonic, index }, cb)->
    result = get-fullpair-by-index mnemonic, index, network
    cb null, result
extend = (add, json)--> json <<< add
get-dec = (network)->
    { decimals } = network
    10^decimals
add-value = (network, it)-->
    dec = get-dec network
    it.value =
        | it.satoshis? => it.satoshis
        | it.amount? => it.amount `times` dec
        | _ => 0
get-outputs = ({ network, address} , cb)-->
    { url } = network.api
    body <- get "#{get-api-url network}/addr/#{address}/utxo" .then
    err, result <- json-parse body.text
    return cb err if err?
    return cb "Result is not an array" if typeof! result isnt \Array
    result
        |> each add-value network
        |> map extend { network, address }
        |> -> cb null, it
export create-transaction = ({ network, account, recepient, amount, amount-fee, fee-type}, cb)->
    err, outputs <- get-outputs { network, account.address}
    return cb err if err?
    return cb 'Not Enough Funds (Unspent Outputs)' if outputs.length is 0
    is-no-value =
        outputs |> find (-> !it.value?)
    return cb 'Each output should have a value' if is-no-value
    dec = get-dec network
    value = amount `times` dec
    fee = amount-fee `times` dec
    total = 
        outputs 
            |> map (.value)
            |> sum
    return cb "Balance is not enough to send tx" if +(total `minus` fee) < 0
    return cb 'Total is NaN' if isNaN total
    tx = new BitcoinLib.TransactionBuilder network
    rest = total `minus` value `minus` fee
    tx.add-output recepient, +value
    tx.add-output account.address, +rest
    #console.log {value, rest}
    apply = (output, i)->
        tx.add-input output.txid, output.vout
    sign = (output, i)->
        key = BitcoinLib.ECPair.fromWIF(account.private-key, network)
        tx.sign i, key  
    outputs.for-each apply
    outputs.for-each sign
    rawtx = tx.build!.to-hex!
    cb null, { rawtx }
export push-tx = ({ network, rawtx } , cb)-->
    err, res <- post "#{get-api-url network}/tx/send", { rawtx } .end
    return cb err if err?
    cb null, res.body
export get-balance = ({ address, network } , cb)->
    return cb "Url is not defined" if not network?api?url?
    err, data <- get "#{get-api-url network}/addr/#{address}/balance" .timeout { deadline } .end
    return cb err if err? or data.text.length is 0
    dec = get-dec network
    num = data.text `div` dec
    cb null, num
incoming-vout = (address, vout)-->
    addrs = vout.script-pub-key?addresses
    return no if typeof! addrs isnt \Array
    addrs.index-of(address) > -1
outcoming-vouts = (address, vout)-->
    addresses = vout.script-pub-key?addresses
    return null if typeof! addresses isnt \Array
    return { vout.value, address: addresses.join(",") } if addresses.index-of(address) is -1
    null
transform-in = ({ net, address }, t)->
    network = net.token
    tx = t.txid
    time = t.time
    fee = t.fees ? 0
    vout = t.vout ? []
    unspend =
        vout |> filter incoming-vout address
            |> head
    amount = unspend?value
    to = address
    url = "#{net.api.url}/tx/#{tx}"
    { network, tx, amount, fee, time, url, to }
transform-out = ({ net, address }, t)->
    network = net.token
    tx = t.txid
    time = t.time
    fee = t.fees ? 0
    vout = t.vout ? []
    outcoming =
        vout 
            |> map outcoming-vouts address
            |> filter (?)
    amount =
        outcoming
            |> map (.value)
            |> foldl plus, 0
    to = outcoming.map(-> it.address).join(",")
    url = "#{net.api.url}/tx/#{tx}"
    { network, tx, amount, fee, time, url, to }
transform-tx = (config, t)-->
    self-sender =
        t.vin ? []
            |> find -> it.addr is config.address
    return transform-in config, t if not self-sender?
    transform-out config, t
get-api-url = (network)->
    api-name = network.api.api-name ? \api
    "#{network.api.url}/#{api-name}"
export get-transactions = ({ network, address}, cb)->
    return cb "Url is not defined" if not network?api?url?
    err, data <- get "#{get-api-url network}/txs/?address=#{address}" .timeout { deadline: 5000 } .end
    return cb err if err?   
    err, result <- json-parse data.text
    return cb err if err?
    return cb "Unexpected result" if typeof! result?txs isnt \Array
    txs = 
        result.txs 
            |> map transform-tx { net: network, address }
            |> filter (?)
    cb null, txs