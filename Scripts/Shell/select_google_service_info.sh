#!/bin/sh

#  select_google_service_info.sh
#  Manifests
#
#  Created by jumy on 11/9/25.
#  

set -e

ENVIRONMENT="${ENV:-$CONFIGURATION}"
SRC_DIR="${PROJECT_DIR}/Resources/Firebase"
DEST_DIR="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
DEST_PATH="${DEST_DIR}/GoogleService-Info.plist"

echo "Copying GoogleService-Info for environment: ${ENVIRONMENT}"
echo "Configuration: ${CONFIGURATION}"
echo "Source Dir: ${SRC_DIR}"
echo "Destination Dir: ${DEST_DIR}"

case "${ENVIRONMENT}" in
    "DEV" | "Dev" | "dev")
        SOURCE_PATH="${SRC_DIR}/GoogleService-Info-Dev.plist"
        ;;
    "PROD" | "Prod" | "prod" | "Release")
        SOURCE_PATH="${SRC_DIR}/GoogleService-Info-Prod.plist"
        ;;
    *)
        echo "error: Unknown Firebase environment: ${ENVIRONMENT}"
        exit 1
        ;;
esac

if [ ! -f "${SOURCE_PATH}" ]; then
    echo "error: Missing Firebase configuration file at ${SOURCE_PATH}"
    exit 1
fi

mkdir -p "${DEST_DIR}"
cp "${SOURCE_PATH}" "${DEST_PATH}"

echo "Copied ${SOURCE_PATH} to ${DEST_PATH}"
