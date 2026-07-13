FROM pytorch/pytorch:2.7.1-cuda12.8-cudnn9-devel

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        git curl wget vim tmux htop openssh-client \
        build-essential ninja-build ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -U pip setuptools wheel packaging ninja

# flash-attn: 自动匹配 torch2.7 + cu12 的预编译 wheel（H100/sm_90 可用），无需本地编译
RUN pip install --no-cache-dir flash-attn==2.8.3 --no-build-isolation

# 先把 ms-swift 的完整依赖装进镜像；容器启动时会被挂载进来的源码以 editable 方式覆盖
# 版本与 start.sh 中 clone 的源码 tag (v4.4.1) 保持一致
RUN pip install --no-cache-dir 'ms-swift[llm]==4.4.1' 'deepspeed<0.19'

# 可选：GRPO 训练 / vLLM 推理加速需要 vllm（镜像会大 ~10GB，需要再取消注释重新 build）
# RUN pip install --no-cache-dir vllm==0.10.0

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
