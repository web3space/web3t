require! {
    \../plugins/gobyte-coin.js
    fs : { read-file-sync, write-file-sync }
}

text = JSON.stringify gobyte-coin, null, 4
write-file-sync './gobyte-coin.json', text