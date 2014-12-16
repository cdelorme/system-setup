#!/bin/bash

# @todo set hostname (run with sudo, will require password)
# scutil --set HostName "${config_system_hostname}"
# domainname "${config_system_domainname}"

# @todo determine sudo commands first to execute within time limit on password entry

# @todo install dot-files

# @todo generate ssh key

# @todo upload ssh key to github

# @todo generate github api token & append to ~/.bashrc
# keys=$(curl -s -i -u "${GITHUB_USERNAME}:${GITHUB_PASSWORD}" -H "Content-Type: application/json" -H "Accept: application/json" -X GET https://api.github.com/authorizations)
# if echo $keys | grep "homebrew" &> /dev/null
# then
#     token=$(echo "${keys#*homebrew}" | grep token | head -n1 | tr -d '":,' | awk '{print $2}')
# else
#     keys=$(curl -i -u "${GITHUB_USERNAME}:${GITHUB_PASSWORD}" -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"scopes\":[\"gist\",\"repo\",\"user\"],\"note\":\"homebrew\"}" https://api.github.com/authorizations)
#     token=$(echo "$keys" | grep token | head -n1 | tr -d '":,' | awk '{print $2}')
# fi
# if [ -n "$token" ]
# then

#     # push token into .bashrc
#     echo -ne "\n# homebrew github token (remove rate-limiting)\nexport HOMEBREW_GITHUB_API_TOKEN=${token}" >> "$DOWNLOADS/.bashrc"
# fi

# @todo homebrew installation

# @todo homebrew package installation

# @todo download some bin tools
mkdir -p ~/.bin
$dl_cmd ~/.bin/brewgrade "${remote_source}/data/home/.bin/brewgrade"

# @todo setup crontab /w update-keys
chmod +x ~/.bin/brewgrade
echo "@daily ~/.bin/brewgrade" >> ~/.crontab
crontab ~/.crontab

# install golang vim plugin
# which go 2>/dev/null && cp -R "$(go env GOROOT)/misc/vim/" "$DOWNLOADS/.vim"

# @todo vim plugin installation (ctrlp, vim-json)
