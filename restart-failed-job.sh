#!/usr/bin/env bash
## Find the latest failed job for today. Restart it.
for (( ; ; )); do
  for repo in \
    NuttX/nuttx \
    nuttxpr/nuttx \
    nuttxpr/nuttx-apps
  do
    ## Find the latest failed job for today
    echo repo=$repo
    date=$(date -u +'%Y-%m-%d')
    run_list="
      $(gh run list \
        --repo $repo \
        --limit 1 \
        --created $date \
        --status failure \
        --json databaseId,name,displayTitle,conclusion \
        --jq '.[].databaseId')
    "
    ## Restart the failed job
    echo run_list=$run_list
    for run_id in $run_list; do
      echo Restarting $run_id
      gh run rerun --repo $repo --debug --failed $run_id
    done  
  done
  ## Wait a while
  date
  sleep 500
done
