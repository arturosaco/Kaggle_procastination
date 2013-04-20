#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "usage: ${0} <num-topics> <num-top-words>" >&2
  exit 1
fi

NUM_TOPICS="${1}"
NUM_TOP_WORDS="${2}"

if [ -z "${MALLET_HOME}" ]; then
  MALLET=mallet
else
  MALLET="${MALLET_HOME}"/bin/mallet
fi

${MALLET} train-topics \
  --no-inference \
  --input-model topic-model."${NUM_TOPICS}".out \
  --num-top-words "${NUM_TOP_WORDS}" \
  --xml-topic-phrase-report topic-word-weights."${NUM_TOPICS}".xml
