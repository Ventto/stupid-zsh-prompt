#!/bin/zsh

source "$(dirname "$0")/settings.zsh"

function _szp_count() {
    SZP_PROMPT_SIZE=$(($SZP_PROMPT_SIZE + ${#1}))
}

function _szp_separator() {
    local _symbol="$1"
    local _bg_color="$2"
    local _fg_color="$3"

    local bg_tag=""
    local fg_tag=""

    [ "$_bg_color" != "" ] && bg_tag="%{\$bg[${_bg_color}]%}"
    [ "$_fg_color" != "" ] && fg_tag="%{\$fg[${_fg_color}]%}"

    _szp_count "$_symbol"
    echo -n "${bg_tag}${fg_tag}${_symbol}%{\$reset_color%}"
}

function _szp_block() {
    local _content="$1"
    local _bg_color="$2"
    local _fg_color="$3"

    local separator="$(_szp_separator "$SZP_SEPARATOR_LEFT_FMT" '' "${_bg_color}")"
    local begin_color_cfg="%{\$bg[${_bg_color}]%}%{\$fg[${_fg_color}]%}"

    export PROMPT="${PROMPT}${separator}${begin_color_cfg}${_content}"
}

function _szp_prompt_cmd_status() {
    local _pipestatus="$1"

    local rc="${_pipestatus##*' '}"

    if [ "$rc" -eq 0 ]; then
        local cmd_state_fmt="$SZP_CMD_STATUS_SUCCESS_FMT"
        SZP_CMD_STATUS_COLORS=( green black )
    else
        local cmd_state_fmt="$SZP_CMD_STATUS_FAILURE_FMT"
        SZP_CMD_STATUS_COLORS=( red black )
    fi

    _szp_block " ${_pipestatus} ${cmd_state_fmt}" "$SZP_CMD_STATUS_COLORS[1]" "$SZP_CMD_STATUS_COLORS[2]"

    # Whitespace before command line
    export PROMPT="${PROMPT} "
}

function _szp_prompt_date() {
    _szp_block " $SZP_DATE_FMT " "$SZP_DATE_COLORS[1]" "$SZP_DATE_COLORS[2]"
    _szp_count " $(date +%H:%M) "
}

function _szp_prompt_cmd_timer() {
    function time_ms_to_human_readable() {
        local _time="$1"

        local tmp
        while [ "$_time" -ge 1000 ]; do
            tmp="$_time"
            tmp=$((tmp / 1000))
            if [ "$tmp" -ge 60 ]; then
                tmp=$((tmp / 60))
                if [ "$tmp" -ge 60 ]; then
                    tmp=$((tmp / 60))
                    if [ "$tmp" -ge 24 ]; then
                        tmp=$((tmp / 24))
                        echo -n "${tmp}d "
                        _time=$(($_time-($tmp*86400000)))
                    else
                        echo -n "${tmp}h "
                        _time=$(($_time-($tmp*3600000)))
                    fi
                else
                    echo -n "${tmp}m "
                    _time=$(($_time-($tmp*60000)))
                fi
            else
                echo -n "${tmp}s "
                _time=$(($_time-($tmp*1000)))
            fi
        done
        echo -n "${_time}ms "
    }
    if [ -n "$_szp_cmd_timer" ]; then
        local cmd_time="$(time_ms_to_human_readable "$_szp_cmd_timer")"
        cmd_time="${SZP_CMD_TIMER_RESULT_FMT} ${cmd_time}"
    else
        local cmd_time="${SZP_CMD_TIMER_WAIT_FMT} "
    fi

    _szp_block "$cmd_time" "$SZP_CMD_TIMER_COLORS[1]" "$SZP_CMD_TIMER_COLORS[2]"
    _szp_count "$cmd_time"
}

function _szp_prompt_cdir() {
    _szp_block " $SZP_CDIR_FMT " "$SZP_CDIR_COLORS[1]" "$SZP_CDIR_COLORS[2]"
    # More 2 whitespace to include the icon + whitespace
    _szp_count "   $(pwd | sed -e "s%${HOME}%~%") "

}

function _szp_prompt_vcs() {
    [ -z "${vcs_info_msg_0_}" ] && return

    _szp_block  " ${vcs_info_msg_0_}" "$SZP_VCS_COLORS[1]" "$SZP_VCS_COLORS[2]"
    _szp_count " ${vcs_info_msg_0_} "
}

function _szp_prompt_eol() {
    local _last_colors=( "$1" )

    # Split string into array (based on whitespace character)
    _last_colors=("${(@s/ /)_last_colors}")

    export PROMPT="${PROMPT}%{\$reset_color%}$(_szp_separator "$SZP_SEPARATOR_RIGHT_FMT" '' "$_last_colors[1]")%{\$reset_color%}"
}

function _szp_prompt_newline() {
    local _colors="$1"

    _szp_prompt_eol "$_colors"

    # Complete the line before the next one
    export PROMPT="${PROMPT}$(_szp_complete_line "$(($COLUMNS-$SZP_PROMPT_SIZE-5))")"
    export PROMPT="${PROMPT}"$'\n'"${SZP_LASTLINE_PREFIX_FMT}"

    # Reset calculated prompt size
    SZP_PROMPT_SIZE=0
}

function _szp_update_block_visiblity() {
    SZP_VCS_IS_VISIBLE=$([ -n "$vcs_info_msg_0_" ] && echo 0 || echo 1)
}

function _szp_cmd_timer_stop() {
    if [ -n "$_szp_cmd_timer" ]; then
        local now=$(($(date +%s%0N)/1000000))
        local elapsed=$(($now - $_szp_cmd_timer))
        _szp_cmd_timer="$elapsed"
    fi
}

function _szp_complete_line() {
    if [ "$1" -le 0 ]; then
        return
    fi
    for i in {1.."$1"}; do echo -n '─'; done
}

function _szp_precmd() {
    local _pipestatus="$pipestatus"

    # Stop the command timer as soon as possible avoiding the shell overhead
    _szp_cmd_timer_stop

    # Populates Version Control Systems's variables
    vcs_info

    # Populates blocks visibility's variable
    _szp_update_block_visiblity

    local last_colors=()
    local elm=""

    for (( i = 1; i <= $#SZP_LEFT_PROMPT_ELEMENTS; i++ )) do
        elm="$SZP_LEFT_PROMPT_ELEMENTS[i]"

        # First item
        if [ "$i" -eq 1 ]; then
            export PROMPT="$SZP_FIRSTLINE_PREFIX_FMT"
            _szp_count "$SZP_FIRSTLINE_PREFIX_FMT"
        fi

        local elm_visible=""

        if [ "$elm" != "newline" ]; then
            elm_visible="SZP_${elm:u}_IS_VISIBLE"
            elm_visible="$(eval "echo \${${elm_visible}}")"

            if [ ! -z "$elm_visible" ] && [ "$elm_visible" = "1" ]; then
                continue
            fi
        fi

        case $elm in
            newline)    _szp_prompt_$elm "$last_colors";;
            cmd_status) _szp_prompt_$elm "$_pipestatus";;
            *) _szp_prompt_$elm;;
        esac

        ##
        # Must be place after _szp_prompt_* function calls because they can
        # update the colors (c.f _my_prompt_cmd_status() ).
        if [ "$elm" != "newline" ]; then
            last_colors="SZP_${elm:u}_COLORS"
            last_colors="$(eval "echo \${${last_colors}}")"
        fi
    done

    if [ "$elm" != "newline" ]; then
        _szp_prompt_eol "${last_colors}"
    fi

    # FIXME: whitespace option after block
    export PROMPT="${PROMPT} "
    unset _szp_cmd_timer
    unset SZP_PROMPT_SIZE
}

function _szp_preexec() {
    _szp_cmd_timer=$(($(date +%s%0N)/1000000))
}

function _szp_clean() {
    unset _szp_cmd_timer
}

precmd_functions=($precmd_functions _szp_precmd _szp_clean)
preexec_functions=($precmd_functions _szp_preexec)
