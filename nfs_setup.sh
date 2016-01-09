#!/bin/bash

set -e

mounts="${@}"

for mnt in "${mounts[@]}"; do
  src=$(echo $mnt | awk -F':' '{ print $1 }')
  if [ -n "$INSECURE" ]; then
    insecure=",insecure"
  fi
  echo "$src *(rw,sync,no_subtree_check,fsid=0,no_root_squash${insecure})" >> /etc/exports
done

exec runsvdir /etc/sv
