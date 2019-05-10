require! {
    \proof-of-work : pow
}
solver = new pow.Solver!
solve = ({ nonce, complexity }, cb)->
    prefix = Buffer.from nonce, \hex
    nonce = solver.solve complexity, prefix
    cb null, nonce.to-string(\hex)
module.exports = solve