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
export token = \dash
export image = \./res/dash-ethnamed.png
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH,LTC,DASH,XEM,USDT&tsyms=USD).DASH.USD"