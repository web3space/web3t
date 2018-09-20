export mainnet =
    decimals: 8
    tx-fee: \0.0000004
    mask: '1000000000000000000000000000000000'
    api: 
        provider: \insight
        url: \https://insight.bitpay.com
        decimal: 8
    message-prefix: '\x18Bitcoin Signed Message:\n'
    bech32: 'bc'
    bip32:
        public: 0x0488b21e
        private: 0x0488ade4
    pubKeyHash: 0x00
    scriptHash: 0x05
    wif: 0x80
export testnet =
    tx-fee: 0.0001
    decimals: 8
    mask: '1000000000000000000000000000000000'
    api:
        provider: \insight
        url: \https://testnet.blockexplorer.com
        decimal: 8
    messagePrefix: '\x18Bitcoin Signed Message:\n'
    topup: \https://testnet.manu.backend.hamburg/faucet
    bech32: 'tb'
    bip32:
        public: 0x043587cf
        private: 0x04358394
    pubKeyHash: 0x6f
    scriptHash: 0xc4
    wif: 0xef
export type = \coin
export enabled = yes
export token = \btc
export image = \./res/btc-ethnamed.png