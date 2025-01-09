#!/bin/bash

ERROR='\033[0;31m'   # Error
SUCCESS='\033[0;32m' # Success
WARNING='\033[0;33m' # Warning
INFO='\033[0;34m'    # Info
NC='\033[0m'         # No Color (reset)

while getopts ":q" opt; do
    case $opt in
    q) quiet=true ;;
    \?)
        echo "Invalid option: -$OPTARG"
        exit 1
        ;;
    esac
done

shift $((OPTIND - 1))

if [ "$#" -ne 1 ]; then
    echo "Usage: $(basename $0) [-q] <directory|file>"
    echo "  Renames files by encoding their names in base64 and moving them to the same directory."
    echo "  If a directory is provided, all files within it will be renamed."
    echo "  -q: Quiet mode, suppresses 'is a file/directory' messages."
    exit 1
fi

target=$1

function move {
    path=$1
    if [ -f "$path" ]; then
        file=$(basename "$path")

        directory=$(dirname "$path")
        filename=$(echo "$file" | sed 's/\(.*\)\.[a-zA-Z0-9]*$/\1/')
        extension="${file##*.}"

        if [ -z "$quiet" ]; then
            echo -e "${INFO}INFO:${NC}        filename: $filename"
            echo -e "${INFO}INFO:${NC}        extension: $extension"
        fi

        base64=$(echo -n "$filename" | base64) # -w 0 removes line breaks
        base64_no_equals=$(echo "$base64" | tr -d '=')
        base64_lowercase=$(echo "$base64_no_equals" | tr '[:upper:]' '[:lower:]')
        new_file="${base64_lowercase}.${extension}"
        new_path="${directory}/$new_file"
        mv "$path" $new_path
        echo -e "${SUCCESS}SUCCESS:${NC}     $path ==> $new_path"
    fi
}

# Check if the provided path is a file
if [ -f "$target" ]; then
    if [ -z "$quiet" ]; then
        echo -e "${INFO}INFO:${NC}        $target is a file."
    fi
    move "$target"
fi

# Check if the provided path is a directory
if [ -d "$target" ]; then
    if [ -z "$quiet" ]; then
        echo -e "${INFO}INFO:${NC}        $target is a directory."
    fi
    # Loop through all files in the directory
    for path in "$target"/*; do
        move "$path"
    done
fi

exit 0
