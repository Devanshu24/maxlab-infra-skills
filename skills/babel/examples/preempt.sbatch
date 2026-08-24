#!/bin/bash
# Worked example, not scaffolding. Fit these invariants into the user's launcher:
# - Babel has JobRequeue=1 and preempt uses REQUEUE. Never set --no-requeue;
#   explicit --requeue changes nothing.
# - Startup and resume must be idempotent; the next attempt may run elsewhere.
# - Durable state belongs on /data. Scratch and caches may vanish between attempts.
# - Checkpoint often enough that the worst-case lost work is acceptable; do not rely
#   on shutdown-time checkpointing alone.
# - Publish checkpoints atomically and restore the complete ML state: model,
#   optimizer, scheduler/scaler, RNG, sampler/dataloader position, and global step.
# - Distributed jobs must coordinate checkpoint writers and restore every rank to
#   the same step. Arrays need stable, task-specific run identities.
# - Resume the same experiment-tracker run rather than creating one per attempt.

#SBATCH --job-name=example_ml_run
#SBATCH --partition=preempt
#SBATCH --gres=gpu:1
#SBATCH --time=1-00:00:00
#SBATCH --output=/data/user_data/%u/slurm_logs/%x_%j.out
#SBATCH --error=/data/user_data/%u/slurm_logs/%x_%j.err
#SBATCH --open-mode=append

# Slurm opens logs before this script runs. On a compute node, create the parent
# before submission:
# mkdir -p /data/user_data/$USER/slurm_logs
set -euo pipefail

# Keep this identity stable across manual resubmissions; include
# SLURM_ARRAY_TASK_ID when each array task is a distinct run.
EXPERIMENT=example
RUN_NAME=seed_0
OUT="/data/user_data/$USER/runs/${EXPERIMENT}/${RUN_NAME}"
CKPT="$OUT/checkpoints"
mkdir -p "$CKPT"

# Recreate node-local scratch on every attempt. Cleanup is best-effort only.
SCR="/scratch/$USER/$SLURM_JOB_ID"
mkdir -p "$SCR"/{tmp,xdg,triton,inductor}
export TMPDIR="$SCR/tmp" XDG_CACHE_HOME="$SCR/xdg"
export TRITON_CACHE_DIR="$SCR/triton" TORCHINDUCTOR_CACHE_DIR="$SCR/inductor"
export HF_HOME="/data/user_data/$USER/.hf_cache"
export HF_HUB_CACHE="/data/hf_cache/hub"
export HF_DATASETS_CACHE="/data/hf_cache/datasets"
trap 'rm -rf "$SCR"' EXIT

# Check for resume before any training initialization can overwrite durable state.
# The trainer must create last.pt via a temporary file plus atomic rename.
RESUME=()
if [ -f "$CKPT/last.pt" ]; then
  RESUME=(--resume "$CKPT/last.pt")
fi

srun python train.py --out "$OUT" --ckpt-dir "$CKPT" "${RESUME[@]}"
