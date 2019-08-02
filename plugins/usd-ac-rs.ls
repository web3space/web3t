#require! {
#    \../config-public.json : { web3stable: { url } }
#}
url = \https://royalswap.com
export mainnet =
    decimals: 2
    tx-fee: 0
    tx-fee-options:
        withdraw: 0
    message-prefix: 'Ethereum'
    mask: \0x0000000000000000000000000000000000000000
    api:
        provider: \rst
        url : "#{url}/fiat/explorer"
        apiUrl : "#{url}/fiat-token/usd_ac_rs"
        web3Provider : "#{url}/fiat-token/usd_ac_rs"
export testnet =
    disabled: yes
export color = "#62C272"
export type = \coin
export enabled = yes
export token = \usd_ac_rs
export image = "https://bitcoin-debit-cards.com/wp-content/uploads/2017/12/advcash-app.png"
export usd-info = 1