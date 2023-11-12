#!/bin/bash

# Default values
commit_message="Automated commit"
branch="main"
new_branch=false
add_all=false
show_diff=false
debug_mode=false

# Define help menu
help_menu() {
  echo "Usage: ./git-script.sh -aDd -b <branch> -n <name> -c <msg>"
  echo ""
  echo "OPTIONS:"
  echo "  -a, --all              add all changes"
  echo "  -b, --branch <name>    specify branch (default: dev)"
  echo "  -n, --new <name>       create new branch and switch to it"
  echo "  -c, --commit <msg>     custom commit message (default: Automated commit)"
  echo "  -D, --debug            enable debug mode"
  echo "  -d, --diff             show git diff --stat before committing or when it's the only argument"
  echo "  -h, --help             display this help menu"
  echo ""
  echo "This script was generated by ChatGPT, a language model trained by OpenAI."
  echo ""
  exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
  -a | --all)
    add_all=true
    shift
    ;;
  -b | --branch)
    branch="$2"
    shift
    shift
    ;;
  -n | --new)
    branch="$2"
    new_branch=true
    shift
    shift
    ;;
  -c | --commit)
    commit_message="$2"
    shift
    shift
    ;;
  -D | --debug)
    debug_mode=true
    shift
    ;;
  -d | --diff)
    show_diff=true
    shift
    ;;
  -h | --help)
    help_menu
    ;;
  *)
    break
    ;;
  esac
done

# Check if any files are specified
if [[ $# -eq 0 && "$add_all" = false && "$show_diff" = false ]]; then
  help_menu
fi

# Create new branch if option is provided
if [ "$new_branch" = true ]; then
  git checkout -b "$branch"
fi

# Show git diff --stat and skip all other steps
if [ "$show_diff" = true ] && [[ "$#" -eq 0 ]]; then
  git diff --stat
  exit 0
fi

if [ "$add_all" = true ]; then
  git add --all
else
  if [[ $# -gt 0 ]]; then
    git add "$@"
  fi
fi

if [ "$debug_mode" = true ]; then
  echo "Debug Mode:"
  echo "  PWD: $(pwd)"
  echo "  Commit Message: $commit_message"
  echo "  Branch: $branch"
  echo "  New Branch: $new_branch"
  echo "  Add All: $add_all"
  echo "  Files: "
  git status --short | awk '{print $2}'
  echo ""
  echo "  Number of Files: $#"
  echo "  Show Diff: $show_diff"
  echo "  Debug Mode: $debug_mode"
  echo ""
fi

if git diff-index --quiet HEAD --; then
  echo "No changes to commit. Skipping the commit step."
else
  if [ "$commit_message" != "Automated commit" ]; then
    username=$(git config user.name)
    commit_message+=" ($(date +%Y-%m-%d)) [branch: $branch, author: $username]"
    git commit -m "$commit_message"
    echo "Changes committed with message: $commit_message"
    if [ "$add_all" = true ] && [ "$commit_message" != "Automated commit" ]; then
      git push origin "$branch"
      echo "Changes pushed to $branch branch."
    fi
  else
    echo "Warning: No commit message set. Use the -c or --commit option to provide a commit message."
  fi
fi
if [ "$new_branch" = true ]; then
  git checkout dev
fi