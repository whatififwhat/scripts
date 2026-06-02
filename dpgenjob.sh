#!/bin/bash
#SBATCH -J dpgen
#SBATCH -o dpgen-%j.log
#SBATCH -e dpgen-%j.err
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --cpus-per-task=4

set -eo pipefail

echo "Time is $(date)"
echo "Directory is $PWD"
echo "This job runs on the following nodes:"
echo "$SLURM_JOB_NODELIST"
echo "This job has allocated $SLURM_JOB_CPUS_PER_NODE cpu cores."

# conda
source /data/software/anaconda3/etc/profile.d/conda.sh
conda activate dp

# Intel oneAPI
if [ -z "${SETVARS_COMPLETED:-}" ]; then
    set +u
    source /data/software/intel_2023/oneapi/setvars.sh
    set -u
else
    echo "Intel oneAPI has already been initialized; skip setvars.sh"
fi


# VASP
export PATH=/data/software/vasp.6.3.2/bin:$PATH

which python
which dpgen
which vasp_gam || true

test -f param.json
test -f machine.json

python -m json.tool param.json > /dev/null
python -m json.tool machine.json > /dev/null

dpgen run param.json machine.json

echo "DP-GEN finished at $(date)"
