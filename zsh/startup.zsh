## tmux自動起動
#Start tmux on every shell login
#https://wiki.archlinux.org/index.php/Tmux#Start_tmux_on_every_shell_login
if which tmux 2>&1 >/dev/null; then
    #if not inside a tmux session, and if no session is started, start a new session
 #   test -z "$TMUX" && (tmux attach || tmux new-session)
fi
