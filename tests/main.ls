require! {
    \../index.ls : build-web3t
    \./check-fields.ls
    \./test-coins.ls
    \./check-config.ls
}
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0
main = (network, cb)->
    err <- check-config
    return cb err if err?
    err, web3t <- build-web3t network
    return cb err if err?
    err <- check-fields web3t
    return cb err if err?
    err <- test-coins web3t
    return cb err if err?
    cb null
#
#
#
err, result <- main 'testnet, ethnamed for eth'
return console.error err if err?
console.log result