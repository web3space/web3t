export mainnet = 
    incorrect: yes
    decimals: 8
    tx-fee: \0.0001
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
    mask: 'L000000000000000000000000000000000'
    api: 
        provider: \insight
        url: \https://insight.litecore.io
        decimal: 8
    message-prefix: '\x19Litecoin Signed Message:\n'
    bip32:
        public: 0x0432a9a8
        private: 0x0432a243
    pub-key-hash: 0x71
    script-hash: 0xc4
    wif: 241
export type = \coin    
export enabled = no
export token = \doge
export image = \./res/doge-ethnamed.png