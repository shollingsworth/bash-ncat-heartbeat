#!/usr/bin/env bash
super_secret="foo bar flubber you should probably make me complex... and stuff"
base_dir="/var/tmp"
base_fn="${base_dir}/$(echo "${super_secret}" | sha256sum | cut -d " " -f1)"
crt="${base_fn}.crt"

dest_host="127.0.0.1"
dest_port="8888"
opts=()
opts+=("-4")
opts+=("--send-only")
opts+=("--ssl")
opts+=("--ssl-verify")
opts+=("--ssl-trustfile ${crt}")
opts+=("-vvvvvvvvvvvvv")
cmd="ncat ${opts[@]} ${dest_host} ${dest_port}"
echo "${cmd}"
echo "${super_secret}" | ${cmd} 
