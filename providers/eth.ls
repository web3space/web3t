require! {
    \qs : { stringify }
    \prelude-ls : { filter, map, foldl, each }
    \../math.ls : { plus, minus, times, div, from-hex }
    \superagent : { get, post }
    #\web3 : \Web3
    \ethereumjs-tx : \Tx
    \ethereumjs-util : { BN }
    \../json-parse.ls
    \whitebox : { get-fullpair-by-index }
    \../deadline.ls
}
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
    console.log \p0
    err, gas-price <- calc-gas-price { fee-type, network }
    return cb err if err?
    value =
        | amount? => amount `times` dec
        | _ => 0
    #err, nonce <- get-nonce { account, network }
    #return cb err if err?
    data-parsed = 
        | data? => data
        | _ => ''
    from = account.address
    query = { from, to, data: data-parsed }
    err, estimate <- make-query network, \eth_estimateGas , [ query ]
    #err, estimate <- web3.eth.estimate-gas { from, nonce, to, data }
    return cb "estimate gas err: #{err.message ? err}" if err?
    res = gas-price `times` from-hex(estimate)
    val = res `div` dec
    cb null, val
export get-keys = ({ network, mnemonic, index }, cb)->
    result = get-fullpair-by-index mnemonic, index, network
    cb null, result
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
    cb null, from-hex(price)
get-nonce = ({ network, account }, cb)->
    #err, nonce <- web3.eth.get-transaction-count 
    err, nonce <- make-query network, \eth_getTransactionCount , [ account.address, \pending ]
    return cb "cannot get nonce - err: #{err.message ? err}" if err?
    cb null, from-hex(nonce)
export create-transaction = ({ network, account, recipient, amount, amount-fee, data, fee-type, tx-type} , cb)-->
    dec = get-dec network
    private-key = new Buffer account.private-key.replace(/^0x/,''), \hex
    err, nonce <- get-nonce { account, network }
    return cb err if err?
    to-wei = -> it `times` dec
    to-eth = -> it `div` dec
    value = to-wei amount
    err, gas-price <- calc-gas-price { fee-type, network }
    return cb err if err?
    gas-estimate = to-wei(amount-fee) `div` gas-price
    err, balance <- make-query network, \eth_getBalance , [ account.address, \latest ]
    return cb err if err?
    balance-eth = to-eth balance
    to-send = amount `plus` amount-fee
    return cb "Balance #{balance-eth} is not enough to send tx #{to-send}" if +balance-eth < +to-send
    tx = new Tx do
        nonce: to-hex nonce
        gas-price: to-hex gas-price
        value: to-hex value
        gas: to-hex gas-estimate
        to: recipient
        from: account.address
        data: data ? ""
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
export get-balance = ({ network, address} , cb)->
    err, number <- make-query network, \eth_getBalance , [ address, \latest ]
    return cb err if err?
    #err, number <- web3.eth.get-balance address
    #return cb "cannot get balance - err: #{err.message ? err}" if err?
    dec = get-dec network
    balance = number `div` dec
    cb null, balance