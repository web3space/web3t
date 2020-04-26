require! {
    \qs : { stringify }
    \prelude-ls : { filter, map, foldl, each }
    \../math.js : { plus, minus, times, div, from-hex }
    \./superagent.js : { get, post }
    \./deps.js : { Web3, Tx, BN, hdkey, bip39 }
    \../json-parse.js
    \../deadline.js
    \bs58 : { decode, encode }
    \ethereumjs-common : { default: Common }
    \../addresses.js : { vlxToEth, ethToVlx }
}
isChecksumAddress = (address) ->
    address = address.replace '0x', ''
    addressHash = sha3 address.toLowerCase!
    i = 0
    while i < 40
        return false if (parseInt addressHash[i], 16) > 7 and address[i].toUpperCase! isnt address[i] or (parseInt addressHash[i], 16) <= 7 and address[i].toLowerCase! isnt address[i]
        i++
    true
isAddress = (address) ->
    if not //^(0x)?[0-9a-f]{40}$//i.test address
        false
    else
        if (//^(0x)?[0-9a-f]{40}$//.test address) or //^(0x)?[0-9A-F]{40}$//.test address then true else isChecksumAddress address
to-velas-address = (eth-address-buffer)->
    #return cb "eth-address is not correct" if isAddress eth-address
    s1 = encode eth-address-buffer
    "V#{s1}"
to-eth-address = (velas-address, cb)->
    return cb "required velas-address as a string" if typeof! velas-address isnt \String
    return cb null, velas-address if isAddress velas-address
    return cb "velas address can be started with V" if velas-address.0 isnt \V
    #NEW_ADDRESS
    return cb null, vlxToEth(velas-address)
    bs58str = velas-address.substr(1, velas-address.length)
    try 
        bytes = decode bs58str
        hex = bytes.toString('hex')
        eth-address = \0x + hex
        #return cb "incorrect velas address" if not isAddress eth-address
        cb null, eth-address
    catch err
        cb err
window.to-eth-address = vlxToEth if window?
window.to-velas-address = ethToVlx if window?
get-ethereum-fullpair-by-index = (mnemonic, index, network)->
    seed = bip39.mnemonic-to-seed(mnemonic)
    wallet = hdkey.from-master-seed(seed)
    w = wallet.derive-path("m0").derive-child(index).get-wallet!
    #NEW_ADDRESS
    address = ethToVlx w.get-address!.to-string(\hex)
    #address = to-velas-address w.get-address! #.to-string(\hex)
    private-key = w.get-private-key-string!
    public-key = w.get-public-key-string!
    { address, private-key, public-key }
try-parse = (data, cb)->
    return cb null, data if typeof! data.body is \Object
    try 
        console.log \try-parse, data.text, JSON.parse
        data.body = JSON.parse data.text
        cb null, data
    catch err
        console.log \parse-err, err
        cb err
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
    err, data <- try-parse data
    return cb err if err?
    return cb "expected object" if typeof! data.body isnt \Object
    return cb data.body.error if data.body?error?
    cb null, data.body.result
export get-transaction-info = (config, cb)->
    { network, tx } = config
    query = [tx]
    err, info <- make-query network, \eth_getTransactionReceipt , query
    return cb err if err?
    tx = info?result
    return cb "expected result" if typeof! tx isnt \Object
    status = 
        | tx.status is \0x1 => \confirmed
        | _ => \pending
    result = { tx.from, tx.to, status, info: tx }
    cb null, result
get-gas-estimate = ({ network, query, gas }, cb)->
    return cb null, gas if gas?
    err, estimate <- make-query network, \eth_estimateGas , [ query ]
    #err, estimate <- web3.eth.estimate-gas { from, nonce, to, data }
    return cb null, 1000000 if err?
    cb null, from-hex(estimate)
export calc-fee = ({ network, fee-type, account, amount, to, data, gas-price, gas }, cb)->
    #console.log \calc-fee, { network, fee-type, account, amount, to, data }
    return cb null if typeof! to isnt \String or to.length is 0
    return cb null if fee-type isnt \auto
    dec = get-dec network
    err, gas-price <- calc-gas-price { fee-type, network, gas-price }
    return cb err if err?
    data-parsed = 
        | data? => data
        | _ => '0x'
    err, from <- to-eth-address account.address
    return cb err if err?
    err, to <- to-eth-address to
    return cb err if err?
    query = { from, to, data: data-parsed }
    err, estimate <- get-gas-estimate { network, query, gas }
    return cb err if err?
    #return cb "estimate gas err: #{err.message ? err}" if err?
    res = gas-price `times` estimate
    #res = if +res1 is 0 then 21000 * 8 else res1
    val = res `div` dec
    #console.log { gas-price, res, val }
    #min = 0.002
    #return cb null, min if +val < min
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
    err, address <- to-eth-address address
    return cb err if err?
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
calc-gas-price = ({ fee-type, network, gas-price }, cb)->
    return cb null, gas-price if gas-price?
    return cb null, 22000 if fee-type is \cheap
    #err, price <- web3.eth.get-gas-price
    err, price <- make-query network, \eth_gasPrice , []
    return cb "calc gas price - err: #{err.message ? err}" if err?
    price = from-hex(price)
    return cb null, 22000 if +price is 0
    cb null, price
try-get-lateest = ({ network, account }, cb)->
    err, address <- to-eth-address account.address
    return cb err if err?
    err, nonce <- make-query network, \eth_getTransactionCount , [ address, "latest" ]
    return cb "cannot get nonce (latest) - err: #{err.message ? err}" if err?
    next = +from-hex(nonce)
    cb null, next
get-nonce = ({ network, account }, cb)->
    #err, nonce <- web3.eth.get-transaction-count 
    err, address <- to-eth-address account.address
    return cb err if err?
    err, nonce <- make-query network, \eth_getTransactionCount , [ address, \pending ]
    return try-get-lateest { network, account }, cb if err? and "#{err.message ? err}".index-of('not implemented') > -1
    return cb "cannot get nonce (pending) - err: #{err.message ? err}" if err?
    cb null, from-hex(nonce)
is-address = (address) ->
    if not //^(0x)?[0-9a-f]{40}$//i.test address
        false
    else
        true
export create-transaction = ({ network, account, recipient, amount, amount-fee, data, fee-type, tx-type, gas-price, gas } , cb)-->
    #console.log \tx, { network, account, recipient, amount, amount-fee, data, fee-type, tx-type}
    console.log \tx, gas, gas-price
    dec = get-dec network
    err, recipient <- to-eth-address recipient
    return cb err if err?
    return cb "address in not correct ethereum address" if not is-address recipient
    private-key = new Buffer account.private-key.replace(/^0x/,''), \hex
    err, nonce <- get-nonce { account, network }
    return cb err if err?
    to-wei = -> it `times` dec
    to-eth = -> it `div` dec
    value = to-wei amount
    err, gas-price <- calc-gas-price { fee-type, network, gas-price }
    return cb err if err?
    err, address <- to-eth-address account.address
    return cb err if err?
    err, balance <- make-query network, \eth_getBalance , [ address, \latest ]
    return cb err if err?
    balance-eth = to-eth balance
    to-send = amount `plus` amount-fee
    return cb "Balance #{balance-eth} is not enough to send tx #{to-send}" if +balance-eth < +to-send
    gas-estimate =
        |  gas? => gas
        |  +gas-price is 0 => 21000
        | _ => round(to-wei(amount-fee) `div` gas-price)
    err, networkId <- make-query network, \net_version , []
    return cb err if err?
    common = Common.forCustomChain 'mainnet', { networkId }
    tx-obj = {
        nonce: to-hex nonce
        gas-price: to-hex gas-price
        value: to-hex value
        gas: to-hex gas-estimate
        to: recipient
        from: address
        data: data ? ""
    }
    tx = new Tx tx-obj, { common }
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
    err, address <- to-eth-address account.address
    return cb err if err?
    total =
        txs |> filter (-> it.to.to-upper-case! is address.to-upper-case!)
            |> map (.amount)
            |> foldl plus, 0
    cb null, total
export get-unconfirmed-balance = ({ network, address} , cb)->
    err, address <- to-eth-address address
    return cb err if err?
    err, number <- make-query network, \eth_getBalance , [ address, \pending ]
    return cb err if err?
    #err, number <- web3.eth.get-balance address
    #return cb "cannot get balance - err: #{err.message ? err}" if err?
    dec = get-dec network
    balance = number `div` dec
    cb null, balance
export get-balance = ({ network, address} , cb)->
    #return cb null, 0
    #console.log \address, address
    err, address <- to-eth-address address
    #console.log \address, address, err
    return cb err if err?
    err, number <- make-query network, \eth_getBalance , [ address, \latest ]
    return cb err if err?
    #err, number <- web3.eth.get-balance address
    #return cb "cannot get balance - err: #{err.message ? err}" if err?
    dec = get-dec network
    balance = number `div` dec
    cb null, balance
#console.log \test
#to-eth-address "VADyNxJR9PjWrQzJVmoaKxqaS8Mk", console.log
#console.log to-velas-address Buffer.from("0b6a35fafb76e0786db539633652a8553ac28d67", 'hex')
#
#
#
# SERVICE
#
#
#
#
export get-sync-status = ({ network }, cb)->
    err, estimate <- make-query network, \eth_getSyncing , [ ]
    return cb err if err?
    return cb null, estimate
export get-peer-count = ({ network }, cb)->
    err, estimate <- make-query network, \net_getPeerCount , [ ]
    return cb err if err?
    return cb null, estimate