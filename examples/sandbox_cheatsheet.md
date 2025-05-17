🛠️ Sandbox Command Pack (Pi Project Switcher)
🚀 Switching to Sandbox (Project Context)
Run:

~/pi-switch.sh sandbox

🐍 Activating Sandbox venv Manually
Run:

source ~/projects/sandbox/venv/bin/activate

📝 Creating a Handy Alias for Sandbox venv Activation
Run:

echo "alias sandboxvenv='source ~/projects/sandbox/venv/bin/activate'" >> ~/.bashrc

source ~/.bashrc

Then later:

sandboxvenv

🏗️ Creating a New Project Scaffold (pi-newproject)
Run:

~/pi-newproject.sh <projectname>

Example:

~/pi-newproject.sh testproj

🛠️ Updating Registry to Enable venv Activation
Run:

jq '.projects.sandbox.venv = true' ~/.pi-project-switcher/projects.json > ~/.pi-project-switcher/tmp.json && mv ~/.pi-project-switcher/tmp.json ~/.pi-project-switcher/projects.json

🌐 Linking to a Git Remote
Run:

git remote add origin https://github.com/yourusername/yourrepo.git

git push -u origin master

🔗 Checking Git Remote Connection
Run:

git remote -v

🐍 Creating venv in Sandbox
Run:

cd ~/projects/sandbox

python3 -m venv venv

📦 Upgrading Pip Inside venv
Run:

./venv/bin/pip install --upgrade pip setuptools wheel

📦 Installing Packages in venv (Example: requests)
Run:

./venv/bin/pip install requests

🕒 Setting Up Weekly apt Upgrade Reminder (Crontab)
Run:

crontab -e

Inside crontab, add:

@weekly /usr/bin/apt update && /usr/bin/apt list --upgradable

Confirm with:

crontab -l

🕵️ Verifying Python & Pip Point to venv
Run:

which python

which pip

Expected Output:

/home/pi/projects/sandbox/venv/bin/python

/home/pi/projects/sandbox/venv/bin/pip

🔍 Git Status Check
Run:

git status

📝 Initial Commit Example
Run:

git add .

git commit -m "Initial commit: Sandbox scaffolded."

✅ Final Notes
🏖️ Sandbox is your safe zone for testing Pi Project Switcher workflows.

💡 Pro Tip
To scaffold more projects cleanly:

~/pi-newproject.sh <newprojectname>
