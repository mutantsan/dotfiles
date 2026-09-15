# ~/.zshrc — Omarchy base + personal layer   (stow: dotfiles/zsh/.zshrc)
#
# Model: bash stays the login shell; `chsh -s /usr/bin/zsh` (or Omarchy's
# `exec zsh` hook) hands off to zsh, which reads this file. The shared
# Omarchy shell base is provided by the `omarchy-zsh` package
# (/usr/share/omarchy-zsh/shell/*). Personal config is layered on top and
# mirrors the old ~/.bashrc so behaviour stays the same.

# Not interactive: do nothing.
[[ $- != *i* ]] && return

# ---------------------------------------------------------------------------
# Omarchy base
# ---------------------------------------------------------------------------
# OMARCHY_PATH / PATH bootstrap (guarded; also present via /etc/profile.d).
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] &&
  source /usr/share/omarchy/default/bash/env-bootstrap

# zsh options, keybindings, completion, fzf ZLE widgets, syntax-highlighting.
[[ -f /usr/share/omarchy-zsh/shell/zoptions ]] &&
  source /usr/share/omarchy-zsh/shell/zoptions

# Shared aliases / functions / env / tool init (mise, starship, zoxide,
# try, fzf) — identical content to what the bash side loads.
[[ -f /usr/share/omarchy-zsh/shell/all ]] &&
  source /usr/share/omarchy-zsh/shell/all

# ---------------------------------------------------------------------------
# Personal environment
# ---------------------------------------------------------------------------
export GOPATH="$HOME/go"
export PYENV_ROOT="$HOME/.pyenv"
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"
export PLAYDATE_SDK_PATH="$HOME/.playdate-sdk"
export MY_CONF_DIR="$HOME/dotfiles"        # used by initckan for templates/ckan.ini
export GPG_TTY="$TTY"

export CDM_USE_UV=1
export DIRENV_SKIP_TIMEOUT=1
export ATUIN_CONFIG_DIR="$HOME/.config/atuin"
export ATUIN_THEME_DIR="$ATUIN_CONFIG_DIR/themes"

# Alt-C: fuzzy-cd into any dir under $HOME (not just from $PWD)
export FZF_ALT_C_COMMAND="fd -t d --follow \
  -E .git \
  -E .direnv \
  -E node_modules \
  -E __pycache__ \
  -E .cargo \
  -E .nvm \
  -E .npm \
  -E .pyenv \
  -E .ipython \
  -E .cache \
  -E .vscode \
  -E .rustup \
  -E .steam \
  -E go/pkg/ \
  . $HOME"

# PATH — Omarchy already adds ~/.local/bin and mise shims.
path=(
  "$PYENV_ROOT/bin"
  "$HOME/.cargo/bin"
  "$GOPATH/bin"
  $path
)
[[ -d "$HOME/.atuin/bin" ]] && path=("$HOME/.atuin/bin" $path)
typeset -U path                            # dedupe, keep first occurrence

# ---------------------------------------------------------------------------
# Personal tool init
# ---------------------------------------------------------------------------
# pyenv + nvm are kept alongside mise deliberately: the initckan workflow
# needs `pyenv` and `$HOME/.nvm/versions/node`. They prepend their shims,
# so python/node resolve to pyenv/nvm — same as the old bash setup.
command -v pyenv  &>/dev/null && eval "$(pyenv init - zsh)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
command -v atuin  &>/dev/null && eval "$(atuin init zsh)"

export NVM_DIR="$HOME/.nvm"
if [[ -s /usr/share/nvm/init-nvm.sh ]]; then
  source /usr/share/nvm/init-nvm.sh
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
  autoload -U +X bashcompinit && bashcompinit
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi

# ---------------------------------------------------------------------------
# Personal shell fragments (stow-managed ~/.config/bash/*.sh)
# ---------------------------------------------------------------------------
# Sourced AFTER the Omarchy base so personal aliases win — same as bash.
for _f in "$HOME/.config/bash/"*.sh(N); do
  [[ -r "$_f" ]] && source "$_f"
done
unset _f


# Optional: `sudo pacman -S zsh-autosuggestions` to enable.
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

sbx() {
  if [[ "$1 $2" == "run claude" && $# -eq 2 ]]; then
    local name="claude-${PWD:t}"
    if command sbx ls 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "$name"; then
      command sbx run claude --name "$name"                       # exists → attach
    else
      command sbx run claude --static-mcp codebase-memory-mcp     # new → bake it in
    fi
  else
    command sbx "$@"
  fi
}
