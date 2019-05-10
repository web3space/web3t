require! {
    \keythereum
}

module.exports = (complexity=18)->
    dk = keythereum.create!
    nonce = keythereum.private-key-to-address dk.privateKey
    { complexity, nonce }
