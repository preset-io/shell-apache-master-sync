#!/usr/bin/env bash

set -e

mkdir -p ~/.ssh
ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts

# Setup our SSH config to use the key spec'd by our Jenkins secret
cat <<EOF >> ~/.ssh/config
host github.com
 HostName github.com
 IdentityFile ${SSH_KEY_GITHUB}
 User git
EOF
