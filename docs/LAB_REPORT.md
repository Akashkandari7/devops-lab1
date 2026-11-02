# Lab 1 Report: DevOps Foundations & Continuous Integration

**Name:**
**Roll No.:**
**Date(s) performed:**
**GitHub repo:**

## 1. Aim

Set up Git-based source control, build a Jenkins CI/CD pipeline and automate building and deploying a sample application, with a clean commit history and a reproducible pipeline configuration.

## 2. Environment

| Tool | Version (fill from your terminal) |
|---|---|
| Ubuntu | 24.04 LTS |
| Git | |
| Java (OpenJDK) | |
| Jenkins | |
| Python | |
| VS Code | |

## 3. Commands executed

Paste the commands you actually ran, in order. Tip: run `history > commands.txt` at the end of each session.

```bash

```

## 4. Configuration file: Jenkinsfile

See [`Jenkinsfile`](../Jenkinsfile). Explain each part in your own words:

- `agent any`:
- `options`:
- `triggers { pollSCM(...) }`:
- `environment`:
- `post`:

## 5. Pipeline stages

| Stage | What it does | Result / time (from Stage View) |
|---|---|---|
| Checkout | | |
| Verify Tools | | |
| Build | | |
| Unit Test | | |
| Package | | |
| Deploy | | |
| Smoke Test | | |

## 6. Screenshots

| # | Screenshot | File |
|---|---|---|
| 1 | Jenkins service running | `screenshots/01-jenkins-service.png` |
| 2 | Tool versions | `screenshots/02-tool-versions.png` |
| 3 | GitHub SSH auth | `screenshots/03-github-ssh.png` |
| 4 | Git log | `screenshots/04-git-log.png` |
| 5 | GitHub repository | `screenshots/05-github-repo.png` |
| 6 | Local tests | `screenshots/06-local-tests.png` |
| 7 | Pull request | `screenshots/07-pull-request.png` |
| 8 | Jenkins dashboard | `screenshots/08-jenkins-dashboard.png` |
| 9 | Job configuration | `screenshots/09-job-config.png` |
| 10 | Pipeline stage view | `screenshots/10-pipeline-stages.png` |
| 11 | Console output | `screenshots/11-console-output.png` |
| 12 | Archived artifacts | `screenshots/12-artifacts.png` |
| 13 | Deployed app | `screenshots/13-deployed-app.png` |
| 14 | Auto-triggered build | `screenshots/14-auto-trigger.png` |
| 15 | Failed build | `screenshots/15-failed-build.png` |
| 16 | Recovered build | `screenshots/16-recovered-build.png` |

## 7. Observations

Write what **you** saw during the lab. Points to cover:

- How long did a full pipeline run take? Which stage was the slowest?
- How long after a `git push` did Jenkins start a build?
- What happened when a test failed? Did Deploy run? Which version stayed live?
- What does `/health` show after each build (version number)?
- What problems did you hit, and how did you fix them?

## 8. Conclusion

## 9. Viva questions to prepare

- Difference between CI, Continuous Delivery and Continuous Deployment
- Declarative vs scripted pipeline
- Why keep the Jenkinsfile in the repo (pipeline as code)?
- pollSCM vs webhooks: when would you use each?
- What is an artifact, and why fingerprint it?
- `git merge` vs `git rebase`; what `git revert` does
