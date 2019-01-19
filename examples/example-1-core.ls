require! {
    \../index.ls : web3t-builder #same as web3t
    \./plugins/erc20-rem.json : rem
    \./plugins/erc20-sprkl.json : sprkl
    \./plugins/erc20-stt.json : stt
    \./plugins/xem.json : xem
}

mode = \testnet

plugins = { sprkl, rem, stt, xem }

export init-web3t = (cb)->
    web3t-builder { mode, plugins }, cb
    
export mnemonic = "some unique pharses should be here"