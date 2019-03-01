export mainnet =
    decimals: 18
    tx-fee: \0.0014
    tx-fee-options: 
        auto: \0.0014
        fast: \0.0014
        cheap: \0.00014
    message-prefix: 'Ethereum'
    mask: \0x0000000000000000000000000000000000000000
    api:
        provider: \eth
        web3Provider : \https://mainnet.infura.io/UoCkF4efTrbEGU8Qpcs0
        url : \https://etherscan.io
        apiUrl : \https://api.etherscan.io/api
export ethnamed =
    decimals: 18
    tx-fee: \0.0014
    tx-fee-options: 
        fast: \0.0014
        cheap: \0.00014
    message-prefix: 'Ethereum'
    mask: \0x0000000000000000000000000000000000000000
    api:
        provider: \eth
        web3Provider : \http://web3.space:9000
        url : \http://web3.space:8000
        apiUrl : \http://web3.space:8000/api
export ropsten =
    decimals: 18
    tx-fee: \0.0014
    tx-fee-options: 
        auto: \0.0014
        fast: \0.0014
        cheap: \0.00014
    message-prefix: 'Ethereum'
    mask: \0x0000000000000000000000000000000000000000
    api:
        provider: \eth
        web3Provider : \https://ropsten.infura.io/UoCkF4efTrbEGU8Qpcs0
        url : \https://ropsten.etherscan.io
        apiUrl : \http://api-ropsten.etherscan.io/api
export color = \#5838B8
export testnet = ropsten
export type = \coin    
export enabled = yes
export token = \eth
export image = \./res/eth-ethnamed.png
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH,LTC,DASH,XEM,USDT&tsyms=USD).ETH.USD"