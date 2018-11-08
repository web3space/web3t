require! {
    \prelude-ls : { map, pairs-to-obj, split, tail }
}
get-mode = (config)->
    return config.split(\,).0 if typeof! config is \String
    return get-mode config.mode if typeof! config is \Object
    \testnet
parse-mapping-string = (config)->
    all = config.split(\,).map(-> it.trim!)
    return {} if not all.length is 1
    all
        |> tail
        |> map split ' for '
        |> map -> [it.1, it.0]
        |> pairs-to-obj
get-mapping = (config)->
    return parse-mapping-string config if typeof! config is \String
    return config.network-mapping ? {} if typeof! config is \Object
    {}
module.exports = (config)->
    mode = get-mode config
    mapping = get-mapping config
    get-mode-for = (symbol)->
        mapping[symbol] ? mode
    { get-mode-for }