require! {
    \./btc-coin.ls : btc
    \./dash-coin.ls : dash
    \./eth-coin.ls : eth
    \./ltc-coin.ls : ltc
    \./xem-coin.ls : xem
}
module.exports = (query, cb)->
    cb null, {btc, dash, eth, ltc, xem}