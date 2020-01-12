require! {
    \bip39
}

seed = bip39.mnemonic-to-seed-hex "asdf asdf asdf sfd asdf "
console.log seed