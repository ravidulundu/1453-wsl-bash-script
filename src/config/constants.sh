#!/bin/bash
# Global Constants Configuration
# Centralized numeric constants to replace magic numbers

# ==========================================
# Retry and Timeout Configuration
# ==========================================
# Default number of retry attempts for package installation
readonly MAX_PACKAGE_RETRIES=3

# Default number of retry attempts for system updates
readonly MAX_UPDATE_RETRIES=3

# Delay between retry attempts (seconds)
readonly RETRY_DELAY_SECONDS=2

# Network connection timeout (seconds)
readonly NETWORK_TIMEOUT_SECONDS=3

# APT repository update timeout (seconds)
readonly APT_UPDATE_TIMEOUT_SECONDS=10

# Sudo keepalive refresh interval (seconds)
readonly SUDO_KEEPALIVE_INTERVAL=60

# ==========================================
# Disk Space Requirements
# ==========================================
# Recommended minimum disk space (MB)
readonly RECOMMENDED_DISK_SPACE_MB=2000

# Warning threshold for disk space (MB)
readonly WARNING_DISK_SPACE_MB=1000

# ==========================================
# Shell Configuration
# ==========================================
# Bash history size (number of commands)
readonly BASH_HISTSIZE=100000

# Bash history file size (number of lines)
readonly BASH_HISTFILESIZE=200000

# Terminal color support
readonly TERM_COLOR_MODE="xterm-256color"

# ==========================================
# Menu and UI Constants
# ==========================================
# Sleep duration for user feedback (seconds)
readonly UI_FEEDBACK_DELAY=1

# Sleep duration after menu actions (seconds)
readonly MENU_ACTION_DELAY=2

# Sleep duration for transitions (seconds)
readonly TRANSITION_DELAY=3

# Read timeout for stdin cleanup (seconds)
readonly READ_TIMEOUT=0.01

# Read buffer size for stdin cleanup
readonly READ_BUFFER_SIZE=1000

# ==========================================
# File Permissions
# ==========================================
# Directory permissions (octal)
readonly DIR_PERMISSIONS=755

# File permissions (octal)
readonly FILE_PERMISSIONS=644

# Executable permissions (octal)
readonly EXEC_PERMISSIONS=755

# ==========================================
# Checksum Configuration
# ==========================================
# SHA algorithm version for checksums
readonly SHA_ALGORITHM=256

# Checksum display length (characters)
readonly CHECKSUM_DISPLAY_LENGTH=16

# Checksum compare length (characters)
readonly CHECKSUM_FULL_DISPLAY=32

# ==========================================
# Export all constants
# ==========================================
export MAX_PACKAGE_RETRIES
export MAX_UPDATE_RETRIES
export RETRY_DELAY_SECONDS
export NETWORK_TIMEOUT_SECONDS
export APT_UPDATE_TIMEOUT_SECONDS
export SUDO_KEEPALIVE_INTERVAL

export RECOMMENDED_DISK_SPACE_MB
export WARNING_DISK_SPACE_MB

export BASH_HISTSIZE
export BASH_HISTFILESIZE
export TERM_COLOR_MODE

export UI_FEEDBACK_DELAY
export MENU_ACTION_DELAY
export TRANSITION_DELAY
export READ_TIMEOUT
export READ_BUFFER_SIZE

export DIR_PERMISSIONS
export FILE_PERMISSIONS
export EXEC_PERMISSIONS

export SHA_ALGORITHM
export CHECKSUM_DISPLAY_LENGTH
export CHECKSUM_FULL_DISPLAY
