export mainnet =
    decimals: 8
    tx-fee: \0.0005
    tx-fee-options: 
        fast: \0.0005
        cheap: \0.00000226
    mask: '1000000000000000000000000000000000'
    api:
        provider: \insight
        url: \https://insight.gobyte.network
        api-name: \insight-api-gobyte
        decimal: 8
    message-prefix: '\x18GoByte Signed Message:\n'
    bech32: 'bc'
    bip32:
        public: 0x488b21e
        private: 0x488ade4
    pubKeyHash: 0x26 #38 base58Prefixes[PUBKEY_ADDRESS]
    scriptHash: 0x10 #16 base58Prefixes[SCRIPT_ADDRESS]
    wif: 0xc6 #198 base58Prefixes[SECRET_KEY]
    dust-threshold: 5460
export testnet =
    tx-fee: \0.0005
    tx-fee-options: 
        fast: \0.0005
        cheap: \0.00000226
    decimals: 8
    mask: 'n000000000000000000000000000000000'
    api:
        provider: \insight
        url: \http://texplorer.gobyte.network:4001
        api-name: \insight-api-gobyte
        decimal: 8
    messagePrefix: '\x18GoByte Signed Message:\n'
    topup: \https://testnet.manu.backend.hamburg/faucet
    bech32: 'tb'
    bip32:
        public: 0x043587cf
        private: 0x04358394
    pubKeyHash: 0x70 #base58Prefixes[PUBKEY_ADDRESS]
    scriptHash: 0x14 #base58Prefixes[SCRIPT_ADDRESS]
    wif: 0xf0 #base58Prefixes[SECRET_KEY]
    dust-threshold: 5460
export color = \#185C9D
export type = \coin
export enabled = yes
export token = \gbx
export image = \https://res.cloudinary.com/nixar-work/image/upload/v1548537659/gobyte.png
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=GBX&tsyms=USD).GBX.USD"