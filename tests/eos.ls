require! {
    \../index.js : build-web3t
    \./mnemonic.js
}
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0
err, web3t <- build-web3t \mainnet

{ create-account, get-balance, calc-fee } = web3t.eth

err, account <- create-account { mnemonic, index: 0 }
#console.log err, account

to = \0x35b686646ffc646969953dbe12252d554fe6c5ce

err, fee <- calc-fee { account, to, data: '0x', fee-type: \auto, amount: "0" }
console.log err, fee

#err, balance <- get-balance { account }

#console.log err, balance