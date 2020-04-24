#!/bin/zsh

typeset -g MYPROMPT_LEFT_PROMPT_ELEMENTS=(
    # ===============[ Line #1 ]===============
    cmd_timer       # command execution time
    date            # current date
    cdir            # current directory
    vcs             # git status
    # ===============[ Line #2 ]===============
    newline         # \n
    cmd_status      # command status
)

# ============================================
#                  Formats
# ============================================

typeset -g MYPROMPT_FIRSTLINE_PREFIX_FMT='╭─'
typeset -g MYPROMPT_LASTLINE_PREFIX_FMT='╰─'
typeset -g MYPROMPT_DATE_FMT='%D{%H:%M}'
typeset -g MYPROMPT_CDIR_FMT='  %~'
typeset -g MYPROMPT_CMD_STATUS_SUCCESS_FMT=''
typeset -g MYPROMPT_CMD_STATUS_FAILURE_FMT=''
typeset -g MYPROMPT_CMD_TIMER_WAIT_FMT=' '
typeset -g MYPROMPT_CMD_TIMER_RESULT_FMT=' '

typeset -g MYPROMPT_SEPARATOR_LEFT_FMT=''
typeset -g MYPROMPT_SEPARATOR_RIGHT_FMT=''

# ============================================
#                   Colors
# ============================================


typeset -g MYPROMPT_CMD_TIMER_COLORS=( yellow black )
typeset -g MYPROMPT_DATE_COLORS=( blue black )
typeset -g MYPROMPT_CDIR_COLORS=( white black)
typeset -g MYPROMPT_VCS_COLORS=( yellow black )
typeset -g MYPROMPT_CMD_STATUS_COLORS=( green black )

# ============================================
#                 Visibility
# ============================================

typeset -g MYPROMPT_VCS_I_IS_VISIBLE=1
