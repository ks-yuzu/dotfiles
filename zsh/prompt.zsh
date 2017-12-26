autoload -Uz add-zsh-hook

## tmux info disp
function disp-tmux-info()
{
    if [ $(perl -e "print '$TERM' =~ /screen/ ? 1 : 0") -eq 0 ] && return
    
    local NUM_SESSIONS=$(tmux list-sessions | wc -l)
    local NUM_WINDOWS=$( tmux list-windows  | wc -l)

    local CURR_SESSION_ID=$(tmux display -p '#S')
    local CURR_WINDOW_ID=$( tmux display -p '#I')

    local CURR_SESSION_NUM=$(tmux ls  | grep -n "^$CURR_SESSION_ID" | perl -ne 'print /^(\d+)/')
    local CURR_WINDOW_NUM=$( tmux lsw | grep -n "^$CURR_WINDOW_ID"  | perl -ne 'print /^(\d+)/')

    echo -n "W $CURR_WINDOW_NUM/$NUM_WINDOWS (WID:$CURR_WINDOW_ID), S $CURR_SESSION_NUM/$NUM_SESSIONS (SID:$CURR_SESSION_ID)"
}

function disp-tmux-info-mini()
{
    
    if [ $(perl -e "print '$TERM' =~ /screen/ ? 1 : 0") -eq 0 ] && return

    local NUM_SESSIONS=$(tmux list-sessions | wc -l)
    local NUM_WINDOWS=$( tmux list-windows  | wc -l)

    local CURR_SESSION_ID=$(tmux display -p '#S')
    local CURR_WINDOW_ID=$( tmux display -p '#I')

    local CURR_SESSION_NUM=$(tmux ls  | grep -n "^$CURR_SESSION_ID" | perl -ne 'print /^(\d+)/')
    local CURR_WINDOW_NUM=$( tmux lsw | grep -n "^$CURR_WINDOW_ID"  | perl -ne 'print /^(\d+)/')

    echo -n "W:$CURR_WINDOW_NUM/$NUM_WINDOWS S:$CURR_SESSION_NUM/$NUM_SESSIONS"
}

function disp-tmux-info-for-prompt()
{
    if [ $(perl -e "print '$TERM' =~ /screen/ ? 1 : 0") -eq 0 ] && return
    echo -n "["
    echo -n $(disp-tmux-info-mini)
    echo -n "] "
}




## prompt

function update-prompt()
{
    local tmuxinfo="%F{magenta}$(disp-tmux-info-for-prompt)%f"
    local name="%F{green}%n@%m%f"
    local cdir="%F{yellow}%~%f"
    local endl=$'\n'
    local mark="%B%(?,%F{green},%F{red})%(!,#,>)%f%b "

    PROMPT="$name $tmuxinfo$cdir $endl$mark"
}

add-zsh-hook precmd update-prompt


# rev prompt
autoload -Uz vcs_info
autoload -Uz colors
colors

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' max-exports 6 # max number of variables in format
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' formats '%b@%r' '%c' '%u'
zstyle ':vcs_info:git:*' actionformats '%b@%r|%a' '%c' '%u'

setopt prompt_subst

function rprompt
{
    local repo=$(vcs_echo)
    local dir=$(get-path-from-git-root)
    if [ ! -z $repo -o ! -z $dir ]; then
        echo "[$repo /$dir]"
    elif [ ! -z $repo -o -z $dir ]; then
        echo "[$repo /]"
    fi

}

function vcs_echo
{
    STY= LANG=en_US.UTF-8 vcs_info
    local st=`git status 2> /dev/null`
    if [[ -z "$st" ]]; then return; fi
    local branch="$vcs_info_msg_0_"
    local color
    if   [[ -n "$vcs_info_msg_1_" ]];                then color=${fg[yellow]} # staged
    elif [[ -n "$vcs_info_msg_2_" ]];                then color=${fg[red]}    # unstaged
    elif [[ -n $(echo "$st" | grep "^Untracked") ]]; then color=${fg[cyan]}   # untracked
    else                                                  color=${fg[green]}
    fi

    echo "%{$color%}$branch%{$reset_color%}" | sed -e s/@/"%F{white}@%f%{$color%}"/
}

RPROMPT='$(rprompt)'

## period
function show-time()
{
    echo ""
    LC_ALL=c date | perl -pe 's/^(.*)$/(\1)/'
}

PERIOD=30
add-zsh-hook periodic show-time


## rev-prompt
# autoload -Uz vcs_info
# autoload -Uz colors
# colors
# autoload -Uz add-zsh-hook
# setopt prompt_subst
# zstyle ':vcs_info:*' enable git
# zstyle ':vcs_info:git:*' check-for-changes true
# zstyle ':vcs_info:git:*' stagedstr "%{$fg[yellow]%}+"
# zstyle ':vcs_info:git:*' unstagedstr "%{$fg[red]%}!"
# #zstyle ':vcs_info:*'     formats       "%{$fg[green]%}%c%u[%b]%{$reset_color%}"
# #zstyle ':vcs_info:*'     actionformats '[%b|%a]'
# #precmd () { vcs_info }
# #RPROMPT='${vcs_info_msg_0_}'


# zstyle ':vcs_info:git:stagedstr:*:' S
# zstyle ':vcs_info:git:unstagedstr:*' U
# zstyle ':vcs_info:*' formats "%{${fg[green]}%}[%b] %{${fg_bold[red]}%}%c%u%{${reset_color}%}"

#  PROMPT="$PROMPT_USERHOST $PROMPT_TIME $vcs_info_msg_0_ $PROMPT_STATUS"

# update_vcs_info () {
#     vcs_info
#     RPROMPT="$vcs_info_msg_0_"
# }
# add-zsh-hook precmd update_vcs_info  # precmd フックへの登録






# autoload -Uz VCS_INFO_get_data_git; VCS_INFO_get_data_git 2> /dev/null

# function rprompt-git-current-branch {
#         local name st color gitdir action
#         if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
#                 return
#         fi

#         name=`git rev-parse --abbrev-ref=loose HEAD 2> /dev/null`
#         if [[ -z $name ]]; then
#                 return
#         fi

#         gitdir=`git rev-parse --git-dir 2> /dev/null`
#         action=`VCS_INFO_git_getaction "$gitdir"` && action="($action)"

# 		if [[ -e "$gitdir/rprompt-nostatus" ]]; then
# 		   echo "$name$action "
# 		   		return
# 				fi

#         st=`git status 2> /dev/null`
# 		if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
# 		   color=%F{green}
# 		   elif [[ -n `echo "$st" | grep "^nothing added"` ]]; then
# 		   		color=%F{yellow}
# 				elif [[ -n `echo "$st" | grep "^# Untracked"` ]]; then
#                 color=%B%F{red}
#         else
#                 color=%F{red}
#         fi

#         echo "$color$name$action%f%b"
# }

function get-path-from-git-root
{
	git rev-parse --show-prefix 2> /dev/null
}


# remake prompt-meswhen showing prompt
# setopt prompt_subst

# RPROMPT='[`rprompt-git-current-branch``relative-path`]' #%~]'
