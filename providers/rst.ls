require! {
    \./eth.js
    \../math.js : { plus, minus, times, div, from-hex }
    \ethers : { utils } 
}
is-address = (address) ->
    if not //^(0x)?[0-9a-f]{40}$//i.test address
        false
    else
        if (//^(0x)?[0-9a-f]{40}$//.test address) or //^(0x)?[0-9A-F]{40}$//.test address then true else isChecksumAddress address
is-checksum-address = (address) ->
    address = address.replace '0x', ''
    addressHash = sha3 address.toLowerCase!
    i = 0
    while i < 40
        return false if (parseInt addressHash[i], 16) > 7 and address[i].toUpperCase! isnt address[i] or (parseInt addressHash[i], 16) <= 7 and address[i].toLowerCase! isnt address[i]
        i++
    true
toHexString = (byteArray) -> (Array.from byteArray, (byte) -> ('0' + (byte .&. 255).toString 16).slice -2).join ''
string-to-hex = (str)->
    str
        |> utils.toUtf8Bytes 
        |> toHexString
        |> -> "0x#{it}"
calc-fee = ({ network, fee-type, account, amount, to, data }, cb)->
    return cb null, 0 if is-address to
    return cb null, 0 if network.tx-fee-options?withdraw is 0
    return cb "unsupported tx option" if network.tx-fee-options?withdraw isnt "50 + 2%"
    fixed = 50
    return cb null, fixed if +amount is 0
    def = fixed `plus` ((amount `div` 100) `times` 2)
    #return cb null, def if (to ? "").length is 0
    cb null, def
    #err, api <- get-api network.private-key
    #return cb err if err?
    #err, fee <- api.check-comission to
    #return cb err if err?
    #res = 
    #    | fee.rate? => (amount `div` 100) `times` fee.rate
    #    | _ => fee.fixed
    #cb null, res
create-transaction = (config , cb)-->
    #console.log \create-transaction, config
    return cb "config.recipient is required" if not config.recipient?
    { recipient } = config
    recipient =
        | is-address config.recipient => config.recipient
        | _ => config.account.address
    data =
        | is-address config.recipient => config.data
        | _ => string-to-hex config.recipient
    eth.create-transaction { ...config, recipient, data }, cb
module.exports = { ...eth, create-transaction, calc-fee }  