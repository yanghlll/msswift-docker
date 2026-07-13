#!/usr/bin/env bash
# 一键启动：clone 源码（如缺）→ build 镜像 → 后台起容器 → 进入 shell
set -euo pipefail
cd "$(dirname "$0")"

MSSWIFT_VERSION=v4.4.1   # 与 Dockerfile 中的依赖版本保持一致

if [ ! -d ms-swift ]; then
    echo ">>> Cloning ms-swift ${MSSWIFT_VERSION} source to ./ms-swift ..."
    git clone -b "${MSSWIFT_VERSION}" https://github.com/modelscope/ms-swift.git
fi

mkdir -p workdir "${HOME}/.cache/huggingface" "${HOME}/.cache/modelscope"

echo ">>> Building image & starting container ..."
docker compose up -d --build

echo ">>> Entering container (再次进入可执行: docker exec -it msswift bash)"
docker exec -it msswift bash
