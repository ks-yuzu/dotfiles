# peco-history
function peco-select-history()
{
    local tac
    if which tac > /dev/null; then
	tac="tac"
    else
        tac="tail -r"
    fi

    BUFFER=$(\history -n 1 | \
    eval $tac | \
    peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history



# peco snippet
function peco-snippets()
{
    local snippets="$HOME/.dotfiles/zsh/snippets.txt"

    if [ ! -e "$snippets" ]; then
        echo "$snippets is not found." >&2
        return 1
    fi

    local line="$(grep -v "^#" "$snippets" | peco --query "$LBUFFER")"
    if [ -z "$line" ]; then
        return 1
    fi
    
    local snippet="$(echo "$line" | sed "s/^\[[^]]*\] *//g")"
    if [ -z "$snippet" ]; then
        return 1
    fi

    BUFFER=$snippet
    zle clear-screen
}

zle -N peco-snippets
bindkey '^x^x' peco-snippets



# peco cheatsheet
function peco-sni-cs()
{
	local cspath="$HOME/works/cheatsheet/.snip-peco-cheatsheet"
	
    if [ ! -e "$cspath" ]; then
        echo "$cspath is not found." >&2
        return 1
    fi

    local line="$(grep -v "^#" $cspath | peco --query "$LBUFFER")"
    if [ -z "$line" ]; then
        return 1
    fi
    
    local snippet="$(echo "$line" | sed "s/^\[[^]]*\] *//g")"
    if [ -z "$snippet" ]; then
        return 1
    fi

    BUFFER=$snippet
    zle clear-screen
}

zle -N peco-sni-cs
bindkey '^xc' peco-sni-cs



# peco-process-kill
function peco-pkill()
{
    for pid in `ps u | peco | awk '{ print $2 }'`
	do
	    kill $pid
		echo "killed ${pid}"
	done
}
alias pk="peco-pkill"

# peco-process-kill-all
function peco-pkill-all()
{
    for pid in `ps -aux | peco | awk '{ print $2 }'`
	do
	    sudo kill $pid
		echo "killed ${pid}"
	done
}
alias pka="peco-pkill-all"



# peco-get-fullpath
function peco-get-fullpath()
{
    local fullpath
	fullpath=$(find `pwd` -maxdepth 1 -mindepth 1 | peco)
    echo "${fullpath}" | clip
	echo "copied ${fullpath}"
}
alias fullpath="peco-get-fullpath"



# peco-cd
function peco-cd()
{
	while true
	do
		local selected_dir=$(ls -al | grep / | awk '{print $9}' | peco 2> /dev/null)

		if [ "$selected_dir" = "./" ]; then
			BUFFER=""
			break;
		fi

		if [ -n "$selected_dir" ]; then
			BUFFER="cd ${selected_dir}"
			zle accept-line
			cd "$selected_dir"
		else
			break;
		fi
	done
	zle clear-screen
}
zle -N peco-cd
bindkey '^x^f' peco-cd



# peco-nmcli-wifi-connect
function peco-wlcon()
{
	local ssid=$(nmcli dev wifi list | tail -n +2 | peco --query "$*" | awk '{print $1}' | sed "s/'//g")
	print -z "nmcli dev wifi connect \"${ssid}\" password\ "
}
alias wlcon="peco-wlcon"


# peco-git-add
function peco-git-add()
{
    local SELECTED_FILE_TO_ADD="$(git status --porcelain | \
                                  peco --query "$LBUFFER" | \
                                  awk -F ' ' '{print $NF}')"
    if [ -n "$SELECTED_FILE_TO_ADD" ]; then
      BUFFER="git add $(echo "$SELECTED_FILE_TO_ADD" | tr '\n' ' ')"
      CURSOR=$#BUFFER
    fi
    zle accept-line
    # zle clear-screen
}
zle -N peco-git-add
bindkey "^g^a" peco-git-add

function peco-pcd()
{
	local path=$(cat -)

	if [ -n "$selected_dir" ]; then
		BUFFER="cd ${selected_dir}"
		zle accept-line
		cd "$selected_dir"
	else
		break;
	fi
	zle clear-screen
}
zle -N peco-pcd
#bindkey '' pcd

function pecorm()
{
    rm $(ls -a | peco)
}


function peco-ssh () {
  local selected_host=$(awk '
  tolower($1)=="host" {
    for (i=2; i<=NF; i++) {
      if ($i !~ "[*?]") {
        print $i
      }
    }
  }
  ' ~/.ssh/config | sort | peco --query "$LBUFFER")
  if [ -n "$selected_host" ]; then
    BUFFER="ssh ${selected_host}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ssh
bindkey '^\' peco-ssh

function sp()
{
    ssh $(grep -E '^Host' /home/yuzu/.ssh/config | perl -ne '
      m/Host\s+.*?(\S+)(\s+(\S+))?/;
      printf "[ %-9s ] $1\n", $3;
    ' | grep -vE 'bitbucket|gitlab|lab-router' | peco | sed -e 's/^\[.*\] //g')
}
