#!/bin/bash
#!/bin/bash

# Ensure LOG_MESSAGE_PATH is set
if [[ -z "$LOG_MESSAGE_PATH" ]]; then
  echo "LOG_MESSAGE_PATH is not set."
  exit 1
fi

source "$LOG_MESSAGE_PATH"

update_files() {
    local old_filename="$1"
    local new_filename="$2"
    local update_dir="$3"
    local gep_temp_file=$(mktemp)

    # Escape special characters for sed
    old_filename_escaped=$(printf '%s\n' "$old_filename" | sed 's/[.[\*^$]/\\&/g')
    new_filename_escaped=$(printf '%s\n' "$new_filename" | sed 's/[.[\*^$]/\\&/g')

    # Store the results of grep in the temporary file
    grep -rwl "$old_filename_escaped" "$update_dir" >"$gep_temp_file"

    while IFS= read -r update_file; do
        print_message info "Updating file: $update_file"

        # Check if the file is binary or image or font
        if file "$update_file" | grep -qi 'binary \|image \|font '; then
            print_message warning "Skipping binary file: $update_file"
            continue
        fi

        print_message info "Replacing $old_filename with $new_filename"

        # Use sed to replace occurrences of old_filename with new_filename
        sed -i "s/\b$old_filename_escaped\b/$new_filename_escaped/g" "$update_file"
    done <"$gep_temp_file"
    rm "$gep_temp_file"
}

# Function to display usage
usage() {
    print_message info "Usage: $(basename "$0") --renames=<dirs,...> --updates=<dirs,...>"
    print_message info "  --renames  : Comma-separated list of directories containing files to rename"
    print_message info "  --updates  : Comma-separated list of directories containing files to update with new names"
    print_message info "This script renames files in the specified directories using base64 encoding and updates references to the old names in other files."
    exit 1
}

# Parse command-line arguments
for arg in "$@"; do
    case $arg in
    --renames=*)
        IFS=',' read -r -a renames <<<"${arg#*=}"
        ;;
    --updates=*)
        IFS=',' read -r -a updates <<<"${arg#*=}"
        ;;
    *)
        usage
        ;;
    esac
done

# Check if both arrays are set
if [ -z "${renames+x}" ] || [ -z "${updates+x}" ]; then
    usage
fi

# Echo message for the start
print_message info "Renaming files in directories: ${renames[*]}"

# Rename files
for rename_dir in "${renames[@]}"; do

    find_temp_file=$(mktemp)

    find "$rename_dir" -type f >"$find_temp_file"
    while IFS= read -r rename; do

        print_message info "Found file: $rename"

        old_filename=$(basename "$rename")

        if [[ "${old_filename##*.}" == "$old_filename" ]]; then
            print_message warning "$old_filename has no extension."
            continue
        fi

        if [[ "$old_filename" == .* ]]; then
            print_message warning "$old_filename is a dotfile, skipping"
            continue
        fi

        if [[ "$old_filename" == "favicon.ico" ]]; then
            print_message warning "Skipping favicon.ico"
            continue
        fi

        # crypt the old filename
        response="$(base64-rename -q "$rename")"
        print_message info "$response"

        # get the crypted filename
        new_filename=${response##*\ }
        new_filename="$(basename "$new_filename")"

        print_message info "new encrypted filename: $new_filename"

        # Update references in other files
        for update_dir in "${updates[@]}"; do
            print_message info "Checking directory: $update_dir"

            update_files "$old_filename" "$new_filename" "$update_dir"

        done
    done <"$find_temp_file"
    # Clean up the temporary file
    rm "$find_temp_file"

done

print_message success "Task done"
