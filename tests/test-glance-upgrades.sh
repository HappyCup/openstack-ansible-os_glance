#!/usr/bin/env bash

# Copyright 2016, Rackspace US, Inc.
#
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

# WARNING:
# This file is use by all OpenStack-Ansible roles for testing purposes.
# Any changes here will affect all OpenStack-Ansible role repositories
# with immediate effect.

# PURPOSE:
# This script executes test Ansible playbooks required for performing
# an upgrade test of the os_neutron role.
# Due to the way Ansible caches and handles modules, we need to run
# separate Ansible runs to ensure the "upgrade" uses the new
# "neutron_migrations_facts" module, instead of the cached version
# used when deploying the previous Neutron version.

## Shell Opts ----------------------------------------------------------------

set -e

## Vars ----------------------------------------------------------------------

export WORKING_DIR=${WORKING_DIR:-$(pwd)}
export ROLE_NAME=${ROLE_NAME:-''}

export ANSIBLE_PARAMETERS=${ANSIBLE_PARAMETERS:-"-vvv"}
export TEST_PLAYBOOK=${TEST_PLAYBOOK:-$WORKING_DIR/tests/test-upgrade-pre.yml}
export TEST_CHECK_MODE=${TEST_CHECK_MODE:-false}
export TEST_IDEMPOTENCE=${TEST_IDEMPOTENCE:-false}

export COMMON_TESTS_PATH="${WORKING_DIR}/tests/common"
export OSA_OPS_DIR="${WORKING_DIR}/openstack-ansible-ops"
export BOWLING_BALL_DIR="${OSA_OPS_DIR}/bowling_ball"

echo "ANSIBLE_OVERRIDES: ${ANSIBLE_OVERRIDES}"
echo "ANSIBLE_PARAMETERS: ${ANSIBLE_PARAMETERS}"
echo "TEST_PLAYBOOK: ${TEST_PLAYBOOK}"
echo "TEST_CHECK_MODE: ${TEST_CHECK_MODE}"
echo "TEST_IDEMPOTENCE: ${TEST_IDEMPOTENCE}"

## Functions -----------------------------------------------------------------

function execute_ansible_playbook {

  export ANSIBLE_CLI_PARAMETERS="${ANSIBLE_PARAMETERS}"
  CMD_TO_EXECUTE="ansible-playbook ${TEST_PLAYBOOK} $@ ${ANSIBLE_CLI_PARAMETERS}"

  echo "Executing: ${CMD_TO_EXECUTE}"
  echo "With:"
  echo "    ANSIBLE_INVENTORY: ${ANSIBLE_INVENTORY}"
  echo "    ANSIBLE_LOG_PATH: ${ANSIBLE_LOG_PATH}"

  ${CMD_TO_EXECUTE}

}

## Main ----------------------------------------------------------------------

# Ensure that the Ansible environment is properly prepared
source "${COMMON_TESTS_PATH}/test-ansible-env-prep.sh"

# Prepare environment for the initial deploy of previous Glance
# No upgrading or testing is done yet.
export TEST_PLAYBOOK="${WORKING_DIR}/tests/test-upgrade-pre.yml"
export ANSIBLE_LOG_PATH="${ANSIBLE_LOG_DIR}/ansible-execute-glance-install.log"

# Execute the setup of previous Glance
execute_ansible_playbook

# Prepare the environment for the upgrade of Glance
export TEST_PLAYBOOK="${WORKING_DIR}/tests/test-upgrade-post.yml"
export ANSIBLE_LOG_PATH="${ANSIBLE_LOG_DIR}/ansible-execute-glance-upgrade.log"

# Execute the upgrade of Glance including testing/benchmarking
execute_ansible_playbook
