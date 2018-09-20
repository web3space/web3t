require! {
    \./providers/eth.ls
    \./providers/insight.ls
    \./providers/xem.ls
}

module.exports = (query, cb)->
   cb null, { eth, insight, xem }