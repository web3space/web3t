require! {
    \bitgo-utxo-lib : BitcoinLib
    \web3 : \Web3
    \ethereumjs-tx : Tx
    \ethereumjs-util : { BN }
    \ethereumjs-wallet/hdkey
    \bip39
}
#bitgo-utxo-lib

# performance optimization start
mnemonic-to-seed = bip39.mnemonic-to-seed
cache = {}
bip39.mnemonic-to-seed = (mnemonic)->
    cache[mnemonic] = mnemonic-to-seed mnemonic if not cache[mnemonic]?
    cache[mnemonic] 
# performance optimization end
    
module.exports = { BitcoinLib, Web3, Tx, BN, hdkey, bip39 }