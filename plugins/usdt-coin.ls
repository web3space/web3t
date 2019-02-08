export mainnet =
    decimals: 8
    tx-fee: \0.00005546
    tx-fee-in: \btc
    mask: '1000000000000000000000000000000000'
    api: 
        api-url: \https://api.omniwallet.org
        api-url-btc: \https://insight.bitpay.com
        provider: \omni
        url: \https://omniexplorer.info
        decimal: 8
    propertyid: '31'
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
    tx-fee-in: \btc
    disabled: yes
    decimals: 8
    mask: '1000000000000000000000000000000000'
    api:
        provider: \insight
        url: \https://testnet.blockexplorer.com
        api-url: \https://api.omniwallet.org
        api-url-btc: \https://testnet.blockexplorer.com
        decimal: 8
    messagePrefix: '\x18Bitcoin Signed Message:\n'
    propertyid: '31'
    bech32: 'tb'
    bip32:
        public: 0x043587cf
        private: 0x04358394
    pubKeyHash: 0x6f
    scriptHash: 0xc4
    wif: 0xef
export type = \coin
export enabled = yes
export token = \usdt
export color = \#26A17B
export image = \https://res.cloudinary.com/nixar-work/image/upload/v1547940263/download.png
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH,LTC,DASH,XEM,USDT&tsyms=USD).USDT.USD"