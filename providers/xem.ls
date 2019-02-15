require! {
    \nem-sdk : { default: nem }
    \superagent : { get }
    \../json-parse.ls
    \prelude-ls : { filter, map, head }
    \../math.ls : { minus, div }
    \../deadline.ls
}
export calc-fee = ({ network, tx }, cb)->
    cb null
export get-keys = ({ network, mnemonic, index }, cb)->
    private-key = nem.crypto.helpers.derive-pass-sha(mnemonic, 6000).priv
    kp = nem.crypto.key-pair.create nem.utils.helpers.fix-private-key private-key
    address = nem.model.address.to-address kp.public-key.to-string!, network.id
    cb null, { address, private-key }
transform-transfer = (network, tx)-->
    amount = tx.amount `div` (network.decimals ^ 10)
    fee = tx.fee `div` (network.decimals ^ 10)
    time = tx.timestamp_unix
    to = tx.r_printablekey
    from = tx.s_printablekey
    url = "#{network.api.url}/transfer/#{tx.id}"
    { network, tx: tx.id, amount, fee, time, url, from, to }
export get-transactions = ({ network, address }, cb)->
    err, data <- get "#{network.api.api-url}/account?address=#{address}" .timeout { deadline } .end
    return cb err if err?
    err, result <- json-parse data.text
    return cb null, [] if not result.raw?
    return cb err if err?
    err, data <- get "#{network.api.api-url}/account_transactions?id=#{result.raw.id}&iid=0" .timeout { deadline } .end
    return cb err if err?
    err, result <- json-parse data.text
    return cb err if err?
    txs =
        result.transfers
            |> map transform-transfer network
    cb null, txs
export create-transaction = ({ network, account, recepient, amount, amount-fee, data, message-type, fee-type} , cb)-->
    return cb "Params are required" if not network? or not account? or not recepient? or not amount-fee?
    common = nem.model.objects.create(\common) "", account.private-key
    transfer-transaction = nem.model.objects.get \transferTransaction
    transfer-transaction.amount = amount
    transfer-transaction.message = data ? ""
    transfer-transaction.recipient = recepient
    transfer-transaction.is-multisig = no 
    transfer-transaction.multisig-account = ""
    transfer-transaction.message-type = message-type ? 0
    transaction-entity = nem.model.transactions.prepare(\transferTransaction)(common, transfer-transaction, network.id)
    kp = nem.crypto.key-pair.create nem.utils.helpers.fix-private-key account.private-key
    serialized = nem.utils.serialization.serialize-transaction transaction-entity
    signature = kp.sign serialized
    result =
        data : nem.utils.convert.ua2hex serialized
        signature : signature.to-string!
    rawtx = JSON.stringify result
    cb null, { rawtx }
export push-tx = ({ network, rawtx } , cb)-->
    endpoint = nem.model.objects.create(\endpoint) network.api.node-address, network.api.node-port
    success = (res)->
        return cb res.message if res.code >= 2
        cb null, res?transaction-hash?data
    failed = (res)->
        cb res
    nem.com.requests.transaction.announce endpoint, rawtx .then success, failed
export get-balance = ({ network, address } , cb)->
    err, data <- get "#{network.api.api-url}/account?address=#{address}" .timeout { deadline } .end
    return cb err if err?
    err, result <- json-parse data.text
    return cb err if err?
    return cb null, "0" if not result.raw?
    input =
        result.raw.balance
            |> filter (.type is 1)
            |> map (.sum)
            |> head
    output =
        result.raw.balance
            |> filter (.type is 2) 
            |> map (.sum)
            |> head
    return cb null, "0" if not input?
    saldo = input `minus` (output ? 0)
    print = saldo `div` (10^6)
    cb null, print