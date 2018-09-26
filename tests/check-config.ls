require! {
    \../config-parser.ls
}

module.exports = (cb)->
    config = config-parser \testnet
    return cb "Wrong network #{config.get-mode-for \eth}, expected testnet" if config.get-mode-for(\eth) isnt \testnet
    config = config-parser 'testnet, ethnamed for eth'
    return cb "Wrong network #{config.get-mode-for \eth}, expected ethnamed" if config.get-mode-for(\eth) isnt \ethnamed
    cb null