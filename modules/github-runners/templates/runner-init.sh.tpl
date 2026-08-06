#!/bin/bash
set -euo pipefail

RUNNER_USER="ghrunner"
RUNNER_VERSION="${runner_version}"
GITHUB_OWNER="${github_owner}"
GITHUB_REPO="${github_repo}"
RUNNER_LABELS="${runner_labels}"
RUNNER_GROUP="${runner_group}"
REG_TOKEN="${registration_token}"
RUNNERS_PER_VM="${runners_per_vm}"

id -u "$RUNNER_USER" &>/dev/null || useradd -m -s /bin/bash "$RUNNER_USER"

apt-get update -y
apt-get install -y curl jq tar liblttng-ust1 libkrb5-3 zlib1g libicu-dev

for i in $(seq 1 "$RUNNERS_PER_VM"); do
  RUNNER_DIR="/home/$RUNNER_USER/actions-runner-$i"
  mkdir -p "$RUNNER_DIR"
  cd "$RUNNER_DIR"

  curl -o actions-runner-linux-x64.tar.gz -L \
    "https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz"
  tar xzf actions-runner-linux-x64.tar.gz
  chown -R "$RUNNER_USER":"$RUNNER_USER" "$RUNNER_DIR"

  sudo -u "$RUNNER_USER" ./config.sh \
    --url "https://github.com/$${GITHUB_OWNER}/$${GITHUB_REPO}" \
    --token "$${REG_TOKEN}" \
    --name "$(hostname)-$i" \
    --labels "$${RUNNER_LABELS}" \
    --runnergroup "$${RUNNER_GROUP}" \
    --work "_work" \
    --unattended \
    --replace

  ./svc.sh install "$RUNNER_USER"
  ./svc.sh start
done
