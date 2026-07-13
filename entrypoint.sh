#!/usr/bin/env bash
set -e

# 把宿主机挂载进来的 ms-swift 源码以 editable 方式安装（--no-deps 秒级完成，幂等）
# 之后在宿主机上改 ./ms-swift 里的代码，容器内直接生效，无需重启
if [ -f /workspace/ms-swift/setup.py ] || [ -f /workspace/ms-swift/pyproject.toml ]; then
    pip install -e /workspace/ms-swift --no-deps -q
    echo "[entrypoint] ms-swift installed in editable mode from /workspace/ms-swift"
else
    echo "[entrypoint] WARNING: /workspace/ms-swift 未挂载源码，使用镜像内 pip 版本的 swift"
fi

exec "$@"
