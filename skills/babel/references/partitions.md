# Babel partitions

Babel is CMU-wide; `maxlab` and `maxlab-cpu` are MaxLab resources within it.

- `preempt`: default for restartable GPU work.
- `maxlab`: scarce MaxLab GPUs used non-preemptibly; Max must approve the workload.
- `maxlab-cpu`: CPU work and access to `/data` and `/scratch`.
- `general`: non-preemptible GPU work, available only to users with the `normal` QOS.

## `maxlab-cpu`

Default to 2 CPUs and 4 GB unless the workload clearly requires more:

```bash
srun -p maxlab-cpu --cpus-per-task=2 --mem=4G --pty zsh
```

## `general` access

```bash
sacctmgr -nP show assoc where user="$USER" format=QOS
```

The user can use `general` only when `normal` appears in their QOS list.

## Limits

Before writing a request, inspect the target partition and do not exceed its
`MaxTime`:

```bash
scontrol show partition <partition> --oneliner
```

`preempt`, `maxlab`, and `general` require at least one GPU; `maxlab-cpu` is
CPU-only. Because Babel uses `EnforcePartLimits=NO`, an excessive time request may
be accepted and remain pending instead of failing immediately.
