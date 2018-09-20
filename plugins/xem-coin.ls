require! {
    \nem-sdk : { default: nem }
}
proxy = \https://cors-anywhere.herokuapp.com/
proxy = ''
export mainnet =
    decimals: 6
    tx-fee: \0.05
    id : 104
    prefix : "68"
    char : "N"
    api:
        provider: \xem
        node-address: nem.model.nodes.default-mainnet
        node-port: nem.model.nodes.default-port
        url: nem.model.nodes.mainnet-explorer.replace('/transfer/', '')
        api-url : "#{proxy}http://chain.nem.ninja/api3"
export testnet =
    decimals: 6
    tx-fee: \0.05
    id : -104
    prefix : "98"
    char : "T"
    api:
        provider: \xem
        node-address: nem.model.nodes.default-testnet
        node-port: nem.model.nodes.default-port
        url: nem.model.nodes.testnet-explorer.replace('/transfer/', '')
        api-url : "#{proxy}http://bob.nem.ninja:8765/api3"
export type = \coin
export enabled = yes
export token = \xem
export image = \./res/nem-ethnamed.png