module.exports = (obj, cb)->
    try
        cb null, JSON.parse(obj)
    catch err
        cb err