#!/usr/bin/env bash
# Role-based users and groups (least privilege) for the insurance company lab.
set -euo pipefail

# group            user
declare -A ROLES=(
  [security]=sahar_sec       # security administrator
  [it_support]=mohamed_it    # IT support
  [finance]=ahmed_finance    # finance department (SFTP only)
  [sinistres]=karim_sinistre # claims department (SFTP only)
  [audit_ext]=paul_audit     # external auditor
)

groupadd -f sshusers           # only members of this group may use SSH

for group in "${!ROLES[@]}"; do
  user=${ROLES[$group]}
  groupadd -f "$group"
  id "$user" &>/dev/null || useradd -m -s /bin/bash -G "$group" "$user"
  # password expires every 90 days, warning 7 days before
  chage -M 90 -W 7 "$user"
  # force a password change at first login
  passwd -e "$user" >/dev/null
done

# Only the security admin gets SSH access and sudo rights
usermod -aG sshusers,sudo sahar_sec

# Home directories readable only by their owner
chmod 700 /home/*
