#!/bin/bash
set -e

echo "Configuring user preferences..."

# Set EDITOR
if ! grep -q "export EDITOR=" ~/.bashrc 2>/dev/null; then
    echo 'export EDITOR="code --wait"' >> ~/.bashrc
    echo "✓ EDITOR added to ~/.bashrc"
else
    echo "✓ EDITOR already configured in ~/.bashrc"
fi

# Add .local/bin to PATH
if ! grep -q ".local/bin" ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo "✓ .local/bin added to PATH"
else
    echo "✓ .local/bin PATH already configured in ~/.bashrc"
fi

# Claude prune alias
if ! grep -q "alias claude-prune=" ~/.bashrc 2>/dev/null; then
    echo "alias claude-prune='find ~/.claude/projects -name \"*.jsonl\" -delete && echo \"Claude sessions pruned.\"'" >> ~/.bashrc
    echo "✓ claude-prune alias added to ~/.bashrc"
else
    echo "✓ claude-prune alias already configured in ~/.bashrc"
fi

# Install system packages
echo "Installing system packages..."
sudo apt-get update
sudo apt-get install -y jq vim git curl
sudo apt-get clean

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ oh-my-zsh installed"
else
    echo "✓ oh-my-zsh already installed"
fi

# Install Claude Code
echo "Installing Claude Code..."
claude install

echo "Done!"
