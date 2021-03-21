#!/bin/sh

set -eu

mkdir -p data/preprocessed/UD_Finnish-TDT
mkdir -p data/raw/
mkdir -p data/train
mkdir -p models

echo "Downloading UD_Finnish-TDT"
git clone --branch r2.7 --single-branch --depth 1 https://github.com/UniversalDependencies/UD_Finnish-TDT data/raw/UD_Finnish-TDT

echo "Downloading turku-ner data"
wget https://github.com/TurkuNLP/turku-ner-corpus/archive/v1.0.tar.gz
tar xzf v1.0.tar.gz -C data/raw/
rm v1.0.tar.gz

echo "Convert data to the SpaCy format"
rm -rf data/train/parser/*
for dataset in train dev test
do
    mkdir -p data/train/parser/$dataset
    python tools/preprocess_UD-TDT.py \
	   < data/raw/UD_Finnish-TDT/fi_tdt-ud-$dataset.conllu \
	   > data/preprocessed/UD_Finnish-TDT/fi_tdt-ud-$dataset.conllu

    spacy convert --lang fi -n 6 data/preprocessed/UD_Finnish-TDT/fi_tdt-ud-$dataset.conllu data/train/parser/$dataset
done

echo "Convert ner data"
rm -rf data/train/ner/*
mkdir -p data/train/ner/train
mkdir -p data/train/ner/dev
mkdir -p data/train/ner/test
spacy convert --lang fi -n 6 -c ner data/raw/turku-ner-corpus-1.0/data/conll/train.tsv data/train/ner/train
spacy convert --lang fi -n 6 -c ner data/raw/turku-ner-corpus-1.0/data/conll/dev.tsv data/train/ner/dev
spacy convert --lang fi -n 6 -c ner data/raw/turku-ner-corpus-1.0/data/conll/test.tsv data/train/ner/test
