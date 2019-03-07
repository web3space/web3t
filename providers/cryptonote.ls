require! {
    \../library/monero.js : { generate-address }
    \superagent : { post, get }
}
# API doc
# https://github.com/moneroexamples/onion-monero-blockchain-explorer#apioutputstxhashtx_hashaddressviewkeytxprove01

rawtransaction = ({ network, txhash }, cb)->
    get "#{network.api.api-url}/api/rawtransaction/#{txhash}" .end cb

transaction = ({ network, txhash }, cb)->
    get "#{network.api.api-url}/api/transaction/#{txhash}" .end cb

outputs = ({ network, txhash, address, viewkey }, cb)->
    get "#{network.api.api-url}/outputs?txhash=#{txhash}&address=#{address}&viewkey=#{viewkey}&txprove=0" .end cb

search = ({ network, txhash }, cb)->
    get "#{network.api.api-url}/search/#{txhash}" .end cb

export calc-fee = ({ network, tx }, cb)->
    return cb null

export get-keys = ({ network, mnemonic, index }, cb)->
    { address, spend-key, view-key } = generate-address "#{mnemonic} / #{index}"
    { address, private-key: spend-key, view-key }
export push-tx = ({ rawtx } , cb)-->
    cb "Not Implemented"
export get-balance = ({address, network} , cb)->
    cb "Not Implemented"
    #input = 
    #    jsonrpc : "2.0"
    #    id : "0"
    #    method : \get_payments
    #    params:
    #        payment_id: \426870cb29c598e191184fa87003ca562d9e25f761ee9e520a888aec95195912
    #err, data <-  post "http://testnet.xmrchain.net:28081/json_rpc", input .end
    #console.log err, data
export get-unconfirmed-balance = ({ network, address} , cb)->
    cb "Not Implemented"
export get-transactions = ({ address, network }, cb)->
    cb "Not Implemented"
export create-transaction = ({account, recipient, amount, amount-fee, data, tx-type} , cb)-->
    cb "Not Implemented"
#get-balance {}