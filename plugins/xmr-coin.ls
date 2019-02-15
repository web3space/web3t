export mainnet =
    message-prefix: 'Monero'
    api:
        provider: \cryptonote
        url: \https://xmrchain.com
        api-url: \https://xmrchain.com/api
        node: \http://node.moneroworld.com:18089/json_rpc
export testnet =
    message-prefix: 'Monero'
    api:
        provider: \cryptonote
        url: \https://testnet.xmrchain.com
        api-url: \https://testnet.xmrchain.com/api
        node-url: \testnet.xmrchain.net:28081/json_rpc
export type = \coin    
export enabled = no
export token = \xmr
export image = \./res/xml-ethnamed.png
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=XMR&tsyms=USD).XMR.USD"