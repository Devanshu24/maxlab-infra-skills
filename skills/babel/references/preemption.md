# Preemption on `preempt`

A valid `preempt` job must:

- never set `--no-requeue` (Babel sets `JobRequeue=1`, so requeue is already on and
  an explicit `--requeue` changes nothing; `--no-requeue` forfeits it);
- checkpoint often enough that the worst-case lost work is acceptable;
- discover and resume its latest durable checkpoint at startup;
- write checkpoints atomically;
- use a stable run path across manual resubmissions; and
- append rather than truncate its Slurm log.

Keep run state in `/data/user_data/$USER`, not `/scratch`. Restore the full training
state: model, optimizer, scheduler/scaler, RNG, sampler/dataloader position, and
global step. For arrays, include `$SLURM_ARRAY_TASK_ID` in the stable run identity
when each task is a distinct run.

`examples/preempt.sbatch` is one worked example of the list above, not a structure
to adopt. Its cache layout, `last.pt` naming, and `srun python train.py` are
illustrative. Satisfy the requirements in whatever shape fits the user's code.
