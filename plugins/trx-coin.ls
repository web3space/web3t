export mainnet =
    decimals: 1
    tx-fee: \0.0000001
    tx-fee-options:
        fast: \0.000001
        cheap: \0.0000002
    mask: 'username'
    api:
        provider: \tron
        node-url: ""
        api-url: ""
        explorer-url: ""
        decimal: 1
export testnet =
    tx-fee: \0.0000001
    tx-fee-options:
        fast: \0.000001
        cheap: \0.0000002
    decimals: 1
    mask: 'username'
    api:
        provider: \tron
        node-url: ""
        api-rul: ""
        explorer-url: ""
        decimal: 1
export color = \#000000
export type = \coin
export enabled = yes
export token = \trx
export image = \https://s2.coinmarketcap.com/static/img/coins/200x200/1958.png
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=TRX&tsyms=USD).TRX.USD"