
<p align="center">
  <img src="http://res.cloudinary.com/nixar-work/image/upload/v1534729062/Screen_Shot_2018-08-20_at_04.36.54.png">
</p>


Unified Open Source Coin Registry (Same interface for all possible coins, tokens)

#### Install 

```
npm i web3t
```


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
  
  // Functions
  
  web3t.[YOUR_COIN].createSender({ mnemonic, index }, cb); // => { address, privateKey }
  
  web3t.[YOUR_COIN].getBalance({ sender }, cb); // => balance
  
  web3t.[YOUR_COIN].getHistory({ sender }, cb); // => array of txs
  
  web3t.[YOUR_COIN].calcFee({ sender, recepient, amount, data}, cb); // => fee
  
  web3t.[YOUR_COIN].createTransaction({ sender, recepient, amount, data}, cb); // => tx
  
});

buildWeb3t("testnet", testnet);
buildWeb3t("mainnet", mainnet);

```

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
