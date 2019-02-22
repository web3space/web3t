The concept includes 2 types of entities:

1. Providers
2. Plugins

## Description

#### 1. Providers

Most heavy code. Everything which implements the communication with protocol

For example `bitcore` provides functionality for bitcoin and all his forks


#### 2. Plugins

Configurations which can be pluged-in on the fly.

Plugins should have a corresponding `provider`

## Interface

#### 1. Providers implements functions

```Javascript 

export getKeys = ({ network, mnemonic, index }, cb)=>
    cb(null, ...); //Get { privateKey, address }
    
export pushTx = ({ rawtx } , cb)=>
    cb(null, ...); //Get transactionUrl

export getBalance = ( {address, network} , cb)=>
    cb(null, ...); //Get balance
    
export getTransactions = ({ address, network }, cb)=>
    cb(null, ...); //Get array or transactions
    
export createTransaction = ({account, recipient, amount, amount-fee, data} , cb)-->
    cb(null, ...); //Get signed transaction (hex)

export calcFee = ({tx, network} , cb)-->
    cb(null, ...); //Get amount fee
    
```

#### 2. Plugins

```Javascript
export type = 'coin'

//put network specific configuration here
export mainnet = {
    api : {
        url: "..."
    }
}

//put network specific configuration here
export testnet = {
    api : {
        url: "..."
    }
}
export enabled = true;

```