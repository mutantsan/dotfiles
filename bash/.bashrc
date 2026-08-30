# Omarchy environment (OMARCHY_PATH + PATH), needed even for non-interactive shells
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything else (leave this above the rc source)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.

# Personal dotfiles: bash fragments in ~/.config/bash (stow-managed from ~/dotfiles/bash)
export MY_CONF_DIR="$HOME/dotfiles"     # used by initckan for templates/ckan.ini
for _f in "$HOME/.config/bash/"*.sh; do
  [[ -r "$_f" ]] && source "$_f"
done
unset _f

# pyenv + direnv (needed by initckan)
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv  >/dev/null && eval "$(pyenv init - bash)"
command -v direnv >/dev/null && eval "$(direnv hook bash)"

# Alt-C: fuzzy-cd into any directory under $HOME (not just from $PWD)
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git . $HOME"

# Teach bash completion about the git aliases (branch names after gco, etc.)
if [[ $- == *i* ]]; then
  declare -F __git_complete >/dev/null || _completion_loader git 2>/dev/null
  if declare -F __git_complete >/dev/null; then
    __git_complete g   __git_main
    __git_complete got __git_main
    __git_complete get __git_main
    __git_complete gco git_checkout
    __git_complete gb  git_branch
    __git_complete gc  git_commit
    __git_complete gd  git_diff
    __git_complete gs  git_status
    __git_complete ga  git_add
  fi
fi

[[ -r /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

# atuin
eval "$(atuin init bash)"
