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
#0.25m + 0.05m * numberOfInputs
#private send https://github.com/DeltaEngine/MyDashWallet/blob/master/Node/DashNode.cs#L18
#https://github.com/StaminaDev/dash-insight-api/blob/master/lib/index.js#L244
get-masternode-list = ({ network }, cb)->
    err, res <- get "#{get-api-url network}/masternodes/list" .end
    return cb err if err?
    return cb "expected array" if typeof! res.body isnt \Array
    list =
        res.body |> filter (.status is \ENABLED) 
    cb null, list
find-max = (first, current)->
    if current.rank < first.rank then current else first
get-one-of-masternode = ({ network }, cb)->
    err, list <- get-masternode-list { network }
    return cb err if err?
    item =
        list |> foldl find-max, list.0
    return cb "Not Found" if not item?
    cb null, item
calc-fee-private = ({ network, tx, tx-type, account, fee-type }, cb)->
    return cb "address cannot be empty" if (account?address ? "") is ""
    o = network?tx-fee-options
    tx-fee = o?[fee-type] ? network.tx-fee ? 0
    err, outputs <- get-outputs { network, account.address }
    return cb err if err?
    number-of-inputs = if outputs.length > 0 then outputs.length else 1
    fee =
        (tx-fee `times` 2) `plus` (number-of-inputs `times` o.private-per-input)
    cb null, fee
calc-fee-instantx = ({ network, tx, tx-type, account, fee-type }, cb)->
    return cb "address cannot be empty" if (account?address ? "") is ""
    o = network?tx-fee-options
    tx-fee = o?[fee-type] ? network.tx-fee ? 0
    err, outputs <- get-outputs { network, account.address }
    return cb err if err?
    number-of-inputs = if outputs.length > 0 then outputs.length else 1
    fee =
        (number-of-inputs `times` o.instant-per-input)
    cb null, fee
export calc-fee = (config, cb)->
    { network, tx, tx-type, account } = config
    return calc-fee-private config, cb if tx-type is \private
    return calc-fee-instantx config, cb if tx-type is \instant
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
    err, data <- get "#{get-api-url network}/addr/#{address}/utxo" .end
    return cb err if err?
    data.body
        |> each add-value network
        |> map extend { network, address }
        |> -> cb null, it
parse-rate-string = (usd-info)->
    [_, url, extract] = usd-info.match(/url\(([^)]+)\)(.+)?/)
    { url, extract }
extract-val = (data, [head, ...tail])->
    return data if not head?
    extract-val data[head], tail
parse-result = (text, extract, cb)->
    return cb null, text if (extract ? "") is ""
    err, model <- json-parse text
    return cb err if err?
    result = extract-val model, extract
    cb null, result
get-deposit-address-info = ({ amount, recipient, network }, cb)->
    { mixing-info } = network?api ? {}
    return cb "Mixing Pool is not connected" if typeof! mixing-info isnt \String
    { url, extract } = parse-rate-string mixing-info
    err, data <- get url .end
    return cb err if err?
    cb null, parse-result(data.text, extract)
get-deposit-address-from-list = ({ amount, recipient, network },cb)->
    err, list <- get-masternode-list { network }
    return cb err if err?
    console.log err, list
    cb "Not Implemented"
get-deposit-address = ({ amount, recipient, network }, cb)->
    { mixing-info } = network?api ? {}
    return get-deposit-address-info { amount, recipient, network }, cb if typeof! mixing-info is \String
    get-deposit-address-from-list { amount, recipient, network }, cb
add-outputs-private = (config, cb)->
    { tx-type, rest, total, value, fee, tx, recipient, network } = config
    #return add-outputs-private config, cb if tx-type is \private
    o = network?tx-fee-options
    rest = total `minus` value `minus` fee
    fee2 = o?[fee-type] ? network.tx-fee ? 0
    amount = value `plus` fee `minus` fee2
    err, address <- get-deposit-address { recipient, amount, network }
    return cb err if err?
    tx.add-output address, +value
    tx.add-output account.address, +rest
    cb null
add-outputs = (config, cb)->
    { tx-type, rest, total, value, fee, tx, recipient } = config
    return add-outputs-private config, cb if tx-type is \private
    rest = total `minus` value `minus` fee
    tx.add-output recipient, +value
    tx.add-output account.address, +rest
    cb null
#recipient
export create-transaction = ({ network, account, recipient, amount, amount-fee, fee-type, tx-type}, cb)->
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
    return cb "Balance is not enough to send tx" if +((total `minus` fee) `minus` value) < 0
    return cb 'Total is NaN' if isNaN total
    tx = new BitcoinLib.TransactionBuilder network
    err <- add-outputs { tx-type, rest, total, value, fee, tx, recipient, network }
    return cb err if err?
    apply = (output, i)->
        tx.add-input output.txid, output.vout
    sign = (output, i)->
        key = BitcoinLib.ECPair.fromWIF(account.private-key, network)
        tx.sign i, key  
    outputs.for-each apply
    outputs.for-each sign
    rawtx = tx.build!.to-hex!
    cb null, { rawtx }
export push-tx = ({ network, rawtx, tx-type } , cb)-->
    send-type =
        | tx-type is \instant => \sendix
        | _ => \send
    err, res <- post "#{get-api-url network}/tx/#{send-type}", { rawtx } .end
    return cb err if err?
    cb null, res.body?txid
export get-balance = ({ address, network } , cb)->
    #err, node <- get-one-of-masternode { network }
    #console.log { err, node }
    #node.ip
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
export check-tx-status = ({ network, tx }, cb)->
    cb "Not Implemented"
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