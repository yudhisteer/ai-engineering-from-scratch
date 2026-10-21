#!/usr/bin/env bash
# Project helper. Usage: ./run.sh <command> [args]. `make <command>` calls this.
# Pushes go to the `fork` remote (yudhisteer/ai-engineering-from-scratch); `origin` is upstream.
set -euo pipefail
cd "$(dirname "$0")"

REMOTE="${REMOTE:-fork}"
BRANCH="${BRANCH:-main}"

cmd="${1:-help}"
shift || true

case "$cmd" in
  status) git status -sb ;;
  log)    git log --oneline -n "${1:-10}" ;;
  diff)   git diff --stat ;;

  # commit everything: ./run.sh commit "feat(phase-NN/MM): slug"
  commit)
    msg="${1:?commit message required, e.g. ./run.sh commit \"fix(site): ...\"}"
    git add -A
    git diff --cached --quiet && { echo "nothing to commit"; exit 0; }
    git commit -m "$msg"
    ;;

  push) git push "$REMOTE" "$BRANCH" ;;
  pull) git pull --rebase --autostash "$REMOTE" "$BRANCH" ;;
  save) "$0" commit "${1:?commit message required}" && "$0" push ;;

  # per-PR validation from AGENTS.md
  audit)
    python3 scripts/audit_lessons.py
    python3 scripts/audit_certifications.py
    python3 scripts/check_readme_counts.py || true
    ;;
  manuals) node --test site/test_manuals.js && node scripts/audit_manuals.js ;;

  # CI rebuilds data.js and catalog.json on main; run locally only to preview
  build)
    python3 scripts/build_catalog.py
    node site/build.js
    ;;
  serve) node scripts/serve-agent-site.js ;;

  # run one lesson's tests: ./run.sh lesson phases/NN-x/MM-y
  lesson)
    dir="${1:?lesson dir required}/code"
    (cd "$dir" && python3 main.py && python3 -m unittest discover tests -v)
    ;;

  help|*)
    cat <<'EOF'
status | log [n] | diff
commit "msg"   stage all and commit
push           push main to fork
pull           rebase on fork/main (autostash)
save "msg"     commit + push
audit          lesson + certification audits
manuals        manual tests and audit
build          rebuild catalog.json and site/data.js (generated, do not commit)
serve          local agent site
lesson <dir>   run one lesson's code and tests
EOF
    ;;
esac
