require! {
    \bignumber.js
    \prelude-ls : { map, pairs-to-obj }
}
math = ($)-> (x, y)->
    try 
        new bignumber(x)[$](y).to-fixed!
    catch err
        throw "#{x} #{$} #{y} = #{err}"
module.exports =
    <[ plus minus times div ]>
        |> map -> [it, math(it)]
        |> pairs-to-obj