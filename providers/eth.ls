require! {
    \qs : { stringify }
    \prelude-ls : { filter, map, foldl, each }
    \../math.ls : { plus, minus, times, div }
    \superagent : { get }
    \web3 : \Web3
    \ethereumjs-tx : \Tx
    \ethereumjs-util : { BN }
    \../json-parse.ls
    \whitebox : { get-fullpair-by-index }
}
export calc-fee = ({ network, tx }, cb)->
    cb null
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
    err, resp <- get "#{api-url}?#{query}" .end
    return cb err if err?
    err, result <- json-parse resp.text
    return cb err if err?
    return cb "Unexpected result" if typeof! result?result isnt \Array
    txs = 
        result.result |> map transform-tx network
    cb null, txs
get-web3 = (network)->
    { web3-provider } = network.api
    new Web3(new Web3.providers.HttpProvider(web3-provider))
get-dec = (network)->
    { decimals } = network
    10^decimals
export create-transaction = ({ network, account, recepient, amount, amount-fee, data} , cb)-->
    web3 = get-web3 network
    dec = get-dec network
    
    private-key = new Buffer account.private-key.replace(/^0x/,''), \hex
    err, nonce <- web3.eth.get-transaction-count account.address, \pending
    to-wei = -> it `times` dec
    value = to-wei amount
    err, gas-price <- web3.eth.get-gas-price
    #gas-price = to-wei \0.000000004
    #console.log { gas-price } 
    #calc-fee { network }
    gas-estimate = to-wei(amount-fee) `div` gas-price
    #send = (value `plus` gas-price `plus` gas-estimate) `div` dec
    #console.log { value, amount }
    tx = new Tx do
        nonce: to-hex nonce
        gas-price: to-hex gas-price
        value: to-hex value
        gas: to-hex gas-estimate
        to: recepient
        from: account.address
        data: data ? ""
    tx.sign private-key
    rawtx = \0x + tx.serialize!.to-string \hex
    cb null, { rawtx }
export check-decoded-data = (decoded-data, data)->
    return no if not (decoded-data ? "").length is 0
    return no if not (data ? "").length is 0
export push-tx = ({ network, rawtx } , cb)-->
    web3 = get-web3 network
    err, txid <- web3.eth.send-signed-transaction rawtx
    cb err, txid
export get-balance = ({ network, address} , cb)->
    #console.log { network }
    web3 = get-web3 network
    err, number <- web3.eth.get-balance address
    return cb err if err?
    dec = get-dec network
    balance = number `div` dec
    cb null, balance