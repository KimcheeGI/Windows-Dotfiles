# Windows Terminal Dotfile Package

This package contains a portable Windows Terminal settings configuration and deployment examples for CI/CD automation.

## Contents

- `settings.json` — your Windows Terminal settings file
- `install.ps1` — PowerShell deployment script for Windows
- `install.sh` — cross-platform install script for WSL / Git Bash
- `ansible/` — Ansible role example
- `puppet/` — Puppet module example
- `chef/` — Chef cookbook example

## Usage

### Manual deployment

1. Clone or copy this repository to the target machine.
2. Run `install.ps1` in PowerShell as your user.

### Ansible

Use `ansible/playbook.yml` or the role under `ansible/roles/windows_terminal` to deploy the settings.

### Puppet

Use the module under `puppet/windows_terminal` and include `windows_terminal` in your node manifest.

### Chef

Use the cookbook under `chef/windows_terminal` and include the recipe `windows_terminal::default`.

## Notes

- This package is designed to work with Windows Terminal installed from the Microsoft Store.
- The current `settings.json` is based on your existing Windows Terminal configuration.
- Adjust the install scripts and automation manifests as needed for your environment.
