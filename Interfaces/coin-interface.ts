interface Bip32 {
	public: number;
    private: number;
}

interface Api {
    //Different blockchain can use the same protocol. Like bitcoin and litecoin, ethereum and ethereum classic
	protocol: string;
    //Connection to the fullNode (absolute path)
    url: string;
}

interface Network {
	decimals: number;
    txFee: number;
    mask: string;
    api: Api;
    messagePrefix?: string;
    bech32?: string;
    bip32?: Bip32;
    pubKeyHash?: number;
    scriptHash?: number;
    wif?: number;
}

interface Coin {
    symbol: string;
    imageUrl: string;
    testnet: Network;
    mainnet: Network;
}