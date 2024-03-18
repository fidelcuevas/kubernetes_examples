#!/bin/bash
microk8s.helm3 -n hivemr3 install prod oci://registry-1.docker.io/bitnamicharts/postgresql \
  --set global.postgresql.auth.postgresPassword="FscP@2023" \
  --set global.postgresql.auth.username="hive" \
  --set global.postgresql.auth.password="FscP@2023" \
  --set global.postgresql.auth.database="hive_db"
