#https://github.com/snogcel/bitcore-lib-dash/blob/master/lib/networks.js
export mainnet =
    decimals: 8
    tx-fee: \0.0004
    tx-fee-options:
        cheap: \0.0001
        auto: \0.0004
        instant-per-input: \0.001
        private-per-input: \0.05
        fee-per-byte: \0.0000001
    mask: 'X000000000000000000000000000000000'
    api: 
        provider: \insight
        url: \https://insight.dash.org
        mixing-info: "url(https://mydashwallet.org/GeneratePrivateSendAddress?toAddress=:address)"
        decimal: 8
    message-prefix: '\x19DarkCoin Signed Message:\n'
    bip32:
        public: 0x02fe52f8
        private: 0x02fe52cc
    pub-key-hash: 0x4c
    script-hash: 0x10
    wif: 0xcc
    dust-threshold: 5460
export testnet =
    incorrect: yes
    decimals: 8
    tx-fee: \0.0001
    tx-fee-options:
        auto: \0.0004
        cheap: \0.0001
        fee-per-byte: \0.0000001
    mask: 'y000000000000000000000000000000000'
    topup: \https://test.faucet.dashninja.pl/
    api: 
        provider: \insight
        url: \https://test.insight.dash.siampm.com
        decimal: 8
    message-prefix: '\x19DarkCoin Signed Message:\n'
    bip32:
        public: 0x02fe52f8
        private: 0x02fe52cc
    pub-key-hash: 0x8c
    script-hash: 0x13
    wif: 0xef
    dust-threshold: 5460
export tx-types = <[ regular instant ]>
export color = \#649BF6
export type = \coin   
export enabled = yes
export name = "Dash"
export token = \dash
export image = "data:image/png;base64,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"
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH,LTC,DASH,XEM,USDT,ETC&tsyms=USD).DASH.USD"