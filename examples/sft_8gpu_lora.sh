#!/usr/bin/env bash
# 单机 8 卡 LoRA 微调（ms-swift v4.4.1）
# 用法（在容器内）：bash examples/sft_8gpu_lora.sh
# 改模型/数据集/超参直接编辑下面的变量即可。
set -euo pipefail

NPROC=8                                   # 用几张卡
GPUS=0,1,2,3,4,5,6,7                       # 对应的卡号
MODEL=Qwen/Qwen2.5-7B-Instruct            # 换成你要训的模型
DATASET='AI-ModelScope/alpaca-gpt4-data-zh#2000'   # 换成你的数据集，多个用空格分隔
OUTPUT=/workspace/workdir/output/sft-8gpu-lora
GLOBAL_BS=128                             # 期望的全局 batch size（= NPROC * per_device_bs * grad_accum）
PER_DEVICE_BS=2                           # 单卡 batch size，显存不够就调小

# grad_accum = GLOBAL_BS / (NPROC * PER_DEVICE_BS)，自动算好
GRAD_ACCUM=$(( GLOBAL_BS / (NPROC * PER_DEVICE_BS) ))

CUDA_VISIBLE_DEVICES=$GPUS \
NPROC_PER_NODE=$NPROC \
swift sft \
    --model "$MODEL" \
    --tuner_type lora \
    --dataset $DATASET \
    --torch_dtype bfloat16 \
    --attn_impl flash_attn \
    --num_train_epochs 1 \
    --per_device_train_batch_size $PER_DEVICE_BS \
    --per_device_eval_batch_size $PER_DEVICE_BS \
    --gradient_accumulation_steps $GRAD_ACCUM \
    --learning_rate 1e-4 \
    --lora_rank 8 \
    --lora_alpha 32 \
    --target_modules all-linear \
    --max_length 2048 \
    --eval_steps 100 \
    --save_steps 100 \
    --save_total_limit 2 \
    --logging_steps 5 \
    --warmup_ratio 0.05 \
    --dataloader_num_workers 4 \
    --gradient_checkpointing_kwargs '{"use_reentrant": false}' \
    --deepspeed zero2 \
    --output_dir "$OUTPUT" \
    --system 'You are a helpful assistant.'
