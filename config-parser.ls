require! {
    \prelude-ls : { map, pairs-to-obj, split, tail }
}
get-mode = (config)->
    return config.split(\,).0 if typeof! config is \String
    return get-mode config.mode if typeof! config is \Object
    \testnet
parse-mapping-string = (config)->
    console.log { config }
    all = config.split(\,).map(-> it.trim!)
    return {} if not all.length is 1
    all
        |> tail
        |> map split ' for '
        |> map -> [it.1, it.0]
        |> pairs-to-obj
parse-mapping-object = (config)->
    mapping = parse-mapping-string config.mode 
    mapping <<<< config.network-mapping ? {}
    mapping
get-mapping = (config)->
    return parse-mapping-string config if typeof! config is \String
    return parse-mapping-object config if typeof! config is \Object
    {}
module.exports = (config)->
    mode = get-mode config
    mapping = get-mapping config
    get-mode-for = (symbol)->
        mapping[symbol] ? mode
    { get-mode-for }