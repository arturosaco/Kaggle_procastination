#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "usage: ${0} <num-topics>" >&2
  exit 1
fi

NUM_TOPICS="${1}"

if [ -z "${MALLET_HOME}" ]; then
  MALLET=mallet
else
  MALLET="${MALLET_HOME}"/bin/mallet
fi

# Infer topics for the test questions.

${MALLET} infer-topics \
  --inferencer inferencer."${NUM_TOPICS}".out \
  --input test.vectors \
  --output-doc-topics infer-topics."${NUM_TOPICS}".txt
