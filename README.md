# WorkflowHub Submission Action
A GitHub action to submit a workflow repository to WorkflowHub.

## Prerequisites

1. [Create a WorkflowHub account](https://about.workflowhub.eu/docs/how-to-register/)
2. [Create or join an existing WorkflowHub team](https://about.workflowhub.eu/docs/join-create-teams-spaces/)
3. Create a WorkflowHub API token (Menu > My Profile > Actions > API Tokens > New API Token)
4. Add your API Token as a secret in GitHub https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions (named either `WORKFLOWHUB_API_TOKEN` or `DEV_WORKFLOWHUB_API_TOKEN` depending on which instance you are submitting to)

## Examples

#### Submit workflow to WorkflowHub when a new release is published on GitHub

```yaml
name: Publish workflows on WorkflowHub

on:
  release:
    types: [published]

jobs:
  wfh-submit:
    name: WorkflowHub submission
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Submit workflows
        uses: workflowhub-eu/submission-action@v0
        env:
          API_TOKEN: ${{ secrets.WORKFLOWHUB_API_TOKEN }}
        with:
          team_id: 123
```

#### Test workflow submission using dev.workflowhub.eu

This requires an account, token and team to be created on the WorkflowHub dev/sandbox instance: https://dev.workflowhub.eu

This action is triggered manually: https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-workflow-runs/manually-running-a-workflow

```yaml
name: Test workflow publishing on dev.WorkflowHub

on: workflow_dispatch

jobs:
  wfh-submit:
    name: WorkflowHub submission test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Submit workflows
        uses: workflowhub-eu/submission-action@v0
        env:
          API_TOKEN: ${{ secrets.DEV_WORKFLOWHUB_API_TOKEN }}
        with:
          team_id: 123
          instance: https://dev.workflowhub.eu
```
