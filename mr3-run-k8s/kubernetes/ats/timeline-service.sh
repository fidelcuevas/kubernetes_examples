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

# ats.yaml and timeline.yaml mount env.sh
# TypeScript code mounts both env.sh and env-secret.sh
source $BASE_DIR/env.sh
if [[ -f "$BASE_DIR/env-secret.sh" ]]; then
  source $BASE_DIR/env-secret.sh
fi

function main {
    cp $BASE_DIR/conf/core-site.xml $BASE_DIR/hadoop/apache-hadoop/etc/hadoop/
    cp $BASE_DIR/conf/log4j.properties $BASE_DIR/hadoop/apache-hadoop/etc/hadoop/
    cp $BASE_DIR/conf/ssl-server.xml $BASE_DIR/hadoop/apache-hadoop/etc/hadoop/
    cp $BASE_DIR/conf/yarn-site.xml $BASE_DIR/hadoop/apache-hadoop/etc/hadoop/

    export YARN_TIMELINESERVER_HEAPSIZE=2048
    export YARN_TIMELINESERVER_OPTS="-Djava.security.krb5.conf=$BASE_DIR/conf/krb5.conf"

    exec $BASE_DIR/hadoop/apache-hadoop/bin/yarn timelineserver
}

main $@
