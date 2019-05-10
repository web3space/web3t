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
export image = \https://res.cloudinary.com/nixar-work/image/upload/v1555933362/Ethereum-Classic-ETC-icon.png
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH,LTC,DASH,XEM,USDT,ETC&tsyms=USD).ETC.USD"