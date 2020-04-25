#!/bin/zsh

source "$(dirname "$0")/settings.zsh"

function _mypt_count() {
    MYPROMPT_SIZE=$(($MYPROMPT_SIZE + ${#1}))
}

function _mypt_separator() {
    local _symbol="$1"
    local _bg_color="$2"
    local _fg_color="$3"

    local bg_tag=""
    local fg_tag=""

    [ "$_bg_color" != "" ] && bg_tag="%{\$bg[${_bg_color}]%}"
    [ "$_fg_color" != "" ] && fg_tag="%{\$fg[${_fg_color}]%}"

    _mypt_count "$_symbol"
    echo -n "${bg_tag}${fg_tag}${_symbol}%{\$reset_color%}"
}

function _mypt_block() {
    local _content="$1"
    local _bg_color="$2"
    local _fg_color="$3"

    local separator="$(_mypt_separator "$MYPROMPT_SEPARATOR_LEFT_FMT" '' "${_bg_color}")"
    local begin_color_cfg="%{\$bg[${_bg_color}]%}%{\$fg[${_fg_color}]%}"

    export PROMPT="${PROMPT}${separator}${begin_color_cfg}${_content}"
}

function _mypt_prompt_cmd_status() {
    local _pipestatus="$2"

    local rc="$(echo "$_pipestatus" | awk '{print $NF}')"

    if [ "$rc" -eq 0 ]; then
        local cmd_state_fmt="$MYPROMPT_CMD_STATUS_SUCCESS_FMT"
        MYPROMPT_CMD_STATUS_COLORS=( green black )
    else
        local cmd_state_fmt="$MYPROMPT_CMD_STATUS_FAILURE_FMT"
        MYPROMPT_CMD_STATUS_COLORS=( red black )
    fi

    _mypt_block " ${_pipestatus} ${cmd_state_fmt}" "$MYPROMPT_CMD_STATUS_COLORS[1]" "$MYPROMPT_CMD_STATUS_COLORS[2]"

    # Whitespace before command line
    export PROMPT="${PROMPT} "
}

function _mypt_prompt_date() {
    _mypt_block " $MYPROMPT_DATE_FMT " "$MYPROMPT_DATE_COLORS[1]" "$MYPROMPT_DATE_COLORS[2]"
    _mypt_count " $(date +%H:%M) "
}

function _mypt_prompt_cmd_timer() {
    function time_ms_to_human_readable() {
        local val="$1"

        if [ "$val" -ge 1000 ]; then
            val=$((val / 1000))
            if [ "$val" -ge 60 ]; then
                val=$((val / 60))
                if [ "$val" -ge 60 ]; then
                    val=$((val / 60))
                    if [ "$val" -ge 24 ]; then
                        val=$((val / 24))
                        printf '%s' "${val}d "
                        time_ms_to_human_readable $(($1-($val*24*60*60*1000)))
                    else
                        printf '%s' "${val}h "
                        time_ms_to_human_readable $(($1-($val*60*60*1000)))
                    fi
                else
                    printf '%s' "${val}m "
                    time_ms_to_human_readable $(($1-($val*60*1000)))
                fi
            else
                printf '%s' "${val}s "
                time_ms_to_human_readable $(($1-($val*1000)))
            fi
        else
            printf '%s' "${val}ms "
        fi
    }
    if [ -n "$_mypt_cmd_timer" ]; then
        local cmd_time="$(time_ms_to_human_readable "$_mypt_cmd_timer")"
        cmd_time="${MYPROMPT_CMD_TIMER_RESULT_FMT} ${cmd_time}"
    else
        local cmd_time="${MYPROMPT_CMD_TIMER_WAIT_FMT} "
    fi

    _mypt_block "$cmd_time" "$MYPROMPT_CMD_TIMER_COLORS[1]" "$MYPROMPT_CMD_TIMER_COLORS[2]"
    _mypt_count "$cmd_time"
}

function _mypt_prompt_cdir() {
    _mypt_block " $MYPROMPT_CDIR_FMT " "$MYPROMPT_CDIR_COLORS[1]" "$MYPROMPT_CDIR_COLORS[2]"
    # More 2 whitespace to include the icon + whitespace
    _mypt_count "   $(pwd | sed -e "s%${HOME}%~%") "

}

function _mypt_prompt_vcs() {
    [ -z "${vcs_info_msg_0_}" ] && return

    _mypt_block  " ${vcs_info_msg_0_}" "$MYPROMPT_VCS_COLORS[1]" "$MYPROMPT_VCS_COLORS[2]"
    _mypt_count " ${vcs_info_msg_0_} "
}

function _mypt_prompt_eol() {
    local _last_colors=( "$1" )

    # Split string into array (based on whitespace character)
    _last_colors=("${(@s/ /)_last_colors}")

    export PROMPT="${PROMPT}%{\$reset_color%}$(_mypt_separator "$MYPROMPT_SEPARATOR_RIGHT_FMT" '' "$_last_colors[1]")%{\$reset_color%}"
}

function _mypt_prompt_newline() {
    local _colors="$1"

    _mypt_prompt_eol "$_colors"

    # Complete the line before the next one
    export PROMPT="${PROMPT}$(_mypt_complete_line "$(($COLUMNS-$MYPROMPT_SIZE-5))")"
    export PROMPT="${PROMPT}"$'\n'"${MYPROMPT_LASTLINE_PREFIX_FMT}"

    # Reset calculated prompt size
    MYPROMPT_SIZE=0
}

function _mypt_update_block_visiblity() {
    MYPROMPT_VCS_IS_VISIBLE=$([ -n "$vcs_info_msg_0_" ] && echo 0 || echo 1)
}

function _mypt_cmd_timer_stop() {
    if [ -n "$_mypt_cmd_timer" ]; then
        local now=$(($(date +%s%0N)/1000000))
        local elapsed=$(($now - $_mypt_cmd_timer))
        _mypt_cmd_timer="$elapsed"
    fi
}

function _mypt_complete_line() {
    for i in {1.."$1"}; do echo -n '─'; done
}

function _mypt_precmd() {
    local _pipestatus="$1"

    # Stop the command timer as soon as possible avoiding the shell overhead
    _mypt_cmd_timer_stop

    # Populates Version Control Systems's variables
    vcs_info

    # Populates blocks visibility's variable
    _mypt_update_block_visiblity

    local last_colors=()
    local elm=""

    for (( i = 1; i <= $#MYPROMPT_LEFT_PROMPT_ELEMENTS; i++ )) do
        elm="$MYPROMPT_LEFT_PROMPT_ELEMENTS[i]"

        # First item
        if [ "$i" -eq 1 ]; then
            export PROMPT="$MYPROMPT_FIRSTLINE_PREFIX_FMT"
            _mypt_count "$MYPROMPT_FIRSTLINE_PREFIX_FMT"
        fi

        local elm_visible=""

        if [ "$elm" != "newline" ]; then
            elm_visible="MYPROMPT_${elm:u}_IS_VISIBLE"
            elm_visible="$(eval "echo \${${elm_visible}}")"

            if [ ! -z "$elm_visible" ] && [ "$elm_visible" = "1" ]; then
                continue
            fi
        fi

        # Same function name but not parameters
        case $elm in
            newline)    _mypt_prompt_$elm "$last_colors";;
            cmd_status) _mypt_prompt_$elm "middle" "$_pipestatus";;
            *) _mypt_prompt_$elm "middle" "";;
        esac

        ##
        # Must be place after _mypt_prompt_* function calls because they can
        # update the colors (c.f _my_prompt_cmd_status() ).
        if [ "$elm" != "newline" ]; then
            last_colors="MYPROMPT_${elm:u}_COLORS"
            last_colors="$(eval "echo \${${last_colors}}")"
        fi
    done

    if [ "$elm" != "newline" ]; then
        _mypt_prompt_eol "${last_colors}"
    fi

    # FIXME: whitespace option after block
    export PROMPT="${PROMPT} "
    unset _mypt_cmd_timer
    unset MYPROMPT_SIZE
}

function _mypt_preexec() {
    _mypt_cmd_timer=$(($(date +%s%0N)/1000000))
}

function precmd() {
    _mypt_precmd "$pipestatus"
    unset _mypt_cmd_timer
}

function preexec() {
    _mypt_preexec
}
