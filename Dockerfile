# syntax=docker/dockerfile:1

# $Source: /home/c/Dropbox/src/docker/transformertests/RCS/Dockerfile,v $
# $Date: 2023/01/02 04:27:34 $
# $Revision: 1.9 $

FROM pytorch/pytorch:1.12.1-cuda11.3-cudnn8-devel as chromadb1

SHELL ["/bin/bash", "-ceoux", "pipefail"]

ARG DEBIAN_FRONTEND=noninteractive
ARG MIRROR1=/var/cache/o31/mirror
ARG WGET1="wget --directory-prefix=$MIRROR1 --force-directories --protocol-directories --timestamping"

# Disable automatic cache cleanup so we can persist the apt cache between build runs
# https://contains.dev/blog/mastering-docker-cache
RUN \
    --mount=type=cache,target=/root/.cache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/o31/mirror,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    <<EOF
  useradd -mp "" -s /bin/bash c
  rm -f /etc/apt/apt.conf.d/docker-clean
  echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
    > /etc/apt/apt.conf.d/keep-cache
  apt update -y && apt upgrade -y
EOF

RUN \
    --mount=type=cache,target=/root/.cache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/o31/mirror,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    <<EOF
  apt install -y libpq-dev sudo wget
EOF

RUN \
    --mount=type=cache,target=/root/.cache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/o31/mirror,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    <<EOF
  pip3 install chromadb ipython psycopg2 sentence_transformers stardate
EOF

COPY --chmod=755 stardate.pl /usr/local/bin/stardate.pl
COPY stringstack.sh /etc/stringstack.sh

# Pre-install models into /home/c/.cache/torch/sentence_transformers
USER c
RUN \
    --mount=type=cache,target=/root/.cache,sharing=locked \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/cache/o31/mirror,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    <<EOF1
  /opt/conda/bin/python3.7 <<EOF2
import chromadb

for m in [
    "all-MiniLM-L6-v2",
    "all-mpnet-base-v2",
    "BAAI/bge-large-en"
]: 
    chromadb.utils.embedding_functions.SentenceTransformerEmbeddingFunction(
        model_name=m)
EOF2
EOF1

# vim: set et ff=unix ft=dockerfile nocp sts=2 sw=2 ts=2: