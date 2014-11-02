#!/bin/bash
keys=$(wget -qO- https://github.com/$(whoami).keys)
echo "$keys" | while read -r key
do
    if [ -f "${HOME}/.ssh/authorized_keys" ] && ! grep "$key" "${HOME}/.ssh/authorized_keys" &> /dev/null
    then
        echo "$key" >> "${HOME}/.ssh/authorized_keys"
    fi
done
