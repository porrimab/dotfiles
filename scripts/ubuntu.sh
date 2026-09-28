#!/usr/bin/env bash
echo "--- Running Ubuntu/Debian-based setup (apt + binary) ---"

# apt で基本ツールをインストール
sudo apt update -y
sudo apt install -y  --no-install-recommends \
    bash-completion \
    zsh \
    fzf \
    bat \
    zoxide \
    curl \
    wget \
    git \
    build-essential \
    gcc \
    make \
    wget \
    sccache \
    eza \
    mold

# rustup のインストール
if ! command -v rustup &>/dev/null; then
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    # 現在のセッションでパスを通す
    source "$HOME/.cargo/env"
else
    echo "rustup is already installed. Updating..."
    rustup self update
    rustup update stable
fi

rustup default stable
rustup completions bash > $HOME/.local/share/bash-completion/completions/rustup
rustup completions zsh > $HOME/.local/share/zsh/site-functions/_rustup

mkdir -p "$HOME/.cargo/bin"

# cargo-binstall の導入 (Rust製ツールの高速インストールのために便利)
if ! command -v cargo-binstall &>/dev/null; then
    echo "Installing cargo-binstall..."
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
    cargo binstall -y cargo-update
fi

# sheldon (plugin manager)
if ! command -v sheldon &>/dev/null; then
    cargo binstall -y sheldon || cargo install sheldon
    $HOME/.cargo/bin/sheldon completions bash > $HOME/.local/share/bash-completion/completions/sheldon
    $HOME/.cargo/bin/sheldon completions --shell zsh > $HOME/.local/share/zsh/site-functions/_sheldon
fi

if [[ "${INSTALL_STARSHIP:-0}" == "1" ]]; then
    if ! command -v starship &>/dev/null; then
        echo "Installing starship..."
        cargo binstall -y starship || cargo install starship
        $HOME/.cargo/bin/starship completions bash > $HOME/.local/share/bash-completion/completions/starship
        $HOME/.cargo/bin/starship completions zsh > $HOME/.local/share/zsh/site-functions/_starship
    fi
fi

# mise (version manager) from apt repo
if ! command -v mise &>/dev/null; then
    echo "Installing mise..."
    curl https://mise.run | sh
    mise completion bash --install
    mise completion zsh --install
fi

wget -O "$HOME/.zshrc"      https://grml.org/console/zshrc
wget -O "$HOME/.zshrc.local" https://grml.org/console/zshrc.local

echo 'if [ -f "$HOME/.config/zsh/local.zsh" ]; then
    source "$HOME/.config/zsh/local.zsh"
fi' >> "$HOME/.zshrc.local"

echo "alias p='sudo apt update ; sudo apt upgrade; rustup self update; rustup update ; cargo install-update -a ; mise self-update -y ; mise up'" >> "$DOTFILES_CONFIG_DIR/zsh/lazy.zsh"

echo 'include "/usr/share/nano/*.nanorc"' >> "$DOTFILES_CONFIG_DIR/../.nanorc" || true
echo "Ubuntu setup script finished."