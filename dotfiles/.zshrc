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
