#!/usr/bin/env bash
# 单机 8 卡 全参数微调（ms-swift v4.4.1，DeepSpeed ZeRO-3 分片省显存）
# 全参训练显存占用大，7B 用 8 卡 zero3 大约可行；更大的模型请调小 max_length / 用 zero3-offload
# 用法（在容器内）：bash examples/sft_8gpu_full.sh
set -euo pipefail

NPROC=8
GPUS=0,1,2,3,4,5,6,7
MODEL=Qwen/Qwen2.5-7B-Instruct
DATASET='AI-ModelScope/alpaca-gpt4-data-zh#2000'
OUTPUT=/workspace/workdir/output/sft-8gpu-full
GLOBAL_BS=64
PER_DEVICE_BS=1

GRAD_ACCUM=$(( GLOBAL_BS / (NPROC * PER_DEVICE_BS) ))

CUDA_VISIBLE_DEVICES=$GPUS \
NPROC_PER_NODE=$NPROC \
swift sft \
    --model "$MODEL" \
    --tuner_type full \
    --dataset $DATASET \
    --torch_dtype bfloat16 \
    --attn_impl flash_attn \
    --num_train_epochs 1 \
    --per_device_train_batch_size $PER_DEVICE_BS \
    --per_device_eval_batch_size $PER_DEVICE_BS \
    --gradient_accumulation_steps $GRAD_ACCUM \
    --learning_rate 1e-5 \
    --max_length 2048 \
    --eval_steps 100 \
    --save_steps 100 \
    --save_total_limit 2 \
    --logging_steps 5 \
    --warmup_ratio 0.05 \
    --dataloader_num_workers 4 \
    --gradient_checkpointing_kwargs '{"use_reentrant": false}' \
    --deepspeed zero3 \
    --output_dir "$OUTPUT" \
    --system 'You are a helpful assistant.'
