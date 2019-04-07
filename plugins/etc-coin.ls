export mainnet =
    decimals: 18
    tx-fee: \0.0014
    tx-fee-options: 
        auto: \0.0014
        cheap: \0.00014
    message-prefix: 'Ethereum'
    mask: \0x0000000000000000000000000000000000000000
    api:
        provider: \eth
        web3Provider : \https://ethereumclassic.network
        url : \http://gastracker.io
        address-sub-url: \addr
        apiUrl : \https://api.etherscan.io/api
export testnet =
    decimals: 18
    disabled: yes
    tx-fee: \0.0014
    tx-fee-options: 
        auto: \0.0014
        cheap: \0.00014
    message-prefix: 'Ethereum'
    mask: \0x0000000000000000000000000000000000000000
    api:
        provider: \eth
        web3Provider : \https://ropsten.infura.io/UoCkF4efTrbEGU8Qpcs0
        url : \https://ropsten.etherscan.io
        apiUrl : \https://api-ropsten.etherscan.io/api
export color = \#71DF8F
export type = \coin    
export enabled = yes
export token = \etc
export image = \https://bitsettle.com/images/sp/1321-dbbd894924b65cc449f43c7bc7e9325e0478bbd4e9723249ac029fc6279cb55e.png
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH,LTC,DASH,XEM,USDT,ETC&tsyms=USD).ETC.USD"