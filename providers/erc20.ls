require! {
    \qs : { stringify }
    \prelude-ls : { filter, map, foldl, each }
    \../math.js : { plus, minus, times, div }
    \superagent : { get }
    \web3 : \Web3
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
abi = [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]
get-contract-instance = (web3, addr)->
    | typeof! web3.eth.contract is \Function => web3.eth.contract(abi).at(addr)
    | _ => new web3.eth.Contract(abi, addr)
is-address = (address) ->
    if not //^(0x)?[0-9a-f]{40}$//i.test address
        false
    else
        true
export calc-fee = ({ network, tx, fee-type, account, amount, to, data }, cb)->
    return cb null if fee-type isnt \auto
    web3 = get-web3 network
    err, gas-price <- calc-gas-price { web3, fee-type }
    return cb err if err?
    err, nonce <- web3.eth.get-transaction-count account.address, \pending
    return cb err if err?
    from = account.address
    err, estimate <- web3.eth.estimate-gas { from, nonce, to, data }
    return cb err if err?
    dec = get-dec network
    res = gas-price `times` estimate
    val = res `div` (10^18)
    cb null, val
export get-keys = ({ network, mnemonic, index }, cb)->
    result = get-ethereum-fullpair-by-index mnemonic, index, network
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
up = (s)->
    (s ? "").to-upper-case!
export get-transactions = ({ network, address }, cb)->
    { api-url } = network.api
    module = \account
    action = \tokentx
    startblock = 0
    endblock = 99999999
    sort = \asc
    apikey = \4TNDAGS373T78YJDYBFH32ADXPVRMXZEIG
    query = stringify { module, action, apikey, address, sort, startblock, endblock }
    err, resp <- get "#{api-url}?#{query}" .timeout { deadline } .end
    return cb err if err?
    err, result <- json-parse resp.text
    return cb err if err?
    return cb "Unexpected result" if typeof! result?result isnt \Array
    txs = 
        result.result 
            |> filter -> up(it.contract-address) is up(network.address)
            |> map transform-tx network
    cb null, txs
get-web3 = (network)->
    { web3-provider } = network.api
    new Web3(new Web3.providers.HttpProvider(web3-provider))
get-dec = (network)->
    { decimals } = network
    10^decimals
calc-gas-price = ({ web3, fee-type }, cb)->
    return cb null, \3000000000 if fee-type is \cheap
    web3.eth.get-gas-price cb
round = (num)->
    Math.round +num
export create-transaction = ({ network, account, recipient, amount, amount-fee, fee-type, tx-type} , cb)-->
    return cb "address in not correct ethereum address" if not is-address recipient
    web3 = get-web3 network
    dec = get-dec network
    private-key = new Buffer account.private-key.replace(/^0x/,''), \hex
    err, nonce <- web3.eth.get-transaction-count account.address, \pending
    return cb err if err?
    return cb "nonce is required" if not nonce?
    contract = get-contract-instance web3, network.address
    to-wei = -> it `times` dec
    to-wei-eth = -> it `times` (10^18)
    to-eth = -> it `div` (10^18)
    value = to-wei amount
    err, gas-price-bn <- calc-gas-price { web3, fee-type }
    #gas-price = round (gas-price-bn `plus` ( gas-price-bn `div` 100 ))
    gas-price = gas-price-bn.to-fixed!
    return cb err if err?
    gas-minimal = to-wei-eth(amount-fee) `div` gas-price
    gas-estimate = round ( gas-minimal `times` 5 )
    #console.log { gas-estimate, amount-fee }, gas-price.to-fixed!
    return cb "getBalance is not a function" if typeof! web3.eth.get-balance isnt \Function
    err, balance <- web3.eth.get-balance account.address
    return cb err if err?
    balance-eth = to-eth balance
    return cb "Balance is not enough to send tx" if +balance-eth < +amount-fee
    err, erc-balance <- get-balance { network, account.address }
    return cb err if err?
    return cb "Balance is not enough to send this amount" if +erc-balance < +amount
    data = 
        | contract.methods? => contract.methods.transfer(recipient, value).encodeABI!
        | _ => contract.transfer.get-data recipient, value
    console.log \tx-build, { nonce, gas-price, gas-estimate, to: network.address, account.address, data }
    tx = new Tx do
        nonce: to-hex nonce
        gas-price: to-hex gas-price
        value: to-hex "0"
        gas: to-hex gas-estimate
        to: network.address
        from: account.address
        data: data
    console.log \sign
    tx.sign private-key
    rawtx = \0x + tx.serialize!.to-string \hex
    cb null, { rawtx }
export check-decoded-data = (decoded-data, data)->
    return no if not (decoded-data ? "").length is 0
    return no if not (data ? "").length is 0
export push-tx = ({ network, rawtx } , cb)-->
    web3 = get-web3 network
    send = web3.eth.send-raw-transaction ? web3.eth.send-signed-transaction
    console.log \push-tx
    err, txid <- send rawtx
    console.log { err, txid }
    cb err, txid
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
    cb "Not Implemented"
export get-balance = ({ network, address} , cb)->
    web3 = get-web3 network
    contract = get-contract-instance web3, network.address
    balance-of =
        | contract.methods? => (address, cb)-> contract.methods.balance-of(address).call cb
        | _ => (address, cb)-> contract.balance-of address, cb
    err, number <- balance-of address
    return cb err if err?
    dec = get-dec network
    balance = number `div` dec
    cb null, balance