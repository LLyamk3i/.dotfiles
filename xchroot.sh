#!/bin/bash

# Script: xchroot
# Description: Helper script to mount and unmount a Debian chroot environment.
#              It handles the main partition mount (with Btrfs subvolume support)
#              and all necessary bind mounts for /dev, /sys, /proc, /dev/pts, /dev/shm,
#              and /etc/resolv.conf.

# --- Configuration ---
# Default base directory where your Debian chroot will be mounted.
# This can be overridden by passing a mount point parameter.
# Make sure this directory exists on your host system or will be created by the script.
DEFAULT_CHROOT_DIR="/mnt/debian_chroot"

# For Btrfs filesystems, specify the subvolume to mount.
# If your Debian is installed directly on the root of the partition (e.g., ext4),
# or you don't use a subvolume, you can remove '-o subvol=$BTRFS_SUBVOL' from the mount command.
BTRFS_SUBVOL="@"

# --- Functions ---

# Function to display the help message
show_help() {
    echo "Usage: $(basename "$0") [mount|umount|--help|-h] [DEVICE] [MOUNT_POINT]"
    echo ""
    echo "  mount DEVICE [MOUNT_POINT] : Mounts the specified DEVICE (e.g., /dev/sda1) to MOUNT_POINT"
    echo "                               (or ${DEFAULT_CHROOT_DIR} if not specified) and sets up all"
    echo "                               necessary bind mounts for the chroot environment."
    echo "                               DEVICE should be the main partition containing your Debian chroot."
    echo ""
    echo "  umount [MOUNT_POINT]       : Unmounts all bind mounts and the main partition from MOUNT_POINT"
    echo "                               (or ${DEFAULT_CHROOT_DIR} if not specified)."
    echo "                               Note: The DEVICE argument is not required for umount."
    echo ""
    echo "  -h, --help                 : Displays this help message."
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") mount /dev/sda1"
    echo "  $(basename "$0") mount /dev/sda1 /mnt/my_chroot"
    echo "  $(basename "$0") umount"
    echo "  $(basename "$0") umount /mnt/my_chroot"
    echo "  $(basename "$0") -h"
}

# Helper function to attempt unmounting in case of a failed mount, to clean up partially mounted filesystems.
do_umount_force_cleanup() {
    echo "Attempting to clean up partially mounted filesystems due to an error..."
    # Using 2>/dev/null to suppress "not mounted" errors for cleanup
    sudo umount "$CHROOT_DIR/etc/resolv.conf" 2>/dev/null
    sudo umount "$CHROOT_DIR/dev/shm" 2>/dev/null
    sudo umount "$CHROOT_DIR/dev/pts" 2>/dev/null
    sudo umount "$CHROOT_DIR/dev" 2>/dev/null
    sudo umount "$CHROOT_DIR/sys" 2>/dev/null
    sudo umount "$CHROOT_DIR/proc" 2>/dev/null
    sudo umount "$CHROOT_DIR/boot/efi" 2>/dev/null # Include if /boot/efi might be bind-mounted or part of chroot
    sudo umount "$CHROOT_DIR" 2>/dev/null
}

# Function to mount the chroot environment
do_mount() {
    local DEVICE="$1"
    local CHROOT_DIR="${2:-$DEFAULT_CHROOT_DIR}"

    if [ -z "$DEVICE" ]; then
        echo "Error: DEVICE is required for the 'mount' command."
        show_help
        exit 1
    fi

    echo "--- Mounting chroot environment ---"
    echo "Target directory: ${CHROOT_DIR}"
    echo "Main device: ${DEVICE}"

    # 1. Create the main chroot directory if it doesn't exist
    if [ ! -d "$CHROOT_DIR" ]; then
        echo "Creating main chroot directory: ${CHROOT_DIR}"
        sudo mkdir -p "$CHROOT_DIR" || { echo "Error: Failed to create ${CHROOT_DIR}."; exit 1; }
    fi

    # Check if the main chroot directory is already mounted
    if mountpoint -q "$CHROOT_DIR"; then
        echo "${CHROOT_DIR} is already mounted. Skipping main partition mount."
    else
        # 2. Mount the main Debian partition (with Btrfs subvolume option)
        echo "Mounting main partition ${DEVICE}..."
        # If not using Btrfs subvolumes, remove 'subvol=$BTRFS_SUBVOL'
        if sudo mount -o subvol=$BTRFS_SUBVOL "$DEVICE" "$CHROOT_DIR"; then
            echo "Successfully mounted ${DEVICE} to ${CHROOT_DIR}."
        else
            echo "Error: Failed to mount ${DEVICE} to ${CHROOT_DIR}."
            echo "Please check if the device (${DEVICE}) is correct, the subvolume (${BTRFS_SUBVOL}) is correct, or if there's an issue with the partition."
            exit 1
        fi
    fi

    # 3. Create necessary subdirectories for bind mounts inside the chroot
    echo "Creating necessary directories for bind mounts inside chroot..."
    for dir in "$CHROOT_DIR/dev" "$CHROOT_DIR/sys" "$CHROOT_DIR/proc" "$CHROOT_DIR/dev/pts" "$CHROOT_DIR/dev/shm"; do
        if [ ! -d "$dir" ]; then
            sudo mkdir -p "$dir" || { echo "Error: Could not create directory: $dir. Aborting."; do_umount_force_cleanup; exit 1; }
        fi
    done
    # Ensure /etc exists for resolv.conf, though it should in a valid chroot
    if [ ! -d "$CHROOT_DIR/etc" ]; then
        sudo mkdir -p "$CHROOT_DIR/etc" || { echo "Error: Could not create directory: $CHROOT_DIR/etc. Aborting."; do_umount_force_cleanup; exit 1; }
    fi


    # 4. Perform bind mounts for virtual filesystems and resolv.conf
    echo "Setting up bind mounts..."
    sudo mount --bind /dev "$CHROOT_DIR/dev" || { echo "Error: Failed to bind mount /dev."; do_umount_force_cleanup; exit 1; }
    sudo mount --bind /sys "$CHROOT_DIR/sys" || { echo "Error: Failed to bind mount /sys."; do_umount_force_cleanup; exit 1; }
    sudo mount --bind /proc "$CHROOT_DIR/proc" || { echo "Error: Failed to bind mount /proc."; do_umount_force_cleanup; exit 1; }
    sudo mount --bind /dev/pts "$CHROOT_DIR/dev/pts" || { echo "Error: Failed to bind mount /dev/pts."; do_umount_force_cleanup; exit 1; }
    sudo mount --bind /dev/shm "$CHROOT_DIR/dev/shm" || { echo "Error: Failed to bind mount /dev/shm."; do_umount_force_cleanup; exit 1; }
    sudo mount --bind /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf" || { echo "Error: Failed to bind mount /etc/resolv.conf. Check host's /etc/resolv.conf exists."; do_umount_force_cleanup; exit 1; }

    echo "--- Chroot environment successfully mounted! ---"
    echo "You can now enter the chroot using: sudo chroot ${CHROOT_DIR} /bin/bash"
    echo "Remember to 'exit' the chroot and then run '$(basename "$0") umount' when finished."
}

# Function to unmount the chroot environment
do_umount() {
    local CHROOT_DIR="${1:-$DEFAULT_CHROOT_DIR}"
    echo "--- Unmounting chroot environment ---"
    echo "Target directory: ${CHROOT_DIR}"

    # Check if the main chroot directory is actually mounted before attempting umounts
    if ! mountpoint -q "$CHROOT_DIR"; then
        echo "${CHROOT_DIR} is not mounted. Nothing to unmount."
        exit 0
    fi

    # Unmount virtual filesystems first (critical order for a clean unmount)
    echo "Unmounting bind mounts..."
    # Using 2>/dev/null to ignore errors if a specific mount isn't found (e.g., if previous mount failed)
    sudo umount "$CHROOT_DIR/dev/pts" 2>/dev/null && echo "  - Unmounted ${CHROOT_DIR}/dev/pts" || echo "  - Failed or not mounted: ${CHROOT_DIR}/dev/pts"
    sudo umount "$CHROOT_DIR/dev/shm" 2>/dev/null && echo "  - Unmounted ${CHROOT_DIR}/dev/shm" || echo "  - Failed or not mounted: ${CHROOT_DIR}/dev/shm"
    sudo umount "$CHROOT_DIR/etc/resolv.conf" 2>/dev/null && echo "  - Unmounted ${CHROOT_DIR}/etc/resolv.conf" || echo "  - Failed or not mounted: ${CHROOT_DIR}/etc/resolv.conf"
    sudo umount "$CHROOT_DIR/dev" 2>/dev/null && echo "  - Unmounted ${CHROOT_DIR}/dev" || echo "  - Failed or not mounted: ${CHROOT_DIR}/dev"
    sudo umount "$CHROOT_DIR/sys" 2>/dev/null && echo "  - Unmounted ${CHROOT_DIR}/sys" || echo "  - Failed or not mounted: ${CHROOT_DIR}/sys"
    sudo umount "$CHROOT_DIR/proc" 2>/dev/null && echo "  - Unmounted ${CHROOT_DIR}/proc" || echo "  - Failed or not mounted: ${CHROOT_DIR}/proc"

    # User mentioned /boot/efi in their umount list. It wasn't in the mount list, but
    # it's good practice to try unmounting if it might be mounted.
    if mountpoint -q "$CHROOT_DIR/boot/efi"; then
        sudo umount "$CHROOT_DIR/boot/efi" 2>/dev/null && echo "  - Unmounted ${CHROOT_DIR}/boot/efi" || echo "  - Failed or not mounted: ${CHROOT_DIR}/boot/efi"
    fi

    # Unmount the main chroot partition
    echo "Unmounting main chroot partition ${CHROOT_DIR}..."
    if sudo umount "$CHROOT_DIR"; then
        echo "Successfully unmounted ${CHROOT_DIR}."
    else
        echo "Error: Failed to unmount ${CHROOT_DIR}."
        echo "Some mounts might still be busy. You may need to manually unmount them"
        echo "or use 'sudo fuser -m ${CHROOT_DIR}' to find processes holding it open."
        echo "Then try 'sudo umount -l ${CHROOT_DIR}' (lazy unmount) or restart if persistent."
        exit 1
    fi
    echo "--- Chroot environment successfully unmounted! ---"
}

# --- Main Script Logic ---
case "$1" in
    mount)
        do_mount "$2" "$3"
        ;;
    umount)
        # Mount point can be specified as second argument for umount
        do_umount "$2"
        ;;
    -h|--help)
        show_help
        ;;
    *)
        echo "Invalid command or missing arguments."
        show_help
        exit 1
        ;;
esac
