#!/bin/bash
# Global Constants Configuration
# Centralized numeric constants to replace magic numbers
# NOTE: Using 'declare -rx' to combine readonly (immutability) and export (subprocess availability)
#       This prevents accidental modification while ensuring proper variable propagation

# ==========================================
# Retry and Timeout Configuration
# ==========================================
# Default number of retry attempts for package installation
declare -rx MAX_PACKAGE_RETRIES=3

# Default number of retry attempts for system updates
declare -rx MAX_UPDATE_RETRIES=3

# Delay between retry attempts (seconds)
declare -rx RETRY_DELAY_SECONDS=2

# Network connection timeout (seconds)
declare -rx NETWORK_TIMEOUT_SECONDS=3

# APT repository update timeout (seconds)
declare -rx APT_UPDATE_TIMEOUT_SECONDS=10

# Sudo keepalive refresh interval (seconds)
declare -rx SUDO_KEEPALIVE_INTERVAL=60

# ==========================================
# Disk Space Requirements
# ==========================================
# Recommended minimum disk space (MB)
declare -rx RECOMMENDED_DISK_SPACE_MB=2000

# Warning threshold for disk space (MB)
declare -rx WARNING_DISK_SPACE_MB=1000

# ==========================================
# Shell Configuration
# ==========================================
# Bash history size (number of commands)
declare -rx BASH_HISTSIZE=100000

# Bash history file size (number of lines)
declare -rx BASH_HISTFILESIZE=200000

# Terminal color support
declare -rx TERM_COLOR_MODE="xterm-256color"

# ==========================================
# Menu and UI Constants
# ==========================================
# Sleep duration for user feedback (seconds)
declare -rx UI_FEEDBACK_DELAY=1

# Sleep duration after menu actions (seconds)
declare -rx MENU_ACTION_DELAY=2

# Sleep duration for transitions (seconds)
declare -rx TRANSITION_DELAY=3

# Read timeout for stdin cleanup (seconds)
declare -rx READ_TIMEOUT=0.01

# Read buffer size for stdin cleanup
declare -rx READ_BUFFER_SIZE=1000

# ==========================================
# File Permissions
# ==========================================
# Directory permissions (octal)
declare -rx DIR_PERMISSIONS=755

# File permissions (octal)
declare -rx FILE_PERMISSIONS=644

# Executable permissions (octal)
declare -rx EXEC_PERMISSIONS=755

# ==========================================
# Checksum Configuration
# ==========================================
# SHA algorithm version for checksums
declare -rx SHA_ALGORITHM=256

# Checksum display length (characters)
declare -rx CHECKSUM_DISPLAY_LENGTH=16

# Checksum compare length (characters)
declare -rx CHECKSUM_FULL_DISPLAY=32

# Note: All constants use 'declare -rx' for atomic readonly+export declaration.
# This ensures immutability (prevents accidental modification) while maintaining
# availability in sourced scripts and subprocesses.
