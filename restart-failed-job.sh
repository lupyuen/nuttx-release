#!/usr/bin/env bash
## Find the latest failed job for today. Restart it.
for (( ; ; )); do
  for repo in \
    NuttX/nuttx \
    nuttxpr/nuttx \
    nuttxpr/nuttx-apps
  do
    ## Find the running jobs for today
    echo repo=$repo
    date=$(date -u +'%Y-%m-%d')
    running_list="
      $(gh run list \
        --repo $repo \
        --limit 1 \
        --created $date \
        --status queued \
        --json databaseId,name,displayTitle,conclusion \
        --jq '.[].databaseId')
      $(gh run list \
        --repo $repo \
        --limit 1 \
        --created $date \
        --status in_progress \
        --json databaseId,name,displayTitle,conclusion \
        --jq '.[].databaseId')
    "
    running_list=$(echo $running_list | xargs)
    echo running_list=$running_list

    ## Skip if jobs are still running
    if [[ "$running_list" != "" ]]; then
      echo Skipping $repo, jobs are still running
      continue
    fi

    ## Find the latest failed job for today
    failed_list="
      $(gh run list \
        --repo $repo \
        --limit 1 \
        --created $date \
        --status failure \
        --json databaseId,name,displayTitle,conclusion \
        --jq '.[].databaseId')
    "

    ## Restart the failed job
    echo failed_list=$failed_list
    for run_id in $failed_list; do
      echo Restarting $run_id
      gh run rerun --repo $repo --debug --failed $run_id
    done  
  done
  ## Wait a while
  date
  sleep 500
done
