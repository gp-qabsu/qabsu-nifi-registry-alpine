#!/bin/sh -e

prop_replace 'nifi.registry.db.url'                         "${NIFI_REGISTRY_DB_URL:-jdbc:h2:./database/nifi-registry-primary;AUTOCOMMIT=OFF;DB_CLOSE_ON_EXIT=FALSE;LOCK_MODE=3;LOCK_TIMEOUT=25000;WRITE_DELAY=0;AUTO_SERVER=FALSE}"
prop_replace 'nifi.registry.db.driver.class'                "${NIFI_REGISTRY_DB_CLASS:-org.h2.Driver}"
prop_replace 'nifi.registry.db.driver.directory'            "${NIFI_REGISTRY_DB_DIR:-}"
prop_replace 'nifi.registry.db.username'                    "${NIFI_REGISTRY_DB_USER:-nifireg}"
prop_replace 'nifi.registry.db.password'                    "${NIFI_REGISTRY_DB_PASS:-nifireg}"
prop_replace 'nifi.registry.db.maxConnections'              "${NIFI_REGISTRY_DB_MAX_CONNS:-5}"
prop_replace 'nifi.registry.db.sql.debug'                   "${NIFI_REGISTRY_DB_DEBUG_SQL:-false}"