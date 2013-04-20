#!/bin/bash

TOKEN_REGEX='[vV]?[cC]\+\+(\p{N}[\p{N}xX])?|[%#-]?[\p{L}\p{M}_][\p{L}\p{M}\p{N}\p{Pc}\p{Pd}\p{Pf}\p{Pi}\.:'\''_-]*[\p{L}\p{M}\p{N}_%]|[cCfF]#|<[^<>,\p{Z}]+>'

if [ "$#" -ne 0 ]; then
  echo "usage: ${0}" >&2
  exit 1
fi

if [ -z "${MALLET_HOME}" ]; then
  MALLET=mallet
else
  MALLET="${MALLET_HOME}"/bin/mallet
fi

IMPORT_DIR_ARGS="\
  --keep-sequence \
  --remove-stopwords \
  --token-regex ${TOKEN_REGEX}"

${MALLET} import-dir \
  --input train \
  --output train.vectors \
  ${IMPORT_DIR_ARGS}

${MALLET} import-dir \
  --input test \
  --output test.vectors \
  --use-pipe-from train.vectors \
  ${IMPORT_DIR_ARGS}
