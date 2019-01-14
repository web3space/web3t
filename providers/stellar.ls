require! {
    \js-stellar-sdk
    \../json-parse.ls
    \../math.ls : { div }
}
#https://www.stellar.org/developers/js-stellar-sdk/reference/examples.html
export calc-fee = ({ network, tx }, cb)->
    cb null
export get-keys = ({ network, mnemonic, index }, cb)->
    cb "Not implemented"
export create-transaction = ({ sender, recepient, amount, amount-fee } , cb)-->
    cb "Not implemented"
export push-tx = ({ network, rawtx } , cb)-->
    cb "Not implemented"
export get-balance = ({ address } , cb)->
    cb "Not implemented"
export get-transactions = ({ network, address}, cb)->
    cb null, []