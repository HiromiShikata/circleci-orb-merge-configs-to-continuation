#!/bin/bash

[ -z "$MAIN_BRANCH_NAME" ] && echo "parameter main_branch_name is empty" && exit 1;
[ -z "$SERVICE_DIRECTORIES" ] && echo "parameter service_directories is empty" && exit 1;
[ -z "$CONFIGURATION_FILE_NAME" ] && echo "parameter configuration_file_name is empty" && exit 1;
[ -z "$WORKING_DIRECTORY_NAME" ] && echo "parameter working_directory_name is empty" && exit 1;
[ -z "$CONTINUATION_CONFIG_FILE_NAME" ] && echo "parameter continuation_config_file_name is empty" && exit 1;

mkdir -p "${WORKING_DIRECTORY_NAME}"
git fetch

function cp_config_if_dir_has_diff() {
  dir_name=$1
  if [ "$(git diff "origin/${MAIN_BRANCH_NAME}"...HEAD "$dir_name" | wc -l)" -eq 0 ]; then
    echo "SKIP: ${dir_name}"
    return
  fi
  cp "$dir_name/${CONFIGURATION_FILE_NAME}" "${WORKING_DIRECTORY_NAME}/${dir_name//\//-}-${CONFIGURATION_FILE_NAME}"
  echo "ADD: ${CONFIGURATION_FILE_NAME} for ${dir_name}"
}

for service in ${SERVICE_DIRECTORIES}; do
  cp_config_if_dir_has_diff "$service"
done

ls -la "${WORKING_DIRECTORY_NAME}"
cd "${WORKING_DIRECTORY_NAME}" || exit
# shellcheck disable=SC2046
npx deepmerge-yaml $(ls -A ./) > "${CONTINUATION_CONFIG_FILE_NAME}"
cd - || exit
mv "${WORKING_DIRECTORY_NAME}/${CONTINUATION_CONFIG_FILE_NAME}" ".circleci/$CONTINUATION_CONFIG_FILE_NAME"
rm -rf "${WORKING_DIRECTORY_NAME}"

