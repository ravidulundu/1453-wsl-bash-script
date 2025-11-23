#!/bin/bash
# 1453 WSL Architect - Theme Configuration
# Description: Defines the 24-bit TrueColor palette and style constants
# Based on Blueprint: docs/reports/dev-kurulun-cli-prd.md

# ==============================================================================
# COLOR PALETTE (24-bit TrueColor)
# ==============================================================================

# Primary Brand Colors
# Crimson: Used for main headers, borders of primary actions, and brand identity
export COLOR_CRIMSON="#DC143C"
export COLOR_CRIMSON_FG="212"  # Approximate ANSI for fallback

# Gold: Used for secondary borders, icons, and highlights
export COLOR_GOLD="#FFD700"
export COLOR_GOLD_FG="220"     # Approximate ANSI for fallback

# UI Colors
# Off-White: Standard text color for readability
export COLOR_TEXT="#F5F5F5"
export COLOR_TEXT_FG="255"

# Muted: Used for subtitles, descriptions, and less important text
export COLOR_MUTED="#A0A0A0"
export COLOR_MUTED_FG="247"

# Status Colors
# Red: Errors, critical warnings, destructive actions
export COLOR_ERROR="#FF0000"
export COLOR_ERROR_FG="196"

# Teal: Success messages, completed steps
export COLOR_SUCCESS="#008080"
export COLOR_SUCCESS_FG="30"

# Orange: Warnings, attention needed
export COLOR_WARNING="#FFA500"
export COLOR_WARNING_FG="214"

# Blue: Information, active states
export COLOR_INFO="#1E90FF"
export COLOR_INFO_FG="33"

# ==============================================================================
# GUM STYLE CONSTANTS
# ==============================================================================

# Borders
export STYLE_BORDER_ROUNDED="rounded"
export STYLE_BORDER_DOUBLE="double"
export STYLE_BORDER_NORMAL="normal"

# Icons
export ICON_SUCCESS="✅"
export ICON_ERROR="❌"
export ICON_WARNING="⚠️"
export ICON_INFO="ℹ️"
export ICON_QUESTION="❓"
export ICON_ROCKET="🚀"
export ICON_GEAR="⚙️"
export ICON_PACKAGE="📦"

# ==============================================================================
# ANSI ESCAPE CODES (For non-Gum fallback)
# ==============================================================================
export ANSI_CRIMSON="\033[38;2;220;20;60m"
export ANSI_GOLD="\033[38;2;255;215;0m"
export ANSI_RESET="\033[0m"
