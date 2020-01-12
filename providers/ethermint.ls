require! {
    \qs : { stringify }
    \prelude-ls : { filter, map, foldl, each }
    \../math.js : { plus, minus, times, div, from-hex }
    \./superagent.js : { get, post }
    #\web3 : \Web3
    \ethereumjs-tx : \Tx
    \ethereumjs-util : { BN }
    \../json-parse.js
    \../deadline.js
    \ethereumjs-wallet/hdkey
    \bip39
}
get-ethereum-fullpair-by-index = (mnemonic, index, network)->
    seed = bip39.mnemonic-to-seed(mnemonic)
    wallet = hdkey.from-master-seed(seed)
    w = wallet.derive-path("m0").derive-child(index).get-wallet!
    address = "0x" + w.get-address!.to-string(\hex)
    private-key = w.get-private-key-string!
    public-key = w.get-public-key-string!
    { address, private-key, public-key }
make-query = (network, method, params, cb)->
    { web3-provider } = network.api
    query = {
        jsonrpc : \2.0
        id : 1
        method
        params
    }
    err, data <- post web3-provider, query .end
    return cb "query err: #{err.message ? err}" if err?
    return cb data.body.error if data.body.error?
    cb null, data.body.result
export calc-fee = ({ network, fee-type, account, amount, to, data }, cb)->
    return cb null if fee-type isnt \auto
    dec = get-dec network
    err, gas-price <- calc-gas-price { fee-type, network }
    return cb err if err?
    value =
        | amount? => amount `times` dec
        | _ => 0
    #err, nonce <- get-nonce { account, network }
    #return cb err if err?
    data-parsed = 
        | data? => data
        | _ => '0x'
    from = account.address
    query = { from, to, data: data-parsed }
    err, estimate <- make-query network, \eth_estimateGas , [ query ]
    #err, estimate <- web3.eth.estimate-gas { from, nonce, to, data }
    return cb "estimate gas err: #{err.message ? err}" if err?
    res = gas-price `times` from-hex(estimate)
    #res = if +res1 is 0 then 21000 * 8 else res1
    val = res `div` dec
    cb null, val
export get-keys = ({ network, mnemonic, index }, cb)->
    result = get-ethereum-fullpair-by-index mnemonic, index, network
    cb null, result
round = (num)->
    Math.round +num
to-hex = ->
    new BN(it)
transform-tx = (network, t)-->
    { url } = network.api
    dec = get-dec network
    network = \eth
    tx = t.hash
    amount = t.value `div` dec
    time = t.time-stamp
    url = "#{url}/tx/#{tx}"
    fee = t.cumulative-gas-used `times` t.gas-price `div` dec
    { network, tx, amount, fee, time, url, t.from, t.to }
export get-transactions = ({ network, address }, cb)->
    { api-url } = network.api
    module = \account
    action = \txlist
    startblock = 0
    endblock = 99999999
    sort = \asc
    apikey = \4TNDAGS373T78YJDYBFH32ADXPVRMXZEIG
    query = stringify { module, action, apikey, address, sort, startblock, endblock }
    err, resp <- get "#{api-url}?#{query}" .timeout { deadline } .end
    return cb "cannot execute query - err #{err.message ? err }" if err?
    err, result <- json-parse resp.text
    return cb "cannot parse json: #{err.message ? err}" if err?
    return cb "Unexpected result" if typeof! result?result isnt \Array
    txs = 
        result.result |> map transform-tx network
    #console.log api-url, result.result, txs
    cb null, txs
#get-web3 = (network)->
#    { web3-provider } = network.api
#    new Web3(new Web3.providers.HttpProvider(web3-provider))
get-dec = (network)->
    { decimals } = network
    10^decimals
calc-gas-price = ({ fee-type, network }, cb)->
    return cb null, \3000000000 if fee-type is \cheap
    #err, price <- web3.eth.get-gas-price
    err, price <- make-query network, \eth_gasPrice , []
    return cb "calc gas price - err: #{err.message ? err}" if err?
    price = from-hex(price)
    return cb null, 8 if +price is 0
    cb null, price
try-get-lateest = ({ network, account }, cb)->
    err, nonce <- make-query network, \eth_getTransactionCount , [ account.address, "latest" ]
    return cb "cannot get nonce (latest) - err: #{err.message ? err}" if err?
    next = +from-hex(nonce)
    cb null, next
get-nonce = ({ network, account }, cb)->
    #err, nonce <- web3.eth.get-transaction-count 
    err, nonce <- make-query network, \eth_getTransactionCount , [ account.address, \pending ]
    return try-get-lateest { network, account }, cb if err? and "#{err.message ? err}".index-of('not implemented') > -1
    return cb "cannot get nonce (pending) - err: #{err.message ? err}" if err?
    cb null, from-hex(nonce)
is-address = (address) ->
    if not //^(0x)?[0-9a-f]{40}$//i.test address
        false
    else
        true
export create-transaction = ({ network, account, recipient, amount, amount-fee, data, fee-type, tx-type} , cb)-->
    #console.log \tx, { network, account, recipient, amount, amount-fee, data, fee-type, tx-type}
    dec = get-dec network
    return cb "address in not correct ethereum address" if not is-address recipient
    private-key = new Buffer account.private-key.replace(/^0x/,''), \hex
    err, nonce <- get-nonce { account, network }
    return cb err if err?
    to-wei = -> it `times` dec
    to-eth = -> it `div` dec
    value = to-wei amount
    err, gas-price <- calc-gas-price { fee-type, network }
    return cb err if err?
    gas-estimate =
        |  +gas-price is 0 => 0
        | _ => round(to-wei(amount-fee) `div` gas-price)
    err, balance <- make-query network, \eth_getBalance , [ account.address, \latest ]
    return cb err if err?
    balance-eth = to-eth balance
    to-send = amount `plus` amount-fee
    return cb "Balance #{balance-eth} is not enough to send tx #{to-send}" if +balance-eth < +to-send
    #gas-estimate = 21000
    #nonce = 0
    #console.log { nonce, gas-price, value, gas-estimate, recipient, account.address, data }
    tx = new Tx do
        nonce: to-hex nonce
        gas-price: to-hex gas-price
        value: to-hex value
        gas: to-hex gas-estimate
        to: recipient
        from: account.address
        data: data ? "0x"
    tx.sign private-key
    rawtx = \0x + tx.serialize!.to-string \hex
    cb null, { rawtx }
export check-decoded-data = (decoded-data, data)->
    return no if not (decoded-data ? "").length is 0
    return no if not (data ? "").length is 0
export push-tx = ({ network, rawtx } , cb)-->
    err, txid <- make-query network, \eth_sendRawTransaction , [ rawtx ]
    #err, txid <- web3.eth.send-signed-transaction rawtx
    return cb "cannot get signed tx - err: #{err.message ? err}" if err?
    cb null, txid
export check-tx-status = ({ network, tx }, cb)->
    cb "Not Implemented"
export get-total-received = ({ address, network }, cb)->
    err, txs <- get-transactions { address, network }
    total =
        txs |> filter (-> it.to.to-upper-case! is address.to-upper-case!)
            |> map (.amount)
            |> foldl plus, 0
    cb null, total
export get-unconfirmed-balance = ({ network, address} , cb)->
    err, number <- make-query network, \eth_getBalance , [ address, \pending ]
    return cb err if err?
    #err, number <- web3.eth.get-balance address
    #return cb "cannot get balance - err: #{err.message ? err}" if err?
    dec = get-dec network
    balance = number `div` dec
    cb null, balance
export get-balance = ({ network, address} , cb)->
    err, number <- make-query network, \eth_getBalance , [ address, \latest ]
    return cb err if err?
    #err, number <- web3.eth.get-balance address
    #return cb "cannot get balance - err: #{err.message ? err}" if err?
    dec = get-dec network
    balance = number `div` dec
    cb null, balance