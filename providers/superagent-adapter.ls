require! {
    \cross-fetch : fetch
    \tor-request : tor
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
clear-timer = (cb)->
    delete cb.timer
    clear-timeout cb.timer
reset-request = (cb)-> ->
    return console.log('ignored reset') if not cb.timer?
    clear-timer cb
    cb "Deadline was reached"
get-cb-with-deadline = (timeout, cb)->
    return cb "timeout.deadline is expected" if typeof! timeout.deadline isnt \Number
    cb.timer = set-timeout reset-request(cb), timeout.deadline
    (err, data)->
        return console.log('ignored response') if not cb.timer?
        clear-timer cb
        cb err, data
make-cross-api = (method)-> (url, data)->
    $ = {}
    headers = {
        "Content-Type": "application/json"
    }
    $._timeout =
        deadline: 30000
    $.type = (type)->
        headers["Content-Type"] = get-type type
    $.timeout = (timeout)->
        $._timeout = timeout
        $
    $.set = (header, value)->
        headers[header] = value
        $
    $.end = (fcb)->
        real-data = data ? {}
        cb = get-cb-with-deadline $._timeout , fcb
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
make-tor-api = (method)-> (url, data)->
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
        tor.setTorAddress("localhost", "9050")
        err, res, text <- tor.request url, body
        err, body <- json-parse text
        #return cb err if err?
        console.log \make-tor-request, method, url, err, body
        cb null, { body, text }
        $
    $
module.exports = 
    all:
        post : make-cross-api \POST
        get  : make-cross-api \GET
        put  : make-cross-api \PUT
    tor:
        post : make-tor-api \POST
        get  : make-tor-api \GET
        put  : make-tor-api \PUT
    type: \all