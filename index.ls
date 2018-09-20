require! {
    \require-ls
    \./load-providers.ls
    \./load-coins.ls
}
    
module.exports = (mode, cb)->
    err, coins <- load-coins mode
    return cb err if err?
    err, providers <- load-providers mode
    return cb err if err?
    err, api <- build-api coins, providers, mode
    return cb err if err?
    cb null, api
    