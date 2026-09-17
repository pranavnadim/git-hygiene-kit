# git-hygiene-kit

A small starter kit for the habit in
[Quick git hygiene that I missed all these years (somehow)](https://pranavnadim.com/quick-git-hygiene-that-i-missed-all-these-years-somehow/).

Local secret scan before the commit. CI scan after the push. Real credentials never in the repo. If a secret already landed in history, rotate it — the hook does not rewind time.

Built as a toy you can copy into a data / notebook / internal-tools repo tonight.

## What this is

```
developer machine
    ↓
pre-commit secret scan
    ↓
git commit
    ↓
push
    ↓
CI secret scan
    ↓
merge
```

Hooks are client-side. Anyone can run `git commit --no-verify`. That is why CI still exists.

## 10-minute setup

Needs `git`, `python3`, and either Homebrew or pip.

```bash
# 1. copy these files into your repo (or use this repo as a template)
cp .pre-commit-config.yaml .gitleaks.toml .gitignore .env.example .

# 2. install the hook runner + scanner
pip install pre-commit
# scanner is pulled by the hook; optional local binary:
#   brew install gitleaks
#   or: https://github.com/gitleaks/gitleaks/releases

# 3. install the hook into THIS repo
pre-commit install

# 4. scan what is already on disk
pre-commit run --all-files
```

From then on, `git commit` runs Gitleaks on the staged diff. A lookalike AWS key, GitHub token, OpenAI key, private key, or database password fails the commit.

## Files

| File | Why |
| --- | --- |
| `.pre-commit-config.yaml` | Runs Gitleaks on every commit |
| `.gitleaks.toml` | Allowlist for obvious fixtures / example strings |
| `.gitignore` | Keeps `.env`, keys, notebooks checkpoints out |
| `.env.example` | Names only, no values |
| `.github/workflows/secret-scan.yml` | Second line of defense |
| `tools/make_env_example.py` | Builds `.env.example` from a local `.env` without copying secrets |
| `demo/simulate_leak.sh` | Shows the scanner catching a fake key — nothing is committed |

## Demo the failure without leaking anything

```bash
bash demo/simulate_leak.sh
```

That script writes a temporary file with a *documented fake* AWS example key, runs the scanner against it, then deletes the file. You should see a finding. The repo stays clean.

## Notebook / data-engineer extras

`.gitignore` already drops:

- `.env`, `.env.*`, `credentials.json`, `*.pem`, `*.p12`
- `.ipynb_checkpoints/`
- `dask-worker-space/`, `.pytest_cache/`, `__pycache__/`

If a secret file is **already tracked**, `.gitignore` will not save you:

```bash
git rm --cached path/to/.env
# then add the pattern to .gitignore and commit that
```

If the secret is **already in history**, rotate/revoke it immediately, even on a branch that never reached `main`. Then run a history scan (`gitleaks detect`) and treat the key as public.

## Generate a safe `.env.example`

```bash
python3 tools/make_env_example.py .env > .env.example
```

Values are replaced with empty placeholders. Comments and key names are kept.

## Org pattern

1. This kit in every service / analytics repo.
2. Branch protection + required CI check.
3. Platform secret scanning (GitHub Secret Protection, etc.) as a third net.
4. Rotation runbook: leak → revoke → rewrite only if policy says so → new key in a secret manager, never in git.

## Not covered on purpose

This kit does not rewrite history, rotate cloud keys, or replace a secret manager. It only stops the *next* accidental commit and gives CI a chance to stop the *next* push.
