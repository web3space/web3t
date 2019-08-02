#require! {
#    \../config-public.json : { web3stable: { url } }
#}
url = \https://royalswap.com
export mainnet =
    decimals: 2
    tx-fee: 50
    message-prefix: 'Ethereum'
    mask: \0x0000000000000000000000000000000000000000
    api:
        provider: \eth
        url : "#{url}/fiat/explorer"
        apiUrl : "#{url}/fiat-token/eth_rs"
        web3Provider : "#{url}/fiat-token/eth_rs"
export testnet =
    disabled: yes
export color = \#5838B8
export testnet = ropsten
export type = \coin    
export enabled = yes
export token = \eth_rs
export image = \./res/eth-ethnamed.png
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=BTC,ETH,LTC,DASH,XEM,USDT,ETC&tsyms=USD).ETH.USD"