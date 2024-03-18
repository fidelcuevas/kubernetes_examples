#!/bin/bash
microk8s.helm3 -n hivemr3 install prod oci://registry-1.docker.io/bitnamicharts/mysql \
  --set auth.rootPassword="FscP@2023" \
  --set auth.database="hive_db" \
  --set auth.username="hive" \
  --set auth.password="FscP@2023"
