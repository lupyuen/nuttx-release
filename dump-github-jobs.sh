#!/usr/bin/env bash
## Dump all the GitHub Actions Jobs

## For Testing:
## date=2024-10-21
date=$(date -u +'%Y-%m-%d')
repo=apache/nuttx
run_id=22837803838 ## From databaseId

## Set the GitHub Token: export GITHUB_TOKEN=...
## Any Token with Read-Access to NuttX Repo will do:
## "public_repo" (Access public repositories)
. $HOME/github-token.sh

    gh pr list \
      --repo $repo \
      --limit 1000 \
      --search "created:$date" \
      --json   id,url,updatedAt,title,additions,assignees,author,autoMergeRequest,baseRefName,changedFiles,closed,closedAt,createdAt,deletions,files,headRefName,headRefOid,headRepository,headRepositoryOwner,isDraft,labels,mergeCommit,mergeStateStatus,mergeable,mergedAt,mergedBy,milestone,number,state

## Result
# [
#   {
#     "additions": 1320,
#     "assignees": [],
#     "author": {
#       "id": "MDQ6VXNlcjY1MzIwMjg=",
#       "is_bot": false,
#       "login": "jasonbu",
#       "name": ""
#     },
#     "autoMergeRequest": null,
#     "baseRefName": "master",
#     "changedFiles": 20,
#     "closed": false,
#     "closedAt": null,
#     "createdAt": "2026-03-06T10:01:56Z",
#     "deletions": 24,
#     "files": [
#       {
#         "path": "arch/arm/include/imx9/imx95_irq.h",
#         "additions": 3,
#         "deletions": 3
#       },
#       {
#         "path": "arch/arm64/include/imx9/imx95_irq.h",
#         "additions": 3,
#         "deletions": 3
#       },
#       {
#         "path": "arch/arm64/src/common/CMakeLists.txt",
#         "additions": 1,
#         "deletions": 0
#       },
#       {
#         "path": "arch/arm64/src/imx9/CMakeLists.txt",
#         "additions": 3,
#         "deletions": 1
#       },
#       {
#         "path": "arch/arm64/src/imx9/Kconfig",
#         "additions": 3,
#         "deletions": 0
#       },
#       {
#         "path": "arch/arm64/src/imx9/hardware/imx95/imx95_ccm.h",
#         "additions": 753,
#         "deletions": 0
#       },
#       {
#         "path": "arch/arm64/src/imx9/hardware/imx95/imx95_gpio.h",
#         "additions": 61,
#         "deletions": 0
#       },
#       {
#         "path": "arch/arm64/src/imx9/hardware/imx95/imx95_pinmux.h",
#         "additions": 50,
#         "deletions": 0
#       },
#       {
#         "path": "arch/arm64/src/imx9/hardware/imx95/imx95_pll.h",
#         "additions": 197,
#         "deletions": 0
#       },
#       {
#         "path": "arch/arm64/src/imx9/hardware/imx9_ccm.h",
#         "additions": 1,
#         "deletions": 0
#       },
#       {
#         "path": "arch/arm64/src/imx9/hardware/imx9_gpio.h",
#         "additions": 1,
#         "deletions": 0
#       },
#       {
#         "path": "arch/arm64/src/imx9/hardware/imx9_pinmux.h",
#         "additions": 1,
#         "deletions": 0
#       },
#       {
#         "path": "arch/arm64/src/imx9/imx9_gpiobase.c",
#         "additions": 1,
#         "deletions": 2
#       },
#       {
#         "path": "arch/arm64/src/imx9/imx9_usdhc.c",
#         "additions": 63,
#         "deletions": 6
#       },
#       {
#         "path": "boards/arm64/imx9/imx95-a55-evk/include/board.h",
#         "additions": 24,
#         "deletions": 3
#       },
#       {
#         "path": "boards/arm64/imx9/imx95-a55-evk/src/CMakeLists.txt",
#         "additions": 4,
#         "deletions": 0
#       },
#       {
#         "path": "boards/arm64/imx9/imx95-a55-evk/src/Makefile",
#         "additions": 4,
#         "deletions": 0
#       },
#       {
#         "path": "boards/arm64/imx9/imx95-a55-evk/src/imx9_bringup.c",
#         "additions": 48,
#         "deletions": 0
#       },
#       {
#         "path": "boards/arm64/imx9/imx95-a55-evk/src/imx9_usdhc.c",
#         "additions": 85,
#         "deletions": 0
#       },
#       {
#         "path": "drivers/mmcsd/mmcsd_sdio.c",
#         "additions": 14,
#         "deletions": 6
#       }
#     ],
#     "headRefName": "imx95_emmc8bit",
#     "headRefOid": "95d44356ea31a03c76208790987d05da674abe1c",
#     "headRepository": {
#       "id": "R_kgDOLHs-vw",
#       "name": "nuttx"
#     },
#     "headRepositoryOwner": {
#       "id": "MDQ6VXNlcjY1MzIwMjg=",
#       "login": "jasonbu"
#     },
#     "id": "PR_kwDODZiUac7IdLQM",
#     "isDraft": false,
#     "labels": [
#       {
#         "id": "LA_kwDODZiUac8AAAABsqOt8A",
#         "name": "Arch: arm",
#         "description": "Issues related to ARM (32-bit) architecture",
#         "color": "DC5544"
#       },
#       {
#         "id": "LA_kwDODZiUac8AAAABsqO1YA",
#         "name": "Arch: arm64",
#         "description": "Issues related to ARM64 (64-bit) architecture",
#         "color": "DC5544"
#       },
#       {
#         "id": "LA_kwDODZiUac8AAAABsqR34A",
#         "name": "Area: Drivers",
#         "description": "Drivers issues",
#         "color": "0075ca"
#       },
#       {
#         "id": "LA_kwDODZiUac8AAAABvj_dNA",
#         "name": "Size: XL",
#         "description": "The size of the change in this PR is very large. Consider breaking down the PR into smaller pieces.",
#         "color": "FEF2C0"
#       },
#       {
#         "id": "LA_kwDODZiUac8AAAABw8LvAA",
#         "name": "Board: arm64",
#         "description": "",
#         "color": "F9D0C4"
#       }
#     ],
#     "mergeCommit": null,
#     "mergeStateStatus": "CLEAN",
#     "mergeable": "MERGEABLE",
#     "mergedAt": null,
#     "mergedBy": null,
#     "milestone": null,
#     "number": 18501,
#     "state": "OPEN",
#     "title": "arch/arm64/imx95-a55: add GPIO and eMMC (USDHC) support with partition table parsing",
#     "updatedAt": "2026-03-09T08:57:41Z",
#     "url": "https://github.com/apache/nuttx/pull/18501"
#   },
#   {
#     "additions": 356,
#     "assignees": [],
#     "author": {
#       "id": "MDQ6VXNlcjYyODUwMDkx",
#       "is_bot": false,
#       "login": "linguini1",
#       "name": "Matteo Golin"
#     },
#     "autoMergeRequest": null,
#     "baseRefName": "master",
#     "changedFiles": 3,
#     "closed": false,
#     "closedAt": null,
#     "createdAt": "2026-03-06T05:54:19Z",
#     "deletions": 1,
#     "files": [
#       {
#         "path": "Documentation/components/tools/ci/select.rst",
#         "additions": 132,
#         "deletions": 0
#       },
#       {
#         "path": "Documentation/components/tools/index.rst",
#         "additions": 8,
#         "deletions": 1
#       },
#       {
#         "path": "tools/ci/build-selector/select.py",
#         "additions": 216,
#         "deletions": 0
#       }
#     ],
#     "headRefName": "gcd-path",
#     "headRefOid": "c8d55f1c04f8448e7576eca8ccfe548d28f080d4",
#     "headRepository": {
#       "id": "R_kgDOMTJh2w",
#       "name": "nuttx"
#     },
#     "headRepositoryOwner": {
#       "id": "MDQ6VXNlcjYyODUwMDkx",
#       "name": "Matteo Golin",
#       "login": "linguini1"
#     },
#     "id": "PR_kwDODZiUac7IaIun",
#     "isDraft": true,
#     "labels": [
#       {
#         "id": "MDU6TGFiZWwyNDU1MDI2ODAz",
#         "name": "Area: CI",
#         "description": "",
#         "color": "0075ca"
#       },
#       {
#         "id": "LA_kwDODZiUac8AAAABvj_ZzA",
#         "name": "Size: M",
#         "description": "The size of the change in this PR is medium",
#         "color": "FEF2C0"
#       }
#     ],
#     "mergeCommit": null,
#     "mergeStateStatus": "BLOCKED",
#     "mergeable": "MERGEABLE",
#     "mergedAt": null,
#     "mergedBy": null,
#     "milestone": {
#       "number": 9,
#       "title": "CI",
#       "description": "Apache NuttX RTOS CI related tasks.",
#       "dueOn": null
#     },
#     "number": 18500,
#     "state": "OPEN",
#     "title": "tools/ci: Granular build selection tool",
#     "updatedAt": "2026-03-07T11:38:38Z",
#     "url": "https://github.com/apache/nuttx/pull/18500"
#   }
# ]

exit

    gh run list \
      --repo $repo \
      --limit 1000 \
      --created $date \
      --json attempt,conclusion,createdAt,databaseId,displayTitle,event,headBranch,headSha,name,number,startedAt,status,updatedAt,url,workflowDatabaseId,workflowName

## Result:
# "attempt": 1,
# "conclusion": "success",
# "createdAt": "2026-03-09T04:01:49Z",
# "databaseId": 22837803838,
# "displayTitle": "arch/arm64/imx95-a55: add GPIO and eMMC (USDHC) support with partition table parsing",
# "event": "pull_request",
# "headBranch": "imx95_emmc8bit",
# "headSha": "95d44356ea31a03c76208790987d05da674abe1c",
# "name": "Build",
# "number": 53875,
# "startedAt": "2026-03-09T04:01:49Z",
# "status": "completed",
# "updatedAt": "2026-03-09T07:34:48Z",
# "url": "https://github.com/apache/nuttx/actions/runs/22837803838",
# "workflowDatabaseId": 908549,
# "workflowName": "Build"

      curl -L --silent \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/$repo/actions/runs/$run_id/timing \
        | jq '.run_duration_ms'

## Result:
# 12779000

## How to get PR ID???

exit

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

  ## Call GitHub API to get the Job Duration
  ## https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#get-workflow-run-usage
  for run_id in $run_ids; do
    local run_duration_ms=$(
      curl -L --silent \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/$repo/actions/runs/$run_id/timing \
        | jq '.run_duration_ms'
    )
    # Beware of GitHub API Rate Limits
    sleep 1
    if [[ "$run_duration_ms" == "null" ]]; then
      continue
    fi

    ## Extrapolate the Job Duration to Runner Hours
    total_job_hours=$(
      echo "$total_job_hours+($run_duration_ms/1000/60/60)" | bc -l
    )
    local runner_hours=$(
      echo "$duration_hours_to_runner_hours*$run_duration_ms/1000/60/60" | bc -l
    )

    if [[ "$runner_hours" != "0" ]]; then
      local runner_hours_rounded=$(
        printf "%0.1f\n" $(echo "$runner_hours" | bc)
      )
      echo $run_id,$run_duration_ms,$runner_hours_rounded
    fi
  done
}

## Accumulate the Runner Hours for nuttx and nuttx-apps repos
echo run_id,run_duration_ms,runner_hours
total_job_hours=0
add_runner_hours apache/nuttx
add_runner_hours apache/nuttx-apps

## Compute the Full-Time Runners
total_runner_hours=$(
  echo "$duration_hours_to_runner_hours*$total_job_hours" | bc -l
)
fulltime_runners=$(
  echo "$total_runner_hours/$hours" | bc
)
total_job_hours_rounded=$(
  printf "%0.1f\n" $(echo "$total_job_hours" | bc -l)
)
total_runner_hours_rounded=$(
  printf "%0.0f\n" $(echo "$total_runner_hours" | bc -l)
)
echo date=$date
echo hours=$hours
echo total_job_hours=$total_job_hours_rounded
echo total_runner_hours=$total_runner_hours_rounded
echo fulltime_runners=$fulltime_runners
