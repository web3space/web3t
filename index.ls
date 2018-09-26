require! {
    \require-ls
    \./load-providers.ls
    \./load-coins.ls
    \./build-api.ls
}
module.exports = (config, cb)->
    err, coins <- load-coins config
    return cb err if err?
    err, providers <- load-providers config
    return cb err if err?
    err, api <- build-api coins, providers, config
    return cb err if err?
    cb null, api
    