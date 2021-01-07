#!/bin/sh -e

# 1 - value to search for
# 2 - value to replace
# 3 - file to perform replacement inline
prop_replace () {
  target_file=${3:-${nifi_registry_props_file}}
  echo 'replacing target file ' ${target_file}
  sed -i -e "s|^$1=.*$|$1=$2|"  ${target_file}
}

# NIFI_HOME is defined by an ENV command in the backing Dockerfile
export nifi_registry_props_file=${NIFI_REGISTRY_HOME}/conf/nifi-registry.properties
export hostname=$(hostname)