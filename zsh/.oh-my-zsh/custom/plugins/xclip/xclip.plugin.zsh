# Copies the content of a file to the clipboard.
# Usage: xfile <file_path>
xfile() {
    if [[ -f "$1" ]]; then
        xclip -selection clipboard -i "$1"
        echo "Copied content of '$1' to clipboard."
    else
        echo "Error: File '$1' not found."
    fi
}

# Takes the first line from your clipboard and writes it to a file.
# Usage: pfile <file_path>
pfile() {
    if [[ -n "$1" ]]; then
        xclip -selection clipboard -o | head -n 1 > "$1"
        echo "Wrote first line from clipboard to '$1'."
    else
        echo "Error: Please specify an output file."
    fi
}

# Copies your current working directory to the clipboard.
# Usage: xpwd
xpwd() {
    pwd | xclip -selection clipboard
    echo "Copied current directory '$(pwd)' to clipboard."
}

# Executes a command and copies its standard output to the clipboard.
# Usage: xcmd <command>
xcmd() {
    if [[ -n "$*" ]]; then
        "$@" | xclip -selection clipboard
        echo "Copied output of '$*' to clipboard."
    else
        echo "Usage: xcopy_cmd <command>"
    fi
}
