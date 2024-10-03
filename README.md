# WorkflowHub Submission Action

A GitHub action to submit a workflow repository to WorkflowHub.

## Prerequisites

1. [Create a WorkflowHub account](https://about.workflowhub.eu/docs/how-to-register/)
2. [Create or join an existing WorkflowHub team](https://about.workflowhub.eu/docs/join-create-teams-spaces/)
3. Create a WorkflowHub API token (Menu > My Profile > Actions > API Tokens > New API Token)
4. Add your API token as a secret in GitHub https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions (named either `WORKFLOWHUB_API_TOKEN` or `DEV_WORKFLOWHUB_API_TOKEN` depending on which instance you are submitting to)

## Usage

This action can be used to submit one or more workflows to [WorkflowHub](https://workflowhub.eu) (or other instance).

The default behaviour assumes the repository contains a single valid [Workflow RO-Crate](https://about.workflowhub.eu/Workflow-RO-Crate/), with the `ro-crate-metadata.json` located at the root. 
Your API token and a valid [Team](https://about.workflowhub.eu/docs/space-team-organisation/#what-is-a-team) ID must be passed into the action (See the examples below).

To submit multiple workflows, or a workflow that is not located at the root of the repository, you can create a `.workflowhub.yml` config file.

* For single workflow repositories: provide all the properties at the top-level of the YAML
* For multi-workflow repositories: the top-level of the YAML should contain a `workflows` property, with 1 or more `path`s listed below.

`path` is currently the only supported property, which is path in your repository (relative to the root) where the `ro-crate-metadata.json` can be found. By default this is `.` (at the root itself).

### .workflowhub.yml examples

#### Single workflow with custom path

```yaml
path: workflows/my-workflow
```

#### Multiple workflows

```yaml
workflows: 
  - path: workflows/workflow-1
  - path: workflows/workflow-2
  - path: workflows/workflow-3
```


## Action Examples

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

```yaml
name: Test workflow publishing on dev.WorkflowHub

on: push

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
