#!/bin/bash

# Source the logging script
if [[ -z "$LOG_MESSAGE_PATH" ]]; then
    # Fallback to a simple echo if the logger isn't found.
    print_message() {
        # Simple logger: level in brackets, then message.
        # e.g. [info] Doing a thing.
        echo "[$1] $2"
    }
    print_message warning "LOG_MESSAGE_PATH is not set. Using fallback logger."
else
    source "$LOG_MESSAGE_PATH"
fi

# Function to display usage
usage() {
    print_message info "Usage: $0 <tool-name> [binary-name] [-h|--help]"
    print_message info "Description:"
    print_message info "  Prints the installation path of a tool managed by asdf and finds a binary within it."
    print_message info "  - <tool-name>: The name of the asdf tool (e.g., node, python, ruby)."
    print_message info "  - [binary-name]: Optional. The name of the binary to find. Defaults to <tool-name>."
    print_message info "  - -h|--help: Show this help message and exit."
}

# Main script logic
main() {
    # Check for help option
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        usage
        exit 0
    fi

    # Check if the tool name is provided
    if [[ -z "$1" ]]; then
        print_message error "No tool name provided."
        usage
        exit 1
    fi

    local tool_name="$1"
    local binary_name="$2"

    if [[ -z "$binary_name" ]]; then
        binary_name="$tool_name"
    fi

    # Check if asdf command exists
    if ! command -v asdf &> /dev/null; then
        print_message error "asdf command not found. Please ensure asdf is installed and in your PATH."
        exit 1
    fi

    # Get the path using asdf where
    local tool_path
    tool_path=$(asdf where "$tool_name")
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        print_message error "Failed to find installation path for '$tool_name' with asdf. It might not be installed or the plugin may be missing."
        exit 1
    fi

    if [[ -z "$tool_path" ]]; then
        print_message error "asdf did not return a path for '$tool_name'."
        exit 1
    fi

    # Print the raw path to stdout for piping or capture
    print_message info "$tool_path"

    local binary_paths
    readarray -t binary_paths < <(find "$tool_path" -type f -name "$binary_name" -executable -exec file {} \; | cut -d: -f1)

    if [[ ${#binary_paths[@]} -eq 0 ]]; then
        print_message warning "No executable named '$binary_name' found in '$tool_path'."
        exit 1
    fi

    print_message info "Binary path: ${binary_paths[0]}"

    print_message info "Finding asdf shims directory..."
    local shim_path
    shim_path=$(asdf which "$tool_name")
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        print_message error "Failed to find shim path for '$tool_name' with asdf which."
        print_message error "This can happen if the tool doesn't have a shim for the main binary."
        exit 1
    fi

    local shims_dir
    shims_dir=$(dirname "$shim_path")

    if [[ ! -d "$shims_dir" ]]; then
        print_message error "asdf shims directory not found at '$shims_dir'."
        exit 1
    fi

    print_message info "Found asdf shims directory: $shims_dir"

    local binary_to_link="${binary_paths[0]}"
    local symlink_path="$shims_dir/$binary_name"

    print_message info "Creating symlink from '$binary_to_link' to '$symlink_path'."

    if ln -sf "$binary_to_link" "$symlink_path"; then
        print_message info "Successfully created symlink."
    else
        print_message error "Failed to create symlink."
        exit 1
    fi
}

# Execute the main function with all provided arguments
main "$@"
