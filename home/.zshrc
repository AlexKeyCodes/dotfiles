# ─── Keys ──────────────────────────────────────────────────────────────────
# zsh switches to vi keys when EDITOR contains "vi"; keep the usual emacs keys.
bindkey -e

# ─── Completion ────────────────────────────────────────────────────────────
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ─── History ───────────────────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ─── Tools ─────────────────────────────────────────────────────────────────
(( $+commands[mise] ))     && eval "$(mise activate zsh)"   # Ruby, Node
(( $+commands[fzf] ))      && source <(fzf --zsh)           # ctrl+r history, ctrl+t files
(( $+commands[zoxide] ))   && eval "$(zoxide init zsh)"     # z <dir>
(( $+commands[starship] )) && eval "$(starship init zsh)"   # prompt

# ─── Aliases ───────────────────────────────────────────────────────────────
[[ -f ~/.aliases ]] && source ~/.aliases

# ─── This machine only (not in the repo): project paths, SSH aliases, secrets
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ─── Plugins (pacman packages; syntax highlighting must load last) ─────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'   # colour 8 follows the theme
plugins=/usr/share/zsh/plugins
[[ -f $plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source $plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f $plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source $plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
unset plugins
