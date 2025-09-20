#!/bin/bash

source $LOG_MESSAGE_PATH

if [ -z "$1" ]; then
    print_message error "Usage: $0 <directory_or_file> or '-' for stdin"
    exit 1
fi

if [ "$1" == "-" ]; then
    print_message info "extracting links from standard input"
    grep -oPrh 'https?://\S+' - | \
    sed 's/[",<>()]//g' | \
    sort -u
elif [ -d "$1" ]; then
    print_message info "extracting links in folder $1"
    find "$1" -type f -exec grep -oPrh 'https?://\S+' {} + 2>/dev/null | \
    sed 's/[",<>()]//g' | \
    sort -u
elif [ -f "$1" ]; then
    print_message info "extracting links from file $1"
    grep -oPrh 'https?://\S+' "$1" 2>/dev/null | \
    sed 's/[",<>()]//g' | \
    sort -u
else
    print_message error "Error: '$1' is not a valid file or directory."
    exit 1
fi

