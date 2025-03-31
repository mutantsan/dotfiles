# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export EDITOR='vim'
export GPG_TTY=$(tty)
export ZSH_THEME="powerlevel10k/powerlevel10k"
export DISABLE_MAGIC_FUNCTIONS=true

plugins=(fzf zsh-autosuggestions history zsh-syntax-highlighting nvm git)

source $ZSH/oh-my-zsh.sh

######## PYENV #################################################################
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

eval "$(pyenv init -)"
######## PYENV END ############################################################

######## ALIASES ##############################################################
alias jb='ssh -i ~/.ssh/calexandr.pem calexandr@jumpbox.links.com.au'
alias ajb='ssh -i ~/.ssh/calexandr.pem calexandr@aujumpbox.links.com.au'
alias sysadd='ckan user add calexandr password="Strongpass123#" email=calexandr@gmail.com && ckan user setpass calexandr -p calexandr && ckan sysadmin add calexandr'
alias jproxy='sudo ssh -i ~/.ssh/calexandr.pem -Cq -D 2001 -N calexandr@aujumpbox.links.com.au'
alias cdate='date +%Y-%m-%d'
alias explorer="explorer.exe ."
alias ls='lsd'
alias l='ls'
alias ll='ls'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# tempomat aliases
alias tls='tempo ls'
alias td='tempo d'
alias tlst='tls $(date -d "4 days ago" +%Y-%m-%d)'
alias tlsy='tls $(date -d "1 days ago" +%Y-%m-%d) -v'

# git aliases
alias gs='git status '
alias ga='git add '
alias gb='git branch -vvv'
alias gc='git commit'
alias gd='git diff'
alias gco='git checkout '
alias gk='gitk --all&'
alias gx='gitx --all'
alias gpt='git push --tags'
alias got='git '
alias get='git '
######## ALIASES END ##########################################################

######## Create CKAN project ##################################################
tplckan () {
    if [ -n "$1" ]
    then
        _v=$(pyenv versions | sed -E 's/^.\s//' | awk "/^$1/ {print \$1;}" | sort --version-sort | tail -n1)
        if [ -z $_v ]
        then
            echo 'Cannot locate Python version'
            return 1
        fi
        pyenv local $_v
    fi

    venv_path="$HOME/.virtualenvs/$(basename $(pwd))"
    python -m venv "$venv_path"

	mkdir -p config/storage/webassets

    echo "source $venv_path/bin/activate" > .envrc
    echo 'export CKAN_INI=$PWD/config/ckan.ini' >> .envrc
    echo 'export SETUPTOOLS_ENABLE_FEATURES="legacy-editable"' >> .envrc
    echo "unset PS1" >> .envrc

    direnv allow
}
######## Create CKAN project END ##############################################

######## Go to project ########################################################
_gopro_complete() {
    local proj_folder="/home/berry/projects"
    local drupal_folder="/var/www"
    local current_word="${COMP_WORDS[COMP_CWORD]}"
    local projects=""

    if [ -d "$proj_folder" ]; then
        projects=$(find "$proj_folder" -maxdepth 1 -type d -exec basename {} \; | grep -v '^projects$')
    fi

    if [ -d "$drupal_folder" ]; then
        drupal_projects=$(find "$drupal_folder" -maxdepth 1 -type d -exec basename {} \; | grep -v '^www$')
        projects="$projects $drupal_projects"
    fi

    COMPREPLY=($(compgen -W "$projects" -- "$current_word"))
}

gopro() {
    local proj_folder="/home/berry/projects"
    local drupal_folder="/var/www"

    if [ -n "$1" ]; then
        if [ -d "$proj_folder/$1" ]; then
            cd "$proj_folder/$1"
        elif [ -d "$drupal_folder/$1" ]; then
            cd "$drupal_folder/$1"
        else
            echo "Project not found."
        fi
    else
        find "$proj_folder" -maxdepth 1 -type d -exec basename {} \; | grep -v '^projects$';
        find "$drupal_folder" -maxdepth 1 -type d -exec basename {} \; | grep -v '^www$';

    fi
}

complete -F _gopro_complete gopro
######## Go to project END ####################################################

######### EXA #################################################################

alias exa="exa -l"

etree() {
  local extra_exclude="$*"
  local pattern="__pycache__|pyc"  # Always exclude __pycache__ and .pyc files
  if [[ -n "$extra_exclude" ]]; then
    pattern+="|$(echo "$extra_exclude" | sed 's/ /|/g')"
  fi
  exa --tree | grep -vE "($pattern)"
}
###############################################################################

eval "$(direnv hook zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

######## NVM ##################################################################
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
######## NVM END ##############################################################

######## TEMPOMAT #############################################################
TEMPO_AC_ZSH_SETUP_PATH=/home/berry/.cache/tempomat/autocomplete/zsh_setup && test -f $TEMPO_AC_ZSH_SETUP_PATH && source $TEMPO_AC_ZSH_SETUP_PATH;alias tl='tempo l'
######## TEMPOMAT END #########################################################

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
