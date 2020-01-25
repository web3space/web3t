require! {
    \./providers/eth.js
    \./providers/insight.js
    \./providers/erc20.js
    \./providers/omni.js
    \./providers/velas.js
    #\./providers/eos.js
    #\./providers/stellar.js
    #\./providers/tron.js
    #\./providers/cryptonote.js
    #\./providers/xem.js
    #\./providers/ripple.js
}
extend-providers = (providers, config)->
    return if typeof! config.providers isnt \Object
    providers <<<< config.providers
module.exports = (config, cb)->
   def = { eth, insight, erc20, omni, velas }
   extend-providers def, config
   cb null, def