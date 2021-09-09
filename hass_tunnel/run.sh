#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
KEY_PATH=/data/.ssh

HOSTNAME=$(jq --raw-output ".hostname" $CONFIG_PATH)
SSH_PORT=$(jq --raw-output ".ssh_port" $CONFIG_PATH)
USERNAME=$(jq --raw-output ".username" $CONFIG_PATH)
REMOTE_FORWARDING=$(jq --raw-output ".remote_forwarding[]" $CONFIG_PATH)
LOCAL_FORWARDING=$(jq --raw-output ".local_forwarding[]" $CONFIG_PATH)
OTHER_SSH_OPTIONS=$(jq --raw-output ".other_ssh_options" $CONFIG_PATH)
MONITOR_PORT=$(jq --raw-output ".monitor_port" $CONFIG_PATH)
SERVER_ALIVE_INTERVAL=$(jq --raw-output ".server_alive_interval" $CONFIG_PATH)
SERVER_ALIVE_COUNT_MAX=$(jq --raw-output ".server_alive_count_max" $CONFIG_PATH)
GATETIME=$(jq --raw-output ".gatetime" $CONFIG_PATH)
USE_SHARE_FOLDER=$(jq --raw-output ".use_share_folder" $CONFIG_PATH)

export AUTOSSH_GATETIME=$GATETIME

echo "[DEBUG] Start"

# Use host share folder for keys
if [ "$USE_SHARE_FOLDER" = true ] ; then
    KEY_PATH=/share/.ssh
fi

# Generate key
if [ ! -d "$KEY_PATH" ]; then
    echo "[INFO] Setup private key"
    mkdir -p "$KEY_PATH"
    ssh-keygen -b 4096 -t rsa -N "" -f "${KEY_PATH}/addon_autossh_key"
else
    echo "[INFO] Restore private_keys"
fi

echo "[INFO] public key is:"
cat "${KEY_PATH}/addon_autossh_key.pub"

command_args="-M ${MONITOR_PORT} -N -q -o ServerAliveInterval=${SERVER_ALIVE_INTERVAL} -o ServerAliveCountMax=${SERVER_ALIVE_COUNT_MAX} ${USERNAME}@${HOSTNAME} -p ${SSH_PORT} -i ${KEY_PATH}/addon_autossh_key"

if [ ! -z "$REMOTE_FORWARDING" ]; then
  while read -r line; do
    command_args="${command_args} -R $line"
  done <<< "$REMOTE_FORWARDING"
fi

if [ ! -z "$LOCAL_FORWARDING" ]; then
  while read -r line; do
    command_args="${command_args} -L $line"
  done <<< "$LOCAL_FORWARDING"
fi

echo "[INFO] testing ssh connection"
ssh -o StrictHostKeyChecking=no -p $SSH_PORT $HOSTNAME 2>/dev/null || true

echo "[INFO] listing host keys"
ssh-keyscan -p $SSH_PORT $HOSTNAME || true

command_args="${command_args} ${OTHER_SSH_OPTIONS}"

echo "[INFO] command args: ${command_args}"

# start autossh
/usr/bin/autossh ${command_args}
