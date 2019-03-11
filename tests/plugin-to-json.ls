require! {
    \../plugins/gobyte-coin.ls
    fs : { read-file-sync, write-file-sync }
}

text = JSON.stringify gobyte-coin, null, 4
write-file-sync './gobyte-coin.json', text