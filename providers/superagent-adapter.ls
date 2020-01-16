require! {
    \cross-fetch : fetch
    \qs : { stringify }
}

json-parse = (text, cb)->
    try
        cb null, JSON.parse(text)
    catch err
        cb err
        

json-stringify = (model, cb)->
    try
        cb null, JSON.stringify(model)
    catch err
        cb err

as-callback = (p, cb)->
    #p.then (res)-> res
    p.catch (err) -> cb err
    p.then (data)->
        cb null, data

form-encoded = (data, cb)->
    res = stringify data
    cb null, res

get-body = (headers, data, cb)->
    return json-stringify data, cb if headers["Content-Type"] is "application/json"
    return form-encoded data, cb if headers["Content-Type"] is "application/x-www-form-urlencoded"
    cb "header #{headers['Content-Type']} is not supported"

make-body = (method, headers, data, cb)->
    return cb null if method not in <[ POST PUT ]>
    err, body <- get-body headers, data
    return cb err if err?
    cb null, { method, body, headers }

get-type = (type)->
    | type is "application/json" => "application/json"
    | type is "json" => "application/json"
    | type is "form" => "application/x-www-form-urlencoded"
    | _ => type
    
make-api = (method)-> (url, data)->
    $ = {}
    headers = {
        "Content-Type": "application/json"
    }
    $.type = (type)->
        headers["Content-Type"] = get-type type
    $.timeout = (timeout)->
        $._timeout = timeout
        $
    $.set = (header, value)->
        headers[header] = value
        $
    $.end = (cb)->
        real-data = data ? {}
        err, body <- make-body method, headers, real-data
        return cb err if err?
        p = fetch url, body
        err, data <- as-callback p
        return cb err if err?
        return cb "expected data" if not data?
        err, text <- as-callback data.text!
        return cb err if err?
        err, body <- json-parse text
        #return cb err if err?
        cb null, { body, text }
        $
    $

post = make-api \POST

get  = make-api \GET

put  = make-api \PUT

module.exports = { get, post, put }

cb = console.log
#
#err, data <- post "http://web3.space:8085/wallet/VLcEHRJwhBZPRVQHV1vTGLsypcwgcaKFYVc/txs", {} .end
#return cb err if err?
#cb null, data
