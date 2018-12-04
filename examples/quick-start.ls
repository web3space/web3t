require! {
    \web3t : web3t-builder
    \./plugins/erc20-example.json : sparkle
}


module.exports = {}

mode = \testnet

plugins = { sparkle }

err, web3t <- web3t-builder { mode, plugins  }
throw err if err?

module.exports <<<< web3t