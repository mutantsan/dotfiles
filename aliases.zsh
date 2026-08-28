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
alias vf='vim $(fzf --preview "bat --color=always {}")'
alias vim='nvim'
alias ckt='ckan run -t'
alias cbm_list='codebase-memory-mcp cli list_projects | jq'
alias cbm_run='codebase-memory-mcp --port=9749'
alias pip='uv pip'
alias opip='pip'

cbm_index() {
    codebase-memory-mcp cli index_repository "{\"repo_path\":\"$PWD\"}"
}

# tempie aliases
alias tl='tempie log'
alias tls='tempie list'
alias td='tempie delete'
alias tm='tempie month'
alias tlr='tempie list-range'

case "$(uname)" in
  Darwin)
    alias tlst='tempie list $(date -v-4d +%Y-%m-%d)'
    alias tlsf='tempie list $(date -v-3d +%Y-%m-%d)'
    alias tlsy='tempie list $(date -v-1d +%Y-%m-%d)'
    ;;
  Linux)
    alias tlst='tempie list $(date -d "4 days ago" +%Y-%m-%d)'
    alias tlsy='tempie list $(date -d "1 days ago" +%Y-%m-%d)'
    ;;
esac


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
alias gurl='git config --get remote.origin.url | sed -E "s#git@([^:]+):#https://\1/#" | sed -E "s#https?://##" | sed "s#^#https://#" | sed "s/\.git$//"'
alias gtag='function _gtag() { git tag -a "v$1" -m "Release v$1"; }; _gtag'

gadd() {
    git diff --name-only | while IFS= read -r f; do
        git --no-pager diff -- "$f"
        printf "\n\n----------------------------------------\n"
        printf "Stage %s? [y/N] " "$f"
        read -r ans </dev/tty
        [[ $ans =~ ^[Yy]$ ]] && git add -- "$f"
        printf "\n\n"
    done
}

######## ALIASES END ##########################################################
