export mainnet =
    decimals: 18
    tx-fee: \0.0014
    message-prefix: 'Ethereum'
    address: \0x73779dF3F86A4F314655247443dB8780a9b9F4CC
    mask: \0x0000000000000000000000000000000000000000
    api:
        provider: \erc20
        web3Provider : \https://mainnet.infura.io/UoCkF4efTrbEGU8Qpcs0
        url : \https://etherscan.io
        apiUrl : \https://api.etherscan.io/api
export ropsten =
    decimals: 18
    tx-fee: \0.0020
    address: \0x57BC203385A221942449c4bB1dBc0D775c8B5A02
    message-prefix: 'Ethereum'
    mask: \0x0000000000000000000000000000000000000000
    api:
        provider: \erc20
        web3Provider : "https://ropsten.infura.io/UoCkF4efTrbEGU8Qpcs0"
        url : "https://ropsten.etherscan.io"
        apiUrl : "http://api-ropsten.etherscan.io/api"
export color = \#5E72E4
export testnet = ropsten
export type = \coin
export enabled = yes
export token = \sprkl
export image = \./res/sparkle-ethnamed.png
export usd-info = 1