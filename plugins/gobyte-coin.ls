export mainnet =
    decimals: 8
    tx-fee: \0.00001
    tx-fee-auto-mode: \per-byte
    tx-fee-options: 
        auto: \0.0005
        cheap: \0.00001
        instant-per-input: \0.0001
        instant-service-price: 0
        private-per-input: \0.005
        private-service-price: \0.025
        fee-per-byte: \0.00000001
    mask: '1000000000000000000000000000000000'
    api:
        provider: \insight
        url: \https://insight.gobyte.network
        api-name: \insight-api-gobyte
        mixing-list: "https://explorer.gobyte.network:5002/api/masternodelist"
        decimal: 8
    message-prefix: '\x18GoByte Signed Message:\n'
    bech32: 'bc'
    bip32:
        public: 0x488b21e
        private: 0x488ade4
    pubKeyHash: 0x26 #38 base58Prefixes[PUBKEY_ADDRESS]
    scriptHash: 0x10 #16 base58Prefixes[SCRIPT_ADDRESS]
    wif: 0xc6 #198 base58Prefixes[SECRET_KEY]
    dust-threshold: 5460
export testnet =
    tx-fee: \0.00005
    tx-fee-options:
        fast: \0.00005
        cheap: \0.00001
        instant-per-input: \0.0001
        private-per-input: \0.005
        fee-per-byte: \0.00000001
    decimals: 8
    mask: 'n000000000000000000000000000000000'
    api:
        provider: \insight
        url: \https://texplorer.gobyte.network:4001
        api-name: \insight-api-gobyte
        decimal: 8
    messagePrefix: '\x18GoByte Signed Message:\n'
    topup: \https://testnet.manu.backend.hamburg/faucet
    bech32: 'tb'
    bip32:
        public: 0x043587cf
        private: 0x04358394
    pubKeyHash: 0x70 #base58Prefixes[PUBKEY_ADDRESS]
    scriptHash: 0x14 #base58Prefixes[SCRIPT_ADDRESS]
    wif: 0xf0 #base58Prefixes[SECRET_KEY]
    dust-threshold: 5460
export tx-types = <[ regular instant ]>
export color = \#545DF1
export branding =
    logo: \https://www.gobyte.network/img/logo.svg
    title: "GoByte Multicurrency Wallet"
    important: yes
    topup: \gobyte
export links =
    *   image: \https://www.gobyte.network/img/fb.png
        href: \https://wwww.facebook.com/gobytenetwork
    *   image: \https://www.gobyte.network/img/twitter.png
        href: \https://twitter.com/gobytenetwork
    *   image: \https://www.gobyte.network/img/reddit.png
        href: \https://www.reddit.com/r/gobytenetwork/
    *   image: \https://www.gobyte.network/img/slack.png
        href: \https://gobyte.slack.com/
    *   image: \https://www.gobyte.network/img/discordapp.png
        href: \https://discord.gobyte.network/
    *   image: \https://www.gobyte.network/img/telegram.png
        href: \https://t.me/gobytenetwork
    *   image: \https://www.gobyte.network/img/github.png
        href: \https://github.com/gobytecoin/gobyte
export type = \coin
export enabled = yes
export token = \gbx
export image = \https://res.cloudinary.com/nixar-work/image/upload/v1548537659/gobyte.png
export usd-info = "url(https://min-api.cryptocompare.com/data/pricemulti?fsyms=GBX&tsyms=USD).GBX.USD"