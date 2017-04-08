#!/usr/bin/env bash

check_interval=1
hf="etc/hosts"
state="log/state.log"
statefile="run/monitor.pid"
transition="log/trans.log"
echo "$$" > ${statefile}
trap "rm -fv ${statefile}" EXIT

previous=""
checkstuff() {
    now=$(date +%s)
    hosts=$(cat "${hf}")
    for i in ${hosts[@]}; do
        host=$(echo "${i}" | cut -d ':' -f1)
        minutes=$(echo "${i}" | cut -d ':' -f2)
        stale=$(echo "${minutes} * 60" | bc -l)
        lstate=$(grep "${host}" "${state}" | tail -1)
        lts=$(echo "${lstate}" | cut -d ':' -f1)
        stale_cnt=$(echo "${now} - ${lts}" | bc -l)
        age=$(echo "${stale} - ${stale_cnt}" | bc)
        if [[ ${age} -lt 0 ]]; then
            echo "BAD:${host}:${age}"
        else
            echo "OK:${host}:${age}"
        fi
    done
}

getstate() {
    echo "${1}" | cut -d ':' -f1,2
}


statdiff() {
    previous="$1"
    current="$1"
    diff -u <(getstate "${current}") <(getstate "${previous}")
}

while ((1)); do
    sleep ${check_interval}
    if [[ -z "${previous}" ]]; then
        previous=$(checkstuff)
    fi
    diff=$(statdiff "${previous}" "$(checkstuff)")
    if [[ -z "${diff}" ]]; then
        echo "nothing to report"
    fi
done
