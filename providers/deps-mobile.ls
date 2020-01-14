require! {
    \rn-bitcoinjs-lib : BitcoinLib
    \node-libs-browser
    \web3 : \Web3
    \ethereumjs-tx : Tx
    \ethereumjs-util : { BN }
    \react-native-secure-randombytes : { asyncRandomBytes }
    \react-native-safe-crypto : safeCrypto
    \ethereumjs-wallet-react-native/hdkey.js
    \react-native-bip39 : bip39
}

# for web3 according to https://github.com/ethereum/web3.js/issues/1022#issuecomment-330825219
#node-libs-browser
# but I could be wrong because of https://gist.github.com/dougbacelar/29e60920d8fa1982535247563eb63766

# https://github.com/WoeOm/ethereumjs-wallet-react-native requirement
window.randomBytes = asyncRandomBytes
window.scryptsy = safeCrypto.scrypt


module.exports = { BitcoinLib, Web3, Tx, BN, hdkey, bip39 }