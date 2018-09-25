require! {
    \./types.ls
}

fields = <[ sendTransaction createAccount calcFee getBalance getHistory sendAllFunds ]>
check-fields = (web3t, cb)->
    
    return cb err if err?
    coins =
        Object.keys web3t
    return cb "Cannot find coins" if coins.filter(-> it not in types).length > 0
    return cb "Cannot find types" if types.filter(-> it not in coins).length > 0
    return cb "Cannot find fields" if coins.filter((t)-> Object.keys(web3t[t]).filter((f)-> f not in fields).length > 0 ).length > 0
    return cb "Cannot find fields" if coins.filter((t)-> fields.filter((f)-> f not in Object.keys(web3t[t])).length > 0 ).length > 0
    cb null
module.exports = check-fields