#!/usr/bin/env bash
set -ue

INSTALL_STARSHIP=0

show_usage() {
    cat <<'EOF'
Usage: ./install.sh [--starship] [--no-starship] [--help]

  --starship      Install starship in addition to the base setup.
  --no-starship   Do not install starship (default).
  --help          Show this help message.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --starship)
            INSTALL_STARSHIP=1
            ;;
        --no-starship)
            INSTALL_STARSHIP=0
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_usage >&2
            exit 1
            ;;
    esac
    shift
done

export DOTFILES_ROOT=$(cd $(dirname $0); pwd)
export DOTFILES_SCRIPTS_DIR="$DOTFILES_ROOT/scripts"
export DOTFILES_CONFIG_DIR="$DOTFILES_ROOT/.config"

# /etc/os-release を読み込んで OS を特定
if [ -f /etc/os-release ]; then
    . /etc/os-release
    # ID は直接の識別子、ID_LIKE は派生元（ubuntu の ID_LIKE は debian など）
    case "$ID" in
        arch)
            OS="arch"
            ;;
        ubuntu|debian)
            OS="ubuntu"
            ;;
        *)
            # ID_LIKE もチェック（例: manjaro なら arch と判定させる）
            if [[ "${ID_LIKE:-}" == *"arch"* ]]; then
                OS="arch"
            elif [[ "${ID_LIKE:-}" == *"debian"* ]]; then
                OS="ubuntu"
            else
                echo "Unsupported OS: $ID"
                exit 1
            fi
            ;;
    esac
else
    echo "/etc/os-release not found. Unknown OS."
    exit 1
fi

echo "OS Detected: $ID (Targeting $OS config)"

mkdir -p ~/.local/bin
source "$HOME/.bashrc"

if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo 'if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
  fi' >> ~/.bashrc
  source "$HOME/.bashrc"
fi

mkdir -p $HOME/.local/share/bash-completion/completions
mkdir -p $HOME/.local/share/zsh/site-functions

if [ -f "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc to .zshrc.bak"
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi
if [ -f "$HOME/.zshrc.local" ]; then
    echo "Backing up existing .zshrc.local to .zshrc.local.bak"
    mv "$HOME/.zshrc.local" "$HOME/.zshrc.local.bak"
fi

# 1. OS固有のインストール
INSTALL_STARSHIP="$INSTALL_STARSHIP" bash "$DOTFILES_SCRIPTS_DIR/$OS.sh"

if [ -f /usr/bin/batcat ]; then
    ln -s /usr/bin/batcat $HOME/.local/bin/bat
fi

cp -ri .config/. "$HOME/.config/"
zsh -c "zcompile $HOME/.zshrc; zcompile $HOME/.config/zsh/local.zsh"

mkdir -p "$HOME/.cargo"
cp -ri .cargo/. "$HOME/.cargo/"

if [ -f "$HOME/.zshrc.local" ]; then
    zsh -c "zcompile $HOME/.zshrc.local"
fi

unset DOTFILES_ROOT
unset DOTFILES_SCRIPTS_DIR
unset DOTFILES_CONFIG_DIR

echo "Setup complete!"