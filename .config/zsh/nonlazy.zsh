# Current Directory env
ZSHRC_DIR=${${(%):-%N}:A:h}

# options
HISTFILE=$HOME/.zsh_history
if [ $UID = 0 ]; then
	unset HISTFILE
	SAVEHIST=0
fi

setopt hist_ignore_all_dups
setopt hist_reduce_blanks
zstyle ":completion:*:commands" rehash 1
export DO_NOT_TRACK=1

path=($HOME/.local/bin(N-/) $path)

# cargo
path=($HOME/.cargo/bin(N-/) $path)

# mise
export MISE_CONFIG_DIR="$HOME/.config/mise"
export MISE_GLOBAL_CONFIG_FILE="$MISE_CONFIG_DIR/config.toml"
if type "mise" &>/dev/null; then
	mise_path=$(command -v mise)
	mise_cache="$ZSHRC_DIR/mise.zsh"
	if [[ ! -r "$mise_cache" || "$mise_path" -nt "$mise_cache" ]]; then
		command "$mise_path" activate zsh> $mise_cache
	fi
	source "$mise_cache"
	unset mise_path
	unset mise_cache
fi
