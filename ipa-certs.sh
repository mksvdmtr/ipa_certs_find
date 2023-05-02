#!/bin/bash 

set -e

CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%m)
STOP_YEAR=2023
START_DAY=28 # Рекомендуемые значения 1-28. Не реализована логика вычисления последнего дня месяца.
STOP_MONTH=12
OUT_FILE_NAME=/tmp/ipa_certs_validnotafter_$(date +%d_%m_%Y-%H_%M).out
SUBJECT=".test.local"

for y in $(seq ${CURRENT_YEAR} ${STOP_YEAR})
do
        ny=${y}
        for m in $(seq ${CURRENT_MONTH} ${STOP_MONTH})
        do
                if [ ${m} -lt 12 ]; then
                        nm=$((${m}+1))
                elif [ ${m} -eq 12 ]; then 
                        nm=1
                        CURRENT_MONTH=1 
                        if [ ${y} -ne ${STOP_YEAR} ]; then
                                ny=$((${y}+1))
                        fi
                        if [ ${y} -eq ${STOP_YEAR} ]; then
                                break
                        fi
                fi

                if date -d "${m}/${START_DAY}/${y}" > /dev/null && date -d "${nm}/${START_DAY}/${ny}" > /dev/null; then
                        ipa cert-find --status=VALID --validnotafter-from=${y}-${m}-${START_DAY}  --validnotafter-to=${ny}-${nm}-${START_DAY}  --subject=${SUBJECT} --all >> ${OUT_FILE_NAME}
                else
                        exit 1
                fi
        done

done

grep -i "subject: cn=" -A15 ${OUT_FILE_NAME} | \
        grep -ivP \
        "kerberos:|issuer:|upn:|fingerprint|principal name:|other name:|issuing ca:|certificate:|certificate chain:|entries returned:|certificates matched:|owner service:|revoked:|status:|not before:|serial number \(" | \
        cat -s | sed 's/^ *//' > ${OUT_FILE_NAME}.filtered.txt

