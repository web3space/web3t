require! {
    \superagent
    \superagent-proxy : extend-proxy
}
extend-proxy(superagent)
cors-service =
    get: ({ args, type}, cb)->
        instance = superagent.get("https://cors-anywhere.herokuapp.com/#{args.0}", args.1)
        instance.type(type) if type?
        instance.timeout({ deadline: 5000 }).end cb
proxy-servers =
    * \http://207.176.218.185:1321
    * \http://207.176.218.193:1321
    * \http://168.63.43.102:3128
    ...
make-random = (length)->
    return 0 if length is 0
    max = length - 1
    Math.round(Math.random! * max)
try-proxy = ({ method, args, type, err }, cb)->
    num = make-random proxy-servers.length
    return cb err if not superagent[method]?
    instance = superagent[method](args.0, args.1)
    instance.proxy proxy-servers[num]
    instance.type(type) if type?
    err2, data <- instance.timeout({ deadline: 10000 }).end
    return cb null, data if not err2
    m = cors-service[method]
    return cb err, data if not m?
    return m { args, type }, cb if m?
    cb err, data
build-request = (method)-> (...args)->
    original-request = superagent[method]
    $ = {}
    $.timeout = (timeout)->
        $._timeout = timeout
        $
    $.type = (type)->
        $._type = type
        $
    $.end = (cb)->
        instance = original-request.apply(original-request, args)
        instance.type($._type) if $._type?
        instance.timeout($._timeout) if $._timeout?
        err, data <- instance.end
        return try-proxy({ method, args, type: $._type, err }, cb) if err?
        cb err, data
    $
export post = build-request \post
export put  = build-request \put
export get  = build-request \get