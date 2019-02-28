export mainnet =
    decimals: 1
    tx-fee: \0.0000001
    tx-fee-options:
        fast: \0.000001
        cheap: \0.0000002
    mask: 'username'
    api:
        provider: \stellar
        node-url: ""
        api-url: "https://horizon.stellar.org"
        explorer-url: "https://steexp.com"
        decimal: 1
export testnet =
    tx-fee: \0.0000001
    tx-fee-options:
        fast: \0.000001
        cheap: \0.0000002
    decimals: 1
    mask: 'username'
    api:
        provider: \stellar
        node-url: ""
        api-url: "https://horizon-testnet.stellar.org"
        explorer-url: ""
        decimal: 1
export color = \#D9F0F7
export type = \coin
export enabled = yes
export token = \xlm
export image = \https://crushcrypto.com/wp-content/uploads/2018/08/Stellar-Logo.jpg
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=XLM&tsyms=USD).XLM.USD"