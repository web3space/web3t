#require! {
#    \../config-public.json : { web3stable: { url } }
#}
url = \https://royalswap.com
export mainnet =
    decimals: 2
    tx-fee: 0
    message-prefix: 'Ethereum'
    mask: \0x0000000000000000000000000000000000000000
    api:
        provider: \eth
        url : "#{url}/fiat/explorer"
        apiUrl : "#{url}/fiat-token/qiwi_token"
        web3Provider : "#{url}/fiat-token/qiwi_token"
export testnet =
    disabled: yes
export color = \#FF8C00
export type = \coin
export enabled = yes
export token = \qiwi_token
export image = \https://corp.qiwi.com/dam/jcr:fbce4856-723e-44a2-a54f-e7b164785f01/qiwi_sign_rgb.png
export usd-info = "1/url(https://api.exchangeratesapi.io/latest?base=USD).rates.RUB"