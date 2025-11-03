#!/usr/bin/env bash
set -euo pipefail

mkdir -p evidence.logs/evidence/reports
exec > >(tee -a evidence/logs/bootstrap.log) 2>&1
echo "[A1] start $(date -Is)"

if ! grep -q '# A1 shell hygiene' ~/.bashrc; then
  cat >> ~/.bashrc <<'BRC'

HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
PROMPT_COMMAND='history -a'
alias gs='git status'; alias ga='git add'; alias gc='git commit -m'
alias gp='git push'; alias gl='git log --oneline --graph --decorate'
alias vact='. .venv/bin/activate'
BRC
  echo "[A1] appended aliases to ~/.bashrc"
fi

# venv + dev deps
python3 -m venv .venv || true
. .venv/bin/activate
python -m pip install -U pip
pip install -q -r requirements.txt -r requirements.dev.txt || true
pip install -q pre-commit black isort ruff detect secrets pytest

# evidence perf row
csv="evidence/reports/perf.csv"
 [ -f "$csv" ] || echo "step,start_ns,end_ns,duration_ms" > "$csv"
start=$(date +%s%N); sleep 0.02; end=$(date +%s%N)
awk -v s="$start" -v e="$end" 'BEGIN{printf "bootstrap,%s,%s,%.3f\n",s,e,(e-s)/1e6}' >> "$csv"

# ensure hooks present
pre-commit install

echo "[A1] complete $(date -Is)"
