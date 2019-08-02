require! {
    \xmlhttprequest : { XMLHttpRequest }
}
location = {"href":"https://web3.space/wallet?plugin=usd_ac_rs","protocol":"https:","host":"web3.space","hostname":"web3.space","port":"","pathname":"/wallet","search":"?plugin=usd_ac_rs","hash":"","origin":"https://web3.space","ancestorOrigins":{}}

global.location = location
global.window = { XMLHttpRequest, location }
global.XMLHttpRequest = XMLHttpRequest

require! {
    \../index.ls : build-web3t
}


export test = (cb)->
    err, web3t <- build-web3t "mainnet"
    return cb err if err?
    account =
        address: \0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
    err, data <- web3t.eth.get-balance { account }
    cb err, data