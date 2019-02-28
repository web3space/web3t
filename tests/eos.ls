require! {
    \../index.ls : build-web3t
    \./mnemonic.ls
}
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0
err, web3t <- build-web3t \mainnet

{ create-account, get-balance } = web3t.xlm

err, account <- create-account { mnemonic, index: 0 }
console.log err, account

err, balance <- get-balance { account }

console.log err, balance