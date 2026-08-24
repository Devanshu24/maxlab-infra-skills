# Babel storage

`/data` and `/scratch` are compute-node-only. Use the `maxlab-cpu` command in
`partitions.md` when no compute allocation is already available.

| Purpose | Path |
|---|---|
| Personal datasets, checkpoints, run state | `/data/user_data/$USER` |
| Intentionally team-shared artifacts | `/data/group_data/maxlab/common_datasets` |
| Hugging Face Hub cache | `/data/hf_cache/hub` |
| Hugging Face datasets cache | `/data/hf_cache/datasets` |
| Disposable node-local work | `/scratch/$USER/<run>` |

The group path is not routine personal overflow. Use it personally only when
`/data/user_data/$USER` is full or unusable and the situation is exigent.

Use Babel's shared, evictable Hugging Face cache by default:

```bash
export HF_HOME="/data/user_data/$USER/.hf_cache"
export HF_HUB_CACHE="/data/hf_cache/hub"
export HF_DATASETS_CACHE="/data/hf_cache/datasets"
```

Neither the HF cache nor `/scratch` may hold the only copy of an artifact or
checkpoint.
