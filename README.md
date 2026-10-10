# ci-workflows

Shared GitHub Actions workflows for every repo I own, personal and org. Each repo keeps a short caller; the logic lives here, so one change here reaches every repo.

Callers pin `@v1`. The `v1` tag moves forward only after `ci` (this repo's self-test) is green on `main`.

## Workflows

| Workflow | Use it for |
|---|---|
| `test.yml` | Running a repo's own test command, with optional toolchain setup (`uv`, `bun`, `node`, `java`) |
| `static.yml` | Syntax gate for repos without tests: `.py` parses, `.json` is valid, `.sh` passes `bash -n` and shellcheck errors, `.mjs` passes `node --check` |
| `pick-runner.yml` | Run on a self-hosted runner when one with the given labels is online; otherwise fall back to a hosted runner |

## Examples

Hosted Linux, Python:

```yaml
name: test
on:
  push:
    branches: [main]
  pull_request:
permissions:
  contents: read
jobs:
  test:
    uses: AltDoug/ci-workflows/.github/workflows/test.yml@v1
    with:
      setup: uv
      command: uv run pytest -q
```

Self-hosted Windows box with hosted fallback:

```yaml
jobs:
  pick:
    uses: AltDoug/ci-workflows/.github/workflows/pick-runner.yml@v1
    with:
      labels: '["self-hosted","Windows","my-windows-box"]'
      fallback: windows-latest
      force-hosted: ${{ vars.CI_HOSTED == 'true' }}
    secrets:
      RUNNER_PICK_TOKEN: ${{ secrets.RUNNER_PICK_TOKEN }}
  test:
    needs: pick
    uses: AltDoug/ci-workflows/.github/workflows/test.yml@v1
    with:
      runs-on: ${{ needs.pick.outputs.runs-on }}
      setup: uv
      command: uv run pytest -q
```

`RUNNER_PICK_TOKEN` is a fine-grained token with **Administration: read** on the calling repo, because the built-in `GITHUB_TOKEN` cannot list runners. Every failure path (no secret, an API error, an expired token, no matching runner online) falls back to hosted, so a broken token costs hosted minutes but never blocks a PR.

## Rules

- **Self-hosted runners serve private repos only.** On a public repo, anyone's pull request would run code on the machine.
- **Third-party actions are pinned to a commit SHA**, with the version in a comment. Dependabot proposes the bumps.
- **No secrets live in this repo.** Callers pass them explicitly.
