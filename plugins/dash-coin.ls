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