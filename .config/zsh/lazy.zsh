# Current Directory env
ZSHRC_DIR=${${(%):-%N}:A:h}

# zsh-completions
fpath=($HOME/.local/share/zsh/site-functions(N-/) $fpath)
autoload -Uz compinit
compinit

# alias
alias cat='bat --decorations=never --paging=never'
alias ls='eza --icons=auto'

# fzf
if type "fzf" &>/dev/null; then
    export FZF_DEFAULT_OPTS="--ansi -e --prompt='QUERY> ' --layout=reverse --border=rounded --height 100%"
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=header,grid --line-range :100 {}'"
    export FZF_ALT_C_OPTS="--preview 'eza {} -h -T -F  --no-user --no-time --no-filesize --no-permissions --long | head -200'"
    fzf_path=$(command -v fzf)
    fzf_cache="$ZSHRC_DIR/fzf.zsh"
    if [[ ! -r "$fzf_cache" || "$fzf_path" -nt "$fzf_cache" ]]; then
        command "$fzf_path" --zsh > "$fzf_cache"
    fi
    source $fzf_cache
    unset fzf_cache
    unset fzf_path
fi

# zoxide
if type "zoxide" &>/dev/null; then
    zoxide_cache="$ZSHRC_DIR/zoxide.zsh"
    zoxide_path=$(command -v zoxide)
    if [[ ! -r "$zoxide_cache" || "$zoxide_path" -nt "$zoxide_cache" ]]; then
        command "$zoxide_path" init zsh > "$zoxide_cache"
    fi
    source $zoxide_cache
    unset zoxide_cache
    unset zoxide_path
fi
