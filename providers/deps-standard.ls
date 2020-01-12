require! {
    \bitcoinjs-lib : BitcoinLib
    \web3 : \Web3
    \ethereumjs-tx : Tx
    \ethereumjs-util : { BN }
    \ethereumjs-wallet/hdkey
    \bip39
}
module.exports = { BitcoinLib, Web3, Tx, BN, hdkey, bip39 }