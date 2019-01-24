export mainnet =
    decimals: 18
    tx-fee: \0.0014
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
    message-prefix: 'Ethereum'
    mask: \0x0000000000000000000000000000000000000000
    api:
        provider: \eth
        web3Provider : \http://web3.space/ganache
        url : \https://web3.space/explorer
        apiUrl : \https://web3.space/explorer/api
export ropsten =
    decimals: 18
    tx-fee: \0.0014
    message-prefix: 'Ethereum'
    mask: \0x0000000000000000000000000000000000000000
    api:
        provider: \eth
        web3Provider : "https://ropsten.infura.io/UoCkF4efTrbEGU8Qpcs0"
        url : "https://ropsten.etherscan.io"
        apiUrl : "http://api-ropsten.etherscan.io/api"
export testnet = ropsten
export type = \coin    
export enabled = yes
export token = \eth
export image = \./res/eth-ethnamed.png