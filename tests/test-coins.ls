require! {
    \./types.ls
    \./test-coin.ls
}
test-coins = ([type, ...types], web3t, cb)->
    return cb null if not type?
    coin = web3t[type]
    return cb "Type Not Found" if not coin?
    err, data <- test-coin coin
    return cb err if err?
    err, coins <- test-coins types, web3t
    return cb err if err?
    cb null, data
module.exports = (web3t, cb)->
    test-coins types, web3t, cb