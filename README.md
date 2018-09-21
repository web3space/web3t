
<p align="center">
  <img src="http://res.cloudinary.com/nixar-work/image/upload/v1534729062/Screen_Shot_2018-08-20_at_04.36.54.png">
</p>


Unified Open Source Coin Registry (Same interface for all possible coins, tokens)

#### Demo

[WEB3 Wallet](https://chrome.google.com/webstore/detail/web3-wallet/ifagkkjladbaocinenklelnaailedikm)

#### Install

```
npm i web3t
rm -rf ./node_modules/bitcore-message/node_modules
```

#### Supports

* BTC (Bitcoin)
* LTC (Litecoin)
* ETH (Ethereum)
* DASH 
* XEM (NEM)
* XRP (Ripple)
* [YOUR_COIN]


#### Example
----

```Javascript 

var buildWeb3t = require('web3t');

function testnet(err, web3t) {

  // Standard
  
  web3t.eth.sendTransaction({ to, amount }, cb);

  web3t.btc.sendTransaction({ to, amount }, cb);

  web3t.zec.sendTransaction({ to, amount }, cb);

  web3t.[YOUR_COIN].sendTransaction({ to, amount }, cb);
  
```

#### Create Sender
```Javascript

  web3t.[YOUR_COIN].createSender({ mnemonic, index }, cb); // => { address, privateKey }
  
```

#### Get Balance
```Javascript  

  web3t.[YOUR_COIN].getBalance({ sender }, cb); // => balance
  
```

#### Get History of Transactions
```Javascript 
  
  web3t.[YOUR_COIN].getHistory({ sender }, cb); // => array of txs
  
```

#### Calc Fee 
```Javascript   
  
  web3t.[YOUR_COIN].calcFee({ sender, recepient, amount, data}, cb); // => fee
  
```

#### Create and Send Transaction
```Javascript   

  web3t.[YOUR_COIN].createTransaction({ sender, recepient, amount, data}, cb); // => tx

```

#### Create and Sign Transaction
```Javascript   

  web3t.[YOUR_COIN].signTransaction({ sender, recepient, amount, data}, cb); // => rawtx

```

#### Broadcast the Signed Transaction
```Javascript   

  web3t.[YOUR_COIN].pushTransaction(rawtx, cb); // => rawtx

```

#### Build Testnet
```Javascript 
});

buildWeb3t("testnet", testnet);

```


#### Build Mainnet
```Javascript 
function mainnet(err, web3t) {
    ... 
}

buildWeb3t("mainnet", mainnet);

```

#### Compatibility

`sendTransaction` and `getBalance` are compatible with `web3 wallet` (https://chrome.google.com/webstore/detail/web3-wallet/ifagkkjladbaocinenklelnaailedikm)


#### How to Contibute

1. Please modify only `plugins`, `providers`, `package.json`
2. `plugin` should consists only network information and implements `Interfaces/coin-interface.ts`
3. `provider` should implements `Interfaces/protocol-interface.ts`
4. Send a pull request
5. Any question `a.stegno@gmail.com`

#### Simple Summary
----

The management of different coins should be similar, so that there is no need for each to develop a new infrastructure, and connect it to the existing one


#### Abstract

----

Standard of Coin/Token Common Interface

#### Motivation
----

The same type will help to quickly create a list of supported crypto currency for exchanges, multicurrency wallets and help new projects get the existing infrastructure instantly and effortlessly


#### Backwards Compatibility
----

No known issues

#### Test Cases
----

Left for future work

#### Implementation
----

Left for future work

#### Copyright
----

Copyright and related rights waived via CC0.
