#!/usr/bin/env bash

prog="./exampleprog.sh"
kf="etc/secret.key"
if [ ! -f "${kf}" ]; then
    cat /dev/urandom | tr -dc 'a-zA-Z0-9!-+' | fold -w 50 | head -n 1 > "${kf}"
fi
secret=$(cat "${kf}")
listen_addy="127.0.0.1"
listen_port="8888"
ciphers='HIGH:!aNULL:!eNULL'
certfn="certs/$(echo "${secret}" | sha256sum | cut -d " " -f1)"
key="${certfn}.key"
crt="${certfn}.crt"
csr="${certfn}.csr"
subj="/C=US/ST=Nope Lane/L=Nopeville/O=Nope/OU=Nope Department/CN=${listen_addy}"
logfile="log/ncat.log"

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
    rm -fv ${csr}
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
#opts+=("-vvvv")
opts+=("--ssl-ciphers ${ciphers}")
opts+=("--sh-exec '${prog}'")
#opts+=("--exec '${prog}'")
cmd="ncat ${opts[@]} ${listen_addy} ${listen_port}"
echo "${cmd}"
${cmd}
