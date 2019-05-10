require! {
    \proof-of-work : pow
}

array-to-hex = (arr)->
    arr.map(-> +it.to-string(16)).join('')

verify = ({ nonce, complexity, solution }, cb)->
    size = 1024
    n = 16
    prefix = Buffer.from(nonce, 'hex')
    validity = 60000
    verifier = new pow.Verifier { size, n, complexity, prefix, validity }
    hex = 
        | solution.index-of(',') > -1 => solution.split(',')
        | _ => solution
    result = verifier.check Buffer.from(hex, "hex")
    cb null, result
module.exports = verify