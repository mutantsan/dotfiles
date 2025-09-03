# -----------------------------------------------------------------------------
# Notes Management Script
#
# This script provides a simple way to manage personal notes stored in
# "$HOME/.notes". Notes are created in Markdown format and can be created,
# searched, previewed, edited, or deleted from the terminal.
#
# Requirements:
#   - rg (ripgrep) : fast search, https://github.com/BurntSushi/ripgrep
#   - fzf          : fuzzy finder, https://github.com/junegunn/fzf
#   - bat          : syntax highlighting preview, https://github.com/sharkdp/bat
#   - nvim (or any editor you set), https://neovim.io/
#
# Note folder:
#   By default, the notes are stored in "$HOME/.notes". You can change this by
#   editing the NOTES_DIR variable below.
#
# Editor:
#   By default, the script uses "nvim" as the editor. You can change this by
#   editing the EDITOR variable below.:
#       EDITOR=nvim
#   Example alternatives:
#       EDITOR=nano
#       EDITOR=code
#       EDITOR="${EDITOR:-nvim}"   # use system default
#
# Usage:
#   n [filename]        - Create or edit a note.
#                         If no filename is given, creates a timestamped file.
#                         Example: n todo -> opens/creates "todo.md"
#
#   nf                  - Find a note.
#
#   nfe                 - Find and edit a note.
#
#   nd                  - Find and delete a note (with confirmation).
#
# Aliases:
#   n   = note          (create/edit note)
#   nf  = note find     (search + preview)
#   nfe = note find -e  (search + edit)
#   nd  = note delete   (search + delete)
#
# -----------------------------------------------------------------------------

NOTES_DIR="$HOME/.notes"
EDITOR=nvim

mkdir -p "$NOTES_DIR"

note() {
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
                    $EDITOR "$selected_file"
                else
                    echo "Previewing $selected_file"
                    echo "\n"
                    bat "$selected_file" --style=plain
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

            $EDITOR "$NOTES_DIR/$filename"
            ;;
    esac
}

alias nf='note find'
alias nfe='note find -e'
alias nd='note delete'
alias n='note'
