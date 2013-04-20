#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "usage: ${0} <zip-file>" >&2
  exit 1
fi

# Unzip the question / answer files.

unzip -u -D -q "${1}" '*.txt'

# Create a folder of training question / answer pairs.

mkdir -p train

awk 'NR > 1 { print $2 }' itemID_train.txt | while read ITEM_ID; do
  FILE="texts/${ITEM_ID}/${ITEM_ID}_a.txt"
  # [ ! -f "${FILE}" ] && echo "Warning: No text file for training itemID ${ITEM_ID}" && continue
  [ ! -f "${FILE}" ] && continue
  install -C --mode=0644 "${FILE}" "train/${ITEM_ID}.txt"
done || exit

# Create a folder of test questions.

mkdir -p test

awk 'NR > 1 { print $2 }' itemID_test.txt | while read ITEM_ID; do
  FILE="texts/${ITEM_ID}/${ITEM_ID}_q.txt"
  # [ ! -f "${FILE}" ] && echo "Warning: No text file for test itemID ${ITEM_ID}" && continue
  [ ! -f "${FILE}" ] && continue
  install -C --mode=0644 "${FILE}" "test/${ITEM_ID}.txt"
done || exit
