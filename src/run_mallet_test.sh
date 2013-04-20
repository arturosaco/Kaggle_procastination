export MALLET_HOME=/Applications/mallet-2.0.7/
alias mallet="/Applications/mallet-2.0.7/bin/mallet"

NUM_TOPICS="${1}"

mallet import-dir --input ./data/mallet/texts_test \
  --output ./data/output_mallet/test.mallet."${NUM_TOPICS}" \
  --keep-sequence --remove-stopwords


mallet infer-topics \
  --inferencer ./data/output_mallet/inferencer."${NUM_TOPICS}".out \
  --input ./data/output_mallet/test.mallet."${NUM_TOPICS}" \
  --output-doc-topics ./data/output_mallet/infer-topics."${NUM_TOPICS}".txt