#!/usr/bin/env bash

listen_addy="127.0.0.1"
listen_port="8888"
super_secret="foo bar flubber you should probably make me complex... and stuff"
ciphers='HIGH:!aNULL:!eNULL'
base_dir="/var/tmp"
base_fn="${base_dir}/$(echo "${super_secret}" | sha256sum | cut -d " " -f1)"
key="${base_fn}.key"
crt="${base_fn}.crt"
csr="${base_fn}.csr"
subj="/C=US/ST=Fuckoff Lane/L=Fuckoffville/O=Nope/OU=Nope Department/CN=${listen_addy}"
logfile="/var/tmp/ncat.log"

mk_key() {
    key=$1
    crt=$2
    csr=$3
    subj=$4
    tmpkey=$(mktemp)
    rand=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!-+' | fold -w 50 | head -n 1)
    openssl genrsa -des3 -passout pass:"${rand}" -out ${tmpkey} 2048
    openssl rsa -passin pass:"${rand}" -in ${tmpkey} -out ${key}
    rm -fv ${tmpkey}
    openssl req -new -key ${key} -out ${csr} -subj "${subj}"
    openssl x509 -req -days 365 -in ${csr} -signkey ${key} -out ${crt}
}

if [[ ! -f ${key} ]]; then
    echo "Generating certificate: ${key}"
    mk_key "${key}" "${crt}" "${csr}" "${subj}"
fi


opts=()
opts+=("-4")
opts+=("--listen ")
opts+=("--output ${logfile}")
opts+=("--append-output")
opts+=("--keep-open")
opts+=("--ssl")
opts+=("--ssl-cert ${crt}")
opts+=("--ssl-key ${key}")
opts+=("--recv-only")
opts+=("-vvvvvvvvvvv")
opts+=("--ssl-ciphers ${ciphers}")
cmd="ncat ${opts[@]} ${listen_addy} ${listen_port}"
echo "${cmd}"
${cmd}

#waittime=1
#opts+=("--wait ${waittime}")
#opts+=("--max-conns 10")
#opts=("--sh-exec ${dprog}")
#opts=("--nodns")
#idletime=1
#opts+=("--idle-timeout ${idletime}")
#opts+=("--crlf")
#--ssl-trustfile        PEM file containing trusted SSL certificates
