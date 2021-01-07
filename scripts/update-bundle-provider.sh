#!/bin/sh -e

providers_file=${NIFI_REGISTRY_HOME}/conf/providers.xml
property_xpath='/providers/extensionBundlePersistenceProvider'

add_property() {
  property_name=$1
  property_value=$2

  if [ -n "${property_value}" ]; then
    xmlstarlet ed --inplace --subnode "${property_xpath}" --type elem -n property -v "${property_value}" \
      -i \$prev --type attr -n name -v "${property_name}" \
      "${providers_file}"
  fi
}

xmlstarlet ed --inplace -u "${property_xpath}/property[@name='Extension Bundle Storage Directory']" -v "${NIFI_REGISTRY_BUNDLE_STORAGE_DIR:-./extension_bundles}" "${providers_file}"

case ${NIFI_REGISTRY_BUNDLE_PROVIDER} in
    file)
        xmlstarlet ed --inplace -u "${property_xpath}/class" -v "org.apache.nifi.registry.provider.extension.FileSystemBundlePersistenceProvider" "${providers_file}"
        ;;
    s3)
        xmlstarlet ed --inplace -u "${property_xpath}/class" -v "org.apache.nifi.registry.aws.S3BundlePersistenceProvider" "${providers_file}"
        add_property "Region"                "${NIFI_REGISTRY_S3_REGION:-}"
        add_property "Bucket Name"           "${NIFI_REGISTRY_S3_BUCKET_NAME:-}"
        add_property "Key Prefix"            "${NIFI_REGISTRY_S3_KEY_PREFIX:-}"
        add_property "Credentials Provider"  "${NIFI_REGISTRY_S3_CREDENTIALS_PROVIDER:-DEFAULT_CHAIN}"
        add_property "Access Key"            "${NIFI_REGISTRY_S3_ACCESS_KEY:-}"
        add_property "Secret Access Key"     "${NIFI_REGISTRY_S3_SECRET_ACCESS_KEY:-}"
        add_property "Endpoint URL"          "${NIFI_REGISTRY_S3_ENDPOINT_URL:-}"
        ;;
esac