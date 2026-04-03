export ZSH="$HOME/.oh-my-zsh"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#5ab8c8,bg=ffffff,bold,underline"
export EDITOR='vim'
export DISABLE_MAGIC_FUNCTIONS=true
export GOPATH=$HOME/go # GO
export PATH=$GOPATH/bin:$PATH # GO
export PIPENV_PYTHON="$PYENV_ROOT/shims/python" # pyenv
export PYENV_ROOT="$HOME/.pyenv" # pyenv
export PATH="$PYENV_ROOT/bin:$PATH" # pyenv
export PATH="$PATH:/home/berry/.local/bin" # pipx
export MY_CONF_DIR="$HOME/myconf"
export PLAYDATE_SDK_PATH="$HOME/.playdate-sdk"
export GPG_TTY=$TTY
export PATH="$HOME/.atuin/bin:$PATH" # atuin
export FZF_DEFAULT_COMMAND="fd . $HOME"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND --hidden --follow --exclude .git"
export FZF_ALT_C_COMMAND="fd -t d . $HOME"
export ATUIN_CONFIG_DIR="$HOME/.config/atuin"
export ATUIN_THEME_DIR="$ATUIN_CONFIG_DIR/themes"
export DIRENV_SKIP_TIMEOUT=1

plugins=(fzf fzf-tab zsh-autosuggestions history zsh-syntax-highlighting nvm git)

source ~/dotfiles/initckan.zsh
source ~/dotfiles/gopro.zsh
source ~/dotfiles/notes.zsh
source ~/dotfiles/aliases.zsh

eval "$(pyenv init -)" # Initialize pyenv
eval "$(direnv hook zsh)" # Initialize direnv
if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)" # Initialize atuin
fi

######## NVM ##################################################################
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
######## NVM END ##############################################################

# keep the same path when open a new tab/split
keep_current_path() {
  printf "\e]9;9;%s\e\\" "$(wslpath -w "$PWD")"
}
precmd_functions+=(keep_current_path)

eval "$(oh-my-posh init zsh --config /home/berry/dotfiles/oh-my-posh/my-theme.json)"
