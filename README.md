# Lab 1: DevOps Foundations & Continuous Integration

A small Python web app with a Jenkins CI/CD pipeline that checks out code from GitHub, builds it, tests it, packages it, deploys it and smoke-tests the deployment. Everything runs on Ubuntu 24.04 LTS.

## Repository layout

```
.
├── app/app.py              # Sample web app (standard library only)
├── tests/test_app.py       # Unit + HTTP tests (unittest)
├── scripts/
│   ├── install_tools.sh    # Installs Git, Java 21, Jenkins, VS Code
│   ├── deploy.sh           # Extracts the build and (re)starts the app
│   └── smoke_test.sh       # Checks /health after deployment
├── Jenkinsfile             # Declarative pipeline (pipeline as code)
├── docs/
│   ├── LAB_GUIDE.md        # Step-by-step procedure with every command
│   └── LAB_REPORT.md       # Report template: commands, stages, observations
└── screenshots/            # Evidence screenshots (see screenshots/README.md)
```

## Endpoints

| Path            | Response                                           |
|-----------------|----------------------------------------------------|
| `/`             | `{"message": "Hello, DevOps!", "time": "..."}`     |
| `/?name=Akash`  | `{"message": "Hello, Akash!", ...}`                |
| `/health`       | `{"status": "UP", "app": "...", "version": "..."}` |

## Run locally

```bash
python3 -m unittest discover -s tests -v   # run tests
python3 app/app.py                         # start on http://localhost:8000
```

## Pipeline stages

`Checkout → Verify Tools → Build → Unit Test → Package → Deploy → Smoke Test`

See [docs/LAB_GUIDE.md](docs/LAB_GUIDE.md) for the full procedure.
