#!/bin/bash

TOKEN_REGEX='[vV]?[cC]\+\+(\p{N}[\p{N}xX])?|[%#-]?[\p{L}\p{M}_][\p{L}\p{M}\p{N}\p{Pc}\p{Pd}\p{Pf}\p{Pi}\.:'\''_-]*[\p{L}\p{M}\p{N}_%]|[cCfF]#|<[^<>,\p{Z}]+>'

if [ "$#" -ne 1 ]; then
  echo "usage: ${0} <directory>" >&2
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
  --input "${1}" \
  ${IMPORT_DIR_ARGS} \
  --print-output
