_gopro_complete() {
    local proj_folder="$HOME/projects"
    local drupal_folder="/var/www"
    local myproj_folder="$HOME/my_proj"

    local current_word="${COMP_WORDS[COMP_CWORD]}"
    local projects=""

    if [ -d "$proj_folder" ]; then
        projects=$(find "$proj_folder" -maxdepth 1 -type d -exec basename {} \; | grep -v '^projects$')
    fi

    if [ -d "$drupal_folder" ]; then
        drupal_projects=$(find "$drupal_folder" -maxdepth 1 -type d -exec basename {} \; | grep -v '^www$')
        projects="$projects $drupal_projects"
    fi

    if [ -d "$myproj_folder" ]; then
        myproj_projects=$(find "$myproj_folder" -maxdepth 1 -type d -exec basename {} \; | grep -v '^myproj$')
        projects="$projects $myproj_projects"
    fi

    COMPREPLY=($(compgen -W "$projects" -- "$current_word"))
}

gopro() {
    local proj_folder="$HOME/projects"
    local drupal_folder="/var/www"
    local myproj_folder="$HOME/my_proj"

    if [ -n "$1" ]; then
        if [ -d "$proj_folder/$1" ]; then
            cd "$proj_folder/$1"
        elif [ -d "$drupal_folder/$1" ]; then
            cd "$drupal_folder/$1"
        elif [ -d "$myproj_folder/$1" ]; then
            cd "$myproj_folder/$1"
        else
            echo "Project not found."
        fi
    else
        find "$proj_folder" -maxdepth 1 -type d -exec basename {} \; | grep -v '^projects$';
        find "$drupal_folder" -maxdepth 1 -type d -exec basename {} \; | grep -v '^www$';

    fi
}

complete -F _gopro_complete gopro
