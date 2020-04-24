#!/bin/zsh

##
# Prompt string is first subjected to parameter expansion,
# command substitution and arithmetic expansion
setopt prompt_subst

# Enable colors in prompt
autoload -U colors && colors

# Enable Version Control Systems to print current git's repository information
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' check-for-changes true
zstyle ':vcs_info:git*' get-revision true
zstyle ':vcs_info:git*' formats ' %b %u%f'
zstyle ':vcs_info:git*' actionformats ' %b %u%f'

source "$(dirname "$0")/internal/core.zsh"
