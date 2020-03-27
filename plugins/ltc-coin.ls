export mainnet = 
    decimals: 8
    tx-fee: \0.0001
    tx-fee-options:
        auto: \0.0001
        cheap: \0.000014
    mask: 'L000000000000000000000000000000000'
    api: 
        provider: \insight
        url: \https://insight.litecore.io
        decimal: 8
    message-prefix: '\x19Litecoin Signed Message:\n'
    bip32:
        public: 0x019da462
        private: 0x019d9cfe
    pub-key-hash: 0x30
    script-hash: 0x32
    wif: 0xb0
export testnet = 
    decimals: 8
    tx-fee: \0.0001
    tx-fee-options: 
        auto: \0.0001
        cheap: \0.000014
    topup: \https://litecoin-faucet.com/
    mask: 'n000000000000000000000000000000000'
    api: 
        provider: \insight
        url: \https://testnet.litecore.io
        decimal: 8
    message-prefix: '\x19Litecoin Signed Message:\n'
    bip32:
        public: 0x0436ef7d
        private: 0x0436f6e1
    pub-key-hash: 0x6f
    script-hash: 0xc4
    wif: 0xef
export color = \#a04b55
export type = \coin    
export enabled = yes
export name = 'Litecoin'
export token = \ltc
export image = "data:image/png;base64,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"
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH,LTC,DASH,XEM,USDT,ETC&tsyms=USD).LTC.USD"