export mainnet =
    decimals: 8
    tx-fee: \0.0001
    mask: 't000000000000000000000000000000000'
    api: 
        provider: \insightzec
        url: \https://zcashnetwork.info
        decimal: 8
    message-prefix: '\x18Zcash Signed Message:\n'
    bip32:
        public: 0x0488b21e
        private: 0x05358394
    pubKeyHash: 0x1CB8
    scriptHash: 0x1CBD
    wif: 0x80
export testnet =
    decimals: 8
    tx-fee: \0.0001
    mask: 'tm00000000000000000000000000000000'
    api: 
        provider: \insightzec
        url: \https://explorer.testnet.z.cash
        decimal: 8
    topup: \https://faucet.testnet.z.cash/
    message-prefix: '\x18Zcash Signed Message:\n'
    bip32:
        public: 0x043587cf
        private: 0x04358394
    pubKeyHash: 0x1d25
    scriptHash: 0x1cba
    wif: 0xef
export type = \coin
export enabled = no
export token = \zec
export image = \./res/zcash_icon.png
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=ZEC&tsyms=USD).ZEC.USD"