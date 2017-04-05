#!/usr/bin/env bash

kf="etc/secret.key"
secret=$(cat "${kf}")
certfn="certs/$(echo "${secret}" | sha256sum | cut -d " " -f1)"
crt="${certfn}.crt"

dest_host="127.0.0.1"
dest_port="8888"
opts=()
opts+=("-4")
opts+=("--send-only")
opts+=("--ssl")
opts+=("--ssl-verify")
opts+=("--ssl-trustfile ${crt}")
cmd="ncat ${opts[@]} ${dest_host} ${dest_port}"
#b64=$(echo "blarg" | base64 -w0) #bad test
b64=$(cat "${kf}" | base64 -w0)
param="${b64}:$(hostname)"
echo "${param}" | ${cmd}
