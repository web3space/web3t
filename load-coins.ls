require! {
    \./plugins/btc-coin.ls : btc
    \./plugins/dash-coin.ls : dash
    \./plugins/eth-coin.ls : eth
    \./plugins/ltc-coin.ls : ltc
    \./plugins/xem-coin.ls : xem
    \./plugins/xrp-coin.ls : xrp
}
module.exports = (config, cb)->
    cb null, { btc, dash, eth, ltc, xem }