# Sandbox Cheatsheet

Your quick reference guide for working with the Sandbox project using Pi Project Switcher.

## 🔄 Switching to Sandbox

- Switch to Sandbox context:
  source ~/pi-switch.sh sandbox

- Recommended alias for easy switching:
  alias piswitch='source ~/pi-switch.sh'
  piswitch sandbox

## 🐍 Venv Handling

- Activates Sandbox's venv on switch
- Cleanly deactivates existing venv before activating Sandbox
- Projects without a venv will still trigger a deactivate to keep the environment clean

## 🏗️ Creating a New Project

- Scaffold a new project with:
  ~/pi-newproject.sh <projectname>

- Creates standard folders:
  config/
  data/
  docs/
  scripts/
  venv/ (empty, ready to init)

## 🐍 Setting up venv for New Projects

- Initialize the venv:
  python3 -m venv venv

- Update projects.json to activate venv switching:
  "newproject": {
    "path": "/home/pi/projects/newproject",
    "venv": true
  }

## 🗂️ Project Registry

- Managed in ~/.pi-project-switcher/projects.json
- Controls which projects have venv activation
- Ensures clean context switches between projects

## 🛡️ Context Behavior

- Switching to a project:
  - Changes working directory
  - Deactivates active venv (if any)
  - Activates target project venv (if configured)
  - Loads project-specific environment variables (future feature)

## 💡 Pro Tips

- Use piswitch <projectname> for all project switching
- Confirm active venv with:
  echo $VIRTUAL_ENV
- Avoid manual cd’ing into project folders—always use the switcher for clean context
