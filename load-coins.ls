require! {
    \./plugins/btc-coin.ls : btc
    \./plugins/dash-coin.ls : dash
    \./plugins/eth-coin.ls : eth
    \./plugins/ltc-coin.ls : ltc
    \./plugins/xem-coin.ls : xem
    \./plugins/xrp-coin.ls : xrp
    \prelude-ls : { obj-to-pairs, pairs-to-obj, filter }
}
only-coins = (plugins)->
    plugins
        |> obj-to-pairs
        |> filter (.type is \coin)
        |> pairs-to-obj
extend-coins = (coins, config)->
    return if typeof! config.plugins isnt \Object
    coins <<<< only-coins config.plugins
module.exports = (config, cb)->
    def = { btc, dash, eth, ltc, xem }
    extend-coins def, config
    cb null, def