require! {
    \./example-1-core.ls : { init-web3t, mnemonic }
}

## Core

export create-btc-account = (index, cb )->
  err, web3t <- init-web3t
  return cb err if err?
  web3t.btc.create-account({ mnemonic, index }, cb)

export create-ltc-account = (index, cb )->
  err, web3t <- init-web3t
  return cb err if err?
  web3t.ltc.create-account({ mnemonic, index }, cb)
  
export create-dash-account = (index, cb )->
  err, web3t <- init-web3t
  return cb err if err?
  web3t.dash.create-account({ mnemonic, index }, cb)
  
export create-eth-account = (index, cb )->
  err, web3t <- init-web3t
  return cb err if err?
  web3t.eth.create-account({ mnemonic, index }, cb)
  
# Plugins

export create-xem-account = (index, cb )->
  err, web3t <- init-web3t
  return cb err if err?
  web3t.xem.create-account({ mnemonic, index }, cb)
  
export create-rem-account = (index, cb )->
  err, web3t <- init-web3t
  return cb err if err?
  web3t.rem.create-account({ mnemonic, index }, cb)

export create-stt-account = (index, cb )->
  err, web3t <- init-web3t
  return cb err if err?
  web3t.stt.create-account({ mnemonic, index }, cb)
  
export create-sprkl-account = (index, cb )->
  err, web3t <- init-web3t
  return cb err if err?
  web3t.sprkl.create-account({ mnemonic, index }, cb)


