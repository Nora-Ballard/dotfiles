
export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES

# enable mouse scrolling in less
export LESS='$LESS --mouse --wheel-lines=3 --no-init --quit-if-one-screen -r'
_byobu_sourced=1 . /usr/bin/byobu-launch 2>/dev/null || true
