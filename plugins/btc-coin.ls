export mainnet =
    decimals: 8
    tx-fee: \0.0000004
    tx-fee-auto-mode: \per-byte
    tx-fee-options: 
        auto: \0.000001
        cheap: \0.0000004
        fee-per-byte: \0.000001
    mask: '1000000000000000000000000000000000'
    api: 
        provider: \insight
        url: \https://insight.bitpay.com
        decimal: 8
        alternative:
            balance: \https://blockchain.info/q/addressbalance/:address
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
export color = \#4650E7
export type = \coin
export enabled = yes
export name = \Bitcoin
export token = \btc
export image = "data:image/png;base64,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"
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH,LTC,DASH,XEM,USDT,ETC&tsyms=USD).BTC.USD"