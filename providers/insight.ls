require! {
    \moment
    \prelude-ls : { map, foldl, any, each, find, sum, filter, head, values, join }
    \./superagent.js : { get, post } 
    \../math.js : { plus, minus, div, times }
    \./deps.js : { BitcoinLib, bip39 }
    \../json-parse.js
    \../deadline.js
    \bs58 : { decode }
}
get-bitcoin-fullpair-by-index = (mnemonic, index, network)->
    #console.log \get-bitcoin-fullpair-by-index , mnemonic, index, network
    seed = bip39.mnemonic-to-seed-hex mnemonic
    hdnode = BitcoinLib.HDNode.from-seed-hex(seed, network).derive(index)
    address = hdnode.get-address!
    private-key = hdnode.key-pair.toWIF!
    public-key = hdnode.get-public-key-buffer!.to-string(\hex)
    { address, private-key, public-key }
#0.25m + 0.05m * numberOfInputs
#private send https://github.com/DeltaEngine/MyDashWallet/blob/master/Node/DashNode.cs#L18
#https://github.com/StaminaDev/dash-insight-api/blob/master/lib/index.js#L244
get-masternode-list = ({ network }, cb)->
    err, res <- get "#{get-api-url network}/masternodes/list" .timeout { deadline } .end
    return cb "cannot obtain list - err: #{err.message ? err}" if err?
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
get-enough = ([output, ...outputs], amount, you-have, cb)->
    return cb "Not Enough Funds (Unspent Outputs). You have #{you-have}" if not output?
    return cb "Expected output amount, got #{output.amount}" if not output.amount?
    output-amount = output.amount ? 0
    next-amount = amount `minus` output-amount
    return cb null, [output] if +next-amount <= 0
    you-have-next = you-have `plus` output-amount
    err, other <- get-enough outputs, next-amount, you-have-next
    return cb err if err?
    current =
        | +output-amount is 0 => []
        | _ => [output]
    all = current ++ other
    cb null, all    
calc-fee-per-byte = (config, cb)->
    { network, fee-type, account } = config
    o = network?tx-fee-options
    tx-fee = o?[fee-type] ? network.tx-fee ? 0
    return cb null, tx-fee if fee-type isnt \auto
    fee-type = \cheap
    amount-fee = o.cheap
    recipient = config.account.address
    #console.log { config.amount, amount-fee }
    err, data <- create-transaction { fee-type, amount-fee , recipient, ...config }
    return cb null, o.cheap if "#{err}".index-of("Not Enough Funds (Unspent Outputs)") > -1
    #console.log { err }
    return cb err, o.cheap if err?
    return cb "rawtx is expected" if typeof! data.rawtx isnt \String
    #console.log data.rawtx
    #bytes = decode(data.rawtx).to-string(\hex).length / 2
    bytes = data.rawtx.length / 2
    infelicity = 1
    calc-fee = (bytes + infelicity) `times` o.fee-per-byte
    final-price = 
        | calc-fee > +o.cheap => calc-fee
        | _ => o.cheap
    cb null, final-price
calc-dynamic-fee = ({ network, tx, tx-type, account, fee-type }, cb)->
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
get-calc-fee-func = (network)->
    | network?tx-fee-auto-mode is \per-byte => calc-fee-per-byte
    | _ => calc-dynamic-fee
calc-fee-private = (config, cb)->
    { network, tx, tx-type, account, fee-type } = config
    return cb "address cannot be empty" if (account?address ? "") is ""
    o = network?tx-fee-options
    calc-fee = get-calc-fee-func network
    err, tx-fee <- calc-fee config
    return cb err if err?
    err, outputs <- get-outputs { network, account.address }
    return cb err if err?
    number-of-inputs = if outputs.length > 0 then outputs.length else 1
    return cb "private-per-input is missing" if not o.private-per-input? 
    fee =
        (tx-fee `times` 2) `plus` (number-of-inputs `times` o.private-per-input)
    cb null, fee
calc-fee-instantx = ({ network, tx, tx-type, account, fee-type }, cb)->
    return cb "address cannot be empty" if (account?address ? "") is ""
    o = network?tx-fee-options
    calc-fee = get-calc-fee-func network
    err, tx-fee <- calc-fee { network, tx, tx-type, account, fee-type }
    return cb err if err?
    err, outputs <- get-outputs { network, account.address }
    return cb err if err?
    number-of-inputs = if outputs.length > 0 then outputs.length else 1
    return cb "instant-per-input is missing" if not o.instant-per-input? 
    fee =
        (number-of-inputs `times` o.instant-per-input)
    cb null, fee
export calc-fee = (config, cb)->
    { network, tx, tx-type, account } = config
    return calc-fee-private config, cb if tx-type is \private
    return calc-fee-instantx config, cb if tx-type is \instant
    calc-fee = get-calc-fee-func network
    calc-fee config, cb
export get-keys = ({ network, mnemonic, index }, cb)->
    result = get-bitcoin-fullpair-by-index mnemonic, index, network
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
#DEBUG
#mock = [{"address":"GbyU4HML1rX8gcdVB2dNfE4RszCwKFYuuv","txid":"2b598e790c06e106709ea230b4553e9b867f234aa6e84ad700f81efe68bb563e","vout":0,"scriptPubKey":"76a914c6df968d5d5e5103290559629f966c5efe6cfbfb88ac","amount":1,"satoshis":100000000,"height":275994,"confirmations":598},{"address":"GbyU4HML1rX8gcdVB2dNfE4RszCwKFYuuv","txid":"e815481a072b33390e0a2dad5df7ff1726c39d3542558e933f0aa475613c4145","vout":0,"scriptPubKey":"76a914c6df968d5d5e5103290559629f966c5efe6cfbfb88ac","amount":1,"satoshis":100000000,"height":275988,"confirmations":604},{"address":"GbyU4HML1rX8gcdVB2dNfE4RszCwKFYuuv","txid":"f9897905e569aed3067c532d5a1e11bd018a4b60231caf62c66db4e7ec9234c5","vout":1,"scriptPubKey":"76a914c6df968d5d5e5103290559629f966c5efe6cfbfb88ac","amount":0.00001,"satoshis":1000,"height":275987,"confirmations":605}]
get-outputs = ({ network, address} , cb)-->
    { url } = network.api
    err, data <- get "#{get-api-url network}/addr/#{address}/utxo" .timeout { deadline } .end
    return cb "cannot get outputs - err #{err.message ? err}" if err?
    #mock
    data.body
        |> each add-value network
        |> filter (.amount?)
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
    return cb "cannot get deposit info - err: #{err.message ? err}" if err?
    cb null, parse-result(data.text, extract)
get-deposit-address-from-list = ({ amount, recipient, network },cb)->
    err, list <- get-masternode-list { network }
    return cb err if err?
    #console.log err, list
    cb "Not Implemented"
get-deposit-address = ({ amount, recipient, network }, cb)->
    { mixing-info } = network?api ? {}
    return get-deposit-address-info { amount, recipient, network }, cb if typeof! mixing-info is \String
    get-deposit-address-from-list { amount, recipient, network }, cb
add-outputs-private = (config, cb)->
    { tx-type, total, value, fee, tx, recipient, network, account } = config
    #return add-outputs-private config, cb if tx-type is \private
    return cb "fee, value, total are required" if not fee? or not value? or not total?
    o = network?tx-fee-options
    rest = total `minus` value `minus` fee
    fee2 = o?[fee-type] ? network.tx-fee ? 0
    amount = value `plus` fee `minus` fee2
    err, address <- get-deposit-address { recipient, amount, network }
    return cb err if err?
    tx.add-output address, +value
    if +rest isnt 0
        tx.add-output account.address, +rest
    cb null
add-outputs = (config, cb)->
    { tx-type, total, value, fee, tx, recipient, account } = config
    return cb "fee, value, total are required" if not fee? or not value? or not total?
    return add-outputs-private config, cb if tx-type is \private
    rest = total `minus` value `minus` fee
    tx.add-output recipient, +value
    #console.log { rest }
    if +rest isnt 0
        tx.add-output account.address, +rest
    cb null
#recipient
get-error = (config, fields)->
    result =
        fields 
            |> filter -> not config[it]?
            |> map -> "#{it} is required field"
            |> join ", "
    return null if result is ""
    result
export create-transaction = (config, cb)->
    err = get-error config, <[ network account amount amountFee recipient ]>
    return cb err if err? 
    { network, account, recipient, amount, amount-fee, fee-type, tx-type} = config
    err, outputs <- get-outputs { network, account.address }
    return cb err if err?
    amount-with-fee = amount `plus` amount-fee
    err, outputs <- get-enough outputs, amount-with-fee, 0
    return cb err if err?
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
    #console.log { total, fee, value, outputs }
    return cb "Balance is not enough to send tx" if +((total `minus` fee) `minus` value) < 0
    return cb 'Total is NaN' if isNaN total
    tx = new BitcoinLib.TransactionBuilder network
    err <- add-outputs { tx-type, total, value, fee, tx, recipient, network, account }
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
    return cb "#{err}: #{res?text}" if err?
    cb null, res.body?txid
export get-total-received = ({ address, network }, cb)->
    return cb "Url is not defined" if not network?api?url?
    err, data <- get "#{get-api-url network}/addr/#{address}/totalReceived" .timeout { deadline } .end
    return cb err if err? or data.text.length is 0
    dec = get-dec network
    num = data.text `div` dec
    cb null, num
export get-unconfirmed-balance = ({ network, address} , cb)->
    return cb "Url is not defined" if not network?api?url?
    err, data <- get "#{get-api-url network}/addr/#{address}/unconfirmedBalance" .timeout { deadline } .end
    return cb err if err? or data.text.length is 0
    dec = get-dec network
    num = data.text `div` dec
    cb null, num
export get-balance = ({ address, network } , cb)->
    return cb "Url is not defined" if not network?api?url?
    err, data <- get "#{get-api-url network}/addr/#{address}/balance" .timeout { deadline } .end
    return cb err if err? or data.text.length is 0
    dec = get-dec network
    num = data.text `div` dec
    #return cb null, "2.00001"
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
    pending = t.confirmations is 0
    unspend =
        vout |> filter incoming-vout address
            |> head
    amount = unspend?value
    to = address
    from = t.vin.addr
    url = "#{net.api.url}/tx/#{tx}"
    #console.log(\insight-in, t)
    { network, tx, amount, fee, time, url, to, from, pending }
transform-out = ({ net, address }, t)->
    network = net.token
    tx = t.txid
    time = t.time
    fee = t.fees ? 0
    vout = t.vout ? []
    pending = t.confirmations is 0
    outcoming =
        vout 
            |> map outcoming-vouts address
            |> filter (?)
    amount =
        outcoming
            |> map (.value)
            |> foldl plus, 0
    to = outcoming.map(-> it.address).join(",")
    from = address
    url = "#{net.api.url}/tx/#{tx}"
    #console.log(\insight-out, t)
    { network, tx, amount, fee, time, url, to, pending, from }
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