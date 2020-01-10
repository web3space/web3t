require! {
    \bignumber.js
    \prelude-ls : { map, pairs-to-obj }
}
math = ($)-> (x, y)->
    return '..' if x is '..' or y is '..'
    try 
        new bignumber(x)[$](y).to-fixed!
    catch err
        throw "#{x} #{$} #{y} = #{err}"
module.exports =
    <[ plus minus times div ]>
        |> map -> [it, math(it)]
        |> pairs-to-obj
module.exports.from-hex = (hex)->
    new bignumber(hex, 16).to-fixed!