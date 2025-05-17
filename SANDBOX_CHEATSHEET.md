Sandbox Cheatsheet
Quick reference guide for working with the Sandbox project using Pi Project Switcher.

Switching to Sandbox
Use the switcher to enter sandbox context:

~/pi-switch.sh sandbox

Recommended alias for quick switching:

alias piswitch='source ~/pi-switch.sh'

Then use: piswitch sandbox

Venv Handling
🐍 Sandbox has its own virtual environment.

When switching to sandbox:

Existing venv (from other projects) is deactivated.

Sandbox's venv is activated.

Switching to a project without a venv will still deactivate any active venv cleanly.

Project Scaffolding
To create a new project with standard folders:

~/pi-newproject.sh <projectname>

This creates:

config/

data/

docs/

scripts/

venv/ (empty, ready to init)

Venv Setup for New Projects
Initialize venv in new project:

python3 -m venv venv

Register venv in projects.json:

Add "venv": true under the project entry.

Example projects.json snippet:
"sandbox": {
"path": "/home/pi/projects/sandbox",
"venv": true
}

Context Behavior
Switching projects updates:

Working directory (cd to project path)

Active venv (deactivates old, activates new)

Environment variables if defined

Re-switching to the same project will not stack venvs.

Projects without a venv entry will not attempt activation.

Pro Tip
Use piswitch <projectname> for all context switching.

Confirm active venv with:

echo $VIRTUAL_ENV
