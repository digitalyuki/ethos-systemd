#!/bin/bash

CHRONOS_URL="http://localhost"
CHRONOS_PORT="4400"
CHRONOS_USERNAME="$(etcdctl get /chronos/config/username)"
CHRONOS_PASSWORD="$(etcdctl get /chronos/config/password)"
if [[ "$CHRONOS_USERNAME" != "" && "$CHRONOS_PASSWORD" != "" ]]; then
  $CHRONOS_AUTH="-u ${CHRONOS_USERNAME}:${CHRONOS_PASSWORD}"
else
  $CHRONOS_AUTH=""
fi
ALL_JOBS="$(curl ${CHRONOS_AUTH} -L -X GET ${CHRONOS_URL}:${CHRONOS_PORT}/scheduler/jobs | jq -r '.[] | [ .schedule, .name ]| join(",")' )"
OLD_JOBS="$(echo "$ALL_JOBS" | grep '^R0/')"
OLD_JOB_NAMES="$( echo "$OLD_JOBS" | awk -F ',' '{print $2}' )"
if [[ "$OLD_JOB_NAMES" != "" ]] ; then
  echo -e "Old jobs found:\n$OLD_JOB_NAMES\n"
  for job_name in $OLD_JOB_NAMES ; do 
    echo "Deleting $job_name..."
    curl --write-out '  curl return code: %{http_code}\n' -L -X DELETE ${CHRONOS_URL}:${CHRONOS_PORT}/scheduler/job/${job_name}
  done
else 
  echo "No old jobs to be deleted!"
fi
