require! {
    \moment
    \prelude-ls : { map, foldl, any, each, find, sum, filter }
    \superagent : { get, post } 
    \../math.ls : { plus, minus, div, times }
    \bitcoinjs-lib-zcash : BitcoinLib
    \../json-parse.ls
    \../deadline.ls
}
export calc-fee = ({ network, tx }, cb)->
export get-keys = ({ network, mnemonic, index }, cb)->
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
    body <- get "#url/api/addr/#{address}/utxo" .then
    err, result <- json-parse body.text
    return cb err if err?
    return cb "Result is not an array" if typeof! result isnt \Array
    result
        |> each add-value network
        |> map extend { network, address }
        |> -> cb null, it
export create-transaction = ({ network, account, recepient, amount, amount-fee}, cb)->
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
    return cb 'Total is NaN' if isNaN total
    tx = new BitcoinLib.TransactionBuilder network
    rest = total `minus` value `minus` fee
    tx.add-output recepient, +value
    tx.add-output account.address, +rest
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
    { url } = network.api
    res <- post "#url/api/tx/send", { rawtx } .then
    return cb res.body if res.bad-request
    cb null, res.body
export get-balance = ({ address, network } , cb)->
    return cb "Url is not defined" if not network?api?url?
    err, data <-! get "#{network.api.url}/api/addr/#{address}/balance" .end
    return cb err if err? or data.text.length is 0
    dec = get-dec network
    num = data.text `div` dec
    cb null, num
transform-tx = (net, t)-->
    same-value = (out)->
        parse-float(out.value `minus` t.value-out) is 0
    network = net.token
    tx = t.txid
    time = t.time
    amount = t.value-out
    fee = t.fees ? 0
    to = t.vout?filter?(same-value)?map(-> it.script-pub-key?addresses?0)?0
    url = "#{net.api.url}/tx/#{tx}"
    { network, tx, amount, fee, time, url, to }
export get-transactions = ({ network, address}, cb)->
    return cb "Url is not defined" if not network?api?url?
    err, data <-! get "#{network.api.url}/api/txs/?address=#{address}" .end
    return cb err if err?   
    err, result <- json-parse data.text
    return cb err if err?
    return cb "Unexpected result" if typeof! result?txs isnt \Array
    txs = 
        result.txs |> map transform-tx network
    cb null, txs