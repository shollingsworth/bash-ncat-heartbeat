#!/usr/bin/env bash

#@TODO input validation

tfile=$(mktemp)
cat - > ${tfile}
trap "rm -f ${tfile}" EXIT
ts=$(date +%s)

kf="./etc/secret.key"
err="log/err.log"
state="log/state.log"
secret=$(cat "${kf}" | base64 -w0)

param_secret=$(cat ${tfile} | cut -d ":" -f1)
param_host=$(cat ${tfile} | cut -d ":" -f2)

conn_info="${NCAT_REMOTE_ADDR}.${NCAT_REMOTE_PORT}:${NCAT_LOCAL_ADDR}.${NCAT_LOCAL_PORT}:${NCAT_PROTO}"
if [[ "${param_secret}" != "${secret}" ]]; then
    echo "${ts}:$(cat ${tfile}):${conn_info}" >> ${err}
else
    echo "${ts}:${param_host}:${conn_info}" >> ${state}
fi
