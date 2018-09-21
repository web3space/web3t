
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
* [ANY_COIN]

#### Init Builder

```Javascript

var buildWeb3t = require('web3t');

```

#### Build Testnet

```Javascript 
function testnet(err, web3t) {
    ... 

}

buildWeb3t("testnet", testnet);

```


#### Build Mainnet

```Javascript 
function mainnet(err, web3t) {
    ... 
}

buildWeb3t("mainnet", mainnet);

```

#### Example
----

```Javascript 

web3t.eth.sendTransaction({ to, amount }, cb);

web3t.btc.sendTransaction({ to, amount }, cb);

web3t.zec.sendTransaction({ to, amount }, cb);

web3t.[ANY_COIN].sendTransaction({ to, amount }, cb);
  
```

#### Create Sender

```Javascript

var cb => (err, { address, privateKey, publicKey }) {
  
}

web3t.[ANY_COIN].createSender({ mnemonic, index }, cb);
  
```

#### Get Balance
Get Balance by sender object ({ address, privateKey })
Usually it does not need the private key but coins like monero needs decrypt data to read the balance

```Javascript  

  var cb => (err, balance) {
  
  }

  web3t.[ANY_COIN].getBalance({ sender }, cb);
  
```

#### Get History of Transactions
List of all transactions. Same result structure for all coins

```Javascript 
  
  var cb => (err, transactions) {
  
  }
  
  web3t.[ANY_COIN].getHistory({ sender }, cb);
  
```

#### Calc Fee 
You need to define the default fee in `plugin` but for NEM, Monero and other coins you need to calculate the fee

```Javascript   
  
  var cb => (err, amountFee) {
  
  }
  
  web3t.[ANY_COIN].calcFee({ sender, recepient, amount, data}, cb); // => fee
  
```

#### Create and Send Transaction
This transaction consists of `create`, `sign`, `push` transaction

```Javascript   

  var cb => (err, receipt) {
  
  }

  web3t.[ANY_COIN].createTransaction({ sender, recepient, amount, data}, cb); // => tx

```

#### Create and Sign Transaction
In some cases you need to have the hex of transaction before for some reason before you push it

```Javascript   

  var cb => (err, rawtx) {
  
  }

  web3t.[ANY_COIN].signTransaction({ sender, recepient, amount, data}, cb); // => rawtx

```

#### Broadcast the Signed Transaction
Push the signed transaction (hex) into blockchain

```Javascript   

  var cb => (err, receipt) {
  
  }

  web3t.[ANY_COIN].pushTransaction(rawtx, cb); // => rawtx

```



#### Compatibility

`sendTransaction` and `getBalance` are compatible with  [https://chrome.google.com/webstore/detail/web3-wallet/ifagkkjladbaocinenklelnaailedikm](Web3 Wallet)


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


#### Copyright
----

Copyright and related rights waived via CC0.
