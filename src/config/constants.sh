#!/bin/bash
# Global Constants Configuration
# Centralized numeric constants to replace magic numbers
# NOTE: Using export instead of readonly for proper variable propagation in sourced scripts

# ==========================================
# Retry and Timeout Configuration
# ==========================================
# Default number of retry attempts for package installation
export MAX_PACKAGE_RETRIES=3

# Default number of retry attempts for system updates
export MAX_UPDATE_RETRIES=3

# Delay between retry attempts (seconds)
export RETRY_DELAY_SECONDS=2

# Network connection timeout (seconds)
export NETWORK_TIMEOUT_SECONDS=3

# APT repository update timeout (seconds)
export APT_UPDATE_TIMEOUT_SECONDS=10

# Sudo keepalive refresh interval (seconds)
export SUDO_KEEPALIVE_INTERVAL=60

# ==========================================
# Disk Space Requirements
# ==========================================
# Recommended minimum disk space (MB)
export RECOMMENDED_DISK_SPACE_MB=2000

# Warning threshold for disk space (MB)
export WARNING_DISK_SPACE_MB=1000

# ==========================================
# Shell Configuration
# ==========================================
# Bash history size (number of commands)
export BASH_HISTSIZE=100000

# Bash history file size (number of lines)
export BASH_HISTFILESIZE=200000

# Terminal color support
export TERM_COLOR_MODE="xterm-256color"

# ==========================================
# Menu and UI Constants
# ==========================================
# Sleep duration for user feedback (seconds)
export UI_FEEDBACK_DELAY=1

# Sleep duration after menu actions (seconds)
export MENU_ACTION_DELAY=2

# Sleep duration for transitions (seconds)
export TRANSITION_DELAY=3

# Read timeout for stdin cleanup (seconds)
export READ_TIMEOUT=0.01

# Read buffer size for stdin cleanup
export READ_BUFFER_SIZE=1000

# ==========================================
# File Permissions
# ==========================================
# Directory permissions (octal)
export DIR_PERMISSIONS=755

# File permissions (octal)
export FILE_PERMISSIONS=644

# Executable permissions (octal)
export EXEC_PERMISSIONS=755

# ==========================================
# Checksum Configuration
# ==========================================
# SHA algorithm version for checksums
export SHA_ALGORITHM=256

# Checksum display length (characters)
export CHECKSUM_DISPLAY_LENGTH=16

# Checksum compare length (characters)
export CHECKSUM_FULL_DISPLAY=32

# Note: All constants are already exported inline above.
# No need for redundant export statements.
