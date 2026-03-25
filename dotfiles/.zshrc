export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Editor
export EDITOR="code --wait"

# Aliases
alias claude-prune='find ~/.claude/projects -name "*.jsonl" -delete && echo "Claude sessions pruned."'
alias awsl="aws sso login && aws codeartifact login --tool npm --repository npm --domain ww-nonprod --domain-owner 254305338854 --region us-east-1 && date +%s > ~/.aws/.codeartifact_auth"
alias awslp="aws sso login --profile npm-publisher && aws codeartifact login --tool npm --repository npm --domain ww-nonprod --domain-owner 254305338854 --region us-east-1 --profile npm-publisher && date +%s > ~/.aws/.codeartifact_auth"
