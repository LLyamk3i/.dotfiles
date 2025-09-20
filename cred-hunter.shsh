#!/bin/bash

# Source the logging script
if [[ -z "$LOG_MESSAGE_PATH" ]]; then
    print_message error "LOG_MESSAGE_PATH is not set."
    exit 1
fi
source "$LOG_MESSAGE_PATH"

# Function to display usage
usage() {
    print_message info "Usage: $0 <folder|file> [file1 file2 ...] [--output <output_folder>] [-h|--help]"
    print_message info "Description:"
    print_message info "  Extract credentials from .txt files in the specified folder, files, or piped input (stdin)."
    print_message info "  - <folder|file>: The folder containing .txt files or a single file to process."
    print_message info "  - [file1 file2 ...]: Optional list of additional files to process."
    print_message info "  - --output <output_folder>: Optional output folder for saving extracted credentials."
    print_message info "  - -h|--help: Show this help message and exit."
}

# Function to process a single file
process_file() {
    local file="$1"
    print_message info "Processing file: $file"

    # Check if the file exists and is readable
    if [[ ! -f "$file" || ! -r "$file" ]]; then
        print_message error "Failed to read file: $file"
        return
    fi

    # Read the file line by line
    while IFS= read -r line; do
        # Skip empty lines
        if [[ -z "$line" ]]; then
            continue
        fi

        # Replace spaces with colons
        line="${line// /:}"

        # Split the line into four parts using : as a delimiter
        IFS=: read -r part1 part2 login password <<< "$line"

        # Reconstruct the link by concatenating the first two parts with a colon
        link="${part1}:${part2}"

        # Use the full URL as the filename
        output_file="${output_folder:-.}/$(echo "$link" | tr -cd '[:alnum:]\n\r._-' | tr '/' '_').txt"
        # Check if the link already exists in the output file
        if grep -q "^$link$" "$output_file" > /dev/null 2>&1; then
            print_message info "Duplicate link found: $link"
            # Append credentials to the output file if the link already exists
            echo "$login:$password" >> "$output_file"
            continue
        fi

        # Check if the domain is alive using curl and capture the response
        response=$(curl -Is "$link" 2>&1)

        # Extract the first line of the curl response
        first_line=$(echo "$response" | head -n 1)

        # Log the first line of the curl response
        print_message info "Curl response for $link: $first_line"

        if [[ -n "$first_line" ]]; then
            # Append the link to the output file
            echo "$link" >> "$output_file"
            echo "$login:$password" >> "$output_file"
        else
            print_message warning "Could not reach server: $link."
        fi

    done < "$file"
}

# Main script logic
main() {
    # Check for help option
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        usage
        exit 0
    fi

args=("$@")


    # Check for optional --output argument
    output_folder=""
    for arg in "$@"; do
        if [[ "$arg" == --output=* ]]; then
            output_folder="${arg#--output=}"
            if [[ -z "$output_folder" ]]; then
                print_message error "Output folder not specified after --output."
                exit 1
            fi
            if [[ ! -d "$output_folder" ]]; then
                print_message error "Output folder does not exist: $output_folder"
                exit 1
            fi
            args=("${args[@]/--output=*}")
        fi
    done

    echo "${args[@]}"
    echo "$output_folder"
    exit;

    # Check if the first argument is provided
    if [[ -z "$1" ]]; then
        print_message error "No folder, file, or piped input provided."
        usage
        exit 1
    fi

    # Process the first argument (folder, file, or stdin)
    first_arg="${args[0]}"

    # Check if the first argument is a folder, file, or piped input
    if [[ -d "$first_arg" ]]; then
        # Process all .txt files in the folder
        for file in "$first_arg"/*.txt; do
            process_file "$file"
        done
    elif [[ -f "$first_arg" ]]; then
        # Process the single file
        process_file "$first_arg"
    elif [[ ! -t 0 ]]; then
        # Read from stdin
        while IFS= read -r line; do
            echo "$line" >> /tmp/stdin_input.txt
        done
        process_file "/tmp/stdin_input.txt"
        rm -f /tmp/stdin_input.txt
    else
        print_message error "Folder, file, or piped input not found: $first_arg"
        exit 1
    fi

    # Process additional files if provided
    if [[ $# -gt 0 ]]; then
        for file in "$@"; do
            process_file "$file"
        done
    fi

    print_message success "Processing completed successfully."
}

# Execute the main function
main "$@"
