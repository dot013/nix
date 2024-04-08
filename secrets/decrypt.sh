#!/usr/bin/env bash

export SOPS_AGE_KEY_FILE=/home/guz/.config/sops/age/keys.txt

secrets_dir="/home/guz/.nix/secrets"

sops --output $secrets_dir/homelab-lesser-secrets.decrypted.json \
	-d $secrets_dir/homelab-lesser-secrets.json
	

