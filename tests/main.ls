require! {
    \../index.ls : build-web3t
    \./check-fields.ls
    \./test-coins.ls
}
main = (network, cb)->
    err, web3t <- build-web3t network
    return cb err if err?
    err <- check-fields web3t
    return cb err if err?
    err <- test-coins web3t
    cb null
#
#
#
err, result <- main \testnet
return console.error err if err?
console.log result