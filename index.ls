require! {
    \./load-providers.js
    \./load-coins.js
    \./build-api.js
}

module.exports = (config, cb)->
    err, coins <- load-coins config
    return cb err if err?
    err, providers <- load-providers config
    return cb err if err?
    err, api <- build-api coins, providers, config
    return cb err if err?
    cb null, api
    