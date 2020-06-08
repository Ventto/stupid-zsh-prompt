#!/bin/zsh

typeset -g SZP_LEFT_PROMPT_ELEMENTS=(
    # ===============[ Line #1 ]===============
    date            # current date
    cdir            # current directory
    vcs             # git status
    python_venv
    # ===============[ Line #2 ]===============
    newline         # \n
    cmd_timer       # command execution time
    cmd_status      # command status
)

# ============================================
#                  Formats
# ============================================

typeset -g SZP_FIRSTLINE_PREFIX_FMT='╭─'
typeset -g SZP_LASTLINE_PREFIX_FMT='╰─'
typeset -g SZP_DATE_FMT='%D{%H:%M}'

##
# Description:
#
#   Ex: typeset -g SZP_CDIR_FMT='  %(5~|%-1~/…/%3~|%~)'
#
# This checks, if the path is at least 5 elements long (%(5~|true|false)) and,
# if true, prints the first element (%-1~), some dots (/…/) and
# the last 3 elements otherwise the full path is printed %~.
#
# N.B: `/home/user` counts for 2.
#
typeset -g SZP_CDIR_FMT='  %(5~|%-1~/…/%3~|%~)'
typeset -g SZP_CMD_STATUS_SUCCESS_FMT=''
typeset -g SZP_CMD_STATUS_FAILURE_FMT=''
typeset -g SZP_CMD_TIMER_WAIT_FMT=' '
typeset -g SZP_CMD_TIMER_RESULT_FMT=' '

typeset -g SZP_SEPARATOR_LEFT_FMT=''
typeset -g SZP_SEPARATOR_RIGHT_FMT=''

# ============================================
#                   Colors
# ============================================

typeset -g SZP_CMD_TIMER_COLORS=( yellow black )
typeset -g SZP_DATE_COLORS=( blue black )
typeset -g SZP_CDIR_COLORS=( white black)
typeset -g SZP_VCS_COLORS=( yellow black )
typeset -g SZP_CMD_STATUS_COLORS=( green black )
typeset -g SZP_PYTHON_VENV_COLORS=( yellow black )

# ============================================
#                 Visibility
# ============================================

typeset -g SZP_VCS_I_IS_VISIBLE=1
