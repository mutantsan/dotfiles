######## ALIASES ##############################################################
alias jb='ssh -i ~/.ssh/calexandr.pem calexandr@jumpbox.links.com.au'
alias ajb='ssh -i ~/.ssh/calexandr.pem calexandr@aujumpbox.links.com.au'
alias sysadd='ckan user add calexandr password="Strongpass123#" email=calexandr@gmail.com && ckan user setpass calexandr -p calexandr && ckan sysadmin add calexandr'
alias jproxy='sudo ssh -i ~/.ssh/calexandr.pem -Cq -D 2001 -N calexandr@aujumpbox.links.com.au'
alias ppub="rm -rf dist && python -m build && cd dist && twine upload * && cd .."
alias cdate='date +%Y-%m-%d'
alias explorer="explorer.exe ."
alias ols='/usr/bin/ls -l'
alias ls='lsd -l'
alias l='ls'
alias ll='ls'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias fd='fdfind'
alias vf='vim $(fzf --preview "bat --color=always {}")'
alias vim='nvim'

# tempie aliases
alias tl='tempie log'
alias tls='tempie list'
alias td='tempie delete'
alias tlst='tempie list $(date -d "4 days ago" +%Y-%m-%d)'
alias tlsy='tempie list $(date -d "1 days ago" +%Y-%m-%d)'
alias tlr='tempie list-range'

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
alias gurl='git config --get remote.origin.url | sed "s|git@github.com:|https://github.com/|" | sed "s/\.git//"'
alias gtag='ver=$(grep "^version" pyproject.toml | cut -d "\"" -f2) && git tag -a "v$ver" -m "Release v$ver"'
######## ALIASES END ##########################################################
