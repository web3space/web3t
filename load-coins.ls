require! {
    \./plugins/btc-coin.ls : btc
    \./plugins/dash-coin.ls : dash
    \./plugins/eth-coin.ls : eth
    \./plugins/etc-coin.ls : etc
    \./plugins/ltc-coin.ls : ltc
    #\./plugins/xem-coin.ls : xem
    \./plugins/xrp-coin.ls : xrp
    \./plugins/usdt-coin.ls : usdt
    #\./plugins/eos-coin.ls : eos
    \./plugins/xlm-coin.ls : xlm
    \./plugins/trx-coin.ls : trx
    \./plugins/xmr-coin.ls : xmr
    #\./plugins/qiwi-coin.ls : qiwi_token
    #\./plugins/ym-coin.ls : ym_token
    \prelude-ls : { obj-to-pairs, pairs-to-obj, filter }
}
only-coins = (plugins)->
    plugins
        |> obj-to-pairs
        |> filter (.1?type is \coin)
        |> pairs-to-obj
extend-coins = (coins, config)->
    return if typeof! config.plugins isnt \Object
    coins <<<< only-coins config.plugins
module.exports = (config, cb)->
    #eos
    def = { btc, dash, eth, ltc, usdt, xlm, trx, xmr, etc }
    extend-coins def, config
    cb null, def