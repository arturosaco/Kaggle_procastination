export MALLET_HOME=/Applications/mallet-2.0.7/
alias mallet="/Applications/mallet-2.0.7/bin/mallet"

NUM_TOPICS="${1}"

mallet import-dir --input ./data/mallet/texts_train \
  --output ./data/output_mallet/train.mallet."${NUM_TOPICS}" \
  --keep-sequence --remove-stopwords


mallet train-topics \
  --input ./data/output_mallet/train.mallet."${NUM_TOPICS}" \
  --output-model ./data/output_mallet/topic-model."${NUM_TOPICS}".out \
  --output-state ./data/output_mallet/topic-state."${NUM_TOPICS}".gz \
  --num-topics "${NUM_TOPICS}" \
  --optimize-interval 10 \
  --inferencer-filename ./data/output_mallet/inferencer."${NUM_TOPICS}".out \
  --output-topic-keys ./data/output_mallet/topic-keys."${NUM_TOPICS}".txt \
  --output-doc-topics ./data/output_mallet/doc-topics."${NUM_TOPICS}".txt

