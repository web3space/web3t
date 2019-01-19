# Examples 

## How To

* Core (Init)

  Init default core coins `btc`,`ltc`,`eth`,`dash` and custom `stt`,`rem`,`xem`,`sprkl`

* Create Account

  Each account requires mnemonic pharse and unique index (integer)

* Get Balance

  Get Balance requires account object ({ address }) to check the it in blockchain via public node
  
* Send Transactions

  Requires account object, recepient (to) and amount
  
## Examples written on [Livscript](livescript.net) Language. This language compiles into Javascript.
   
   You can compile each file into javascript with command 
   
   ```sh
   cd examples
   npm i livescript -g
   lsc -c *.ls
   ```
   
   But if you want to read it please follow the conversion guide
   
   1. Callback Notation
   
   ```Livscript
   err, account <- create-account
   ```
   
   is same as 
   
   ```Javascript 
   create-account(function(err, account) {
       
   });
   ```
   
   2. Import Notation
   
   ```Livscript
   require! {
       \./example-1-core.ls
       \./example-3-create_accounts.ls
   }
   ```
   
   is same as 
   
   ```Javascript 
   import example-1-core from "./example-1-core.ls";
   import example-3-create_accounts from "./example-3-create-accounts.ls";
   ```
   
   3. Naming Notation
   
   ```Livscript
   const var-name = 1
   ```
   
   is same as 
   
   ```Javascript 
   const varName = 1;
   ```

   4. Error Notation
   
   ```Livscript
   return cb err if err?
   ```
   
   is same as 
   
   ```Javascript 
   if(err) {
       return cb(err);
   }
   ```