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

# Train the LDA on the training question / answer pairs.

${MALLET} train-topics \
  --input train.vectors \
  \
  --output-model topic-model."${NUM_TOPICS}".out \
  --output-state topic-state."${NUM_TOPICS}".gz \
  --inferencer-filename inferencer."${NUM_TOPICS}".out \
  \
  --num-topics "${NUM_TOPICS}" \
  --optimize-interval 10 \
  \
  --output-topic-keys topic-keys."${NUM_TOPICS}".txt
