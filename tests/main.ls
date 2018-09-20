require! {
    \../index.ls : build-web3t
}


err, web3t <- build-web3t \testnet

console.log err, Object.keys(web3t.btc)