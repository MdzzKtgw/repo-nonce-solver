#!/bin/bash
# Race N probsab procs on inst/$TAG.txt; push verified win to branch res-$TAG-$JOB
set -u
N=$(nproc); BETAS=(2.6 4.0 1.9 3.0 2.2 3.4 1.7 4.5)
F=inst/$TAG.txt; [ -f "$F.gz" ] && gunzip -kf "$F.gz"; mkdir -p out
# stop early if another job already won
END=$(( $(date +%s) + SECS ))
for i in $(seq 0 $((N-1))); do
  B=${BETAS[$(( (JOB*N+i) % 8 ))]}
  S=$(( (JOB*7919 + i*104729 + $(date +%s%N) ) % 2147483647 ))
  timeout $((SECS+5)) ./probsab $F $S $B $SECS > out/$i.txt 2>/dev/null &
done
while [ $(date +%s) -lt $END ]; do
  sleep 2
  for o in out/*.txt; do
    b=$(head -c 2000 $o | tr -dc '01')
    if [ ${#b} -ge 100 ]; then
      if python3 verify.py $F "$b"; then
        echo "$b" > win.txt
        git config user.email a@b.c; git config user.name solver
        git checkout -b res-$TAG-$JOB && git add win.txt && git commit -qm win && git push -q origin res-$TAG-$JOB
        echo WON; pkill probsab; exit 0
      fi
    fi
  done
  if [ $(( $(date +%s) % 20 )) -lt 2 ]; then
    git ls-remote --heads origin "res-$TAG-*" | grep -q . && { echo "other won"; pkill probsab; exit 0; }
  fi
done
pkill probsab; echo none
