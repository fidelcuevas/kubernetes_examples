#!/bin/bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR=$(readlink -f $DIR)
YAML_DIR=$BASE_DIR/spark-yaml

source $BASE_DIR/config-run.sh
source $BASE_DIR/spark/env.sh 

run_kubernetes_parse_args $@

if [ $ENABLE_SSL = true ]; then
  create_sparkmr3_ssl_certificate $BASE_DIR/spark/key
fi

if [[ $GENERATE_TRUSTSTORE_ONLY = true ]]; then
  exit 0
fi

# run as the user who has set up ~/.kube/config

microk8s.kubectl create namespace $SPARK_MR3_NAMESPACE

# PersistentVolume
# required if mr3.dag.recovery.enabled=true in mr3-site.xml
if [ $CREATE_PERSISTENT_VOLUME = false ]; then
  echo "do not use PersistentVolume"
else
  microk8s.kubectl create -f $YAML_DIR/workdir-pv.yaml 
  microk8s.kubectl create -n $SPARK_MR3_NAMESPACE -f $YAML_DIR/workdir-pvc.yaml 
fi

# env-secret is used by Spark driver running inside Kubernetes (but not by DAGAppMaster and ContainerWorker)
microk8s.kubectl create -n $SPARK_MR3_NAMESPACE secret generic env-secret --from-file=$BASE_DIR/spark/env.sh
# SPARK_CONF_DIR_CONFIGMAP is used by all of Spark driver, DAGAppMaster, and ContainerWorker (e.g., jgss.conf and krb5.conf)
microk8s.kubectl create -n $SPARK_MR3_NAMESPACE configmap $SPARK_CONF_DIR_CONFIGMAP --from-file=$BASE_DIR/spark/conf/

if [ $CREATE_KEYTAB_SECRET = true ]; then
  microk8s.kubectl create -n $SPARK_MR3_NAMESPACE secret generic $SPARK_KEYTAB_SECRET --from-file=$BASE_DIR/spark/key/
else 
  microk8s.kubectl create -n $SPARK_MR3_NAMESPACE secret generic $SPARK_KEYTAB_SECRET
fi

if [ $CREATE_WORKER_SECRET = true ]; then
  microk8s.kubectl create -n $SPARK_MR3_NAMESPACE secret generic $SPARK_WORKER_SECRET --from-file=$WORKER_SECRET_DIR
else
  microk8s.kubectl create -n $SPARK_MR3_NAMESPACE secret generic $SPARK_WORKER_SECRET
fi
microk8s.kubectl create -f $YAML_DIR/cluster-role.yaml
microk8s.kubectl create -f $YAML_DIR/spark-role.yaml
microk8s.kubectl create -f $YAML_DIR/master-role.yaml
microk8s.kubectl create -f $YAML_DIR/worker-role.yaml
microk8s.kubectl create -f $YAML_DIR/spark-service-account.yaml  # for running run-spark-shell.sh in a Pod inside Kubernetes
if [ $CREATE_SERVICE_ACCOUNTS = true ]; then
  microk8s.kubectl create -f $YAML_DIR/master-service-account.yaml
  microk8s.kubectl create -f $YAML_DIR/worker-service-account.yaml
fi

microk8s.kubectl create clusterrolebinding spark-clusterrole-binding --clusterrole=node-reader --serviceaccount=$SPARK_MR3_NAMESPACE:$SPARK_MR3_SERVICE_ACCOUNT
microk8s.kubectl create rolebinding spark-role-binding --role=spark-role --serviceaccount=$SPARK_MR3_NAMESPACE:$SPARK_MR3_SERVICE_ACCOUNT -n $SPARK_MR3_NAMESPACE

microk8s.kubectl create clusterrolebinding spark-master-clusterrole-binding --clusterrole=node-reader --serviceaccount=$SPARK_MR3_NAMESPACE:$MASTER_SERVICE_ACCOUNT
microk8s.kubectl create rolebinding spark-master-role-binding --role=master-role --serviceaccount=$SPARK_MR3_NAMESPACE:$MASTER_SERVICE_ACCOUNT -n $SPARK_MR3_NAMESPACE

microk8s.kubectl create rolebinding spark-worker-role-binding --role=worker-role --serviceaccount=$SPARK_MR3_NAMESPACE:$WORKER_SERVICE_ACCOUNT -n $SPARK_MR3_NAMESPACE

# reuse CLIENT_TO_AM_TOKEN_KEY if already defined; use a random UUID otherwise
RANDOM_CLIENT_TO_AM_TOKEN_KEY=$(cat /proc/sys/kernel/random/uuid)
export CLIENT_TO_AM_TOKEN_KEY=${CLIENT_TO_AM_TOKEN_KEY:-$RANDOM_CLIENT_TO_AM_TOKEN_KEY}
echo "export CLIENT_TO_AM_TOKEN_KEY=$CLIENT_TO_AM_TOKEN_KEY"

# reuse MR3_APPLICATION_ID_TIMESTAMP if already defined; use a random integer > 0
RANDOM_MR3_APPLICATION_ID_TIMESTAMP=$RANDOM
export MR3_APPLICATION_ID_TIMESTAMP=${MR3_APPLICATION_ID_TIMESTAMP:-$RANDOM_MR3_APPLICATION_ID_TIMESTAMP}
echo "export MR3_APPLICATION_ID_TIMESTAMP=$MR3_APPLICATION_ID_TIMESTAMP"

# reuse ATS_SECRET_KEY if already defined; use a random UUID otherwise
#RANDOM_ATS_SECRET_KEY=$(cat /proc/sys/kernel/random/uuid)
#ATS_SECRET_KEY=${ATS_SECRET_KEY:-$RANDOM_ATS_SECRET_KEY}
#echo "ATS_SECRET_KEY=$ATS_SECRET_KEY"

#
# required for running Spark inside Kubernetes
#

microk8s.kubectl create -n $SPARK_MR3_NAMESPACE configmap client-am-config \
  --from-literal=key=$CLIENT_TO_AM_TOKEN_KEY \
  --from-literal=timestamp=$MR3_APPLICATION_ID_TIMESTAMP \
#  --from-literal=ats-secret-key=$ATS_SECRET_KEY

#
# required for running Spark outside Kubernetes
#

#microk8s.kubectl create -f $YAML_DIR/mr3-service.yaml

#export JAVA_HOME=/usr/jdk64/jdk1.8.0_112
#export PATH=$JAVA_HOME/bin:$PATH

# create a directory for mr3.am.staging-dir to simulate AMK8sClient running inside Kubernetes
mkdir -p /opt/mr3-run/work-dir

