#!/bin/bash

CHRONOS_URL="http://localhost"
CHRONOS_PORT="4400"
ALL_JOBS="$(curl -L -X GET ${CHRONOS_URL}:${CHRONOS_PORT}/scheduler/jobs | jq -r '.[] | [ .schedule, .name ]| join(",")' )"
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
