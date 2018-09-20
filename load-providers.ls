require! {
    \./eth.ls
    \./insight.ls
    \./xem.ls
}

module.exports = (query, cb)->
   cb null, { eth, insight, xem }