export mainnet =
    decimals: 1
    tx-fee: \0
    mask: 'username'
    chainId: \aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906
    register-account-link: \https://www.zeos.co/en/home?public-key=:public-key
    api:
        provider: \eos
        node-url: 
            * \https://api.eosnewyork.io
            * \https://api.eosio.cr:80
            * \https://api.eosdetroit.io:443
            * \https://eos.greymass.com:443
            * \https://api.eosmetal.io:18890
            * \http://api.hkeos.com:80
            * \https://eosapi.blockmatrix.network:443
            * \https://fn.eossweden.se:443
            * \http://api.blockgenicbp.com:8888
            * \http://mainnet.eoscalgary.io:80
            * \https://node1.eosphere.io
            * \https://eos.saltblock.io
            * \http://eos-api.worbli.io:80
            * \https://eos-api.worbli.io:443
            * \http://mainnet.eoscalgary.io:80
            * \http://user-api.eoseoul.io:80
            * \https://node2.liquideos.com:8883
            * \https://api.eosuk.io:443
            * \http://api1.eosdublin.io:80
            * \http://api.eosvibes.io:80
            * \http://api.cypherglass.com:8888
            * \http://bp.cryptolions.io:8888
            * \http://dc1.eosemerge.io
            * \https://api.eosio.cr:443
            * \https://api.eosn.io
            * \https://eu1.eosdac.io:443
            * \https://api.main.alohaeos.com:443
            * \https://rpc.eosys.io
        api-url: \https://api.eospark.com
        explorer-url: \https://eospark.com
        decimal: 1
export testnet =
    tx-fee: \0
    decimals: 1
    mask: 'username'
    register-account-link: \https://www.google.com/search?q=eos+account+jungle
    api:
        provider: \eos
        node-url: \https://jungle.eosio.cr:443
        api-rul: \https://api.jungle.eospark.com
        explorer-url: \https://jungle.eospark.com
        decimal: 1
export color = \#272431
export type = \coin
export enabled = yes
export token = \eos
export image = \https://res.cloudinary.com/nixar-work/image/upload/v1550938232/EOS.png
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=EOS&tsyms=USD).EOS.USD"