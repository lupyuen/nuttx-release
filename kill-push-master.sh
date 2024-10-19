#!/usr/bin/env bash
## Kill all Merge Jobs pushing to master branch.
## Change `protect_id` to the Run ID of the Merge Job that shall be restarted and shouldn't be cancelled
## We shall update `protect_id` Two Times Per Day at 00:00, 12:00 UTC
## Run IDs are here: https://github.com/apache/nuttx/actions/workflows/build.yml?query=branch%3Amaster+event%3Apush
protect_id=11412628885
for (( ; ; ))
do
  ## For apache/nuttx: Kill all Merge Jobs pushing to master branch
  run_list="
    $(gh run list --repo apache/nuttx --event push --branch master --status queued      --json databaseId --jq '.[].databaseId')
    $(gh run list --repo apache/nuttx --event push --branch master --status in_progress --json databaseId --jq '.[].databaseId')
  "
  echo run_list=$run_list
  for run_id in $run_list; do
    echo run_id=$run_id
    if [[ "$run_id" != "$protect_id" ]]; then
      echo Killing $run_id
      gh run cancel --repo apache/nuttx $run_id
    fi
  done

  ## UPDATE: We no longer restart the Protected Job.
  ## Previously: Restart the Protected Job, in case a new merge has cancelled it.
  ## Ignore the error: "cannot be rerun; its workflow file may be broken"
  ## gh run rerun --repo apache/nuttx --debug --failed $protect_id

  ## For apache/nuttx-apps: Kill all Merge Jobs pushing to master branch
  run_list="
    $(gh run list --repo apache/nuttx-apps --event push --branch master --status queued      --json databaseId --jq '.[].databaseId')
    $(gh run list --repo apache/nuttx-apps --event push --branch master --status in_progress --json databaseId --jq '.[].databaseId')
  "
  echo run_list=$run_list
  for run_id in $run_list; do
    echo run_id=$run_id
    if [[ "$run_id" != "$protect_id" ]]; then
      echo Killing $run_id
      gh run cancel --repo apache/nuttx-apps $run_id
    fi
  done

  ## Wait a while
  date
  sleep 60
done
