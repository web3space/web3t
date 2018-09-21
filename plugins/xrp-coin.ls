export mainnet =
    decimals: 8
    tx-fee: \0.0000004
    mask: '1000000000000000000000000000000000'
    api: 
        provider: \ripple
        url: \https://bithomp.com/explorer
        api-url: \http://s2.ripple.com:51234/
        decimal: 8
export testnet =
    tx-fee: 0.0001
    decimals: 8
    mask: '1000000000000000000000000000000000'
    api:
        provider: \ripple
        url: \https://bithomp.com/explorer
        api-url: \https://s.altnet.rippletest.net:51234
        decimal: 8
    topup: \https://testnet.manu.backend.hamburg/faucet
export type = \coin
export enabled = yes
export token = \xrp
export image = \./res/xrp-ethnamed.png