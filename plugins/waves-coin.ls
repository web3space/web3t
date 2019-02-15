export mainnet =
    decimals: 8
    tx-fee: \0.001
    mask: '3P000000000000000000000000000000000'
    message-prefix: 'Waves'
    api:
        provider: \waves
        url: \https://wavesexplorer.com
export testnet =
    decimals: 8
    tx-fee: \0.001
    mask: '3P000000000000000000000000000000000'
    message-prefix: 'Waves'
    api:
        provider: \waves
        url: \https://wavesexplorer.com
export type = \coin    
export enabled = no
export token = \waves
export image = \//res.cloudinary.com/nixar-work/image/upload/v1525380100/waves-icon.png
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=WAVES&tsyms=USD).WAVES.USD"