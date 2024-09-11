# submission-action
GitHub action to submit a workflow repository to WorkflowHub

## Example usage:
```yaml
name: Publish workflows on WorkflowHub

on: push

jobs:
  wfh-submit:
    name: WorkflowHub Submission
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

