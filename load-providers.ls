require! {
    \./providers/eth.ls
    \./providers/rst.ls
    \./providers/insight.ls
    #\./providers/xem.ls
    \./providers/ripple.ls
    \./providers/erc20.ls
    \./providers/omni.ls
    #\./providers/eos.ls
    \./providers/stellar.ls
    \./providers/tron.ls
    #\./providers/cryptonote.ls
}
extend-providers = (providers, config)->
    return if typeof! config.providers isnt \Object
    providers <<<< config.providers
module.exports = (config, cb)->
   def = { eth, insight, ripple, erc20, omni, stellar, tron, rst }
   extend-providers def, config
   cb null, def