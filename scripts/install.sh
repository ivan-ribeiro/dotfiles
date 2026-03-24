#!/bin/bash
set -e

echo "Configuring user preferences..."

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
