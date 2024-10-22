#!/usr/bin/env bash
## Estimate the consumed GitHub Full-Time Runners for the day so far (by UTC time).
## We Accumulate the GitHub Job Duration and Extrapolate the GitHub Runner Hours.

## Job Duration to Runner Hours is inflated slightly
duration_hours_to_runner_hours=8

## For Testing:
## date=2024-10-21
## hours=24
date=$(date -u +'%Y-%m-%d')
hours=$(( 1+$(date -u +'%H') ))

## Set the GitHub Token: export GITHUB_TOKEN=...
. $HOME/github-token.sh

## Accumulate the Job Duration and Extrapolate the Runner Hours
function add_runner_hours {
  local repo=$1
  local run_ids=$(
    gh run list \
      --repo $repo \
      --limit 1000 \
      --created $date \
      --json databaseId,createdAt,displayTitle,name \
      --jq '.[].databaseId'
  )

  for run_id in $run_ids; do
    # echo run_id=$run_id
    local run_duration_ms=$(
      curl -L --silent \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/$repo/actions/runs/$run_id/timing \
        | jq '.run_duration_ms'
    )
    if [[ "$run_duration_ms" == "null" ]]; then
      continue
    fi
    # echo run_duration_ms=$run_duration_ms
    local runner_hours=$(
      bc -e "$duration_hours_to_runner_hours*$run_duration_ms/1000/60/60"
    )
    # echo runner_hours=$runner_hours
    if [[ "$runner_hours" != "0" ]]; then
      echo $run_id,$run_duration_ms,$runner_hours
      total_runner_hours=$(( $total_runner_hours+$runner_hours ))
    fi
  done
}

## Accumulate the Runner Hours for nuttx and nuttx-apps repos
echo run_id,run_duration_ms,runner_hours
total_runner_hours=0
add_runner_hours apache/nuttx
add_runner_hours apache/nuttx-apps

## Compute the Full-Time Runners
fulltime_runners=$(
  bc -e "$total_runner_hours/$hours"
)
echo date=$date
echo hours=$hours
echo total_runner_hours=$total_runner_hours
echo fulltime_runners=$fulltime_runners
