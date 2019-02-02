require! {
    \qs : { stringify }
    \prelude-ls : { filter, map, foldl, each, find }
    \../math.ls : { plus, minus, times, div }
    \superagent : { get, post }
    \web3 : \Web3
    \ethereumjs-tx : \Tx
    \ethereumjs-util : { BN }
    \../json-parse.ls
    \whitebox : { get-fullpair-by-index }
}
# https://api.omniexplorer.info/#request-v1-address-addr
export calc-fee = ({ network, tx }, cb)->
    cb null
export get-keys = ({ network, mnemonic, index }, cb)->
    result = get-fullpair-by-index mnemonic, index, network
    cb null, result
to-hex = ->
    new BN(it)
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
extend = (str, fixed)->
    return str if str.length >= fixed
    extend "0#{str}"
to-hex = (num, fixed)->
    n = (+num).to-string 16
    extend n, min
export create-transaction = ({ network, account, recepient, amount, amount-fee}, cb)->
    #err, outputs <- get-outputs { network, account.address }
    #return cb err if err?
    #return cb 'Not Enough Funds (Unspent Outputs)' if outputs.length is 0
    #is-no-value =
    #    outputs |> find (-> !it.value?)
    #return cb 'Each output should have a value' if is-no-value
    dec = get-dec network
    value = amount `times` dec
    fee = amount-fee `times` dec
    total = 
        outputs
            |> map (.value)
            |> sum
    return cb 'Total is NaN' if isNaN total
    tx = new BitcoinLib.TransactionBuilder network
    simple_send =
        * "6f6d6e69" # omni
        * to-hex 0, 4
        * to-hex network.propertyid, 12
        * to-hex value, 16
    data = Buffer.from simple_send.join(''), \hex
    omni-output = BitcoinLib.script.compile [bitcoin.opcodes.OP_RETURN, data]
    rest = total `minus` value `minus` fee
    tx.add-output recepient, +value
    tx.add-output omni-output, 0
    tx.add-output account.address, +rest
    #apply = (output, i)->
    #    tx.add-input output.txid, output.vout
    sign = (output, i)->
        key = BitcoinLib.ECPair.fromWIF account.private-key, network
        tx.sign i, key  
    #outputs.for-each apply
    outputs.for-each sign
    rawtx = tx.build!.to-hex!
    cb null, { rawtx }
transform-tx = ({ network, address }, t)-->
    { url } = network.api
    network = \usdt 
    dec = get-dec network
    tx = t.txid
    amount = t.amount `div` dec
    time = t.blocktime
    url = "#{url}/tx/#{tx}"
    fee = t.fee `div` dec
    from = 
        | t.ismine is yes => address
        | _ => t.sendingaddress
    to =
        | t.ismine is no => t.sendingaddress
        | _ => address
    { network, tx, amount, fee, time, url, t.from, t.to }
export get-transactions = ({ network, address }, cb)->
    { api-url } = network.api
    req =
        addr : address
    err, data <- post("#{api-url}/v1/address/addr/details/", req).type('form').end
    return cb err if err?
    return cb "expected object" if typeof! data isnt \Object
    return cb "expected array" if data.body.transactions isnt \Array
    txs =
         data.body.transactions
            |> filter (.propertyid is network.propertyid)
            |> map transform-tx { network, address }
    cb null, txs
get-dec = (network)->
    { decimals } = network
    10^decimals
export check-decoded-data = (decoded-data, data)->
    cb null, ''
export push-tx = ({ network, rawtx } , cb)-->
    { api-url } = network.api
    req =
        signed-transaction : rawtx
    err, data <- post("#{api-url}/v1/transaction/pushtx/", req).type('form').end
    return cb err if err?
    return cb "expected object" if typeof! data isnt \Object
    return cb "status isnt OK" if data.body.status isnt 'ok'
    return cb "not pusshed" if data.body.pusshed isnt 'pushed'
    cb null, data.body.tx
export get-balance = ({ network, address} , cb)->
    { api-url } = network.api
    req =
        addr : address
    err, data <- post("#{api-url}/v1/address/addr/", req).type('form').end
    return cb err if err?
    return cb "expected object" if typeof! data isnt \Object
    return cb "expected balance array. got #{data.text}" if typeof! data.body.balance isnt \Array
    balance =
        data.body.balance |> find (.id is network.propertyid)
    #console.log { balance, network.propertyid }
    return cb null, "0" if not balance?
    dec = get-dec network
    value = balance.value `div` dec
    cb null, value