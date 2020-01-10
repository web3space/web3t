require! {
    \./plugins/btc-coin.js : btc
    \./plugins/dash-coin.js : dash
    \./plugins/eth-coin.js : eth
    \./plugins/etc-coin.js : etc
    \./plugins/ltc-coin.js : ltc
    #\./plugins/xem-coin.js : xem
    #\./plugins/xrp-coin.js : xrp
    \./plugins/usdt-coin.js : usdt
    #\./plugins/eos-coin.js : eos
    \./plugins/xlm-coin.js : xlm
    \./plugins/trx-coin.js : trx
    \./plugins/xmr-coin.js : xmr
    #\./plugins/qiwi-coin.js : qiwi_token
    #\./plugins/ym-coin.js : ym_token
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