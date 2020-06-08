require! {
    \./superagent-adapter.js : superagent
    \cross-fetch
    #\../pow/pow-solve.js
    \prelude-ls : { keys, each }
}
add-sets = (instance, sets)->
    return if not sets?
    sets |> keys |> each (-> instance.set(it, sets[it]) )
try-with-pow = (instance, data, cb)->
    nonce = data.headers[\pow-nonce]
    complexity = data.headers[\pow-complexity]
    return cb "Not Implemented"
    #err, result <- pow-solve { nonce, complexity }
    return cb err if err?
    instance.set(\pow-result, result).end cb
build-request = (method)-> (...args)->
    #console.log \superagent.type , superagent.type
    original-request = superagent[superagent.type][method]
    $ = {}
    $.timeout = (timeout)->
        $._timeout = timeout
        $
    $.type = (type)->
        $._type = type
        $
    $.set = (name, value)->
        $._set = $._set ? {}
        $._set[name] = value
        $
    $.end = (cb)->
        instance = original-request.apply(original-request, args)
        instance.type($._type) if $._type?
        instance.timeout($._timeout) if $._timeout?
        add-sets instance, $._set
        err, data <- instance.end
        return try-with-pow instance, data, cb if data?status is 401 and data.headers[\www-authenticate] is \pow
        return cb err, data if data?status >= 400
        cb err, data
    $
export post = build-request \post
export put  = build-request \put
export get  = build-request \get