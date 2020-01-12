require! {
    \rn-bitcoinjs-lib : BitcoinLib
    \web3 : \Web3
    \ethereumjs-tx : Tx
    \ethereumjs-util : { BN }
    \react-native-secure-randombytes : { asyncRandomBytes }
    \react-native-safe-crypto : safeCrypto
    \ethereumjs-wallet-react-native/hdkey.js
    \react-native-bip39 : bip39
}
# https://github.com/WoeOm/ethereumjs-wallet-react-native requirement
window.randomBytes = asyncRandomBytes
window.scryptsy = safeCrypto.scrypt


module.exports = { BitcoinLib, Web3, Tx, BN, hdkey, bip39 }