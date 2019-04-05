require! {
   \../index.ls : build-web3t
}

mnemonic = "step world panther frog tiny express ensure wear soldier album make kit"

err, web3t <- build-web3t "mainnet"

err, account <- web3t.btc.createAccount { mnemonic, index: 1  }
console.log err, account?address