# Lab 1 Procedure

Do every step on Ubuntu 24.04. 📸 marks where to take a screenshot. Save screenshots in `screenshots/` with the file name shown.

---

## Part A: Install the tools

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl python3 fontconfig openjdk-21-jre
java -version
git --version
```

### Jenkins (LTS)

```bash
sudo install -d -m 0755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
sudo systemctl enable --now jenkins
sudo systemctl status jenkins        # 📸 01-jenkins-service.png
```

> If `apt update` reports `NO_PUBKEY`, Jenkins has rotated its signing key. Download the current key from https://pkg.jenkins.io/debian-stable/ and run the commands again.

### VS Code

```bash
sudo snap install code --classic
code --version
```

📸 `02-tool-versions.png`: one terminal showing `git --version`, `java -version`, `python3 --version`, `code --version`.

(`scripts/install_tools.sh` runs all of Part A in one go.)

---

## Part B: Configure Git and GitHub

```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --list
```

### SSH key for GitHub

```bash
ssh-keygen -t ed25519 -C "you@example.com"     # press Enter for defaults
cat ~/.ssh/id_ed25519.pub
```

Copy the key into GitHub → Settings → SSH and GPG keys → New SSH key. Then:

```bash
ssh -T git@github.com     # "Hi <username>! You've successfully authenticated"
```

📸 `03-github-ssh.png`

### Create the repository

1. On GitHub, create an **empty** repository named `devops-lab1` (no README).
2. Copy this project folder to Ubuntu (or create the files) and open it in VS Code: `code .`

---

## Part C: Build the repo with meaningful commits

Commit in small logical steps. Each commit should explain *what* changed and *why*.

```bash
cd devops-lab1
git init
git status

git add .gitignore .gitattributes README.md
git commit -m "Initialize repository with README and ignore rules"

git add app/
git commit -m "Add sample Python web app with / and /health endpoints"

git add tests/
git commit -m "Add unit and HTTP tests for the sample app"

git add scripts/
git commit -m "Add install, deploy and smoke-test scripts"

git add Jenkinsfile
git commit -m "Add declarative Jenkins pipeline for build, test and deploy"

git add docs/ screenshots/
git commit -m "Add lab guide and report template"

git log --oneline --graph       # 📸 04-git-log.png

git remote add origin git@github.com:<username>/devops-lab1.git
git branch -M main
git push -u origin main         # 📸 05-github-repo.png (repo page in browser)
```

### Try the app locally before CI

```bash
python3 -m unittest discover -s tests -v    # 📸 06-local-tests.png
python3 app/app.py &
curl http://localhost:8000/health
kill %1
```

### Feature-branch workflow (good practice)

```bash
git checkout -b feature/version-endpoint
# edit something small, e.g. add a test
git add -A
git commit -m "Add test for ..."
git push -u origin feature/version-endpoint
```

Open a Pull Request on GitHub, merge it into `main`, then:

```bash
git checkout main
git pull
```

📸 `07-pull-request.png`

---

## Part D: Set up Jenkins

1. Open http://localhost:8080
2. Unlock Jenkins with the password from:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. Choose **Install suggested plugins** (this includes Git, Pipeline and Timestamper).
4. Create the admin user. 📸 `08-jenkins-dashboard.png`

### Create the pipeline job

1. **New Item** → name `devops-lab1-pipeline` → **Pipeline** → OK
2. **Pipeline** section:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/<username>/devops-lab1.git`
     (public repo: no credentials needed. Private repo: add a GitHub Personal Access Token as a *Username with password* credential.)
   - Branch Specifier: `*/main`
   - Script Path: `Jenkinsfile`
3. Save → **Build Now**

The first build registers the `pollSCM` trigger from the Jenkinsfile. After that, Jenkins checks GitHub every ~2 minutes and builds when it sees a new commit.

📸 `09-job-config.png`
📸 `10-pipeline-stages.png` (Stage View showing all stages green)
📸 `11-console-output.png`
📸 `12-artifacts.png` (archived `sample-app-1.0.N.tar.gz`)

### Verify the deployment

```bash
curl http://localhost:8000/health
curl "http://localhost:8000/?name=Jenkins"
ls /var/lib/jenkins/deployments/sample-app/releases/
```

📸 `13-deployed-app.png`

---

## Part E: Show that CI works automatically

1. Make a change, for example add a new test in `tests/test_app.py`, then commit and push.
2. Within about 2 minutes Jenkins starts a new build by itself ("Started by an SCM change").
   📸 `14-auto-trigger.png`
3. **Break the build on purpose:** change `self.assertEqual(app.add(2, 3), 5)` to expect `6`, then commit and push.
   The pipeline fails at **Unit Test**, and Deploy never runs, so the last good version stays live.
   📸 `15-failed-build.png`
4. Revert the change:
   ```bash
   git revert HEAD
   git push
   ```
   The next build is green again. 📸 `16-recovered-build.png`

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Jenkins won't start | `sudo journalctl -u jenkins -n 50`. Check that `java -version` shows 17 or 21 |
| Port 8080 already in use | `sudo systemctl edit jenkins` → set `Environment="JENKINS_PORT=8081"` |
| `Permission denied` on a script | The Jenkinsfile already calls scripts with `bash script.sh`, so no `chmod` is needed |
| `bash\r: No such file` | Line endings are CRLF. Run `sed -i 's/\r$//' scripts/*.sh` (`.gitattributes` prevents this) |
| Smoke test fails: port 8000 busy | `sudo lsof -i :8000` and stop the other process |
| App stops after the build finishes | Make sure the `JENKINS_NODE_COOKIE = 'dontKillMe'` line is still in the Deploy stage |
