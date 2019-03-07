require! {
    \superagent
    \ripple-keypairs : { derive-keypair, derive-address, generate-seed }
    \big.js : big
    \hash.js : hashjs
    \prelude-ls : { map }
}

deadline = 15000

query = ({ network, method, params }, cb)->
  req = superagent.post network.api.api-url .send { method, params }
  err, res <- req.timeout(deadline).end
  return cb err if err?
  if not res.body
    err = Error 'no response'
    err.code = res.status
  if res.status isnt 200
    err = Error res.body
    err.code = res.status
  result = void
  if res.body.error
    err = Error res.body.error
    err.code = res.status
    result = res.body
  else
    result = res.body.result
  cb && cb err, result


export calc-fee = ({ network, tx }, cb)->
    cb null
export get-keys = ({ network, mnemonic, index }, cb)->
    entropy = (hashjs.sha512!.update "#mnemonic / #index").digest!.slice 0, 32
    secret = generate-seed { entropy }
    keypair = derive-keypair secret
    address = derive-address keypair.public-key
    cb null, { address, secret }
export push-tx = ({ rawtx, network } , cb)-->
    data =
        method: \submit
        params: [{ tx_blob: rawtx }]
        network: network
    err, res <- query data
    return cb err if err?
    cb null
export get-balance = ({ address } , cb)->
    err, data <- get "https://data.ripple.com/v2/accounts/#{address}/balances"
    cb err, data
transform-tx = (network, tx)-->
    #https://xrpcharts.ripple.com/#/transactions/8D51797E60C2E87FAE2B771EDD63809D30055F213408A93B594155FBE85743CF
    tx
export get-transactions = ({ address, network }, cb)->
    account = address
    data =
        method: \account_tx
        params: [{ account }]
        network: network
    err, res <- query data
    return cb err if err?
    txs = 
        res.transactions |> map transform-tx
    cb null, txs
export get-unconfirmed-balance = ({ network, address} , cb)->
    cb "Not Implemented"
export check-tx-status = ({ network, tx }, cb)->
    cb "Not Implemented"
export get-total-received = ({ address, network }, cb)->
    cb "Not Implemented"
export create-transaction = ({ network, account, recipient, amount, amount-fee, data, tx-type} , cb)-->
    tx_json =
        Account: account.address
        Destination: recipient
        Amount: big(amount).mul(10^6).to-fixed!
        TransactionType: \Payment
    secret = account.private-key
    data =
        method: \sign
        params: [{ secret, tx_json }]
        network: network
    err, res <- query data
    return cb err if err?
    cb null, res