#!/usr/bin/env zsh

# Helper utils for locking/unlocking encrypted files using gpg in zsh

# Here is a simple script I setup to quickly encrypt files with GPG. Can't say
# I use this too much now days, but I have it here because its something to
# have in my back pocket. It looks for ~/.gpg-id for the key-id to use.


gpglock() {
    [ ! -f ~/.gpg-id ] && echo "~/.gpg-id file is not set" && return 1
    local infile=$1
    if [ -z "$(echo $infile | grep -E '.+\.gpg$')" ]; then
        local gpg_id=$(cat ~/.gpg-id)
        local outfile="${1}.gpg"
        gpg --output $outfile -r $gpg_id --encrypt $infile
    else
        echo "Trying to encrypt already encrypted file"
    fi
}


gpgunlock() {
    local infile=$1
    if [ -n "$(echo $infile | grep -E '.+\.gpg$')" ]; then
        local outfile=$(echo ${infile} | sed -e 's/\.gpg$//g')
        gpg --output $outfile --decrypt $infile
    else
        echo "Not a valid gpg locked file; Unable to unlock!"
    fi
}
