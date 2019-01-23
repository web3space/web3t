export mainnet =
    decimals: 1
    tx-fee: \0.0004
    mask: '1000000000000000000000000000000000'
    api: 
        api-url: \https://api.omniwallet.org
        api-url-btc: \https://insight.bitpay.com
        provider: \omni
        url: \https://omniexplorer.info
        decimal: 1
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
    decimals: 1
    mask: '1000000000000000000000000000000000'
    api:
        api-url: \https://api.omniwallet.org
        api-url-btc: \https://testnet.blockexplorer.com
        provider: \omni
        url: \https://omniexplorer.info
        decimal: 1
    propertyid: '2147484069'
    message-prefix: '\x18Bitcoin Signed Message:\n'
    bech32: 'bc'
    bip32:
        public: 0x0488b21e
        private: 0x0488ade4
    pubKeyHash: 0x00
    scriptHash: 0x05
    wif: 0x80
export type = \coin
export enabled = yes
export token = \usdt
export image = \https://res.cloudinary.com/nixar-work/image/upload/v1547940263/download.png