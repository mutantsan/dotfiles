NOTES_DIR="$HOME/.notes"
mkdir -p "$NOTES_DIR"

note() {
    local editor=nvim
    local preview=glow

    case "$1" in
        find)
            shift
            local edit_mode=false
            if [ "$1" = "-e" ]; then
                edit_mode=true
                shift
            fi

            local selected_file
            selected_file=$(rg -i --line-number --no-heading --color=always -C3 "$1" "$NOTES_DIR" |
                fzf --ansi --phony --query "$1" \
                    --bind "change:reload:rg -i --line-number --no-heading --color=always {q} \"$NOTES_DIR\" || true" \
                    --delimiter : \
                    --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
                    --nth=1 |
                cut -d: -f1)

            if [ -n "$selected_file" ]; then
                if $edit_mode; then
                    $editor "$selected_file"
                else
                    $preview "$selected_file"
                fi
            fi
            ;;
        delete)
            shift
            local file_to_delete
            file_to_delete=$(rg -i --line-number --no-heading --color=never -C3 "$1" "$NOTES_DIR" |
                fzf --ansi --phony --query "$1" \
                    --bind "change:reload:rg -i --line-number --no-heading --color=never {q} \"$NOTES_DIR\" || true" \
                    --delimiter : \
                    --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' |
                cut -d: -f1)

            if [ -n "$file_to_delete" ]; then
                echo "Are you sure you want to delete '$file_to_delete'? [y/N]"
                read -r answer
                if [[ "$answer" =~ ^[Yy]$ ]]; then
                    rm "$file_to_delete" && echo "Deleted $file_to_delete"
                else
                    echo "Aborted."
                fi
            fi
            ;;
        *)
            local filename
            if [ -z "$1" ]; then
                filename=$(date +"%Y-%m-%d_%H-%M-%S").md
            else
                if [[ "$1" == *.md ]]; then
                    filename="$1"
                else
                    filename="$1.md"
                fi
            fi

            nvim "$NOTES_DIR/$filename"
            ;;
    esac
}

alias nf='note find'
alias nfe='note find -e'
alias nd='note delete'
alias n='note'
